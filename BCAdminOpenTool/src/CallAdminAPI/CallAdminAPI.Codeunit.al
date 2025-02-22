codeunit 73271 TKACallAdminAPI
{
    Access = Public;

    var
        CallAdminAPIImpl: Codeunit TKACallAdminAPIImpl;

    /// <summary>
    /// Verifies the connection to the specified BC tenant.
    /// </summary>
    /// <param name="ForBCTenant">Specifies the BC tenant to connect to.</param>
    procedure TestAdminCenterConnection(ForBCTenant: Record TKAManagedBCTenant)
    begin
        CallAdminAPIImpl.TestAdminCenterConnection(ForBCTenant);
    end;

    /// <summary>
    /// Calls the Admin API for the specified BC tenant.
    /// </summary>
    /// <param name="ForBCTenant">Specifies the BC tenant for which the API call is to be made.</param>
    /// <param name="Endpoint">Specifies the API endpoint to be called.</param>
    /// <returns>Response as text.</returns>
    procedure GetFromAdminAPI(ForBCTenant: Record TKAManagedBCTenant; Endpoint: Text): Text
    begin
        exit(CallAdminAPIImpl.GetFromAdminAPI(ForBCTenant, Endpoint));
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
    /// Returns the endpoint for getting all environments.
    /// </summary>
    /// <returns>String containing the endpoint for getting all environments.</returns>
    procedure GetListAllEnvironmentsEndpoint(): Text
    begin
        exit('/applications/BusinessCentral/environments');
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
}
