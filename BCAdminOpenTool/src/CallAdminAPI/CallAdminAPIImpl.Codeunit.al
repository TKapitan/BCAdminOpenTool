codeunit 73270 TKACallAdminAPIImpl
{
    Access = Internal;

    /// <summary>
    /// Verifies the connection to the specified BC tenant.
    /// </summary>
    /// <param name="ForBCTenant">Specifies the BC tenant to connect to.</param>
    procedure TestAdminCenterConnection(ForBCTenant: Record TKAManagedBCTenant)
    var
        CallAdminAPI: Codeunit TKACallAdminAPI;
        ResponseText: Text;
        ConnectionSuccessfulButUnexpectedMessageReceivedErr: Label 'Connection to tenant %1 (%2) was successful, but an unexpected message was received.', Comment = '%1 - TenantId, %2 - Name';
        ConnectionSuccessfulMsg: Label 'Connection to tenant %1 (%2) was successful.', Comment = '%1 - TenantId, %2 - Name';
    begin
        ResponseText := GetFromAdminAPI(ForBCTenant, CallAdminAPI.GetListAllEnvironmentsEndpoint());
        if not ResponseText.Contains('"applicationFamily":"BusinessCentral"') then
            Error(ConnectionSuccessfulButUnexpectedMessageReceivedErr, ForBCTenant.TenantId, ForBCTenant.Name);
        Message(ConnectionSuccessfulMsg, ForBCTenant.TenantId, ForBCTenant.Name);
    end;

    /// <summary>
    /// Calls the Admin API for the specified BC tenant and API endpoint.
    /// </summary>
    /// <param name="ForBCTenant">Specifies the BC tenant for which the API call is to be made.</param>
    /// <param name="Endpoint">Specifies the API endpoint to be called.</param>
    /// <returns>Response as a text</returns>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAAdminCenterAPISetup, 'R')]
    procedure GetFromAdminAPI(ForBCTenant: Record TKAManagedBCTenant; Endpoint: Text): Text
    var
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
        HttpRequestMessage: HttpRequestMessage;
        HttpHeaders: HttpHeaders;
        HttpClient: HttpClient;
        ResponseInStream: InStream;
        HttpResponseMessage: HttpResponseMessage;
        Result: Text;
        AdminAPICallFailedErr: Label 'Admin API call failed.';
    begin
        AdminCenterAPISetup.ReadIsolation(IsolationLevel::ReadCommitted);
        AdminCenterAPISetup.SetLoadFields(APIUrl);
        AdminCenterAPISetup.Get();

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', GetBearerToken(ForBCTenant));

        HttpRequestMessage.SetRequestUri(AdminCenterAPISetup.APIUrl + Endpoint);
        HttpRequestMessage.Method('GET');

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        if not HttpResponseMessage.IsSuccessStatusCode() then
            ThrowError(AdminAPICallFailedErr, HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(ResponseInStream);
        ResponseInStream.ReadText(Result);
        exit(Result);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCAdministrationApp, 'R')]
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAAdminCenterAPISetup, 'R')]
    local procedure GetBearerToken(ForBCTenant: Record TKAManagedBCTenant): SecretText
    var
        ManagedBCAdministrationApp: Record TKAManagedBCAdministrationApp;
        AdminCenterAPISetup: Record TKAAdminCenterAPISetup;
        OAuth2: Codeunit OAuth2;
        AccessToken: SecretText;
        AuthFailedErr: Label 'Failed to acquire token.';
    begin
        ManagedBCAdministrationApp.ReadIsolation(IsolationLevel::ReadCommitted);
        ManagedBCAdministrationApp.Get(ForBCTenant.ClientId);

        AdminCenterAPISetup.ReadIsolation(IsolationLevel::ReadCommitted);
        AdminCenterAPISetup.SetLoadFields(AuthUrl);
        AdminCenterAPISetup.Get();

        ClearLastError();
        if not OAuth2.AcquireTokenWithClientCredentials(
            Format(ManagedBCAdministrationApp.ClientId, 0, 4),
            ManagedBCAdministrationApp.GetClientSecretAsSecretText(),
            AdminCenterAPISetup.AuthUrl.Replace('%tenantid%', Format(ForBCTenant.TenantId, 0, 4)),
            '', // RedirectUri
            'https://api.businesscentral.dynamics.com/.default',
            AccessToken
        ) then
            ThrowError(AuthFailedErr);

        exit(SecretStrSubstNo('Bearer %1', AccessToken));
    end;

    local procedure ThrowError(ErrorText: Text)
    var
        LastErrorText: Text;
        NewErrorInfo: ErrorInfo;
        CustomDimensions: Dictionary of [Text, Text];
        ErrorInclLastErrorDetailsErr: Label '%1\\Additional Details: %2', Comment = '%1 - Error message specified by the caller function, %2 - Error message from the response';
    begin
        NewErrorInfo := ErrorInfo.Create();
        LastErrorText := GetLastErrorText();
        if LastErrorText <> '' then begin
            NewErrorInfo.Message := StrSubstNo(ErrorInclLastErrorDetailsErr, ErrorText, LastErrorText);
            CustomDimensions.Add('ErrorMessage', LastErrorText);
            CustomDimensions.Add('ErrorCallStack', GetLastErrorCallStack());
            CustomDimensions.Add('ErrorCode', GetLastErrorCode());
            NewErrorInfo.CustomDimensions(CustomDimensions);
        end else
            NewErrorInfo.Message := ErrorText;
        Error(NewErrorInfo);
    end;

    local procedure ThrowError(ErrorText: Text; HttpResponseMessage: HttpResponseMessage)
    var
        NewErrorInfo: ErrorInfo;
        CustomDimensions: Dictionary of [Text, Text];
        ErrorInclHttpResponseDetailsErr: Label '%1\\HttpStatusCode: %2\ReasonPhrase: %3', Comment = '%1 - Error message specified by the caller function, %2 - HttpStatusCode from the response, %3 - ReasonPhrase from the response';
    begin
        if HttpResponseMessage.IsSuccessStatusCode() then
            exit;
        NewErrorInfo := ErrorInfo.Create();
        NewErrorInfo.Message := StrSubstNo(ErrorInclHttpResponseDetailsErr, ErrorText, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase);
        CustomDimensions.Add('HttpStatusCode', Format(HttpResponseMessage.HttpStatusCode));
        CustomDimensions.Add('ReasonPhrase', HttpResponseMessage.ReasonPhrase);
        NewErrorInfo.CustomDimensions(CustomDimensions);
        Error(NewErrorInfo);
    end;
}