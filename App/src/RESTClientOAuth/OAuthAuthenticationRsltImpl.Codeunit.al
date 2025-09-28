codeunit 73299 TKAOAuthAuthenticationRsltImpl
{
    Access = Internal;

    var
        TokenType: Text;
        AccessToken, RefreshToken : SecretText;
        ExpiresAt: DateTime;

    [NonDebuggable]
    procedure SetResponse(AuthenticationResponse: JsonObject)
    begin
        TokenType := GetJsonToken('token_type', AuthenticationResponse).AsValue().AsText();
        AccessToken := GetJsonToken('access_token', AuthenticationResponse).AsValue().AsText();
        RefreshToken := GetJsonToken('refresh_token', AuthenticationResponse).AsValue().AsText();
        if AuthenticationResponse.Contains('expires_in') then
            ExpiresAt := CurrentDateTime() + (GetJsonToken('expires_in', AuthenticationResponse).AsValue().AsInteger() * 1000)
        else
            ExpiresAt := 0DT;
    end;

    procedure GetAuthorizationHeader(): SecretText
    begin
        exit(SecretStrSubstNo('%1 %2', TokenType, AccessToken));
    end;

    procedure IsValid() ReturnValue: Boolean
    begin
        if AccessToken.IsEmpty() then
            exit(false);

#pragma warning disable LC0029 // Comparison is OK
        exit(ExpiresAt > CurrentDateTime());
#pragma warning restore LC0029
    end;

    [NonDebuggable]
    local procedure GetJsonToken(Path: Text; JsonObject: JsonObject) Result: JsonToken
    var
        DummyJsonValue: JsonValue;
    begin
        if not JsonObject.SelectToken(Path, Result) then begin
            DummyJsonValue.SetValue('');
            Result := DummyJsonValue.AsToken();
        end;
    end;
}