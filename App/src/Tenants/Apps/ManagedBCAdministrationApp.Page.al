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
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(CreateCertificateActionRef; CreateCertificateAction) { }
            actionref(DownloadCertificateActionRef; DownloadCertificateAction) { }
        }
        area(Processing)
        {
            action(CreateCertificateAction)
            {
                Caption = 'Create Certificate';
                Image = NewResource;
                ToolTip = 'Allows you to create a new self-signed certificate for the app.';

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

                trigger OnAction()
                begin
                    Rec.DownloadCertificate();
                end;
            }
        }
    }
}