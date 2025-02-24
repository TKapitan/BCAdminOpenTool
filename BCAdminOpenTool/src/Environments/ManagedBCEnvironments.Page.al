page 73273 TKAManagedBCEnvironments
{
    ApplicationArea = All;
    Caption = 'Managed BC Environments';
    CardPageId = TKAManagedBCEnvironmentCard;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    PageType = List;
    SourceTable = TKAManagedBCEnvironment;
    UsageCategory = Lists;

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
                field(Name; Rec.Name) { }
                field(TenantName; Rec.TenantName) { }
                field(Type; Rec."Type") { }
                field(RingName; Rec.RingName)
                {
                    Visible = false;
                }
                field(CountryCode; Rec.CountryCode) { }
                field(ApplicationVersion; Rec.ApplicationVersion) { }
                field(PlatformVersion; Rec.PlatformVersion) { }
                field(UpdateIsActive; Rec.UpdateIsActive) { }
                field(UpdateTargetVersion; Rec.UpdateTargetVersion) { }
                field(UpgradeDate; Rec.UpgradeDate) { }
                field(PreferredStartTime; Rec.PreferredStartTime)
                {
                    Visible = false;
                }
                field(PreferredEndTime; Rec.PreferredEndTime)
                {
                    Visible = false;
                }
                field(TimeZoneId; Rec.TimeZoneId)
                {
                    Visible = false;
                }
                field(Status; Rec.Status) { }
                field(AppSourceAppsUpdateCadence; Rec.AppSourceAppsUpdateCadence) { }
                field(LocationName; Rec.LocationName) { }
                field(GeoName; Rec.GeoName) { }
                field(ApplicationInsightsKey; Rec.ApplicationInsightsKey)
                {
                    Visible = false;
                }
                field(SoftDeletedOn; Rec.SoftDeletedOn)
                {
                    Visible = false;
                }
                field(HardDeletePendingOn; Rec.HardDeletePendingOn)
                {
                    Visible = false;
                }
                field(DeleteReason; Rec.DeleteReason)
                {
                    Visible = false;
                }
                field(OpenEnvironmentField; OpenEnvironmentLbl)
                {
                    Caption = 'Web Client';
                    ToolTip = 'Specifies the web client URL for the environment.';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(Rec.WebClientURL);
                    end;
                }
                field(EnvironmentModifiedAt; Rec.EnvironmentModifiedAt) { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateEnvironments)
            {
                ApplicationArea = All;
                Caption = 'Update Environments';
                ToolTip = 'Refresh the list of managed BC environments from admin portal.';
                Image = Refresh;

                trigger OnAction()
                var
                    ManagedBCEnvironment: Record TKAManagedBCEnvironment;
                    GetEnvironments: Codeunit TKAGetEnvironments;
                begin
                    CurrPage.SetSelectionFilter(ManagedBCEnvironment);
                    GetEnvironments.UpdateSelectedEnvironments(ManagedBCEnvironment);
                    CurrPage.Update();
                end;
            }
            action(ChangeUpdateSettings)
            {
                ApplicationArea = All;
                Caption = 'Change Update Settings';
                ToolTip = 'Change the update settings for the selected environments.';
                Image = SetPriorities;

                trigger OnAction()
                var
                    ManagedBCEnvironment: Record TKAManagedBCEnvironment;
                    ChangeUpdateSettings: Report TKAChangeUpdateSettings;
                begin
                    CurrPage.SetSelectionFilter(ManagedBCEnvironment);
                    ChangeUpdateSettings.SetEnvironmentsToUpdate(ManagedBCEnvironment);
                    ChangeUpdateSettings.RunModal();
                    CurrPage.Update();
                end;
            }
            action(ChangeUpdateDate)
            {
                ApplicationArea = All;
                Caption = 'Change Update Date';
                ToolTip = 'Change the update date for the selected environments.';
                Image = ChangeLog;

                trigger OnAction()
                var
                    ManagedBCEnvironment: Record TKAManagedBCEnvironment;
                    ChangeUpdateDate: Report TKAChangeUpdateDate;
                begin
                    CurrPage.SetSelectionFilter(ManagedBCEnvironment);
                    ChangeUpdateDate.SetEnvironmentsToUpdate(ManagedBCEnvironment);
                    ChangeUpdateDate.RunModal();
                    CurrPage.Update();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(UpdateEnvironments_Promoted; UpdateEnvironments) { }

                group(Change)
                {
                    Caption = 'Change';
                    Image = Change;

                    actionref(ChangeUpdateSettings_Promoted; ChangeUpdateSettings) { }
                    actionref(ChangeUpdateDate_Promoted; ChangeUpdateDate) { }
                }
            }
        }
    }

    var
        OpenEnvironmentLbl: Label 'Open Environment';
}
