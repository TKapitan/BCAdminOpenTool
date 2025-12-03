codeunit 73286 TKAOAuthClientApplicationImpl
{
    Access = Internal;

    #region ClientId
    var
        ClientId: Text;

    procedure SetClientId(Value: Text)
    begin
        ClientId := Value;
    end;

    procedure GetClientId() Value: Text
    begin
        Value := ClientId;
    end;
    #endregion

    #region Certificate
    var
        Certificate: Codeunit TKAOAuthCertificate;

    procedure SetCertificate(Value: Codeunit TKAOAuthCertificate)
    begin
        Certificate := Value;
    end;

    procedure GetCertificate() Value: Codeunit TKAOAuthCertificate
    begin
        Value := Certificate;
    end;

    #endregion

    #region ClientSecret
    var
        ClientSecret: SecretText;

    procedure SetClientSecret(Value: SecretText)
    begin
        ClientSecret := Value;
    end;

    procedure GetClientSecret() Value: SecretText
    begin
        Value := ClientSecret;
    end;

    procedure HasClientSecret(): Boolean
    begin
        exit(not ClientSecret.IsEmpty());
    end;
    #endregion

    #region Scopes
    var
        Scopes: List of [Text];

    procedure AddScope(Scope: Text)
    begin
        Scopes.Add(Scope);
    end;

    procedure GetUrlEncodedScopes() UrlEncodedScopes: Text
    var
        TextBuilder: TextBuilder;
        Scope: Text;
    begin
        foreach Scope in Scopes do begin
            TextBuilder.Append(Scope);
            TextBuilder.Append(' ')
        end;
        UrlEncodedScopes := TextBuilder.ToText().Trim();
    end;
    #endregion
}