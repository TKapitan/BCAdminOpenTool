permissionset 73271 TKABCAdminEdit
{
    Assignable = true;
    Caption = 'BC Admin Edit', MaxLength = 30;
    IncludedPermissionSets =
        TKABCAdminRead;
    Permissions =
        tabledata TKABCTenant = IMD,
        tabledata TKABCAdminApp = IMD;
}