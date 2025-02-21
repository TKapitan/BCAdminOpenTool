page 73270 TKABCAdminApps
{
    Caption = 'BC Admin Apps';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = TKABCAdminApp;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(ClientId; Rec.ClientId)
                {
                    ShowMandatory = true;
                }
                field(Name; Rec.Name) { }
                field(ClientSecretField; ClientSecret)
                {
                    Caption = 'Client Secret';
                    ShowMandatory = true;
                    Style = Subordinate;
                    StyleExpr = not SecretChanged;
                    ToolTip = 'Specifies the client secret for the app.';

                    trigger OnValidate()
                    begin
                        ValidateClientSecret();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        UnchangedLbl: Label '(Unchanged)';
    begin
        ClientSecret := '';
        if not IsNullGuid(Rec.ClientSecretID) then
            ClientSecret := UnchangedLbl;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClientSecret := '';
    end;

    var
        [NonDebuggable]
        ClientSecret: Text;
        SecretChanged: Boolean;

    local procedure ValidateClientSecret()
    var
        ClientSecretAsSecretText: SecretText;
    begin
        ClientSecretAsSecretText := ClientSecret;
        Rec.SetClientSecret(ClientSecretAsSecretText);
        SecretChanged := true;
    end;
}