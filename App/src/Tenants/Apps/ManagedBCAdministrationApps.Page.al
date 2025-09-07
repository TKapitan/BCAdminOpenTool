page 73270 TKAManagedBCAdministrationApps
{
    Caption = 'Managed BC Administration Apps';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    Editable = false;
    CardPageId = TKAManagedBCAdministrationApp;
    SourceTable = TKAManagedBCAdministrationApp;

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
            }
        }
    }
}