page 73278 TKAAppSourceOfferings
{
    ApplicationArea = All;
    Caption = 'Our AppSource Apps';
    PageType = List;
    SourceTable = TKAAppSourceOffering;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(AppId; Rec.AppId) { }
                field(Name; Rec.Name) { }
            }
        }
    }
}
