codeunit 73275 TKAChangeUpdateDateImpl
{
    Access = Internal;

#if not CLEAN29
    [Obsolete('Replaced by flexible update logic and related fields.', '27.2')]
    procedure RunChangeUpdateDate(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; NewUpdateDate: Date; ChangeIgnoreUpgradeWindow: Boolean; NewIgnoreUpgradeWindow: Boolean)
    begin
        TestLegacyChangesPossible(ManagedBCEnvironment, NewUpdateDate);
        ProcessChangeLegacy(ManagedBCEnvironment, NewUpdateDate, ChangeIgnoreUpgradeWindow, NewIgnoreUpgradeWindow);
    end;
#endif

    procedure RunChangeUpdateDate(TempManagedBCEnvAvailUpdateSelected: Record TKAManagedBCEnvAvailUpdate temporary; var ManagedBCEnvironment: Record TKAManagedBCEnvironment; NewUpdateDate: Date; ChangeIgnoreUpgradeWindow: Boolean; NewIgnoreUpgradeWindow: Boolean)
    begin
        ValidateVersion(ManagedBCEnvironment, TempManagedBCEnvAvailUpdateSelected.TargetVersion, TempManagedBCEnvAvailUpdateSelected, NewUpdateDate);
        ProcessChange(ManagedBCEnvironment, TempManagedBCEnvAvailUpdateSelected, NewUpdateDate, ChangeIgnoreUpgradeWindow, NewIgnoreUpgradeWindow);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'R')]
#pragma warning disable LC0010 // Complexity OK, validation conditions
    procedure ValidateVersion(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; SelectedVersionCode: Code[20]; var TempManagedBCEnvAvailUpdate: Record TKAManagedBCEnvAvailUpdate temporary; NewUpdateDate: Date)
#pragma warning restore LC0010
    var
        EnvironmentTestManagedBCEnvAvailUpdate: Record TKAManagedBCEnvAvailUpdate;
        TargetVersionNotValidErr: Label 'The selected target version is not valid for environment %1.', Comment = '%1 - Environment Name';
        RolloutStatusDifferentErr: Label 'The selected target version rollout status is different for environment %1.', Comment = '%1 - Environment Name';
        LatestSelectableDateDifferentErr: Label 'The latest selectable date for the selected target version is different for environment %1.', Comment = '%1 - Environment Name';
        UpdateDateAfterLatestSelectableDateErr: Label 'The latest selectable date for the selected target version is before the new update date %1 for environment %2.', Comment = '%1 - New Update Date, %2 - Environment Name';
        NewUpdateDateMustHaveValueErr: Label 'The field "New Update Date" must have a value.';
        UpdateToVersionMustHaveValueErr: Label 'The field "Update to Version" must have a value.';
        ExpectedAvailabilityMustHaveValueErr: Label 'The expected availability for the selected target version is different for environment %1.', Comment = '%1 - Environment Name';
        NewUpdateDateMustBeBlankErr: Label 'The field "New Update Date" must not have a value for updates with expected availability.';
        OnlyGAAllowedErr: Label 'Only General Availability (GA) versions can be selected. You can update to other types directly in the admin center.';
        TargetVersionTypeDifferentErr: Label 'Target version type is different for environment %1.', Comment = '%1 - Environment Name';
    begin
        if SelectedVersionCode = '' then
            Error(UpdateToVersionMustHaveValueErr);
        if TempManagedBCEnvAvailUpdate.TargetVersionType <> 'GA' then
            Error(OnlyGAAllowedErr);
        ManagedBCEnvironment.FindSet();
        repeat
            EnvironmentTestManagedBCEnvAvailUpdate.SetRange(TenantId, ManagedBCEnvironment.TenantId);
            EnvironmentTestManagedBCEnvAvailUpdate.SetRange(EnvironmentName, ManagedBCEnvironment.Name);
            EnvironmentTestManagedBCEnvAvailUpdate.SetRange(TargetVersion, SelectedVersionCode);
            if not EnvironmentTestManagedBCEnvAvailUpdate.FindFirst() then
                Error(TargetVersionNotValidErr, ManagedBCEnvironment.Name);
            if EnvironmentTestManagedBCEnvAvailUpdate.TargetVersionType <> TempManagedBCEnvAvailUpdate.TargetVersionType then
                Error(TargetVersionTypeDifferentErr, ManagedBCEnvironment.Name);
            if EnvironmentTestManagedBCEnvAvailUpdate.RolloutStatus <> TempManagedBCEnvAvailUpdate.RolloutStatus then
                Error(RolloutStatusDifferentErr, ManagedBCEnvironment.Name);
            if EnvironmentTestManagedBCEnvAvailUpdate.LatestSelectableDate <> TempManagedBCEnvAvailUpdate.LatestSelectableDate then
                Error(LatestSelectableDateDifferentErr, ManagedBCEnvironment.Name);
            if EnvironmentTestManagedBCEnvAvailUpdate.ExpectedAvailability <> TempManagedBCEnvAvailUpdate.ExpectedAvailability then
                Error(ExpectedAvailabilityMustHaveValueErr, ManagedBCEnvironment.Name);

            // Update is available, scheduling the exact update date
            if TempManagedBCEnvAvailUpdate.LatestSelectableDate <> 0D then begin
                if NewUpdateDate = 0D then
                    Error(NewUpdateDateMustHaveValueErr);
                if EnvironmentTestManagedBCEnvAvailUpdate.LatestSelectableDate < NewUpdateDate then
                    Error(UpdateDateAfterLatestSelectableDateErr, Format(NewUpdateDate), ManagedBCEnvironment.Name);
            end;
            // Update is not yet available, we cannot schedule exact update date only select target version
            if TempManagedBCEnvAvailUpdate.ExpectedAvailability <> '' then
                if NewUpdateDate <> 0D then
                    Error(NewUpdateDateMustBeBlankErr);
        until ManagedBCEnvironment.Next() < 1;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'R')]
    local procedure ProcessChange(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; TempManagedBCEnvAvailUpdateSelected: Record TKAManagedBCEnvAvailUpdate temporary; NewUpdateDate: Date; ChangeIgnoreUpgradeWindow: Boolean; NewIgnoreUpgradeWindow: Boolean)
    var
        CallAdminAPI: Codeunit TKACallAdminAPI;
        GetEnvironments: Codeunit TKAGetEnvironments;
        HttpResponseMessage: Codeunit "Http Response Message";
        RequestBodyJsonObject, ScheduleDetailJsonObject : JsonObject;
        NewUpdateDateTime: DateTime;
        Endpoint: Text;
    begin
        ManagedBCEnvironment.SetAutoCalcFields(IgnoreScheduleUpgradeWindow);
        ManagedBCEnvironment.FindSet();
        repeat
            Clear(RequestBodyJsonObject);
            Clear(ScheduleDetailJsonObject);
            RequestBodyJsonObject.Add('selected', true);
            if TempManagedBCEnvAvailUpdateSelected.LatestSelectableDate <> 0D then begin
                if NewUpdateDate = Today() then
                    NewUpdateDateTime := CurrentDateTime()
                else
                    NewUpdateDateTime := CreateDateTime(NewUpdateDate, 0T);
                ScheduleDetailJsonObject.Add('selectedDateTime', Format(NewUpdateDateTime, 0, 9));
                if not ChangeIgnoreUpgradeWindow then
                    NewIgnoreUpgradeWindow := ManagedBCEnvironment.IgnoreScheduleUpgradeWindow;
                ScheduleDetailJsonObject.Add('ignoreUpdateWindow', NewIgnoreUpgradeWindow);
                RequestBodyJsonObject.Add('scheduleDetails', ScheduleDetailJsonObject);
            end;

            Endpoint := CallAdminAPI.GetScheduleUpdateForEnvironmentEndpoint(ManagedBCEnvironment.Name, TempManagedBCEnvAvailUpdateSelected.TargetVersion);
            if not CallAdminAPI.PatchToAdminAPI(ManagedBCEnvironment, Endpoint, RequestBodyJsonObject, HttpResponseMessage) then
                CallAdminAPI.ThrowError(HttpResponseMessage);
        until ManagedBCEnvironment.Next() < 1;
        GetEnvironments.UpdateSelectedEnvironments(ManagedBCEnvironment, false);
    end;

