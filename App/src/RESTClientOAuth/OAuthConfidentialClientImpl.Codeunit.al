codeunit 73295 TKAOAuthConfidentialClientImpl
{
    Access = Internal;

    var
        RestClient: Codeunit "Rest Client";
        Base64Convert: Codeunit "Base64 Convert";
        CryptographyManagement: Codeunit "Cryptography Management";
        TimeHelper: Codeunit TKATimeHelper;
        RestClientInitialized: Boolean;

    procedure AcquireTokenForClient(MicrosoftEntraID: Codeunit TKAMicrosoftEntraID; OAuthClientApplication: Codeunit TKAOAuthClientApplication) AuthenticationResult: Codeunit TKAOAuthAuthenticationResult
    var
        AccessTokenRequest: TextBuilder;
    begin
        AccessTokenRequest.Append('grant_type=client_credentials');
        AccessTokenRequest.Append('&client_id=');
        AccessTokenRequest.Append(OAuthClientApplication.GetClientId());
        AccessTokenRequest.Append('&scope=');
        AccessTokenRequest.Append(OAuthClientApplication.GetUrlEncodedScopes());

        AuthenticationResult := SendTokenRequest(AccessTokenRequest.ToText(), MicrosoftEntraID, OAuthClientApplication);
    end;

    local procedure SendTokenRequest(AccessTokenRequest: SecretText; MicrosoftEntraID: Codeunit TKAMicrosoftEntraID; OAuthClientApplication: Codeunit TKAOAuthClientApplication) AuthenticationResult: Codeunit TKAOAuthAuthenticationResult
    var
        HttpResponseMessage: Codeunit "Http Response Message";
        HttpContent: Codeunit "Http Content";
        AccessTokenRequestTxt: SecretText;
    begin
        AccessTokenRequestTxt := FinishTokenRequest(AccessTokenRequest, MicrosoftEntraID, OAuthClientApplication);
        HttpContent := HttpContent.Create(AccessTokenRequestTxt, 'application/x-www-form-urlencoded');

        InitializeRestClient();
        HttpResponseMessage := RestClient.Post(MicrosoftEntraID.GetTokenEndpoint(), HttpContent);

        if not HttpResponseMessage.GetIsSuccessStatusCode() then
            Error(ErrorInfo.Create(HttpResponseMessage.GetErrorMessage(), true));
        AuthenticationResult.SetResponse(HttpResponseMessage.GetContent().AsJson().AsObject());
    end;

    local procedure FinishTokenRequest(AccessTokenRequest: SecretText; MicrosoftEntraID: Codeunit TKAMicrosoftEntraID; OAuthClientApplication: Codeunit TKAOAuthClientApplication) ReturnValue: SecretText
    var
        ClientCredentialNotSetErr: Label 'Either client certificate or client secret must be set for confidential client authentication.';
    begin
        // Check if using certificate-based authentication
        if OAuthClientApplication.GetCertificate().HasValue() then begin
            ReturnValue := FinishTokenRequestWithCertificate(AccessTokenRequest, MicrosoftEntraID, OAuthClientApplication);
            exit;
        end;

        // Check if using client secret authentication
        if OAuthClientApplication.HasClientSecret() then begin
            ReturnValue := FinishTokenRequestWithClientSecret(AccessTokenRequest, OAuthClientApplication);
            exit;
        end;

        // Neither certificate nor client secret is set
        Error(ClientCredentialNotSetErr);
    end;

    local procedure FinishTokenRequestWithCertificate(AccessTokenRequest: SecretText; MicrosoftEntraID: Codeunit TKAMicrosoftEntraID; OAuthClientApplication: Codeunit TKAOAuthClientApplication) ReturnValue: SecretText
    var
        SignatureTextBuilder: TextBuilder;
    begin
        SignatureTextBuilder.Append('&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer');
        SignatureTextBuilder.Append('&client_assertion=');
        SignatureTextBuilder.Append(SignTokenRequest(MicrosoftEntraID, OAuthClientApplication));
        ReturnValue := SecretStrSubstNo('%1%2', AccessTokenRequest, SignatureTextBuilder.ToText());
    end;

    local procedure FinishTokenRequestWithClientSecret(AccessTokenRequest: SecretText; OAuthClientApplication: Codeunit TKAOAuthClientApplication) ReturnValue: SecretText
    var
        Uri: DotNet System.Uri;
        EncodedClientSecret: Text;
    begin
        EncodedClientSecret := Uri.EncodeDataString(OAuthClientApplication.GetClientSecret());
        ReturnValue := SecretStrSubstNo('%1&client_secret=%2', AccessTokenRequest, EncodedClientSecret);
    end;

    local procedure SignTokenRequest(MicrosoftEntraID: Codeunit TKAMicrosoftEntraID; OAuthClientApplication: Codeunit TKAOAuthClientApplication) Jwt: Text
    var
        Signature: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
        JsonHeader, JsonClaims : JsonObject;
        JsonText, SignatureBase64 : Text;
    begin
        JsonHeader.Add('alg', 'RS256');
        JsonHeader.Add('typ', 'JWT');
        JsonHeader.Add('x5t', OAuthClientApplication.GetCertificate().ThumbprintBase64());
        JsonHeader.WriteTo(JsonText);
        Jwt := Base64UrlEncode(Base64Convert.ToBase64(JsonText));

        JsonClaims.Add('aud', MicrosoftEntraID.GetTokenEndpoint());
        JsonClaims.Add('exp', TimeHelper.GetEpochTimestamp(CreateDateTime(Today(), Time() + (5 * 60000))));
        JsonClaims.Add('iss', OAuthClientApplication.GetClientId());
        JsonClaims.Add('jti', Format(CreateGuid(), 0, 4).ToLower());
        JsonClaims.Add('nbf', TimeHelper.GetEpochTimestamp(CreateDateTime(Today(), Time() - 60000)));
        JsonClaims.Add('sub', OAuthClientApplication.GetClientId());
        JsonClaims.Add('iat', TimeHelper.GetEpochTimestamp(CreateDateTime(Today(), Time())));
        JsonClaims.WriteTo(JsonText);
        Jwt := Jwt + '.' + Base64UrlEncode(Base64Convert.ToBase64(JsonText));

        Signature.CreateOutStream(OutStream);
        CryptographyManagement.SignData(Jwt, OAuthClientApplication.GetCertificate().GetPrivateKey(), Enum::"Hash Algorithm"::SHA256, OutStream);

        Signature.CreateInStream(InStream);
        SignatureBase64 := Base64UrlEncode(Base64Convert.ToBase64(InStream));
        Jwt := Jwt + '.' + SignatureBase64;
    end;

    local procedure Base64UrlEncode(Input: Text) Output: Text
    begin
        Output := Input.Replace('+', '-')
                       .Replace('/', '_')
                       .Replace('=', '');
    end;

    local procedure InitializeRestClient()
    var
        HttpClientHandler: Codeunit "Http Client Handler";
    begin
        if RestClientInitialized then
            exit;

        RestClient.Initialize(HttpClientHandler);
        RestClientInitialized := true;
    end;
}