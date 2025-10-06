codeunit 73279 TKAGetTenants
{
    Access = Public;

    var
        GetTenantsImpl: Codeunit TKAGetTenantsImpl;

    /// <summary>
    /// Create or update available (manageable) tenants.
    /// </summary>
    procedure CreateUpdateManageableTenants()
    begin
        GetTenantsImpl.CreateUpdateManageableTenants();
    end;

    /// <summary>
    /// Create or update available (manageable) tenants for the given BC Administration App.
    /// </summary>
    /// <param name="ManagedBCAdministrationApp">The BC Administration App record.</param>
    procedure CreateUpdateManageableTenants(ManagedBCAdministrationApp: Record TKAManagedBCAdministrationApp)
    begin
        GetTenantsImpl.CreateUpdateManageableTenants(ManagedBCAdministrationApp);
    end;
}