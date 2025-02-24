report 73271 TKAChangeUpdateSettings
{
    ApplicationArea = All;
    Caption = 'Change Update Settings';
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
                    field(PreferredStartTimeField; NewPreferredStartTime)
                    {
                        ApplicationArea = All;
                        Caption = 'Preferred Start Time';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the new preferred start time.';
                    }
                    field(PreferredEndTimeField; NewPreferredEndTime)
                    {
                        ApplicationArea = All;
                        Caption = 'Preferred End Time';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the new preferred end time.';
                    }
                    field(TimeZoneIdField; NewTimeZoneId)
                    {
                        ApplicationArea = All;
                        Caption = 'Time Zone Id';
                        ShowMandatory = true;
                        TableRelation = TKAAvailableUpdateTimezone.Name;
                        ToolTip = 'Specifies the new time zone id.';
                    }
                }
            }
        }
    }

    trigger OnPostReport()
    var
        ChangeUpdateSettingsImpl: Codeunit TKAChangeUpdateSettingsImpl;
        AllFieldMandatoryErr: Label 'All fields are mandatory.';
    begin
        if (NewPreferredStartTime = 0T) or (NewPreferredEndTime = 0T) then
            Error(AllFieldMandatoryErr);
        if NewTimeZoneId = '' then
            Error(AllFieldMandatoryErr);

        ChangeUpdateSettingsImpl.RunChangeUpdateDate(ManagedBCEnvironment, NewPreferredStartTime, NewPreferredEndTime, NewTimeZoneId);
    end;

    var
        ManagedBCEnvironment: Record TKAManagedBCEnvironment;
        NewPreferredStartTime, NewPreferredEndTime : Time;
        NewTimeZoneId: Text[100];

    /// <summary>
    /// Sets the environments to update.
    /// </summary>
    /// <param name="NewManagedBCEnvironment">Filtered managed BC environment record.</param>
    procedure SetEnvironmentsToUpdate(var NewManagedBCEnvironment: Record TKAManagedBCEnvironment)
    begin
        ManagedBCEnvironment.Copy(NewManagedBCEnvironment);
    end;
}