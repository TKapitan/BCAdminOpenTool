table 73273 TKAManagedBCEnvironment
{
    Caption = 'Managed BC Environment';
    DataClassification = CustomerContent;
    DrillDownPageId = TKAManagedBCEnvironments;
    LookupPageId = TKAManagedBCEnvironments;

    fields
    {
        field(1; TenantId; Guid)
        {
            Caption = 'Tenant ID';
            DataClassification = OrganizationIdentifiableInformation;
            ToolTip = 'Specifies the tenant ID for the tenant.';
            NotBlank = true;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the tenant.';
            NotBlank = true;
        }
        field(3; TenantName; Text[100])
        {
            Caption = 'Tenant Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(TKAManagedBCTenant.Name where(TenantId = field(TenantId)));
            ToolTip = 'Specifies the name of the tenant.';
        }
        field(4; TenantGroupCode; Code[20])
        {
            Caption = 'Tenant Group Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(TKAManagedBCTenant.GroupCode where(TenantId = field(TenantId)));
            ToolTip = 'Specifies the group code for the tenant.';
        }
        field(5; Type; Text[20])
        {
            Caption = 'Type';
            ToolTip = 'Specifies the type of the tenant. Type can be Production or Sandbox.';
        }
        field(10; CountryCode; Text[2])
        {
            Caption = 'Country Code';
            ToolTip = 'Specifies the country code for the environment.';
        }
        field(15; CustomerNo; Code[20])
        {
            Caption = 'Customer No.';
            FieldClass = FlowField;
            CalcFormula = lookup(TKAManagedBCTenant.CustomerNo where(TenantId = field(TenantId)));
            ToolTip = 'Specifies the customer number for the tenant.';
            Editable = false;
            AllowInCustomizations = AsReadOnly;
        }
        field(20; ApplicationVersion; Text[20])
        {
            Caption = 'Application Version';
            ToolTip = 'Specifies the application version of the environment.';
        }
        field(30; PlatformVersion; Text[20])
        {
            Caption = 'Platform Version';
            ToolTip = 'Specifies the platform version of the environment.';
        }
        field(40; RingName; Text[20])
        {
            Caption = 'Ring Name';
            ToolTip = 'Specifies the ring name of the environment.';
        }
        field(50; Status; Text[50])
        {
            Caption = 'Status';
            ToolTip = 'Specifies the status of the environment. Status can be NotReady, Removing, Preparing or Active.';
        }
        field(100; LocationName; Text[100])
        {
            Caption = 'Location Name';
            ToolTip = 'Specifies the location (datacenter) of the environment.';
        }
        field(105; GeoName; Text[100])
        {
            Caption = 'Geo Name';
            ToolTip = 'Specifies the geo name of the environment.';
        }
        field(250; ApplicationInsightsKey; Text[500])
        {
            Caption = 'AppInsights Key';
            ToolTip = 'Specifies the Application Insights key of the environment.';
        }
        field(260; AppSourceAppsUpdateCadence; Text[50])
        {
            Caption = 'AppSource Apps Update Cadence';
            ToolTip = 'Specifies the update cadence of the AppSource apps in the environment.';
        }
        field(300; WebClientURL; Text[500])
        {
            AllowInCustomizations = AsReadWrite;
            Caption = 'Web Client URL';
            ToolTip = 'Specifies the URL of the web client for the environment.';
            ExtendedDatatype = URL;
        }
        field(500; SoftDeletedOn; DateTime)
        {
            Caption = 'Soft Deleted On';
            ToolTip = 'Specifies the date and time when the record was soft deleted.';
        }
        field(505; HardDeletePendingOn; DateTime)
        {
            Caption = 'Hard Delete Pending On';
            ToolTip = 'Specifies the date and time when the record will be hard deleted.';
        }
        field(510; DeleteReason; Text[100])
        {
            Caption = 'Delete Reason';
            ToolTip = 'Specifies the reason why the environment was deleted.';
        }
        field(700; UpdateTargetVersion; Text[20])
        {
            Caption = 'Update Target Version';
            ToolTip = 'Specifies the version of the application that the environment will update to.';
            ObsoleteReason = 'Replaced by flexible update logic and related fields.';
#if not CLEAN29
            ObsoleteState = Pending;
            ObsoleteTag = '27.2';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
        }
#pragma warning disable AA0232 // SIFT index makes no sense for this field
        field(701; UpdateAvailableTargetVersion; Text[20])
#pragma warning restore AA0232
        {
            Caption = 'Update Available Target Version';
            FieldClass = FlowField;
            CalcFormula = max(TKAManagedBCEnvAvailUpdate.TargetVersion where(TenantId = field(TenantId), EnvironmentName = field(Name), Available = const(true)));
            ToolTip = 'Specifies the latest version of the application that is available for the environment to update to.';
            Editable = false;
        }
        field(702; UpdateSelectedTargetVersion; Text[20])
        {
            Caption = 'Update Selected Target Version';
            FieldClass = FlowField;
            CalcFormula = lookup(TKAManagedBCEnvAvailUpdate.TargetVersion where(TenantId = field(TenantId), EnvironmentName = field(Name), Selected = const(true)));
            ToolTip = 'Specifies the version of the application that the environment has selected for the update.';
            Editable = false;
        }
        field(703; UpdateSelectedExpAvailability; Text[20])
        {
            Caption = 'Selected Update Expected Availability';
            FieldClass = FlowField;
            CalcFormula = lookup(TKAManagedBCEnvAvailUpdate.ExpectedAvailability where(TenantId = field(TenantId), EnvironmentName = field(Name), Selected = const(true)));
            ToolTip = 'Specifies the expected availability of the selected update for the environment.';
            Editable = false;
        }
        field(710; CanTenantSelectDate; Boolean)
        {
            Caption = 'Can Tenant Select Date';
            ToolTip = 'Indicates if a new update date can be selected.';
            ObsoleteReason = 'Replaced by flexible update logic and related fields.';
#if not CLEAN29
            ObsoleteState = Pending;
            ObsoleteTag = '27.2';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
        }
        field(715; DidTenantSelectDate; Boolean)
        {
            Caption = 'Did Tenant Select Date';
            ToolTip = 'Indicates if the tenant has selected the current date for the update.';
            ObsoleteReason = 'Replaced by flexible update logic and related fields.';
#if not CLEAN29
            ObsoleteState = Pending;
            ObsoleteTag = '27.2';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
        }
        field(720; EarliestSelectableUpgradeDate; Date)
        {
            Caption = 'Earliest Selectable Upgrade Date';
            ToolTip = 'Specifies the earliest date that can be chosen for the update.';
            ObsoleteReason = 'Replaced by flexible update logic and related fields.';
#if not CLEAN29
            ObsoleteState = Pending;
            ObsoleteTag = '27.2';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
        }
        field(730; LatestSelectableUpgradeDate; Date)
        {
            Caption = 'Latest Selectable Upgrade Date';
            ToolTip = 'Specifies the latest date that can be chosen for the update.';
            ObsoleteReason = 'Replaced by flexible update logic and related fields.';
#if not CLEAN29
            ObsoleteState = Pending;
            ObsoleteTag = '27.2';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
        }
        field(740; UpgradeDate; Date)
        {
            Caption = 'Upgrade Date';
            ToolTip = 'The currently selected scheduled date of the update.';
            ObsoleteReason = 'Replaced by flexible update logic and related fields.';
#if not CLEAN29
            ObsoleteState = Pending;
            ObsoleteTag = '27.2';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
        }
        field(741; UpdateDate; Date)
        {
            Caption = 'Update Date';
            FieldClass = FlowField;
            CalcFormula = lookup(TKAManagedBCEnvAvailUpdate.SelectedDate where(TenantId = field(TenantId), EnvironmentName = field(Name), Selected = const(true)));
            ToolTip = 'Specifies the date for which the update to the selected target version has been scheduled.';
            Editable = false;
        }
        field(750; UpdateStatus; Text[20])
        {
            Caption = 'Update Status';
            ToolTip = 'The current status of the environment''s update.';
            ObsoleteReason = 'Replaced by flexible update logic and related fields.';
#if not CLEAN29
            ObsoleteState = Pending;
            ObsoleteTag = '27.2';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
        }
        field(760; IgnoreUpgradeWindow; Boolean)
        {
            Caption = 'Ignore Upgrade Window';
            ToolTip = 'Indicates if the environment''s update window will be ignored.';
            ObsoleteReason = 'Replaced by flexible update logic and related fields.';
#if not CLEAN29
            ObsoleteState = Pending;
            ObsoleteTag = '27.2';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
        }
        field(761; IgnoreScheduleUpgradeWindow; Boolean)
        {
            Caption = 'Ignore Scheduled Upgrade Window';
            FieldClass = FlowField;
            CalcFormula = lookup(TKAManagedBCEnvAvailUpdate.IgnoreUpdateWindow where(TenantId = field(TenantId), EnvironmentName = field(Name), Selected = const(true)));
            ToolTip = 'Specifies whether the environment is set to ignore the update window for the scheduled update.';
            Editable = false;
        }
        field(770; UpdateIsActive; Boolean)
        {
            Caption = 'Update Is Active';
            ToolTip = 'Indicates if the update is activated and is scheduled to occur.';
            ObsoleteReason = 'Replaced by flexible update logic and related fields.';
#if not CLEAN29
            ObsoleteState = Pending;
            ObsoleteTag = '27.2';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#endif
        }
        field(771; UpdateIsScheduled; Boolean)
        {
            Caption = 'Update Is Scheduled';
            FieldClass = FlowField;
            CalcFormula = exist(TKAManagedBCEnvAvailUpdate where(TenantId = field(TenantId), EnvironmentName = field(Name), Selected = const(true)));
            ToolTip = 'Specifies if an update is scheduled for the environment.';
            Editable = false;
        }
        field(780; PreferredStartTime; Text[50])
        {
            Caption = 'Preferred Start Time';
            ToolTip = 'Start of environment update window in 24h format (HH:mm).';
        }
        field(781; PreferredEndTime; Text[50])
        {
            Caption = 'Preferred End Time';
            ToolTip = 'End of environment update window in 24h format (HH:mm).';
        }
        field(785; PreferredStartTimeUtc; Text[50])
        {
            Caption = 'Preferred Start Time UTC';
            ToolTip = 'Start of environment update window in 24h format (HH:mm).';
        }
        field(786; PreferredEndTimeUtc; Text[50])
        {
            Caption = 'Preferred End Time UTC';
            ToolTip = 'End of environment update window in 24h format (HH:mm).';
        }
        field(790; TimeZoneId; Text[100])
        {
            Caption = 'Time Zone Id';
            TableRelation = TKAAvailableUpdateTimezone.Name;
            ToolTip = 'Windows time zone identifier. Supported by API version 2.13 and later only.';
        }
        field(1000; EnvironmentModifiedAt; DateTime)
        {
            Caption = 'Environment Modified At';
            Editable = false;
            ToolTip = 'Specifies the date and time when the environment was last modified.';
        }
    }

    keys
    {
        key(PK; "TenantId", "Name")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; TenantId, Name) { }
        fieldgroup(Brick; TenantId, Name) { }
    }

    trigger OnDelete()
    var
        ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp;
    begin
        ManagedBCEnvironmentApp.ReadIsolation(IsolationLevel::ReadUncommitted);
        ManagedBCEnvironmentApp.SetRange(TenantId, TenantId);
        ManagedBCEnvironmentApp.SetRange(Name, Name);
        ManagedBCEnvironmentApp.DeleteAll(true);
    end;

    /// <summary>
    /// Get the Managed BC Tenant record for the Managed BC Environment.
    /// </summary>
    /// <returns>The Managed BC Tenant record.</returns>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCTenant, 'R')]
    procedure GetManagedBCTenant() ManagedBCTenant: Record TKAManagedBCTenant
    begin
        ManagedBCTenant.Get(Rec.TenantId);
    end;

    /// <summary>
    /// Check if the tenant's group is active.
    /// </summary>
    /// <returns>True if the tenant's group is active or if no group is assigned; otherwise, false.</returns>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCTenantGroup, 'R')]
    procedure IsTenantGroupActive(): Boolean
    begin
        exit(GetManagedBCTenant().IsTenantGroupActive());
    end;
}