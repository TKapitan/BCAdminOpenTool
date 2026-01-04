page 73277 TKAManagedBCEnvironmentApps
{
    Caption = 'Managed BC Environment Apps';
    Editable = false;
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = TKAManagedBCEnvironmentApp;

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
                field(EnvironmentName; Rec.EnvironmentName)
                {
                    Visible = false;
                }
                field(ID; Rec.ID) { }
                field(Name; Rec.Name) { }
                field(Publisher; Rec.Publisher) { }
                field(Version; Rec."Version") { }
                field(State; Rec.State) { }
                field(WhitelistedThirdPartyApp; Rec.WhitelistedThirdPartyApp) { }
                field(WhitelistedThirdPartyAppForEnv; Rec.WhitelistedThirdPartyAppForEnv) { }
                field(InstalledOn; Rec.InstalledOn) { }
                field(LastOperationId; Rec.LastOperationId)
                {
                    Visible = false;
                }
                field(LastUpdateAttemptResult; Rec.LastUpdateAttemptResult) { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AddToWhitelistedApps)
            {
                ApplicationArea = All;
                Caption = 'Add to Whitelisted Apps';
                Image = Add;
                ToolTip = 'Add selected AppSource offerings to the whitelisted third party apps.';

                trigger OnAction()
                var
                    ManagedBCEnvironmentApp: Record TKAManagedBCEnvironmentApp;
                begin
                    CurrPage.SetSelectionFilter(ManagedBCEnvironmentApp);
                    if ManagedBCEnvironmentApp.FindSet() then
                        repeat
                            ManagedBCEnvironmentApp.AddToWhitelistedApps();
                        until ManagedBCEnvironmentApp.Next() < 1;
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
    begin
        AdminCenterAPISetup.ReadIsolation(IsolationLevel::ReadUncommitted);
        AdminCenterAPISetup.SetLoadFields(ExcludeHiddedApps);
        AdminCenterAPISetup.Get();

        if AdminCenterAPISetup.ExcludeHiddedApps then
            Rec.SetRange(Hidden, false);
    end;
}
