codeunit 73282 TKAAdminAPIRESTClient
{
    /// <summary>
    /// Creates and initializes a REST Client configured for OAuth2 authentication using the Client Credentials flow.
    /// </summary>
    /// <param name="ManagedBCTenant">The ManagedBCTenant record containing the necessary OAuth configuration. Must have TenantId and ClientId set.</param>
    /// <returns>The initialized REST Client codeunit.</returns>
    procedure GetRestClient(ManagedBCTenant: Record TKAManagedBCTenant) RestClient: Codeunit "Rest Client"
    var
        OAuthClientApplication: Codeunit TKAOAuthClientApplication;
        ClientCredentialsFlow: Codeunit TKAClientCredentialsFlow;
        MicrosoftEntraID: Codeunit TKAMicrosoftEntraID;
    begin
        MicrosoftEntraID.Initialize(ManagedBCTenant);
        OAuthClientApplication := MicrosoftEntraID.GetClientApplication(ManagedBCTenant);
        InitClientCredentialFlow(MicrosoftEntraID, ClientCredentialsFlow);
        InitRESTClient(OAuthClientApplication, ClientCredentialsFlow, RestClient);
    end;

    local procedure InitClientCredentialFlow(var MicrosoftEntraID: Codeunit TKAMicrosoftEntraID; var ClientCredentialsFlow: Codeunit TKAClientCredentialsFlow)
    begin
        ClientCredentialsFlow.SetAuthority(MicrosoftEntraID);
    end;

    local procedure InitRESTClient(var OAuthClientApplication: Codeunit TKAOAuthClientApplication; var ClientCredentialsFlow: Codeunit TKAClientCredentialsFlow; var RestClient: Codeunit "Rest Client")
    var
        HttpAuthenticationOAuth2: Codeunit TKAHttpAuthenticationOAuth2;
        HttpClientHandler: Codeunit TKAHttpClientHandler;
        HttpAuthentication: Interface "Http Authentication";
    begin
        HttpAuthenticationOAuth2.Initialize(OAuthClientApplication, ClientCredentialsFlow);
        HttpAuthentication := HttpAuthenticationOAuth2;
        RestClient.Initialize(HttpClientHandler, HttpAuthentication);
    end;
}