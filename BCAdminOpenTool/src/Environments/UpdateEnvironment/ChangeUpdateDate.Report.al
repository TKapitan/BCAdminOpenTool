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
                    field(ChangeUpdateDateField; ChangeUpdateDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Change Update Date';
                        ToolTip = 'Specifies if the update date should be changed.';
                    }
                    field(NewUpdateDateField; NewUpdateDate)
                    {
                        ApplicationArea = All;
                        Caption = 'New Update Date';
                        Editable = ChangeUpdateDate;
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
    }

    trigger OnPostReport()
    var
        ChangeUpdateDateImpl: Codeunit TKAChangeUpdateDateImpl;
        NothingToChangeErr: Label 'At least one of the fields "Change Update Date" or "Change Ignore Upgrade Window" must be set to Yes.';
        NewUpdateDateMustHaveValueErr: Label 'The field "New Update Date" must have a value.';
    begin
        if not ChangeIgnoreUpgradeWindow and not ChangeUpdateDate then
            Error(NothingToChangeErr);
        if ChangeUpdateDate and (NewUpdateDate = 0D) then
            Error(NewUpdateDateMustHaveValueErr);

        ChangeUpdateDateImpl.RunChangeUpdateDate(ManagedBCEnvironment, ChangeUpdateDate, NewUpdateDate, ChangeIgnoreUpgradeWindow, NewIgnoreUpgradeWindow);
    end;

    var
        ManagedBCEnvironment: Record TKAManagedBCEnvironment;
        ChangeUpdateDate, ChangeIgnoreUpgradeWindow : Boolean;
        NewUpdateDate: Date;
        NewIgnoreUpgradeWindow: Boolean;

    /// <summary>
    /// Sets the environments to update.
    /// </summary>
    /// <param name="NewManagedBCEnvironment">Filtered managed BC environment record.</param>
    procedure SetEnvironmentsToUpdate(var NewManagedBCEnvironment: Record TKAManagedBCEnvironment)
    begin
        ManagedBCEnvironment.Copy(NewManagedBCEnvironment);
    end;
}