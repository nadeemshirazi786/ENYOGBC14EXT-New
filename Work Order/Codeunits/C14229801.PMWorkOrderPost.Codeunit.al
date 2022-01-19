codeunit 14229801 "PM Work Order-Post"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF8566SHR
    //   20100521 - Modified code in jfdoPostItemConsumption for Quantity (Base) calculation
    //            - Modified code to handle dimensions
    // 
    // JF10414SHR
    //   20101105 - Only create jnl lines for Item Consumption with a qty to consume
    // 
    // JF11568SHR
    //   20110203 - Testfield on 'posting date' since it is now available in the form

    Permissions = TableData 23019270 = imd,
                  TableData 23019271 = imd,
                  TableData 23019272 = imd,
                  TableData 23019273 = imd,
                  TableData 23019274 = imd,
                  TableData 23019275 = imd,
                  TableData 23019276 = imd;
    TableNo = 23019260;

    trigger OnRun()
    begin
        grecPMWOHeader := Rec;
        Code;
        Rec := grecPMWOHeader;
    end;

    var
        grecPMWOHeader: Record "23019260";
        grecFinPMWOHeader: Record "23019270";
        grecPMWOLine: Record "23019261";
        grecFinPMWOLine: Record "23019271";
        grecPMWOItemCons: Record "23019262";
        grecFinPMWOItemCons: Record "23019272";
        grecPMWOResource: Record "23019263";
        grecFinPMWORes: Record "23019273";
        grecPMWOComments: Record "23019264";
        grecFinPMWOComments: Record "23019274";
        grecItemJnlLine: Record "83";
        grecPMWOFault: Record "23019265";
        grecFinPMWOFault: Record "23019275";
        grecPMWOLineResult: Record "23019266";
        grecFinPMWOLineResult: Record "23019276";
        gcduWMSMgmt: Codeunit "7302";
        gcduWhseJnlPostLine: Codeunit "7301";

    [Scope('Internal')]
    procedure "Code"()
    begin
        WITH grecPMWOHeader DO BEGIN

            //Perform Check
            //<JF11568SHR>
            grecPMWOHeader.TESTFIELD("Posting Date");
            //</JF11568SHR>

            //Lock Tables
            /*
              IF grecFinPMWOHeader.FIND('+') THEN;
              grecFinPMWOHeader.LOCKTABLE;
              IF grecFinPMWOLine.FIND('+') THEN;
              grecFinPMWOLine.LOCKTABLE;
            */

            //Transfer Fields / Records
            grecFinPMWOHeader.INIT;
            grecFinPMWOHeader.TRANSFERFIELDS(grecPMWOHeader);
            grecFinPMWOHeader.INSERT;

            //-- Copy Links
            grecFinPMWOHeader.COPYLINKS(grecPMWOHeader);

            //Post Comments
            grecPMWOComments.SETRANGE("PM Work Order No.", "PM Work Order No.");
            IF grecPMWOComments.FINDSET THEN
                REPEAT
                    grecFinPMWOComments.TRANSFERFIELDS(grecPMWOComments);
                    grecFinPMWOComments.INSERT;
                UNTIL grecPMWOComments.NEXT = 0;


            grecPMWOLine.SETRANGE("PM Work Order No.", "PM Work Order No.");
            IF grecPMWOLine.FINDSET THEN
                REPEAT

                    //Check Line to be complete
                    grecPMWOLine.TESTFIELD("Test Complete", TRUE);

                    //Transfer Lines
                    grecFinPMWOLine.INIT;
                    grecFinPMWOLine.TRANSFERFIELDS(grecPMWOLine);
                    grecFinPMWOLine.INSERT;

                    //-- Copy Links
                    grecFinPMWOLine.COPYLINKS(grecPMWOLine);

                    //Transfer Result Lines
                    grecPMWOLineResult.SETRANGE("PM Work Order No.", "PM Work Order No.");
                    grecPMWOLineResult.SETRANGE("PM WO Line No.", grecPMWOLine."Line No.");
                    IF grecPMWOLineResult.FINDSET THEN
                        REPEAT
                            grecFinPMWOLineResult.TRANSFERFIELDS(grecPMWOLineResult);
                            grecFinPMWOLineResult.INSERT;

                            //-- Copy Links
                            grecFinPMWOLineResult.COPYLINKS(grecPMWOLineResult);
                        UNTIL grecPMWOLineResult.NEXT = 0;

                    //Post Item Consumption
                    grecPMWOItemCons.SETRANGE("PM Work Order No.", "PM Work Order No.");
                    grecPMWOItemCons.SETRANGE("PM WO Line No.", grecPMWOLine."Line No.");
                    IF grecPMWOItemCons.FIND('-') THEN
                        REPEAT
                            grecFinPMWOItemCons.TRANSFERFIELDS(grecPMWOItemCons);
                            grecFinPMWOItemCons.INSERT;

                            //-- Copy Links
                            grecFinPMWOItemCons.COPYLINKS(grecPMWOItemCons);

                            //<JF10414SHR>
                            /*
                            jfdoPostItemConsumption(grecPMWOItemCons);
                            */
                            IF grecPMWOItemCons."Qty. to Consume" <> 0 THEN BEGIN
                                jfdoPostItemConsumption(grecPMWOItemCons);
                            END;
                        //</JF10414SHR>

                        UNTIL grecPMWOItemCons.NEXT = 0;

                    //Post Resource Usage
                    grecPMWOResource.SETRANGE("PM Work Order No.", "PM Work Order No.");
                    grecPMWOResource.SETRANGE("PM WO Line No.", grecPMWOLine."Line No.");
                    IF grecPMWOResource.FIND('-') THEN
                        REPEAT
                            grecFinPMWORes.TRANSFERFIELDS(grecPMWOResource);
                            grecFinPMWORes.INSERT;

                            //-- Copy Links
                            grecFinPMWORes.COPYLINKS(grecPMWOResource);

                            jfdoPostResConsumption(grecPMWOResource);
                        UNTIL grecPMWOResource.NEXT = 0;

                    //Transfer Fault information:
                    grecPMWOFault.SETRANGE("PM Work Order No.", "PM Work Order No.");
                    grecPMWOFault.SETRANGE("PM WO Line No.", grecPMWOLine."Line No.");
                    IF grecPMWOFault.FIND('-') THEN
                        REPEAT
                            grecFinPMWOFault.TRANSFERFIELDS(grecPMWOFault);
                            grecFinPMWOFault.INSERT;

                            //-- Copy Links
                            grecFinPMWOFault.COPYLINKS(grecPMWOFault);
                        UNTIL grecPMWOFault.NEXT = 0;

                UNTIL grecPMWOLine.NEXT = 0;

            //Delete Open Audit
            //Using true should take care of all related tables.
            grecPMWOHeader.DELETE(TRUE);   //-- Links deleted in DELETE trigger
        END;

    end;

    local procedure jfdoPostItemConsumption(precPMWOItemCons: Record "23019262"): Integer
    var
        lrecOriginalItemJnlLine: Record "83";
        lrecItem: Record "27";
        lrecItemUOM: Record "5404";
        lcduDimMgt: Codeunit "408";
        lcduItemJnlPostLine: Codeunit "22";
        lrecLocation: Record "14";
        lrecWhseJnlLine: Record "7311";
        lrecILE: Record "32";
    begin
        lrecItem.GET(precPMWOItemCons."Item No.");

        WITH precPMWOItemCons DO BEGIN
            grecPMWOHeader.TESTFIELD("Location Code");

            grecItemJnlLine.INIT;

            grecItemJnlLine.VALIDATE("Posting Date", grecPMWOHeader."Posting Date");
            grecItemJnlLine.VALIDATE("Document Date", grecPMWOHeader."Work Order Date");
            grecItemJnlLine.VALIDATE("Entry Type", grecItemJnlLine."Entry Type"::"Negative Adjmt.");

            grecItemJnlLine."Document No." := grecPMWOHeader."PM Work Order No.";

            grecItemJnlLine.VALIDATE("Item No.", "Item No.");
            grecItemJnlLine.VALIDATE("Variant Code", "Variant Code");

            grecItemJnlLine.VALIDATE("Location Code", grecPMWOHeader."Location Code");

            grecItemJnlLine.VALIDATE("Bin Code", "Bin Code");

            grecItemJnlLine.VALIDATE("Unit of Measure Code", "Unit of Measure");

            grecItemJnlLine.VALIDATE(Quantity, "Qty. to Consume");

            //<JF8566SHR>
            IF "Applies-to Entry" <> 0 THEN BEGIN
                grecItemJnlLine.VALIDATE("Applies-to Entry", "Applies-to Entry");

                lrecILE.GET("Applies-to Entry");
                grecItemJnlLine."Dimension Set ID" := lrecILE."Dimension Set ID";

                lcduDimMgt.UpdateGlobalDimFromDimSetID(grecItemJnlLine."Dimension Set ID",
                  grecItemJnlLine."Shortcut Dimension 1 Code", grecItemJnlLine."Shortcut Dimension 2 Code");
            END;
            //</JF8566SHR>

            lrecOriginalItemJnlLine := grecItemJnlLine;

            lcduItemJnlPostLine.RunWithCheck(grecItemJnlLine);

            //-- Post Whse. Journal
            lrecLocation.GET(grecItemJnlLine."Location Code");

            IF lrecLocation."Bin Mandatory" THEN BEGIN
                gcduWMSMgmt.CreateWhseJnlLine(grecItemJnlLine, 0, lrecWhseJnlLine, FALSE);
                gcduWMSMgmt.CheckWhseJnlLine(lrecWhseJnlLine, 1, 0, FALSE);
                gcduWhseJnlPostLine.RUN(lrecWhseJnlLine);
            END;
        END;
    end;

    [Scope('Internal')]
    procedure jfdoPostResConsumption(precPMWOResource: Record "23019263")
    var
        lrecResJnlLine: Record "207";
        lrecResource: Record "156";
        lcduResJnlLinePost: Codeunit "212";
    begin
        IF precPMWOResource.Type <> precPMWOResource.Type::Resource THEN
            EXIT;
        lrecResJnlLine.INIT;
        lrecResJnlLine."Document No." := grecPMWOHeader."PM Work Order No.";
        lrecResJnlLine."Entry Type" := lrecResJnlLine."Entry Type"::Usage;
        lrecResJnlLine."Posting Date" := grecPMWOHeader."Posting Date";
        lrecResJnlLine."Document Date" := grecPMWOHeader."Work Order Date";
        lrecResJnlLine."Resource No." := precPMWOResource."No.";
        lrecResJnlLine.Description := precPMWOResource.Description;
        lrecResJnlLine.Quantity := precPMWOResource.Quantity;
        lrecResJnlLine."Unit of Measure Code" := precPMWOResource."Unit of Measure";
        lrecResJnlLine."Work Type Code" := precPMWOResource."Work Type Code";
        lrecResJnlLine."Unit Cost" := precPMWOResource."Unit Cost";
        lrecResJnlLine."Total Cost" := precPMWOResource."Total Cost";
        lrecResJnlLine."Source Code" := 'RESJNL';
        lrecResJnlLine."Qty. per Unit of Measure" := 1;
        lrecResource.GET(precPMWOResource."No.");
        lrecResJnlLine."Gen. Prod. Posting Group" := lrecResource."Gen. Prod. Posting Group";

        lcduResJnlLinePost.RUN(lrecResJnlLine);
    end;

    [Scope('Internal')]
    procedure jfdoPostFAMaintEntry()
    var
        lrecMachineCenter: Record "99000758";
        lrecWorkCenter: Record "99000754";
        lrecFixedAsset: Record "5600";
        lrecFAJnlLine: Record "5621";
        lblnProcessFAMaint: Boolean;
    begin

        lblnProcessFAMaint := FALSE;

        CASE grecPMWOHeader.Type OF
            grecPMWOHeader.Type::"Machine Center":
                BEGIN
                    lrecMachineCenter.GET(grecPMWOHeader."No.");
                    IF lrecFixedAsset.GET(lrecMachineCenter."Fixed Asset No.") THEN
                        lblnProcessFAMaint := TRUE;
                END;
            grecPMWOHeader.Type::"Work Center":
                BEGIN
                    lrecWorkCenter.GET(grecPMWOHeader."No.");
                    IF lrecFixedAsset.GET(lrecWorkCenter."Fixed Asset No.") THEN
                        lblnProcessFAMaint := TRUE;
                END;
            grecPMWOHeader.Type::"Fixed Asset":
                BEGIN
                    IF lrecFixedAsset.GET(grecPMWOHeader."No.") THEN
                        lblnProcessFAMaint := TRUE;
                END;
        END;

        IF NOT lblnProcessFAMaint THEN
            EXIT;
    end;
}

