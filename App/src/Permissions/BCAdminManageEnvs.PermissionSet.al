permissionset 73273 TKABCAdminManageEnvs
{
    Assignable = true;
    Caption = 'BC Admin Manage Environments', MaxLength = 30;
    IncludedPermissionSets =
        TKABCAdminRead;
    Permissions =
        tabledata TKAManagedBCEnvironment = IMD,
        tabledata TKAManagedBCEnvironmentApp = IMD;
}