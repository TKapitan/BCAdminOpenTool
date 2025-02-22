page 73274 TKAManagedBCEnvironmentCard
{
    Caption = 'Managed BC Environment Card';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = TKAManagedBCEnvironment;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(TenantId; Rec.TenantId)
                {
                    Visible = false;
                }
                field(TenantName; Rec.TenantName) { }
                field(Name; Rec.Name) { }
                field(Type; Rec."Type") { }
                field(CountryCode; Rec.CountryCode) { }
                field(RingName; Rec.RingName)
                {
                    Importance = Additional;
                }
                field(Status; Rec.Status) { }
                field(OpenEnvironmentField; OpenEnvironmentLbl)
                {
                    Caption = 'Web Client';
                    ToolTip = 'Specifies the web client URL for the environment.';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(Rec.WebClientURL);
                    end;
                }
                field(ApplicationInsightsKey; Rec.ApplicationInsightsKey)
                {
                    Importance = Additional;
                }
                field(EnvironmentModifiedAt; Rec.EnvironmentModifiedAt) { }
            }
            group(UpdateManagement)
            {
                Caption = 'Update Management';

                field(ApplicationVersion; Rec.ApplicationVersion) { }
                field(PlatformVersion; Rec.PlatformVersion) { }
                field(AppSourceAppsUpdateCadence; Rec.AppSourceAppsUpdateCadence) { }
            }
            group(StatusDetails)
            {
                Caption = 'Status Details';

                field(Status_StatusDetails; Rec.Status) { }
                field(SoftDeletedOn; Rec.SoftDeletedOn) { }
                field(HardDeletePendingOn; Rec.HardDeletePendingOn) { }
                field(DeleteReason; Rec.DeleteReason) { }
            }
            group(Location)
            {
                Caption = 'Location';

                field(LocationName; Rec.LocationName) { }
                field(GeoName; Rec.GeoName) { }
            }
        }
    }

    var
        OpenEnvironmentLbl: Label 'Open Environment';
}