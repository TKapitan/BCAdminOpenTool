page 73273 TKAManagedBCEnvironments
{
    ApplicationArea = All;
    Caption = 'Managed BC Environments';
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
                field(TenantName; Rec.TenantName) { }
                field(Name; Rec.Name) { }
                field(Type; Rec."Type") { }
                field(OpenEnvironmentField; OpenEnvironmentLbl)
                {
                    Caption = 'Web Client';
                    ToolTip = 'Specifies the web client URL for the environment.';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(Rec.WebClientURL);
                    end;
                }
                field(RingName; Rec.RingName) { }
                field(CountryCode; Rec.CountryCode) { }
                field(ApplicationVersion; Rec.ApplicationVersion) { }
                field(PlatformVersion; Rec.PlatformVersion) { }
                field(Status; Rec.Status) { }
                field(LocationName; Rec.LocationName) { }
                field(GeoName; Rec.GeoName) { }
                field(ApplicationInsightsKey; Rec.ApplicationInsightsKey) { }
                field(EnvironmentModifiedAt; Rec.EnvironmentModifiedAt) { }
            }
        }
    }

    var
        OpenEnvironmentLbl: Label 'Open Environment';
}
