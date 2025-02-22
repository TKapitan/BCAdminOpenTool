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
        DateIsNotAllowedErr: Label 'Environment %1 cannot be changed. The new update date is after the latest selectable upgrade date.', Comment = '%1 - Environment Name';
    begin
        if not ChangeUpdateDate then
            exit;
        if ManagedBCEnvironment.FindSet() then
            repeat
                ManagedBCEnvironment.TestField(UpdateIsActive, true);
                if NewUpdateDate > ManagedBCEnvironment.LatestSelectableUpgradeDate.Date() then
                    Error(DateIsNotAllowedErr, ManagedBCEnvironment.Name);
            until ManagedBCEnvironment.Next() < 1;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'R')]
    local procedure ProcessChange(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; ChangeUpdateDate: Boolean; NewUpdateDate: Date; ChangeIgnoreUpgradeWindow: Boolean; NewIgnoreUpgradeWindow: Boolean)
    var
        CallAdminAPI: Codeunit TKACallAdminAPI;
        RequestBodyJsonObject: JsonObject;
        Endpoint, Response : Text;
    begin
        Endpoint := CallAdminAPI.GetScheduledUpdateForEnvironmentEndpoint(ManagedBCEnvironment.Name);
        if ManagedBCEnvironment.FindSet() then
            repeat
                Clear(RequestBodyJsonObject);
                if not ChangeUpdateDate then
                    //NewUpdateDate := ManagedBCEnvironment.UpgradeDate;
                if not ChangeIgnoreUpgradeWindow then
                        NewIgnoreUpgradeWindow := ManagedBCEnvironment.IgnoreUpgradeWindow;

                RequestBodyJsonObject.Add('runOn', Format(NewUpdateDate, 0, 9) + 'T00:00:00Z');
                RequestBodyJsonObject.Add('ignoreUpgradeWindow', NewIgnoreUpgradeWindow);
                Response := CallAdminAPI.PutToAdminAPI(ManagedBCEnvironment, Endpoint, RequestBodyJsonObject);
            until ManagedBCEnvironment.Next() < 1;
    end;
}
