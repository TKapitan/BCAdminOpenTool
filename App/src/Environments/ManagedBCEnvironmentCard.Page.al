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
                field(UpdateAvailableTargetVersion; Rec.UpdateAvailableTargetVersion)
                {
#if not CLEAN29
#pragma warning disable AL0432
                    Visible = not ShowLegacyUpdateStructure;
#pragma warning restore AL0432
# endif
                }
                field(UpdateIsScheduled; Rec.UpdateIsScheduled)
                {
#if not CLEAN29
#pragma warning disable AL0432
                    Visible = not ShowLegacyUpdateStructure;
#pragma warning restore AL0432
#endif
                }
                field(UpdateSelectedTargetVersion; Rec.UpdateSelectedTargetVersion)
                {
#if not CLEAN29
#pragma warning disable AL0432
                    Visible = not ShowLegacyUpdateStructure;
#pragma warning restore AL0432
#endif
                }
                field(UpdateDate; Rec.UpdateDate)
                {
#if not CLEAN29
#pragma warning disable AL0432
                    Visible = not ShowLegacyUpdateStructure;
#pragma warning restore AL0432
# endif
                }
                field(UpdateSelectedExpAvailability; Rec.UpdateSelectedExpAvailability)
                {
#if not CLEAN29
#pragma warning disable AL0432
                    Visible = not ShowLegacyUpdateStructure;
#pragma warning restore AL0432
# endif
                }
                field(IgnoreScheduleUpgradeWindow; Rec.IgnoreScheduleUpgradeWindow)
                {
#if not CLEAN29
#pragma warning disable AL0432
                    Visible = not ShowLegacyUpdateStructure;
#pragma warning restore AL0432
#endif
                }
#if not CLEAN29
                field(UpdateIsActive; Rec.UpdateIsActive)
                {
                    Visible = ShowLegacyUpdateStructure;
                    ObsoleteReason = 'Replaced by flexible update logic and related fields.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '27.2';
                }
                field(UpdateTargetVersion; Rec.UpdateTargetVersion)
                {
                    Visible = ShowLegacyUpdateStructure;
                    ObsoleteReason = 'Replaced by flexible update logic and related fields.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '27.2';
                }
                field(UpgradeDate; Rec.UpgradeDate)
                {
                    Visible = ShowLegacyUpdateStructure;
                    ObsoleteReason = 'Replaced by flexible update logic and related fields.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '27.2';
                }
                field(UpdateStatus; Rec.UpdateStatus)
                {
                    Visible = ShowLegacyUpdateStructure;
                    ObsoleteReason = 'Replaced by flexible update logic and related fields.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '27.2';
                }
                field(CanTenantSelectDate; Rec.CanTenantSelectDate)
                {
                    Visible = ShowLegacyUpdateStructure;
                    Importance = Additional;
                    ObsoleteReason = 'Replaced by flexible update logic and related fields.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '27.2';
                }
                field(DidTenantSelectDate; Rec.DidTenantSelectDate)
                {
                    Visible = ShowLegacyUpdateStructure;
                    Importance = Additional;
                    ObsoleteReason = 'Replaced by flexible update logic and related fields.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '27.2';
                }
                field(EarliestSelectableUpgradeDate; Rec.EarliestSelectableUpgradeDate)
                {
                    Visible = ShowLegacyUpdateStructure;
                    Importance = Additional;
                    ObsoleteReason = 'Replaced by flexible update logic and related fields.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '27.2';
                }
                field(LatestSelectableUpgradeDate; Rec.LatestSelectableUpgradeDate)
                {
                    Visible = ShowLegacyUpdateStructure;
                    Importance = Additional;
                    ObsoleteReason = 'Replaced by flexible update logic and related fields.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '27.2';
                }
                field(IgnoreUpgradeWindow; Rec.IgnoreUpgradeWindow)
                {
                    Visible = ShowLegacyUpdateStructure;
                    ObsoleteReason = 'Replaced by flexible update logic and related fields.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '27.2';
                }
#endif
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
                AccessByPermission = tabledata TKAManagedBCEnvironment = IMD;
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
                    GetEnvironments.UpdateSelectedEnvironments(ManagedBCEnvironment, false);
                    CurrPage.Update();
                end;
            }
            action(ChangeUpdateSettings)
            {
                ApplicationArea = All;
                AccessByPermission = tabledata TKAManagedBCEnvironment = IMD;
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
#if not CLEAN29
            action(ChangeUpdateDate)
            {
                ApplicationArea = All;
                AccessByPermission = tabledata TKAManagedBCEnvironment = IMD;
                Caption = 'Change Update Date';
                ToolTip = 'Change the update date for the selected environment.';
                Image = ChangeLog;
                ObsoleteReason = 'Replaced by flexible update logic and related fields.';
                ObsoleteState = Pending;
                ObsoleteTag = '27.2';
                Visible = ShowLegacyUpdateStructure;

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
#endif
            action(InstallApps)
            {
                ApplicationArea = All;
                AccessByPermission = tabledata TKAManagedBCEnvironment = IMD;
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
            action(OpenAvailableUpdates)
            {
                Caption = 'Available Updates';
                ApplicationArea = All;
                ToolTip = 'View available updates for this environment.';
                Image = DateRange;
                RunObject = page TKAManagedBCEnvAvailUpdates;
                RunPageLink = TenantId = field(TenantId), EnvironmentName = field(Name);
#if not CLEAN29
#pragma warning disable AL0432
                Visible = not ShowLegacyUpdateStructure;
#pragma warning restore AL0432
#endif
            }
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
                    Caption = 'Change...';
                    Image = Change;

                    actionref(ChangeUpdateSettings_Promoted; ChangeUpdateSettings) { }
#if not CLEAN29
#pragma warning disable AL0432
                    actionref(ChangeUpdateDate_Promoted; ChangeUpdateDate)
#pragma warning restore AL0432
                    {
                        ObsoleteReason = 'Replaced by flexible update logic and related fields.';
                        ObsoleteState = Pending;
                        ObsoleteTag = '27.2';
                    }
#endif
                    actionref(InstallApps_Promoted; InstallApps) { }
                }
            }
            group(Category_Category5)
            {
                Caption = 'Navigation';

                actionref(OpenAvailableUpdates_Promoted; OpenAvailableUpdates) { }
                actionref(OpenManagedBCApps_Promoted; OpenManagedBCApps) { }
            }
        }
    }

#if not CLEAN29
    trigger OnOpenPage()
    var
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
    begin
#pragma warning disable AL0432
        ShowLegacyUpdateStructure := false;
        AdminCenterAPISetup.ReadIsolation(IsolationLevel::ReadUncommitted);
        AdminCenterAPISetup.SetLoadFields(APIVersion);
        AdminCenterAPISetup.Get();
        ShowLegacyUpdateStructure := AdminCenterAPISetup.APIVersion = AdminCenterAPISetup.APIVersion::"v2.24";
#pragma warning restore AL0432
    end;
#endif

    var
        OpenEnvironmentLbl: Label 'Open Environment';
#if not CLEAN29
        [Obsolete('Replaced by flexible update logic and related fields.', '27.2')]
        ShowLegacyUpdateStructure: Boolean;
#endif
}