//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Codeunit EN App. Login Mgmt. (ID 14229200).
/// </summary>
codeunit 14229200 "App. Login Mgmt. ELA"
{
    var
        TEXT14229200: TextConst ENU = 'User %1 is not enabled for application %2.';
        TEXT14229201: TextConst ENU = 'Invalid Pin. is provided for User %1.';
        TEXT14229202: textconst ENU = 'User %1  is not setup for applicaation %2.';
        TEXT14229203: textconst ENU = 'User %1 is blocked. Please contact support.';
        TEXT14229204: textconst ENU = 'User %1 is already logged on another device %2.';
        TEXT14229205: textconst ENU = 'User session is invalid. Try to login again';
        TEXT14229206: textconst ENU = 'Invalid PIN';
        TEXT14229207: TextConst ENU = 'User %1 is not setup as admin';
        WMSJobMgmt: Codeunit "App. Job Mgmt. ELA";


    /// <summary>
    /// RegisterAppSignin.
    /// </summary>
    /// <param name="DeviceAcctID">code[10].</param>
    /// <param name="ApplicationType">code[10].</param>
    /// <param name="AppUserID">Code[10].</param>
    /// <param name="AppUserPIN">Code[4].</param>
    /// <param name="EquipmentID">Code[10].</param>
    /// <param name="DeviceAppVersion">Text[10].</param>
    /// <param name="IsAdmin">VAR Boolean.</param>
    /// <param name="ErrorMsg">VAR text[250].</param>
    /// <param name="ErrorCode">VAR Integer.</param>
    /// <param name="ResponsibilityCenter">VAR Code[10].</param>
    /// <param name="RouteNo">VAR Code[10].</param>
    /// <param name="LoadRequestPrefix">VAR code[6].</param>
    /// <param name="CustomerTransactionPrefix">VAR code[6].</param>
    /// <returns>Return value of type Text.</returns>
    procedure RegisterAppSignin(DeviceAcctID: code[10]; ApplicationType: code[10]; AppUserID: Code[10]; AppUserPIN: Code[4]; CompanyCode: Code[20]; EquipmentID: Code[10];
        DeviceAppVersion: Text[10]; var IsAdmin: Boolean; var ErrorMsg: text[250]; var ErrorCode: text[30]; var ResponsibilityCenter: Code[10];
        var RouteNo: Code[10]; var LoadRequestPrefix: code[6]; var CustomerTransactionPrefix: code[6]; var AppSessionID: Guid): Boolean
    var
        AppUser: Record "Application User ELA";
        UserSetup: Record "User Setup";
        WarehouseEmployee: Record "Warehouse Employee";
        SpecialEquipment: Record "Special Equipment";
        ENErrorCodes: Enum "Error Code ELA";
    begin

        UserSetup.RESET;
        UserSetup.SETRANGE(UserSetup."User ID", DeviceAcctID);
        IF UserSetup.FINDFIRST THEN BEGIN
            IF NOT UserSetup."Use For App. Auth. ELA" THEN BEGIN
                IsAdmin := FALSE;
                ErrorMsg := STRSUBSTNO(TEXT14229207, DeviceAcctID);
                ErrorCode := FORMAT(ENErrorCodes::NotEnabled); //need to see this.
                EXIT(false)
            END;

            IF AppUser.GET(ApplicationType, AppUserID) THEN BEGIN
                IF AppUser."PIN Code" <> AppUserPIN THEN BEGIN
                    ErrorMsg := STRSUBSTNO(TEXT14229201, AppUserID);
                    ErrorCode := FORMAT(ENErrorCodes::InvalidPin);// ErrorCodes::InvalidPin.;
                    EXIT(false)
                END;

                IF AppUser.Blocked THEN BEGIN
                    ErrorMsg := STRSUBSTNO(TEXT14229203, AppUserID);
                    ErrorCode := FORMAT(ENErrorCodes::Blocked); // //ErrorCodes::Blocked;
                    EXIT(false)
                END;

                IsAdmin := AppUser."Is Admin";
                ResponsibilityCenter := AppUser."DSD Responsibility Center";
                RouteNo := AppUser."DSD Route No.";
                LoadRequestPrefix := AppUser."DSD Load Order Prefix";
                CustomerTransactionPrefix := AppUser."DSD Transaction Prefix";
                // Permission := WMSUser.Permission;

                CreateSession(AppUserID, CompanyCode, ApplicationType, DeviceAcctID, DeviceAppVersion, AppSessionID, ErrorMsg, ErrorCode);
                EXIT(true);
            END ELSE BEGIN
                ErrorMsg := STRSUBSTNO(TEXT14229200, AppUserID, ApplicationType);
                ErrorCode := FORMAT(ENErrorCodes::NotEnabled); //ErrorCodes::NotEnabled;
                EXIT(false)
            END;
        END ELSE BEGIN
            IsAdmin := FALSE;
            ErrorMsg := STRSUBSTNO(TEXT14229202, DeviceAcctID, ApplicationType);
            ErrorCode := FORMAT(ENErrorCodes::NotEnabled); // ErrorCodes::NotEnabled;
            EXIT(false)
        END;
    end;

    local procedure CreateSession(AppUserID: Code[10]; CompanyCode: Code[20]; AppCode: Code[10]; DeviceAcctID: Code[10]; DeviceAppVersion: Text[10];
       var AppSessionId: Guid; var ErrorMsg: Text[250]; var ErrorCode: text[30]): Boolean
    var
        AppRole: Record "App. Role ELA";
        AppSession: Record "Application Session ELA";
        ErrorCodes: Enum "Error Code ELA";
    begin
        AppSession.RESET;
        AppSession.SETRANGE(AppSession."App. User ID", AppUserID);
        AppSession.SetRange(AppSession."App. Code", AppCode);
        IF NOT AppSession.FINDFIRST THEN BEGIN
            AppSessionId := LocCreateSessoin(AppUserID, CompanyCode, AppCode, DeviceAcctID, DeviceAppVersion);
            WMSJobMgmt.AssignJobs(AppUserID);
            ErrorMsg := '';
            EXIT(TRUE);
        END ELSE BEGIN
            IF AppSession."Device Acct. ID" <> DeviceAcctID THEN BEGIN
                CLEAR(AppSessionId);
                ErrorMsg := STRSUBSTNO(TEXT14229204, AppUserID, AppSession."Device Acct. ID");
                ErrorCode := FORMAT(ErrorCodes::Duplicate);
                EXIT(FALSE);
            END;

            IF NOT IsUserSessionActive(AppSession."Session ID", AppUserID) THEN BEGIN
                IF AppSession."Device Acct. ID" = DeviceAcctID THEN BEGIN
                    ClearSession(AppSession."Session ID", AppUserID);
                    AppSessionId := LocCreateSessoin(AppUserID, CompanyCode, AppCode, DeviceAcctID, DeviceAppVersion);
                    WMSJobMgmt.AssignJobs(AppUserID);
                    EXIT(TRUE);
                END ELSE BEGIN
                    ErrorMsg := StrSubstNo(TEXT14229204, AppUserID, AppSession."Device Acct. ID");
                    ErrorCode := Format(ErrorCodes::Duplicate);
                    EXIT(FALSE);
                END;
            END ELSE BEGIN
                ClearSession(AppSession."Session ID", AppUserID);
                AppSessionId := LocCreateSessoin(AppUserID, CompanyCode, AppCode, DeviceAcctID, DeviceAppVersion);
                ErrorMsg := '';
                EXIT(TRUE);
            END;
        END;
    end;

    /// <summary>
    /// LocCreateSessoin.
    /// </summary>
    /// <param name="AppUserID">Code[10].</param>
    /// <param name="AppCode">Code[10].</param>
    /// <param name="DeviceAcctID">Code[10].</param>
    /// <param name="DeviceAppVersoin">Text[10].</param>
    /// <returns>Return value of type Guid.</returns>
    local procedure LocCreateSessoin(AppUserID: Code[10]; CompanyCode: code[20]; AppCode: Code[10]; DeviceAcctID: Code[10]; DeviceAppVersoin: Text[10]): Guid
    var
        AppRole: Record "App. Role ELA";
        AppSession: Record "Application Session ELA";
    begin
        AppSession.INIT;
        AppSession."Session ID" := CREATEGUID;
        AppSession."App. User ID" := AppUserID;
        AppSession."App. Code" := AppCode;
        AppSession."Signed In Company" := CompanyCode;
        //WMSUserSession."Location Code" := Location;
        AppSession."Device Acct. ID" := DeviceAcctID;
        AppSession."Device Version" := DeviceAppVersoin;
        AppSession.INSERT(TRUE);
        EXIT(AppSession."Session ID");
    end;

    /// <summary>
    /// UpdateUserPIN.
    /// </summary>
    /// <param name="AppUserID">code[10].</param>
    /// <param name="AppCode">option.</param>
    /// <param name="OldPinCode">Code[4].</param>
    /// <param name="NewPinCode">Code[4].</param>
    /// <param name="ErrorMessage">Text[250].</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure UpdateUserPIN(AppUserID: code[10]; AppCode: code[10]; OldPinCode: Code[4]; NewPinCode: Code[4]; ErrorMessage: Text[250]): Boolean
    var
        AppUser: Record "Application User ELA";
    begin
        AppUser.RESET;
        AppUser.SETRANGE(AppUser."User ID", UserID);
        AppUser.SetRange("App. Code", AppCode);
        IF AppUser.FINDFIRST THEN BEGIN
            IF AppUser."PIN Code" = FORMAT(OldPinCode) THEN BEGIN
                AppUser."PIN Code" := FORMAT(NewPinCode);
                AppUser.MODIFY;
                EXIT(TRUE);
            END ELSE BEGIN
                ErrorMessage := TEXT14229206; //TEXT50006;
                EXIT(FALSE);
            END;
        END ELSE BEGIN
            ErrorMessage := STRSUBSTNO(TEXT14229202, UserId, AppCode);  //TEXT50002, UserID);
            EXIT(FALSE);
        END;

    end;

    /// <summary>
    /// ClearAllInactiveAppSessions.
    /// </summary>
    procedure ClearAllInactiveAppSessions()
    var
        AppSetup: Record "Application Setup ELA";
        ENAppSession: Record "Application Session ELA";
    begin
        AppSetup.get;
        ENAppSession.RESET;
        IF ENAppSession.FINDSET THEN
            REPEAT
                IF TIME - ENAppSession."Last Activity Time" > AppSetup."App. Login Time Out" THEN
                    ClearSession(ENAppSession."Session ID", ENAppSession."App. User ID");
            UNTIL ENAppSession.NEXT = 0;
    end;

    /// <summary>
    /// ClearSession.
    /// </summary>
    /// <param name="AppSessionID">Guid.</param>
    /// <param name="AppUserID">code[10].</param>
    procedure ClearSession(AppSessionID: Guid; AppUserID: code[10])
    var
        AppUserSession: Record "Application Session ELA";
        WhseActLine: Record "Warehouse Activity Line";
        AppRole: Record "App. Role ELA";
        AppSetup: Record "Application Setup ELA";
    begin
        IF AppUserSession.GET(AppSessionID) THEN BEGIN
            AppSetup.GET;
            IF AppRole.GET(AppUserSession."Role Code") THEN;
            IF AppSetup."Clear Assignments On Logout" OR AppRole."Auto Assign Jobs" THEN
                WMSJobMgmt.ClearAssignedJobs(AppUserSession."App. User ID");
            AppUserSession.DELETE;
        END;
    end;

    /// <summary>
    /// IsUserSessionActive.
    /// </summary>
    /// <param name="AppSessionID">GUID.</param>
    /// <param name="AppuserID">Code[10].</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure IsUserSessionActive(AppSessionID: GUID; AppuserID: Code[10]): Boolean
    var
        AppUserSession: Record "Application Session ELA";
        AppSetup: Record "Application Setup ELA";
    begin
        IF AppUserSession.GET(AppSessionID) THEN BEGIN
            AppSetup.GET;
            IF AppUserSession."Date Logged In" = TODAY THEN BEGIN
                IF TIME - AppUserSession."Last Activity Time" < AppSetup."App. Login Time Out" THEN BEGIN
                    AppUserSession."Date Logged In" := TODAY;
                    AppUserSession."Last Activity Time" := TIME;
                    AppUserSession.MODIFY;
                    EXIT(TRUE);
                END ELSE
                    EXIT(FALSE);
            END ELSE BEGIN
                IF AppUserSession."Date Logged In" <> TODAY THEN BEGIN
                    ClearSession(AppUserSession."Session ID", AppuserID);
                    EXIT(FALSE);
                END ELSE
                    EXIT(FALSE);
            END;
        END ELSE
            EXIT(FALSE);
    end;

    /// <summary>
    /// UpdateSessionInfo.
    /// </summary>
    /// <param name="AppSessionID">GUID.</param>
    /// <param name="AppUserID">Code[10].</param>
    /// <param name="AppRoleID">Code[20].</param>
    /// <param name="SpecialEquipment">Code[10].</param>
    /// <param name="LocationCode">Code[20].</param>
    procedure UpdateSessionInfo(AppSessionID: GUID; AppUserID: Code[10]; AppRoleID: Code[20]; SpecialEquipment: Code[10]; LocationCode: Code[20])
    var
        AppSession: Record "Application Session ELA";
        AppJobMgt: Codeunit "App. Job Mgmt. ELA";
    begin
        IF AppSession.GET(AppSessionID) THEN BEGIN
            AppSession."Equipment Code" := SpecialEquipment;
            AppSession."Role Code" := AppRoleID;
            AppSession."Signed In Location" := LocationCode;
            AppSession.MODIFY(TRUE);
            AppJobMgt.AssignJobs(AppUserID);
        END ELSE
            ERROR(TEXT14229205);
    end;
}
