page 73271 TKABCTenants
{
    Caption = 'BC Tenants';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = TKABCTenant;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(TenantId; Rec.TenantId)
                {
                    ShowMandatory = true;
                }
                field(Name; Rec.Name) { }
                field(ClientId; Rec.ClientId)
                {
                    ShowMandatory = true;
                }
            }
        }
    }
}