table 73275 TKAManagedBCTenantGroup
{
    Caption = 'Managed BC Tenant Group';
    DataClassification = CustomerContent;
    DrillDownPageId = TKAManagedBCTenantGroups;
    LookupPageId = TKAManagedBCTenantGroups;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            ToolTip = 'Specifies the code of the tenant group.';
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the tenant group.';
        }
        field(100; Status; Enum TKAManagedBCTenantGroupStatus)
        {
            Caption = 'Status';
            InitValue = Active;
            ToolTip = 'Specifies the status of the tenant group.';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description) { }
        fieldgroup(Brick; "Code", Description) { }
    }

    trigger OnDelete()
    begin
        TestNotUsed();
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCTenant, 'R')]
    local procedure TestNotUsed()
    var
        ManagedBCTenant: Record TKAManagedBCTenant;
        TheGroupIsUsedErr: Label 'The group is used by at least one tenant and cannot be deleted.';
    begin
        ManagedBCTenant.ReadIsolation(IsolationLevel::ReadCommitted);
        ManagedBCTenant.SetRange(GroupCode, Rec.Code);
        if not ManagedBCTenant.IsEmpty() then
            Error(TheGroupIsUsedErr);
    end;
}