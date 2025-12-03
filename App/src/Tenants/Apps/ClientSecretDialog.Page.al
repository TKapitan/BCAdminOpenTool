page 73290 TKAClientSecretDialog
{
    Caption = 'Enter Client Secret';
    PageType = StandardDialog;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Instructions)
            {
                Caption = 'Instructions';
                InstructionalText = 'Enter the Client Secret from your Entra app registration. This value will be securely stored in isolated storage.';
            }
            group(Input)
            {
                Caption = 'Client Secret';

                field(ClientSecretField; ClientSecretText)
                {
                    Caption = 'Client Secret';
                    ToolTip = 'Specifies the client secret from the Entra app registration.';
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;
                }
            }
        }
    }

    var
        ClientSecretText: Text;
        SecretConfirmed: Boolean;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then begin
            if ClientSecretText = '' then
                Error('Client secret cannot be empty.');
            SecretConfirmed := true;
        end;
    end;

    procedure GetClientSecret(var Secret: SecretText): Boolean
    begin
        if SecretConfirmed then
            Secret := ClientSecretText;
        exit(SecretConfirmed);
    end;
}
