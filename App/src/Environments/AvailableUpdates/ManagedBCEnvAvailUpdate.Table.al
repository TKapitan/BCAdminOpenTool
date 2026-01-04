table 73280 TKAManagedBCEnvAvailUpdate
{
    Caption = 'Managed BC Environment Available Update';
    DataClassification = CustomerContent;
    DrillDownPageId = TKAManagedBCEnvAvailUpdates;
    LookupPageId = TKAManagedBCEnvAvailUpdates;

    fields
    {
        field(1; TenantId; Guid)
        {
            Caption = 'Tenant ID';
            TableRelation = TKAManagedBCTenant.TenantId;
            ToolTip = 'Specifies the unique identifier of the tenant.';
            NotBlank = true;
            Editable = false;
        }
        field(2; EnvironmentName; Text[100])
        {
            Caption = 'Environment Name';
            TableRelation = TKAManagedBCEnvironment.Name where(TenantId = field(TenantId));
            ToolTip = 'Specifies the name of the Business Central environment.';
            NotBlank = true;
            Editable = false;
        }
        field(3; TargetVersion; Code[20])
        {
            Caption = 'Target Version';
            ToolTip = 'Specifies the target version of the available update.';
            NotBlank = true;
            Editable = false;
        }
        field(5; TargetVersionType; Code[20])
        {
            Caption = 'Target Version Type';
            ToolTip = 'Specifies the type of the target version.';
            Editable = false;
        }
        field(10; Available; Boolean)
        {
            Caption = 'Available';
            ToolTip = 'Specifies whether the target version has been released.';
            Editable = false;
        }
        field(15; Selected; Boolean)
        {
            Caption = 'Selected';
            ToolTip = 'Specifies whether the next selected update is for this target version.';
            Editable = false;
        }
        field(25; LatestSelectableDate; Date)
        {
            Caption = 'Latest Selectable Date';
            ToolTip = 'Specifies the last date for which the update to this target version can be scheduled.';
            Editable = false;
        }
        field(30; SelectedDate; Date)
        {
            Caption = 'Selected Date';
            ToolTip = 'Specifies the date for which the update to this target version has been scheduled.';
            Editable = false;
        }
        field(40; IgnoreUpdateWindow; Boolean)
        {
            Caption = 'Ignore Update Window';
            ToolTip = 'Specifies whether the update window for the environment may be ignored when running this update.';
            Editable = false;
        }
        field(50; RolloutStatus; Text[50])
        {
            Caption = 'Rollout Status';
            ToolTip = 'Specifies the rollout status of updates to this target version.';
            Editable = false;
        }
        field(75; ExpectedAvailabilityMonth; Integer)
        {
            Caption = 'Expected Availability Month';
            ToolTip = 'Specifies the number of the month in which the target version is expected to be released.';
            Editable = false;
            AllowInCustomizations = AsReadOnly;
        }
        field(80; ExpectedAvailabilityYear; Integer)
        {
            Caption = 'Expected Availability Year';
            ToolTip = 'Specifies the year in which the target version is expected to be released.';
            Editable = false;
            AllowInCustomizations = AsReadOnly;
        }
        field(85; ExpectedAvailability; Text[10])
        {
            Caption = 'Expected Availability';
            ToolTip = 'Specifies the expected availability of the target version in YYYY/MM format.';
            Editable = false;
        }
    }

    keys
    {
        key(PK; TenantId, EnvironmentName, TargetVersion)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; EnvironmentName, TargetVersion, Available) { }
        fieldgroup(Brick; EnvironmentName, TargetVersion, Available, Selected, SelectedDate) { }
    }

    trigger OnRename()
    var
        RecordCannotBeRenamedErr: Label 'Record cannot be renamed.';
    begin
        Error(RecordCannotBeRenamedErr);
    end;
}