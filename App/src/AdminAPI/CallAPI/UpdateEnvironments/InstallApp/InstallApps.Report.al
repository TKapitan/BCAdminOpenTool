report 73272 TKAInstallApps
{
    ApplicationArea = All;
    Caption = 'Install Apps';
    ProcessingOnly = true;
    UsageCategory = None;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    Caption = 'General';

                    field(UseEnvironmentUpdateWindowField; UseEnvironmentUpdateWindow)
                    {
                        ApplicationArea = All;
                        Caption = 'Use Environment Update Window';
                        ToolTip = 'Specifies whether to use the environment update window for the installation of apps.';
                    }
                    field(InstallUpdateNeededDependenciesField; InstallUpdateNeededDependencies)
                    {
                        ApplicationArea = All;
                        Caption = 'Install/Update Needed Dependencies';
                        ToolTip = 'Specifies whether to install the update needed dependencies.';
                    }
                }
                group(SelectAppsToInstall)
                {
                    Caption = 'Select Apps to Install';

                    part(TKAInstallAppsSubform; TKAInstallAppsSubform)
                    {
                        ApplicationArea = All;
                        Caption = '', Locked = true;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            UseEnvironmentUpdateWindow := true;
            InstallUpdateNeededDependencies := true;
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if not (CloseAction in [CloseAction::OK, CloseAction::LookupOK]) then
                exit(true);
            RequestOptionsPage.TKAInstallAppsSubform.Page.GetApps(InstallAppsBuffer);
            TestAppsToInstallSpecified();
        end;
    }

    trigger OnPostReport()
    var
        InstallAppsImpl: Codeunit TKAInstallAppsImpl;
    begin
        TestAppsToInstallSpecified();
        InstallAppsImpl.RunInstallApps(ManagedBCEnvironment, InstallAppsBuffer, UseEnvironmentUpdateWindow, InstallUpdateNeededDependencies);
    end;

    var
        InstallAppsBuffer: Record TKAInstallAppsBuffer;
        ManagedBCEnvironment: Record TKAManagedBCEnvironment;
        UseEnvironmentUpdateWindow, InstallUpdateNeededDependencies : Boolean;

    /// <summary>
    /// Sets the environments.
    /// </summary>
    /// <param name="NewManagedBCEnvironment">Filtered managed BC environment record.</param>
    procedure SetEnvironments(var NewManagedBCEnvironment: Record TKAManagedBCEnvironment)
    begin
        ManagedBCEnvironment.Copy(NewManagedBCEnvironment);
    end;

    local procedure TestAppsToInstallSpecified()
    var
        SelectAtLeastOneAppToInstallErr: Label 'Select at least one app to install.';
    begin
        if InstallAppsBuffer.IsEmpty() then
            Error(SelectAtLeastOneAppToInstallErr);
    end;
}