report 73273 TKAUpdateEnvironmentsDetails
{
    Caption = 'Update Environments Details';
    UsageCategory = Tasks;
    ApplicationArea = All;

    trigger OnPostReport()
    var
        GetTenants: Codeunit TKAGetTenants;
    begin
        GetTenants.CreateUpdateManageableTenants();
    end;
}