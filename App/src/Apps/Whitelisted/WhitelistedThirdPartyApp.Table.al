table 73279 TKAWhitelistedThirdPartyApp
{
    Caption = 'Whitelisted Third Party App';
    DataClassification = CustomerContent;
    DrillDownPageId = TKAWhitelistedThirdPartyApps;
    LookupPageId = TKAWhitelistedThirdPartyApps;

    fields
    {
        field(1; AppId; Guid)
        {
            Caption = 'AppId';
            NotBlank = true;
            ToolTip = 'Specifies the unique identifier of the app.';

            trigger OnValidate()
            begin
                TryPopulateAppDetails();
            end;
        }
        field(10; Publisher; Text[250])
        {
            Caption = 'Publisher';
            ToolTip = 'Specifies the publisher of the app.';
        }
        field(25; Name; Text[250])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the app.';
        }
        field(50; Comment; Text[500])
        {
            Caption = 'Comment';
            ToolTip = 'Specifies a comment about the whitelisted app.';
        }
    }

    keys
    {
        key(PK; "AppId")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Publisher, Name, AppId) { }
        fieldgroup(Brick; Publisher, Name, AppId) { }
    }

    trigger OnInsert()
    var
        ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp;
    begin
        ManagedBCEnvironmentApp.SetRange(ID, AppId);
        ManagedBCEnvironmentApp.ModifyAll(WhitelistedThirdPartyApp, true, true);
    end;

    trigger OnRename()
    var
        RecordCannotBeRenamedErr: Label 'Record cannot be renamed.';
    begin
        Error(RecordCannotBeRenamedErr);
    end;

    trigger OnDelete()
    var
        ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp;
    begin
        ManagedBCEnvironmentApp.SetRange(ID, AppId);
        ManagedBCEnvironmentApp.ModifyAll(WhitelistedThirdPartyApp, false, true);
    end;

    local procedure TryPopulateAppDetails()
    var
        ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp;
    begin
        ManagedBCEnvironmentApp.SetRange(ID, AppId);
        if not ManagedBCEnvironmentApp.FindFirst() then
            exit;
        Publisher := ManagedBCEnvironmentApp.Publisher;
        Name := ManagedBCEnvironmentApp.Name;
    end;
}