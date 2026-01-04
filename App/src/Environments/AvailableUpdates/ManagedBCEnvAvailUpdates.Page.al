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
}
