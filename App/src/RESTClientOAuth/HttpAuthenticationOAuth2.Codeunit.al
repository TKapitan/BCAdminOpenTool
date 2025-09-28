codeunit 73290 TKAHttpAuthenticationOAuth2 implements "Http Authentication"
{
    var
        HttpAuthenticationOAuth2Imp: Codeunit TKAHttpAuthenticationOAuth2Imp;

    /// <summary>
    /// Initializes the HTTP Authentication with the given OAuth Client Application and Client Credentials Flow.
    /// </summary>
    /// <param name="ClientApplication">The OAuth Client Application codeunit.</param>
    /// <param name="ClientCredentialsFlow">The Client Credentials Flow codeunit.</param>
    procedure Initialize(ClientApplication: Codeunit TKAOAuthClientApplication; ClientCredentialsFlow: Codeunit TKAClientCredentialsFlow)
    begin
        HttpAuthenticationOAuth2Imp.Initialize(ClientApplication, ClientCredentialsFlow);
    end;

    /// <summary>
    /// Determines whether authentication is required for the HTTP request.
    /// </summary>
    /// <returns>True if authentication is required; otherwise, false.</returns>
    procedure IsAuthenticationRequired(): Boolean
    begin
        exit(HttpAuthenticationOAuth2Imp.IsAuthenticationRequired());
    end;

    /// <summary>
    /// Gets the authorization headers to be included in the HTTP request.
    /// </summary>
    /// <returns>A dictionary containing the authorization headers.</returns>
    procedure GetAuthorizationHeaders() Headers: Dictionary of [Text, SecretText]
    begin
        Headers := HttpAuthenticationOAuth2Imp.GetAuthorizationHeaders()
    end;
}