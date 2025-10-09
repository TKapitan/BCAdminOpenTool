page 73276 TKAManagedBCTenantGroups
{
    ApplicationArea = All;
    Caption = 'Managed BC Tenant Groups';
    PageType = List;
    SourceTable = TKAManagedBCTenantGroup;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code") { }
                field(Description; Rec.Description) { }
                field(Status; Rec.Status) { }
            }
        }
    }
}
