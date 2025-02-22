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

        DeleteDeletedEnvironments(TenantId, ListOfFoundEnvironments);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'RD')]
    local procedure DeleteDeletedEnvironments(TenantId: Guid; ListOfFoundEnvironments: List of [Text[100]])
    var
        ManagedBCEnvironment, ManagedBCEnvironment2 : Record TKAManagedBCEnvironment;
    begin
        ManagedBCEnvironment.SetRange(TenantId, TenantId);
        if ManagedBCEnvironment.FindSet() then
            repeat
                if not ListOfFoundEnvironments.Contains(ManagedBCEnvironment.Name) then begin
                    ManagedBCEnvironment2.GetBySystemId(ManagedBCEnvironment.SystemId);
                    ManagedBCEnvironment2.Delete(true);
                end;
            until ManagedBCEnvironment.Next() < 1;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'RIM')]
    local procedure ParseEnvironment(var JsonEnvironment: JsonObject; TenantId: Guid; EnvironmentName: Text[100])
    var
        ManagedBCEnvironment: Record TKAManagedBCEnvironment;
        JsonTokenValue: JsonToken;
    begin
        JsonEnvironment.Get('name', JsonTokenValue);
        EnvironmentName := CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(EnvironmentName));
        JsonEnvironment.Get('aadTenantId', JsonTokenValue);
        Evaluate(TenantId, JsonTokenValue.AsValue().AsText());

        if not ManagedBCEnvironment.Get(TenantId, EnvironmentName) then begin
            ManagedBCEnvironment.Init();
            ManagedBCEnvironment.Validate(TenantId, TenantId);
            ManagedBCEnvironment.Validate(Name, EnvironmentName);
            ManagedBCEnvironment.Insert(true);
        end;
        JsonEnvironment.Get('type', JsonTokenValue);
        ManagedBCEnvironment.Validate(Type, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.Type)));
        JsonEnvironment.Get('countryCode', JsonTokenValue);
        ManagedBCEnvironment.Validate(CountryCode, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.CountryCode)));
        JsonEnvironment.Get('applicationVersion', JsonTokenValue);
        ManagedBCEnvironment.Validate(ApplicationVersion, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.ApplicationVersion)));
        JsonEnvironment.Get('platformVersion', JsonTokenValue);
        ManagedBCEnvironment.Validate(PlatformVersion, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.PlatformVersion)));
        JsonEnvironment.Get('status', JsonTokenValue);
        ManagedBCEnvironment.Validate(Status, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.Status)));
        JsonEnvironment.Get('webClientLoginUrl', JsonTokenValue);
        ManagedBCEnvironment.Validate(WebClientURL, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.WebClientURL)));

        // Other fields (not sure if they are always included in the response)
        if JsonEnvironment.Get('ringName', JsonTokenValue) then
            ManagedBCEnvironment.Validate(RingName, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.RingName)));
        if JsonEnvironment.Get('locationName', JsonTokenValue) then
            ManagedBCEnvironment.Validate(LocationName, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.LocationName)));
        if JsonEnvironment.Get('geoName', JsonTokenValue) then
            ManagedBCEnvironment.Validate(GeoName, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.GeoName)));
        if JsonEnvironment.Get('appInsightsKey', JsonTokenValue) then
            ManagedBCEnvironment.Validate(ApplicationInsightsKey, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(ManagedBCEnvironment.ApplicationInsightsKey)));
        ManagedBCEnvironment.Validate(EnvironmentModifiedAt, CurrentDateTime());
        ManagedBCEnvironment.Modify(true);
    end;
}