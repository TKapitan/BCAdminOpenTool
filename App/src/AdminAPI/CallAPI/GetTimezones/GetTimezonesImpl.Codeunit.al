codeunit 73277 TKAGetTimezonesImpl
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
        ProcessGetTimezonesRespImpl: Codeunit TKAProcessGetTimezonesRespImpl;
        Response: Text;
        CompletedSuccessfullyMsg: Label 'Available timezones have been successfully updated.';
    begin
        ManagedBCTenant.ReadIsolation(IsolationLevel::ReadCommitted);
        ManagedBCTenant.FindFirst();

        Response := CallAdminAPI.GetFromAdminAPI(ManagedBCTenant, CallAdminAPI.GetAvailableTimezonesEndpoint());
        ProcessGetTimezonesRespImpl.ParseGetAvailableUpdateTimezonesResponse(Response);
        Message(CompletedSuccessfullyMsg);
    end;
}
