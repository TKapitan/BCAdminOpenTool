codeunit 73280 TKAGetTenantsImpl
{
    Access = Internal;

    /// <summary>
    /// Create or update available (manageable) tenants.
    /// </summary>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCAdministrationApp, 'R')]
    procedure CreateUpdateManageableTenants()
    var
        ManagedBCAdministrationApp: Record TKAManagedBCAdministrationApp;
        CompletedSuccessfullyMsg: Label 'Availabe tenants have been successfully updated.';
    begin
        ManagedBCAdministrationApp.ReadIsolation(IsolationLevel::ReadCommitted);
        if ManagedBCAdministrationApp.FindSet() then
            repeat
                CreateUpdateManageableTenants(ManagedBCAdministrationApp);
            until ManagedBCAdministrationApp.Next() < 1;
        Message(CompletedSuccessfullyMsg);
    end;

    /// <summary>
    /// Create or update available (manageable) tenants for the given BC Administration App.
    /// </summary>
    /// <param name="ManagedBCAdministrationApp">The BC Administration App record.</param>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCTenant, 'R')]
    procedure CreateUpdateManageableTenants(ManagedBCAdministrationApp: Record TKAManagedBCAdministrationApp)
    var
        ManagedBCTenant: Record TKAManagedBCTenant;
        CallAdminAPI: Codeunit TKACallAdminAPI;
        ProcessGetTenantsRespImpl: Codeunit TKAProcessGetTenantsRespImpl;
        Response: Text;
        AtLeastOneTenantMustBeCreatedManuallyMsg: Label 'To Create/Update manageable tenants via API, at least one tenant for every %1 %2 must be created manually.', Comment = '%1 - Administration App Table Name, %2 - Administration App Name';
    begin
        ManagedBCTenant.SetRange(ClientId, ManagedBCAdministrationApp.ClientId);
        if ManagedBCTenant.FindFirst() then begin
            Response := CallAdminAPI.GetFromAdminAPI(ManagedBCTenant, CallAdminAPI.GetManagedBCTenantsEndpoint());
            ProcessGetTenantsRespImpl.ParseGetManageableTenantsResponse(Response, ManagedBCAdministrationApp, true);
        end else
            Message(AtLeastOneTenantMustBeCreatedManuallyMsg, ManagedBCAdministrationApp.TableCaption(), ManagedBCAdministrationApp.Name);
        Commit(); // One BC Admin app processed
    end;
}
