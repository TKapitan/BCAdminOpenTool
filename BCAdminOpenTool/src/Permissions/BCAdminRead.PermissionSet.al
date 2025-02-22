permissionset 73270 TKABCAdminRead
{
    Assignable = true;
    Caption = 'BC Admin Read', MaxLength = 30;
    Permissions =
        tabledata TKABCTenant = R,
        tabledata TKABCAdminApp = R,
        tabledata TKAAdminCenterAPISetup = R;
}