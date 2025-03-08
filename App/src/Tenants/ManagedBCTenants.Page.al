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
                field(GroupCode; Rec.GroupCode) { }
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
            action(CreateUpdateTenantsEnvironments)
            {
                ApplicationArea = All;
                Caption = 'Create/Update Tenants & Environments';
                ToolTip = 'Create or update the tenants and environments for all client IDs that has at least one valid tenant configured in this table.';
                Image = Refresh;

                trigger OnAction()
                var
                    GetTenants: Codeunit TKAGetTenants;
                begin
                    GetTenants.CreateUpdateManageableTenants();
                    CurrPage.Update();
                end;
            }
            action(UpdateEnvironments)
            {
                ApplicationArea = All;
                Caption = 'Create/Update Environments';
                Image = UpdateDescription;
                ToolTip = 'Create or update the environments for the tenant.';

                trigger OnAction()
                var
                    GetEnvironments: Codeunit TKAGetEnvironments;
                begin
                    GetEnvironments.CreateUpdateEnvironmentsForTenant(Rec, false);
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
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(CreateUpdateTenantsEnvironments_Promoted; CreateUpdateTenantsEnvironments) { }
                actionref(UpdateEnvironments_Promoted; UpdateEnvironments) { }
                actionref(TestConnection_Promoted; TestConnection) { }
            }
            group(Category_Category4)
            {
                Caption = 'Navigation';
                actionref(Environments_Promoted; Environments) { }
            }
        }
    }
}