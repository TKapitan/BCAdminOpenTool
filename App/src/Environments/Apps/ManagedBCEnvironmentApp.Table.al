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
        field(3; ID; Guid)
        {
            Caption = 'App ID';
            ToolTip = 'Specifies the unique identifier of the app.';
            NotBlank = true;
            Editable = false;
        }
        field(10; Name; Text[250])
        {
            Caption = 'App Name';
            ToolTip = 'Specifies the name of the app.';
            Editable = false;
        }
        field(11; Publisher; Text[250])
        {
            Caption = 'Publisher';
            ToolTip = 'Specifies the publisher of the app.';
            Editable = false;
        }
        field(12; Version; Text[30])
        {
            Caption = 'Version';
            ToolTip = 'Specifies the version of the app.';
            Editable = false;
        }
        field(13; State; Text[20])
        {
            Caption = 'State';
            ToolTip = 'Specifies the current state of the app.';
            Editable = false;
        }
        field(14; LastOperationId; Guid)
        {
            Caption = 'Last Operation ID';
            ToolTip = 'Specifies the ID of the last operation performed on the app.';
            Editable = false;
        }
        field(15; LastUpdateAttemptResult; Text[20])
        {
            Caption = 'Last Update Attempt Result';
            ToolTip = 'Specifies the result of the last update attempt for the app.';
            Editable = false;
        }
        field(20; InstalledOn; DateTime)
        {
            Caption = 'Installed On';
            ToolTip = 'Specifies the date and time when the app was installed. This information is not available in API response. It is calculated for apps that are downloaded only in second or subsequent calls.';
            Editable = false;
        }
        field(30; WhitelistedThirdPartyApp; Boolean)
        {
            Caption = 'Whitelisted Third Party App';
            ToolTip = 'Specifies whether the app is a whitelisted third party app.';
            Editable = false;
        }
        field(35; WhitelistedThirdPartyAppForEnv; Boolean)
        {
            Caption = 'Whitelisted Third Party App for Environment';
            ToolTip = 'Specifies whether the app is a whitelisted third party app for the environment.';

            trigger OnValidate()
            var
                ExistingWhitelistedThirdPartyApp: Record TKAWhitelistedThirdPartyApp;
            begin
                if ExistingWhitelistedThirdPartyApp.Get(Rec.ID) then
                    exit;
                Rec.WhitelistedThirdPartyApp := Rec.WhitelistedThirdPartyAppForEnv;
            end;
        }
        field(50; Hidden; Boolean)
        {
            AllowInCustomizations = AsReadOnly;
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

    trigger OnInsert()
    var
        ExistingWhitelistedThirdPartyApp: Record TKAWhitelistedThirdPartyApp;
    begin
        if ExistingWhitelistedThirdPartyApp.Get(Rec.ID) then
            Rec.Validate(WhitelistedThirdPartyApp, true);
    end;

    trigger OnRename()
    var
        RecordCannotBeRenamedErr: Label 'Record cannot be renamed.';
    begin
        Error(RecordCannotBeRenamedErr);
    end;

    procedure AddToWhitelistedApps()
    var
        NewWhitelistedThirdPartyApp: Record TKAWhitelistedThirdPartyApp;
    begin
        if NewWhitelistedThirdPartyApp.Get(Rec.ID) then
            exit; // Already whitelisted
        NewWhitelistedThirdPartyApp.Init();
        NewWhitelistedThirdPartyApp.Validate(AppId, Rec.ID);
        NewWhitelistedThirdPartyApp.Validate(Publisher, Rec.Publisher);
        NewWhitelistedThirdPartyApp.Validate(Name, Rec.Name);
        NewWhitelistedThirdPartyApp.Insert(true);
    end;
}