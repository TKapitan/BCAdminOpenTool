codeunit 73304 TKAGetUpdates
{
    Access = Public;

    var
        GetUpdatesImpl: Codeunit TKAGetUpdatesImpl;

    /// <summary>
    /// Get updates for a specific environment.
    /// </summary>
    /// <param name="ManagedBCEnvironment">The environment for which to get the updates.</param>
    /// <param name="HideDialog">Specifies whether to hide any dialog.</param>
    procedure GetUpdatesForEnvironment(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; HideDialog: Boolean)
    begin
        GetUpdatesImpl.GetUpdatesForEnvironment(ManagedBCEnvironment, HideDialog);
    end;
}