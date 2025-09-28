codeunit 73280 TKAGetTenantsImpl
{
    Access = Internal;

    /// <summary>
    /// Create or update available (manageable) tenants.
    /// </summary>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCAdministrationApp, 'R')]
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCTenant, 'R')]
    procedure CreateUpdateManageableTenants()
    var
        ManagedBCAdministrationApp: Record TKAManagedBCAdministrationApp;
        ManagedBCTenant: Record TKAManagedBCTenant;
        CallAdminAPI: Codeunit TKACallAdminAPI;
        ProcessGetTenantsRespImpl: Codeunit TKAProcessGetTenantsRespImpl;
        Response: Text;
        CompletedSuccessfullyMsg: Label 'Availabe tenants have been successfully updated.';
        AtLeastOneTenantMustBeCreatedManuallyMsg: Label 'To Create/Update manageable tenants via API, at least one tenant for every %1 %2 must be created manually.', Comment = '%1 - Administration App Table Name, %2 - Administration App Name';
    begin
        ManagedBCAdministrationApp.ReadIsolation(IsolationLevel::ReadCommitted);
        if ManagedBCAdministrationApp.FindSet() then
            repeat
                ManagedBCTenant.SetRange(ClientId, ManagedBCAdministrationApp.ClientId);
                if ManagedBCTenant.FindFirst() then begin
                    Response := CallAdminAPI.GetFromAdminAPI(ManagedBCTenant, CallAdminAPI.GetManagedBCTenantsEndpoint());
                    ProcessGetTenantsRespImpl.ParseGetManageableTenantsResponse(Response, ManagedBCAdministrationApp, true);
                end else
                    Message(AtLeastOneTenantMustBeCreatedManuallyMsg, ManagedBCAdministrationApp.TableCaption(), ManagedBCAdministrationApp.Name);
                Commit(); // One BC Admin app processed
            until ManagedBCAdministrationApp.Next() < 1;
        Message(CompletedSuccessfullyMsg);
    end;
}
