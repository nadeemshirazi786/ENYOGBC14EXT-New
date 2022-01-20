codeunit 14229800 "PM Management ELA"
{
    trigger OnRun()
    begin
    end;

    var
        JFText0001: Label 'Would you like to create a new version from %1, Version %2?';
        JFText0002: Label 'Version %1 for %2 has been created.';
        JFText0003: Label 'PM Work Order %1 has been created.';
        JFText0004: Label 'Sales Return %1, Line %1 has no item tracking lines defined.  Do you wish to create the Audit without a %3 / %4?';
        JFText0005: Label 'Do you want to Create Work Orders from the %1 PM Planning Worksheet?';
        gblnSuppressMessages: Boolean;

    [Scope('Internal')]
    procedure GetActiveVersion(pcodPMProcedureCode: Code[20]): Code[10]
    var
        lrecPMProcedure: Record "PM Procedure Header ELA";
    begin
        IF pcodPMProcedureCode = '' THEN
            EXIT('');

        lrecPMProcedure.SETCURRENTKEY(Code, Status, "Starting Date", "Version No.");
        lrecPMProcedure.SETRANGE(Code, pcodPMProcedureCode);
        lrecPMProcedure.SETRANGE(Status, lrecPMProcedure.Status::Certified);
        lrecPMProcedure.SETFILTER("Starting Date", '..%1', WORKDATE);
        IF lrecPMProcedure.FINDLAST THEN;

        EXIT(lrecPMProcedure."Version No.");
    end;

    [Scope('Internal')]
    procedure CreateNewVersion(precPMProcedure: Record "PM Procedure Header ELA")
    var
        lrecPMProcedure: Record "PM Procedure Header ELA";
        lrecPMProcedure2: Record "PM Procedure Header ELA";
        lrecPMProcLines: Record "PM Procedure Line ELA";
        lrecPMProcLines2: Record "PM Procedure Line ELA";
        lrecPMPItemCons: Record "PM Item Consumption ELA";
        lrecPMPItemCons2: Record "PM Item Consumption ELA";
        lrecPMPResmentReq: Record "PM Resource ELA";
        lrecPMPResmentReq2: Record "PM Resource ELA";
        lrecPMProcComments: Record "PM Proc. Comment ELA";
        lrecPMProcComments2: Record "PM Proc. Comment ELA";
    begin
        IF NOT CONFIRM(JFText0001, TRUE, precPMProcedure.Code, precPMProcedure."Version No.") THEN
            EXIT;
        WITH precPMProcedure DO BEGIN
            lrecPMProcedure.GET(Code, "Version No.");
            //FindLastVersion;
            lrecPMProcedure2.SETRANGE(Code, Code);
            IF lrecPMProcedure2.FINDLAST THEN;

            lrecPMProcedure."Version No." := INCSTR(lrecPMProcedure2."Version No.");
            IF lrecPMProcedure."Version No." = '' THEN
                lrecPMProcedure."Version No." := '1';
            lrecPMProcedure."Last Work Order Date" := 0D;
            lrecPMProcedure.Status := lrecPMProcedure.Status::"Under Development";
            lrecPMProcedure.INSERT(TRUE);

            //-- Copy Links from last version
            lrecPMProcedure.COPYLINKS(lrecPMProcedure2);

            //Insert PM Work Order Lines
            lrecPMProcLines.SETRANGE("PM Procedure Code", Code);
            lrecPMProcLines.SETRANGE("Version No.", "Version No.");
            IF lrecPMProcLines.FINDSET THEN
                REPEAT
                    lrecPMProcLines2 := lrecPMProcLines;
                    lrecPMProcLines2."Version No." := lrecPMProcedure."Version No.";
                    lrecPMProcLines2.INSERT(TRUE);

                    //-- Copy Links
                    lrecPMProcLines2.COPYLINKS(lrecPMProcLines);
                UNTIL lrecPMProcLines.NEXT = 0;

            //Insert Item Consumption
            lrecPMPItemCons.SETRANGE("PM Procedure Code", Code);
            lrecPMPItemCons.SETRANGE("Version No.", "Version No.");
            IF lrecPMPItemCons.FINDSET THEN
                REPEAT
                    lrecPMPItemCons2 := lrecPMPItemCons;
                    lrecPMPItemCons2."Version No." := lrecPMProcedure."Version No.";
                    lrecPMPItemCons2.INSERT(TRUE);

                    //-- Copy Links
                    lrecPMPItemCons2.COPYLINKS(lrecPMPItemCons);
                UNTIL lrecPMPItemCons.NEXT = 0;

            //Insert Equipment Requirements
            lrecPMPResmentReq.SETRANGE("PM Procedure Code", Code);
            lrecPMPResmentReq.SETRANGE("Version No.", "Version No.");
            IF lrecPMPResmentReq.FINDSET THEN
                REPEAT
                    lrecPMPResmentReq2 := lrecPMPResmentReq;
                    lrecPMPResmentReq2."Version No." := lrecPMProcedure."Version No.";
                    lrecPMPResmentReq2.INSERT(TRUE);

                    //-- Copy Links
                    lrecPMPResmentReq2.COPYLINKS(lrecPMPResmentReq);
                UNTIL lrecPMPResmentReq.NEXT = 0;

            //Insert Comments
            lrecPMProcComments.SETRANGE("PM Procedure Code", Code);
            lrecPMProcComments.SETRANGE("Version No.", "Version No.");
            IF lrecPMProcComments.FINDSET THEN
                REPEAT
                    lrecPMProcComments2 := lrecPMProcComments;
                    lrecPMProcComments2."Version No." := lrecPMProcedure."Version No.";
                    lrecPMProcComments2.INSERT(TRUE);
                UNTIL lrecPMProcComments.NEXT = 0;

        END;

        IF NOT SuppressMessage THEN
            MESSAGE(JFText0002, lrecPMProcedure."Version No.", lrecPMProcedure.Code);
    end;

    [Scope('Internal')]
    procedure CreatePMWOFromVersion(var pcodPMWONo: Code[20]; precPMProcedure: Record "PM Procedure Header ELA")
    var
        lrecPMWOHeader: Record "Work Order Header ELA";
        lrecPMProcedure: Record "PM Procedure Header ELA";
        lrecPMProcedure2: Record "PM Procedure Header ELA";
        lrecPMProcLines: Record "PM Procedure Line ELA";
        lrecPMWOLine: Record "Work Order Line ELA";
        lrecPMPItemCons: Record "PM Item Consumption ELA";
        lrecPMWOItemCons: Record "WO Item Consumption ELA";
        lrecPMPResmentReq: Record "PM Resource ELA";
        lrecPMWOResource: Record "WO Resource ELA";
        lrecPMProcComments: Record "PM Proc. Comment ELA";
        lrecPMWOComments: Record "WO Comment ELA";
        lrecPMSetup: Record "PM Setup ELA";
    begin
        lrecPMSetup.GET;

        WITH precPMProcedure DO BEGIN
            IF pcodPMWONo = '' THEN BEGIN
                lrecPMWOHeader.INIT;
                lrecPMWOHeader.TRANSFERFIELDS(precPMProcedure);
                lrecPMWOHeader."PM Procedure Code" := precPMProcedure.Code;
                lrecPMWOHeader."PM Work Order No." := '';
                lrecPMWOHeader.INSERT(TRUE);
            END ELSE BEGIN
                lrecPMWOHeader.GET(pcodPMWONo);
                lrecPMWOHeader.TRANSFERFIELDS(precPMProcedure);
                lrecPMWOHeader."PM Procedure Code" := precPMProcedure.Code;
                lrecPMWOHeader."PM Work Order No." := pcodPMWONo;
                lrecPMWOHeader.MODIFY(TRUE);
            END;

            //-- Copy Links
            lrecPMWOHeader.COPYLINKS(precPMProcedure);

            pcodPMWONo := lrecPMWOHeader."PM Work Order No.";

            //Insert PM Work Order Lines
            lrecPMProcLines.SETRANGE("PM Procedure Code", Code);
            lrecPMProcLines.SETRANGE("Version No.", "Version No.");
            IF lrecPMProcLines.FINDSET THEN
                REPEAT
                    lrecPMWOLine.TRANSFERFIELDS(lrecPMProcLines);
                    lrecPMWOLine."PM Procedure Code" := precPMProcedure.Code;
                    lrecPMWOLine."PM Work Order No." := pcodPMWONo;
                    lrecPMWOLine."Code Value" := '';
                    lrecPMWOLine."Text Value" := '';
                    lrecPMWOLine."Decimal Value" := 0;
                    lrecPMWOLine."Date Value" := 0D;
                    lrecPMWOLine."Boolean Value" := FALSE;
                    lrecPMWOLine.INSERT(TRUE);

                    //-- Copy Links
                    lrecPMWOLine.COPYLINKS(lrecPMProcLines);
                UNTIL lrecPMProcLines.NEXT = 0;

            //Insert Item Consumption
            lrecPMPItemCons.SETRANGE("PM Procedure Code", Code);
            lrecPMPItemCons.SETRANGE("Version No.", "Version No.");
            IF lrecPMPItemCons.FINDSET THEN
                REPEAT
                    lrecPMWOItemCons.TRANSFERFIELDS(lrecPMPItemCons);
                    lrecPMWOItemCons."PM Procedure Code" := precPMProcedure.Code;
                    lrecPMWOItemCons."PM Work Order No." := pcodPMWONo;
                    lrecPMWOItemCons."Qty. to Consume" := lrecPMPItemCons."Planned Usage Qty.";
                    lrecPMWOItemCons.INSERT(TRUE);

                    //-- Copy Links
                    lrecPMWOItemCons.COPYLINKS(lrecPMPItemCons);
                UNTIL lrecPMPItemCons.NEXT = 0;

            //Insert Equipment Requirements
            lrecPMPResmentReq.SETRANGE("PM Procedure Code", Code);
            lrecPMPResmentReq.SETRANGE("Version No.", "Version No.");
            IF lrecPMPResmentReq.FINDSET THEN
                REPEAT
                    lrecPMWOResource.TRANSFERFIELDS(lrecPMPResmentReq);
                    lrecPMWOResource."PM Procedure Code" := precPMProcedure.Code;
                    lrecPMWOResource."PM Work Order No." := pcodPMWONo;
                    lrecPMWOResource.INSERT(TRUE);

                    //-- Copy Links
                    lrecPMWOResource.COPYLINKS(lrecPMPResmentReq);
                UNTIL lrecPMPResmentReq.NEXT = 0;

            //Insert Equipment Requirements
            lrecPMProcComments.SETRANGE("PM Procedure Code", Code);
            lrecPMProcComments.SETRANGE("Version No.", "Version No.");
            IF lrecPMProcComments.FIND('-') THEN
                REPEAT
                    lrecPMWOComments.TRANSFERFIELDS(lrecPMProcComments);
                    lrecPMWOComments."PM Procedure Code" := precPMProcedure.Code;
                    lrecPMWOComments."PM Work Order No." := pcodPMWONo;
                    lrecPMWOComments.INSERT(TRUE);
                UNTIL lrecPMProcComments.NEXT = 0;
        END;

        IF NOT SuppressMessage THEN
            MESSAGE(JFText0003, lrecPMWOHeader."PM Work Order No.")
    end;

    [Scope('Internal')]
    procedure SuggestPMWOFaults(var precPMWOLine: Record "Work Order Line ELA")
    var
        lrecPMProcedure: Record "PM Procedure Header ELA";
        lrecPMPFaults: Record "WO Line Result ELA";
        lrecPMWOFaults: Record "Work Order Fault ELA";
    begin
        lrecPMProcedure.GET(precPMWOLine."PM Procedure Code", precPMWOLine."PM Proc. Version No.");

        //FindLastVersion??

        //Insert Line's Possible Faults
        lrecPMPFaults.SETRANGE("PM Work Order No.", lrecPMProcedure.Code);
        lrecPMPFaults.SETRANGE("PM Proc. Version No.", lrecPMProcedure."Version No.");
        lrecPMPFaults.SETRANGE("PM WO Line No.", precPMWOLine."Line No.");

        IF lrecPMPFaults.FIND('-') THEN
            REPEAT
                lrecPMWOFaults.TRANSFERFIELDS(lrecPMPFaults);
                lrecPMWOFaults."PM Procedure Code" := lrecPMProcedure.Code;
                lrecPMWOFaults."PM Proc. Version No." := lrecPMProcedure."Version No.";
                lrecPMWOFaults."PM Work Order No." := precPMWOLine."PM Work Order No.";
                lrecPMWOFaults.INSERT(TRUE);

                //-- Copy Links
                lrecPMWOFaults.COPYLINKS(lrecPMPFaults);
            UNTIL lrecPMPFaults.NEXT = 0;
    end;

    [Scope('Internal')]
    procedure CheckName(pcodCurrWkshtBatchName: Code[10])
    var
        lrecPMWkshtBatch: Record "PM Worksheet Batch ELA";
    begin
        lrecPMWkshtBatch.GET(pcodCurrWkshtBatchName);
    end;

    [Scope('Internal')]
    procedure SetName(pcodCurrWkshtBatchName: Code[10]; var precPMWksht: Record "PM Planning Worksheet ELA")
    begin
        precPMWksht.FILTERGROUP := 2;
        precPMWksht.SETRANGE("Worksheet Batch Name", pcodCurrWkshtBatchName);
        precPMWksht.FILTERGROUP := 0;
        IF precPMWksht.FIND('-') THEN;
    end;

    [Scope('Internal')]
    procedure LookupName(var pcodCurrWkshtBatchName: Code[10]; var precPMWksht: Record "PM Planning Worksheet ELA"): Boolean
    var
        lrecPMWkshtBatch: Record "PM Worksheet Batch ELA";
    begin
        COMMIT;
        IF precPMWksht.GETRANGEMAX("Worksheet Batch Name") <> '' THEN
            lrecPMWkshtBatch.Name := precPMWksht.GETRANGEMAX("Worksheet Batch Name")
        ELSE
            lrecPMWkshtBatch.Name := '';

        IF PAGE.RUNMODAL(0, lrecPMWkshtBatch) = ACTION::LookupOK THEN BEGIN
            pcodCurrWkshtBatchName := lrecPMWkshtBatch.Name;
            SetName(pcodCurrWkshtBatchName, precPMWksht);
        END;
    end;

    [Scope('Internal')]
    procedure CreatePMWOFromWksht(precPMPlanWksht: Record "PM Planning Worksheet ELA")
    var
        lrecPMWO: Record "Work Order Header ELA";
        lrecPMProcedure: Record "PM Procedure Header ELA";
    begin
        IF NOT CONFIRM(JFText0005, TRUE, precPMPlanWksht."Worksheet Batch Name") THEN
            EXIT;

        gblnSuppressMessages := TRUE;

        WITH precPMPlanWksht DO BEGIN
            SETRANGE("Worksheet Batch Name", "Worksheet Batch Name");
            IF FIND('-') THEN BEGIN
                REPEAT
                    CLEAR(lrecPMWO);
                    lrecPMWO."PM Procedure Code" := "PM Procedure Code";
                    lrecPMWO."PM Proc. Version No." := "Version No.";
                    lrecPMProcedure.GET("PM Procedure Code", "Version No.");

                    //Prime the QP Setup record with the desired no. series
                    lrecPMProcedure."PM Work Order No. Series" := "PM Work Order No. Series";

                    CreatePMWOFromVersion(lrecPMWO."PM Work Order No.", lrecPMProcedure);

                    lrecPMWO.Description := Description;
                    lrecPMWO."Person Responsible" := "Person Responsible";
                    lrecPMWO."PM Group Code" := "PM Group Code";
                    lrecPMWO."PM Work Order No. Series" := "PM Work Order No. Series";
                    lrecPMWO."Work Order Date" := "Work Order Date";
                    lrecPMWO.Type := Type;
                    lrecPMWO.VALIDATE("No.", "No.");
                    lrecPMWO."Posting Date" := "Work Order Date";
                    lrecPMWO."Work Order Freq." := "Work Order Freq.";
                    lrecPMWO."PM Scheduling Type" := "PM Scheduling Type";
                    lrecPMWO."Evaluation Qty." := "Evaluation Qty.";
                    lrecPMWO."Schedule at %" := "Schedule at %";
                    lrecPMWO."Maintenance Time" := "Maintenance Time";
                    lrecPMWO."Maintenance UOM" := "Maintenance UOM";

                    lrecPMWO.MODIFY;
                UNTIL NEXT = 0;
                DELETEALL;
            END;
        END;
    end;

    [Scope('Internal')]
    procedure SuppressMessage(): Boolean
    var
        lrecPMSetup: Record "PM Setup ELA";
    begin
        IF gblnSuppressMessages THEN
            EXIT(TRUE);
        EXIT(lrecPMSetup."Notify User on Order Creation");
    end;

    [Scope('Internal')]
    procedure CreateAbsence(precWorkOrder: Record "Work Order Header ELA")
    var
        lrecFA: Record "Fixed Asset";
        lrecMachCenter: Record "Machine Center";
        lrecWorkCenter: Record "Work Center";
        lrecCalendarAbsEntry: Record "Calendar Absence Entry";
        ljfText000: Label 'A Calendar Absence is already recorded for %1 No. %2 at this date and time.\Do you want to overwrite it?';
        lrecCalendarAbsEntry2: Record "Calendar Absence Entry";
        lrecCalEntry: Record "Calendar Entry";
        lcodNoToUse: Code[20];
        ljfText001: Label 'PM Work Order %1';
        lcduCalAbsenceMgt: Codeunit "Calendar Absence Management";
        lcduCalMgmt: Codeunit CalendarManagement;
        lintTimeFactor: Integer;
        ltmeEndingTime: Time;
        lblnCreateEntryOverMidnight: Boolean;
        ljfText002: Label 'Process cancelled by user.';
    begin
        IF precWorkOrder."PM Work Order No." = '' THEN
            EXIT;

        //-- Delete existing absence
        DeleteAbsence(precWorkOrder);

        //-- Create New absence
        lrecCalendarAbsEntry.INIT;

        CASE precWorkOrder.Type OF
            precWorkOrder.Type::"Machine Center":
                BEGIN
                    lrecCalendarAbsEntry.VALIDATE("Capacity Type", lrecCalendarAbsEntry."Capacity Type"::"Machine Center");

                    lcodNoToUse := precWorkOrder."No.";
                END;
            precWorkOrder.Type::"Work Center":
                BEGIN
                    lrecCalendarAbsEntry.VALIDATE("Capacity Type", lrecCalendarAbsEntry."Capacity Type"::"Work Center");

                    lcodNoToUse := precWorkOrder."No.";
                END;
            precWorkOrder.Type::"Fixed Asset":
                BEGIN
                    lrecFA.GET(precWorkOrder."No.");

                    IF lrecFA."Link To Type" = lrecFA."Link To Type"::"Machine Center" THEN
                        lrecCalendarAbsEntry.VALIDATE("Capacity Type", lrecCalendarAbsEntry."Capacity Type"::"Machine Center")
                    ELSE
                        IF lrecFA."Link To Type" = lrecFA."Link To Type"::"Work Center" THEN
                            lrecCalendarAbsEntry.VALIDATE("Capacity Type", lrecCalendarAbsEntry."Capacity Type"::"Work Center")
                        ELSE
                            lrecFA.FIELDERROR("Link To Type");

                    lcodNoToUse := lrecFA."Link To No.";
                END;
            ELSE
                precWorkOrder.FIELDERROR(Type);
        END;

        lrecCalendarAbsEntry.VALIDATE("No.", lcodNoToUse);
        lrecCalendarAbsEntry.VALIDATE(Date, precWorkOrder."Work Order Date");

        precWorkOrder.TESTFIELD("Maintenance UOM");

        lintTimeFactor := lcduCalMgmt.TimeFactor(precWorkOrder."Maintenance UOM");

        CASE lrecCalendarAbsEntry."Capacity Type" OF
            lrecCalendarAbsEntry."Capacity Type"::"Machine Center":
                BEGIN
                    lrecMachCenter.GET(lrecCalendarAbsEntry."No.");
                    lrecMachCenter.TESTFIELD(Capacity);

                    //-- Set Starting Time to be at beginning of shift
                    lrecCalEntry.SETRANGE(Date, precWorkOrder."Work Order Date");
                    lrecCalEntry.SETRANGE("No.", lrecMachCenter."No.");
                    lrecCalEntry.SETRANGE("Capacity Type", lrecCalEntry."Capacity Type"::"Machine Center");

                    //-- We will throw an error here if no calendar entries have been defined
                    lrecCalEntry.FINDFIRST;

                    lrecCalendarAbsEntry.VALIDATE("Starting Time", lrecCalEntry."Starting Time");

                    ltmeEndingTime := lrecCalendarAbsEntry."Starting Time" + (precWorkOrder."Maintenance Time" * lintTimeFactor);

                    IF ltmeEndingTime < lrecCalendarAbsEntry."Starting Time" THEN
                        lblnCreateEntryOverMidnight := TRUE;

                    IF lblnCreateEntryOverMidnight THEN
                        lrecCalendarAbsEntry.VALIDATE("Ending Time", 235959T)
                    ELSE
                        lrecCalendarAbsEntry.VALIDATE("Ending Time", ltmeEndingTime);
                END;
            lrecCalendarAbsEntry."Capacity Type"::"Work Center":
                BEGIN
                    lrecWorkCenter.GET(lrecCalendarAbsEntry."No.");
                    lrecWorkCenter.TESTFIELD(Capacity);

                    //-- Set Starting Time to be at beginning of shift
                    lrecCalEntry.SETRANGE(Date, precWorkOrder."Work Order Date");
                    lrecCalEntry.SETRANGE("No.", lrecWorkCenter."No.");
                    lrecCalEntry.SETRANGE("Capacity Type", lrecCalEntry."Capacity Type"::"Work Center");

                    //-- We will throw an error here if no calendar entries have been defined
                    lrecCalEntry.FINDFIRST;

                    lrecCalendarAbsEntry.VALIDATE("Starting Time", lrecCalEntry."Starting Time");

                    ltmeEndingTime := lrecCalendarAbsEntry."Starting Time" + (precWorkOrder."Maintenance Time" * lintTimeFactor);

                    IF ltmeEndingTime < lrecCalendarAbsEntry."Starting Time" THEN
                        lblnCreateEntryOverMidnight := TRUE;

                    IF lblnCreateEntryOverMidnight THEN
                        lrecCalendarAbsEntry.VALIDATE("Ending Time", 235959T)
                    ELSE
                        lrecCalendarAbsEntry.VALIDATE("Ending Time", ltmeEndingTime);
                END;
        END;

        lrecCalendarAbsEntry.Description := STRSUBSTNO(ljfText001, precWorkOrder."PM Work Order No.");
        lrecCalendarAbsEntry."PM Work Order No." := precWorkOrder."PM Work Order No.";

        lrecCalendarAbsEntry.UpdateDatetime;

        IF NOT lrecCalendarAbsEntry.INSERT THEN
            IF CONFIRM(ljfText000, FALSE, lrecCalendarAbsEntry."Capacity Type", lrecCalendarAbsEntry."No.") THEN
                lrecCalendarAbsEntry.MODIFY
            ELSE
                ERROR(ljfText002);

        IF lblnCreateEntryOverMidnight THEN BEGIN
            lrecCalendarAbsEntry2.TRANSFERFIELDS(lrecCalendarAbsEntry);
            lrecCalendarAbsEntry2.Date := CALCDATE('+1D', lrecCalendarAbsEntry.Date);
            lrecCalendarAbsEntry2.VALIDATE("Starting Time", 000000T);
            lrecCalendarAbsEntry2.VALIDATE("Ending Time", ltmeEndingTime);

            IF NOT lrecCalendarAbsEntry2.INSERT THEN
                lrecCalendarAbsEntry2.MODIFY;
        END;

        lrecCalendarAbsEntry.RESET;
        lrecCalendarAbsEntry.SETRANGE("PM Work Order No.", precWorkOrder."PM Work Order No.");

        IF lrecCalendarAbsEntry.FINDSET THEN BEGIN
            REPEAT
                lcduCalAbsenceMgt.UpdateAbsence(lrecCalendarAbsEntry);
            UNTIL lrecCalendarAbsEntry.NEXT = 0;
        END;
    end;

    [Scope('Internal')]
    procedure DeleteAbsence(precWorkOrder: Record "Work Order Header ELA")
    var
        lrecCalendarAbsEntry: Record "Calendar Absence Entry";
        lrecCalEntry: Record "Calendar Entry";
    begin
        IF precWorkOrder."PM Work Order No." = '' THEN
            EXIT;

        lrecCalendarAbsEntry.SETRANGE("PM Work Order No.", precWorkOrder."PM Work Order No.");
        lrecCalendarAbsEntry.DELETEALL(TRUE);
    end;
}

