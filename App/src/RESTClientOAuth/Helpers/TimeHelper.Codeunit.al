codeunit 73296 TKATimeHelper
{
    /// <summary>
    /// Converts the given DateTime to a Unix epoch timestamp (number of seconds since January 1, 1970).
    /// </summary>
    /// <param name="ToDateTime">The DateTime to convert.</param>
    /// <returns>The Unix epoch timestamp as BigInteger.</returns>
    procedure GetEpochTimestamp(ToDateTime: DateTime) Timestamp: BigInteger
    var
        EpochStartDateTime: DateTime;
        CurrentDateTimeInUTC: DateTime;
    begin
#pragma warning disable AA0206 // This cop is broken in 26.4
        EpochStartDateTime := CreateDateTime(19700101D, 0T);
        CurrentDateTimeInUTC := GetDateTimeInUtc(ToDateTime);
#pragma warning restore AA0206

        // Calculate the number of milliseconds since the Unix epoch
        // We cannot substract the two DateTime values directly because the result is one hour off in Daylight Saving Time
        // Just adding one hour to the result is not a good solution because there are timezones with a 30 minutes offset
        Timestamp := ((CurrentDateTimeInUTC.Date() - EpochStartDateTime.Date()) * 86400) +
                     (Round((CurrentDateTimeInUTC.Time() - EpochStartDateTime.Time()) / 1000, 1, '='));
    end;

    /// <summary>
    /// Converts the given DateTime to UTC.
    /// </summary>
    /// <param name="Input">The DateTime to convert.</param>
    /// <returns>The DateTime in UTC.</returns>
    procedure GetDateTimeInUtc(Input: DateTime) UTC: DateTime
    var
        TimeZone: Codeunit "Time Zone";
        Offset: Duration;
    begin
        Offset := TimeZone.GetTimezoneOffset(Input);
        UTC := Input - Offset;
    end;
}