codeunit 73293 TKAClientCredentialsFlow
{
    var
        ClientCredentialsFlowImpl: Codeunit TKAClientCredentialsFlowImpl;

    /// <summary>
    /// Sets the authority (Microsoft Entra ID tenant) to be used for acquiring tokens.
    /// </summary>
    /// <param name="Value">The Microsoft Entra ID authority as a TKAMicrosoftEntraID codeunit.</param>
    procedure SetAuthority(Value: Codeunit TKAMicrosoftEntraID)
    begin
        ClientCredentialsFlowImpl.SetAuthority(Value);
    end;

    /// <summary>
    /// Returns an authorization header with a bearer token for the client credentials flow.
    /// </summary>
    /// <param name="OAuthClientApplication">The OAuth client application as a TKAOAuthClientApplication codeunit.</param>
    /// <returns>The authorization header as SecretText.</returns>
    procedure GetAuthorizationHeader(OAuthClientApplication: Codeunit TKAOAuthClientApplication) ReturnValue: SecretText
    begin
        ReturnValue := ClientCredentialsFlowImpl.GetAuthorizationHeader(OAuthClientApplication);
    end;
}