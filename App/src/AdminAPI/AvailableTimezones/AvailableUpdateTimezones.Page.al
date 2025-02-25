page 73275 TKAAvailableUpdateTimezones
{
    ApplicationArea = All;
    Caption = 'Available Update Timezones';
    PageType = List;
    SourceTable = TKAAvailableUpdateTimezone;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Name; Rec.Name) { }
                field(DisplayName; Rec.DisplayName) { }
                field(CurrentUtcOffset; Rec.CurrentUtcOffset) { }
                field(SupportsDaylightSavingTime; Rec.SupportsDaylightSavingTime) { }
                field(IsCurrentlyDaylightSavingTime; Rec.IsCurrentlyDaylightSavingTime) { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetAvailableTimezones)
            {
                ApplicationArea = All;
                Caption = 'Get Available Timezones';
                Image = Timeline;
                ToolTip = 'Get available timezones from the Admin API.';

                trigger OnAction()
                var
                    GetTimezones: Codeunit TKAGetTimezones;
                begin
                    GetTimezones.CreateUpdateAvailableUpdateTimezones();
                    CurrPage.Update();
                end;
            }
        }
    }

}
