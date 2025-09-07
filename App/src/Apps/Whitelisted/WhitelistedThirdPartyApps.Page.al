page 73281 TKAWhitelistedThirdPartyApps
{
    Caption = 'Whitelisted Third Party Apps';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = TKAWhitelistedThirdPartyApp;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(AppId; Rec.AppId) { }
                field(Publisher; Rec.Publisher) { }
                field(Name; Rec.Name) { }
                field(Comment; Rec.Comment) { }
            }
        }
    }
}