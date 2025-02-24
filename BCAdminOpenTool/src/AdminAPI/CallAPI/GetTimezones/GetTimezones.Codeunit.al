codeunit 73276 TKAGetTimezones
{
    Access = Public;

    var
        GetTimezonesImpl: Codeunit TKAGetTimezonesImpl;

    /// <summary>
    /// Create or update available timezones.
    /// </summary>
    procedure CreateUpdateAvailableUpdateTimezones()
    begin
        GetTimezonesImpl.CreateUpdateAvailableUpdateTimezones();
    end;
}