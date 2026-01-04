codeunit 73274 TKAProcessGetEnvResponseImpl
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
            Commit(); // One environment processed
        end;
        DeleteDeletedEnvironments(TenantId, ListOfFoundEnvironments);
        Commit(); // All environments processed and deleted ones removed
    end;

    /// <summary>
    /// Parses the response from the Admin API for getting information about an environment.
    /// </summary>
    /// <param name="Response">The response from the Admin API.</param>
    /// <param name="TenantId">The ID of the tenant to which the environment belongs.</param>
    /// <param name="EnvironmentName">The name of the environment.</param>
    procedure ParseEnvironmentResponse(Response: Text; TenantId: Guid; EnvironmentName: Text[100])
    var
        JsonResponse: JsonObject;
    begin
        JsonResponse.ReadFrom(Response);
        ParseEnvironmentResponse(JsonResponse, TenantId, EnvironmentName);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'RIM')]
#pragma warning disable LC0010 // Cyclomatic complexity is caused by the number of fields
    procedure ParseEnvironmentResponse(var JsonEnvironment: JsonObject; var TenantId: Guid; var EnvironmentName: Text[100])
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

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'R')]
    local procedure DeleteDeletedEnvironments(TenantId: Guid; ListOfFoundEnvironments: List of [Text[100]])
    var
        ManagedBCEnvironment: Record TKAManagedBCEnvironment;
    begin
        ManagedBCEnvironment.ReadIsolation(IsolationLevel::UpdLock);
        ManagedBCEnvironment.SetRange(TenantId, TenantId);
        if ManagedBCEnvironment.FindSet() then
            repeat
                if not ListOfFoundEnvironments.Contains(ManagedBCEnvironment.Name) then
                    DeleteEnvironment(ManagedBCEnvironment);
            until ManagedBCEnvironment.Next() < 1;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'D')]
    procedure DeleteEnvironment(ManagedBCEnvironment: Record TKAManagedBCEnvironment)
    begin
        ManagedBCEnvironment.Delete(true);
    end;

    #endregion Environments
    #region Update Settings

    /// <summary>
    /// Parses the response from the Admin API for updating scheduled update information for an environment.
    /// </summary>
    /// <param name="Response">The response from the Admin API.</param>
    /// <param name="ManagedBCEnvironment">The managed BC environment for which to parse the response.</param>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'M')]
    procedure ParseUpdateSettingsResponse(Response: Text; var ManagedBCEnvironment: Record TKAManagedBCEnvironment)
    var
        JsonResponse: JsonObject;
        JsonTokenValue: JsonToken;
    begin
        if Response = '' then begin
            ClearUpdateSettingsFields(ManagedBCEnvironment);
            exit;
        end;
        JsonResponse.ReadFrom(Response);
        JsonResponse.Get('preferredStartTime', JsonTokenValue);
        ManagedBCEnvironment.Validate(PreferredStartTime, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.PreferredStartTime)));
        JsonResponse.Get('preferredEndTime', JsonTokenValue);
        ManagedBCEnvironment.Validate(PreferredEndTime, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.PreferredEndTime)));
        JsonResponse.Get('timeZoneId', JsonTokenValue);
        ManagedBCEnvironment.Validate(TimeZoneId, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.TimeZoneId)));
        JsonResponse.Get('preferredStartTimeUtc', JsonTokenValue);
        ManagedBCEnvironment.Validate(PreferredStartTimeUtc, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.PreferredStartTimeUtc)));
        JsonResponse.Get('preferredEndTimeUtc', JsonTokenValue);
        ManagedBCEnvironment.Validate(PreferredEndTimeUtc, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.PreferredEndTimeUtc)));
        ManagedBCEnvironment.Modify(true);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'M')]
    local procedure ClearUpdateSettingsFields(var ManagedBCEnvironment: Record TKAManagedBCEnvironment)
    begin
        ManagedBCEnvironment.Validate(PreferredStartTime, '');
        ManagedBCEnvironment.Validate(PreferredEndTime, '');
        ManagedBCEnvironment.Validate(TimeZoneId, '');
        ManagedBCEnvironment.Validate(PreferredStartTimeUtc, '');
        ManagedBCEnvironment.Validate(PreferredEndTimeUtc, '');
        ManagedBCEnvironment.Modify(true);
    end;

    #endregion Update Settings
