codeunit 73277 TKARunAdminAPIForTimezonesImpl
{
    Access = Internal;

    /// <summary>
    /// Create or update available timezones.
    /// </summary>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCTenant, 'R')]
    procedure CreateUpdateAvailableUpdateTimezones()
    var
        ManagedBCTenant: Record TKAManagedBCTenant;
        CallAdminAPI: Codeunit TKACallAdminAPI;
        ProcessAdminAPITmzRespImpl: Codeunit TKAProcessAdminAPITmzRespImpl;
        Response: Text;
        CompletedSuccessfullyMsg: Label 'Available timezones have been successfully updated.';
    begin
        ManagedBCTenant.ReadIsolation(IsolationLevel::ReadCommitted);
        ManagedBCTenant.FindFirst();

        Response := CallAdminAPI.GetFromAdminAPI(ManagedBCTenant, CallAdminAPI.GetAvailableTimezonesEndpoint());
        ProcessAdminAPITmzRespImpl.ParseGetAvailableUpdateTimezonesResponse(Response);
        Message(CompletedSuccessfullyMsg);
    end;
}
