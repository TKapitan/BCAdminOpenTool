page 73283 TKAAvailableUpdatesLookup
{
    ApplicationArea = All;
    Caption = 'Available Updates Lookup';
    PageType = List;
    SourceTable = TKAManagedBCEnvAvailUpdate;
    SourceTableTemporary = true;
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
                field(TargetVersion; Rec.TargetVersion) { }
                field(RolloutStatus; Rec.RolloutStatus) { }
                field(Available; Rec.Available) { }
                field(ExpectedAvailability; Rec.ExpectedAvailability) { }
                field(LatestSelectableDate; Rec.LatestSelectableDate) { }
            }
        }
    }

    procedure SetRecordToShow(var TempManagedBCEnvAvailUpdate: Record TKAManagedBCEnvAvailUpdate temporary)
    begin
        Rec.Copy(TempManagedBCEnvAvailUpdate, true);
    end;
}
