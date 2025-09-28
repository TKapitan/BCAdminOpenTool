codeunit 73298 TKAOAuthAuthenticationResult
{
    var
        OAuthAuthenticationRsltImpl: Codeunit TKAOAuthAuthenticationRsltImpl;

    /// <summary>
    /// Sets the authentication response from the OAuth server.
    /// </summary>
    /// <param name="NewAuthenticationResponse">The JSON object containing the authentication response.</param>
    [NonDebuggable]
    procedure SetResponse(NewAuthenticationResponse: JsonObject)
    begin
        OAuthAuthenticationRsltImpl.SetResponse(NewAuthenticationResponse);
    end;

    /// <summary>
    /// Gets the value for the Authorization header.
    /// </summary>
    /// <returns>The Authorization header value.</returns>
    procedure GetAuthorizationHeader() ReturnValue: SecretText
    begin
        ReturnValue := OAuthAuthenticationRsltImpl.GetAuthorizationHeader();
    end;

    /// <summary>
    /// Checks if the current authentication result is valid (i.e., the access token is present and not expired).
    /// </summary>
    /// <returns>True if the authentication result is valid; otherwise, false.</returns>
    procedure IsValid() ReturnValue: Boolean
    begin
        ReturnValue := OAuthAuthenticationRsltImpl.IsValid();
    end;
}