codeunit 73271 TKACallAdminAPI
{
    Access = Public;

    var
        CallAdminAPIImpl: Codeunit TKACallAdminAPIImpl;

    /// <summary>
    /// Verifies the connection to the specified BC tenant.
    /// </summary>
    /// <param name="ForBCTenant">Specifies the BC tenant to connect to.</param>
    procedure TestAdminCenterConnection(ForBCTenant: Record TKAManagedBCTenant)
    begin
        CallAdminAPIImpl.TestAdminCenterConnection(ForBCTenant);
    end;

    /// <summary>
    /// Gets the environments for the specified BC tenant.
    /// </summary>
    /// <param name="ForBCTenant">Specifies the BC tenant for which the environments are to be retrieved.</param>
    /// <returns></returns>
    procedure GetEnvironmentsForTenant(ForBCTenant: Record TKAManagedBCTenant): Text
    begin
        exit(CallAdminAPIImpl.GetEnvironmentsForTenant(ForBCTenant));
    end;
}
