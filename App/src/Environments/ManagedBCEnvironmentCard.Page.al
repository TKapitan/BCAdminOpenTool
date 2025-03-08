page 73274 TKAManagedBCEnvironmentCard
{
    Caption = 'Managed BC Environment Card';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = TKAManagedBCEnvironment;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(TenantId; Rec.TenantId)
                {
                    Visible = false;
                }
                field(TenantName; Rec.TenantName) { }
                field(Name; Rec.Name) { }
                field(Type; Rec."Type") { }
                field(CountryCode; Rec.CountryCode) { }
                field(RingName; Rec.RingName)
                {
                    Importance = Additional;
                }
                field(Status; Rec.Status) { }
                field(OpenEnvironmentField; OpenEnvironmentLbl)
                {
                    Caption = 'Web Client';
                    ToolTip = 'Specifies the web client URL for the environment.';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(Rec.WebClientURL);
                    end;
                }
                field(ApplicationInsightsKey; Rec.ApplicationInsightsKey)
                {
                    Importance = Additional;
                }
                field(EnvironmentModifiedAt; Rec.EnvironmentModifiedAt) { }
            }
            group(UpdateManagement)
            {
                Caption = 'Update Management';

                field(ApplicationVersion; Rec.ApplicationVersion) { }
                field(PlatformVersion; Rec.PlatformVersion) { }
                field(UpdateIsActive; Rec.UpdateIsActive) { }
                field(UpdateTargetVersion; Rec.UpdateTargetVersion) { }
                field(UpgradeDate; Rec.UpgradeDate) { }
                field(UpdateStatus; Rec.UpdateStatus) { }
                field(CanTenantSelectDate; Rec.CanTenantSelectDate)
                {
                    Importance = Additional;
                }
                field(DidTenantSelectDate; Rec.DidTenantSelectDate)
                {
                    Importance = Additional;
                }
                field(EarliestSelectableUpgradeDate; Rec.EarliestSelectableUpgradeDate)
                {
                    Importance = Additional;
                }
                field(LatestSelectableUpgradeDate; Rec.LatestSelectableUpgradeDate)
                {
                    Importance = Additional;
                }
                field(IgnoreUpgradeWindow; Rec.IgnoreUpgradeWindow) { }
                field(PreferredStartTime; Rec.PreferredStartTime) { }
                field(PreferredEndTime; Rec.PreferredEndTime) { }
                field(TimeZoneId; Rec.TimeZoneId) { }
                field(PreferredStartTimeUtc; Rec.PreferredStartTimeUtc) { }
                field(PreferredEndTimeUtc; Rec.PreferredEndTimeUtc) { }
                field(AppSourceAppsUpdateCadence; Rec.AppSourceAppsUpdateCadence) { }
            }
            group(StatusDetails)
            {
                Caption = 'Status Details';

                field(Status_StatusDetails; Rec.Status) { }
                field(SoftDeletedOn; Rec.SoftDeletedOn) { }
                field(HardDeletePendingOn; Rec.HardDeletePendingOn) { }
                field(DeleteReason; Rec.DeleteReason) { }
            }
            group(Location)
            {
                Caption = 'Location';

                field(LocationName; Rec.LocationName) { }
                field(GeoName; Rec.GeoName) { }
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
                ToolTip = 'Refresh the managed BC environment from admin portal.';
                Image = Refresh;

                trigger OnAction()
                var
                    ManagedBCEnvironment: Record TKAManagedBCEnvironment;
                    GetEnvironments: Codeunit TKAGetEnvironments;
                begin
                    ManagedBCEnvironment := Rec;
                    ManagedBCEnvironment.SetRecFilter();
                    GetEnvironments.UpdateSelectedEnvironments(ManagedBCEnvironment);
                    CurrPage.Update();
                end;
            }
            action(ChangeUpdateSettings)
            {
                ApplicationArea = All;
                Caption = 'Change Update Settings';
                ToolTip = 'Change the update settings for the selected environment.';
                Image = SetPriorities;

                trigger OnAction()
                var
                    ManagedBCEnvironment: Record TKAManagedBCEnvironment;
                    ChangeUpdateSettings: Report TKAChangeUpdateSettings;
                begin
                    ManagedBCEnvironment := Rec;
                    ManagedBCEnvironment.SetRecFilter();
                    ChangeUpdateSettings.SetEnvironmentsToUpdate(ManagedBCEnvironment);
                    ChangeUpdateSettings.RunModal();
                    CurrPage.Update();
                end;
            }
            action(ChangeUpdateDate)
            {
                ApplicationArea = All;
                Caption = 'Change Update Date';
                ToolTip = 'Change the update date for the selected environment.';
                Image = ChangeLog;

                trigger OnAction()
                var
                    ManagedBCEnvironment: Record TKAManagedBCEnvironment;
                    ChangeUpdateDate: Report TKAChangeUpdateDate;
                begin
                    ManagedBCEnvironment := Rec;
                    ManagedBCEnvironment.SetRecFilter();
                    ChangeUpdateDate.SetEnvironmentsToUpdate(ManagedBCEnvironment);
                    ChangeUpdateDate.RunModal();
                    CurrPage.Update();
                end;
            }
            action(InstallApps)
            {
                ApplicationArea = All;
                Caption = 'Install App';
                ToolTip = 'Install an app for the selected environments.';
                Image = Installments;

                trigger OnAction()
                var
                    ManagedBCEnvironment: Record TKAManagedBCEnvironment;
                    InstallApps: Report TKAInstallApps;
                begin
                    ManagedBCEnvironment := Rec;
                    ManagedBCEnvironment.SetRecFilter();
                    InstallApps.SetEnvironments(ManagedBCEnvironment);
                    InstallApps.RunModal();
                    CurrPage.Update();
                end;
            }
        }
        area(Navigation)
        {
            action(OpenManagedBCApps)
            {
                Caption = 'Apps';
                ApplicationArea = All;
                ToolTip = 'View and manage apps for this environment.';
                Image = SendApprovalRequest;
                RunObject = page TKAManagedBCEnvironmentApps;
                RunPageLink = TenantId = field(TenantId), EnvironmentName = field(Name);
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
                    actionref(InstallApps_Promoted; InstallApps) { }
                }
                actionref(OpenManagedBCApps_Promoted; OpenManagedBCApps) { }
            }
        }
    }

    var
        OpenEnvironmentLbl: Label 'Open Environment';
}