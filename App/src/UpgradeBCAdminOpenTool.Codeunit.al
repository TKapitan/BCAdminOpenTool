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
        SetAPIVersionv22420260104();
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

    local procedure SetAPIVersionv22420260104()
    var
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
        APIBaseUrlTok: Label 'https://api.businesscentral.dynamics.com/admin/', Locked = true;
    begin
        if UpgradeTag.HasUpgradeTag(SetAPIVersionv22420260104Tok) then
            exit;
        if not AdminCenterAPISetup.Get() then
            exit;
        AdminCenterAPISetup.Validate(APIUrl, APIBaseUrlTok);
        AdminCenterAPISetup.Validate(APIVersion, AdminCenterAPISetup.APIVersion::"v2.24");
        AdminCenterAPISetup.Modify(true);
        UpgradeTag.SetUpgradeTag(SetAPIVersionv22420260104Tok);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", OnGetPerCompanyUpgradeTags, '', false, false)]
    local procedure OnGetPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(SetTenantGroupStatus20251006Tok);
        PerCompanyUpgradeTags.Add(SetAPIVersionv22420260104Tok);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", OnGetPerDatabaseUpgradeTags, '', false, false)]
    local procedure OnGetPerDatabaseUpgradeTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
    end;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        SetTenantGroupStatus20251006Tok: Label 'TKA-BCAdminOpenTool-SetTenantGroupStatus-20251006', Locked = true;
        SetAPIVersionv22420260104Tok: Label 'TKA-BCAdminOpenTool-SetAPIVersionv224-20260104', Locked = true;
}