codeunit 73291 TKAHttpAuthenticationOAuth2Imp
{
    Access = Internal;

    var
        OAuthClientApplication: Codeunit TKAOAuthClientApplication;
        ClientCredentialsFlow: Codeunit TKAClientCredentialsFlow;

    procedure Initialize(ClientApplication: Codeunit TKAOAuthClientApplication; NewClientCredentialsFlow: Codeunit TKAClientCredentialsFlow)
    begin
        OAuthClientApplication := ClientApplication;
        ClientCredentialsFlow := NewClientCredentialsFlow;
    end;

    procedure IsAuthenticationRequired(): Boolean
    begin
        exit(true);
    end;

    procedure GetAuthorizationHeaders() Headers: Dictionary of [Text, SecretText]
    begin
        Headers.Add('Authorization', ClientCredentialsFlow.GetAuthorizationHeader(OAuthClientApplication));
    end;
}