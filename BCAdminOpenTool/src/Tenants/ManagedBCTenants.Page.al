page 73271 TKAManagedBCTenants
{
    Caption = 'Managed BC Tenants';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = TKAManagedBCTenant;

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
                field(EnvironmentsModifiedAt; Rec.EnvironmentsModifiedAt) { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateEnvironments)
            {
                ApplicationArea = All;
                Caption = 'Update Environments';
                Image = UpdateDescription;
                ToolTip = 'Allows to update the environments for the tenant using the specified client ID.';

                trigger OnAction()
                var
                    GetEnvironments: Codeunit TKAGetEnvironments;
                begin
                    GetEnvironments.CreateUpdateEnvironmentsForTenant(Rec);
                end;
            }
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
        area(Navigation)
        {
            action(Environments)
            {
                ApplicationArea = All;
                Caption = 'Environments';
                Image = ShowList;
                ToolTip = 'Navigates to the environments for the tenant.';
                RunObject = page TKAManagedBCEnvironments;
                RunPageLink = TenantId = field(TenantId);
            }
        }
    }
}