codeunit 73281 TKAProcessGetTenantsRespImpl
{
    Access = Internal;

    #region Manageable Tenants

    /// <summary>
    /// Parses the response from the Admin API for getting manageable tenants.
    /// </summary>
    /// <param name="Response">The response from the Admin API.</param>
    /// <param name="ManagedBCAdministrationApp">The managed BC administration app.</param>
    /// <param name="HideDialog">Specifies whether to hide any dialog.</param>
    procedure ParseGetManageableTenantsResponse(Response: Text; ManagedBCAdministrationApp: Record TKAManagedBCAdministrationApp; HideDialog: Boolean)
    var
        JsonResponse, JsonTenant : JsonObject;
        JsonTokenValue, JsonTokenTenant : JsonToken;
        JsonTenants: JsonArray;
    begin
        JsonResponse.ReadFrom(Response);
        JsonResponse.Get('value', JsonTokenValue);
        JsonTenants := JsonTokenValue.AsArray();
        foreach JsonTokenTenant in JsonTenants do begin
            JsonTenant := JsonTokenTenant.AsObject();
            ParseManageableTenantsResponse(JsonTenant, ManagedBCAdministrationApp, HideDialog);
        end;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCTenant, 'RIM')]
    local procedure ParseManageableTenantsResponse(var JsonTenant: JsonObject; ManagedBCAdministrationApp: Record TKAManagedBCAdministrationApp; HideDialog: Boolean)
    var
        ManagedBCTenant: Record TKAManagedBCTenant;
        GetEnvironments: Codeunit TKAGetEnvironments;
        JsonTokenValue: JsonToken;
        TenantIdAsText: Text[100];
        TenantId: Guid;
        CompletedSuccessfullyMsg: Label 'Tenants & Environments have been successfully updated.';
    begin
        JsonTenant.Get('entraTenantId', JsonTokenValue);
        TenantIdAsText := CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(TenantId));
        Evaluate(TenantId, TenantIdAsText);

        if not ManagedBCTenant.Get(TenantId) then begin
            ManagedBCTenant.Init();
            ManagedBCTenant.Validate(TenantId, TenantId);
            ManagedBCTenant.Insert(true);
        end;
        ManagedBCTenant.Validate(ClientId, ManagedBCAdministrationApp.ClientId);
        ManagedBCTenant.Modify(true);

        GetEnvironments.CreateUpdateEnvironmentsForTenant(ManagedBCTenant, true);
        if not HideDialog then
            Message(CompletedSuccessfullyMsg);
    end;

    #endregion Manageable Tenants
}