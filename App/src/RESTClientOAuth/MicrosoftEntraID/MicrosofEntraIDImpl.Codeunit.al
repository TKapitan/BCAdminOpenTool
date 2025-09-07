codeunit 73292 TKAMicrosofEntraIDImpl
{
    Access = Internal;

    var
        TenantId: Text;

    procedure Initialize(ManagedBCTenant: Record TKAManagedBCTenant)
    begin
        ManagedBCTenant.TestField(TenantId);
        TenantId := Format(ManagedBCTenant.TenantId, 0, 4);
    end;

    procedure GetClientApplication(ManagedBCTenant: Record TKAManagedBCTenant) OAuthClientApplication: Codeunit TKAOAuthClientApplication
    var
        ManagedBCAdministrationApp: Record TKAManagedBCAdministrationApp;
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
    begin
        AdminCenterAPISetup.GetRecordOnce();
        if AdminCenterAPISetup.Scope = '' then
            exit;

        ManagedBCAdministrationApp.Get(ManagedBCTenant.ClientId);
        OAuthClientApplication := ManagedBCAdministrationApp.GetOAuth2ClientApplication();
        OAuthClientApplication.AddScope(AdminCenterAPISetup.Scope);
    end;

    procedure GetTokenEndpoint() Url: Text
    var
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
    begin
        AdminCenterAPISetup.GetRecordOnce();
        AdminCenterAPISetup.TestField(TokenUrl);
        Url := StrSubstNo(AdminCenterAPISetup.TokenUrl, TenantId);
    end;
}