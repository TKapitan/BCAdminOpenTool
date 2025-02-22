page 73273 TKAManagedBCEnvironments
{
    ApplicationArea = All;
    Caption = 'Managed BC Environments';
    CardPageId = TKAManagedBCEnvironmentCard;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    PageType = List;
    SourceTable = TKAManagedBCEnvironment;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(TenantId; Rec.TenantId)
                {
                    Visible = false;
                }
                field(Name; Rec.Name) { }
                field(TenantName; Rec.TenantName) { }
                field(Type; Rec."Type") { }
                field(RingName; Rec.RingName)
                {
                    Visible = false;
                }
                field(CountryCode; Rec.CountryCode) { }
                field(ApplicationVersion; Rec.ApplicationVersion) { }
                field(PlatformVersion; Rec.PlatformVersion) { }
                field(UpdateIsActive; Rec.UpdateIsActive) { }
                field(UpdateTargetVersion; Rec.UpdateTargetVersion) { }
                field(UpgradeDate; Rec.UpgradeDate) { }
                field(Status; Rec.Status) { }
                field(AppSourceAppsUpdateCadence; Rec.AppSourceAppsUpdateCadence) { }
                field(LocationName; Rec.LocationName) { }
                field(GeoName; Rec.GeoName) { }
                field(ApplicationInsightsKey; Rec.ApplicationInsightsKey)
                {
                    Visible = false;
                }
                field(SoftDeletedOn; Rec.SoftDeletedOn)
                {
                    Visible = false;
                }
                field(HardDeletePendingOn; Rec.HardDeletePendingOn)
                {
                    Visible = false;
                }
                field(DeleteReason; Rec.DeleteReason)
                {
                    Visible = false;
                }
                field(OpenEnvironmentField; OpenEnvironmentLbl)
                {
                    Caption = 'Web Client';
                    ToolTip = 'Specifies the web client URL for the environment.';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(Rec.WebClientURL);
                    end;
                }
                field(EnvironmentModifiedAt; Rec.EnvironmentModifiedAt) { }
            }
        }
    }

    var
        OpenEnvironmentLbl: Label 'Open Environment';
}