#if not CLEAN29
#pragma warning disable AL0432
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'R')]
    local procedure TestLegacyChangesPossible(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; NewUpdateDate: Date)
    var
        DateIsAfterAllowedDateErr: Label 'Environment %1 cannot be changed. The new update date is after the latest selectable upgrade date.', Comment = '%1 - Environment Name';
        DateIsBeforeAllowedDateErr: Label 'Environment %1 cannot be changed. The new update date is before the earliest selectable upgrade date.', Comment = '%1 - Environment Name';
    begin
        ManagedBCEnvironment.FindSet();
        repeat
            ManagedBCEnvironment.TestField(UpdateIsActive, true);
            if (NewUpdateDate < ManagedBCEnvironment.EarliestSelectableUpgradeDate) or (NewUpdateDate < Today()) then
                Error(DateIsBeforeAllowedDateErr, ManagedBCEnvironment.Name);
            if NewUpdateDate > ManagedBCEnvironment.LatestSelectableUpgradeDate then
                Error(DateIsAfterAllowedDateErr, ManagedBCEnvironment.Name);
        until ManagedBCEnvironment.Next() < 1;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'R')]
    local procedure ProcessChangeLegacy(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; NewUpdateDate: Date; ChangeIgnoreUpgradeWindow: Boolean; NewIgnoreUpgradeWindow: Boolean)
    var
        CallAdminAPI: Codeunit TKACallAdminAPI;
        GetEnvironments: Codeunit TKAGetEnvironments;
        HttpResponseMessage: Codeunit "Http Response Message";
        RequestBodyJsonObject: JsonObject;
        NewUpdateDateTime: DateTime;
        Endpoint: Text;
    begin
        ManagedBCEnvironment.FindSet();
        repeat
            Clear(RequestBodyJsonObject);
            if NewUpdateDate = Today() then
                NewUpdateDateTime := CurrentDateTime()
            else
                NewUpdateDateTime := CreateDateTime(NewUpdateDate, 0T);
            RequestBodyJsonObject.Add('runOn', Format(NewUpdateDateTime, 0, 9));
            if not ChangeIgnoreUpgradeWindow then
                NewIgnoreUpgradeWindow := ManagedBCEnvironment.IgnoreUpgradeWindow;
            RequestBodyJsonObject.Add('ignoreUpgradeWindow', NewIgnoreUpgradeWindow);

            Endpoint := CallAdminAPI.GetScheduledUpdateForEnvironmentEndpoint(ManagedBCEnvironment.Name);
            if not CallAdminAPI.PutToAdminAPI(ManagedBCEnvironment, Endpoint, RequestBodyJsonObject, HttpResponseMessage) then
                CallAdminAPI.ThrowError(HttpResponseMessage);
        until ManagedBCEnvironment.Next() < 1;
        GetEnvironments.UpdateSelectedEnvironments(ManagedBCEnvironment, false);
    end;
#pragma warning restore AL0432
#endif
}