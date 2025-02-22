table 73271 TKAManagedBCAdministrationApp
{
    Caption = 'Managed BC Administratior App';
    DataClassification = CustomerContent;
    DrillDownPageId = TKAManagedBCAdministrationApps;
    LookupPageId = TKAManagedBCAdministrationApps;

    fields
    {
        field(1; ClientId; Guid)
        {
            Caption = 'Client ID';
            ToolTip = 'Specifies the client ID for the app.';
        }
        field(5; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the app.';
        }
        field(20; ClientSecretID; Guid)
        {
            AllowInCustomizations = Never;
            Caption = 'Client Secret';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(PK; ClientId)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Name, ClientId) { }
        fieldgroup(Brick; Name, ClientId) { }
    }

    #region Triggers

    trigger OnDelete()
    begin
        TestNotUsed();
        ClearIsolatedField(Rec.ClientSecretID);
    end;

    #endregion Triggers
    #region "Global Procedures"

    /// <summary>
    /// Save the client secret to isolated storage and generate ClientSecretID if it is not set.
    /// </summary>
    /// <param name="NewClientSecret">New client secret to store to isolated storage</param>
    procedure SetClientSecret(NewClientSecret: SecretText)
    var
        SecretSet: Boolean;
        NonTemporaryOnlyErr: Label 'SetSecret with SecretText parameter can be called only for non-temporary records and for authentications not marked as temporary.';
    begin
        if Rec.IsTemporary() then
            Error(NonTemporaryOnlyErr);

        if NewClientSecret.IsEmpty() then begin
            ClearIsolatedField(Rec.ClientSecretID);
            exit;
        end;

        if IsNullGuid(Rec.ClientSecretID) then
            Rec.ClientSecretID := CreateGuid();

        SecretSet := false;
        if EncryptionKeyExists() then
            SecretSet := IsolatedStorage.SetEncrypted(Rec.ClientSecretID, NewClientSecret, DataScope::Company);
        if not SecretSet then
            IsolatedStorage.Set(Rec.ClientSecretID, NewClientSecret, DataScope::Company);
    end;

    /// <summary>
    /// Get the client secret from isolated storage as secret text.
    /// </summary>
    /// <returns>Client secret as secret text</returns>
    [NonDebuggable]
    procedure GetClientSecretAsSecretText() Value: SecretText
    begin
        if IsNullGuid(Rec.ClientSecretID) then
            exit;
        if not IsolatedStorage.Get(Rec.ClientSecretID, DataScope::Company, Value) then
            Clear(Value);
    end;

    #endregion "Global Procedures"
    #region "Local Procedures"

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCTenant, 'R')]
    local procedure TestNotUsed()
    var
        ManagedBCTenant: Record TKAManagedBCTenant;
        TheBCAdminAppIsUsedErr: Label 'The app is configured for a tenant and cannot be deleted.';
    begin
        ManagedBCTenant.ReadIsolation(IsolationLevel::ReadCommitted);
        ManagedBCTenant.SetRange(ClientId, Rec.ClientId);
        if not ManagedBCTenant.IsEmpty() then
            Error(TheBCAdminAppIsUsedErr);
    end;

    local procedure ClearIsolatedField(var IsolatedGuid: Guid)
    begin
        if not IsNullGuid(IsolatedGuid) then begin
            if IsolatedStorage.Contains(IsolatedGuid, DataScope::Company) then
                IsolatedStorage.Delete(IsolatedGuid, DataScope::Company);
            Clear(IsolatedGuid);
        end;
    end;

    #endregion "Local Procedures"
}