#if not CLEAN29
    #region Scheduled Update

    /// <summary>
    /// Parses the response from the Admin API for getting scheduled update information for an environment.
    /// </summary>
    /// <param name="Response">The response from the Admin API.</param>
    /// <param name="ManagedBCEnvironment">The managed BC environment for which to parse the response.</param>
    [Obsolete('Replaced by flexible update logic and related fields.', '27.2')]
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'M')]
    procedure ParseGetScheduledUpdateResponse(Response: Text; var ManagedBCEnvironment: Record TKAManagedBCEnvironment)
    var
        JsonResponse: JsonObject;
        JsonTokenValue: JsonToken;
    begin
        if Response = '' then begin
            ClearScheduledUpdateFields(ManagedBCEnvironment);
            exit;
        end;
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
    local procedure ClearScheduledUpdateFields(var ManagedBCEnvironment: Record TKAManagedBCEnvironment)
    begin
#pragma warning disable AL0432
        ManagedBCEnvironment.Validate(UpdateIsActive, false);
        ManagedBCEnvironment.Validate(UpdateTargetVersion, '');
        ManagedBCEnvironment.Validate(CanTenantSelectDate, false);
        ManagedBCEnvironment.Validate(DidTenantSelectDate, false);
        ManagedBCEnvironment.Validate(EarliestSelectableUpgradeDate, 0D);
        ManagedBCEnvironment.Validate(LatestSelectableUpgradeDate, 0D);
        ManagedBCEnvironment.Validate(UpgradeDate, 0D);
        ManagedBCEnvironment.Validate(UpdateStatus, '');
        ManagedBCEnvironment.Validate(IgnoreUpgradeWindow, false);
#pragma warning restore AL0432
        ManagedBCEnvironment.Modify(true);
    end;

    #endregion Scheduled Update
