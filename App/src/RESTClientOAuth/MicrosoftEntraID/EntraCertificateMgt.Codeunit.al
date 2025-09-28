codeunit 73300 TKAEntraCertificateMgt
{
    Access = Internal;

    var
        TimeHelper: Codeunit TKATimeHelper;
        SubjectNameTxt: Label 'CN=%1', Locked = true;

    procedure CreateSelfSignedCertificate(var ManagedBCAdministrationApp: Record TKAManagedBCAdministrationApp)
    var
        CertificateRequest: Codeunit CertificateRequest;
        ExpiryDateTime: DateTime;
        PrivateKey, CertBase64 : Text;
    begin
        ManagedBCAdministrationApp.TestField(Name);
        ExpiryDateTime := CreateDateTime(Today() + 365, 000000T);

        CertificateRequest.InitializeRSA(2048, true, PrivateKey);
        CertificateRequest.InitializeCertificateRequestUsingRSA(StrSubstNo(SubjectNameTxt, ManagedBCAdministrationApp.Name), Enum::"Hash Algorithm"::SHA256, Enum::"RSA Signature Padding"::Pkcs1);
        CertificateRequest.AddX509KeyUsageToCertificateRequest(128, true); // 128 = Digital Signature | Docs: https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.x509certificates.x509keyusageflags
        CertificateRequest.CreateSelfSigned(TimeHelper.GetDateTimeInUtc(CreateDateTime(Today(), 000000T)), TimeHelper.GetDateTimeInUtc(ExpiryDateTime), Enum::"X509 Content Type"::Cert, CertBase64);
        ManagedBCAdministrationApp.SetCertificate(CertBase64);
        ManagedBCAdministrationApp.SetCertificatePassword(PrivateKey);
    end;
}