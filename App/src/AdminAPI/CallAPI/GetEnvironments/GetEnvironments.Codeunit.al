codeunit 73272 TKAGetEnvironments
{
    Access = Public;

    var
        GetEnvironmentsImpl: Codeunit TKAGetEnvironmentsImpl;

    /// <summary>
    /// Create or update environments for a tenant.
    /// </summary>
    /// <param name="ManagedBCTenant">The tenant for which to create or update environments.</param>
    procedure CreateUpdateEnvironmentsForTenant(var ManagedBCTenant: Record TKAManagedBCTenant)
    begin
        GetEnvironmentsImpl.CreateUpdateEnvironmentsForTenant(ManagedBCTenant);
    end;

    /// <summary>
    /// Update selected environments.
    /// </summary>
    /// <param name="ManagedBCEnvironment">The environments to update.</param>
    procedure UpdateSelectedEnvironments(var ManagedBCEnvironment: Record TKAManagedBCEnvironment)
    begin
        GetEnvironmentsImpl.UpdateSelectedEnvironments(ManagedBCEnvironment);
    end;
}