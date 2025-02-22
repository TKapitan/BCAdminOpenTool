page 73272 TKAAdminCenterAPISetup
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = TKAAdminCenterAPISetup;
    Caption = 'Admin Center API Setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(AuthUrl; Rec.AuthUrl) { }
                field(Scope; Rec.Scope) { }
                field(APIUrl; Rec.APIUrl) { }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InsertIfNotExists();
    end;
}
