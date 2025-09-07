permissionset 73271 TKABCAdminEditApps
{
    Assignable = true;
    Caption = 'BC Admin Edit', MaxLength = 30;
    IncludedPermissionSets =
        TKABCAdminRead;
    Permissions =
        tabledata TKAAppSourceOffering = IMD,
        tabledata TKAWhitelistedThirdPartyApp = IMD;
}