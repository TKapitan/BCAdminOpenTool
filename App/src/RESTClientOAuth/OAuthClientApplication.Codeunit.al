codeunit 73285 TKAOAuthClientApplication
{
    var
        OAuthClientApplicationImpl: Codeunit TKAOAuthClientApplicationImpl;

    #region ClientId
    /// <summary>
    /// Sets the ClientId of the OAuth Client Application.
    /// </summary>
    /// <param name="Value">The ClientId to set.</param>
    procedure SetClientId(Value: Text)
    begin
        OAuthClientApplicationImpl.SetClientId(Value);
    end;

    /// <summary>
    /// Gets the ClientId of the OAuth Client Application.
    /// </summary>
    /// <returns>The ClientId.</returns>
    procedure GetClientId() Value: Text
    begin
        Value := OAuthClientApplicationImpl.GetClientId();
    end;
    #endregion

    #region Certificate
    /// <summary>
    /// Sets the Certificate used for authentication.
    /// </summary>
    /// <param name="Value">The Certificate codeunit to set.</param>
    procedure SetCertificate(Value: Codeunit TKAOAuthCertificate)
    begin
        OAuthClientApplicationImpl.SetCertificate(Value);
    end;

    /// <summary>
    /// Gets the Certificate used for authentication.
    /// </summary>
    /// <returns>The Certificate codeunit.</returns>
    procedure GetCertificate() Value: Codeunit TKAOAuthCertificate
    begin
        Value := OAuthClientApplicationImpl.GetCertificate();
    end;
    #endregion

    #region Scopes
    /// <summary>
    /// Adds a scope to the OAuth Client Application.
    /// </summary>
    /// <param name="Scope">The scope to add.</param>
    procedure AddScope(Scope: Text)
    begin
        OAuthClientApplicationImpl.AddScope(Scope);
    end;

    /// <summary>
    /// Gets the URL-encoded scopes as a single string.
    /// </summary>
    /// <returns>The URL-encoded scopes.</returns>
    procedure GetUrlEncodedScopes() UrlEncodedScopes: Text
    begin
        UrlEncodedScopes := OAuthClientApplicationImpl.GetUrlEncodedScopes();
    end;
    #endregion
}