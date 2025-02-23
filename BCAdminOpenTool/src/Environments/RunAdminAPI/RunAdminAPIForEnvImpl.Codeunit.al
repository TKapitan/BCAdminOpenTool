codeunit 73273 TKARunAdminAPIForEnvImpl
{
    Access = Internal;

    /// <summary>
    /// Create or update environments for a tenant.
    /// </summary>
    /// <param name="ManagedBCTenant">The tenant for which to create or update environments.</param>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCTenant, 'M')]
    procedure CreateUpdateEnvironmentsForTenant(var ManagedBCTenant: Record TKAManagedBCTenant)
    var
        CallAdminAPI: Codeunit TKACallAdminAPI;
        ProcessAdminAPIEnvRespImpl: Codeunit TKAProcessAdminAPIEnvRespImpl;
        Response: Text;
        CompletedSuccessfullyMsg: Label 'Environments have been successfully updated.';
    begin
        Response := CallAdminAPI.GetFromAdminAPI(ManagedBCTenant, CallAdminAPI.GetListAllEnvironmentsEndpoint());
        ProcessAdminAPIEnvRespImpl.ParseGetEnvironmentsResponse(Response);

        ManagedBCTenant.Validate(EnvironmentsModifiedAt, CurrentDateTime());
        ManagedBCTenant.Modify(true);

        ProcessAdditionalEndpointsForEnvironmentSync(ManagedBCTenant);
        Message(CompletedSuccessfullyMsg);
    end;

    /// <summary>
    /// Update selected environments.
    /// </summary>
    /// <param name="ManagedBCEnvironment">The environments to update.</param>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'R')]
    procedure UpdateSelectedEnvironments(var ManagedBCEnvironment: Record TKAManagedBCEnvironment)
    var
        ManagedBCEnvironment2: Record TKAManagedBCEnvironment;
        CallAdminAPI: Codeunit TKACallAdminAPI;
        ProcessAdminAPIEnvRespImpl: Codeunit TKAProcessAdminAPIEnvRespImpl;
        Response: Text;
        CompletedSuccessfullyMsg: Label 'Environments have been successfully updated.';
    begin
        if ManagedBCEnvironment.FindSet() then
            repeat
                Response := CallAdminAPI.GetFromAdminAPI(ManagedBCEnvironment.GetManagedBCTenant(), CallAdminAPI.GetEnvironmentEndpoint(ManagedBCEnvironment.Name));
                ProcessAdminAPIEnvRespImpl.ParseEnvironmentResponse(Response, ManagedBCEnvironment.TenantId, ManagedBCEnvironment.Name);

                ManagedBCEnvironment2.GetBySystemId(ManagedBCEnvironment.SystemId);
                ProcessAdditionalEndpointsForEnvironmentSync(ManagedBCEnvironment2);
            until ManagedBCEnvironment.Next() < 1;

        Message(CompletedSuccessfullyMsg);
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
                ProcessAdditionalEndpointsForEnvironmentSync(ManagedBCEnvironment);
            until ManagedBCEnvironment.Next() < 1;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAAdminCenterAPISetup, 'R')]
    local procedure ProcessAdditionalEndpointsForEnvironmentSync(var ManagedBCEnvironment: Record TKAManagedBCEnvironment)
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

        Response := CallAdminAPI.GetFromAdminAPI(ManagedBCEnvironment.GetManagedBCTenant(), CallAdminAPI.GetScheduledUpdateForEnvironmentEndpoint(ManagedBCEnvironment.Name));
        ProcessAdminAPIEnvRespImpl.ParseGetScheduledUpdateResponse(Response, ManagedBCEnvironment);
    end;
}
