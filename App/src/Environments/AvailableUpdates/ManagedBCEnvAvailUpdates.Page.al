page 73282 TKAManagedBCEnvAvailUpdates
{
    ApplicationArea = All;
    Caption = 'Managed BC Environment Available Updates';
    PageType = List;
    SourceTable = TKAManagedBCEnvAvailUpdate;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(TenantId; Rec.TenantId)
                {
                    Visible = false;
                }
                field(EnvironmentName; Rec.EnvironmentName)
                {
                    Visible = false;
                }
                field(TargetVersion; Rec.TargetVersion) { }
                field(TargetVersionType; Rec.TargetVersionType) { }
                field(RolloutStatus; Rec.RolloutStatus) { }
                field(Available; Rec.Available) { }
                field(Selected; Rec.Selected) { }
                field(ExpectedAvailability; Rec.ExpectedAvailability) { }
                field(SelectedDate; Rec.SelectedDate) { }
                field(LatestSelectableDate; Rec.LatestSelectableDate) { }
                field(IgnoreUpdateWindow; Rec.IgnoreUpdateWindow) { }
            }
        }
    }
#if not CLEAN29
    trigger OnOpenPage()
    var
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
    begin
        AdminCenterAPISetup.ReadIsolation(IsolationLevel::ReadUncommitted);
        AdminCenterAPISetup.SetLoadFields(APIVersion);
        AdminCenterAPISetup.Get();
#pragma warning disable AL0432
        if AdminCenterAPISetup.APIVersion = AdminCenterAPISetup.APIVersion::"v2.24" then
#pragma warning restore AL0432
            AdminCenterAPISetup.FieldError(APIVersion);
    end;
#endif
}
