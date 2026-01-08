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
#if CLEAN28
        SetDefaultAPIv22820260104();
#endif
#if CLEAN29
        ForceAPIv22820260104();
#endif
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

#if CLEAN28
    local procedure SetDefaultAPIv22820260104()
    var
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
    begin
        if UpgradeTag.HasUpgradeTag(SetDefaultAPIv22820260104Tok) then
            exit;
        if not AdminCenterAPISetup.Get() then
            exit;
        if AdminCenterAPISetup.APIVersion <> AdminCenterAPISetup.APIVersion::"v2.24" then
            exit;
        AdminCenterAPISetup.Validate(APIVersion, AdminCenterAPISetup.APIVersion::"v2.28");
        AdminCenterAPISetup.Modify(true);
        UpgradeTag.SetUpgradeTag(SetDefaultAPIv22820260104Tok);
    end;
#endif

#if CLEAN29
    local procedure ForceAPIv22820260104()
    var
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
    begin
        if UpgradeTag.HasUpgradeTag(ForceAPIv22820260104Tok) then
            exit;
        if not AdminCenterAPISetup.Get() then
            exit;
        if AdminCenterAPISetup.APIVersion <> AdminCenterAPISetup.APIVersion::"v2.24" then
            exit;
        AdminCenterAPISetup.Validate(APIVersion, AdminCenterAPISetup.APIVersion::"v2.28");
        AdminCenterAPISetup.Modify(true);
        UpgradeTag.SetUpgradeTag(ForceAPIv22820260104Tok);
    end;
#endif

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", OnGetPerCompanyUpgradeTags, '', false, false)]
    local procedure OnGetPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(SetTenantGroupStatus20251006Tok);
        PerCompanyUpgradeTags.Add(SetAPIVersionv22420260104Tok);
#if CLEAN28
        PerCompanyUpgradeTags.Add(SetDefaultAPIv22820260104Tok);
#endif
#if CLEAN29
        PerCompanyUpgradeTags.Add(ForceAPIv22820260104Tok);
#endif
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", OnGetPerDatabaseUpgradeTags, '', false, false)]
    local procedure OnGetPerDatabaseUpgradeTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
    end;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        SetTenantGroupStatus20251006Tok: Label 'TKA-BCAdminOpenTool-SetTenantGroupStatus-20251006', Locked = true;
        SetAPIVersionv22420260104Tok: Label 'TKA-BCAdminOpenTool-SetAPIVersionv224-20260104', Locked = true;
#if CLEAN28
        SetDefaultAPIv22820260104Tok: Label 'TKA-BCAdminOpenTool-SetDefaultAPIv228-20260104', Locked = true;
#endif
#if CLEAN29
        ForceAPIv22820260104Tok: Label 'TKA-BCAdminOpenTool-ForceAPIv228-20260104', Locked = true;
#endif
}