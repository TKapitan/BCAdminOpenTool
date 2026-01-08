#pragma warning disable LC0023 // Fieldgroups for setup are not useful
table 73272 TKAAdminCenterAPISetup
#pragma warning restore LC0023
{
    Caption = 'Admin Center API Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = TKAAdminCenterAPISetup;
    LookupPageId = TKAAdminCenterAPISetup;

    fields
    {
        field(1; PrimaryKey; Code[10])
        {
            AllowInCustomizations = Never;
            Caption = 'Primary Key';
            NotBlank = false;
        }
        field(10; TokenUrl; Text[500])
        {
            Caption = 'Token Url';
            ToolTip = 'Specifies the Token URL for the Admin Center API.';
        }
        field(20; Scope; Text[2048])
        {
            Caption = 'Scope';
            ToolTip = 'Specifies the scope for the Admin Center API.';
        }
        field(50; APIUrl; Text[500])
        {
            Caption = 'API Url';
            ToolTip = 'Specifies the API URL for the Admin Center API.';
        }
        field(55; APIVersion; Enum TKAAdminCenterAPIVersion)
        {
            Caption = 'API Version';
            ToolTip = 'Specifies the API version for the Admin Center API.';
        }
        field(100; GetScheduledUpdateAPIEnabled; Boolean)
        {
            Caption = 'Get Scheduled Update API Enabled';
            ToolTip = 'Specifies whether the Get Scheduled Update API is enabled.';
        }
        field(105; GetUpdateSettingsAPIEnabled; Boolean)
        {
            Caption = 'Get Update Settings API Enabled';
            ToolTip = 'Specifies whether the Get Update Settings API is enabled.';
        }
        field(110; GetInstalledAppsEnabled; Boolean)
        {
            Caption = 'Get Installed Apps API Enabled';
            ToolTip = 'Specifies whether the Get Installed Apps API is enabled.';
        }
        field(300; OurPublisherName; Text[100])
        {
            Caption = 'Our Publisher Name';
            ToolTip = 'Specifies the publisher name for our apps.';
        }
        field(305; ExcludeHiddedApps; Boolean)
        {
            Caption = 'Exclude Hidded Apps';
            ToolTip = 'Specifies whether to exclude hidden apps from the list of installed apps. Hidden apps are apps with name starting with "_Exclude".';
        }

    }

    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }

    var
        RecordHasBeenRead: Boolean;

    /// <summary>
    /// Get the record. If the record has already been read, do nothing.
    /// </summary>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAAdminCenterAPISetup, 'R')]
    procedure GetRecordOnce()
    begin
        if RecordHasBeenRead then
            exit;
        Rec.InsertIfNotExists();
        RecordHasBeenRead := true;
    end;

    /// <summary>
    /// Insert the record if it does not exist, otherwise get the record.
    /// </summary>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAAdminCenterAPISetup, 'RI')]
    procedure InsertIfNotExists()
    var
        TokenUrlTok: Label 'https://login.microsoftonline.com/%1/oauth2/v2.0/token', Locked = true;
        ScopeTok: Label 'https://api.businesscentral.dynamics.com/.default', Locked = true;
        APIBaseUrlTok: Label 'https://api.businesscentral.dynamics.com/admin/', Locked = true;
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Validate(TokenUrl, TokenUrlTok);
            Rec.Validate(Scope, ScopeTok);
            Rec.Validate(APIUrl, APIBaseUrlTok);
            Rec.Validate(APIVersion, Rec.APIVersion::"v2.28");
            Rec.Validate(ExcludeHiddedApps, true);
            Rec.Validate(GetScheduledUpdateAPIEnabled, true);
            Rec.Validate(GetUpdateSettingsAPIEnabled, true);
            Rec.Validate(GetInstalledAppsEnabled, true);
            Rec.Insert(true);
        end;
    end;
}