#endif
    #region Installed Apps

    /// <summary>
    /// Parses the response from the Admin API for getting installed apps information for an environment.
    /// </summary>
    /// <param name="Response">The response from the Admin API.</param>
    /// <param name="ManagedBCEnvironment">The managed BC environment for which to parse the response.</param>
    procedure ParseInstalledAppsResponse(Response: Text; var ManagedBCEnvironment: Record TKAManagedBCEnvironment)
    var
        JsonResponse, JsonApp : JsonObject;
        JsonTokenValue, JsonTokenApp : JsonToken;
        JsonApps: JsonArray;
        ListOfFoundApps: List of [Guid];
        InstalledOn: DateTime;
        AppId: Guid;
    begin
        if HasManagedBCEnvironmentApps(ManagedBCEnvironment.TenantId, ManagedBCEnvironment.Name) then
            InstalledOn := CurrentDateTime();

        JsonResponse.ReadFrom(Response);
        JsonResponse.Get('value', JsonTokenValue);
        JsonApps := JsonTokenValue.AsArray();
        foreach JsonTokenApp in JsonApps do begin
            JsonApp := JsonTokenApp.AsObject();
            ParseAppResponse(JsonApp, ManagedBCEnvironment.TenantId, ManagedBCEnvironment.Name, AppId, InstalledOn);
            ListOfFoundApps.Add(AppId);
        end;
        DeleteDeletedApps(ManagedBCEnvironment.TenantId, ManagedBCEnvironment.Name, ListOfFoundApps);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironmentApp, 'RIM')]
    local procedure ParseAppResponse(var JsonApp: JsonObject; TenantId: Guid; EnvironmentName: Text[100]; var AppId: Guid; InstalledOn: DateTime)
    var
        ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp;
        JsonTokenValue: JsonToken;
    begin
        JsonApp.Get('id', JsonTokenValue);
        Evaluate(AppId, JsonTokenValue.AsValue().AsText());

        if not ManagedBCEnvironmentApp.Get(TenantId, EnvironmentName, AppId) then begin
            ManagedBCEnvironmentApp.Init();
            ManagedBCEnvironmentApp.Validate(TenantId, TenantId);
            ManagedBCEnvironmentApp.Validate(EnvironmentName, EnvironmentName);
            ManagedBCEnvironmentApp.Validate(ID, AppId);
            ManagedBCEnvironmentApp.Validate(InstalledOn, InstalledOn);
            ManagedBCEnvironmentApp.Insert(true);
        end;

        JsonApp.Get('name', JsonTokenValue);
        ManagedBCEnvironmentApp.Validate(Name, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironmentApp.Name)));
        JsonApp.Get('publisher', JsonTokenValue);
        ManagedBCEnvironmentApp.Validate(Publisher, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironmentApp.Publisher)));
        JsonApp.Get('version', JsonTokenValue);
        ManagedBCEnvironmentApp.Validate(Version, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironmentApp.Version)));
        JsonApp.Get('state', JsonTokenValue);
        ManagedBCEnvironmentApp.Validate(State, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironmentApp.State)));

        if JsonApp.Get('lastOperationId', JsonTokenValue) then begin
            Evaluate(AppId, JsonTokenValue.AsValue().AsText());
            ManagedBCEnvironmentApp.Validate(LastOperationId, AppId);
        end;
        if JsonApp.Get('lastUpdateAttemptResult', JsonTokenValue) then
            ManagedBCEnvironmentApp.Validate(LastUpdateAttemptResult, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironmentApp.LastUpdateAttemptResult)));
        ManagedBCEnvironmentApp.Validate(Hidden, ShouldAppBeSetAsHidden(ManagedBCEnvironmentApp));
        ManagedBCEnvironmentApp.Modify(true);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironmentApp, 'RD')]
    local procedure DeleteDeletedApps(TenantId: Guid; EnvironmentName: Text[100]; ListOfFoundApps: List of [Guid])
    var
        ManagedBCEnvironmentApp, ManagedBCEnvironmentApp2 : Record TKAManagedBCEnvironmentApp;
    begin
        ManagedBCEnvironmentApp.ReadIsolation(IsolationLevel::ReadCommitted);
        ManagedBCEnvironmentApp.SetRange(TenantId, TenantId);
        ManagedBCEnvironmentApp.SetRange(EnvironmentName, EnvironmentName);
        if ManagedBCEnvironmentApp.FindSet() then
            repeat
                if not ListOfFoundApps.Contains(ManagedBCEnvironmentApp.ID) then begin
                    ManagedBCEnvironmentApp2.GetBySystemId(ManagedBCEnvironmentApp.SystemId);
                    ManagedBCEnvironmentApp2.Delete(true);
                end;
            until ManagedBCEnvironmentApp.Next() < 1;
    end;

    local procedure HasManagedBCEnvironmentApps(TenantId: Guid; EnvironmentName: Text[100]): Boolean
    var
        ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp;
    begin
        ManagedBCEnvironmentApp.ReadIsolation(IsolationLevel::ReadUncommitted);
        ManagedBCEnvironmentApp.SetRange(TenantId, TenantId);
        ManagedBCEnvironmentApp.SetRange(EnvironmentName, EnvironmentName);
        exit(not ManagedBCEnvironmentApp.IsEmpty());
    end;

    local procedure ShouldAppBeSetAsHidden(ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp): Boolean
    var
        HiddenAppsPrefixTok: Label '_Exclude', Locked = true;
    begin
        exit(ManagedBCEnvironmentApp.Name.StartsWith(HiddenAppsPrefixTok));
    end;

    #endregion Installed Apps
    #region Helpers

    local procedure GetJsonTokenAsDateTime(var JsonTokenValue: JsonToken): DateTime
    var
        TempDateTime: DateTime;
    begin
        TempDateTime := JsonTokenValue.AsValue().AsDateTime();
        if TempDateTime.Date().Year() = 1753 then // Fix for error 'Cannot write the value 01/01/1753 10:00 AM to the field...
            exit(0DT);
        exit(TempDateTime);
    end;

#if not CLEAN29
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
#endif

    #endregion Helpers
}