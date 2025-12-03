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

                field(ClientSecretField; ClientSecretTextValue)
                {
                    Caption = 'Client Secret';
                    ToolTip = 'Specifies the client secret from the Entra app registration.';
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        // Convert to SecretText immediately upon input to minimize exposure
                        ClientSecretText := ClientSecretTextValue;
                        // Clear the plain text variable immediately
                        Clear(ClientSecretTextValue);
                    end;
                }
            }
        }
    }

    var
        ClientSecretTextValue: Text;
        ClientSecretText: SecretText;
        SecretConfirmed: Boolean;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ClientSecretEmptyLbl: Label 'Client secret cannot be empty.';
    begin
        if CloseAction = Action::OK then begin
            // Ensure any remaining input is converted
            if ClientSecretTextValue <> '' then begin
                ClientSecretText := ClientSecretTextValue;
                Clear(ClientSecretTextValue);
            end;

            if ClientSecretText.IsEmpty() then
                Error(ClientSecretEmptyLbl);
            SecretConfirmed := true;
        end else begin
            // Clear both variables if cancelled
            Clear(ClientSecretTextValue);
            Clear(ClientSecretText);
        end;
    end;

    procedure GetClientSecret(var Secret: SecretText): Boolean
    begin
        if SecretConfirmed then
            Secret := ClientSecretText;
        exit(SecretConfirmed);
    end;
}
