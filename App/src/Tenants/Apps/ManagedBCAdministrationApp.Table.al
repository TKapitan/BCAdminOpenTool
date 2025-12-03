table 73271 TKAManagedBCAdministrationApp
{
    Caption = 'Managed BC Administratior App';
    DataClassification = CustomerContent;
    DrillDownPageId = TKAManagedBCAdministrationApps;
    LookupPageId = TKAManagedBCAdministrationApps;

    fields
    {
        field(1; ClientId; Guid)
        {
            Caption = 'Client ID';
            ToolTip = 'Specifies the client ID for the app.';
        }
        field(5; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the app.';
        }
        field(10; "Authentication Type"; Enum TKAAuthenticationType)
        {
            Caption = 'Authentication Type';
            ToolTip = 'Specifies whether to use Certificate or Client Secret for authentication.';

            trigger OnValidate()
            begin
                // Clear authentication data when switching types
                if "Authentication Type" <> xRec."Authentication Type" then begin
                    ClearIsolatedField(Certificate);
                    ClearIsolatedField(CertificatePassword);
                    ClearIsolatedField(ClientSecret);
                end;
            end;
        }
        field(15; Certificate; Guid)
        {
            Caption = 'Certificate';
            AllowInCustomizations = Never;
        }
        field(16; CertificatePassword; Guid)
        {
            Caption = 'Certificate';
            AllowInCustomizations = Never;
        }
        field(17; ClientSecret; Guid)
        {
            Caption = 'Client Secret';
            AllowInCustomizations = Never;
        }
    }

    keys
    {
        key(PK; ClientId)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Name, ClientId) { }
        fieldgroup(Brick; Name, ClientId) { }
    }

    #region Triggers

    trigger OnDelete()
    begin
        TestNotUsed();
        ClearIsolatedField(Rec.Certificate);
        ClearIsolatedField(Rec.CertificatePassword);
        ClearIsolatedField(Rec.ClientSecret);
    end;

    #endregion Triggers
    #region "Global Procedures"

    /// <summary>
    /// Sets the certificate password in isolated storage and saves a reference to it in the table.
    /// </summary>
    /// <param name="Password">The certificate password as SecretText. If an empty SecretText is passed, the existing password (if any) is removed.</param>
    procedure SetCertificatePassword(Password: SecretText)
    var
        SavingCertErr: Label 'Could not save the certificate password.';
    begin
        ClearIsolatedField(Rec.CertificatePassword);

        if Password.IsEmpty() then
            exit;

        Rec.CertificatePassword := CreateGuid();
        Rec.Modify(true);

        if not IsolatedStorage.Set(Rec.CertificatePassword, Password, DataScope::Company) then
            Error(SavingCertErr);
    end;

    /// <summary>
    /// Sets the client secret in isolated storage and saves a reference to it in the table.
    /// </summary>
    /// <param name="Secret">The client secret as SecretText. If an empty SecretText is passed, the existing secret (if any) is removed.</param>
    procedure SetClientSecret(Secret: SecretText)
    var
        SavingSecretErr: Label 'Could not save the client secret.';
    begin
        ClearIsolatedField(Rec.ClientSecret);

        if Secret.IsEmpty() then
            exit;

        Rec.ClientSecret := CreateGuid();
        Rec.Modify(true);

        if not IsolatedStorage.Set(Rec.ClientSecret, Secret, DataScope::Company) then
            Error(SavingSecretErr);
    end;

    /// <summary>
    /// Creates a new self-signed certificate for the app and saves it in isolated storage.
    /// </summary>
    procedure CreateCertificate()
    var
        EntraCertificateMgt: Codeunit TKAEntraCertificateMgt;
        CertificateCreatedMsg: Label 'A new self-signed certificate has been created for the app.';
    begin
        EntraCertificateMgt.CreateSelfSignedCertificate(Rec);
        Rec.Modify(false);

        Message(CertificateCreatedMsg);
    end;

    /// <summary>
    /// Sets the certificate in isolated storage and saves a reference to it in the table.
    /// </summary>
    /// <param name="Value">The certificate as Text in Base64 format.</param>
    procedure SetCertificate(Value: Text)
    var
        SavingCertErr: Label 'Could not save the certificate.';
    begin
        ClearIsolatedField(Rec.Certificate);
        if Value = '' then
            exit;

        Rec.Certificate := CreateGuid();
        Rec.Modify(true);

#pragma warning disable LC0043 // Not a secret
        if not IsolatedStorage.Set(Rec.Certificate, Value, DataScope::Company) then
