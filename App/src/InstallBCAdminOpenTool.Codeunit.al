codeunit 73303 TKAInstallBCAdminOpenTool
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerCompany()
    var
        UpgradeBCAdminOpenTool: Codeunit TKAUpgradeBCAdminOpenTool;
        ModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        if ModuleInfo.DataVersion() = Version.Create(0, 0, 0, 0) then
            RunOnInstallAppPerCompanyForFreshInstall()
        else
            UpgradeBCAdminOpenTool.RunOnUpgradePerCompany();
    end;

    trigger OnInstallAppPerDatabase()
    var
        UpgradeBCAdminOpenTool: Codeunit TKAUpgradeBCAdminOpenTool;
        ModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        if ModuleInfo.DataVersion() = Version.Create(0, 0, 0, 0) then
            RunOnInstallAppPerDatabaseForFreshInstall()
        else
            UpgradeBCAdminOpenTool.RunOnUpgradePerDatabase();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", OnCompanyInitialize, '', false, false)]
    local procedure OnCompanyInitializeCompanyInitialize()
    begin
        RunOnInstallAppPerCompanyForFreshInstall();
    end;

    procedure RunOnInstallAppPerCompanyForFreshInstall()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        UpgradeTag.SetAllUpgradeTags();
    end;

    procedure RunOnInstallAppPerDatabaseForFreshInstall()
    begin
    end;
}