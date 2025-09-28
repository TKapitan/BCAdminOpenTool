codeunit 73289 TKAMicrosoftEntraID
{
    var
        MicrosoftEntraIDImpl: Codeunit TKAMicrosoftEntraIDImpl;

    /// <summary>
    /// Initializes the codeunit with data from the provided ManagedBCTenant record.
    /// </summary>
    /// <param name="ManagedBCTenant">The ManagedBCTenant record to initialize from. Must have TenantId and ClientId set.</param>
    procedure Initialize(ManagedBCTenant: Record TKAManagedBCTenant)
    begin
        MicrosoftEntraIDImpl.Initialize(ManagedBCTenant);
    end;

    /// <summary>
    /// Returns an OAuthClientApplication codeunit initialized with data from the provided ManagedBCTenant record.
    /// </summary>
    /// <param name="ManagedBCTenant">The ManagedBCTenant record to get the client application for. Must have TenantId and ClientId set.</param>
    /// <returns>The initialized OAuthClientApplication codeunit.</returns>
    procedure GetClientApplication(ManagedBCTenant: Record TKAManagedBCTenant) OAuthClientApplication: Codeunit TKAOAuthClientApplication
    begin
        OAuthClientApplication := MicrosoftEntraIDImpl.GetClientApplication(ManagedBCTenant)
    end;

    /// <summary>
    /// Returns the token endpoint URL for the tenant.
    /// </summary>
    /// <returns>The token endpoint URL.</returns>
    procedure GetTokenEndpoint(): Text
    begin
        exit(MicrosoftEntraIDImpl.GetTokenEndpoint());
    end;
}