codeunit 73274 TKAProcessAdminAPIEnvRespImpl
{
    Access = Internal;

    #region Environments

    /// <summary>
    /// Parses the response from the Admin API for getting all environments.
    /// </summary>
    /// <param name="Response">The response from the Admin API.</param>
    procedure ParseGetEnvironmentsResponse(Response: Text)
    var
        JsonResponse, JsonEnvironment : JsonObject;
        JsonTokenValue, JsonTokenEnvironment : JsonToken;
        JsonEnvironments: JsonArray;
        TenantId: Guid;
        ListOfFoundEnvironments: List of [Text[100]];
        EnvironmentName: Text[100];
    begin
        JsonResponse.ReadFrom(Response);
        JsonResponse.Get('value', JsonTokenValue);
        JsonEnvironments := JsonTokenValue.AsArray();
        foreach JsonTokenEnvironment in JsonEnvironments do begin
            JsonEnvironment := JsonTokenEnvironment.AsObject();
            ParseEnvironmentResponse(JsonEnvironment, TenantId, EnvironmentName);
            ListOfFoundEnvironments.Add(EnvironmentName);
        end;
        DeleteDeletedEnvironments(TenantId, ListOfFoundEnvironments);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'RD')]
    local procedure DeleteDeletedEnvironments(TenantId: Guid; ListOfFoundEnvironments: List of [Text[100]])
    var
        ManagedBCEnvironment, ManagedBCEnvironment2 : Record TKAManagedBCEnvironment;
    begin
        ManagedBCEnvironment.ReadIsolation(IsolationLevel::ReadCommitted);
        ManagedBCEnvironment.SetRange(TenantId, TenantId);
        if ManagedBCEnvironment.FindSet() then
            repeat
                if not ListOfFoundEnvironments.Contains(ManagedBCEnvironment.Name) then begin
                    ManagedBCEnvironment2.GetBySystemId(ManagedBCEnvironment.SystemId);
                    ManagedBCEnvironment2.Delete(true);
                end;
            until ManagedBCEnvironment.Next() < 1;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'RIM')]
#pragma warning disable LC0010 // Cyclomatic complexity is caused by the number of fields
    local procedure ParseEnvironmentResponse(var JsonEnvironment: JsonObject; TenantId: Guid; EnvironmentName: Text[100])
