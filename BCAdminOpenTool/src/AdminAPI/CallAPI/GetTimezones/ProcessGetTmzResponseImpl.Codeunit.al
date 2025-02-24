codeunit 73278 TKAProcessGetTmzResponseImpl
{
    Access = Internal;

    #region Available Timezones

    /// <summary>
    /// Parses the response from the Admin API for getting available timezones.
    /// </summary>
    /// <param name="Response">The response from the Admin API.</param>
    procedure ParseGetAvailableUpdateTimezonesResponse(Response: Text)
    var
        JsonResponse, JsonTimezone : JsonObject;
        JsonTokenValue, JsonTokenTimezone : JsonToken;
        JsonTimezones: JsonArray;
    begin
        DeleteAllAvailableTimezones();

        JsonResponse.ReadFrom(Response);
        JsonResponse.Get('value', JsonTokenValue);
        JsonTimezones := JsonTokenValue.AsArray();
        foreach JsonTokenTimezone in JsonTimezones do begin
            JsonTimezone := JsonTokenTimezone.AsObject();
            ParseAvailableTimezoneResponse(JsonTimezone);
        end;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAAvailableUpdateTimezone, 'D')]
    local procedure DeleteAllAvailableTimezones()
    var
        AvailableUpdateTimezone: Record TKAAvailableUpdateTimezone;
    begin
        AvailableUpdateTimezone.DeleteAll(true);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAAvailableUpdateTimezone, 'RIM')]
    local procedure ParseAvailableTimezoneResponse(var JsonTimezone: JsonObject)
    var
        AvailableUpdateTimezone: Record TKAAvailableUpdateTimezone;
        JsonTokenValue: JsonToken;
        TimezoneId: Text[100];
    begin
        JsonTimezone.Get('id', JsonTokenValue);
        TimezoneId := CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(TimezoneId));

        if not AvailableUpdateTimezone.Get(TimezoneId) then begin
            AvailableUpdateTimezone.Init();
            AvailableUpdateTimezone.Validate(Name, TimezoneId);
            AvailableUpdateTimezone.Insert(true);
        end;
        JsonTimezone.Get('displayName', JsonTokenValue);
        AvailableUpdateTimezone.Validate(DisplayName, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(AvailableUpdateTimezone.DisplayName)));
        JsonTimezone.Get('currentUtcOffset', JsonTokenValue);
        AvailableUpdateTimezone.Validate(CurrentUtcOffset, CopyStr(JsonTokenValue.AsValue().AsText(), 1, MaxStrLen(AvailableUpdateTimezone.CurrentUtcOffset)));
        JsonTimezone.Get('supportsDaylightSavingTime', JsonTokenValue);
        AvailableUpdateTimezone.Validate(SupportsDaylightSavingTime, JsonTokenValue.AsValue().AsBoolean());
        JsonTimezone.Get('isCurrentlyDaylightSavingTime', JsonTokenValue);
        AvailableUpdateTimezone.Validate(IsCurrentlyDaylightSavingTime, JsonTokenValue.AsValue().AsBoolean());
        AvailableUpdateTimezone.Modify(true);
    end;

    #endregion Available Timezones
}