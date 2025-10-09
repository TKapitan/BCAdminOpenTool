codeunit 73302 TKAUpgradeBCAdminOpenTool
{
    Subtype = Upgrade;
    Access = Internal;

    trigger OnUpgradePerCompany()
    begin
        RunOnUpgradePerCompany();
    end;

    trigger OnUpgradePerDatabase()
    begin
        RunOnUpgradePerDatabase();
    end;

    internal procedure RunOnUpgradePerCompany()
    begin
        SetTenantGroupStatus20251006();
    end;

    internal procedure RunOnUpgradePerDatabase()
    begin
    end;

    local procedure SetTenantGroupStatus20251006()
    var
        ManagedBCTenantGroup: Record TKAManagedBCTenantGroup;
        DataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(SetTenantGroupStatus20251006Tok) then
            exit;
        DataTransfer.SetTables(Database::TKAManagedBCTenantGroup, Database::TKAManagedBCTenantGroup);
        DataTransfer.AddConstantValue(ManagedBCTenantGroup.Status::Active, ManagedBCTenantGroup.FieldNo(Status));
        DataTransfer.CopyFields();
        UpgradeTag.SetUpgradeTag(SetTenantGroupStatus20251006Tok);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", OnGetPerCompanyUpgradeTags, '', false, false)]
    local procedure OnGetPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(SetTenantGroupStatus20251006Tok);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", OnGetPerDatabaseUpgradeTags, '', false, false)]
    local procedure OnGetPerDatabaseUpgradeTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
    end;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        SetTenantGroupStatus20251006Tok: Label 'TKA-BCAdminOpenTool-SetTenantGroupStatus-20251006', Locked = true;
}