#pragma warning restore LC0010
    var
        ManagedBCEnvironment: Record TKAManagedBCEnvironment;
        JsonTokenValue: JsonToken;
    begin
        JsonEnvironment.Get('name', JsonTokenValue);
        EnvironmentName := CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(EnvironmentName));
        JsonEnvironment.Get('aadTenantId', JsonTokenValue);
        Evaluate(TenantId, JsonTokenValue.AsValue().AsText());

        if not ManagedBCEnvironment.Get(TenantId, EnvironmentName) then begin
            ManagedBCEnvironment.Init();
            ManagedBCEnvironment.Validate(TenantId, TenantId);
            ManagedBCEnvironment.Validate(Name, EnvironmentName);
            ManagedBCEnvironment.Insert(true);
        end;
        JsonEnvironment.Get('type', JsonTokenValue);
        ManagedBCEnvironment.Validate(Type, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.Type)));
        JsonEnvironment.Get('countryCode', JsonTokenValue);
        ManagedBCEnvironment.Validate(CountryCode, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.CountryCode)));
        JsonEnvironment.Get('applicationVersion', JsonTokenValue);
        ManagedBCEnvironment.Validate(ApplicationVersion, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.ApplicationVersion)));
        JsonEnvironment.Get('platformVersion', JsonTokenValue);
        ManagedBCEnvironment.Validate(PlatformVersion, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.PlatformVersion)));
        JsonEnvironment.Get('status', JsonTokenValue);
        ManagedBCEnvironment.Validate(Status, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.Status)));
        JsonEnvironment.Get('webClientLoginUrl', JsonTokenValue);
        ManagedBCEnvironment.Validate(WebClientURL, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.WebClientURL)));

        // Other fields (not sure if they are always included in the response)
        if JsonEnvironment.Get('ringName', JsonTokenValue) then
            ManagedBCEnvironment.Validate(RingName, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.RingName)));
        if JsonEnvironment.Get('locationName', JsonTokenValue) then
            ManagedBCEnvironment.Validate(LocationName, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.LocationName)));
        if JsonEnvironment.Get('geoName', JsonTokenValue) then
            ManagedBCEnvironment.Validate(GeoName, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.GeoName)));
        if JsonEnvironment.Get('appInsightsKey', JsonTokenValue) then
            ManagedBCEnvironment.Validate(ApplicationInsightsKey, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.ApplicationInsightsKey)));
        if JsonEnvironment.Get('appSourceAppsUpdateCadence', JsonTokenValue) then
            ManagedBCEnvironment.Validate(AppSourceAppsUpdateCadence, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.AppSourceAppsUpdateCadence)));
        if JsonEnvironment.Get('softDeletedOn', JsonTokenValue) then
            ManagedBCEnvironment.Validate(SoftDeletedOn, GetJsonTokenAsDateTime(JsonTokenValue));
        if JsonEnvironment.Get('hardDeletePendingOn', JsonTokenValue) then
            ManagedBCEnvironment.Validate(HardDeletePendingOn, GetJsonTokenAsDateTime(JsonTokenValue));
        if JsonEnvironment.Get('deleteReason', JsonTokenValue) then
            ManagedBCEnvironment.Validate(DeleteReason, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.DeleteReason)));
        ManagedBCEnvironment.Validate(EnvironmentModifiedAt, CurrentDateTime());
        ManagedBCEnvironment.Modify(true);
    end;

    #endregion Environments
    #region Scheduled Update

    /// <summary>
    /// Parses the response from the Admin API for getting scheduled update information for an environment.
    /// </summary>
    /// <param name="Response">The response from the Admin API.</param>
    /// <param name="ManagedBCEnvironment">The managed BC environment for which to parse the response.</param>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'M')]
    procedure ParseGetScheduledUpdateResponse(Response: Text; ManagedBCEnvironment: Record TKAManagedBCEnvironment)
    var
        JsonResponse: JsonObject;
        JsonTokenValue: JsonToken;
    begin
        if Response = '' then begin
            ClearScheduledUpdateFields(ManagedBCEnvironment);
            exit;
        end;
        Message(Response);
        JsonResponse.ReadFrom(Response);
        JsonResponse.Get('targetVersion', JsonTokenValue);
        ManagedBCEnvironment.Validate(UpdateTargetVersion, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.UpdateTargetVersion)));
        JsonResponse.Get('canTenantSelectDate', JsonTokenValue);
        ManagedBCEnvironment.Validate(CanTenantSelectDate, JsonTokenValue.AsValue().AsBoolean());
        JsonResponse.Get('didTenantSelectDate', JsonTokenValue);
        ManagedBCEnvironment.Validate(DidTenantSelectDate, JsonTokenValue.AsValue().AsBoolean());
        JsonResponse.Get('earliestSelectableUpgradeDate', JsonTokenValue);
        ManagedBCEnvironment.Validate(EarliestSelectableUpgradeDate, GetJsonDateTimeTokenAsDate(JsonTokenValue));
        JsonResponse.Get('latestSelectableUpgradeDate', JsonTokenValue);
        ManagedBCEnvironment.Validate(LatestSelectableUpgradeDate, GetJsonDateTimeTokenAsDate(JsonTokenValue));
        JsonResponse.Get('upgradeDate', JsonTokenValue);
        ManagedBCEnvironment.Validate(UpgradeDate, GetJsonDateTimeTokenAsDate(JsonTokenValue));
        JsonResponse.Get('upgradeStatus', JsonTokenValue);
        ManagedBCEnvironment.Validate(UpdateStatus, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.UpdateTargetVersion)));
        JsonResponse.Get('ignoreUpgradeWindow', JsonTokenValue);
        ManagedBCEnvironment.Validate(IgnoreUpgradeWindow, JsonTokenValue.AsValue().AsBoolean());
        JsonResponse.Get('isActive', JsonTokenValue);
        ManagedBCEnvironment.Validate(UpdateIsActive, JsonTokenValue.AsValue().AsBoolean());
        ManagedBCEnvironment.Modify(true);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'M')]
    local procedure ClearScheduledUpdateFields(ManagedBCEnvironment: Record TKAManagedBCEnvironment)
    begin
        ManagedBCEnvironment.Validate(UpdateIsActive, false);
        ManagedBCEnvironment.Validate(UpdateTargetVersion, '');
        ManagedBCEnvironment.Validate(CanTenantSelectDate, false);
        ManagedBCEnvironment.Validate(DidTenantSelectDate, false);
        ManagedBCEnvironment.Validate(EarliestSelectableUpgradeDate, 0D);
        ManagedBCEnvironment.Validate(LatestSelectableUpgradeDate, 0D);
        ManagedBCEnvironment.Validate(UpgradeDate, 0D);
        ManagedBCEnvironment.Validate(UpdateStatus, '');
        ManagedBCEnvironment.Validate(IgnoreUpgradeWindow, false);
        ManagedBCEnvironment.Modify(true);
    end;

    #endregion Scheduled Update
    #region Helpers

    local procedure GetJsonTokenAsDateTime(var JsonTokenValue: JsonToken): DateTime
    var
        TempDateTime: DateTime;
    begin
        TempDateTime := JsonTokenValue.AsValue().AsDateTime();
        if TempDateTime.Date.Year = 1753 then // Fix for error 'Cannot write the value 01/01/1753 10:00 AM to the field...
            exit(0DT);
        exit(TempDateTime);
    end;

    local procedure GetJsonDateTimeTokenAsDate(var JsonTokenValue: JsonToken): Date
    var
        TypeHelper: Codeunit "Type Helper";
        TempDateTimeInCurrentTimeZone, TempDateTimeInUTC : DateTime;
        TimezoneOffset: Duration;
    begin
        TempDateTimeInCurrentTimeZone := GetJsonTokenAsDateTime(JsonTokenValue);
        if TempDateTimeInCurrentTimeZone = 0DT then
            exit(0D);
        if not TypeHelper.GetUserTimezoneOffset(TimezoneOffset) then
            TimezoneOffset := 0;
#pragma warning disable AA0206 // This check is broken, DateTime.Date() is not considered as usage
        TempDateTimeInUTC := TempDateTimeInCurrentTimeZone - TimezoneOffset;
#pragma warning restore AA0206
        exit(TempDateTimeInUTC.Date());
    end;

    #endregion Helpers
}