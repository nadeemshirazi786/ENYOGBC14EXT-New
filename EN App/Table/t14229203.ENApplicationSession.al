//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN Mobile App Session (ID 14229203).
/// </summary>
table 14229203 "Application Session ELA"
{
    DataClassification = ToBeClassified;
    DataPerCompany = false;
    fields
    {
        field(10; "Session ID"; Guid)
        {
        }

        field(20; "Role Code"; code[20])
        {
        }

        field(30; "App. User ID"; Code[10])
        {
        }

        field(40; "Equipment Code"; Code[10])
        {
        }

        field(1000; "Signed In Location"; Code[10])
        {
            DataClassification = ToBeClassified;
        }

        field(60; "Device Acct. ID"; code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(70; "Device Version"; Text[10])
        {
        }

        field(80; "Date Logged In"; Date)
        {
        }

        field(90; "Time Logged In"; Time)
        {
        }

        field(100; "Last Activity Time"; Time)
        {
            trigger OnValidate()
            begin
                IF NOT IsAppUserSessionActive("Session ID") THEN
                    ClearAppUserSession("Session ID")
                ELSE
                    "Last Activity Time" := TIME;
            end;

        }

        field(110; "App. Code"; Code[10])
        {
            TableRelation = "Application ELA";
            // OptionMembers = Floor,DSD,Sales;
        }

        field(1010; "Signed In Company"; Text[30])
        {
            TableRelation = Company;

        }
    }

    keys
    {
        key(PK; "Session ID")
        {
            Clustered = true;
        }

        key("UserIDKey"; "App. User ID")
        {
            Clustered = false;
            MaintainSqlIndex = true;
        }
    }


    trigger OnInsert()
    begin
        "Date Logged In" := TODAY;
        "Time Logged In" := TIME;
        "Last Activity Time" := TIME;
    end;

    trigger OnModify()
    begin
        "Last Activity Time" := TIME;
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    /// <summary>
    /// IsAppUserSessionActive.
    /// </summary>
    /// <param name="UserSessionID">Guid.</param>
    /// <returns>Return value of type Boolean.</returns>
    local procedure IsAppUserSessionActive(UserSessionID: Guid): Boolean
    var
        MobileAppSetup: Record "Application Setup ELA";
        LastDayIdleTime: Integer;
        TodaysIdleTime: Integer;
    begin

        IF GET(UserSessionID) THEN BEGIN
            MobileAppSetup.get;
            IF "Date Logged In" = TODAY THEN BEGIN
                IF TIME - "Last Activity Time" < MobileAppSetup."App. Login Time Out" THEN BEGIN
                    "Date Logged In" := TODAY;
                    "Last Activity Time" := TIME;
                    EXIT(TRUE);
                END ELSE
                    EXIT(FALSE);
            END ELSE BEGIN
                LastDayIdleTime := 235900T - "Last Activity Time";
                TodaysIdleTime := TIME - 0T;
                IF LastDayIdleTime + TodaysIdleTime < MobileAppSetup."App. Login Time Out" THEN BEGIN
                    "Date Logged In" := TODAY;
                    "Last Activity Time" := TIME;
                    EXIT(TRUE);
                END ELSE
                    EXIT(FALSE);
            END;
        END ELSE
            EXIT(FALSE);
    end;

    /// <summary>
    /// ClearAppUserSession.
    /// </summary>
    /// <param name="UserSessionID">Guid.</param>
    local procedure ClearAppUserSession(UserSessionID: Guid)
    var
        MobileAppSession: Record "Application Session ELA";
    begin
        IF MobileAppSession.GET(UserSessionID) THEN
            MobileAppSession.DELETE;
    end;

    /// <summary>
    /// ClearAllInactiveSessions.
    /// </summary>
    local procedure ClearAllInactiveSessions()
    var
        MobileAppSetup: Record "Application Setup ELA";
        MobileAppSession: Record "Application Session ELA";
    begin
        MobileAppSetup.GET;
        MobileAppSession.RESET;
        IF MobileAppSession.FINDSET THEN
            REPEAT
                IF TIME - "Last Activity Time" > MobileAppSetup."App. Login Time Out" THEN
                    ClearAppUserSession(MobileAppSession."Session ID");
            UNTIL MobileAppSession.NEXT = 0;
    end;
}