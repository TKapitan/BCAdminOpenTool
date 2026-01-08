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
                field(TokenUrl; Rec.TokenUrl) { }
                field(Scope; Rec.Scope) { }
                field(APIUrl; Rec.APIUrl) { }
                field(APIVersion; Rec.APIVersion) { }
            }
            group(Apps)
            {
                Caption = 'Apps';
                field(OurPublisherName; Rec.OurPublisherName) { }
                field(ExcludeHiddedApps; Rec.ExcludeHiddedApps) { }
            }
            group(AdditionalEndpoints)
            {
                Caption = 'Additional Endpoints';
                field(GetScheduledUpdateAPIEnabled; Rec.GetScheduledUpdateAPIEnabled) { }
                field(GetUpdateSettingsAPIEnabled; Rec.GetUpdateSettingsAPIEnabled) { }
                field(GetInstalledAppsEnabled; Rec.GetInstalledAppsEnabled) { }
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
