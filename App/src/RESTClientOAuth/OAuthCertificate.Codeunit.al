codeunit 73287 TKAOAuthCertificate
{
    var
        OAuthCertificateImpl: Codeunit TKAOAuthCertificateImpl;

    /// <summary>
    /// Sets the Certificate.
    /// </summary>
    /// <param name="Value">The Certificate in PEM format.</param>
    procedure SetCertificate(Value: Text)
    begin
        OAuthCertificateImpl.SetCertificate(Value);
    end;

    /// <summary>
    /// Sets the Private Key.
    /// </summary>
    /// <param name="Value">The Private Key in PEM format.</param>
    procedure SetPrivateKey(Value: SecretText)
    begin
        OAuthCertificateImpl.SetPrivateKey(Value);
    end;

    /// <summary>
    /// Gets the Private Key.
    /// </summary>
    /// <returns>The Private Key in PEM format.</returns>
    procedure GetPrivateKey() ReturnValue: SecretText
    begin
        ReturnValue := OAuthCertificateImpl.GetPrivateKey();
    end;

    /// <summary>
    /// Checks if the Certificate has been set.
    /// </summary>
    /// <returns>True if the Certificate has a value; otherwise, false.</returns>
    procedure HasValue(): Boolean
    begin
        exit(OAuthCertificateImpl.HasValue());
    end;

    /// <summary>
    /// Gets the Base64-encoded thumbprint of the Certificate.
    /// </summary>
    /// <returns>The Base64-encoded thumbprint.</returns>
    procedure ThumbprintBase64() ReturnValue: Text
    begin
        ReturnValue := OAuthCertificateImpl.ThumbprintBase64();
    end;
}