enum 73271 TKAAdminCenterAPIVersion
{
    Caption = 'Admin Center API Version';
    Extensible = true;

#pragma warning disable LC0045 // We do not want blank option, use option 0 for default value
    value(0; "v2.24")
    {
        Caption = 'v2.24', Locked = true;
    }
#pragma warning restore LC0045
    value(5; "v2.28")
    {
        Caption = 'v2.28', Locked = true;
    }
}