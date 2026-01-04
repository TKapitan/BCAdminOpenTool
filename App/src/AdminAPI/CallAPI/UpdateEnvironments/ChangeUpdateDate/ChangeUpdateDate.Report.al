#if not CLEAN29
report 73270 TKAChangeUpdateDate
{
    ApplicationArea = All;
    Caption = 'Change Update Date';
    ProcessingOnly = true;
    UsageCategory = None;
    ObsoleteReason = 'Replaced by flexible update logic and related fields.';
    ObsoleteState = Pending;
    ObsoleteTag = '27.2';

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    Caption = 'General';
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
    }

    trigger OnPostReport()
    var
        ChangeUpdateDateImpl: Codeunit TKAChangeUpdateDateImpl;
        NewUpdateDateMustHaveValueErr: Label 'The field "New Update Date" must have a value.';
    begin
        if NewUpdateDate = 0D then
            Error(NewUpdateDateMustHaveValueErr);
        ChangeUpdateDateImpl.RunChangeUpdateDate(ManagedBCEnvironment, NewUpdateDate, ChangeIgnoreUpgradeWindow, NewIgnoreUpgradeWindow);
    end;

    var
        ManagedBCEnvironment: Record TKAManagedBCEnvironment;
        ChangeIgnoreUpgradeWindow: Boolean;
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
#endif