#pragma warning restore LC0043
            Error(SavingCertErr);
    end;

    /// <summary>
    /// Downloads the certificate (public) in CER format.
    /// </summary>
    procedure DownloadCertificate()
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        Filename, CertificateAsText : Text;
        CertFileFilterTxt: Label 'Certificate File(*.cer)|*.cer';
        ExportCertificateFileDialogTxt: Label 'Choose the location where you want to save the certificate file.';
        CertificateCannotBeDownloadedErr: Label 'The certificate cannot be downloaded.\\Additional details: %1', Comment = '%1 - error message';
    begin
        GetCertificate(CertificateAsText);

        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(CertificateAsText);
        TempBlob.CreateInStream(InStream);
        Filename := Name + '.cer';
        if not DownloadFromStream(InStream, ExportCertificateFileDialogTxt, '', CertFileFilterTxt, Filename) then
#pragma warning disable LC0048 // Show last error
            Error(CertificateCannotBeDownloadedErr, GetLastErrorText());
#pragma warning restore LC0048
    end;

    /// <summary>
    /// Returns an OAuth2ClientApplication codeunit initialized with the data from the record.
    /// </summary>
    /// <returns>The initialized OAuth2ClientApplication codeunit.</returns>
    procedure GetOAuth2ClientApplication() OAuth2ClientApplication: Codeunit TKAOAuthClientApplication
    var
        OAuthCertificate: Codeunit TKAOAuthCertificate;
        CertificateAsText: Text;
        CertificatePasswordAsSecretText: SecretText;
        ClientSecretAsSecretText: SecretText;
    begin
        Rec.TestField(ClientId);
        Rec.TestField("Authentication Type");

        case Rec."Authentication Type" of
            Rec."Authentication Type"::Certificate:
                begin
                    GetCertificate(CertificateAsText, CertificatePasswordAsSecretText);
                    OAuthCertificate.SetCertificate(CertificateAsText);
                    OAuthCertificate.SetPrivateKey(CertificatePasswordAsSecretText);
                    OAuth2ClientApplication.SetCertificate(OAuthCertificate);
                end;
            Rec."Authentication Type"::"Client Secret":
                begin
                    GetClientSecret(ClientSecretAsSecretText);
                    OAuth2ClientApplication.SetClientSecret(ClientSecretAsSecretText);
                end;
            else
                Error('Unsupported authentication type: %1', Rec."Authentication Type");
        end;

        OAuth2ClientApplication.SetClientId(Format(Rec.ClientId, 0, 4));
    end;

    #endregion "Global Procedures"
    #region "Local Procedures"

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCTenant, 'R')]
    local procedure TestNotUsed()
    var
        ManagedBCTenant: Record TKAManagedBCTenant;
        TheBCAdminAppIsUsedErr: Label 'The app is configured for a tenant and cannot be deleted.';
    begin
        ManagedBCTenant.ReadIsolation(IsolationLevel::ReadCommitted);
        ManagedBCTenant.SetRange(ClientId, Rec.ClientId);
        if not ManagedBCTenant.IsEmpty() then
            Error(TheBCAdminAppIsUsedErr);
    end;

    local procedure ClearIsolatedField(var IsolatedGuid: Guid)
    begin
        if not IsNullGuid(IsolatedGuid) then begin
            if IsolatedStorage.Contains(IsolatedGuid, DataScope::Company) then
                IsolatedStorage.Delete(IsolatedGuid, DataScope::Company);
            Clear(IsolatedGuid);
        end;
    end;

    local procedure GetCertificate(var OutCertificate: Text)
    var
        OutCertificatePassword: SecretText;
    begin
        GetCertificate(OutCertificate, OutCertificatePassword);
    end;

    local procedure GetCertificate(var OutCertificate: Text; var OutCertificatePassword: SecretText)
    var
        Base64StringAsText: Text;
        Password: SecretText;
        ReadingCertErr: Label 'Could not get the certificate.';
        ReadingCertPwdErr: Label 'Could not get the certificate password.';
    begin
        if IsNullGuid(Rec.Certificate) then
            exit;
#pragma warning disable LC0043 // Not a secret
        if not IsolatedStorage.Get(Rec.Certificate, DataScope::Company, Base64StringAsText) then
#pragma warning restore LC0043
            Error(ReadingCertErr);

        if IsNullGuid(Rec."CertificatePassword") then begin
            OutCertificate := Base64StringAsText;
            Clear(OutCertificatePassword);
            exit;
        end;

        if not IsolatedStorage.Get(Rec."CertificatePassword", DataScope::Company, Password) then
            Error(ReadingCertPwdErr);
        OutCertificate := Base64StringAsText;
        OutCertificatePassword := Password;
    end;

    local procedure GetClientSecret(var OutClientSecret: SecretText)
    var
        ReadingSecretErr: Label 'Could not get the client secret.';
    begin
        if IsNullGuid(Rec.ClientSecret) then
            exit;

        if not IsolatedStorage.Get(Rec.ClientSecret, DataScope::Company, OutClientSecret) then
            Error(ReadingSecretErr);
    end;

    #endregion "Local Procedures"
}