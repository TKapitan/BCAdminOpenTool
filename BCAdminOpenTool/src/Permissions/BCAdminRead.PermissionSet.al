permissionset 73270 TKABCAdminRead
{
    Assignable = true;
    Caption = 'BC Admin Read', MaxLength = 30;
    Permissions =
        tabledata TKAManagedBCTenant = R,
        tabledata TKAManagedBCEnvironment = R,
        tabledata TKAManagedBCAdministrationApp = R,
        tabledata TKAAdminCenterAPISetup = R;
}