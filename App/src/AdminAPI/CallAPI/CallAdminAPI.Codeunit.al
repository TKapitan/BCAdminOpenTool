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
    /// Calls the Admin API for the specified BC tenant.
    /// </summary>
    /// <param name="ManagedBCTenant">Specifies the BC tenant for which the API call is to be made.</param>
    /// <param name="Endpoint">Specifies the API endpoint to be called.</param>
    /// <param name="HttpResponseMessage">Specifies the HttpResponseMessage object to be used for the API call.</param>
    /// <returns>Response as text.</returns>
    procedure GetFromAdminAPI(ManagedBCTenant: Record TKAManagedBCTenant; Endpoint: Text; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    begin
        exit(CallAdminAPIImpl.GetFromAdminAPI(ManagedBCTenant, Endpoint, HttpResponseMessage));
    end;

    /// <summary>
    /// Calls the POST method of the Admin API for the specified BC tenant and API endpoint.
    /// </summary>
    /// <param name="ManagedBCEnvironment">Specifies the managed BC environment for which the API call is to be made.</param>
    /// <param name="Endpoint">Specifies the API endpoint to be called.</param>
    /// <param name="RequestBody">Specifies the request body as a JsonObject</param>
    /// <param name="HttpResponseMessage">Specifies the HttpResponseMessage object to be used for the API call.</param>
    /// <returns>True if the API call was successful; otherwise, false.</returns>
    procedure PostToAdminAPI(ManagedBCEnvironment: Record TKAManagedBCEnvironment; Endpoint: Text; RequestBody: JsonObject; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    begin
        exit(CallAdminAPIImpl.WriteToAdminAPI(Enum::"Http Method"::POST, ManagedBCEnvironment, Endpoint, RequestBody, HttpResponseMessage));
    end;

    /// <summary>
    /// Calls the PUT method of the Admin API for the specified BC tenant and API endpoint.
    /// </summary>
    /// <param name="ManagedBCEnvironment">Specifies the managed BC environment for which the API call is to be made.</param>
    /// <param name="Endpoint">Specifies the API endpoint to be called.</param>
    /// <param name="RequestBody">Specifies the request body as a JsonObject</param>
    /// <param name="HttpResponseMessage">Specifies the HttpResponseMessage object to be used for the API call.</param>
    /// <returns>True if the API call was successful; otherwise, false.</returns>
    procedure PutToAdminAPI(ManagedBCEnvironment: Record TKAManagedBCEnvironment; Endpoint: Text; RequestBody: JsonObject; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    begin
        exit(CallAdminAPIImpl.WriteToAdminAPI(Enum::"Http Method"::PUT, ManagedBCEnvironment, Endpoint, RequestBody, HttpResponseMessage));
    end;

    /// <summary>
    /// Throws an error based on the HttpResponseMessage.
    /// </summary>
    /// <param name="HttpResponseMessage">Specifies the HttpResponseMessage object that contains the error details.</param>
    procedure ThrowError(HttpResponseMessage: Codeunit "Http Response Message")
    begin
        CallAdminAPIImpl.ThrowError(HttpResponseMessage);
    end;

    /// <summary>
    /// Gets the error details from the HttpResponseMessage.
    /// </summary>
    /// <param name="HttpResponseMessage">Specifies the HttpResponseMessage object that contains the error details.</param>
    /// <returns>String containing the error details.</returns>
    procedure GetErrorDetailsFromHttpResponseMessage(var HttpResponseMessage: Codeunit "Http Response Message"): Text
    begin
        exit(CallAdminAPIImpl.GetErrorDetailsFromHttpResponseMessage(HttpResponseMessage));
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
    /// Return the endpoint for getting updates for an environment.
    /// </summary>
    /// <param name="EnvironmentName">The name of the environment for which to get the updates.</param>
    /// <returns>String containing the endpoint for getting updates for an environment.</returns>
    procedure GetUpdatesForEnvironmentEndpoint(EnvironmentName: Text): Text
    begin
        exit('/applications/BusinessCentral/environments/{environmentName}/updates'.Replace('{environmentName}', EnvironmentName));
    end;

    /// <summary>
    /// Return the endpoint for getting scheduled update information for an environment.
    /// </summary>
    /// <param name="EnvironmentName">The name of the environment for which to get the scheduled update information.</param>
    /// <returns>String containing the endpoint for getting scheduled update information for an environment.</returns>
    [Obsolete('Replaced by flexible update logic and related fields.', '27.2')]
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

    /// <summary>
    /// Returns the endpoint for installing an app in an environment.
    /// </summary>
    /// <param name="EnvironmentName">The name of the environment in which to install the app.</param>
    /// <param name="AppId">The ID of the app to install.</param>
    /// <returns>String containing the endpoint for installing an app in an environment.</returns>
    procedure GetInstallAppsForEnvironmentEndpoint(EnvironmentName: Text; AppId: Guid): Text
    begin
        exit('/applications/BusinessCentral/environments/{environmentName}/apps/{appId}/install'.Replace('{environmentName}', EnvironmentName).Replace('{appId}', Format(AppId, 0, 4)));
    end;
}
