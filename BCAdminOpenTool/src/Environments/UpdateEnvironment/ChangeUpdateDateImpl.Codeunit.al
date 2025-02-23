codeunit 73275 TKAChangeUpdateDateImpl
{
    Access = Internal;

    procedure RunChangeUpdateDate(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; ChangeUpdateDate: Boolean; NewUpdateDate: Date; ChangeIgnoreUpgradeWindow: Boolean; NewIgnoreUpgradeWindow: Boolean)
    begin
        TestChangesPossible(ManagedBCEnvironment, ChangeUpdateDate, NewUpdateDate);
        ProcessChange(ManagedBCEnvironment, ChangeUpdateDate, NewUpdateDate, ChangeIgnoreUpgradeWindow, NewIgnoreUpgradeWindow);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'R')]
    local procedure TestChangesPossible(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; ChangeUpdateDate: Boolean; NewUpdateDate: Date)
    var
        DateIsAfterAllowedDateErr: Label 'Environment %1 cannot be changed. The new update date is after the latest selectable upgrade date.', Comment = '%1 - Environment Name';
        DateIsBeforeAllowedDateErr: Label 'Environment %1 cannot be changed. The new update date is before the earliest selectable upgrade date.', Comment = '%1 - Environment Name';
    begin
        if not ChangeUpdateDate then
            exit;
        if ManagedBCEnvironment.FindSet() then
            repeat
                ManagedBCEnvironment.TestField(UpdateIsActive, true);
                if (NewUpdateDate < ManagedBCEnvironment.EarliestSelectableUpgradeDate) or (NewUpdateDate < Today()) then
                    Error(DateIsBeforeAllowedDateErr, ManagedBCEnvironment.Name);
                if NewUpdateDate > ManagedBCEnvironment.LatestSelectableUpgradeDate then
                    Error(DateIsAfterAllowedDateErr, ManagedBCEnvironment.Name);
            until ManagedBCEnvironment.Next() < 1;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'R')]
    local procedure ProcessChange(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; ChangeUpdateDate: Boolean; NewUpdateDate: Date; ChangeIgnoreUpgradeWindow: Boolean; NewIgnoreUpgradeWindow: Boolean)
    var
        CallAdminAPI: Codeunit TKACallAdminAPI;
        RunAdminAPIForEnv: Codeunit TKARunAdminAPIForEnv;
        RequestBodyJsonObject: JsonObject;
        Endpoint, Response : Text;
    begin
        if ManagedBCEnvironment.FindSet() then
            repeat
                Clear(RequestBodyJsonObject);
                if not ChangeUpdateDate then
                    NewUpdateDate := ManagedBCEnvironment.UpgradeDate;
                if not ChangeIgnoreUpgradeWindow then
                    NewIgnoreUpgradeWindow := ManagedBCEnvironment.IgnoreUpgradeWindow;

                RequestBodyJsonObject.Add('runOn', Format(NewUpdateDate, 0, 9) + 'T00:00:00Z');
                RequestBodyJsonObject.Add('ignoreUpgradeWindow', NewIgnoreUpgradeWindow);
                Endpoint := CallAdminAPI.GetScheduledUpdateForEnvironmentEndpoint(ManagedBCEnvironment.Name);
                Response := CallAdminAPI.PutToAdminAPI(ManagedBCEnvironment, Endpoint, RequestBodyJsonObject);
            until ManagedBCEnvironment.Next() < 1;
        RunAdminAPIForEnv.UpdateSelectedEnvironments(ManagedBCEnvironment);
    end;
}
