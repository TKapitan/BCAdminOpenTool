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
        field(7; GroupCode; Code[20])
        {
            Caption = 'Group Code';
            TableRelation = TKAManagedBCTenantGroup."Code";
            ToolTip = 'Specifies the group code for the tenant.';
        }
        field(10; ClientId; Guid)
        {
            Caption = 'Client ID';
            TableRelation = TKAManagedBCAdministrationApp.ClientId;
            ToolTip = 'Specifies the client ID for the tenant.';
        }
        field(50; CustomerNo; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
            ToolTip = 'Specifies the customer number associated with the tenant. This link can be used to identify the customer in the system and link tenant information to customer records.';
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

    /// <summary>
    /// Check if the tenant's group is active.
    /// </summary>
    /// <returns>True if the tenant's group is active or if no group is assigned; otherwise, false.</returns>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCTenantGroup, 'R')]
    procedure IsTenantGroupActive(): Boolean
    var
        ManagedBCTenantGroup: Record TKAManagedBCTenantGroup;
    begin
        if Rec.GroupCode = '' then
            exit(true);
        ManagedBCTenantGroup.Get(Rec.GroupCode);
        exit(ManagedBCTenantGroup.Status = ManagedBCTenantGroup.Status::Active);
    end;
}