table 73278 TKAInstallAppsBuffer
{
    Caption = 'Install App Buffer';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; AppId; Guid)
        {
            Caption = 'AppId';
            NotBlank = true;
            TableRelation = TKAAppSourceOffering.AppId;
            ToolTip = 'Specifies the unique identifier of the app.';
        }
        field(25; Name; Text[250])
        {
            Caption = 'Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(TKAAppSourceOffering.Name where(AppId = field(AppId)));
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