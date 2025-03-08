codeunit 73273 TKAGetEnvironmentsImpl
{
    Access = Internal;

    /// <summary>
    /// Create or update environments for a tenant.
    /// </summary>
    /// <param name="ManagedBCTenant">The tenant for which to create or update environments.</param>
    /// <param name="HideDialog">Specifies whether to hide any dialog.</param>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCTenant, 'M')]
    procedure CreateUpdateEnvironmentsForTenant(var ManagedBCTenant: Record TKAManagedBCTenant; HideDialog: Boolean)
    var
        CallAdminAPI: Codeunit TKACallAdminAPI;
        ProcessGetEnvResponseImpl: Codeunit TKAProcessGetEnvResponseImpl;
        Response: Text;
        CompletedSuccessfullyMsg: Label 'Environments have been successfully updated.';
    begin
        Response := CallAdminAPI.GetFromAdminAPI(ManagedBCTenant, CallAdminAPI.GetListAllEnvironmentsEndpoint());
        ProcessGetEnvResponseImpl.ParseGetEnvironmentsResponse(Response);

        ManagedBCTenant.Validate(EnvironmentsModifiedAt, CurrentDateTime());
        ManagedBCTenant.Modify(true);

        ProcessAdditionalEndpointsForEnvironmentSync(ManagedBCTenant);
        if not HideDialog then
            Message(CompletedSuccessfullyMsg);
    end;

    /// <summary>
    /// Update selected environments.
    /// </summary>
    /// <param name="ManagedBCEnvironment">The environments to update.</param>
    /// <param name="HideDialog">Specifies whether to hide any dialog.</param>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'R')]
    procedure UpdateSelectedEnvironments(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; HideDialog: Boolean)
    var
        ManagedBCEnvironment2: Record TKAManagedBCEnvironment;
        CallAdminAPI: Codeunit TKACallAdminAPI;
        ProcessGetEnvResponseImpl: Codeunit TKAProcessGetEnvResponseImpl;
        HttpResponseMessage: HttpResponseMessage;
        Response: Text;
        CompletedSuccessfullyMsg: Label 'Environments have been successfully updated.';
    begin
        if ManagedBCEnvironment.FindSet() then
            repeat
                if not CallAdminAPI.GetFromAdminAPI(ManagedBCEnvironment.GetManagedBCTenant(), CallAdminAPI.GetEnvironmentEndpoint(ManagedBCEnvironment.Name), HttpResponseMessage) then begin
                    if HttpResponseMessage.HttpStatusCode() = 404 then
                        ProcessGetEnvResponseImpl.DeleteEnvironment(ManagedBCEnvironment)
                    else
                        CallAdminAPI.ThrowError(HttpResponseMessage);
                end else begin
                    HttpResponseMessage.Content().ReadAs(Response);
                    ProcessGetEnvResponseImpl.ParseEnvironmentResponse(Response, ManagedBCEnvironment.TenantId, ManagedBCEnvironment.Name);

                    ManagedBCEnvironment2.GetBySystemId(ManagedBCEnvironment.SystemId);
                    ProcessAdditionalEndpointsForEnvironmentSync(ManagedBCEnvironment2);
                end;
            until ManagedBCEnvironment.Next() < 1;
        if not HideDialog then
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
        ProcessGetEnvResponseImpl: Codeunit TKAProcessGetEnvResponseImpl;
        Response: Text;
    begin
        AdminCenterAPISetup.ReadIsolation(IsolationLevel::ReadUncommitted);
        AdminCenterAPISetup.SetLoadFields(GetScheduledUpdateAPIEnabled, GetUpdateSettingsAPIEnabled, GetInstalledAppsEnabled);
        AdminCenterAPISetup.Get();

        if AdminCenterAPISetup.GetScheduledUpdateAPIEnabled then begin
            Response := CallAdminAPI.GetFromAdminAPI(ManagedBCEnvironment.GetManagedBCTenant(), CallAdminAPI.GetScheduledUpdateForEnvironmentEndpoint(ManagedBCEnvironment.Name));
            ProcessGetEnvResponseImpl.ParseGetScheduledUpdateResponse(Response, ManagedBCEnvironment);
        end;
        if AdminCenterAPISetup.GetUpdateSettingsAPIEnabled then begin
            Response := CallAdminAPI.GetFromAdminAPI(ManagedBCEnvironment.GetManagedBCTenant(), CallAdminAPI.GetUpdateSettingsForEnvironmentEndpoint(ManagedBCEnvironment.Name));
            ProcessGetEnvResponseImpl.ParseUpdateSettingsResponse(Response, ManagedBCEnvironment);
        end;
        if AdminCenterAPISetup.GetInstalledAppsEnabled then begin
            Response := CallAdminAPI.GetFromAdminAPI(ManagedBCEnvironment.GetManagedBCTenant(), CallAdminAPI.GetInstalledAppsForEnvironmentEndpoint(ManagedBCEnvironment.Name));
            ProcessGetEnvResponseImpl.ParseInstalledAppsResponse(Response, ManagedBCEnvironment);
        end;
    end;
}
