codeunit 73294 TKAClientCredentialsFlowImpl
{
    Access = Internal;

    var
        MicrosoftEntraID: Codeunit TKAMicrosoftEntraID;
        OAuthAuthenticationResult: Codeunit TKAOAuthAuthenticationResult;

    procedure SetAuthority(Value: Codeunit TKAMicrosoftEntraID)
    begin
        MicrosoftEntraID := Value;
    end;

    procedure GetAuthorizationHeader(OAuthClientApplication: Codeunit TKAOAuthClientApplication) ReturnValue: SecretText
    var
        OAuthConfidentialClient: Codeunit TKAOAuthConfidentialClient;
    begin
        if OAuthAuthenticationResult.IsValid() then
            exit(OAuthAuthenticationResult.GetAuthorizationHeader());

        OAuthAuthenticationResult := OAuthConfidentialClient.AcquireTokenForClient(MicrosoftEntraID, OAuthClientApplication);
        ReturnValue := OAuthAuthenticationResult.GetAuthorizationHeader();
    end;
}