pageextension 73270 TKAUserSetup extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
            field(TKAVisibleBCTenantGroupCode; Rec.TKAVisibleBCTenantGroupCode)
            {
                ApplicationArea = All;
            }
        }
    }
}