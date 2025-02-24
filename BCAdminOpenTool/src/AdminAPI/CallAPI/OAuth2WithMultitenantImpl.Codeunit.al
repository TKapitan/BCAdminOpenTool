codeunit 73282 TKAOAuth2WithMultitenantImpl
{
    Access = Internal;
    SingleInstance = true;

    var
        AccessTokenBuffer: Dictionary of [Guid, Dictionary of [Text, Dictionary of [DateTime, SecretText]]];

    [NonDebuggable]
    procedure FetchBearerTokenImpl(ClientId: Guid; ClientSecret: SecretText; TenantId: Guid; OAuthAuthorityUrl: Text; var AccessToken: SecretText)
    var
        AccessTokenDetails: Dictionary of [DateTime, SecretText];
        TenantAccessTokenDetails: Dictionary of [Text, Dictionary of [DateTime, SecretText]];
        TokenRequestBody, Scopes : SecretText;
        TokenRequestAuthentication: SecretText;
        HttpResponseMessage: HttpResponseMessage;
        TokenValidity: DateTime;
        TokenRequestBodyTok: Label 'grant_type=client_credentials%1', Locked = true;
        ScopeRequestBodyTok: Label '&scope=https://api.businesscentral.dynamics.com/.default', Locked = true;
        MergeTokensTok: Label '%1%2', Locked = true;
    begin
        if AccessTokenBuffer.ContainsKey(ClientId) then begin
            TenantAccessTokenDetails := AccessTokenBuffer.Get(ClientId);
            if TenantAccessTokenDetails.ContainsKey(TenantId) then begin
                // This has always only one record
                AccessTokenDetails := TenantAccessTokenDetails.Get(TenantId);
                foreach TokenValidity in AccessTokenDetails.Keys() do
#pragma warning disable LC0029 // Handled when the record is created
                    if TokenValidity > CurrentDateTime() then begin
#pragma warning restore LC0029
                        AccessToken := AccessTokenDetails.Get(TokenValidity);
                        exit;
                    end;
            end;
        end;

        Scopes := Format(ScopeRequestBodyTok);

        TokenRequestBody := SecretStrSubstNo(TokenRequestBodyTok, Scopes);
        TokenRequestAuthentication := GetOAuth2TokenRequestAuthentication(ClientId, ClientSecret);
        TokenRequestBody := SecretStrSubstNo(MergeTokensTok, TokenRequestBody, TokenRequestAuthentication);

        PostTokenRequest(OAuthAuthorityUrl, TokenRequestBody, HttpResponseMessage);
        ParseAccessTokenResponse(ClientId, TenantId, HttpResponseMessage, AccessToken);
    end;

    [NonDebuggable]
    local procedure PostTokenRequest(OAuthAuthorityUrl: Text; ContentUri: SecretText; var HttpResponseMessage: HttpResponseMessage)
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpContent: HttpContent;
        XwwwFormUrlencodedContentTypeTok: Label 'application/x-www-form-urlencoded', Locked = true;
    begin
        HttpClient.Clear();
        InitContent(HttpContent, ContentUri, XwwwFormUrlencodedContentTypeTok);

        HttpRequestMessage.Method('POST');
        HttpRequestMessage.SetRequestUri(OAuthAuthorityUrl);
        HttpRequestMessage.Content(HttpContent);

        Send(HttpClient, HttpRequestMessage, HttpResponseMessage);
    end;

    [NonDebuggable]
    local procedure Send(HttpClient: HttpClient; HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    var
        FailedToSendOAuth2TokenRequestErr: Label 'Failed to send OAuth2 token request.';
    begin
        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            Error(FailedToSendOAuth2TokenRequestErr);
    end;

    [NonDebuggable]
    local procedure GetOAuth2TokenRequestAuthentication(ClientId: Text; ClientSecret: SecretText): SecretText
    var
        TokenRequestBodyStructureTok: Label '&client_id=%1&client_secret=%2', Locked = true;
    begin
        exit(SecretStrSubstNo(TokenRequestBodyStructureTok, Format(ClientId, 0, 4), ClientSecret));
    end;

    [NonDebuggable]
    local procedure InitContent(var HttpContent: HttpContent; ContentSecretText: SecretText; ContentType: Text)
    var
        Headers: HttpHeaders;
    begin
        HttpContent.Clear();
        HttpContent.WriteFrom(ContentSecretText);

        HttpContent.GetHeaders(Headers);
        AddContentTypeHeader(Headers, ContentType);
    end;

    [NonDebuggable]
    local procedure AddContentTypeHeader(var Headers: HttpHeaders; ContentType: Text)
    begin
        if ContentType <> '' then
            ReplaceHeader(Headers, 'Content-Type', ContentType);
    end;

    [NonDebuggable]
    local procedure ReplaceHeader(var Headers: HttpHeaders; HeaderKey: Text; HeaderValue: Text)
    begin
        if Headers.ContainsSecret(HeaderKey) or Headers.Contains(HeaderKey) then
            Headers.Remove(HeaderKey);
        Headers.Add(HeaderKey, HeaderValue);
    end;

    [NonDebuggable]
    local procedure ParseAccessTokenResponse(ClientId: Guid; TenantId: Guid; HttpResponseMessage: HttpResponseMessage; var AccessToken: SecretText)
    var
        AccessTokenDetails: Dictionary of [DateTime, SecretText];
        TenantAccessTokenDetails: Dictionary of [Text, Dictionary of [DateTime, SecretText]];
        ResponseJson: JsonObject;
        AccessTokenExpiration: DateTime;
    begin
        InitResponseJsonFromHttpResponseMessage(ResponseJson, HttpResponseMessage);

        TestResponseToken(ResponseJson, 'access_token');
        AccessToken := GetJsonTokenAsSecretText(ResponseJson, 'access_token');
        AccessTokenExpiration := CurrentDateTime() + GetJsonTokenAsInteger(ResponseJson, 'expires_in') * 1000 - 2000;

        if AccessTokenBuffer.ContainsKey(ClientId) then begin
            TenantAccessTokenDetails := AccessTokenBuffer.Get(ClientId);
            AccessTokenBuffer.Remove(ClientId);
        end;
        if TenantAccessTokenDetails.ContainsKey(TenantId) then
            TenantAccessTokenDetails.Remove(TenantId);

        AccessTokenDetails.Add(AccessTokenExpiration, AccessToken);
        TenantAccessTokenDetails.Add(TenantId, AccessTokenDetails);
        AccessTokenBuffer.Add(ClientId, TenantAccessTokenDetails);
    end;

    [NonDebuggable]
    local procedure InitResponseJsonFromHttpResponseMessage(var Response: JsonObject; HttpResponseMessage: HttpResponseMessage)
    var
        JsonInStream: InStream;
        UnknownResponseErr: Label 'Unknown access token request response.';
    begin
        HttpResponseMessage.Content().ReadAs(JsonInStream);
        if not Response.ReadFrom(JsonInStream) then
            Error(UnknownResponseErr);
    end;

    [NonDebuggable]
    local procedure TestResponseToken(Response: JsonObject; TokenName: Text)
    var
        ResponseDoesNotHaveRefreshTokenErr: Label 'Response does not have %1.', Comment = '%1 - token name';
        ErrorResponseErr: Label 'Error while requesting %3: %1\\%2', Comment = '%1 - Error text, %2 - Error Details, %3 - token name';
    begin
        if Response.Contains('error') then
            Error(ErrorResponseErr, GetJsonTokenAsText(Response, 'error'), GetJsonTokenAsText(Response, 'error_description'), TokenName);
        if not Response.Contains(TokenName) then
            Error(ResponseDoesNotHaveRefreshTokenErr, TokenName);
    end;

    [NonDebuggable]
    local procedure GetJsonTokenAsText(ParsedObject: JsonObject; KeyName: Text): Text
    var
        JsonValue: JsonValue;
    begin
        if not GetJsonTokenAsJsonValue(ParsedObject, KeyName, JsonValue) then
            exit('');
        exit(JsonValue.AsText());
    end;

    [NonDebuggable]
    local procedure GetJsonTokenAsSecretText(ParsedObject: JsonObject; KeyName: Text): SecretText
    var
        JsonValue: JsonValue;
    begin
        if not GetJsonTokenAsJsonValue(ParsedObject, KeyName, JsonValue) then
            exit;
        exit(JsonValue.AsText());
    end;

    [NonDebuggable]
    procedure GetJsonTokenAsInteger(ParsedObject: JsonObject; KeyName: Text): Integer
    var
        Result: Integer;
    begin
        if not Evaluate(Result, GetJsonTokenAsText(ParsedObject, KeyName)) then
            exit(0);
        exit(Result);
    end;

    [NonDebuggable]
    local procedure GetJsonTokenAsJsonValue(ParsedObject: JsonObject; KeyName: Text; var ResultJsonValue: JsonValue): Boolean
    var
        JsonToken: JsonToken;
    begin
        Clear(ResultJsonValue);
        if not GetJsonToken(ParsedObject, KeyName, JsonToken) then
            exit(false);
        if not JsonToken.IsValue() then
            exit(false);
        if (JsonToken.AsValue().IsNull()) or (JsonToken.AsValue().IsUndefined()) then
            exit(false);
        ResultJsonValue := JsonToken.AsValue();
        exit(true);
    end;

    [NonDebuggable]
    local procedure GetJsonToken(ParsedObject: JsonObject; KeyName: Text; var ResultJsonToken: JsonToken): Boolean
    begin
        Clear(ResultJsonToken);
        if KeyName.StartsWith('$') then begin
            if not ParsedObject.SelectToken(KeyName, ResultJsonToken) then
                exit(false);
        end else
            if not ParsedObject.Get(KeyName, ResultJsonToken) then
                exit(false);
        exit(true);
    end;
}