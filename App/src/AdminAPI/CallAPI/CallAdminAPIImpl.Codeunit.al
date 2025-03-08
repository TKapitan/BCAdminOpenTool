codeunit 73270 TKACallAdminAPIImpl
{
    Access = Internal;

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
        HttpResponseMessage: HttpResponseMessage;
        Result: Text;
    begin
        if not GetFromAdminAPI(ManagedBCTenant, Endpoint, HttpResponseMessage) then
            ThrowError(HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(Result);
        exit(Result);
    end;

    /// <summary>
    /// Calls the GET method of the Admin API for the specified BC tenant and API endpoint.
    /// </summary>
    /// <param name="ManagedBCTenant">Specifies the BC tenant for which the API call is to be made.</param>
    /// <param name="Endpoint">Specifies the API endpoint to be called.</param>
    /// <param name="HttpResponseMessage">Specifies the HttpResponseMessage object to be used for the API call.</param>
    /// <returns>True if the API call was successful; otherwise, false.</returns>
    procedure GetFromAdminAPI(ManagedBCTenant: Record TKAManagedBCTenant; Endpoint: Text; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        HttpRequestMessage: HttpRequestMessage;
        HttpHeaders: HttpHeaders;
    begin
        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', GetBearerToken(ManagedBCTenant.TenantId, ManagedBCTenant.ClientId));

        HttpRequestMessage.SetRequestUri(GetBaseAPIUrl() + Endpoint);
        HttpRequestMessage.Method('GET');
        exit(SendAPIRequest(HttpRequestMessage, HttpResponseMessage));
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
    procedure WriteToAdminAPI(Method: Enum "Http Method"; ManagedBCEnvironment: Record TKAManagedBCEnvironment; Endpoint: Text; RequestBody: JsonObject; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        HttpRequestMessage: HttpRequestMessage;
        HttpContent: HttpContent;
        HttpRequestHeaders, HttpContextHeaders : HttpHeaders;
        RequestBodyAsText: Text;
    begin
        HttpRequestMessage.GetHeaders(HttpRequestHeaders);
        HttpRequestHeaders.Add('Authorization', GetBearerToken(ManagedBCEnvironment.TenantId, ManagedBCEnvironment.GetManagedBCTenant().ClientId));

        RequestBody.WriteTo(RequestBodyAsText);
        HttpContent.WriteFrom(RequestBodyAsText);
        HttpContent.GetHeaders(HttpContextHeaders);
        ReplaceHttpHeader(HttpContextHeaders, 'Content-Type', 'application/json');
        HttpRequestMessage.Content(HttpContent);

        HttpRequestMessage.SetRequestUri(GetBaseAPIUrl() + Endpoint);
        HttpRequestMessage.Method(Format(Method));
        exit(SendAPIRequest(HttpRequestMessage, HttpResponseMessage));
    end;

    procedure ThrowError(HttpResponseMessage: HttpResponseMessage)
    var
        NewErrorInfo: ErrorInfo;
        CustomDimensions: Dictionary of [Text, Text];
        ResponseInStream: InStream;
        ResponseAsText: Text;
        AdminAPICallFailedErr: Label 'Admin API call failed.';
        ErrorInclHttpResponseDetailsErr: Label '%1\\HttpStatusCode: %2\ReasonPhrase: %3\Details: %4', Comment = '%1 - Error message specified by the caller function, %2 - HttpStatusCode from the response, %3 - ReasonPhrase from the response, %4 - Response content';
    begin
        if HttpResponseMessage.IsSuccessStatusCode() then
            exit;

        HttpResponseMessage.Content().ReadAs(ResponseInStream);
        ResponseInStream.ReadText(ResponseAsText);

        NewErrorInfo := ErrorInfo.Create();
        NewErrorInfo.Message := StrSubstNo(ErrorInclHttpResponseDetailsErr, AdminAPICallFailedErr, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase, ResponseAsText);
        CustomDimensions.Add('HttpStatusCode', Format(HttpResponseMessage.HttpStatusCode));
        CustomDimensions.Add('ReasonPhrase', HttpResponseMessage.ReasonPhrase);
        NewErrorInfo.CustomDimensions(CustomDimensions);
        Error(NewErrorInfo);
    end;

    procedure GetErrorDetailsFromHttpResponseMessage(var HttpResponseMessage: HttpResponseMessage): Text
    var
        Response: Text;
        ResponseJson: JsonObject;
        ErrorMessageJsonToken: JsonToken;
    begin
        HttpResponseMessage.Content().ReadAs(Response);
        if Response = '' then
            exit('');
        ResponseJson.ReadFrom(Response);
        ResponseJson.Get('message', ErrorMessageJsonToken);
        exit(ErrorMessageJsonToken.AsValue().AsText());
    end;

    #endregion Internal Procedures
    #region Local Procedures

    local procedure SendAPIRequest(var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        HttpClient: HttpClient;
    begin
        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        if not HttpResponseMessage.IsSuccessStatusCode() then
            exit(false);
        exit(true);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCAdministrationApp, 'R')]
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAAdminCenterAPISetup, 'R')]
    local procedure GetBearerToken(TenantId: Guid; ClientId: Guid): SecretText
    var
        ManagedBCAdministrationApp: Record TKAManagedBCAdministrationApp;
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
        OAuth2WithMultitenantImpl: Codeunit TKAOAuth2WithMultitenantImpl;
        AccessToken: SecretText;
    begin
        ManagedBCAdministrationApp.ReadIsolation(IsolationLevel::ReadCommitted);
        ManagedBCAdministrationApp.Get(ClientId);

        AdminCenterAPISetup.ReadIsolation(IsolationLevel::ReadCommitted);
        AdminCenterAPISetup.SetLoadFields(AuthUrl);
        AdminCenterAPISetup.Get();

        ClearLastError();
        OAuth2WithMultitenantImpl.FetchBearerTokenImpl(
            ManagedBCAdministrationApp.ClientId,
            ManagedBCAdministrationApp.GetClientSecretAsSecretText(),
            TenantId,
            AdminCenterAPISetup.AuthUrl.Replace('%tenantid%', Format(TenantId, 0, 4)),
            AccessToken
        );
        exit(SecretStrSubstNo('Bearer %1', AccessToken));
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

    local procedure ReplaceHttpHeader(var HttpHeaders: HttpHeaders; Name: Text; Value: Text)
    begin
        if HttpHeaders.Contains(Name) then
            HttpHeaders.Remove(Name);
        HttpHeaders.Add(Name, Value);
    end;

    #endregion Local Procedures
}