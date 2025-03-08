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
                field(TenantGroupCode; Rec.TenantGroupCode)
                {
                    Visible = false;
                }
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
                field(GeoName; Rec.GeoName)
                {
                    Visible = false;
                }
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
                field(NoOfApps; NoOfApps)
                {
                    Caption = 'No. of Apps';
                    Editable = false;
                    ToolTip = 'Specifies the number of apps installed for this environment. Only apps installed from AppSource are counted.';

                    trigger OnDrillDown()
                    var
                        ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp;
                    begin
                        SetFilterEnvironmentApps(ManagedBCEnvironmentApp);
                        OpenFilteredEnvironmentApps(ManagedBCEnvironmentApp);
                    end;
                }
                field(NoOfOurApps; NoOfOurApps)
                {
                    Caption = 'No. of Our Apps';
                    Editable = false;
                    ToolTip = 'Specifies the number of apps published by us for this environment. Only apps installed from AppSource are counted.';

                    trigger OnDrillDown()
                    var
                        ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp;
                    begin
                        SetFilterOurApps(ManagedBCEnvironmentApp);
                        OpenFilteredEnvironmentApps(ManagedBCEnvironmentApp);
                    end;
                }
                field(NoOfThirdPartyApps; NoOfThirdPartiesApps)
                {
                    Caption = 'No. of Third-Party Apps';
                    Editable = false;
                    ToolTip = 'Specifies the number of apps published by third parties for this environment. Only apps installed from AppSource are counted.';

                    trigger OnDrillDown()
                    var
                        ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp;
                    begin
                        SetFilterThirdPartyApps(ManagedBCEnvironmentApp);
                        OpenFilteredEnvironmentApps(ManagedBCEnvironmentApp);
                    end;
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
                    CurrPage.SetSelectionFilter(ManagedBCEnvironment);
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

    trigger OnOpenPage()
    var
        SoftDeletedStatusTok: Label 'SoftDeleted', Locked = true;
    begin
        Rec.SetFilter(Status, '<>%1', SoftDeletedStatusTok);
        SetVisibleBCTenantGroupFilter();
    end;

    trigger OnAfterGetRecord()
    begin
        CalcNoOfOurThirdPartyApps();
    end;

    var
        OpenEnvironmentLbl: Label 'Open Environment';
        NoOfApps, NoOfOurApps, NoOfThirdPartiesApps : Integer;


    local procedure SetVisibleBCTenantGroupFilter()
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.ReadIsolation(IsolationLevel::ReadCommitted);
        UserSetup.SetLoadFields(TKAVisibleBCTenantGroupCode);
        if not UserSetup.Get(UserId()) then
            exit;
        if UserSetup.TKAVisibleBCTenantGroupCode = '' then
            exit;
        Rec.SetRange(TenantGroupCode, UserSetup.TKAVisibleBCTenantGroupCode);
    end;

    local procedure CalcNoOfOurThirdPartyApps(): Text
    var
        ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp;
    begin
        SetFilterEnvironmentApps(ManagedBCEnvironmentApp);
        NoOfApps := ManagedBCEnvironmentApp.Count();
        SetFilterOurApps(ManagedBCEnvironmentApp);
        NoOfOurApps := ManagedBCEnvironmentApp.Count();
        SetFilterThirdPartyApps(ManagedBCEnvironmentApp);
        NoOfThirdPartiesApps := ManagedBCEnvironmentApp.Count();
    end;

    local procedure SetFilterEnvironmentApps(var ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp)
    var
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
    begin
        Clear(ManagedBCEnvironmentApp);
        AdminCenterAPISetup.ReadIsolation(IsolationLevel::ReadUncommitted);
        AdminCenterAPISetup.SetLoadFields(ExcludeHiddedApps);
        AdminCenterAPISetup.Get();

        ManagedBCEnvironmentApp.ReadIsolation(IsolationLevel::ReadUncommitted);
        ManagedBCEnvironmentApp.SetRange(TenantId, Rec.TenantId);
        ManagedBCEnvironmentApp.SetRange(EnvironmentName, Rec.Name);
        if AdminCenterAPISetup.ExcludeHiddedApps then
            ManagedBCEnvironmentApp.SetRange(Hidden, false);
    end;

    local procedure SetFilterOurApps(var ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp)
    var
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
    begin
        Clear(ManagedBCEnvironmentApp);
        AdminCenterAPISetup.ReadIsolation(IsolationLevel::ReadUncommitted);
        AdminCenterAPISetup.SetLoadFields(OurPublisherName);
        AdminCenterAPISetup.Get();

        SetFilterEnvironmentApps(ManagedBCEnvironmentApp);
        ManagedBCEnvironmentApp.SetRange(Publisher, AdminCenterAPISetup.OurPublisherName);
    end;

    local procedure SetFilterThirdPartyApps(var ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp)
    var
        MicrosoftPublisherTok: Label 'Microsoft', Locked = true;
    begin
        Clear(ManagedBCEnvironmentApp);
        SetFilterOurApps(ManagedBCEnvironmentApp);
        ManagedBCEnvironmentApp.SetFilter(Publisher, '<>%1&<>%2', ManagedBCEnvironmentApp.GetFilter(Publisher), MicrosoftPublisherTok);
    end;

    local procedure OpenFilteredEnvironmentApps(var ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp)
    var
        PageManagement: Codeunit "Page Management";
    begin
        PageManagement.PageRun(ManagedBCEnvironmentApp);
    end;
}
