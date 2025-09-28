permissionset 73274 TKABCAdminManageTens
{
    Assignable = true;
    Caption = 'BC Admin Manage Tenants', MaxLength = 30;
    IncludedPermissionSets =
        TKABCAdminRead,
        TKABCAdminManageEnvs;
    Permissions =
        tabledata TKAManagedBCTenant = IMD,
        tabledata TKAManagedBCTenantGroup = IMD;
}