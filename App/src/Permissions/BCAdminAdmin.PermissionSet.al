permissionset 73272 TKABCAdminAdmin
{
    Assignable = true;
    Caption = 'BC Admin Admin', MaxLength = 30;
    IncludedPermissionSets =
        TKABCAdminRead,
        TKABCAdminManageEnvs,
        TKABCAdminEditApps;
    Permissions =
        tabledata TKAAdminCenterAPISetup = M,
        tabledata TKAManagedBCTenantGroup = IMD,
        tabledata TKAAvailableUpdateTimezone = IMD;
}