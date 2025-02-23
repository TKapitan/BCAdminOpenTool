codeunit 73272 TKARunAdminAPIForEnv
{
    Access = Public;

    var
        RunAdminAPIForEnvImpl: Codeunit TKARunAdminAPIForEnvImpl;

    /// <summary>
    /// Create or update environments for a tenant.
    /// </summary>
    /// <param name="ManagedBCTenant">The tenant for which to create or update environments.</param>
    procedure CreateUpdateEnvironmentsForTenant(var ManagedBCTenant: Record TKAManagedBCTenant)
    begin
        RunAdminAPIForEnvImpl.CreateUpdateEnvironmentsForTenant(ManagedBCTenant);
    end;

    /// <summary>
    /// Update selected environments.
    /// </summary>
    /// <param name="ManagedBCEnvironment">The environments to update.</param>
    procedure UpdateSelectedEnvironments(var ManagedBCEnvironment: Record TKAManagedBCEnvironment)
    begin
        RunAdminAPIForEnvImpl.UpdateSelectedEnvironments(ManagedBCEnvironment);
    end;
}