codeunit 73306 TKAProcessGetUpdResponseImpl
{
    Access = Internal;

    #region Get Updates

    /// <summary>
    /// Parses the response from the Admin API for getting updates for environments.
    /// </summary>
    /// <param name="ManagedBCEnvironment">The managed BC environment for which to parse the response.</param>
    /// <param name="Response">The response from the Admin API.</param>
    procedure ParseGetUpdatesResponse(ManagedBCEnvironment: Record TKAManagedBCEnvironment; Response: Text)
    var
        JsonResponse, JsonEnvironment : JsonObject;
        JsonTokenValue, JsonTokenEnvironment : JsonToken;
        JsonEnvironments: JsonArray;
        ListOfFoundTargetVersions: List of [Code[20]];
        TargetVersion: Code[20];
    begin
        JsonResponse.ReadFrom(Response);
        JsonResponse.Get('value', JsonTokenValue);
        JsonEnvironments := JsonTokenValue.AsArray();
        foreach JsonTokenEnvironment in JsonEnvironments do begin
            JsonEnvironment := JsonTokenEnvironment.AsObject();
            ParseGetUpdateResponse(JsonEnvironment, ManagedBCEnvironment, TargetVersion);
            ListOfFoundTargetVersions.Add(TargetVersion);
            Commit(); // One environment processed
        end;
        DeleteNoLongerAvailableTargetVersions(ManagedBCEnvironment, ListOfFoundTargetVersions);
        Commit(); // All environments processed and deleted ones removed
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvAvailUpdate, 'RIM')]
#pragma warning disable LC0010 // Cyclomatic complexity is caused by the number of fields
    local procedure ParseGetUpdateResponse(var AvailableUpdateJsonObject: JsonObject; ManagedBCEnvironment: Record TKAManagedBCEnvironment; var TargetVersion: Code[20])
#pragma warning restore LC0010
    var
        ManagedBCEnvAvailUpdate: Record TKAManagedBCEnvAvailUpdate;
        ScheduleDetailsJsonObject: JsonObject;
        TempDateTime: DateTime;
    begin
        TargetVersion := CopyStr(AvailableUpdateJsonObject.GetText('targetVersion'), 1, MaxStrLen(TargetVersion));
        if not ManagedBCEnvAvailUpdate.Get(ManagedBCEnvironment.TenantId, ManagedBCEnvironment.Name, TargetVersion) then begin
            ManagedBCEnvAvailUpdate.Init();
            ManagedBCEnvAvailUpdate.Validate(TenantId, ManagedBCEnvironment.TenantId);
            ManagedBCEnvAvailUpdate.Validate(EnvironmentName, ManagedBCEnvironment.Name);
            ManagedBCEnvAvailUpdate.Validate(TargetVersion, TargetVersion);
            ManagedBCEnvAvailUpdate.Insert(true);
        end;
        ManagedBCEnvAvailUpdate.Validate(Available, AvailableUpdateJsonObject.GetBoolean('available'));
        ManagedBCEnvAvailUpdate.Validate(Selected, AvailableUpdateJsonObject.GetBoolean('selected'));
        ManagedBCEnvAvailUpdate.Validate(TargetVersionType, CopyStr(AvailableUpdateJsonObject.GetText('targetVersionType'), 1, Text.MaxStrLen(ManagedBCEnvAvailUpdate.TargetVersionType)));
        if AvailableUpdateJsonObject.Contains('scheduleDetails') then begin
            ScheduleDetailsJsonObject := AvailableUpdateJsonObject.GetObject('scheduleDetails');
            TempDateTime := ScheduleDetailsJsonObject.GetDateTime('latestSelectableDateTime');
            ManagedBCEnvAvailUpdate.Validate(LatestSelectableDate, TempDateTime.Date());
            TempDateTime := ScheduleDetailsJsonObject.GetDateTime('selectedDateTime');
            ManagedBCEnvAvailUpdate.Validate(SelectedDate, TempDateTime.Date());
            ManagedBCEnvAvailUpdate.Validate(IgnoreUpdateWindow, ScheduleDetailsJsonObject.GetBoolean('ignoreUpdateWindow'));
            ManagedBCEnvAvailUpdate.Validate(RolloutStatus, CopyStr(ScheduleDetailsJsonObject.GetText('rolloutStatus'), 1, Text.MaxStrLen(ManagedBCEnvAvailUpdate.RolloutStatus)));
            ManagedBCEnvAvailUpdate.Validate(ExpectedAvailabilityMonth, 0);
            ManagedBCEnvAvailUpdate.Validate(ExpectedAvailabilityYear, 0);
            ManagedBCEnvAvailUpdate.Validate(ExpectedAvailability, '');
        end;
        if AvailableUpdateJsonObject.Contains('expectedAvailability') then begin
            ScheduleDetailsJsonObject := AvailableUpdateJsonObject.GetObject('expectedAvailability');
            ManagedBCEnvAvailUpdate.Validate(LatestSelectableDate, 0D);
            ManagedBCEnvAvailUpdate.Validate(SelectedDate, 0D);
            ManagedBCEnvAvailUpdate.Validate(IgnoreUpdateWindow, false);
            ManagedBCEnvAvailUpdate.Validate(RolloutStatus, 'planned');
            ManagedBCEnvAvailUpdate.Validate(ExpectedAvailabilityMonth, ScheduleDetailsJsonObject.GetInteger('month'));
            ManagedBCEnvAvailUpdate.Validate(ExpectedAvailabilityYear, ScheduleDetailsJsonObject.GetInteger('year'));
            ManagedBCEnvAvailUpdate.Validate(ExpectedAvailability, Format(ManagedBCEnvAvailUpdate.ExpectedAvailabilityYear) + '/' + CopyStr('0' + Format(ManagedBCEnvAvailUpdate.ExpectedAvailabilityMonth), StrLen(Format(ManagedBCEnvAvailUpdate.ExpectedAvailabilityMonth)), 2));
        end;
        ManagedBCEnvAvailUpdate.Modify(true);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvAvailUpdate, 'R')]
    local procedure DeleteNoLongerAvailableTargetVersions(ManagedBCEnvironment: Record TKAManagedBCEnvironment; ListOfFoundTargetVersions: List of [Code[20]])
    var
        ManagedBCEnvAvailUpdate: Record TKAManagedBCEnvAvailUpdate;
    begin
        ManagedBCEnvAvailUpdate.ReadIsolation(IsolationLevel::UpdLock);
        ManagedBCEnvAvailUpdate.SetRange(TenantId, ManagedBCEnvironment.TenantId);
        ManagedBCEnvAvailUpdate.SetRange(EnvironmentName, ManagedBCEnvironment.Name);
        if ManagedBCEnvAvailUpdate.FindSet() then
            repeat
                if not ListOfFoundTargetVersions.Contains(ManagedBCEnvAvailUpdate.TargetVersion) then
                    DeleteEnvironment(ManagedBCEnvAvailUpdate);
            until ManagedBCEnvAvailUpdate.Next() < 1;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvAvailUpdate, 'D')]
    procedure DeleteEnvironment(ManagedBCEnvAvailUpdate: Record TKAManagedBCEnvAvailUpdate)
    begin
        ManagedBCEnvAvailUpdate.Delete(true);
    end;

    #endregion Get Updates
}