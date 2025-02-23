codeunit 73276 TKARunAdminAPIForTimezones
{
    Access = Public;

    var
        RunAdminAPIForTimezonesImpl: Codeunit TKARunAdminAPIForTimezonesImpl;

    /// <summary>
    /// Create or update available timezones.
    /// </summary>
    procedure CreateUpdateAvailableUpdateTimezones()
    begin
        RunAdminAPIForTimezonesImpl.CreateUpdateAvailableUpdateTimezones();
    end;
}