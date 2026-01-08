report 73270 TKAChangeUpdateDate
{
    ApplicationArea = All;
    Caption = 'Change Update Date';
    ProcessingOnly = true;
    UsageCategory = None;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    Caption = 'General';
                    field(SelectedVersionCodeField; SelectedVersionCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Update to Version';
                        ToolTip = 'Specifies the target version to which the update will be scheduled.';
#if not CLEAN29
#pragma warning disable AL0432
                        Visible = not UseLegacyUpdateStructure;
#pragma warning restore AL0432
#endif

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            AvailableUpdatesLookup: Page TKAAvailableUpdatesLookup;
                        begin
                            PrepareAvailableTargetVersionLookup();
                            AvailableUpdatesLookup.SetRecordToShow(TempManagedBCEnvAvailUpdate);
                            AvailableUpdatesLookup.LookupMode(true);
                            if AvailableUpdatesLookup.RunModal() <> Action::LookupOK then
                                exit;
                            AvailableUpdatesLookup.GetRecord(TempManagedBCEnvAvailUpdate);
                            SelectedVersionCode := TempManagedBCEnvAvailUpdate.TargetVersion;
                        end;

                        trigger OnValidate()
                        var
                            TempManagedBCEnvAvailUpdate2: Record TKAManagedBCEnvAvailUpdate temporary;
                            TargetVersionNotValidErr: Label 'Selected target version is not valid.';
                        begin
                            TempManagedBCEnvAvailUpdate2.Copy(TempManagedBCEnvAvailUpdate, true);
                            TempManagedBCEnvAvailUpdate2.SetRange(TargetVersion, SelectedVersionCode);
                            if TempManagedBCEnvAvailUpdate2.IsEmpty() then
                                Error(TargetVersionNotValidErr);
                        end;
                    }
                    field(NewUpdateDateField; NewUpdateDate)
                    {
                        ApplicationArea = All;
                        Caption = 'New Update Date';
                        ToolTip = 'Specifies the new update date.';
                    }
                    field(ChangeIgnoreUpgradeWindowField; ChangeIgnoreUpgradeWindow)
                    {
                        ApplicationArea = All;
                        Caption = 'Change Ignore Upgrade Window';
                        ToolTip = 'Specifies if the upgrade window should be ignored.';
                    }
                    field(NewIgnoreUpgradeWindowField; NewIgnoreUpgradeWindow)
                    {
                        ApplicationArea = All;
                        Caption = 'New Ignore Upgrade Window';
                        Editable = ChangeIgnoreUpgradeWindow;
                        ToolTip = 'Specifies the new value for ignoring the upgrade window.';
                    }
                }
            }
        }

#if not CLEAN29
        trigger OnQueryClosePage(CloseAction: Action): Boolean
        var
            ChangeUpdateDateImpl: Codeunit TKAChangeUpdateDateImpl;
            NewUpdateDateMustHaveValueErr: Label 'The field "New Update Date" must have a value.';
        begin
            if not (CloseAction in [Action::OK, Action::LookupOK]) then
                exit(true);
#pragma warning disable AL0432
            if UseLegacyUpdateStructure then begin
                if NewUpdateDate = 0D then
                    Error(NewUpdateDateMustHaveValueErr)
#pragma warning restore AL0432
            end else
                ChangeUpdateDateImpl.ValidateVersion(ManagedBCEnvironment, SelectedVersionCode, TempManagedBCEnvAvailUpdate, NewUpdateDate);
            exit(true);
        end;
#else
        trigger OnQueryClosePage(CloseAction: Action): Boolean
        var
            ChangeUpdateDateImpl: Codeunit TKAChangeUpdateDateImpl;
        begin
            ChangeUpdateDateImpl.ValidateVersion(ManagedBCEnvironment, SelectedVersionCode, TempManagedBCEnvAvailUpdate, NewUpdateDate);
        end;
#endif
    }

#if not CLEAN29
    trigger OnInitReport()
    var
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
    begin
#pragma warning disable AL0432
        UseLegacyUpdateStructure := false;
        AdminCenterAPISetup.ReadIsolation(IsolationLevel::ReadUncommitted);
        AdminCenterAPISetup.SetLoadFields(APIVersion);
        AdminCenterAPISetup.Get();
        UseLegacyUpdateStructure := AdminCenterAPISetup.APIVersion = AdminCenterAPISetup.APIVersion::"v2.24";
#pragma warning restore AL0432
    end;

    trigger OnPostReport()
    var
        ChangeUpdateDateImpl: Codeunit TKAChangeUpdateDateImpl;
        NewUpdateDateMustHaveValueErr: Label 'The field "New Update Date" must have a value.';
    begin
#pragma warning disable AL0432
        if UseLegacyUpdateStructure then begin
            if NewUpdateDate = 0D then
                Error(NewUpdateDateMustHaveValueErr);
            ChangeUpdateDateImpl.RunChangeUpdateDate(ManagedBCEnvironment, NewUpdateDate, ChangeIgnoreUpgradeWindow, NewIgnoreUpgradeWindow);
