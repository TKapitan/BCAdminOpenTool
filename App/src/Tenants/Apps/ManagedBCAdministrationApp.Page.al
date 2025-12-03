page 73280 TKAManagedBCAdministrationApp
{
    Caption = 'Managed BC Administration App';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = TKAManagedBCAdministrationApp;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(ClientId; Rec.ClientId)
                {
                    ShowMandatory = true;
                }
                field(Name; Rec.Name) { }
                field("Authentication Type"; Rec."Authentication Type")
                {
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(CreateCertificateActionRef; CreateCertificateAction) { }
            actionref(DownloadCertificateActionRef; DownloadCertificateAction) { }
            actionref(SetClientSecretActionRef; SetClientSecretAction) { }
        }
        area(Processing)
        {
            action(CreateCertificateAction)
            {
                Caption = 'Create Certificate';
                Image = NewResource;
                ToolTip = 'Allows you to create a new self-signed certificate for the app.';
                Visible = Rec."Authentication Type" = Rec."Authentication Type"::Certificate;
                Enabled = Rec."Authentication Type" = Rec."Authentication Type"::Certificate;

                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    Rec.CreateCertificate();
                end;
            }
            action(DownloadCertificateAction)
            {
                Caption = 'Download Certificate';
                Image = Download;
                ToolTip = 'Allows you to download the certificate in PFX format.';
                Visible = Rec."Authentication Type" = Rec."Authentication Type"::Certificate;
                Enabled = Rec."Authentication Type" = Rec."Authentication Type"::Certificate;

                trigger OnAction()
                begin
                    Rec.DownloadCertificate();
                end;
            }
            action(SetClientSecretAction)
            {
                Caption = 'Set Client Secret';
                Image = EncryptionKeys;
                ToolTip = 'Allows you to enter and save the client secret for authentication.';
                Visible = Rec."Authentication Type" = Rec."Authentication Type"::"Client Secret";
                Enabled = Rec."Authentication Type" = Rec."Authentication Type"::"Client Secret";

                trigger OnAction()
                var
                    ClientSecretDialog: Page TKAClientSecretDialog;
                    ClientSecretText: SecretText;
                begin
                    CurrPage.SaveRecord();
                    ClientSecretDialog.RunModal();
                    if ClientSecretDialog.GetClientSecret(ClientSecretText) then begin
                        Rec.SetClientSecret(ClientSecretText);
                    end;
                end;
            }
        }
    }
}