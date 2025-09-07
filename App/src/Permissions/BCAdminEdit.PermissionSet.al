permissionset 73271 TKABCAdminEdit
{
    Assignable = true;
    Caption = 'BC Admin Edit', MaxLength = 30;
    IncludedPermissionSets =
        TKABCAdminRead;
    Permissions =
        tabledata TKAAppSourceOffering = IMD,
        tabledata TKAWhitelistedThirdPartyApp = IMD,
        tabledata TKAManagedBCTenant = IMD,
        tabledata TKAManagedBCAdministrationApp = IMD;
}