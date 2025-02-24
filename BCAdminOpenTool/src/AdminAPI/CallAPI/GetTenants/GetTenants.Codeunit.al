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
}