page 73272 TKAAdminCenterAPISetup
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = TKAAdminCenterAPISetup;
    Caption = 'Admin Center API Setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(AuthUrl; Rec.AuthUrl) { }
                field(Scope; Rec.Scope) { }
                field(APIUrl; Rec.APIUrl) { }
            }
            group(AdditionalEndpoints)
            {
                Caption = 'Additional Endpoints';
                field(GetScheduledUpdateAPIEnabled; Rec.GetScheduledUpdateAPIEnabled) { }
                field(GetUpdateSettingsAPIEnabled; Rec.GetUpdateSettingsAPIEnabled) { }
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
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InsertIfNotExists();
    end;
}
