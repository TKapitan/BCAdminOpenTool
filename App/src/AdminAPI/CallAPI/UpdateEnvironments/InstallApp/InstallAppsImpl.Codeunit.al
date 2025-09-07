codeunit 73284 TKAInstallAppsImpl
{
    Access = Internal;

    var
        NoOfInstalledApps, NoOfSkippedApps, NoOfNotFoundApps, NoMissingDependencies : Integer;
        NotFoundAppsDetailsTextBuilder, MissingDependenciesDetailsTextBuilder : TextBuilder;
        TenantTok: Label ' - Tenant: %1', Locked = true;
        EnvironmentTok: Label ' - Environment: %1', Locked = true;
        AppVersionTok: Label ' - Version: %1', Locked = true;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'R')]
    procedure RunInstallApps(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; var InstallAppsBuffer: Record TKAInstallAppsBuffer temporary; UseEnvironmentUpdateWindow: Boolean; InstallUpdateNeededDependencies: Boolean)
    begin
        NoOfInstalledApps := 0;
        NoOfSkippedApps := 0;
        NoOfNotFoundApps := 0;
        NoMissingDependencies := 0;
        if ManagedBCEnvironment.FindSet() then
            repeat
                if InstallAppsBuffer.FindSet() then
                    repeat
                        InstallAppInEnvironment(ManagedBCEnvironment, InstallAppsBuffer, UseEnvironmentUpdateWindow, InstallUpdateNeededDependencies);
                    until InstallAppsBuffer.Next() < 1;
            until ManagedBCEnvironment.Next() < 1;

        ShowResults();
    end;

    local procedure InstallAppInEnvironment(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; var InstallAppsBuffer: Record TKAInstallAppsBuffer temporary; UseEnvironmentUpdateWindow: Boolean; InstallUpdateNeededDependencies: Boolean)
    var
        CallAdminAPI: Codeunit TKACallAdminAPI;
        HttpResponseMessage: Codeunit "Http Response Message";
        RequestBodyJsonObject: JsonObject;
        Endpoint: Text;
    begin
        Clear(RequestBodyJsonObject);
        RequestBodyJsonObject.Add('useEnvironmentUpdateWindow', UseEnvironmentUpdateWindow);
        RequestBodyJsonObject.Add('allowPreviewVersion', false);
        RequestBodyJsonObject.Add('installOrUpdateNeededDependencies', InstallUpdateNeededDependencies);
        // NOTE: If you do not agree with ISV EULA, do not use the funcionality.
        RequestBodyJsonObject.Add('acceptIsvEula', true);
        Endpoint := CallAdminAPI.GetInstallAppsForEnvironmentEndpoint(ManagedBCEnvironment.Name, InstallAppsBuffer.AppId);
        if CallAdminAPI.PostToAdminAPI(ManagedBCEnvironment, Endpoint, RequestBodyJsonObject, HttpResponseMessage) then begin
            NoOfInstalledApps += 1;
            exit;
        end;
        ProcessErrorResponse(ManagedBCEnvironment, CallAdminAPI, HttpResponseMessage);
    end;

    local procedure ProcessErrorResponse(ManagedBCEnvironment: Record TKAManagedBCEnvironment; var CallAdminAPI: Codeunit TKACallAdminAPI; var HttpResponseMessage: Codeunit "Http Response Message")
    var
        ErrorMessage: Text;
        AppAlreadyInstalledResponseErrorTok: Label 'Entity validation failed: App is already installed.', Locked = true;
        AppNotFoundResponseErrorTok: Label 'Entity validation failed: Target app version was not found.', Locked = true;
        MissingDependenciesResponseErrorTok: Label 'requires the following apps to be installed or updated as dependencies, please either allow automatic dependency installation/update or do the operation manually', Locked = true;
    begin
        ErrorMessage := CallAdminAPI.GetErrorDetailsFromHttpResponseMessage(HttpResponseMessage);
        if (HttpResponseMessage.GetHttpStatusCode() = 400) and (ErrorMessage.Contains(AppAlreadyInstalledResponseErrorTok)) then begin
            NoOfSkippedApps += 1;
            exit;
        end;
        if (HttpResponseMessage.GetHttpStatusCode() = 400) and (ErrorMessage.Contains(AppNotFoundResponseErrorTok)) then begin
            LogNotFoundApp(ManagedBCEnvironment, ErrorMessage);
            NoOfNotFoundApps += 1;
            exit;
        end;
        if (HttpResponseMessage.GetHttpStatusCode() = 400) and (ErrorMessage.Contains(MissingDependenciesResponseErrorTok)) then begin
            LogMissingDependencies(ManagedBCEnvironment, HttpResponseMessage);
            NoMissingDependencies += 1;
            exit;
        end;
        CallAdminAPI.ThrowError(HttpResponseMessage);
    end;

    local procedure LogNotFoundApp(ManagedBCEnvironment: Record TKAManagedBCEnvironment; ErrorMessage: Text)
    var
        AppSourceOffering: Record TKAAppSourceOffering;
        ErrorDetailList: List of [Text];
        AppName: Text;
        AppId: Guid;
        DetailSplitCharTok: Label '''', Locked = true;
        AppCountryCodeTok: Label ' - Country Code: %1', Locked = true;
    begin
        ErrorDetailList := ErrorMessage.Split(DetailSplitCharTok);

        AppSourceOffering.ReadIsolation(IsolationLevel::ReadUncommitted);
        AppSourceOffering.SetLoadFields(Name);

        AppName := ErrorDetailList.Get(2);
        if Evaluate(AppId, AppName) then begin
            AppSourceOffering.Get(AppId);
            AppName := AppSourceOffering.Name;
        end;
        NotFoundAppsDetailsTextBuilder.AppendLine(AppName);
        NotFoundAppsDetailsTextBuilder.AppendLine(StrSubstNo(TenantTok, ManagedBCEnvironment.GetManagedBCTenant().Name));
        NotFoundAppsDetailsTextBuilder.AppendLine(StrSubstNo(EnvironmentTok, ManagedBCEnvironment.Name));
        NotFoundAppsDetailsTextBuilder.AppendLine(StrSubstNo(AppVersionTok, ErrorDetailList.Get(4)));
        NotFoundAppsDetailsTextBuilder.AppendLine(StrSubstNo(AppCountryCodeTok, ErrorDetailList.Get(6)));
        NotFoundAppsDetailsTextBuilder.AppendLine()
    end;

    local procedure LogMissingDependencies(ManagedBCEnvironment: Record TKAManagedBCEnvironment; HttpResponseMessage: Codeunit "Http Response Message")
    var
        ResponseJson, MissingDependencyJson : JsonObject;
        ErrorDataJsonToken, MissingDependenciesJsonToken, MissingDependencyJsonToken, MissingDependencyDetailJsonToken : JsonToken;
        ActionTypeTok: Label ' - Action Type: %1', Locked = true;
    begin
        ResponseJson := HttpResponseMessage.GetContent().AsJson().AsObject();
        ResponseJson.Get('data', ErrorDataJsonToken);
        ErrorDataJsonToken.AsObject().Get('requirements', MissingDependenciesJsonToken);
        foreach MissingDependencyJsonToken in MissingDependenciesJsonToken.AsArray() do begin
            MissingDependencyJson := MissingDependencyJsonToken.AsObject();

            MissingDependencyJson.Get('name', MissingDependencyDetailJsonToken);
            MissingDependenciesDetailsTextBuilder.AppendLine(MissingDependencyDetailJsonToken.AsValue().AsText());
            MissingDependenciesDetailsTextBuilder.AppendLine(StrSubstNo(TenantTok, ManagedBCEnvironment.GetManagedBCTenant().Name));
            MissingDependenciesDetailsTextBuilder.AppendLine(StrSubstNo(EnvironmentTok, ManagedBCEnvironment.Name));
            MissingDependencyJson.Get('version', MissingDependencyDetailJsonToken);
            MissingDependenciesDetailsTextBuilder.AppendLine(StrSubstNo(AppVersionTok, MissingDependencyDetailJsonToken.AsValue().AsText()));
            MissingDependencyJson.Get('type', MissingDependencyDetailJsonToken);
            MissingDependenciesDetailsTextBuilder.AppendLine(StrSubstNo(ActionTypeTok, MissingDependencyDetailJsonToken.AsValue().AsText()));
            MissingDependenciesDetailsTextBuilder.AppendLine()
        end;
    end;

    local procedure ShowResults()
    var
        ErrorMessageTextBuilder: TextBuilder;
        RequestCompletedMsg: Label 'Request Completed. Extensions will be installed during the update window or within a few minutes. Use "Refresh Environments" action to see the updated information.';
        NoOfInstalledAppsMsg: Label 'No. of apps installed: %1', Comment = '%1 - No. of Apps';
        NoOfSkippedAppsMsg: Label 'No. of apps skipped: %1 (already installed)', Comment = '%1 - No. of Apps';
        NoOfNotFoundAppsMsg: Label 'No. of apps not found: %1', Comment = '%1 - No. of Apps';
        NoOfAppsWithMissingDependenciesMsg: Label 'No. of apps skipped due missing dependencies: %1', Comment = '%1 - No. of Apps';
        NotFoundAppsMsg: Label 'Apps not found:';
        MissingAppsMsg: Label 'Missing apps:';
        DelimiterLineTok: Label '----------------------------------------', Locked = true;
    begin
        ErrorMessageTextBuilder.AppendLine(RequestCompletedMsg);
        ErrorMessageTextBuilder.AppendLine();
        ErrorMessageTextBuilder.AppendLine(StrSubstNo(NoOfInstalledAppsMsg, NoOfInstalledApps));
        if NoOfSkippedApps > 0 then
            ErrorMessageTextBuilder.AppendLine(StrSubstNo(NoOfSkippedAppsMsg, NoOfSkippedApps));
        if NoOfNotFoundApps > 0 then begin
            ErrorMessageTextBuilder.AppendLine(StrSubstNo(NoOfNotFoundAppsMsg, NoOfNotFoundApps));
            ErrorMessageTextBuilder.AppendLine();
            ErrorMessageTextBuilder.AppendLine(NotFoundAppsMsg);
            ErrorMessageTextBuilder.AppendLine(DelimiterLineTok);
            ErrorMessageTextBuilder.Append(NotFoundAppsDetailsTextBuilder.ToText());
        end;
        if NoMissingDependencies > 0 then begin
            ErrorMessageTextBuilder.AppendLine(StrSubstNo(NoOfAppsWithMissingDependenciesMsg, NoMissingDependencies));
            ErrorMessageTextBuilder.AppendLine();
            ErrorMessageTextBuilder.AppendLine(MissingAppsMsg);
            ErrorMessageTextBuilder.AppendLine(DelimiterLineTok);
            ErrorMessageTextBuilder.Append(MissingDependenciesDetailsTextBuilder.ToText());
        end;

        Message(ErrorMessageTextBuilder.ToText());
    end;
}
