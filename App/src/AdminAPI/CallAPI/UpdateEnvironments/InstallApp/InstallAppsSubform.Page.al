page 73279 TKAInstallAppsSubform
{
    Caption = 'Selected Apps to Install';
    PageType = ListPart;
    UsageCategory = Lists;
    ApplicationArea = All;
    ShowFilter = false;
    SourceTable = TKAInstallAppsBuffer;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(AppId; Rec.AppId) { }
                field(Name; Rec.Name) { }
            }
        }
    }

    /// <summary>
    /// Gets the apps selected in the buffer table that are to be installed.
    /// </summary>
    /// <param name="InstallAppsBuffer">Buffer table containing the apps to be installed.</param>
    procedure GetApps(var InstallAppsBuffer: Record TKAInstallAppsBuffer temporary)
    begin
        InstallAppsBuffer.Copy(Rec, true);
    end;
}