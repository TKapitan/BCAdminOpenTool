permissionset 73270 TKABCAdminRead
{
    Assignable = true;
    Caption = 'BC Admin Read', MaxLength = 30;
    Permissions =
        tabledata TKAManagedBCTenant = R,
        tabledata TKAManagedBCTenantGroup = R,
        tabledata TKAManagedBCEnvironment = R,
        tabledata TKAManagedBCAdministrationApp = R,
        tabledata TKAAvailableUpdateTimezone = R,
        tabledata TKAAdminCenterAPISetup = R;
}