report 73273 TKAUpdateEnvironmentsDetails
{
    Caption = 'Update Environments Details';
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(TKAManagedBCAdministrationApp; TKAManagedBCAdministrationApp)
        {
            trigger OnAfterGetRecord()
            var
                GetTenants: Codeunit TKAGetTenants;
            begin
                GetTenants.CreateUpdateManageableTenants(TKAManagedBCAdministrationApp);
            end;
        }
    }
}