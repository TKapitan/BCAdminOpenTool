tableextension 73270 TKAUserSetup extends "User Setup"
{
    fields
    {
        field(73270; TKAVisibleBCTenantGroupCode; Code[20])
        {
            Caption = 'Visible BC Tenant Group Code';
            DataClassification = CustomerContent;
            TableRelation = TKAManagedBCTenantGroup."Code";
            ToolTip = 'Specifies the group code for the tenant that will be visible by default in Managed BC Environments.';
        }

    }
}