codeunit 73272 TKARunAdminAPIForEnv
{
    Access = Public;

    var
        RunAdminAPIForEnvImpl: Codeunit TKARunAdminAPIForEnvImpl;

    /// <summary>
    /// Create or update environments for a tenant.
    /// </summary>
    /// <param name="ForBCTenant">The tenant for which to create or update environments.</param>
    procedure CreateUpdateEnvironmentsForTenant(var ForBCTenant: Record TKAManagedBCTenant)
    begin
        RunAdminAPIForEnvImpl.CreateUpdateEnvironmentsForTenant(ForBCTenant);
    end;
}