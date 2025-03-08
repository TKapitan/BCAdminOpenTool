codeunit 73272 TKAGetEnvironments
{
    Access = Public;

    var
        GetEnvironmentsImpl: Codeunit TKAGetEnvironmentsImpl;

    /// <summary>
    /// Create or update environments for a tenant.
    /// </summary>
    /// <param name="ManagedBCTenant">The tenant for which to create or update environments.</param>
    /// <param name="HideDialog">Specifies whether to hide any dialog.</param>
    procedure CreateUpdateEnvironmentsForTenant(var ManagedBCTenant: Record TKAManagedBCTenant; HideDialog: Boolean)
    begin
        GetEnvironmentsImpl.CreateUpdateEnvironmentsForTenant(ManagedBCTenant, HideDialog);
    end;

    /// <summary>
    /// Update selected environments.
    /// </summary>
    /// <param name="ManagedBCEnvironment">The environments to update.</param>
    /// <param name="HideDialog">Specifies whether to hide any dialog.</param>
    procedure UpdateSelectedEnvironments(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; HideDialog: Boolean)
    begin
        GetEnvironmentsImpl.UpdateSelectedEnvironments(ManagedBCEnvironment, HideDialog);
    end;
}