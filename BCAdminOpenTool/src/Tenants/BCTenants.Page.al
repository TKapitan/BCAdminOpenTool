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

    actions
    {
        area(Processing)
        {
            action(TestConnection)
            {
                ApplicationArea = All;
                Caption = 'Test Connection';
                Image = TestDatabase;
                ToolTip = 'Allows to test the connection to the tenant using the specified client ID.';

                trigger OnAction()
                var
                    ConnectToTenant: Codeunit TKACallAdminAPI;
                begin
                    ConnectToTenant.TestAdminCenterConnection(Rec);
                end;
            }
        }
    }
}