codeunit 73273 TKARunAdminAPIForEnvImpl
{
    Access = Internal;

    /// <summary>
    /// Create or update environments for a tenant.
    /// </summary>
    /// <param name="ForBCTenant">The tenant for which to create or update environments.</param>
    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCTenant, 'M')]
    procedure CreateUpdateEnvironmentsForTenant(var ForBCTenant: Record TKAManagedBCTenant)
    var
        CallAdminAPI: Codeunit TKACallAdminAPI;
        Response: Text;
    begin
        Response := CallAdminAPI.GetEnvironmentsForTenant(ForBCTenant);
        Message(Response);
        ParseGetEnvironmentsResponse(Response);

        ForBCTenant.Validate(EnvironmentsModifiedAt, CurrentDateTime());
        ForBCTenant.Modify(true);
    end;

    local procedure ParseGetEnvironmentsResponse(Response: Text)
    var
        JsonResponse, JsonEnvironment : JsonObject;
        JsonTokenValue, JsonTokenEnvironment : JsonToken;
        JsonEnvironments: JsonArray;
        TenantId: Guid;
        ListOfFoundEnvironments: List of [Text[100]];
        EnvironmentName: Text[100];
    begin
        JsonResponse.ReadFrom(Response);
        JsonResponse.Get('value', JsonTokenValue);
        JsonEnvironments := JsonTokenValue.AsArray();
        foreach JsonTokenEnvironment in JsonEnvironments do begin
            JsonEnvironment := JsonTokenEnvironment.AsObject();
            ParseEnvironment(JsonEnvironment, TenantId, EnvironmentName);
            ListOfFoundEnvironments.Add(EnvironmentName);
        end;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'RIM')]
    local procedure ParseEnvironment(var JsonEnvironment: JsonObject; TenantId: Guid; EnvironmentName: Text[100])
    var
        BCEnvironment: Record TKAManagedBCEnvironment;
        JsonTokenValue: JsonToken;
    begin
        JsonEnvironment.Get('name', JsonTokenValue);
        EnvironmentName := CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(EnvironmentName));
        JsonEnvironment.Get('aadTenantId', JsonTokenValue);
        Evaluate(TenantId, JsonTokenValue.AsValue().AsText());

        if not BCEnvironment.Get(TenantId, EnvironmentName) then begin
            BCEnvironment.Init();
            BCEnvironment.Validate(TenantId, TenantId);
            BCEnvironment.Validate(Name, EnvironmentName);
            BCEnvironment.Insert(true);
        end;
        JsonEnvironment.Get('type', JsonTokenValue);
        BCEnvironment.Validate(Type, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(BCEnvironment.Type)));
        JsonEnvironment.Get('countryCode', JsonTokenValue);
        BCEnvironment.Validate(CountryCode, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(BCEnvironment.CountryCode)));
        JsonEnvironment.Get('applicationVersion', JsonTokenValue);
        BCEnvironment.Validate(ApplicationVersion, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(BCEnvironment.ApplicationVersion)));
        JsonEnvironment.Get('platformVersion', JsonTokenValue);
        BCEnvironment.Validate(PlatformVersion, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(BCEnvironment.PlatformVersion)));
        JsonEnvironment.Get('status', JsonTokenValue);
        BCEnvironment.Validate(Status, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(BCEnvironment.Status)));
        JsonEnvironment.Get('webClientLoginUrl', JsonTokenValue);
        BCEnvironment.Validate(WebClientURL, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(BCEnvironment.WebClientURL)));

        // Other fields (not sure if they are always included in the response)
        if JsonEnvironment.Get('ringName', JsonTokenValue) then
            BCEnvironment.Validate(RingName, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(BCEnvironment.RingName)));
        if JsonEnvironment.Get('locationName', JsonTokenValue) then
            BCEnvironment.Validate(LocationName, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(BCEnvironment.LocationName)));
        if JsonEnvironment.Get('geoName', JsonTokenValue) then
            BCEnvironment.Validate(GeoName, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(BCEnvironment.GeoName)));
        if JsonEnvironment.Get('appInsightsKey', JsonTokenValue) then
            BCEnvironment.Validate(ApplicationInsightsKey, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(BCEnvironment.ApplicationInsightsKey)));
        BCEnvironment.Validate(EnvironmentModifiedAt, CurrentDateTime());
        BCEnvironment.Modify(true);
    end;
}