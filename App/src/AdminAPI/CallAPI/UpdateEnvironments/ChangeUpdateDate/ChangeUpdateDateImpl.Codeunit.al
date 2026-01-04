codeunit 73275 TKAChangeUpdateDateImpl
{
    Access = Internal;

    procedure RunChangeUpdateDate(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; NewUpdateDate: Date; ChangeIgnoreUpgradeWindow: Boolean; NewIgnoreUpgradeWindow: Boolean)
    begin
        TestChangesPossible(ManagedBCEnvironment, NewUpdateDate);
        ProcessChange(ManagedBCEnvironment, NewUpdateDate, ChangeIgnoreUpgradeWindow, NewIgnoreUpgradeWindow);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'R')]
    local procedure TestChangesPossible(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; NewUpdateDate: Date)
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
    local procedure ProcessChange(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; NewUpdateDate: Date; ChangeIgnoreUpgradeWindow: Boolean; NewIgnoreUpgradeWindow: Boolean)
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
}