#pragma warning restore AL0432
        end else
            ChangeUpdateDateImpl.RunChangeUpdateDate(TempManagedBCEnvAvailUpdate, ManagedBCEnvironment, NewUpdateDate, ChangeIgnoreUpgradeWindow, NewIgnoreUpgradeWindow);
    end;
#else
    trigger OnPostReport()
    var
        ChangeUpdateDateImpl: Codeunit TKAChangeUpdateDateImpl;
    begin
        ChangeUpdateDateImpl.RunChangeUpdateDate(TempManagedBCEnvAvailUpdate, ManagedBCEnvironment, NewUpdateDate, ChangeIgnoreUpgradeWindow, NewIgnoreUpgradeWindow);
    end;
#endif

    var
        TempManagedBCEnvAvailUpdate: Record TKAManagedBCEnvAvailUpdate temporary;
        ManagedBCEnvironment: Record TKAManagedBCEnvironment;
        ChangeIgnoreUpgradeWindow: Boolean;
        NewUpdateDate: Date;
        NewIgnoreUpgradeWindow: Boolean;
        SelectedVersionCode: Code[20];
#if not CLEAN29
        [Obsolete('Replaced by flexible update logic and related fields.', '27.2')]
        UseLegacyUpdateStructure: Boolean;
#endif

    /// <summary>
    /// Sets the environments to update.
    /// </summary>
    /// <param name="NewManagedBCEnvironment">Filtered managed BC environment record.</param>
    procedure SetEnvironmentsToUpdate(var NewManagedBCEnvironment: Record TKAManagedBCEnvironment)
    begin
        ManagedBCEnvironment.Copy(NewManagedBCEnvironment);
    end;

    local procedure PrepareAvailableTargetVersionLookup()
    var
        ManagedBCEnvAvailUpdate: Record TKAManagedBCEnvAvailUpdate;
        ProcessedFilter: Text;
    begin
        TempManagedBCEnvAvailUpdate.DeleteAll(false);

        ManagedBCEnvAvailUpdate.SetCurrentKey(TargetVersion);
        ManagedBCEnvAvailUpdate.SetRange(Available, true);
        AddTargetVersionToTempBuffer(ManagedBCEnvAvailUpdate, ProcessedFilter);
        ManagedBCEnvAvailUpdate.SetRange(Available, false);
        AddTargetVersionToTempBuffer(ManagedBCEnvAvailUpdate, ProcessedFilter);
    end;

    local procedure AddTargetVersionToTempBuffer(var ManagedBCEnvAvailUpdate: Record TKAManagedBCEnvAvailUpdate; var ProcessedFilter: Text)
    begin
        if ManagedBCEnvAvailUpdate.FindSet() then
            repeat
                if ProcessedFilter <> '' then
                    ProcessedFilter += '&';
                ProcessedFilter += StrSubstNo('<>%1', ManagedBCEnvAvailUpdate.TargetVersion);
                ManagedBCEnvAvailUpdate.SetFilter(TargetVersion, ProcessedFilter);

                if not IsUpdateAvailableForSelectedEnvironments(ManagedBCEnvAvailUpdate.TargetVersion) then
                    continue;

                TempManagedBCEnvAvailUpdate.TargetVersion := ManagedBCEnvAvailUpdate.TargetVersion;
                TempManagedBCEnvAvailUpdate.TargetVersionType := ManagedBCEnvAvailUpdate.TargetVersionType;
                TempManagedBCEnvAvailUpdate.Available := ManagedBCEnvAvailUpdate.Available;
                TempManagedBCEnvAvailUpdate.RolloutStatus := ManagedBCEnvAvailUpdate.RolloutStatus;
                TempManagedBCEnvAvailUpdate.LatestSelectableDate := ManagedBCEnvAvailUpdate.LatestSelectableDate;
                TempManagedBCEnvAvailUpdate.ExpectedAvailability := ManagedBCEnvAvailUpdate.ExpectedAvailability;
                TempManagedBCEnvAvailUpdate.Insert(false);
            until ManagedBCEnvAvailUpdate.Next() < 1;
    end;

    local procedure IsUpdateAvailableForSelectedEnvironments(TargetVersion: Code[20]): Boolean
    var
        ManagedBCEnvAvailUpdate: Record TKAManagedBCEnvAvailUpdate;
    begin
        if ManagedBCEnvironment.FindSet() then
            repeat
                ManagedBCEnvAvailUpdate.SetRange(TenantId, ManagedBCEnvironment.TenantId);
                ManagedBCEnvAvailUpdate.SetRange(EnvironmentName, ManagedBCEnvironment.Name);
                ManagedBCEnvAvailUpdate.SetRange(TargetVersion, TargetVersion);
                if ManagedBCEnvAvailUpdate.IsEmpty() then
                    exit(false);
            until ManagedBCEnvironment.Next() < 1;
        exit(true);
    end;
}