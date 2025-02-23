codeunit 73273 TKARunAdminAPIForEnvImpl
{
    Access = Internal;

    /// <summary>
    /// Create or update environments for a tenant.
    /// </summary>
    /// <param name="ForBCTenant">The tenant for which to create or update environments.</param>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCTenant, 'M')]
    procedure CreateUpdateEnvironmentsForTenant(var ForBCTenant: Record TKAManagedBCTenant)
    var
        CallAdminAPI: Codeunit TKACallAdminAPI;
        ProcessAdminAPIEnvRespImpl: Codeunit TKAProcessAdminAPIEnvRespImpl;
        Response: Text;
    begin
        Response := CallAdminAPI.GetFromAdminAPI(ForBCTenant, CallAdminAPI.GetListAllEnvironmentsEndpoint());
        ProcessAdminAPIEnvRespImpl.ParseGetEnvironmentsResponse(Response);

        ForBCTenant.Validate(EnvironmentsModifiedAt, CurrentDateTime());
        ForBCTenant.Modify(true);

        ProcessAdditionalEndpointsForEnvironmentSync(ForBCTenant);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'R')]
    local procedure ProcessAdditionalEndpointsForEnvironmentSync(ManagedBCTenant: Record TKAManagedBCTenant)
    var
        ManagedBCEnvironment: Record TKAManagedBCEnvironment;
    begin
        ManagedBCEnvironment.ReadIsolation(IsolationLevel::ReadCommitted);
        ManagedBCEnvironment.SetRange(TenantId, ManagedBCTenant.TenantId);
        if ManagedBCEnvironment.FindSet() then
            repeat
                GetScheduledUpdateForEnvironment(ManagedBCTenant, ManagedBCEnvironment);
            until ManagedBCEnvironment.Next() < 1;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAAdminCenterAPISetup, 'R')]
    local procedure GetScheduledUpdateForEnvironment(ManagedBCTenant: Record TKAManagedBCTenant; ManagedBCEnvironment: Record TKAManagedBCEnvironment)
    var
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
        CallAdminAPI: Codeunit TKACallAdminAPI;
        ProcessAdminAPIEnvRespImpl: Codeunit TKAProcessAdminAPIEnvRespImpl;
        Response: Text;
    begin
        AdminCenterAPISetup.ReadIsolation(IsolationLevel::ReadUncommitted);
        AdminCenterAPISetup.SetLoadFields(GetScheduledUpdateAPIEnabled);
        AdminCenterAPISetup.Get();
        if not AdminCenterAPISetup.GetScheduledUpdateAPIEnabled then
            exit;

        Response := CallAdminAPI.GetFromAdminAPI(ManagedBCTenant, CallAdminAPI.GetScheduledUpdateForEnvironmentEndpoint(ManagedBCEnvironment.Name));
        ProcessAdminAPIEnvRespImpl.ParseGetScheduledUpdateResponse(Response, ManagedBCEnvironment);
    end;
}
