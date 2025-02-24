table 73274 TKAAvailableUpdateTimezone
{
    Caption = 'Available Update Timezone';
    DataClassification = CustomerContent;
    DrillDownPageId = TKAAvailableUpdateTimezones;
    LookupPageId = TKAAvailableUpdateTimezones;

    fields
    {
        field(1; Name; Text[100])
        {
            Caption = 'Name';
            NotBlank = true;
            ToolTip = 'Specifies the name of the timezone.';
        }
        field(5; DisplayName; Text[100])
        {
            Caption = 'Display Name';
            ToolTip = 'Specifies the display name of the timezone.';
        }
        field(10; CurrentUtcOffset; Text[20])
        {
            Caption = 'Current UTC Offset';
            ToolTip = 'Specifies the current UTC offset of the timezone.';
        }
        field(20; SupportsDaylightSavingTime; Boolean)
        {
            Caption = 'Supports Daylight Saving Time';
            ToolTip = 'Specifies whether the timezone supports daylight saving time.';
        }
        field(30; IsCurrentlyDaylightSavingTime; Boolean)
        {
            Caption = 'Is Currently Daylight Saving Time';
            ToolTip = 'Specifies whether the timezone is currently in daylight saving time.';
        }
    }

    keys
    {
        key(PK; "Name")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Name, DisplayName) { }
        fieldgroup(Brick; Name, DisplayName) { }
    }
}