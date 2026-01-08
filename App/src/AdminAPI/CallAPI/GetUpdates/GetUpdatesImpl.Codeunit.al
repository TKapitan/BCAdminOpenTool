codeunit 73305 TKAGetUpdatesImpl
{
    Access = Internal;

    /// <summary>
    /// Get updates for a specific environment.
    /// </summary>
    /// <param name="ManagedBCEnvironment">The environment for which to get the updates.</param>
    /// <param name="HideDialog">Specifies whether to hide any dialog.</param>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCTenant, 'M')]
    procedure GetUpdatesForEnvironment(ManagedBCEnvironment: Record TKAManagedBCEnvironment; HideDialog: Boolean)
    var
        ManagedBCTenant: Record TKAManagedBCTenant;
        CallAdminAPI: Codeunit TKACallAdminAPI;
        ProcessGetUpdResponseImpl: Codeunit TKAProcessGetUpdResponseImpl;
        Response: Text;
        CompletedSuccessfullyMsg: Label 'Available updates have been successfully retrieved for the environment.';
    begin
        ManagedBCTenant.Get(ManagedBCEnvironment.TenantId);
        Response := CallAdminAPI.GetFromAdminAPI(ManagedBCTenant, CallAdminAPI.GetUpdatesForEnvironmentEndpoint(ManagedBCEnvironment.Name));
        ProcessGetUpdResponseImpl.ParseGetUpdatesResponse(ManagedBCEnvironment, Response);
        if not HideDialog then
            Message(CompletedSuccessfullyMsg);
    end;
}
