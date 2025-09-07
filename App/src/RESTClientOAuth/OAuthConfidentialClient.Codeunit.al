codeunit 73297 TKAOAuthConfidentialClient
{
    var
        OAuthConfidentialClientImpl: Codeunit TKAOAuthConfidentialClientImpl;

    /// <summary>
    /// Acquires a token for the client using the client credentials flow.
    /// </summary>
    /// <param name="MicrosoftEntraID">Instance of the TKAMicrosoftEntraID codeunit representing the authority.</param>
    /// <param name="OAuthClientApplication">Instance of the TKAOAuthClientApplication codeunit representing the client application.</param>
    /// <returns>An instance of the TKAOAuthAuthenticationResult codeunit containing the authentication result.</returns>
    procedure AcquireTokenForClient(MicrosoftEntraID: Codeunit TKAMicrosoftEntraID; OAuthClientApplication: Codeunit TKAOAuthClientApplication) AuthenticationResult: Codeunit TKAOAuthAuthenticationResult
    begin
        AuthenticationResult := OAuthConfidentialClientImpl.AcquireTokenForClient(MicrosoftEntraID, OAuthClientApplication);
    end;
}