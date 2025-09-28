codeunit 73270 TKACallAdminAPIImpl
{
    Access = Internal;
    SingleInstance = true;

    var
#pragma warning disable LC0003, LC0005 // Cops has a bug in 26.4
        RestClientInstances: Dictionary of [Guid, Codeunit "Rest Client"];
#pragma warning restore LC0003, LC0005

    #region Internal Procedures

    /// <summary>
    /// Verifies the connection to the specified BC tenant.
    /// </summary>
    /// <param name="ManagedBCTenant">Specifies the BC tenant to connect to.</param>
    procedure TestAdminCenterConnection(ManagedBCTenant: Record TKAManagedBCTenant)
    var
        CallAdminAPI: Codeunit TKACallAdminAPI;
        ResponseText: Text;
        ConnectionSuccessfulButUnexpectedMessageReceivedErr: Label 'Connection to tenant %1 (%2) was successful, but an unexpected message was received.', Comment = '%1 - TenantId, %2 - Name';
        ConnectionSuccessfulMsg: Label 'Connection to tenant %1 (%2) was successful.', Comment = '%1 - TenantId, %2 - Name';
    begin
        ResponseText := GetFromAdminAPI(ManagedBCTenant, CallAdminAPI.GetListAllEnvironmentsEndpoint());
        if not ResponseText.Contains('"applicationFamily":"BusinessCentral"') then
            Error(ConnectionSuccessfulButUnexpectedMessageReceivedErr, ManagedBCTenant.TenantId, ManagedBCTenant.Name);
        Message(ConnectionSuccessfulMsg, ManagedBCTenant.TenantId, ManagedBCTenant.Name);
    end;

    /// <summary>
    /// Calls the GET method of the Admin API for the specified BC tenant and API endpoint.
    /// </summary>
    /// <param name="ManagedBCTenant">Specifies the BC tenant for which the API call is to be made.</param>
    /// <param name="Endpoint">Specifies the API endpoint to be called.</param>
    /// <returns>Response as text.</returns>
    procedure GetFromAdminAPI(ManagedBCTenant: Record TKAManagedBCTenant; Endpoint: Text): Text
    var
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        if not GetFromAdminAPI(ManagedBCTenant, Endpoint, HttpResponseMessage) then
            ThrowError(HttpResponseMessage);
        exit(HttpResponseMessage.GetContent().AsText());
    end;

    /// <summary>
    /// Calls the GET method of the Admin API for the specified BC tenant and API endpoint.
    /// </summary>
    /// <param name="ManagedBCTenant">Specifies the BC tenant for which the API call is to be made.</param>
    /// <param name="Endpoint">Specifies the API endpoint to be called.</param>
    /// <param name="HttpResponseMessage">Specifies the HttpResponseMessage object to be used for the API call.</param>
    /// <returns>True if the API call was successful; otherwise, false.</returns>
    procedure GetFromAdminAPI(ManagedBCTenant: Record TKAManagedBCTenant; Endpoint: Text; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    var
        HttpRequestMessage: Codeunit "Http Request Message";
    begin
        HttpRequestMessage.SetRequestUri(GetBaseAPIUrl() + Endpoint);
        HttpRequestMessage.SetHttpMethod(Enum::"Http Method"::GET);
        exit(SendAPIRequest(ManagedBCTenant, HttpRequestMessage, HttpResponseMessage));
    end;

    /// <summary>
    /// Calls the Http Method of the Admin API for the specified BC tenant and API endpoint.
    /// </summary>
    /// <param name="Method">Specifies the Http Method to be used for the API call.</param>
    /// <param name="ManagedBCEnvironment">Specifies the managed BC environment for which the API call is to be made.</param>
    /// <param name="Endpoint">Specifies the API endpoint to be called.</param>
    /// <param name="RequestBody">Specifies the request body as a JsonObject</param>
    /// <param name="HttpResponseMessage">Specifies the HttpResponseMessage object to be used for the API call.</param>
    /// <returns>True if the API call was successful; otherwise, false.</returns>
    procedure WriteToAdminAPI(Method: Enum "Http Method"; ManagedBCEnvironment: Record TKAManagedBCEnvironment; Endpoint: Text; RequestBody: JsonObject; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    var
        HttpRequestMessage: Codeunit "Http Request Message";
        HttpContent: Codeunit "Http Content";
    begin
        HttpContent.Create(RequestBody);
        HttpRequestMessage.SetContent(HttpContent);

        HttpRequestMessage.SetRequestUri(GetBaseAPIUrl() + Endpoint);
        HttpRequestMessage.SetHttpMethod(Method);
        exit(SendAPIRequest(ManagedBCEnvironment.GetManagedBCTenant(), HttpRequestMessage, HttpResponseMessage));
    end;

    procedure ThrowError(HttpResponseMessage: Codeunit "Http Response Message")
    var
        NewErrorInfo: ErrorInfo;
        CustomDimensions: Dictionary of [Text, Text];
        Response: Text;
        AdminAPICallFailedErr: Label 'Admin API call failed.';
        ErrorInclHttpResponseDetailsErr: Label '%1\\HttpStatusCode: %2\ReasonPhrase: %3\Details: %4', Comment = '%1 - Error message specified by the caller function, %2 - HttpStatusCode from the response, %3 - ReasonPhrase from the response, %4 - Response content';
    begin
        if HttpResponseMessage.GetIsSuccessStatusCode() then
            exit;
        Response := HttpResponseMessage.GetContent().AsText();

        NewErrorInfo := ErrorInfo.Create();
        NewErrorInfo.Message := StrSubstNo(ErrorInclHttpResponseDetailsErr, AdminAPICallFailedErr, HttpResponseMessage.GetHttpStatusCode(), HttpResponseMessage.GetReasonPhrase(), Response);
        CustomDimensions.Add('HttpStatusCode', Format(HttpResponseMessage.GetHttpStatusCode()));
        CustomDimensions.Add('ReasonPhrase', HttpResponseMessage.GetReasonPhrase());
        NewErrorInfo.CustomDimensions(CustomDimensions);
        Error(NewErrorInfo);
    end;

    procedure GetErrorDetailsFromHttpResponseMessage(var HttpResponseMessage: Codeunit "Http Response Message"): Text
    var
        Response: Text;
        ResponseJson: JsonObject;
        ErrorMessageJsonToken: JsonToken;
    begin
        Response := HttpResponseMessage.GetContent().AsText();
        if Response = '' then
            exit('');
        ResponseJson.ReadFrom(Response);
        ResponseJson.Get('message', ErrorMessageJsonToken);
        exit(ErrorMessageJsonToken.AsValue().AsText());
    end;

    #endregion Internal Procedures
    #region Local Procedures

    local procedure SendAPIRequest(ManagedBCTenant: Record TKAManagedBCTenant; var HttpRequestMessage: Codeunit "Http Request Message"; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    var
        AdminAPIRESTClient: Codeunit TKAAdminAPIRESTClient;
        RestClient: Codeunit "Rest Client";
    begin
        if not RestClientInstances.ContainsKey(ManagedBCTenant.TenantId) then
            RestClientInstances.Add(ManagedBCTenant.TenantId, AdminAPIRESTClient.GetRestClient(ManagedBCTenant));

        RestClient := RestClientInstances.Get(ManagedBCTenant.TenantId);
        HttpResponseMessage := RestClient.Send(HttpRequestMessage);
        if not HttpResponseMessage.GetIsSuccessStatusCode() then
            exit(false);
        exit(true);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAAdminCenterAPISetup, 'R')]
    local procedure GetBaseAPIUrl(): Text
    var
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
    begin
        AdminCenterAPISetup.ReadIsolation(IsolationLevel::ReadCommitted);
        AdminCenterAPISetup.SetLoadFields(APIUrl);
        AdminCenterAPISetup.Get();
        exit(AdminCenterAPISetup.APIUrl);
    end;

    #endregion Local Procedures
}