table 73277 TKAAppSourceOffering
{
    Caption = 'App Source Offering';
    DataClassification = CustomerContent;
    DrillDownPageId = TKAAppSourceOfferings;
    LookupPageId = TKAAppSourceOfferings;

    fields
    {
        field(1; AppId; Guid)
        {
            Caption = 'AppId';
            NotBlank = true;
            ToolTip = 'Specifies the unique identifier of the app.';
        }
        field(25; Name; Text[250])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the app.';
        }
    }

    keys
    {
        key(PK; "AppId")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Name, AppId) { }
        fieldgroup(Brick; Name, AppId) { }
    }
}