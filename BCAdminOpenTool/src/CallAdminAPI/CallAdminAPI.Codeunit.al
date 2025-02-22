codeunit 73271 TKACallAdminAPI
{
    Access = Public;

    var
        CallAdminAPIImpl: Codeunit TKACallAdminAPIImpl;

    /// <summary>
    /// Verifies the connection to the specified BC tenant.
    /// </summary>
    /// <param name="ForBCTenant">Specifies the BC tenant to connect to.</param>
    procedure TestAdminCenterConnection(ForBCTenant: Record TKABCTenant)
    begin
        CallAdminAPIImpl.TestAdminCenterConnection(ForBCTenant);
    end;
}
