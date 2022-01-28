//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Codeunit EN App. Job Mgmt. (ID 14229202).
/// </summary>
codeunit 14229221 "App. Job Mgmt. ELA"
{

    /// <summary>
    /// ClearAssignedJobs.
    /// </summary>
    /// <param name="AppUserID">code[10].</param>
    procedure ClearAssignedJobs(AppUserID: code[10])
    var
        WhseActLine: Record "Warehouse Activity Line";
    begin

        WhseActLine.RESET;
        // WhseActLine.SETRANGE("Assigned To", WMSUserID);
        IF WhseActLine.FINDSET THEN
            REPEAT
                // WhseActLine.VALIDATE("Assigned To", '');
                WhseActLine.MODIFY;
            UNTIL WhseActLine.NEXT = 0;
    end;

    /// <summary>
    /// AssignJobs.
    /// </summary>
    /// <param name="AppUserID">Code[10].</param>
    procedure AssignJobs(AppUserID: Code[10])
    var
        AppRole: Record "App. Role ELA";
        AppSession: Record "Application Session ELA";
        WhseActLine: Record "Warehouse Activity Line";
        UserRoleFilter: Text[255];
        DoAutoAssign: Boolean;
    // WhseServices : Codeunit "EN WMS Services"        
    begin
        AppSession.RESET;
        AppSession.SETRANGE(AppSession."App. User ID", AppUserID);
        IF AppSession.FINDFIRST THEN BEGIN
            AppRole.GetRoleFilter(AppSession."Role Code", DoAutoAssign, UserRoleFilter);
            IF DoAutoAssign THEN BEGIN
                WhseActLine.RESET;
                // WhseActLine.SETRANGE(Prioritized, TRUE);
                // WhseActLine.SETFILTER("Assigned Role", UserRoleFilter);
                // WhseActLine.SETFILTER("Assigned To", '=%1', WMSUserID);
                IF WhseActLine.FINDFIRST THEN
                    EXIT;

                WhseActLine.RESET;
                // WhseActLine.SETRANGE(Prioritized, TRUE);
                // WhseActLine.SETFILTER("Assigned Role", UserRoleFilter);
                // WhseActLine.SETFILTER("Assigned To", '=%1', '');
                IF WhseActLine.FINDFIRST THEN BEGIN
                    // WhseActLine.VALIDATE("Assigned To", WMSUserID);
                    WhseActLine.MODIFY;
                END ELSE BEGIN
                    //WMSActLines.RESET;
                    // WhseActLine.SETRANGE(Prioritized, FALSE);
                    //WMSActLines.SETFILTER("Assigned Role",UserRoleFilter);
                    //WMSActLines.SETFILTER("Assigned To",'=%1','');
                    IF WhseActLine.FINDFIRST THEN BEGIN
                        // WhseActLine.VALIDATE("Assigned To", WMSUserID);
                        WhseActLine.MODIFY;
                        // WhseActLine.ResetPutawayAutoFill(WhseActLine."No.");  
                    END;
                END;
            END;
        END;
    end;

}
