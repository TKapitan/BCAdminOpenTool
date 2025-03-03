codeunit 73271 TKACallAdminAPI
{
    Access = Public;

    var
        CallAdminAPIImpl: Codeunit TKACallAdminAPIImpl;

    /// <summary>
    /// Verifies the connection to the specified BC tenant.
    /// </summary>
    /// <param name="ManagedBCTenant">Specifies the BC tenant to connect to.</param>
    procedure TestAdminCenterConnection(ManagedBCTenant: Record TKAManagedBCTenant)
    begin
        CallAdminAPIImpl.TestAdminCenterConnection(ManagedBCTenant);
    end;

    /// <summary>
    /// Calls the Admin API for the specified BC tenant.
    /// </summary>
    /// <param name="ManagedBCTenant">Specifies the BC tenant for which the API call is to be made.</param>
    /// <param name="Endpoint">Specifies the API endpoint to be called.</param>
    /// <returns>Response as text.</returns>
    procedure GetFromAdminAPI(ManagedBCTenant: Record TKAManagedBCTenant; Endpoint: Text): Text
    begin
        exit(CallAdminAPIImpl.GetFromAdminAPI(ManagedBCTenant, Endpoint));
    end;

    /// <summary>
    /// Calls the PUT method of the Admin API for the specified BC tenant and API endpoint.
    /// </summary>
    /// <param name="ManagedBCEnvironment">Specifies the managed BC environment for which the API call is to be made.</param>
    /// <param name="Endpoint">Specifies the API endpoint to be called.</param>
    /// <param name="RequestBody">Specifies the request body as a JsonObject</param>
    /// <returns>Response as a text</returns>
    procedure PutToAdminAPI(ManagedBCEnvironment: Record TKAManagedBCEnvironment; Endpoint: Text; RequestBody: JsonObject): Text
    begin
        exit(CallAdminAPIImpl.PutToAdminAPI(ManagedBCEnvironment, Endpoint, RequestBody));
    end;

    /// <summary>
    /// Returns the endpoint for getting all manageable tenants.
    /// </summary>
    /// <returns>String containing the endpoint for getting all manageable tenants.</returns>
    procedure GetManagedBCTenantsEndpoint(): Text
    begin
        exit('/authorizedAadApps/manageableTenants');
    end;

    /// <summary>
    /// Returns the endpoint for getting all available timezones.
    /// </summary>
    /// <returns>String containing the endpoint for getting all available timezones.</returns>
    procedure GetAvailableTimezonesEndpoint(): Text
    begin
        exit('/applications/settings/timezones');
    end;

    /// <summary>
    /// Returns the endpoint for getting all environments.
    /// </summary>
    /// <returns>String containing the endpoint for getting all environments.</returns>
    procedure GetListAllEnvironmentsEndpoint(): Text
    begin
        exit('/applications/BusinessCentral/environments');
    end;

    /// <summary>
    /// Returns the endpoint for one environment.
    /// </summary>
    /// <param name="EnvironmentName">The name of the environment for which to get the endpoint.</param>
    /// <returns>String containing the endpoint for getting one environment.</returns>
    procedure GetEnvironmentEndpoint(EnvironmentName: Text): Text
    begin
        exit('/applications/BusinessCentral/environments/{environmentName}'.Replace('{environmentName}', EnvironmentName));
    end;

    /// <summary>
    /// Return the endpoint for getting scheduled update information for an environment.
    /// </summary>
    /// <param name="EnvironmentName">The name of the environment for which to get the scheduled update information.</param>
    /// <returns>String containing the endpoint for getting scheduled update information for an environment.</returns>
    procedure GetScheduledUpdateForEnvironmentEndpoint(EnvironmentName: Text): Text
    begin
        exit('/applications/BusinessCentral/environments/{environmentName}/upgrade'.Replace('{environmentName}', EnvironmentName));
    end;

    /// <summary>
    /// Return the endpoint for getting update settings for an environment.
    /// </summary>
    /// <param name="EnvironmentName">The name of the environment for which to get the update settings.</param>
    /// <returns>String containing the endpoint for getting update settings for an environment.</returns>
    procedure GetUpdateSettingsForEnvironmentEndpoint(EnvironmentName: Text): Text
    begin
        exit('/applications/BusinessCentral/environments/{environmentName}/settings/upgrade'.Replace('{environmentName}', EnvironmentName));
    end;

    /// <summary>
    /// Returns the endpoint for getting installed apps for an environment.
    /// </summary>
    /// <param name="EnvironmentName">The name of the environment for which to get the installed apps.</param>
    /// <returns>String containing the endpoint for getting installed apps for an environment.</returns>
    procedure GetInstalledAppsForEnvironmentEndpoint(EnvironmentName: Text): Text
    begin
        exit('/applications/BusinessCentral/environments/{environmentName}/apps'.Replace('{environmentName}', EnvironmentName));
    end;
}
