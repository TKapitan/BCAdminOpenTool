table 73270 TKAManagedBCTenant
{
    Caption = 'Managed BC Tenant';
    DataClassification = CustomerContent;
    DrillDownPageId = TKAManagedBCTenants;
    LookupPageId = TKAManagedBCTenants;

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
            TableRelation = TKAManagedBCAdministrationApp.ClientId;
            ToolTip = 'Specifies the client ID for the tenant.';
        }
        field(1000; EnvironmentsModifiedAt; DateTime)
        {
            Caption = 'Environments Modified At';
            Editable = false;
            ToolTip = 'Specifies the date and time when the environments were last modified for the tenant.';
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

    trigger OnDelete()
    begin
        DeleteRelatedRecords();
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'D')]
    local procedure DeleteRelatedRecords()
    var
        ManagedBCEnvironment: Record TKAManagedBCEnvironment;
    begin
        ManagedBCEnvironment.SetRange(TenantId, Rec.TenantId);
        ManagedBCEnvironment.DeleteAll(true);
    end;
}