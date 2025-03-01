table 73276 TKAManagedBCEnvironmentApp
{
    Caption = 'Managed BC Environment App';
    DataClassification = CustomerContent;
    DrillDownPageId = TKAManagedBCEnvironmentApps;
    LookupPageId = TKAManagedBCEnvironmentApps;

    fields
    {
        field(1; TenantId; Guid)
        {
            Caption = 'Tenant ID';
            TableRelation = TKAManagedBCTenant.TenantId;
            ToolTip = 'Specifies the unique identifier of the tenant.';
        }
        field(2; EnvironmentName; Text[100])
        {
            Caption = 'Environment Name';
            TableRelation = TKAManagedBCEnvironment.Name where(TenantId = field(TenantId));
            ToolTip = 'Specifies the name of the Business Central environment.';
        }
        field(3; ID; Guid)
        {
            Caption = 'App ID';
            ToolTip = 'Specifies the unique identifier of the app.';
        }
        field(10; Name; Text[250])
        {
            Caption = 'App Name';
            ToolTip = 'Specifies the name of the app.';
        }
        field(11; Publisher; Text[250])
        {
            Caption = 'Publisher';
            ToolTip = 'Specifies the publisher of the app.';
        }
        field(12; Version; Text[30])
        {
            Caption = 'Version';
            ToolTip = 'Specifies the version of the app.';
        }
        field(13; State; Text[20])
        {
            Caption = 'State';
            ToolTip = 'Specifies the current state of the app.';
        }
        field(14; LastOperationId; Guid)
        {
            Caption = 'Last Operation ID';
            ToolTip = 'Specifies the ID of the last operation performed on the app.';
        }
        field(15; LastUpdateAttemptResult; Text[20])
        {
            Caption = 'Last Update Attempt Result';
            ToolTip = 'Specifies the result of the last update attempt for the app.';
        }
        field(20; InstalledOn; DateTime)
        {
            Caption = 'Installed On';
            ToolTip = 'Specifies the date and time when the app was installed. This information is not available in API response. It is calculated for apps that are downloaded only in second or subsequent calls.';
        }
        field(50; Hidden; Boolean)
        {
            AllowInCustomizations = Always;
            Caption = 'Hidden';
            Editable = false;
            ToolTip = 'Specifies whether the app is hidden. Apps that have name starting with "_Exclude" are hidden.';
        }
    }

    keys
    {
        key(PK; TenantId, EnvironmentName, ID)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Name, Publisher, Version, State) { }
        fieldgroup(Brick; Name, Publisher, Version, State) { }
    }
}