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
        field(10; AuthUrl; Text[500])
        {
            Caption = 'Authentication Url';
            ToolTip = 'Specifies the authentication URL for the Admin Center API.';
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
        Rec.Get();
        RecordHasBeenRead := true;
    end;

    /// <summary>
    /// Insert the record if it does not exist, otherwise get the record.
    /// </summary>
    procedure InsertIfNotExists()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert(true);
        end;
    end;
}