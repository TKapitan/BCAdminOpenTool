codeunit 73283 TKAChangeUpdateSettingsImpl
{
    Access = Internal;

    procedure RunChangeUpdateDate(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; NewPreferredStartTime: Time; NewPreferredEndTime: Time; NewTimeZoneId: Text[100])
    begin
        TestChangesPossible(NewPreferredStartTime, NewPreferredEndTime);
        ProcessChange(ManagedBCEnvironment, NewPreferredStartTime, NewPreferredEndTime, NewTimeZoneId);
    end;

    local procedure TestChangesPossible(NewPreferredStartTime: Time; NewPreferredEndTime: Time)
    var
        TimeDifference: Duration;
        TimeDiffMustBeAtLeast6HoursErr: Label 'The time difference between the preferred start time and the preferred end time must be at least 6 hours.';
    begin
        TimeDifference := NewPreferredEndTime - NewPreferredStartTime;
        if TimeDifference < 0 then
            TimeDifference := NewPreferredStartTime - NewPreferredEndTime;

        if TimeDifference < 6 * 60 * 60 * 1000 then
            Error(TimeDiffMustBeAtLeast6HoursErr);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::TKAManagedBCEnvironment, 'R')]
    local procedure ProcessChange(var ManagedBCEnvironment: Record TKAManagedBCEnvironment; NewPreferredStartTime: Time; NewPreferredEndTime: Time; NewTimeZoneId: Text[100])
    var
        CallAdminAPI: Codeunit TKACallAdminAPI;
        GetEnvironments: Codeunit TKAGetEnvironments;
        HttpResponseMessage: HttpResponseMessage;
        RequestBodyJsonObject: JsonObject;
        Endpoint: Text;
        TimeFormatTok: Label '%1:%2', Locked = true;
    begin
        if ManagedBCEnvironment.FindSet() then
            repeat
                Clear(RequestBodyJsonObject);
                RequestBodyJsonObject.Add('preferredStartTime', StrSubstNo(TimeFormatTok, FormatTwoDigits(NewPreferredStartTime.Hour()), FormatTwoDigits(NewPreferredStartTime.Minute())));
                RequestBodyJsonObject.Add('preferredEndTime', StrSubstNo(TimeFormatTok, FormatTwoDigits(NewPreferredEndTime.Hour()), FormatTwoDigits(NewPreferredEndTime.Minute())));
                RequestBodyJsonObject.Add('timeZoneId', NewTimeZoneId);
                Endpoint := CallAdminAPI.GetUpdateSettingsForEnvironmentEndpoint(ManagedBCEnvironment.Name);
                if not CallAdminAPI.PutToAdminAPI(ManagedBCEnvironment, Endpoint, RequestBodyJsonObject, HttpResponseMessage) then
                    CallAdminAPI.ThrowError(HttpResponseMessage);
            until ManagedBCEnvironment.Next() < 1;
        GetEnvironments.UpdateSelectedEnvironments(ManagedBCEnvironment, false);
    end;

    local procedure FormatTwoDigits(Digits: Integer): Text[2]
    begin
        if Digits < 10 then
            exit('0' + Format(Digits));
        exit(Format(Digits));
    end;
}
