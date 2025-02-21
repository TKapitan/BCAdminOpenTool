table 73270 TKABCTenant
{
    Caption = 'BC Tenant';
    DataClassification = CustomerContent;
    DrillDownPageId = TKABCTenants;
    LookupPageId = TKABCTenants;

    fields
    {
        field(1; TenantId; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = OrganizationIdentifiableInformation;
            ToolTip = 'Specifies the tenant ID for the tenant.';
        }
        field(5; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the tenant.';
        }
        field(10; ClientId; Guid)
        {
            Caption = 'Client ID';
            TableRelation = TKABCAdminApp.ClientId;
            ToolTip = 'Specifies the client ID for the tenant.';
        }
    }

    keys
    {
        key(PK; TenantId)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Name, TenantId) { }
        fieldgroup(Brick; Name, TenantId) { }
    }
}