//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Codeunit EN WMS App Services (ID 14229201).
/// </summary>
codeunit 14229220 "WMS Activity Mgmt. ELA"
{

    var
        TEXT14229216: textconst ENU = 'Changed Bin Code %1 to Bin Code %2 by User %3';
        TEXT14229209: TextConst ENU = 'Bin %1 is blocked for %2';
        ActType: Option " ","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick";

        TEXT14229210: TextConst ENU = 'Offload status was set to %1 Reason: %2';
        TEXT14229211: TextConst ENU = '%1 User %2 %3';
        TEXT14229212: TextConst ENU = 'System is not allowed to over receive the qty';

        WhseActivityReg: Codeunit "Whse.-Activity-Register";

        FirstActNo: Code[20];
        LastActNo: Code[20];

        NameValBuff: Record "Name/Value Buffer";


    /// <summary>
    /// ChangePickBinCode.
    /// </summary>
    /// <param name="DocNo">Code[20].</param>
    /// <param name="DocLineNo">Integer.</param>
    /// <param name="NewZoneCode">Code[10].</param>
    /// <param name="NewBinCode">Code[10].</param>
    /// <param name="WMSUserID">Code[10].</param>
    procedure ChangePickBinCode(DocNo: Code[20]; DocLineNo: Integer; NewZoneCode: Code[10]; NewBinCode: Code[10]; WMSUserID: Code[10])
    var
        WhseActLine: Record "Warehouse Activity Line";
        Msg: text[255];
    begin
        IF WhseActLine.GET(WhseActLine."Activity Type"::Pick, DocNo, DocLineNo) THEN BEGIN
            IF WhseActLine."Action Type" = WhseActLine."Action Type"::Take THEN BEGIN
                Msg := STRSUBSTNO(TEXT14229216, WhseActLine."Bin Code", NewBinCode, WMSUserID);
                WhseActLine.VALIDATE("Zone Code", '');
                WhseActLine.VALIDATE("Bin Code", '');
                // WhseActLine.VALIDATE("Code Date", 0D);

                WhseActLine.VALIDATE("Zone Code", NewZoneCode);
                WhseActLine.VALIDATE("Bin Code", NewBinCode);
                WhseActLine.MODIFY;

                // AddWhseComment(DocNo,DocLineNo,0,2,WMSUserID,Msg);  
            END;
        END;
    end;


    /// <summary>
    /// ChangePutAwayBinCode.
    /// </summary>
    /// <param name="DocNo">Code[20].</param>
    /// <param name="DocLineNo">Integer.</param>
    /// <param name="NewZoneCode">Code[10].</param>
    /// <param name="NewBinCode">Code[10].</param>
    /// <param name="WMSUserID">Code[10].</param>
    procedure ChangePutAwayBinCode(DocNo: Code[20]; DocLineNo: Integer; NewZoneCode: Code[10]; NewBinCode: Code[10]; WMSUserID: Code[10])
    var
        WhseActLine: Record "Warehouse Activity Line";
        Msg: Text[255];
    begin
        IF WhseActLine.GET(WhseActLine."Activity Type"::"Put-away", DocNo, DocLineNo) THEN BEGIN
            IF WhseActLine."Action Type" = WhseActLine."Action Type"::Place THEN BEGIN
                Msg := STRSUBSTNO(TEXT14229216, WhseActLine."Bin Code", NewBinCode, WMSUserID);
                WhseActLine.VALIDATE("Zone Code", '');
                WhseActLine.VALIDATE("Bin Code", '');
                // WhseActLine.VALIDATE("Code Date",0D);

                WhseActLine.VALIDATE("Zone Code", NewZoneCode);
                WhseActLine.VALIDATE("Bin Code", NewBinCode);
                WhseActLine.MODIFY;

                //AddWhseComment(DocNo,DocLineNo,0,2,WMSUserID,Msg);   
            end;
        end;
    end;

    /// <summary>
    /// GetItemNo.
    /// </summary>
    /// <param name="BarCode">Code[20].</param>
    /// <param name="VAR ItemNo">Code[20].</param>
    /// <param name="VAR ItemUOMCode">Code[10].</param>
    /// <param name="VAR ItemDesc">Text[50].</param>
    /// <param name="VAR ExactMatch">Boolean.</param>
    procedure GetItemNo(BarCode: Code[20]; VAR ItemNo: Code[20]; VAR ItemUOMCode: Code[10]; VAR ItemDesc: Text[50]; VAR ExactMatch: Boolean)
    var
        Item: record Item;
        ItemUOM: Record "Item Unit of Measure";
    begin
        Item.RESET;
        Item.SETRANGE("Common Item No.", BarCode);
        IF Item.FINDSET THEN BEGIN
            ItemNo := Item."No.";
            ItemUOMCode := Item."Base Unit of Measure";
            ItemDesc := Item.Description;
            IF Item.COUNT = 1 THEN
                ExactMatch := TRUE
            ELSE
                ExactMatch := FALSE;
        END ELSE BEGIN
            ItemUOM.RESET;
            ItemUOM.SETFILTER("Std. Pack UPC/EAN Number ELA", '=%1', BarCode);
            IF ItemUOM.FINDFIRST THEN BEGIN
                ItemNo := ItemUOM."Item No.";
                ItemUOMCode := ItemUOM.Code;
                item.Get(ItemNo);
                ItemDesc := Item.Description;
                ExactMatch := TRUE;
            END;
        END;
    end;


    //*******************************************************************************************************WMS ACTIVITIES*******************************************************************

    /// <summary>
    /// BackOrderPickLine.
    /// </summary>
    /// <param name="ActivityType">Option.</param>
    /// <param name="DocNo">Code[20].</param>
    /// <param name="DocLineNo">Integer.</param>
    procedure BackOrderPickLine(ActivityType: Option; DocNo: Code[20]; DocLineNo: Integer)
    var
        WhseActLine: Record "Warehouse Activity Line";
        WhseActLine2: Record "Warehouse Activity Line";
        WhseActHdr: Record "Warehouse Activity Header";
    begin
        IF WhseActHdr.GET(ActivityType, DocNo) THEN BEGIN
            IF WhseActLine.GET(ActivityType, DocNo, DocLineNo) THEN BEGIN
                IF WhseActLine."Action Type" = WhseActLine."Action Type"::Take THEN BEGIN
                    WhseActLine.DELETE(TRUE);
                    WhseActLine2.RESET;
                    WhseActLine2.SETRANGE("Activity Type", ActivityType);
                    WhseActLine2.SETRANGE("No.", DocNo);
                    // WhseActLine2.SETRANGE("Parent Line No.", DocLineNo);
                    IF WhseActLine2.FINDFIRST THEN
                        WhseActLine2.DELETE(TRUE);

                    WhseActLine.RESET;
                    WhseActLine.SETRANGE("Activity Type", ActivityType);
                    WhseActLine.SETRANGE("No.", DocNo);
                    IF NOT WhseActLine.FINDFIRST THEN
                        WhseActHdr.DELETE;
                END;
            END;
        END;
    end;



    PROCEDURE UpdateWhseReceipt(ReceiptNo: Code[20]; OffLoadStatus: Integer; WMSUserID: Code[10]; Reason: Text[250]);
    VAR
        WhseRcpHdr: Record 7316;
        WhseCommentLine: Record 5770;
        Msg: Text[250];
    BEGIN
        //<<EN1.38
        IF WhseRcpHdr.GET(ReceiptNo) THEN BEGIN
            WhseRcpHdr."Off-load Status ELA" := OffLoadStatus;
            WhseRcpHdr.MODIFY;
            Msg := STRSUBSTNO(TEXT14229210, OffLoadStatus, Reason);
            AddWhseComment(ReceiptNo, 0, WhseCommentLine."Table Name"::"Whse. Receipt", 0, WMSUserID, Msg);  //EN1.46
        END;
        //>>EN1.38
    END;

    PROCEDURE AddWhseComment(DocumentNo: Code[20]; DocumentLineNo: Integer; TableName: Option "Whse. Activity Header","Whse. Receipt","Whse. Shipment","Internal Put-away","Internal Pick","Rgstrd. Whse. Activity Header","Posted Whse. Receipt","Posted Whse. Shipment","Posted Invt. Put-Away","Posted Invt. Pick",,,"Staged Pick","Bill Of Lading";
    Type: Option "","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick"; UserID: Code[20]; Message: Text[250]);
    VAR
        WhseCommentLine: Record 5770;
        NextCommentLineNo: Integer;
    BEGIN
        //<<EN1.36
        WhseCommentLine.RESET;
        WhseCommentLine.SETRANGE("Table Name", TableName);
        WhseCommentLine.SETRANGE(Type, Type);
        WhseCommentLine.SETRANGE("No.", DocumentNo);
        IF WhseCommentLine.FINDLAST THEN
            NextCommentLineNo := WhseCommentLine."Line No." + 10000
        ELSE
            NextCommentLineNo := 10000;

        WhseCommentLine.INIT;
        WhseCommentLine."Table Name" := TableName;
        WhseCommentLine.Type := Type; //WhseCommentLine.Type::" "; //EN1.46
        WhseCommentLine."No." := DocumentNo;
        WhseCommentLine."Line No." := NextCommentLineNo;
        WhseCommentLine.Date := TODAY;
        WhseCommentLine.Comment :=
          STRSUBSTNO(TEXT14229211, FORMAT(TIME), UserID, Message);
        IF WhseCommentLine.INSERT THEN;
        //>>EN1.36
    END;

    PROCEDURE UpdateWhseReceiptLine(ReceiptNo: Code[20]; LineNo: Integer; QtyToRec: Decimal; WMSUserID: Code[10]; VendPONum: Code[20]; NoOfPallets: Decimal; ExpirationDate: Date);
    VAR
        WhseReceiptHdr: Record 7316;
        WhseReceiptLine: Record 7317;
        CrossDockOpp: Record 5768;
        CrossDockMgt: Codeunit 5780;
        TrackingSpecs: Record 337;
    BEGIN
        //<<EN1.49
        IF WhseReceiptHdr.GET(ReceiptNo) THEN BEGIN
            WhseReceiptHdr."Vendor Shipment No." := VendPONum;
            WhseReceiptHdr.MODIFY;
        END;
        //>>EN1.49
        //<<EN1.06
        IF WhseReceiptLine.GET(ReceiptNo, LineNo) THEN BEGIN
            IF QtyToRec > WhseReceiptLine."Qty. Outstanding" THEN
                ERROR(TEXT14229212);

            WhseReceiptLine."Vendor Shipment No. ELA" := VendPONum; //<<EN1.49

            //<<EN1.33
            WhseReceiptLine."Received By ELA" := WMSUserID;
            WhseReceiptLine."Received Date ELA" := TODAY;
            WhseReceiptLine."Received Time ELA" := TIME;
            //>>EN1.33

            WhseReceiptLine.VALIDATE("Qty. to Receive", QtyToRec);
            WhseReceiptLine."No. of Pallets ELA" := NoOfPallets;

            WhseReceiptLine.MODIFY;

            TrackingSpecs.RESET;
            TrackingSpecs.SetRange("Source ID", WhseReceiptLine."Source No.");
            TrackingSpecs.SetRange("Source Ref. No.", WhseReceiptLine."Source Line No.");
            IF TrackingSpecs.FindSET() THEN BEGIN
                REPEAT
                    TrackingSpecs."Expiration Date" := ExpirationDate;
                    TrackingSpecs.Modify();
                UNTIL TrackingSpecs.NEXT = 0;
            END;
            IF TrackingSpecs.FINDLAST() THEN BEGIN
                TrackingSpecs."Qty. to Handle (Base)" := WhseReceiptLine."Qty. to Receive" * WhseReceiptLine."Qty. per Unit of Measure";
                TrackingSpecs.Modify();
            END;

            //  CrossDockMgt.MarkCrossDockLines(CrossDockOpp, '', ReceiptNo, WhseReceiptLine."Location Code");
            //TRIF WhseReceiptLine.GET(ReceiptNo, LineNo) THEN;
            //TRCanUseCrossDock := WhseReceiptLine."Can Use Cross-Dock ELA"; //EN1.11
        END;
        //>>EN1.06
    END;

    PROCEDURE UpdateWhseProdSOReceipt(ReceiptNo: Code[20]; ProductionSalesOrderNo: Code[20]; VendShipNo: Code[20]; PalletNo: Integer);
    VAR
        WhseReceiptHdr: Record 7316;
        WhseReceiptLine: Record 7317;
        CrossDockOpp: Record 5768;
        CrossDockMgt: Codeunit 5780;
    BEGIN
        //<<EN1.06
        //<<EN1.49
        IF WhseReceiptHdr.GET(ReceiptNo) THEN BEGIN
            WhseReceiptHdr."Vendor Shipment No." := VendShipNo;
            WhseReceiptHdr.MODIFY;
        END;
        //>>EN1.49

        WhseReceiptLine.RESET;
        WhseReceiptLine.SETRANGE("No.", ReceiptNo);
        //WhseReceiptLine.SETRANGE("Prod. Sales Order No. ", ProductionSalesOrderNo);
        // WhseReceiptLine.SETRANGE("Prod. Sales Order Pallet No.", PalletNo);
        IF WhseReceiptLine.FINDSET THEN BEGIN
            REPEAT
                WhseReceiptLine."Vendor Shipment No. ELA" := VendShipNo; //<<EN1.49
                WhseReceiptLine.VALIDATE("Qty. to Receive", WhseReceiptLine."Qty. Outstanding");
                WhseReceiptLine.MODIFY;
            UNTIL WhseReceiptLine.NEXT = 0;

            // CrossDockMgt.MarkCrossDockLines(CrossDockOpp, '', ReceiptNo, WhseReceiptLine."Location Code"); //EN1.11
            WhseReceiptLine.RESET;
            WhseReceiptLine.SETRANGE("No.", ReceiptNo);
            // WhseReceiptLine.SETRANGE("Prod. Sales Order No. ", ProductionSalesOrderNo);
            //  WhseReceiptLine.SETRANGE("Prod. Sales Order Pallet No.", PalletNo);
            // WhseReceiptLine.SETRANGE("Can Use Cross-Dock ", TRUE);
            IF WhseReceiptLine.FINDSET THEN
                REPEAT
                //CrossDockMgt.UpdateCrossDockLine(CrossDockOpp, '', ReceiptNo, WhseReceiptLine."Line No.",
                //WhseReceiptLine."Location Code");
                //>>EN1.11
                UNTIL WhseReceiptLine.NEXT = 0;
        END;
        //>>EN1.06
    END;

    PROCEDURE UpdateWhseCrossDockQty(ReceiptNo: Code[20]; ReceiptLineNo: Integer; QtyToCrossDock: Decimal; LocCode: Code[10]);
    VAR
        CrossDockOpp: Record 5768;
        CrossDockMgt: Codeunit 5780;
    BEGIN
        //CrossDockMgt.UpdateCrossDockLine(CrossDockOpp, '', ReceiptNo, ReceiptLineNo, LocCode); //EN1.11
    END;

    PROCEDURE PostWHReceipt(ReceiptNo: Code[20]);
    VAR
        WhseRcptHdr: Record 7316;
        WhseRcptLine: Record 7317;
        WhseActivHeader: Record 5766;
        WhsePostReceipt: Codeunit 5760;
    BEGIN
        //<<EN1.06
        IF WhseRcptHdr.GET(ReceiptNo) THEN BEGIN
            WhseRcptLine.RESET;
            WhseRcptLine.SETRANGE("No.", WhseRcptHdr."No.");
            IF WhseRcptLine.FINDFIRST THEN BEGIN
                WhsePostReceipt.SetHideValidationDialog(TRUE);
                WhsePostReceipt.RUN(WhseRcptLine);
                //WhsePostReceipt.GetFirstPutAwayDocument(WhseActivHeader);
                //PutawayDocNo := WhseActivHeader."No.";
                // ResetPutawayAutoFill(PutawayDocNo); //EN1.51
            END;
        END;
        //>>EN1.06
    END;

    PROCEDURE ClearBinInfoOnPutawayDoc(LocCode: Code[10]; DocNo: Code[20]; DocLineNo: Integer);
    VAR
        WhseActLine: Record 5767;
    BEGIN
        //<<EN1.61
        WhseActLine.RESET;
        WhseActLine.SETRANGE("Activity Type", WhseActLine."Activity Type"::"Put-away");
        WhseActLine.SETRANGE("Action Type", WhseActLine."Action Type"::Place);
        WhseActLine.SETRANGE("No.", DocNo);
        WhseActLine.SETRANGE("Line No.", DocLineNo);
        IF WhseActLine.FINDFIRST THEN BEGIN
            WhseActLine."Zone Code" := '';
            WhseActLine."Bin Code" := '';
            WhseActLine."Expiration Date" := 0D;
            // WhseActLine."Code Date" := 0D;
            WhseActLine.MODIFY;
        END;
        //>>EN1.61
    END;

    PROCEDURE CreatePutAway(ReceiptNo: Code[20]; ReceiptLineNo: Integer);
    VAR
        PostedWhseRcptHdr: Record 7318;
        PostedWhseRcptLine: Record 7319;
        WhseSetup: Record 5769;
        Location: Record 14;
        CreatePutAwayFromWhseSource: Report 7305;
    BEGIN
        //<<EN1.12
        PostedWhseRcptLine.RESET;
        PostedWhseRcptLine.SETRANGE("Whse. Receipt No.", ReceiptNo);
        PostedWhseRcptLine.SETRANGE("Whse Receipt Line No.", ReceiptLineNo);
        PostedWhseRcptLine.SETFILTER(Quantity, '>0');
        PostedWhseRcptLine.SETFILTER(
          Status, '<>%1', PostedWhseRcptLine.Status::"Completely Put Away");
        IF PostedWhseRcptLine.FINDFIRST THEN BEGIN
            Location.GET(PostedWhseRcptLine."Location Code");
            IF NOT Location."Require Put-away" THEN BEGIN
                IF Location.Code = '' THEN BEGIN
                    WhseSetup.GET;
                    WhseSetup.TESTFIELD("Require Put-away");
                END ELSE
                    Location.TESTFIELD("Require Put-away");
            END;

            //CreatePutAwayFromWhseSource.Initialize('',0,FALSE,TRUE,FALSE); //EN1.96
            CreatePutAwayFromWhseSource.Initialize('', 0, FALSE, TRUE, TRUE); //EN1.96
            CreatePutAwayFromWhseSource.SetPostedWhseReceiptLine(PostedWhseRcptLine, '');
            CreatePutAwayFromWhseSource.SetHideValidationDialog(TRUE);
            //CreatePutAwayFromWhseSource.USEREQUESTFORM(FALSE);
            CreatePutAwayFromWhseSource.RUNMODAL;
            CreatePutAwayFromWhseSource.GetResultMessage(1);
            CLEAR(CreatePutAwayFromWhseSource);
        END;
        //>>EN1.12
    END;


    PROCEDURE ResetQtyToHandle(ActivityType: Option "","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick"; DocNo: Code[20]);
    VAR
        WhseActLine: Record 5767;
    BEGIN
        //<<EN1.62
        //WhseActLine2.copy(whseactline);
        WhseActLine.RESET;
        WhseActLine.SETRANGE("Activity Type", ActivityType);
        WhseActLine.SETRANGE("No.", DocNo);
        IF WhseActLine.FINDFIRST THEN
            WhseActLine.DeleteQtyToHandle(WhseActLine);
        //>>EN1.62
    END;


    PROCEDURE CreateBarCode(ItemNo: Code[20]; UOM: Code[10]; Barcode: Text[20])
    var
        lItemUOM: Record "Item Unit of Measure";
    begin
        IF lItemUOM.GET(ItemNo, UOM) THEN BEGIN
            lItemUOM.VALIDATE("Std. Pack UPC/EAN Number ELA", Barcode);
            lItemUOM.MODIFY;
        end;
    end;


    PROCEDURE RegisterWMSPickPutawayxx(ActivityType: Text[30]; DocNo: Code[20]; DocLineNo: Integer; PlaceDocLineNo: Integer; BinCode: Code[10]; Qty: Decimal; ContainerID: Integer; PalletNo: Integer;
    PalletLineNo: Integer; WMSUserID: Code[20]);
    VAR
        WhseActivityLine: Record 5767;
        Bin: Record 7354;
        WhseActivityReg: Codeunit "Whse.-Activity-Register";
        ActType: Option "","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick";
    BEGIN
        GetActivityType(ActivityType, ActType);
        IF WhseActivityLine.GET(ActType, DocNo, DocLineNo) THEN BEGIN
            IF (WhseActivityLine."Bin Code" <> BinCode) AND
               (WhseActivityLine."Activity Type" = WhseActivityLine."Activity Type"::Pick)
            THEN BEGIN
                WhseActivityLine.VALIDATE("Bin Code", BinCode);
            END;

            WhseActivityLine.VALIDATE("Qty. to Handle", Qty);
            //TR  WhseActivityLine."Assigned To" := WMSUserID;
            //TR  WhseActivityLine.VALIDATE("Container ID", ContainerID); //<<EN1.12
            //TR WhseActivityLine.VALIDATE("Pallet No.", PalletNo); //<<EN1.12
            //TR WhseActivityLine.VALIDATE("Pallet Line No.", PalletLineNo); //<<EN1.12
            WhseActivityLine.MODIFY;
        END;

        IF WhseActivityLine.GET(ActType, DocNo, PlaceDocLineNo) THEN BEGIN
            IF (WhseActivityLine."Bin Code" <> BinCode) AND
               (WhseActivityLine."Activity Type" = WhseActivityLine."Activity Type"::"Put-away")
            THEN BEGIN
                //<<EN1.16
                GetBin(Bin, WhseActivityLine."Location Code", BinCode);
                //TRs IF Bin."Block Movement" IN [Bin."Block Movement"::All, Bin."Block Movement"::Inbound] THEN
                //TR   ERROR(STRSUBSTNO(TEXT50009, BinCode, Bin."Block Movement"));

                WhseActivityLine.VALIDATE("Zone Code", Bin."Zone Code");
                WhseActivityLine.VALIDATE("Bin Code", BinCode);
                //>>EN1.16
            END;

            WhseActivityLine.VALIDATE("Qty. to Handle", Qty);
            //TR WhseActivityLine."Assigned To" := WMSUserID;
            //TR WhseActivityLine.VALIDATE("Container ID", ContainerID);
            //TRWhseActivityLine.VALIDATE("Pallet No.", PalletNo);
            //TRWhseActivityLine.VALIDATE("Parent Line No.", PalletLineNo);
            WhseActivityLine.MODIFY;
        END;

        IF WhseActivityLine.GET(ActType, DocNo, DocLineNo) THEN BEGIN
            WhseActivityReg.ShowHideDialog(TRUE);
            //WhseActivityReg.RUN(WhseActivityLine);
        END;

        //TR WMSLoginMgt.AssignJobs(WMSUserID); //<<EN1.27
    END;

    PROCEDURE AutoRegProdSOPutaway(ReceiptNo: Code[20]; OrderNo: Code[20]; PalletNo: Integer; WMSUserID: Code[10]);
    VAR
        WhseActivityLine: Record 5767;
        WhseActivityLine2: Record 5767;
        Location: Record 14;
        Bin: Record 7354;
        WhseActivityReg: Codeunit 7307;
        ActType: Option "","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick";
        ExistingCodeDate: Date;
    BEGIN
        //<<EN1.18
        COMMIT;
        WhseActivityLine.RESET;
        WhseActivityLine.SETRANGE("Activity Type", WhseActivityLine."Activity Type"::"Put-away");
        //TRWhseActivityLine.SETRANGE("Receive To Pick", TRUE);
        //TR WhseActivityLine.SETRANGE("Prod. Sales Order No.", OrderNo);
        //TR WhseActivityLine.SETRANGE("Prod. Sales Order Pallet No.", PalletNo);
        IF WhseActivityLine.FINDSET THEN BEGIN
            Location.GET(WhseActivityLine."Location Code");
            REPEAT
                //TR   IF WhseActivityLine."Code Date" <> 0D THEN
                //TR      ExistingCodeDate := WhseActivityLine."Code Date";

                IF (WhseActivityLine."Action Type" = WhseActivityLine."Action Type"::Place) THEN
                    //<<EN1.25
                    IF WhseActivityLine."Bin Code" <> Location."Cross-Dock Bin Code" THEN BEGIN
                        WhseActivityLine."Zone Code" := '';
                        WhseActivityLine.VALIDATE("Bin Code", Location."Cross-Dock Bin Code"); //EN1.23
                    END;
                //EN1.25

                WhseActivityLine.VALIDATE("Qty. to Handle", WhseActivityLine.Quantity);
                //TR IF (WhseActivityLine."Code Date" = 0D) AND (ExistingCodeDate <> 0D) THEN
                //TR    WhseActivityLine."Code Date" := ExistingCodeDate;

                //TR  WhseActivityLine."Assigned To" := WMSUserID;
                WhseActivityLine.MODIFY;
            UNTIL WhseActivityLine.NEXT = 0;
        END;

        WhseActivityLine.RESET;
        WhseActivityLine.SETRANGE("Activity Type", WhseActivityLine."Activity Type"::"Put-away");
        //TR WhseActivityLine.SETRANGE("Receive To Pick", TRUE);
        //TR WhseActivityLine.SETRANGE("Prod. Sales Order No.", OrderNo);
        //TRWhseActivityLine.SETRANGE("Prod. Sales Order Pallet No.", PalletNo);
        IF WhseActivityLine.FINDSET THEN
            REPEAT
                WhseActivityReg.ShowHideDialog(TRUE);
                WhseActivityReg.RUN(WhseActivityLine);
            UNTIL WhseActivityLine.NEXT = 0;
        //END;
        //>>EN1.18
    END;

    PROCEDURE RegisterWMSMovement(DocNo: Code[20]; ItemNo: Code[20]; Qty: Decimal; BinCode: Code[10]; WMSUserID: Code[20]);
    VAR
        WhseActivityLine: Record 5767;
        WhseActivityReg: Codeunit 7307;
        ActType: Option "","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick";
    BEGIN
        WhseActivityLine.RESET;
        WhseActivityLine.SETRANGE("Activity Type", ActType::Movement);
        WhseActivityLine.SETRANGE("No.", DocNo);
        WhseActivityLine.SETRANGE("Item No.", ItemNo);
        IF WhseActivityLine.FINDSET THEN BEGIN
            //CheckForValidPutaway(WhseActivityLine."Location Code",BinCode,ItemNo,WhseActivityLine."Unit of Measure Code",
            // Qty,WhseActivityLine."Code Date");  //<<EN1.24 + EN1.43
            REPEAT
                IF WhseActivityLine."Action Type" = WhseActivityLine."Action Type"::Place THEN
                    IF WhseActivityLine."Bin Code" <> BinCode THEN BEGIN
                        WhseActivityLine."Zone Code" := ''; //<<EN1.24
                        WhseActivityLine.VALIDATE("Bin Code", BinCode); //EN1.13
                                                                        //TR IF WhseActivityLine."Expiration Date" = 0D THEN
                                                                        //TR WhseActivityLine."Expiration Date" := WhseActivityLine."Code Date"; //EN1.43
                    END;
                //TR WhseActivityLine.VALIDATE("Qty. to Handle", Qty);
                WhseActivityLine."Qty. to Handle" := Qty;
                WhseActivityLine."Assigned App. User ELA" := WMSUserID;
                WhseActivityLine.MODIFY;
            UNTIL WhseActivityLine.NEXT = 0;

            WhseActivityReg.RUN(WhseActivityLine);
        END;

        //TR WMSLoginMgt.AssignJobs(WMSUserID); //<<EN1.27
    END;

    PROCEDURE GetActivityType(ActivityType: Text[30]; VAR ActivityTypeOption: Option);
    VAR
        ActType: Option " ","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick";
    BEGIN
        //<<EN1.06
        CASE ActivityType OF
            'Putaway', 'Put-away', 'Put_away':
                ActivityTypeOption := ActType::"Put-away";
            'Pick':
                ActivityTypeOption := ActType::Pick;
            'Movement':
                ActivityTypeOption := ActType::Movement;
            'InvtPutaway':
                ActivityTypeOption := ActType::"Invt. Put-away";
            'InvtPick':
                ActivityTypeOption := ActType::"Invt. Pick";
            '':
                ActivityTypeOption := ActType::" ";
        END;
        //>>EN1.06
    END;

    PROCEDURE UpdateWMSQueueState(ActivityType: Text[30]; DocNo: Code[20]; DocLineNo: Integer; WMSUserID: Code[20]);
    VAR
        WhseActLine: Record 5767;
    BEGIN
        GetActivityType(ActivityType, ActType);
        IF ActType = ActType::"Put-away" THEN BEGIN
            WhseActLine.RESET;
            WhseActLine.SETRANGE(WhseActLine."Activity Type", ActType);
            WhseActLine.SETRANGE("No.", DocNo);
            //TR WhseActLine.SETRANGE("Parent Line No.", DocLineNo);
            IF WhseActLine.FINDFIRST THEN BEGIN
                //TR   WhseActLine.VALIDATE("Assigned To", WMSUserID);
                WhseActLine.MODIFY;
            END;
        END ELSE
            IF ActType IN [ActType::Pick, ActType::Movement] THEN BEGIN
                IF WhseActLine.GET(ActType, DocNo, DocLineNo) THEN BEGIN
                    //TR    WhseActLine.VALIDATE("Assigned To", WMSUserID);
                    WhseActLine.MODIFY;

                END
            END;
    END;

    PROCEDURE IsBinValidForPutaway(LocCode: Code[10]; BinNo: Code[10]; ItemNo: Code[20]; ItemUOM: Code[10]; Quantity: Decimal; ExpDate: Date; VAR HasADifferentItem: Boolean;
    VAR DifferentItemNo: Code[20]; VAR DifferentItemUOM: Code[10]; VAR DifferentItemDesc: Text[50]; VAR DifferentItemBinNo: Code[10]; VAR DifferentItemZoneCode: Code[10]; VAR IsExcedingMaxCap: Boolean;
    VAR HasDiffCodeDate: Boolean);
    VAR
        BinContent: Record 7302;
        BinQty: Decimal;
    BEGIN
        //<<EN1.19
        //Location Code,Bin Code,Item No.,Variant Code,Unit of Measure Code
        BinContent.RESET;
        BinContent.SETRANGE("Location Code", LocCode);
        BinContent.SETRANGE("Bin Code", BinNo);
        BinContent.SETFILTER("Item No.", '<>%1', ItemNo);
        IF BinContent.FINDFIRST THEN BEGIN
            BinContent.CALCFIELDS(Quantity);
            IF BinContent.Quantity > 0 THEN BEGIN
                HasADifferentItem := TRUE;
                DifferentItemNo := BinContent."Item No.";
                DifferentItemUOM := BinContent."Unit of Measure Code";
                //TR BinContent.CALCFIELDS("Item Description");
                //TR DifferentItemDesc := BinContent."Item Description";
                DifferentItemBinNo := BinContent."Bin Code";
                DifferentItemZoneCode := BinContent."Zone Code";
            END;
        END;
        //>>EN1.19
    END;

    PROCEDURE CheckForValidPutaway(LocCode: Code[10]; BinNo: Code[10]; ItemNo: Code[20]; ItemUOM: Code[10]; Quantity: Decimal; ExpDate: Date);
    VAR
        BinContent: Record 7302;
        BinContent2: Record 7302;
        ItemXLink: Record "Item Cross Link ELA";
        BinQty: Decimal;
        BaseItemNo: Code[20];
        LTXT001: TextConst ENU = 'Bin %1 contains Item No. %2 with a different Exp. date %3';
        LTXT002: TextConst ENU = 'Bin %1 contains a Cross Link Item No. %2 with a different Exp. date %3';
        LTXT003: TextConst ENU = 'Bin %1 contains a different Item No. %2 Quantity %3';
        XLinkItemList: ARRAY[20] OF Code[20];
        ExpDateFound: Date;
    BEGIN
        //<<EN1.23
        // check for same item and exp. date
        IF NOT IsCodeDateValid(LocCode, BinNo, ItemNo, ExpDate, ExpDateFound) THEN
            ERROR(STRSUBSTNO(LTXT001, BinNo, ItemNo, ExpDateFound));

        // check cross links for exp. date in the same bin.
        BinContent.RESET;
        BinContent.SETRANGE("Location Code", LocCode);
        BinContent.SETRANGE("Bin Code", BinNo);
        IF BinContent.FINDFIRST THEN BEGIN
            BaseItemNo := GetXlinkBaseItemNo(ItemNo);
            ItemXLink.RESET;
            ItemXLink.SETRANGE("Item No.", BaseItemNo);
            IF ItemXLink.FINDSET THEN
                REPEAT
                    IF NOT IsCodeDateValid(LocCode, BinNo, ItemXLink."Linked Item No.", ExpDate, ExpDateFound) THEN
                        ERROR(STRSUBSTNO(LTXT002, BinNo, ItemXLink."Linked Item No.", ExpDateFound));
                UNTIL ItemXLink.NEXT = 0;
        END;

        BinContent.RESET;
        BinContent.SETRANGE("Location Code", LocCode);
        BinContent.SETRANGE("Bin Code", BinNo);
        BinContent.SETFILTER("Item No.", '<>%1', ItemNo);
        IF BinContent.FINDFIRST THEN BEGIN
            BaseItemNo := GetXlinkBaseItemNo(ItemNo);
            ItemXLink.RESET;
            ItemXLink.SETRANGE("Item No.", BaseItemNo);
            IF ItemXLink.FINDSET THEN
                REPEAT
                    IF BinContent."Item No." = ItemXLink."Linked Item No." THEN
                        EXIT;
                UNTIL ItemXLink.NEXT = 0;
            BinContent.CALCFIELDS(Quantity);
            IF BinContent.Quantity > 0 THEN
                ERROR(STRSUBSTNO(LTXT003, BinNo, BinContent."Item No."));
        END;
        //>>EN1.23
    END;


    procedure GetXlinkBaseItemNo(ItemNo: Code[20]): Code[20]
    var
        ItemXLink: Record "Item Cross Link ELA";
    begin
        //<<EN1.03
        EXIT(ItemXLink.GetBaseXlinkItem(ItemNo));
        //>>EN1.03

    end;


    PROCEDURE CanPutaway(LocCode: Code[10]; BinNo: Code[10]; ItemNo: Code[20]; CodeDate: Date): Boolean;
    VAR
        Bin: Record 7354;
        WhseActLine: Record 5767;
        CreatePutAway: Codeunit 7313;
    BEGIN
        //<<EN1.61

        //TR  EXIT(NOT CreatePutAway.IsBinInUse(LocCode, '', BinNo, ItemNo, '', CodeDate));
        //>>EN1.61
    END;

    LOCAL PROCEDURE IsCodeDateValid(LocCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; ExpDate: Date; VAR ExpDateFound: Date): Boolean;
    VAR
        BinContent: Record 7302;
    BEGIN
        //<<EN1.23
        BinContent.RESET;
        BinContent.SETRANGE("Location Code", LocCode);
        BinContent.SETRANGE("Bin Code", BinCode);
        BinContent.SETRANGE("Item No.", ItemNo);
        IF BinContent.FINDFIRST THEN
            IF BinContent."Bin Type Code" = 'PUTPICK' THEN BEGIN
                BinContent.CALCFIELDS(Quantity);
                IF BinContent.Quantity > 0 THEN
                    //TR IF BinContent."Code Date" <> ExpDate THEN BEGIN
                    //TR    ExpDateFound := BinContent."Code Date";
                    EXIT(FALSE);
                //TR END;
            END;

        EXIT(TRUE);
        //>>EN1.23
    END;

    PROCEDURE CheckForPartOrder(OrderNo: Code[20]; AssignedUserID: Code[10]; AssignedUserRole: Code[20]): Boolean;
    VAR
        WhseActLine: Record 5767;
    BEGIN
        //<<EN1.30
        WhseActLine.RESET;
        WhseActLine.SETRANGE("Activity Type", WhseActLine."Activity Type"::Pick);
        WhseActLine.SETRANGE("Source No.", OrderNo);
        //TRWhseActLine.SETRANGE("Assigned To", AssignedUserID);
        WhseActLine.SETRANGE("Action Type", WhseActLine."Action Type"::Take);
        //TR WhseActLine.SETFILTER("Assigned Role", '<>%1', AssignedUserRole);
        IF WhseActLine.FINDFIRST THEN
            EXIT(TRUE);
        //>>EN1.30
    END;

    PROCEDURE GetPalletInfo(ContainerID: Integer; PalletNo: Integer; PalletLineNo: Integer; VAR DocNo: Code[20]; VAR OrderNo: Code[20]; VAR ItemNo: Code[20]; VAR ItemUOM: Code[10];
    VAR ItemDesc: Text[30]; VAR Quantity: Decimal; VAR AssignedTo: Code[10]);
    VAR
        WhseActLine: Record 5767;
    BEGIN
        //<<EN1.31
        WhseActLine.RESET;
        //TRWhseActLine.SETRANGE(WhseActLine."Container ID", ContainerID);
        //TRWhseActLine.SETRANGE(WhseActLine."Pallet No.", PalletNo);
        //TRWhseActLine.SETRANGE(WhseActLine."Pallet Line No.", PalletLineNo);
        IF WhseActLine.FINDFIRST THEN BEGIN
            DocNo := WhseActLine."No.";
            //AssignedTo := WhseActLine."Assigned To"; //EN1.76
            ItemNo := WhseActLine."Item No.";
            ItemDesc := WhseActLine.Description;
            Quantity := WhseActLine.Quantity;
            ItemUOM := WhseActLine."Unit of Measure Code";
            OrderNo := WhseActLine."Source No.";
        END;
        //>>EN1.31
    END;

    PROCEDURE GetPalletLoadInfo(LoadNo: Code[20]; PalletNo: Integer; PalletLineNo: Integer; VAR DocNo: Code[20]; VAR OrderNo: Code[20]; VAR ItemNo: Code[20]; VAR ItemUOM: Code[10];
    VAR ItemDesc: Text[30]; VAR Quantity: Decimal; VAR AssignedTo: Code[10]);
    VAR
        WhseActLine: Record 5767;
    BEGIN
        //<<EN1.31
        WhseActLine.RESET;
        //TR WhseActLine.SETRANGE(WhseActLine."Load ID", LoadNo);
        //TR WhseActLine.SETRANGE(WhseActLine."Pallet No.", PalletNo);
        //<<EN1.88
        //TR IF PalletLineNo <> 0 THEN
        //TR     WhseActLine.SETRANGE(WhseActLine."Pallet Line No.", PalletLineNo);
        //>>EN1.88
        IF WhseActLine.FINDFIRST THEN BEGIN
            DocNo := WhseActLine."No.";
            //AssignedTo := WhseActLine."Assigned To"; //EN1.76
            ItemNo := WhseActLine."Item No.";
            ItemDesc := WhseActLine.Description;
            Quantity := WhseActLine.Quantity;
            ItemUOM := WhseActLine."Unit of Measure Code";
            OrderNo := WhseActLine."Source No.";
        END;
        //>>EN1.31
    END;

    PROCEDURE AdjustPutawayDoc(PutawayDocNo: Code[20]);
    VAR
    //AdjWhsePutaway : Report 50177;
    BEGIN
        //<<EN1.39
        /* AdjWhsePutaway.SetValues('',PutawayDocNo,'');
         AdjWhsePutaway.SetHideDialog(TRUE);
         AdjWhsePutaway.USEREQUESTFORM(FALSE);
         AdjWhsePutaway.RUN;*/
        //>>EN1.39
    END;

    PROCEDURE AdjustPalletQty(LoadID: Code[20]; PalletNo: Integer; PalletLineNo: Integer; NewQty: Decimal);
    var
        ShipDashbrdMgt: Codeunit "Shipment Mgmt. ELA";
    BEGIN
        //<<EN1.36
        //TR ShipDashbrdMgt.AdjustRegPickLinesCosign(LoadID, PalletNo, PalletLineNo, NewQty, TRUE);
        //>>EN1.36
    END;

    PROCEDURE GetPutawayDocFromTransferOrder(TransferOrder: Code[20]; TransferOrderLineNo: Integer; VAR PutawayDocNo: Code[20]; VAR PutawayDocLineNo: Integer);
    VAR
        WhseActLine: Record 5767;
    BEGIN
        //<<EN1.43
        WhseActLine.RESET;
        WhseActLine.SETRANGE("Activity Type", WhseActLine."Activity Type"::"Put-away");
        //TR WhseActLine.SETRANGE("Source Type", WhseActLine."Source Type"::"5741");
        WhseActLine.SETRANGE("Source Subtype", WhseActLine."Source Subtype"::"1");
        WhseActLine.SETRANGE("Action Type", WhseActLine."Action Type"::Place);
        WhseActLine.SETRANGE("Source No.", TransferOrder);
        WhseActLine.SETRANGE("Source Line No.", TransferOrderLineNo);
        IF WhseActLine.FINDFIRST THEN BEGIN
            PutawayDocNo := WhseActLine."No.";
            PutawayDocLineNo := WhseActLine."Line No.";
        END;
        //>>EN1.43
    END;

    PROCEDURE BlockPutawayBinForPicking(LocCode: Code[10]; BinCode: Code[10]; ItemNo: Code[20]; ItemUOM: Code[10]);
    VAR
        Item: Record 27;
        BinContent: Record 7302;
    BEGIN
        //<<EN1.44
        Item.GET(ItemNo);
        //TR IF Item."Block Bin for Pick On Put-away " THEN BEGIN
        //Location Code,Bin Code,Item No.,Variant Code,Unit of Measure Code
        //<<EN1.52
        BinContent.RESET;
        BinContent.SETRANGE(BinContent."Location Code", LocCode);
        BinContent.SETRANGE(BinContent."Bin Code", BinCode);
        BinContent.SETRANGE(BinContent."Item No.", ItemNo);
        BinContent.SETRANGE(BinContent."Variant Code", '');
        BinContent.SETRANGE(BinContent."Unit of Measure Code", ItemUOM);
        IF BinContent.FINDSET THEN
            REPEAT
                //TR BinContent."Block Reason" := 'QC';
                BinContent.VALIDATE("Block Movement", BinContent."Block Movement"::Outbound);
                BinContent.MODIFY;
            UNTIL BinContent.NEXT = 0;
        //>>EN1.52
        //TR END;
        //>>EN1.44
    END;


    PROCEDURE CreatePickTicket("Source No.": Code[20]; UserID: Code[20]; AssignedTo: Code[20]; TripID: Code[10]): Boolean;
    VAR
        ShptDash: Record "Shipment Dashboard ELA";
        ShipDBMgt: Codeunit "Shipment Mgmt. ELA";
        WhseActLine: Record 5767;
        PickAllocation: Page "Picking Bin Allocation ELA";
        TmpWhseActLine: Record 5767 TEMPORARY;
        TmpWhseActHdr: Record 5766 TEMPORARY;
        WhseActLine2: Record 5767;
        IsFullyPicked: Boolean;
    BEGIN
        //<<EN1.64
        ShipDBMgt.AddApprovedOrders; //EN1.72

        //<<EN1.92
        IsFullyPicked := TRUE;
        ShptDash.RESET;
        ShptDash.SETRANGE(Level, 1);
        ShptDash.SETRANGE("Source No.", "Source No.");
        IF ShptDash.FINDSET THEN
            REPEAT
                IF NOT ShptDash."Full Pick" THEN
                    IsFullyPicked := FALSE;
            UNTIL ShptDash.NEXT = 0;

        //EN1.95A
        //TR IF (ShptDash."Source Type" = ShptDash."Source Type"::"5741") AND IsFullyPicked THEN
        //TR   EXIT(TRUE);
        //>>EN1.95A

        //TR IF IsFullyPicked THEN
        //TR    ERROR(STRSUBSTNO(TEXT50017, "Source No."));
        //>>EN1.92

        //Select Order From Shipment Dashboard.
        ShptDash.RESET;

        //<<EN1.94
        IF TripID = '' THEN BEGIN
            //<<EN1.73
            IF AssignedTo <> '' THEN BEGIN
                ShptDash.SETRANGE(Level, 1);
                ShptDash.SETRANGE("Source No.", "Source No.");
                //TR  ShptDash.SETRANGE("Assigned To", AssignedTo);
            END ELSE BEGIN
                ShptDash.SETRANGE(Level, 0);
                ShptDash.SETRANGE("Source No.", "Source No.");
            END;
            IF ShptDash.FINDSET THEN
                REPEAT
                    ShptDash.VALIDATE(Select, TRUE);
                    ShptDash.MODIFY;
                UNTIL ShptDash.NEXT = 0;
            //>>EN1.73
        END ELSE BEGIN
            IF AssignedTo <> '' THEN BEGIN
                ShptDash.SETRANGE(Level, 1);
                //TR ShptDash.SETRANGE("Trip ID", TripID);
                //TR ShptDash.SETRANGE("Assigned To", AssignedTo);
            END ELSE BEGIN
                ShptDash.SETRANGE(Level, 0);
                //TR ShptDash.SETRANGE("Trip ID", TripID);
            END;
            IF ShptDash.FINDSET THEN
                REPEAT
                    ShptDash.VALIDATE(Select, TRUE);
                    ShptDash.MODIFY;
                UNTIL ShptDash.NEXT = 0;
        END;
        //TR ShipDBMgt.SetTripID(TripID);
        //>>EN1.94

        //TR ShipDBMgt.CreatePickTickets("Source No.", UserID); //<<EN1.01          //Create Pick of Selected order.
        //TR ShptDash.DeSelectOrder("Source No.");                                 //Deselect selected order.

        ShipDBMgt.AddApprovedOrders;

        WhseActLine.RESET;                                                    //Mark Release to Pick Flag true for particular order.
        WhseActLine.SETRANGE("Activity Type", WhseActLine."Activity Type"::Pick);
        //TR IF TripID = '' THEN                                             //EN1.94
        //TR     WhseActLine.SETRANGE("Source No.", "Source No.");
        //TRELSE
        //TR  WhseActLine.SETRANGE("Trip ID", TripID);                       //EN1.94
        //TR WhseActLine.SETRANGE("Released To Pick", FALSE);
        //TR IF AssignedTo <> '' THEN                                 //<<EN1.73
        //TR     WhseActLine.SETRANGE("Assigned To", AssignedTo);
        //TR IF WhseActLine.FINDSET THEN
        //TR REPEAT
        //TR       WhseActLine."Released To Pick" := TRUE;
        //TR      WhseActLine.MODIFY;
        //TR    UNTIL WhseActLine.NEXT = 0;


        WITH WhseActLine2 DO BEGIN                                         //Release Order to Pick
            TmpWhseActLine.RESET;
            TmpWhseActLine.DELETEALL;
            TmpWhseActHdr.RESET;
            TmpWhseActHdr.DELETEALL;

            RESET;
            //TR SETFILTER("Released To Pick", '%1', TRUE);
            IF FINDSET THEN
                REPEAT
                    TmpWhseActLine.INIT;
                    TmpWhseActLine.COPY(WhseActLine2);
                    TmpWhseActLine.INSERT;
                UNTIL NEXT = 0;

            TmpWhseActLine.RESET;
            IF TmpWhseActLine.FINDSET THEN
                REPEAT
                    WhseActLine.RESET;
                    WhseActLine.SETRANGE("Activity Type", WhseActLine."Activity Type"::Pick);
                    WhseActLine.SETRANGE(WhseActLine."No.", TmpWhseActLine."No.");
                    //TR WhseActLine.SETRANGE("Released To Pick", FALSE);
                    //TR IF AssignedTo <> '' THEN                                 //<<EN1.73
                    //TR    WhseActLine.SETRANGE("Assigned To", AssignedTo);

                    IF WhseActLine.FINDSET THEN BEGIN
                        REPEAT
                            IF (WhseActLine."Line No." = TmpWhseActLine."Line No.") AND
                               (WhseActLine."Bin Code" <> TmpWhseActLine."Bin Code") AND
                               (WhseActLine."Action Type" = WhseActLine."Action Type"::Take)
                            THEN BEGIN
                                WhseActLine."Zone Code" := TmpWhseActLine."Zone Code";
                                WhseActLine.VALIDATE("Bin Code", TmpWhseActLine."Bin Code");
                            END;

                            IF WhseActLine."Line No." = TmpWhseActLine."Line No." THEN BEGIN
                                //TR   WhseActLine.VALIDATE("Released To Pick", TmpWhseActLine."Released To Pick");

                                WhseActLine."Special Equipment Code" := TmpWhseActLine."Special Equipment Code";
                                //TR  WhseActLine.VALIDATE("Assigned Role", TmpWhseActLine."Assigned Role");
                                //TR WhseActLine.VALIDATE("Assigned To", TmpWhseActLine."Assigned To");
                                WhseActLine.MODIFY;
                                COMMIT;
                            END;
                        UNTIL WhseActLine.NEXT = 0;
                    END;
                UNTIL TmpWhseActLine.NEXT = 0;
            COMMIT;


            TmpWhseActLine.RESET;
            //TR TmpWhseActLine.SETRANGE("Released To Pick", TRUE);
            //TR TmpWhseActLine.SETRANGE("Receive To Pick", TRUE);
            //TR IF AssignedTo <> '' THEN                                 //<<EN1.73
            //TR     TmpWhseActLine.SETRANGE("Assigned To", AssignedTo);

            IF TmpWhseActLine.FINDSET THEN
                REPEAT
                    IF NOT TmpWhseActHdr.GET(TmpWhseActLine."Activity Type", TmpWhseActLine."No.") THEN BEGIN
                        TmpWhseActHdr.INIT;
                        TmpWhseActHdr.Type := TmpWhseActLine."Activity Type";
                        TmpWhseActHdr."No." := TmpWhseActLine."No.";
                        TmpWhseActHdr.INSERT;
                    END;
                UNTIL TmpWhseActLine.NEXT = 0;

            //<<EN1.06
            TmpWhseActLine.RESET;
            //TRTmpWhseActLine.SETRANGE("Released To Pick", TRUE);
            //TRTmpWhseActLine.SETRANGE("Trip ID", "Trip ID");
            //TR  IF TmpWhseActLine.FIND('-') THEN BEGIN
            //TR     REPEAT
            //TR  ShipDashbrdMgt.AutoAssignPallets(TmpWhseActLine."Source No.");
            //TR     UNTIL TmpWhseActLine.NEXT = 0;
            //TR END ELSE    //>>EN1.06
            //TR   ShipDashbrdMgt.AutoAssignPallets(TmpWhseActLine."Source No."); //<<EN1.04

        END;

        WhseActLine.RESET;
        WhseActLine.SETRANGE("Activity Type", WhseActLine."Activity Type"::Pick);
        WhseActLine.SETRANGE("Source No.", "Source No.");
        //TR IF AssignedTo <> '' THEN                                 //<<EN1.73
        //TR   WhseActLine.SETRANGE("Assigned To", AssignedTo);

        IF WhseActLine.FINDFIRST THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);

        //>>EN1.64
    END;



    /// <summary>
    /// GetNextTaskDocNo.
    /// </summary>
    /// <param name="WMSUserID">Code[20].</param>
    /// <param name="WMSUserRole">Code[20].</param>
    /// <param name="VAR ActivityType">Text[30].</param>
    /// <param name="VAR ActivityNo">Code[20].</param>
    /// <param name="VAR DocNo">Code[20].</param>
    /// <param name="DestinationNo">VAR Code[20].</param>
    /// <param name="ShipToCode">VAR COde[20].</param>
    /// <param name="ShipToName">VAR text[50].</param>
    /// <param name="ShipDate">VAR Date.</param>
    /// <param name="ExternalDocNo">VAR code[20].</param>
    /// <param name="TripID">VAR Code[10].</param>
    procedure GetNextTaskDocNo(WMSUserID: Code[20]; WMSUserRole: Code[20]; VAR ActivityType: Text[30]; VAR ActivityNo: Code[20];
        VAR DocNo: Code[20]; var DestinationNo: Code[20]; var ShipToCode: COde[20]; var ShipToName: text[50];
        var ShipDate: Date; var ExternalDocNo: code[20]; var TripID: Code[10])
    var
        AppRole: Record "App. Role ELA";
        SalesHeader: Record "Sales Header";
        WhseActHdr: Record "Warehouse Activity Header";
        WhseActLine: Record "Warehouse Activity Line";
        RoleFilter: Code[80];
    begin

        IF AppRole.GET(WMSUserRole) THEN BEGIN
            IF AppRole."Role Type" = AppRole."Role Type"::Custom THEN
                RoleFilter := AppRole."Custom Role Filter"
            ELSE
                RoleFilter := AppRole."Role Code";
        END ELSE
            ERROR('Unable to find given role');

        WhseActLine.RESET;
        // WhseActLine.SETCURRENTKEY("Assigned Role", "Assigned To", "Released To Pick", "Release Time");
        // WhseActLine.SETRANGE("Assigned Role", RoleFilter);
        // WhseActLine.SETRANGE("Assigned To", WMSUserID);
        // WhseActLine.SETRANGE("Released To Pick", TRUE);
        IF WhseActLine.FINDFIRST THEN BEGIN
            ActivityType := FORMAT(WhseActLine."Activity Type");
            ActivityNo := WhseActLine."No.";
            DocNo := WhseActLine."Source No.";
            DestinationNo := WhseActLine."Destination No.";
            // TripID := WhseActLine."Trip ID";            //EN1.94

            WhseActHdr.GET(WhseActLine."Activity Type", WhseActLine."No.");
            // ShipToCode := WhseActHdr."Ship-to Code";
            // ShipToName := WhseActHdr."Ship-to Name";
            ShipDate := WhseActHdr."Shipment Date";
            //<<EN1.77 ks
            IF SalesHeader.GET(SalesHeader."Document Type"::Order, WhseActLine."Source No.") THEN BEGIN
                // IF SalesHeader."IC External Doc. No." <> '' THEN
                //     ExternalDocNo := SalesHeader."IC External Doc. No."
                // ELSE
                ExternalDocNo := SalesHeader."External Document No.";
            END;
        END;
    end;


    /// <summary>
    /// ResetQtyToHandle.
    /// </summary>
    /// <param name="ActivityType">Enum "EN WMS Activity Type".</param>
    /// <param name="DocNo">Code[20].</param>
    PROCEDURE RegisterWMSPickPutaway(ActivityType: Text[30]; DocNo: Code[20]; DocLineNo: Integer; PlaceDocLineNo: Integer;
        BinCode: Code[10]; Qty: Decimal; ContainerID: Code[20]; PalletNo: Integer; PalletLineNo: Integer; AppUserID: Code[20];
        NewExpDate: Date; EnforceExpDate: Boolean; LoadID: Code[20]);
    VAR
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityLine2: Record "Warehouse Activity Line";
        Bin: Record Bin;
        ExistingCodeDate: Date;
        ENWMSUtil: Codeunit "WMS Util ELA";
        ActType: Enum "WMS Activity Type ELA";
        WMSJobMgt: Codeunit "App. Job Mgmt. ELA";
        PlaceLineNo: Integer;
        TakeLineNo: Integer;
    BEGIN
        ENWMSUtil.GetActivityType(ActivityType, ActType);

        GetActivityType(ActivityType, ActType);
        IF ActType = ActType::Pick THEN BEGIN
            ResetQtyToHandle(ActType, DocNo); //EN1.82
            IF WhseActivityLine.GET(ActType, DocNo, DocLineNo) THEN BEGIN
                GetWhseTakePlaceLineNo(WhseActivityLine, TakeLineNo, PlaceLineNo);
                WhseActivityLine.VALIDATE("Qty. to Handle", Qty);
                WhseActivityLine.MODIFY;
                IF WhseActivityLine2.GET(ActType, DocNo, PlaceLineNo) THEN BEGIN

                    WhseActivityLine2.VALIDATE("Qty. to Handle", Qty);

                    WhseActivityLine2.MODIFY;


                END;
            END ELSE
                ERROR(STRSUBSTNO('doc no. %1 doc line %2 not found', DocNo, DocLineNo));
        END ELSE
            IF ActType = ActType::"Put-away" THEN BEGIN
                //<<EN1.96
                /* //TR ResetQtyToHandle(ActType, DocNo); //EN1.62
                 IF WhseActivityLine.GET(ActType, DocNo, DocLineNo) THEN BEGIN
                     IF (WhseActivityLine."Action Type" = WhseActivityLine."Action Type"::Place)
                     // AND (WhseActivityLine."Bin Code" <> BinCode) //EN1.96
                     THEN BEGIN
                         //<<EN1.20

                         GetBin(Bin, WhseActivityLine."Location Code", BinCode);
                         IF Bin."Block Movement" IN [Bin."Block Movement"::All, Bin."Block Movement"::Inbound] THEN
                             ERROR(STRSUBSTNO(TEXT50009, BinCode, Bin."Block Movement"));

                         WhseActivityLine.VALIDATE("Zone Code", '');
                         WhseActivityLine.VALIDATE("Bin Code", BinCode);



                         QtyPutawayBase := Qty * WhseActivityLine."Qty. per Unit of Measure"; //EN1.96
                         WhseActivityLine.VALIDATE("Qty. to Handle (Base)", QtyPutawayBase);  //EN1.96

                         WhseActivityLine.MODIFY;
                         TakeLineNo := WhseActivityLine."Line No." - 10000;
                         IF WhseActivityLine2.GET(ActType, DocNo, TakeLineNo) THEN BEGIN


                             ///WhseActivityLine2.VALIDATE("Qty. to Handle",Qty); //EN1.96
                             WhseActivityLine2.VALIDATE("Qty. to Handle (Base)", QtyPutawayBase); //EN1.96
                                                                                                  //<<EN1.96
                             IF (WhseActivityLine2."Action Type" = WhseActivityLine2."Action Type"::Take) THEN
                                 IF (WhseActivityLine2."Breakbulk No." <> 0) OR WhseActivityLine2."Original Breakbulk" THEN
                                     WhseActivityLine2.UpdateBreakbulkQtytoHandle();
                             //>>EN1.96



                             WhseActivityLine2.MODIFY;
                         END;
                     END;
                 END*/
            END;

        COMMIT; //EN1.50
        IF WhseActivityLine.GET(ActType, DocNo, DocLineNo) THEN BEGIN
            WhseActivityReg.ShowHideDialog(TRUE);
            WhseActivityReg.RUN(WhseActivityLine);
            //COMMIT;        //EN1.83 Remove Commit in case of error , delete Pallet lines from device side.
            ResetPutawayAutoFill(DocNo); //EN1.51
        END;

        //WMSLoginMgt.AssignJobs(WMSUserID); //<<EN1.27
    END;

    /// <summary>
    /// ResetQtyToHandle.
    /// </summary>
    /// <param name="ActivityType">Enum "EN WMS Activity Type".</param>
    /// <param name="DocNo">Code[20].</param>
    procedure ResetQtyToHandle(ActivityType: Enum "WMS Activity Type ELA"; DocNo: Code[20])
    var
        WhseActLine: Record "Warehouse Activity Line";
    begin
        WhseActLine.RESET;
        WhseActLine.SETRANGE("Activity Type", ActivityType);
        WhseActLine.SETRANGE("No.", DocNo);
        IF WhseActLine.FINDFIRST THEN
            WhseActLine.DeleteQtyToHandle(WhseActLine);
    end;

    /// <summary>
    /// GetBin.
    /// </summary>
    /// <param name="VAR Bin">Record Bin.</param>
    /// <param name="LocationCode">Code[10].</param>
    /// <param name="BinCode">Code[20].</param>
    local procedure GetBin(VAR Bin: Record Bin; LocationCode: Code[10]; BinCode: Code[20])
    var
    begin
        IF (LocationCode = '') OR (BinCode = '') THEN
            Bin.INIT
        ELSE
            IF (Bin."Location Code" <> LocationCode) OR
               (Bin.Code <> BinCode)
            THEN
                Bin.GET(LocationCode, BinCode);
    end;

    /// <summary>
    /// ResetPutawayAutoFill.
    /// </summary>
    /// <param name="DocNo">Code[20].</param>
    local procedure ResetPutawayAutoFill(DocNo: Code[20])
    var
        WhseActLine: Record "Warehouse Activity Line";
    begin
        WhseActLine.RESET;
        WhseActLine.SETRANGE("Activity Type", WhseActLine."Activity Type"::"Put-away");
        WhseActLine.SETRANGE("No.", DocNo);
        IF WhseActLine.FINDFIRST THEN
            WhseActLine.DeleteQtyToHandle(WhseActLine);
    end;


    //**************************************************************************************Adjustment********************************************************************
    PROCEDURE CreateWMSMovement(SourceBinCode: Code[10]; ItemNo: Code[20]; ItemUOM: Code[10]; Qty: Decimal; TargetBinCode: Code[10]; LocationCode: Code[10]; VAR DocumentNo: Code[20]; ExpiryDate: Date; WMSUserID: Code[20])
    VAR
        WhseWorkshtLine: Record 7326;
        CreateMovFromWhseSource: Report 7305;
        warehouseActLine: record "Warehouse Activity Line";
        NextLineNo: Integer;
        BatchName: Code[10];
    BEGIN
        //<<EN1.23
        //CheckForValidPutaway(LocationCode,TargetBinCode,ItemNo,ItemUOM,Qty,ExpiryDate);  //EN1.61


        //<<EN1.36
        IF BatchName = '' THEN
            GetBatchName(WMSUserID, BatchName);

        CreateWhseMovementWkSht(LocationCode, BatchName);

        WhseWorkshtLine.RESET;
        WhseWorkshtLine.SETRANGE("Worksheet Template Name", 'MOVEMENT');
        WhseWorkshtLine.SETRANGE(Name, BatchName);
        WhseWorkshtLine.SETRANGE("Location Code", LocationCode);
        WhseWorkshtLine.DELETEALL;
        //IF WhseWorkshtLine.FINDLAST THEN
        //  NextLineNo := WhseWorkshtLine."Line No." + 10000
        //ELSE
        //>>EN1.36
        NextLineNo := 10000;

        WhseWorkshtLine.INIT;
        WhseWorkshtLine."Worksheet Template Name" := 'MOVEMENT';
        WhseWorkshtLine.Name := BatchName; //'DEFAULT'; //EN1.36
        WhseWorkshtLine."Location Code" := LocationCode;
        WhseWorkshtLine."Line No." := NextLineNo;
        WhseWorkshtLine.INSERT;
        WhseWorkshtLine.VALIDATE("Item No.", ItemNo);
        WhseWorkshtLine.VALIDATE("Unit of Measure Code", ItemUOM); //EN1.16
        WhseWorkshtLine.VALIDATE("From Bin Code", SourceBinCode);
        WhseWorkshtLine.VALIDATE("To Bin Code", TargetBinCode);
        //WhseWorkshtLine."Code Date" := ExpiryDate;  //EN1.16
        WhseWorkshtLine.VALIDATE(Quantity, Qty);

        WhseWorkshtLine."Whse. Document Type" := WhseWorkshtLine."Whse. Document Type"::"Whse. Mov.-Worksheet";
        WhseWorkshtLine."Whse. Document No." := 'DEFAULT';
        WhseWorkshtLine."Whse. Document Line No." := NextLineNo;
        //WhseWorkshtLine.AutofillQtyToHandle(WhseWorkshtLine);
        WhseWorkshtLine.MODIFY;

        //WhseWorkshtLine.MODIFY;

        CreateMovFromWhseSource.SetHideValidationDialog(TRUE);
        CreateMovFromWhseSource.UseRequestPage(FALSE);
        CreateMovFromWhseSource.SetWhseWkshLine(WhseWorkshtLine);

        CreateMovFromWhseSource.RUN;
        DocumentNo := ENGetBufferValue('LastActNo');
        //CreateMovFromWhseSource.GetResultDocInfo(3, DocumentNo);
        // CLEAR(CreateMovFromWhseSource);
    END;

    procedure ENSetBufferValue(Name: Text[250]; ENValue: Text[250])
    begin
        NameValBuff.INIT;
        NameValBuff.Name := Name;
        NameValBuff.Value := ENValue;
        NameValBuff.INSERT;
    end;

    procedure ENGetBufferValue(Name: Text[250]): Text
    begin
        NameValBuff.RESET;
        NameValBuff.SETRANGE(Name, Name);
        IF NameValBuff.FindFirst() then
            exit(NameValBuff.Value)
        else
            exit('');
    end;

    [EventSubscriber(ObjectType::Report, Report::"Whse.-Source - Create Document", 'OnAfterPostReport', '', true, true)]
    procedure ENWhseSrcCreateDocOnAfterPostReport(FirstActivityNo: Code[20]; LastActivityNo: Code[20])

    begin
        NameValBuff.DeleteAll();
        //ENSetBufferValue('FirstActNo', FirstActivityNo);
        ENSetBufferValue('LastActNo', LastActivityNo);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnSetupSplitJnlLineOnBeforeSplitTempLines', '', true, true)]

    procedure ENOnSetupSplitJnlLineOnBeforeSplitTempLines(VAR TempSplitItemJournalLine: Record "Item Journal Line" temporary; VAR TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
        //TR EVALUATE(TempTrackingSpecification."Expiration Date", ENGetBufferValue('ExpDate'));
        //TR TempTrackingSpecification.Modify()
    end;
    /*procedure GetResultDocInfo(WhseDocType: Option; VAR WhseDocNo: Code[20]): Boolean
     begin
         //<<EN1.01
         IF FirstActivityNo = '' THEN
             EXIT(FALSE)
         ELSE BEGIN
             WhseActivHeader.Type := WhseDocType;
             IF WhseWkshLineFound THEN BEGIN
                 IF FirstActivityNo = LastActivityNo THEN
                     WhseDocNo := FirstActivityNo

                 ELSE
                     ERROR(STRSUBSTNO(Text005,
                       FirstActivityNo, LastActivityNo, FORMAT(WhseActivHeader.Type)));
             END ELSE BEGIN
                 IF FirstActivityNo = LastActivityNo THEN
                     WhseDocNo := FirstActivityNo
                 ELSE
                     ERROR(Text005,
                       FirstActivityNo, LastActivityNo, FORMAT(WhseActivHeader.Type));
             END;

             EXIT(EverythingHandled);
         END;
         //>>EN1.01
     end;

 */
    PROCEDURE CreateWMSMovement2(SourceBinCode: Code[10]; ItemNo: Code[20]; ItemUOM: Code[10]; Qty: Decimal; TargetBinCode: Code[10]; LocationCode: Code[10]; VAR DocumentNo: Code[20]; ExpiryDate: Date; WMSUserID: Code[20]; LoadID: Code[20]; PalletNo: Integer; PalletLineNo: Integer)
    VAR
        WhseWorkshtLine: Record 7326;
        CreateMovFromWhseSource: Report 7305;
        NextLineNo: Integer;
        BatchName: Code[10];
    BEGIN
        //<<EN1.23
        CheckForValidPutaway(LocationCode, TargetBinCode, ItemNo, ItemUOM, Qty, ExpiryDate);

        //<<EN1.36
        IF BatchName = '' THEN
            GetBatchName(WMSUserID, BatchName);

        CreateWhseMovementWkSht(LocationCode, BatchName);

        WhseWorkshtLine.RESET;
        WhseWorkshtLine.SETRANGE("Worksheet Template Name", 'MOVEMENT');
        WhseWorkshtLine.SETRANGE(Name, BatchName);
        WhseWorkshtLine.SETRANGE("Location Code", LocationCode);
        WhseWorkshtLine.DELETEALL;
        //IF WhseWorkshtLine.FINDLAST THEN
        //  NextLineNo := WhseWorkshtLine."Line No." + 10000
        //ELSE
        //>>EN1.36
        NextLineNo := 10000;

        WhseWorkshtLine.INIT;
        WhseWorkshtLine."Worksheet Template Name" := 'MOVEMENT';
        WhseWorkshtLine.Name := BatchName; //'DEFAULT'; //EN1.36
        WhseWorkshtLine."Location Code" := LocationCode;
        WhseWorkshtLine."Line No." := NextLineNo;
        WhseWorkshtLine.INSERT;
        WhseWorkshtLine.VALIDATE("Item No.", ItemNo);
        WhseWorkshtLine.VALIDATE("From Bin Code", SourceBinCode);
        WhseWorkshtLine.VALIDATE("To Bin Code", TargetBinCode);
        WhseWorkshtLine.VALIDATE("Unit of Measure Code", ItemUOM); //EN1.16
        WhseWorkshtLine.VALIDATE(Quantity, Qty);
        //TR WhseWorkshtLine."Code Date" := ExpiryDate;  //EN1.16
        WhseWorkshtLine."Whse. Document Type" := WhseWorkshtLine."Whse. Document Type"::"Whse. Mov.-Worksheet";
        WhseWorkshtLine."Whse. Document No." := 'DEFAULT';
        WhseWorkshtLine."Whse. Document Line No." := NextLineNo;
        //<<EN 8/31
        //TR WhseWorkshtLine."Load ID" := LoadID;
        //TR WhseWorkshtLine."Pallet No." := PalletNo;
        //TR WhseWorkshtLine."Pallet Line No." := PalletLineNo;
        //>>EN
        WhseWorkshtLine.MODIFY;

        CreateMovFromWhseSource.SetHideValidationDialog(TRUE);
        //TR CreateMovFromWhseSource.USEREQUESTFORM(FALSE);
        CreateMovFromWhseSource.SetWhseWkshLine(WhseWorkshtLine);
        CreateMovFromWhseSource.RUN;
        commit;
        //TR CreateMovFromWhseSource.GetResultDocInfo(3, DocumentNo);
        CLEAR(CreateMovFromWhseSource);
        //>>EN1.23
    END;

    PROCEDURE RegisterWMSAdjustment(JournalTemplateName: Code[10]; VAR JournalBatchName: Code[10]; LocationCode: Code[10]; LineNo: Integer; WMSUserID: Code[10]);
    VAR
        WhseJournalLine: Record 7311;
        WhseJournalLine2: Record 7311;
        WMSetup: Record 5769;
    BEGIN
        //<<EN1.60
        WhseJournalLine2.RESET;
        WhseJournalLine2.SETRANGE("Journal Template Name", JournalTemplateName);
        WhseJournalLine2.SETRANGE("Journal Batch Name", JournalBatchName);
        WhseJournalLine2.SETRANGE("Location Code", LocationCode);
        WhseJournalLine2.SETFILTER("Item No.", '=%1', '');
        WhseJournalLine2.SetFilter("Line No.", '<>%1', LineNo);
        WhseJournalLine2.DELETEALL;
        //>>EN1.60

        WhseJournalLine2.RESET;
        WhseJournalLine2.SETRANGE("Journal Template Name", JournalTemplateName);
        WhseJournalLine2.SETRANGE("Journal Batch Name", JournalBatchName);
        WhseJournalLine2.SETRANGE("Location Code", LocationCode);
        WhseJournalLine2.SetFilter("Line No.", '<>%1', LineNo);
        WhseJournalLine2.DELETEALL;

        IF WhseJournalLine.GET(JournalTemplateName, JournalBatchName, LocationCode, LineNo) THEN BEGIN
            //<<EN1.46
            IF WhseJournalLine."App. User ID ELA" = '' THEN BEGIN
                WhseJournalLine."App. User ID ELA" := WMSUserID;
                WhseJournalLine.MODIFY;
            END;
            //>>EN1.46
            CODEUNIT.RUN(CODEUNIT::"Whse. Jnl.-Register Batch", WhseJournalLine);
        END ELSE
            ERROR('line not found');

        WMSetup.GET;
        IF NOT WMSetup."Batch Post WMS Adjustment ELA" THEN BEGIN
            CreateWMSAdjustmentItemJnl(WhseJournalLine."Item No.", LocationCode, WMSUserID, JournalBatchName); //<<EN1.12
            PostWMSAdjustmentItemJnl(WhseJournalLine."Item No.", LocationCode, WMSUserID, JournalBatchName);  //<<EN1.12
        END;
    END;

    PROCEDURE CreateWMSAdjustmentItemJnl(ItemNo: Code[20]; LocationCode: Code[10]; WMSUserID: Code[10]; VAR BatchName: Code[10]);
    VAR
        ItemJnlLine: Record 83;
        Item: Record 27;
        WhseSetup: Record 5769;
        CalcWhseAdjmt: Report 7315;
    BEGIN
        WhseSetup.GET;
        IF BatchName = '' THEN
            GetBatchName(WMSUserID, BatchName);

        CreateItemJnlBatch(LocationCode, BatchName, TRUE); //<<EN1.12 + EN1.36
        ItemJnlLine.RESET;
        ItemJnlLine.SETRANGE("Journal Template Name", WhseSetup."Item Jnl Temp. for WMS Adj ELA");
        ItemJnlLine.SETRANGE("Journal Batch Name", BatchName);  //<<EN1.12
        IF ItemNo <> '' THEN
            ItemJnlLine.SETRANGE("Item No.", ItemNo);
        IF LocationCode <> '' THEN
            ItemJnlLine.SETRANGE("Location Code", LocationCode);

        ItemJnlLine.DELETEALL;
        IF ItemNo <> '' THEN
            Item.GET(ItemNo);

        CLEAR(ItemJnlLine);
        ItemJnlLine.INIT;
        ItemJnlLine."Journal Template Name" := WhseSetup."Item Jnl Temp. for WMS Adj ELA";
        ItemJnlLine."Journal Batch Name" := BatchName;  //<<EN1.12
        ItemJnlLine."Document No." := BatchName; //<<EN1.12
        CalcWhseAdjmt.InitializeRequest(TODAY, BatchName);
        CalcWhseAdjmt.SetHideValidationDialog(TRUE);
        CalcWhseAdjmt.UseRequestPage(FALSE);
        CalcWhseAdjmt.SetItemJnlLine(ItemJnlLine);
        IF ItemNo <> '' THEN
            CalcWhseAdjmt.SETTABLEVIEW(Item);

        CalcWhseAdjmt.SetTableView(Item);
        //(Item."No.", LocationCode); //<<EN1.12
        CalcWhseAdjmt.RUN;
        CLEAR(CalcWhseAdjmt);
    END;

    PROCEDURE PostWMSAdjustmentItemJnl(ItemNo: Code[20]; LocationCode: Code[10]; WMSUserID: Code[10]; BatchName: Code[10]);
    VAR
        ItemJnlLine: Record 83;
        WhseSetup: Record 5769;
        Item: Record 27;
    BEGIN
        WhseSetup.GET;
        IF BatchName = '' THEN
            GetBatchName(WMSUserID, BatchName);

        ItemJnlLine.RESET;
        ItemJnlLine.SETRANGE("Journal Template Name", WhseSetup."Item Jnl Temp. for WMS Adj ELA");
        ItemJnlLine.SETRANGE("Journal Batch Name", BatchName); //EN1.12
        IF ItemNo <> '' THEN
            ItemJnlLine.SETRANGE("Item No.", ItemNo);
        IF LocationCode <> '' THEN
            ItemJnlLine.SETRANGE("Location Code", LocationCode);
        IF ItemJnlLine.FINDFIRST THEN
            CODEUNIT.RUN(CODEUNIT::"Item Jnl.-Post", ItemJnlLine);

        DeleteWMSItemJnlBatch(LocationCode, BatchName); //EN1.12
        DeleteWMSPhysInvBatch(LocationCode, BatchName); //EN1.12
    END;

    PROCEDURE PostItemJnl(ItemNo: Code[20]; LocationCode: Code[10]; WMSUserID: Code[10]; BatchName: Code[10]; LotNo: Code[20]);
    VAR
        ItemJnlLine: Record 83;
        WhseSetup: Record 5769;
        Item: Record 27;
    BEGIN
        //<<EN1.53
        WhseSetup.GET;
        IF BatchName = '' THEN
            GetBatchName(WMSUserID, BatchName);

        ItemJnlLine.RESET;
        ItemJnlLine.SETRANGE("Journal Template Name", WhseSetup."Item Jnl Temp. for WMS Adj ELA");
        ItemJnlLine.SETRANGE("Journal Batch Name", BatchName);
        IF ItemNo <> '' THEN
            ItemJnlLine.SETRANGE("Item No.", ItemNo);
        IF LocationCode <> '' THEN
            ItemJnlLine.SETRANGE("Location Code", LocationCode);
        IF ItemJnlLine.FINDFIRST THEN BEGIN
            If LotNo <> '' then begin
                InsertItemJnlItemTrackingLine2(ItemJnlLine, LotNo);
                /* InsertItemJnlItemTrackingLine('', LotNo, ItemJnlLine.Quantity, ItemJnlLine."Journal Template Name", ItemJnlLine."Item No.",
                 ItemJnlLine."Location Code", '', 83, ItemJnlLine."Journal Batch Name", ItemJnlLine."Line No.");
                 ItemJnlLine.Validate("New Lot No.", LotNo);
                 ItemJnlLine.Modify();*/
            end;
            CODEUNIT.RUN(CODEUNIT::"Item Jnl.-Post", ItemJnlLine);
        END;

        //>>EN1.53
    END;

    PROCEDURE PostItemReclassJnl(ItemNo: Code[20]; LocationCode: Code[10]; WMSUserID: Code[10]; BatchName: Code[10]);
    VAR
        ItemJnlLine: Record 83;
        WhseSetup: Record 5769;
        Item: Record 27;
    BEGIN
        //<<EN1.56
        WhseSetup.GET;
        IF BatchName = '' THEN
            GetBatchName(WMSUserID, BatchName);

        ItemJnlLine.RESET;
        ItemJnlLine.SETRANGE("Journal Template Name", WhseSetup."Item Reclass Jnl Template ELA");
        ItemJnlLine.SETRANGE("Journal Batch Name", BatchName);
        IF ItemNo <> '' THEN
            ItemJnlLine.SETRANGE("Item No.", ItemNo);
        IF LocationCode <> '' THEN
            ItemJnlLine.SETRANGE("Location Code", LocationCode);
        IF ItemJnlLine.FINDFIRST THEN
            CODEUNIT.RUN(CODEUNIT::"Item Jnl.-Post", ItemJnlLine);
        //>>EN1.56
    END;

    PROCEDURE PostPhysInvJnl(ItemNo: Code[20]; LocationCode: Code[10]; WMSUserID: Code[10]; BatchName: Code[10]);
    VAR
        ItemJnlLine: Record 83;
        WhseSetup: Record 5769;
        Item: Record 27;
    BEGIN
        //<<EN1.53
        WhseSetup.GET;
        IF BatchName = '' THEN
            GetBatchName(WMSUserID, BatchName);

        ItemJnlLine.RESET;
        ItemJnlLine.SETRANGE("Journal Template Name", WhseSetup."Phys. Jnl Template ELA");
        ItemJnlLine.SETRANGE("Journal Batch Name", BatchName);
        IF ItemNo <> '' THEN
            ItemJnlLine.SETRANGE("Item No.", ItemNo);
        IF LocationCode <> '' THEN
            ItemJnlLine.SETRANGE("Location Code", LocationCode);
        IF ItemJnlLine.FINDFIRST THEN BEGIN
            // IF ItemJnlLine."Code Date" <> COdeDate then begin
            //   ItemJnlLine."Code Date" := codedate;
            //   itemjnlline.modify;
            // end;
            CODEUNIT.RUN(CODEUNIT::"Item Jnl.-Post", ItemJnlLine);
        END;
        //>>EN1.53
    END;

    PROCEDURE CreateWMSItemJnl(TempName: Code[10]; BatchName: Code[10]; ItemNo: Code[20]; ItemUOM: Code[10]; Qty: Decimal; LocCode: Code[10]; BinCode: Code[10]; IsFromBin: Boolean; LotNo: Code[20]);
    VAR
        WhseSetup: Record 5769;
        WhseJnlBatch: Record 7310;
        WhseJnlLine: Record 7311;
        Location: Record 14;
        Bin: Record 7354;
        NoSeriesMgt: Codeunit 396;
        NextLineNo: Integer;
    BEGIN
        // Used for Item Substitution
        //<<EN1.18
        GetWMSItemJnlLine(TempName, BatchName, LocCode, WhseJnlLine);
        WhseJnlLine.INSERT;
        WhseJnlLine."Registering Date" := WORKDATE;
        //WhseJnlLine."wo." := BatchName;
        WhseJnlLine.VALIDATE("Item No.", ItemNo);
        WhseJnlLine.VALIDATE("Unit of Measure Code", ItemUOM);
        WhseJnlLine.VALIDATE(Quantity, Qty);
        //TR WhseJnlLine."Code Date" := CodeDate;  //<<EN1.20
        WhseJnlLine.VALIDATE("Bin Code", BinCode);
        If LotNo <> '' then begin
            InsertWhseItemJnlItemTrackingLine('', LotNo, Qty, TempName, ItemNo, LocCode, '', 7311, BatchName, WhseJnlLine."Line No.");
            WhseJnlLine.Validate("Lot No.", LotNo);
        end;


        Location.GET(LocCode);
        GetBin(Bin, Location.Code, Location."Adjustment Bin Code");
        IF Qty > 0 THEN BEGIN
            WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::"Positive Adjmt.";
            WhseJnlLine."From Zone Code" := Bin."Zone Code";
            WhseJnlLine."From Bin Code" := Bin.Code;
            WhseJnlLine."From Bin Type Code" := Bin."Bin Type Code";
        END ELSE BEGIN
            WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::"Negative Adjmt.";
            WhseJnlLine."To Zone Code" := Bin."Zone Code";
            WhseJnlLine."To Bin Code" := Bin.Code;
        END;

        //TR WhseJnlLine."Code Date" := CodeDate;  //<<EN1.20

        WhseJnlLine.MODIFY;
        //>>EN1.18
    END;


    procedure InsertWhseItemJnlItemTrackingLine(SerialNo: Code[20]; LotNo: Code[20]; Qty: Decimal; JournalTemplateName: Code[20]; ItemNo: Code[20];
        LocationCode: Code[20]; VariantCode: Code[20]; FormSourceType: Integer; SourceID: Code[20]; SourceRefNo: integer)
    var
        WhseJnlLine: Record 7311;
        WhseItemTrackingLine: Record "Whse. Item Tracking Line";
        WhseItemTrackingLine2: Record "Whse. Item Tracking Line";
    begin
        With WhseItemTrackingLine DO BEGIN
            INIT;
            VALIDATE("Lot No.", LotNo);
            VALIDATE("Serial No.", SerialNo);
            //"Expiration Date" := ExpirationDate;
            //"Qty. per Unit of Measure" := QtyperUnitofMeasure;
            VALIDATE("Item No.", ItemNo);
            VALIDATE("Quantity (Base)", Abs(Qty));
            "Source Type" := FormSourceType;
            "Source ID" := SourceID;
            "Source Ref. No." := SourceRefNo;
            "Source Batch Name" := JournalTemplateName;
            "Location Code" := LocationCode;

            "Variant Code" := VariantCode;
            IF WhseItemTrackingLine2.FIND('+') THEN;
            "Entry No." := WhseItemTrackingLine2."Entry No." + 1;
            INSERT;

        end;

    end;

    procedure InsertItemJnlItemTrackingLine2(var ItemJnlLine: Record "Item Journal Line"; LotNo: Code[20])
    var
        ReserveLine: Record 337;
        ReserveLine2: Record 337;
        LotNoInfo: Record "Lot No. Information";
    begin
        ReserveLine."Reservation Status" := ReserveLine."Reservation Status"::Prospect;
        ReserveLine."Creation Date" := WORKDATE;
        ReserveLine."Source Type" := 83;
        ReserveLine."Source Subtype" := 2;
        ReserveLine."Source ID" := ItemJnlLine."Journal Template Name";
        ReserveLine."Source Batch Name" := ItemJnlLine."Journal Batch Name";
        ReserveLine."Source Ref. No." := ItemJnlLine."Line No.";
        ReserveLine.Positive := TRUE;
        ReserveLine.VALIDATE("Location Code", ItemJnlLine."Location Code");
        //ReserveLine.VALIDATE("bin", ItemJnlLine."Bin Code");
        ReserveLine.VALIDATE("Item No.", ItemJnlLine."Item No.");
        ReserveLine.VALIDATE("Quantity (Base)", ItemJnlLine.Quantity);
        ReserveLine.VALIDATE(Quantity, ItemJnlLine.Quantity);
        ReserveLine."Lot No." := LotNo;

        IF ReserveLine2.FIND('+') THEN
            ReserveLine."Entry No." := ReserveLine2."Entry No." + 1;

        IF ReserveLine.INSERT(TRUE) THEN BEGIN
            LotNoInfo.INIT;
            LotNoInfo.VALIDATE("Item No.", ReserveLine."Item No.");
            LotNoInfo.VALIDATE("Lot No.", ReserveLine."Lot No.");
            LotNoInfo.INSERT(TRUE);
        END
    END;
    /*

        procedure InsertItemJnlItemTrackingLine(var ItemJnlLine: Record "Item Journal Line"; LotNo: Code[20])
        var
            ReservationManagement: Codeunit "Reservation Management";
            DoFullReceive: boolean;
            ItemJnlLineReserve: codeunit "Item Jnl. Line-Reserve";
            lReservationEntry: Record 337;
            lReservEntryILE: Record 337;
            lReservEntryEdit: Record 337;
        begin
            ReservationManagement.SetItemJnlLine(ItemJnlLine);
            //error('%1', ItemJnlLine."Source Type");
            commit;
            ReservationManagement.AutoReserve(DoFullReceive, ItemJnlLine.Description, WORKDATE, ItemJnlLine.Quantity, ItemJnlLine."Quantity (Base)");
            ItemJnlLineReserve.FilterReservFor(lReservationEntry, ItemJnlLine);
            IF lReservationEntry.FINDSET THEN
                REPEAT
                    lReservEntryILE.GET(lReservationEntry."Entry No.", NOT lReservationEntry.Positive);
                    lReservEntryEdit.GET(lReservationEntry."Entry No.", lReservationEntry.Positive);
                    lReservEntryEdit."Lot No." := LotNo;
                    lReservEntryEdit.MODIFY;
                UNTIL lReservationEntry.NEXT = 0;
        end;

        procedure InsertItemJnlItemTrackingLine(SerialNo: Code[20]; LotNo: Code[20]; Qty: Decimal; JournalTemplateName: Code[20]; ItemNo: Code[20];
            LocationCode: Code[20]; VariantCode: Code[20]; FormSourceType: Integer; SourceID: Code[20]; SourceRefNo: integer)
        var
            ItemJnlLine: Record "Item Journal Line";

            ItemTrackingLine: Record "Tracking Specification";
            ItemTrackingLine2: Record "Tracking Specification";
        begin
            With ItemTrackingLine DO BEGIN
                INIT;
                VALIDATE("Lot No.", LotNo);
                VALIDATE("Serial No.", SerialNo);
                //"Expiration Date" := ExpirationDate;
                //"Qty. per Unit of Measure" := QtyperUnitofMeasure;
                VALIDATE("Item No.", ItemNo);
                VALIDATE("Quantity (Base)", Abs(Qty));
                "Source Type" := FormSourceType;
                "Source ID" := JournalTemplateName;
                "Source Ref. No." := SourceRefNo;
                "Source Batch Name" := SourceID;
                "Location Code" := LocationCode;
                "Creation Date" := TODAY;
                "Variant Code" := VariantCode;
                IF ItemTrackingLine2.FIND('+') THEN;
                "Entry No." := ItemTrackingLine2."Entry No." + 1;
                INSERT;

            end;

        end;
    */

    PROCEDURE GenerateWHPhysInvJnl(LocCode: Code[10]; BinCode: Code[10]; ItemNo: Code[20]; WMSUserID: Code[10]; VAR BatchName: Code[10]);
    VAR
        WhseSetup: Record 5769;
        BinContent: Record 7302;
        WhseJnlLine: Record 7311;
        WhseCalcInventory: Report 7390;
    BEGIN
        //<<EN1.12
        CLEAR(WhseJnlLine);
        WhseSetup.GET;
        GetWMSItemJnlLine(WhseSetup."WMS Phys. Jnl. Template ELA", BatchName, LocCode, WhseJnlLine);

        BinContent.RESET;
        BinContent.SETRANGE("Location Code", LocCode);
        BinContent.SETRANGE("Bin Code", BinCode);
        IF ItemNo <> '' THEN //<<EN1.42
            BinContent.SETRANGE("Item No.", ItemNo);

        WhseCalcInventory.InitializeRequest(TODAY, WhseJnlLine."Whse. Document No.", FALSE);
        WhseCalcInventory.SetWhseJnlLine(WhseJnlLine);
        WhseCalcInventory.SETTABLEVIEW(BinContent);
        WhseCalcInventory.SetHideValidationDialog(TRUE);
        WhseCalcInventory.UseRequestPage(FALSE);
        WhseCalcInventory.Run();
        CLEAR(WhseCalcInventory);

        // check if zone is empty delete it  form batch
        WhseJnlLine.RESET;
        WhseJnlLine.SETRANGE("Journal Template Name", WhseSetup."WMS Phys. Jnl. Template ELA");
        WhseJnlLine.SETRANGE("Journal Batch Name", BatchName);
        WhseJnlLine.SETRANGE("Zone Code", '');
        WhseJnlLine.DELETEALL;
        //>>EN1.12
    END;

    PROCEDURE GeneratePhysInvJnl(LocCode: Code[10]; BinCode: Code[10]; ItemNo: Code[20]; WMSUserID: Code[10]; VAR BatchName: Code[10]; LotNo: Code[20]);
    VAR
        WhseSetup: Record 5769;
        BinContent: Record 7302;
        ItemJnlLine: Record 83;
        CalcInventory: Report 790;
        Item: Record 27;
        ItemLedger: Record 32;
    BEGIN
        //<<EN1.53
        CLEAR(ItemJnlLine);
        WhseSetup.GET;
        ItemJnlLine.RESET;
        ItemJnlLine.SETRANGE("Journal Template Name", WhseSetup."Phys. Jnl Template ELA");
        ItemJnlLine.SETRANGE("Journal Batch Name", BatchName);  //<<EN1.12
        IF ItemNo <> '' THEN
            ItemJnlLine.SETRANGE("Item No.", ItemNo);
        IF LocCode <> '' THEN
            ItemJnlLine.SETRANGE("Location Code", LocCode);
        ItemJnlLine.DELETEALL;

        ItemJnlLine.INIT;
        ItemJnlLine."Journal Template Name" := WhseSetup."Phys. Jnl Template ELA";
        ItemJnlLine."Journal Batch Name" := BatchName;
        ItemJnlLine."Line No." := 10000;
        ItemJnlLine."Document No." := BatchName;

        //<<EN1.90
        Item.RESET;
        IF ItemNo <> '' THEN
            Item.SETRANGE("No.", ItemNo);
        Item.SETFILTER("Location Filter", LocCode);
        Item.SETFILTER("Bin Filter", BinCode);
        //>>EN1.90

        CalcInventory.SetItemJnlLine(ItemJnlLine);
        CalcInventory.InitializeRequest(TODAY, BatchName, False, False);
        CalcInventory.SETTABLEVIEW(Item);
        CalcInventory.SetHideValidationDialog(TRUE);
        CalcInventory.UseRequestPage(FALSE);
        if GuiAllowed THEN
            CalcInventory.RUNMODAL()
        Else
            CalcInventory.Run();
        CLEAR(CalcInventory);
        //>>EN1.53
    END;

    PROCEDURE GetBatchName(WMSUserID: Code[20]; VAR BatchName: Code[10]);
    BEGIN
        //<<EN1.12
        BatchName := COPYSTR(WMSUserID, 1, 4);
        BatchName := BatchName + FORMAT(TODAY, 0, '<Year><Month,2><Day,2>');
        IF STRLEN(BatchName) > 10 THEN
            BatchName := COPYSTR(BatchName, 1, 10);
        //>>EN1.12
    END;

    PROCEDURE CreateItemJnlBatch(LocationCode: Code[10]; BatchName: Code[10]; DoSuppressMessages: Boolean);
    VAR
        WhseSetup: Record 5769;
        ItemJnlBatch: Record 233;
        NewItemJnlBatch: Record 233;
    BEGIN
        //<<EN1.12
        WhseSetup.GET;
        WhseSetup.TESTFIELD(WhseSetup."Item Jnl Temp. for WMS Adj ELA");
        IF NOT ItemJnlBatch.GET(WhseSetup."Item Jnl Temp. for WMS Adj ELA", BatchName) THEN BEGIN
            NewItemJnlBatch.INIT;
            NewItemJnlBatch."Journal Template Name" := WhseSetup."Item Jnl Temp. for WMS Adj ELA";
            NewItemJnlBatch.Name := BatchName;
            NewItemJnlBatch."No. Series" := '';
            NewItemJnlBatch."Template Type" := NewItemJnlBatch."Template Type"::Item;
            NewItemJnlBatch."Suppress Messages ELA" := DoSuppressMessages;
            NewItemJnlBatch."System Created ELA" := TRUE; //<<EN1.54
            NewItemJnlBatch.INSERT(TRUE); //<<EN1.54
            COMMIT;
        END;
        //>>EN1.12
    END;

    PROCEDURE CreateItemReclassJnlBatch(LocationCode: Code[10]; BatchName: Code[10]; VAR TemplateName: Code[10]; DoSuppressMessages: Boolean);
    VAR
        WhseSetup: Record 5769;
        ItemJnlBatch: Record 233;
        NewItemJnlBatch: Record 233;
    BEGIN
        //<<EN1.56
        WhseSetup.GET;
        WhseSetup.TESTFIELD(WhseSetup."Item Reclass Jnl Template ELA");
        TemplateName := WhseSetup."Item Reclass Jnl Template ELA";
        DeleteItemReclassJnlBatch(BatchName);
        IF NOT ItemJnlBatch.GET(WhseSetup."Item Reclass Jnl Template ELA", BatchName) THEN BEGIN
            NewItemJnlBatch.INIT;
            NewItemJnlBatch."Journal Template Name" := WhseSetup."Item Reclass Jnl Template ELA";
            NewItemJnlBatch.Name := BatchName;
            NewItemJnlBatch."No. Series" := '';
            NewItemJnlBatch."Template Type" := NewItemJnlBatch."Template Type"::Transfer;
            NewItemJnlBatch."Suppress Messages ELA" := DoSuppressMessages;
            NewItemJnlBatch."System Created ELA" := TRUE;
            NewItemJnlBatch.INSERT(TRUE);
            COMMIT;
        END;
        //>>EN1.56
    END;

    PROCEDURE CreatePhysInvJnlBatch(LocationCode: Code[10]; BatchName: Code[10]; DoSuppressMessages: Boolean);
    VAR
        WhseSetup: Record 5769;
        ItemJnlBatch: Record 233;
        NewItemJnlBatch: Record 233;
    BEGIN
        //<<EN1.53
        WhseSetup.GET;
        WhseSetup.TESTFIELD(WhseSetup."Phys. Jnl Template ELA");
        IF NOT ItemJnlBatch.GET(WhseSetup."Phys. Jnl Template ELA", BatchName) THEN BEGIN
            NewItemJnlBatch.INIT;
            NewItemJnlBatch."Journal Template Name" := WhseSetup."Phys. Jnl Template ELA";
            NewItemJnlBatch.Name := BatchName;
            NewItemJnlBatch."No. Series" := '';
            NewItemJnlBatch."Template Type" := NewItemJnlBatch."Template Type"::"Phys. Inventory";
            NewItemJnlBatch."Suppress Messages ELA" := DoSuppressMessages;
            NewItemJnlBatch."System Created ELA" := TRUE; //<<EN1.54
            NewItemJnlBatch.INSERT(TRUE);  //<<EN1.54
            COMMIT;
        END;
        //>>EN1.53
    END;

    PROCEDURE CreateWMSPhysInvBatch(LocationCode: Code[10]; BatchName: Code[10]);
    VAR
        WhseSetup: Record 5769;
        WhseJnlBatch: Record 7310;
        NewWhseJnlBatch: Record 7310;
        WhseJnlTemplate: Record 7309;
    BEGIN
        //<<EN1.12
        WhseSetup.GET;
        WhseSetup.TESTFIELD("WMS Phys. Jnl. Template ELA");
        WhseSetup.TESTFIELD("WMS Phys. Jnl. Nos. ELA"); //EN1.16
        IF NOT WhseJnlBatch.GET(WhseSetup."WMS Phys. Jnl. Template ELA", BatchName, LocationCode) THEN BEGIN
            WhseJnlTemplate.GET(WhseSetup."WMS Phys. Jnl. Template ELA"); //EN1.58
            NewWhseJnlBatch.INIT;
            NewWhseJnlBatch."Journal Template Name" := WhseSetup."WMS Phys. Jnl. Template ELA";
            NewWhseJnlBatch.Name := BatchName;
            NewWhseJnlBatch."Location Code" := LocationCode;
            NewWhseJnlBatch."No. Series" := WhseJnlTemplate."No. Series"; //EN1.58
            NewWhseJnlBatch."Template Type" := WhseJnlTemplate.Type;  //EN1.58
            NewWhseJnlBatch."System Created ELA" := TRUE;  //<<EN1.54
            NewWhseJnlBatch.INSERT(TRUE); //en1.54
            COMMIT;
        END;
        //>>EN1.12
    END;

    PROCEDURE CreateWMSItemJnlBatch(LocationCode: Code[10]; BatchName: Code[10]);
    VAR
        WhseSetup: Record 5769;
        WhseJnlBatch: Record 7310;
        NewWhseJnlBatch: Record 7310;
        WhseJnlTemplate: Record 7309;
    BEGIN
        //<<EN1.12
        WhseSetup.GET;
        WhseSetup.TESTFIELD(WhseSetup."WMS Item Jnl. Template ELA");
        WhseSetup.TESTFIELD("WMS Item Jnl. No. ELA"); //EN1.16
        IF NOT WhseJnlBatch.GET(WhseSetup."WMS Item Jnl. Template ELA", BatchName, LocationCode) THEN BEGIN
            WhseJnlTemplate.GET(WhseSetup."WMS Item Jnl. Template ELA"); //EN1.58
            NewWhseJnlBatch.INIT;
            NewWhseJnlBatch."Journal Template Name" := WhseSetup."WMS Item Jnl. Template ELA";
            NewWhseJnlBatch.Name := BatchName;
            NewWhseJnlBatch."Location Code" := LocationCode;
            NewWhseJnlBatch."No. Series" := WhseJnlTemplate."No. Series"; //EN1.58
            NewWhseJnlBatch."Template Type" := WhseJnlTemplate.Type;  //EN1.58
            NewWhseJnlBatch."System Created ELA" := TRUE;  //<<EN1.54
            NewWhseJnlBatch.INSERT(TRUE);  //<<EN1.54
            COMMIT;
        END;
        //>>EN1.12
    END;

    PROCEDURE CreateWhseMovementWkSht(LocationCode: Code[10]; NewWkshtName: Code[20]);
    VAR
        WhseWksheetName: Record 7327;
        cod: Codeunit 7302;
    BEGIN
        //<<EN1.24
        IF NOT WhseWksheetName.GET('MOVEMENT', NewWkshtName, LocationCode) THEN BEGIN
            WhseWksheetName.INIT;
            WhseWksheetName."Worksheet Template Name" := 'MOVEMENT';
            WhseWksheetName.Name := NewWkshtName;
            WhseWksheetName."Location Code" := LocationCode;
            WhseWksheetName.Description := NewWkshtName;
            WhseWksheetName."Template Type" := WhseWksheetName."Template Type"::Movement;
            //TR   WhseWksheetName."System Created" := TRUE; //EN1.54
            WhseWksheetName.INSERT(TRUE); //EN1.54
        END;
        //>>EN1.24
    END;

    PROCEDURE PopulateItemReclassJnlBatch(LocationCode: Code[10]; BatchName: Code[10]; ItemNo: Code[20]; ItemUOM: Code[10]; FromBinCode: Code[10]);
    VAR
        BinContent: Record 7302;
        GetBinContent: Report 7391;
        WhseSetup: Record 5769;
        ItemJnlBatch: Record 233;
        ItemJnlLine: Record 83;
    BEGIN
        //<<EN1.56
        WhseSetup.GET;
        ItemJnlLine.RESET;
        ItemJnlLine.SETRANGE("Journal Template Name", WhseSetup."Item Reclass Jnl Template ELA");
        ItemJnlLine.SETRANGE("Journal Batch Name", BatchName);
        ItemJnlLine.DELETEALL;

        CLEAR(GetBinContent);
        BinContent.SETRANGE("Location Code", LocationCode);
        BinContent.SETRANGE("Bin Code", FromBinCode);
        BinContent.SETRANGE("Item No.", ItemNo);
        BinContent.SETRANGE("Unit of Measure Code", ItemUOM);
        //TR BinContent.SETRANGE("Code Date", CodeDate);
        GetBinContent.SETTABLEVIEW(BinContent);

        ItemJnlLine.INIT;
        ItemJnlLine."Journal Template Name" := WhseSetup."Item Reclass Jnl Template ELA";
        ItemJnlLine."Journal Batch Name" := BatchName;
        ItemJnlLine."Line No." := 10000;
        ItemJnlLine."Posting Date" := TODAY;
        ItemJnlLine."Document No." := BatchName;

        GetBinContent.InitializeItemJournalLine(ItemJnlLine);
        GetBinContent.UseRequestPage(FALSE);
        GetBinContent.RUN;
        //>>EN1.56
    END;

    PROCEDURE UpdateItemJournalLine(BatchName: Code[20]; TemplateName: code[20]; ToBinCode: Code[20]; Qty: Decimal; ReasonCode: Code[20])
    var
        ItemJnlLine: Record "Item Journal Line";
    begin
        ItemJnlLine.Reset();
        ItemJnlLine.SetRange("Journal Template Name", TemplateName);
        ItemJnlLine.SetRange("Journal Batch Name", BatchName);
        IF ItemJnlLine.FindFirst() THEN BEGIN
            ItemJnlLine.Validate("New Bin Code", ToBinCode);
            ItemJnlLine.Validate(Quantity, Qty);
            ItemJnlLine.Validate("Reason Code", ReasonCode);
            ItemJnlLine.Modify();
        END
    end;

    PROCEDURE DeleteItemJnlBatch(BatchName: Code[10]);
    VAR
        WhseSetup: Record 5769;
        ItemJnlBatch: Record 233;
        NewItemJnlBatch: Record 233;
    BEGIN
        //<<EN1.12
        WhseSetup.GET;
        WhseSetup.TESTFIELD(WhseSetup."Item Jnl Temp. for WMS Adj ELA");
        IF ItemJnlBatch.GET(WhseSetup."Item Jnl Temp. for WMS Adj ELA", BatchName) THEN
            IF ItemJnlBatch.DELETE(TRUE) THEN;
        //>>EN1.12
    END;

    procedure WhseAdjustmentQty(RegWhseActType: Option ,"Put-away",Pick,Movement; RegWhsActNo: Code[20]; RegWhseActLineNo: Integer; NewItemNo: Code[20]; NewItemDesc: text[50];
     NewShipmentNo: Code[20]; NewShipmentLineNo: Integer; NewContId: Code[20]; NewContContent: Integer; NewAdjQty: Decimal; ReasonCode: Code[20]; HideDialogBox: Boolean)
    var
        WhseShipLine: Record "Warehouse Shipment Line";
        WhseShipLine2: Record "Warehouse Shipment Line";
        RegWhseActLine: Record "Registered Whse. Activity Line";
        RegWhseActLine2: Record "Registered Whse. Activity Line";
        PickedActLine: Record "Registered Whse. Activity Line";
        ShipDashBrd: Record "Shipment Dashboard ELA";
        WhseCommentLine: Record "Warehouse Comment Line";
        Location: Record Location;
        WeightPerUnit: Decimal;
        NewWeightPerUnit: Decimal;
        ShippedLinePickedQty: Decimal;
        TotalPickedLinesQty: Decimal;
        NewPickedQty: Decimal;
        QtyToReduce: Decimal;
        NewShippedQty: Decimal;
        //RtcWindow: DotNet "'Microsoft.VisualBasic, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'.Microsoft.VisualBasic.Interaction";
        Window: Dialog;
        WinMsg: Text[250];
        NextCommentLineNo: Integer;
        Comment: Text[250];
        ItemNo: Code[20];
        ItemDesc: Text[50];
        ItemUOM: Code[10];
        LocCode: Code[10];
        PutBackBin: Code[10];
        MovDocNo: Code[20];
        CodeDate: Date;
        ContainerContent: Record "Container Content ELA";
        BatchName: code[20];
        TemplateName: Code[20];
        WhseSetup: Record "Warehouse Setup";
        RegWhseActivityLine: Record "Registered Whse. Activity Line";
        ShipmentNo: Code[20];
        ShipmentLineNo: Integer;
        ContainerLineNo: Integer;
        NewEnteredQty: Decimal;
        ContainerNo: Code[20];
        TakeLineNo: Integer;
        PlaceLineNo: Integer;
        TXT001: TextConst ENU = 'Enter New Quantity for Item No. %1 %2 Pallet No. %3 Pallet Line No. %4';
        TXT005: TextConst ENU = 'You cannot overship through adjustment. Please update qty using shipment dashboard';
        TXT006: TextConst ENU = 'Please enter the valid New Qty';
        TXT007: TextConst ENU = 'User %1 Changed Item No. %2 Qty %3 to %4';
        TXT010: TextConst ENU = 'Do you want to move the adjusted Qty. %1 Item %2 %3 back to Bin No. %4';
    begin

        ItemNo := NewItemNo;
        ItemDesc := NewItemDesc;
        ShipmentNo := NewShipmentNo;
        ShipmentLineNo := NewShipmentLineNo;
        ContainerNo := NewContId;
        ContainerLineNo := NewContContent;
        If RegWhseActivityLine.Get(RegWhseActType, RegWhsActNo, RegWhseActLineNo) Then;
        //<<EN1.02
        WhseSetup.Get;
        //<<EN1.03
        IF NewAdjQty <= 0 THEN
            ERROR(TXT006);

        NewEnteredQty := NewAdjQty;
        //<<EN1.05
        IF NewEnteredQty < 0 THEN
            ERROR('You cannot enter negative qty. Please enter the new quantity');


        ContainerContent.RESET;
        ContainerContent.SETRANGE("Container No.", ContainerNo);
        ContainerContent.SETRANGE("Line No.", ContainerLineNo);
        IF ContainerContent.FINDFIRST THEN BEGIN
            IF NewEnteredQty > ContainerContent.Quantity THEN
                ERROR(TXT005);

            IF NewEnteredQty = 0 THEN
                QtyToReduce := ContainerContent.Quantity
            ELSE
                QtyToReduce := ContainerContent.Quantity - NewEnteredQty;

            ContainerContent.Quantity := NewEnteredQty;
            ContainerContent.MODIFY;
        END;

        GetRegWhseTakePlaceLineNo(RegWhseActivityLine, TakeLineNo, PlaceLineNo);

        IF RegWhseActLine.GET(RegWhseActivityLine."Activity Type"::Pick, RegWhseActivityLine."No.", TakeLineNo) THEN begin
            ItemNo := RegWhseActLine."Item No.";
            ItemDesc := RegWhseActLine.Description;
            ItemUOM := RegWhseActLine."Unit of Measure Code";
            LocCode := RegWhseActLine."Location Code";
            PutBackBin := RegWhseActLine."Bin Code";

            PickedActLine.RESET;
            PickedActLine.SETRANGE(PickedActLine."Activity Type", PickedActLine."Activity Type"::Pick);
            PickedActLine.SETRANGE(PickedActLine."Action Type", PickedActLine."Action Type"::Take);
            PickedActLine.SETRANGE("Whse. Document No.", RegWhseActLine."Whse. Document No.");
            PickedActLine.SETRANGE("Whse. Document Line No.", RegWhseActLine."Whse. Document Line No.");
            IF PickedActLine.FINDSET THEN
                REPEAT
                    TotalPickedLinesQty := TotalPickedLinesQty + PickedActLine.Quantity;
                UNTIL PickedActLine.NEXT = 0;
            IF NewEnteredQty > RegWhseActLine.Quantity THEN
                ERROR(TXT005);

            IF NewEnteredQty = 0 THEN
                QtyToReduce := RegWhseActLine.Quantity
            ELSE
                QtyToReduce := RegWhseActLine.Quantity - NewEnteredQty;
            TotalPickedLinesQty := TotalPickedLinesQty - QtyToReduce;
            // message('%1 ',TotalPickedLinesQty);

            IF RegWhseActLine.Weight <> 0 THEN BEGIN
                IF RegWhseActLine.Quantity > 0 THEN
                    WeightPerUnit := RegWhseActLine.Weight / RegWhseActLine.Quantity
                ELSE
                    WeightPerUnit := 0;

                NewWeightPerUnit := WeightPerUnit * NewEnteredQty;
            END;

            RegWhseActLine."Original Qty. ELA" := RegWhseActLine.Quantity;
            RegWhseActLine.Quantity := NewEnteredQty;
            RegWhseActLine."Qty. (Base)" := NewEnteredQty * RegWhseActLine."Qty. per Unit of Measure";
            RegWhseActLine.Weight := NewWeightPerUnit;
            RegWhseActLine."Reason Code ELA" := ReasonCode;
            RegWhseActLine.MODIFY;
            //  message('reg 1 %1 ', RegWhseActLine.Quantity);
            IF RegWhseActLine2.GET(RegWhseActLine2."Activity Type"::Pick, RegWhseActivityLine."No.", PlaceLineNo) THEN begin
                RegWhseActLine2.Quantity := RegWhseActLine.Quantity;
                RegWhseActLine2."Qty. (Base)" := RegWhseActLine."Qty. (Base)";
                RegWhseActLine2.Weight := RegWhseActLine.Weight;
                RegWhseActLine2."Reason Code ELA" := ReasonCode;
                RegWhseActLine2.MODIFY;
            end;
        end;
        //<<EN1.02
        IF WhseShipLine.GET(ShipmentNo, ShipmentLineNo) THEN BEGIN
            Comment := STRSUBSTNO(TXT007, USERID, WhseShipLine."Item No.", WhseShipLine."Qty. Picked", TotalPickedLinesQty);
            AddWhseComment(ShipmentNo, ShipmentLineNo, WhseCommentLine."Table Name"::"Whse. Shipment", 0, USERID, Comment);
            //>>EN1.02

            WhseShipLine."Qty. Picked" := TotalPickedLinesQty;
            WhseShipLine."Qty. Picked (Base)" := TotalPickedLinesQty * WhseShipLine."Qty. per Unit of Measure";
            WhseShipLine."Qty. to Ship" := TotalPickedLinesQty;
            WhseShipLine."Qty. to Ship (Base)" := TotalPickedLinesQty * WhseShipLine."Qty. per Unit of Measure";
            WhseShipLine."Completely Picked" := FALSE;
            WhseShipLine.MODIFY;
            //message (' whse qty picked %1',  WhseShipLine."Qty. Picked");

        END;// ELSE
            // ERROR(TXT004);

        ShipDashBrd.RESET;
        ShipDashBrd.SETRANGE("Shipment No.", ShipmentNo);
        ShipDashBrd.SETRANGE("Shipment Line No.", ShipmentLineNo);
        IF ShipDashBrd.FINDFIRST THEN BEGIN
            ShipDashBrd."Picked Qty." := TotalPickedLinesQty;
            ShipDashBrd.Completed := FALSE;
            ShipDashBrd."Full Pick" := FALSE;
            ShipDashBrd.MODIFY;
            // message ('ship db picked %1',TotalPickedLinesQty)     ;
        END;



        //<<EN1.02
        IF WhseSetup."Move Adjusted Stock Back ELA" THEN BEGIN
            IF NOT HideDialogBox THEN
                IF NOT CONFIRM(STRSUBSTNO(TXT010, QtyToReduce, ItemNo, ItemDesc, PutBackBin)) THEN
                    EXIT;

            Location.GET(LocCode);
            GetBatchName(UserId, BatchName);
            CreateItemReclassJnlBatch(LocCode, BatchName, TemplateName, true);
            PopulateItemReclassJnlBatch(LocCode, BatchName, ItemNo, ItemUOM, Location."Shipment Bin Code");
            UpdateItemJournalLine(BatchName, TemplateName, PutBackBin, QtyToReduce, ReasonCode);
            PostItemReclassJnl(ItemNo, LocCode, UserId, BatchName);
            //  WMSServices.CreateWMSMovement(Location."Shipment Bin Code", ItemNo, ItemUOM, QtyToReduce, PutBackBin, LocCode, MovDocNo, CodeDate,
            //  USERID);

            // WMSServices.RegisterWMSMovement(MovDocNo, ItemNo, QtyToReduce, PutBackBin, USERID);
        END;

        //>>EN1.02
        //>>EN1.03
    end;

    local procedure GetRegWhseTakePlaceLineNo(RegisterWhseActLine: Record "Registered Whse. Activity Line"; Var TakeLine: Integer; var PlaceLine: Integer)
    var
        RgWhActLine: Record "Registered Whse. Activity Line";
    begin
        IF RegisterWhseActLine."Action Type" = RegisterWhseActLine."Action Type"::Take THEN begin
            RgWhActLine.RESET;
            RgWhActLine.SetRange("No.", RegisterWhseActLine."No.");
            RgWhActLine.SetRange("Parent Line No. ELA", RegisterWhseActLine."Line No.");
            IF RgWhActLine.FindFirst() THEN begin
                TakeLine := RgWhActLine."Parent Line No. ELA";
                PlaceLine := RgWhActLine."Line No.";
            end;
        end;
    end;



    PROCEDURE DeleteItemReclassJnlBatch(BatchName: Code[10]);
    VAR
        WhseSetup: Record 5769;
        ItemJnlBatch: Record 233;
        NewItemJnlBatch: Record 233;
    BEGIN
        //<<EN1.56
        WhseSetup.GET;
        WhseSetup.TESTFIELD(WhseSetup."Item Reclass Jnl Template ELA");
        IF ItemJnlBatch.GET(WhseSetup."Item Reclass Jnl Template ELA", BatchName) THEN
            IF ItemJnlBatch.DELETE(TRUE) THEN;
        //>>EN1.56
    END;

    PROCEDURE DeletePhyInvJnlBatch(BatchName: Code[10]);
    VAR
        WhseSetup: Record 5769;
        ItemJnlBatch: Record 233;
        NewItemJnlBatch: Record 233;
    BEGIN
        //<<EN1.53
        WhseSetup.GET;
        WhseSetup.TESTFIELD(WhseSetup."Phys. Jnl Template ELA");
        IF ItemJnlBatch.GET(WhseSetup."Phys. Jnl Template ELA", BatchName) THEN
            IF ItemJnlBatch.DELETE(TRUE) THEN;
        //>>EN1.53
    END;

    PROCEDURE DeleteWMSPhysInvBatch(LocationCode: Code[10]; BatchName: Code[10]);
    VAR
        WhseSetup: Record 5769;
        WhseJnlBatch: Record 7310;
        NewWhseJnlBatch: Record 7310;
    BEGIN
        //<<EN1.12
        WhseSetup.GET;
        WhseSetup.TESTFIELD("WMS Phys. Jnl. Template ELA");
        IF WhseJnlBatch.GET(WhseSetup."WMS Phys. Jnl. Template ELA", BatchName, LocationCode) THEN
            WhseJnlBatch.DELETE(TRUE);
        //>>EN1.12
    END;

    PROCEDURE DeleteWMSItemJnlBatch(LocationCode: Code[10]; BatchName: Code[10]);
    VAR
        WhseSetup: Record 5769;
        WhseJnlBatch: Record 7310;
        NewWhseJnlBatch: Record 7310;
    BEGIN
        //<<EN1.12
        WhseSetup.GET;
        WhseSetup.TESTFIELD(WhseSetup."WMS Item Jnl. Template ELA");
        IF WhseJnlBatch.GET(WhseSetup."WMS Item Jnl. Template ELA", BatchName, LocationCode) THEN
            WhseJnlBatch.DELETE(TRUE);
        //>>EN1.12
    END;

    PROCEDURE DeleteEmptyBinContent(LocationCode: Code[10]; ZoneCode: Code[10]; BinCode: Code[10]);
    VAR
        WhseMgt: Codeunit 7302;
    BEGIN
        //TR WhseMgt.DeleteBinContent(LocationCode, ZoneCode, BinCode);
    END;



    PROCEDURE BackOrderPendingPicksOnBin(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; ItemUOM: Code[10]): Boolean;
    VAR
        BinContent: Record 7302;
        WhseActLine: Record 5767;
        WhseActLine2: Record 5767;
        ShipDashbrdMgt: Codeunit "Shipment Mgmt. ELA";
    BEGIN
        //<<EN1.23
        WhseActLine.RESET;
        WhseActLine.SETRANGE("Activity Type", WhseActLine."Activity Type"::Pick, WhseActLine."Activity Type"::Movement); //EN1.26
        WhseActLine.SETRANGE("Action Type", WhseActLine."Action Type"::Take);
        WhseActLine.SETRANGE("Location Code", LocationCode);
        WhseActLine.SETRANGE("Bin Code", BinCode);
        WhseActLine.SETRANGE("Item No.", ItemNo);
        WhseActLine.SETRANGE("Unit of Measure Code", ItemUOM);
        IF WhseActLine.FINDSET THEN
            REPEAT
                BackOrderPickLine(WhseActLine."Activity Type", WhseActLine."No.", WhseActLine."Line No."); //EN1.26
            UNTIL WhseActLine.NEXT = 0;
        //>>EN1.23
    END;

    PROCEDURE DeletePendingPutawaysOnBin(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; ItemUOM: Code[10]): Boolean;
    VAR
        BinContent: Record 7302;
        WhseActHdr: Record 5766;
        WhseActLine: Record 5767;
        WhseActLine2: Record 5767;
        ShipDashbrdMgt: Codeunit "Shipment Mgmt. ELA";
        ParentLineNo: Integer;
    BEGIN
        //<<EN1.52

        WhseActLine.RESET;
        WhseActLine.SETRANGE("Activity Type", WhseActLine."Activity Type"::"Put-away", WhseActLine."Activity Type"::Movement);
        //WhseActLine.SETRANGE("Action Type",WhseActLine."Action Type"::Take);
        WhseActLine.SETRANGE("Location Code", LocationCode);
        WhseActLine.SETRANGE("Bin Code", BinCode);
        WhseActLine.SETRANGE("Item No.", ItemNo);
        WhseActLine.SETRANGE("Unit of Measure Code", ItemUOM);
        IF WhseActLine.FINDSET THEN BEGIN
            WhseActHdr.GET(WhseActLine."Activity Type", WhseActLine."No.");
            REPEAT
                //TR IF WhseActLine."Parent Line No." <> 0 THEN BEGIN
                //TR ParentLineNo := WhseActLine."Parent Line No.";
                //TR  WhseActLine2.RESET;
                //TR  WhseActLine2.SETRANGE("Activity Type",WhseActLine."Activity Type");
                //TR  WhseActLine2.SETRANGE("No.",WhseActLine."No.");
                //TR  WhseActLine2.SETRANGE("Line No.",WhseActLine."Line No.");
                //TR  IF WhseActLine2.FINDFIRST THEN
                //TR    WhseActLine2.DELETE(TRUE);

                //TR   WhseActLine2.RESET;
                //TR   WhseActLine2.SETRANGE("Activity Type",WhseActLine."Activity Type");
                //TR   WhseActLine2.SETRANGE("No.",WhseActLine."No.");
                //TR   WhseActLine2.SETRANGE("Line No.",ParentLineNo);
                //TR  IF WhseActLine2.FINDFIRST THEN
                //TR    WhseActLine2.DELETE(TRUE);
                //TR END ELSE BEGIN
                ParentLineNo := WhseActLine."Line No.";
                WhseActLine2.RESET;
                WhseActLine2.SETRANGE("Activity Type", WhseActLine."Activity Type");
                WhseActLine2.SETRANGE("No.", WhseActLine."No.");
                WhseActLine2.SETRANGE("Line No.", WhseActLine."Line No.");
                IF WhseActLine2.FINDFIRST THEN
                    WhseActLine2.DELETE(TRUE);

                WhseActLine2.RESET;
                WhseActLine2.SETRANGE("Activity Type", WhseActLine."Activity Type");
                WhseActLine2.SETRANGE("No.", WhseActLine."No.");
                //TR WhseActLine2.SETRANGE("Parent Line No.",ParentLineNo);
                IF WhseActLine2.FINDFIRST THEN
                    WhseActLine2.DELETE(TRUE);
                //TR  END;

                DeleteBinContent(LocationCode, BinCode, ItemNo, '', ItemUOM);
            UNTIL WhseActLine.NEXT = 0;
        END;
        //>>EN1.52
    END;

    PROCEDURE DeleteBinContent(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; ItemUOM: Code[10]);
    VAR
        lBinContent: Record 7302;
    BEGIN
        //<<EN1.52
        lBinContent.RESET;
        lBinContent.SETRANGE(lBinContent."Location Code", LocationCode);
        lBinContent.SETRANGE(lBinContent."Bin Code", BinCode);
        lBinContent.SETRANGE(lBinContent."Item No.", ItemNo);
        lBinContent.SETRANGE(lBinContent."Variant Code", VariantCode);
        lBinContent.SETRANGE(lBinContent."Unit of Measure Code", ItemUOM);
        IF lBinContent.FINDSET THEN
            REPEAT
                IF NOT lBinContent.Fixed THEN BEGIN
                    lBinContent.CALCFIELDS("Quantity (Base)", "Positive Adjmt. Qty. (Base)", "Put-away Quantity (Base)");
                    IF (lBinContent."Quantity (Base)" = 0) AND
                       (lBinContent."Positive Adjmt. Qty. (Base)" = 0) AND
                       (lBinContent."Put-away Quantity (Base)" = 0) // - lBinContent."Qty. Outstanding (Base)" <= 0)
                    THEN
                        lBinContent.DELETE;
                    //TR  ELSE
                    //TR ERROR(STRSUBSTNO(TEXT50015,BinCode,ItemNo));
                END;
            UNTIL lBinContent.NEXT = 0;
        //>>EN1.52
    END;


    //*****************************************************************************WH Receive***************************************************************************************
    PROCEDURE ReceiveBreadPOLine(ItemNo: Code[20]; ItemUnitOfMeasure: Code[10]; QtyToReceive: Decimal; ExpDate: Date; PONo: Code[20]; POLineNo: Integer; WMSUserID: Code[10]; VAR PutawayDocNo: Code[20]; VAR PutawayDocLineNo: Integer; VAR TransferOrderNo: Code[20]; VAR TransferOrderLineNo: Integer);
    VAR
        WhseSetup: Record 5769;
        ReceiptNo: Code[20];
    BEGIN
        //<<EN1.43
        WhseSetup.GET;
        //TR ProdLoadRegMgt.CreateItemJnlLine(WhseSetup."Item Jnl Temp. for WMS Adjust", WhseSetup."Item Jnl Batch for WMS Adjust"
        //TR   , ItemNo, ItemUnitOfMeasure, QtyToReceive, ExpDate, WhseSetup."Prod. Output Reg. Location", '', '', 0);
        //TR ProdLoadRegMgt.PostItemJnl(WhseSetup."Item Jnl Temp. for WMS Adjust", WhseSetup."Item Jnl Batch for WMS Adjust");
        //TR ProdLoadRegMgt.CreateTransferHeader(WhseSetup."Prod. Output Reg. Location",
        //TR  WhseSetup."Prod. Output Reg. Destination", '', '', TransferOrderNo);
        //TR ProdLoadRegMgt.CreateTransferLine(TransferOrderNo, ItemNo, ItemUnitOfMeasure, QtyToReceive, ExpDate, POLineNo, 0, 0, 0, PONo,
        //TR   TransferOrderLineNo);
        //TR  ProdLoadRegMgt.PostTransferOrderShipment(TransferOrderNo);
        //TR ProdLoadRegMgt.CreateWHRcptFromTransferOrder(TransferOrderNo, PONo, ReceiptNo); //<<EN1.49
        //TR  ProdLoadRegMgt.AutoReceiveWHRcpt(ReceiptNo, WMSUserID, PONo, PutawayDocNo); //EN1.49
        GetPutawayDocFromTransferOrder(TransferOrderNo, TransferOrderLineNo, PutawayDocNo, PutawayDocLineNo);
        //>>EN1.43
    END;

    PROCEDURE WriteOffStock(ItemNo: Code[20]; ItemUnitOfMeasure: Code[10]; QtyToReceive: Decimal; ExpDate: Date; LocationCode: Code[20])
    VAR
        WhseSetup: Record 5769;
        ReceiptNo: Code[20];
    BEGIN
        //<<EN1.67
        WhseSetup.GET;
        //TR  CreateItemJnlLine(WhseSetup."Item Jnl Temp. for WMS Adjust", WhseSetup."Item Jnl Batch for WMS Adjust"
        //TR   , ItemNo, ItemUnitOfMeasure, QtyToReceive, ExpDate, LocationCode, '', '', 0);
        //TR  ProdLoadRegMgt.PostItemJnl(WhseSetup."Item Jnl Temp. for WMS Adjust", WhseSetup."Item Jnl Batch for WMS Adjust");
        //>>EN1.67
    END;

    PROCEDURE PostPurchaseOrder(PONo: Code[20]; POLineNo: Integer; QtyToReceive: Decimal; ExpDate: Date);
    VAR
        PurchHdr: Record 38;
        PurchLine: Record 39;
        PurchPost: Codeunit 90;
    BEGIN
        //<<EN1.67
        PurchHdr.RESET;
        IF PurchHdr.GET(PurchHdr."Document Type"::Order, PONo) THEN BEGIN
            /* //TR PurchLine.RESET;
             PurchLine.SETFILTER("Document Type", '=%1', PurchLine."Document Type"::Order);
             PurchLine.SETFILTER("Document No.", PurchHdr."No.");
             PurchLine.SETFILTER("Line No.", '<>%1', POLineNo);
             IF PurchLine.FINDSET THEN
                 REPEAT
                     PurchLine.VALIDATE(PurchLine."Qty. to Receive", 0);
                     PurchLine.MODIFY;
                 UNTIL PurchLine.NEXT = 0;

             PurchLine.SETFILTER("Line No.", '=%1', POLineNo);
             IF PurchLine.FINDFIRST THEN BEGIN
                 PurchLine.VALIDATE("Qty. to Receive", QtyToReceive);
                 //TR PurchLine.VALIDATE("Code Date", CodeDate);             //EN1.68
                 NameValBuff.DeleteAll();
                 ENSetBufferValue('ExpDate', Format(ExpDate));
                 PurchLine.MODIFY;
             END;
                //TR */
            PurchHdr.Receive := TRUE;
            PurchHdr.Invoice := FALSE;
            PurchPost.RUN(PurchHdr);
        END;
        //>>EN1.67
    END;


    PROCEDURE PostTransferOrder(TONo: Code[20]; TOLineNo: Integer; QtyToReceive: Decimal; CodeDate: Date; ReceiveAll: Boolean);
    VAR
        TransferHeader: Record 5740;
        TransferLine: Record 5741;
        TransferPost: Codeunit 5705;
    BEGIN
        //<<EN1.66 FS
        IF TransferHeader.GET(TONo) THEN BEGIN
            //<<EN1.74
            TransferLine.RESET;
            TransferLine.SETFILTER("Document No.", TransferHeader."No.");
            TransferLine.SETRANGE(TransferLine."Derived From Line No.", 0);
            IF ReceiveAll THEN BEGIN
                IF TransferLine.FINDSET THEN
                    REPEAT
                        TransferLine.VALIDATE("Qty. to Receive", TransferLine.Quantity - TransferLine."Quantity Received");
                        //TR   TransferLine.VALIDATE("Expiration Date", TODAY);  //EN1.68
                        TransferLine.MODIFY;
                    UNTIL TransferLine.NEXT = 0;
                //>>EN1.74
            END ELSE BEGIN
                TransferLine.SETFILTER("Line No.", '<>%1', TOLineNo);
                TransferLine.SETRANGE(TransferLine."Derived From Line No.", 0);
                IF TransferLine.FINDSET THEN
                    REPEAT
                        TransferLine.VALIDATE(TransferLine."Qty. to Receive", 0);
                        TransferLine.MODIFY;
                    UNTIL TransferLine.NEXT = 0;

                TransferLine.SETFILTER("Line No.", '=%1', TOLineNo);
                IF TransferLine.FINDFIRST THEN BEGIN
                    TransferLine.VALIDATE("Qty. to Receive", QtyToReceive);
                    //TR TransferLine.VALIDATE("Expiration Date", CodeDate);  //EN1.68
                    TransferLine.MODIFY;
                END;
            END;
            TransferPost.RUN(TransferHeader);
        END;
        //>>EN1.66 FS
    END;

    PROCEDURE CreateItemJnlLine(ItemJnlTmpName: Code[10]; ItemJnlBatchName: Code[20]; ItemNo: Code[20]; ItemUOM: Code[10]; Qty: Decimal; ExpDate: Date; LocCode: Code[10]; ExtDocNo: Code[20]; LoadID: Code[20]; LoadLineNo: Integer);
    VAR
        ItemJnlLine: Record 83;
        ItemLedgEntry: Record 32;
        WMSSetup: Record 5769;
        ItemJnlBatch: Record 233;
        //TR lProdOutputReg: Record 50012;
        Item: Record 27;
        NoSeriesMgmt: Codeunit 396;
        NextLineNo: Integer;
        DocNo: Code[20];
        BatchName: Code[10];
        Location: Record 14;
        WMSManagement: Codeunit 7302;
        "Transfer-To Bin Code": Code[10];
    BEGIN
        //<<EN1.18
        WMSSetup.GET;
        NextLineNo := 10000;
        IF NOT ItemJnlBatch.GET(ItemJnlTmpName, ItemJnlBatchName) THEN BEGIN
            ItemJnlBatch.INIT;
            ItemJnlBatch."Journal Template Name" := ItemJnlTmpName;
            ItemJnlBatch.Name := ItemJnlBatchName;
            //ItemJnlBatch.Description := 'Prod. Output Reg. Jnl';
            ItemJnlBatch."Reason Code" := '02';
            ItemJnlBatch."Template Type" := ItemJnlBatch."Template Type"::Item;
            //TR ItemJnlBatch."Suppress Messages" := TRUE; //EN1.16
            ItemJnlBatch.INSERT;
        END ELSE BEGIN
            ItemJnlLine.RESET;
            ItemJnlLine.SETRANGE("Journal Template Name", ItemJnlTmpName);
            ItemJnlLine.SETRANGE("Journal Batch Name", ItemJnlBatchName);
            IF ItemJnlLine.FINDLAST THEN
                NextLineNo := ItemJnlLine."Line No." + 10000
        END;

        //TR DocNo := NoSeriesMgmt.GetNextNo(WMSSetup."WMS Item Jnl. No.", 0D, TRUE);   // create new no series
        DocNo := INCSTR(DocNo);
        //<<EN1.70 FS
        Location.RESET;
        IF (LocCode <> '') AND (ItemNo <> '') THEN BEGIN
            Location.GET(LocCode);
            //TR IF Location."Bin Mandatory" AND NOT Location."Directed Put-away and Pick" THEN

            //TR WMSManagement.GetDefaultBin(ItemNo, '', Location.Code, "Transfer-To Bin Code", ExpDate);       //EN1.06
        END;
        //>>EN1.70 FS

        ItemJnlLine.INIT;
        ItemJnlLine."Journal Template Name" := ItemJnlTmpName;
        ItemJnlLine."Journal Batch Name" := ItemJnlBatchName;
        ItemJnlLine."Reason Code" := ItemJnlBatch."Reason Code";
        ItemJnlLine."Line No." := NextLineNo;
        IF ItemJnlLine.INSERT(TRUE) THEN BEGIN
            ItemJnlLine.VALIDATE("Posting Date", TODAY);
            ItemJnlLine."Document No." := DocNo;
            ItemJnlLine.VALIDATE("Item No.", ItemNo);
            ItemJnlLine.VALIDATE("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
            ItemJnlLine.VALIDATE("Location Code", LocCode);
            ItemJnlLine.VALIDATE("Bin Code", "Transfer-To Bin Code"); //FS
            ItemJnlLine.VALIDATE(Quantity, Qty);
            ItemJnlLine.VALIDATE("Unit of Measure Code", ItemUOM);
            //TR  ItemJnlLine."Prod. Output Load ID" := LoadID;
            ItemJnlLine."External Document No." := ExtDocNo;
            //TR ItemJnlLine."Prod. Order No." := LoadID;
            //TR ItemJnlLine."Prod. Order Line No." := LoadLineNo;
            //TR ItemJnlLine."Code Date" := ExpDate;
            ItemJnlLine.MODIFY;
        END;
        //>>EN.18
    END;

    PROCEDURE PostReceipt(ItemNo: Code[20]; ItemUnitOfMeasure: Code[10]; QtyToReceive: Decimal; ExpDate: Date; PONo: Code[20]; POLineNo: Integer; WMSUserID: Code[10]; VAR PutawayDocNo: Code[20]; VAR PutawayDocLineNo: Integer; PrintPalletLabel: Boolean);
    VAR
        WhseReceiptHdr: Record 7316;
        WhseReceiptLine: Record 7317;
        CrossDockOpp: Record 5768;
        CrossDockMgt: Codeunit 5780;
    BEGIN
        //EN1.67

        // handle by PO
        // if receipt not exists, then create receipt
        // otherwise use receipt
        WhseReceiptHdr.RESET;
        WhseReceiptHdr.SETRANGE("Source Doc. No. ELA", PONo);
        IF WhseReceiptHdr.FINDFIRST THEN BEGIN
            WhseReceiptLine.RESET;
            WhseReceiptLine.SETRANGE("No.", WhseReceiptHdr."No.");
            WhseReceiptLine.SETRANGE("Source Line No.", POLineNo); //EN1.71 FS
            WhseReceiptLine.SETRANGE("Item No.", ItemNo);
            IF WhseReceiptLine.FINDFIRST THEN BEGIN
                IF QtyToReceive > WhseReceiptLine."Qty. Outstanding" THEN;
                //TR ERROR(TEXT50007);

                WhseReceiptLine."Vendor Shipment No. ELA" := PONo; //<<EN1.49

                //<<EN1.33
                //TR WhseReceiptLine."Assigned User ID" := WMSUserID;
                WhseReceiptLine."Received By ELA" := WMSUserID;
                //TR WhseReceiptLine."Received Date" := TODAY;
                //TR WhseReceiptLine."Received Time" := TIME;
                //>>EN1.33

                //TR  WhseReceiptLine.VALIDATE("Expiration Date", ExpDate);
                WhseReceiptLine.VALIDATE("Qty. to Receive", QtyToReceive);
                WhseReceiptLine.MODIFY;

                //PostWHReceipt(WhseReceiptHdr."No.", PutawayDocNo);
                PostWHReceipt(WhseReceiptHdr."No.");
                //<<EN1.85
                //IF PrintPalletLabel THEN
                //   PrintReceivedPalletLabel(WhseReceiptLine."No.",WhseReceiptLine."Line No.");

                //>>EN1.85
            END;
        END;
        //>>EN1.67
    END;



    PROCEDURE UpdatePOQuantity(ItemNo: Code[20]; ItemUnitOfMeasure: Code[10]; QtyToReceive: Decimal; ExpDate: Date; PONo: Code[20]; POLineNo: Integer; WMSUserID: Code[10]; VAR PutawayDocNo: Code[20]; VAR PutawayDocLineNo: Integer);
    VAR
        WhseReceiptHdr: Record 7316;
        WhseReceiptLine: Record 7317;
        PurchOrderHdr: Record 38;
        PurchOrderLine: Record 39;
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        GetSourceDoc: Codeunit 5751;
        Loc: Record 14;
        CrossDockOpp: Record 5768;
        WhseCommentLine: Record 5770;
    BEGIN
        //<<EN1.67
        WhseReceiptHdr.RESET;
        WhseReceiptHdr.SETRANGE("Source Doc. No. ELA", PONo);
        IF WhseReceiptHdr.FINDFIRST THEN BEGIN

            WhseReceiptLine.RESET;
            WhseReceiptLine.SETRANGE("No.", WhseReceiptHdr."No.");
            IF WhseReceiptLine.FIND('-') THEN
                WhseReceiptLine.DELETEALL;

            CrossDockOpp.SETRANGE("Source Template Name", '');
            CrossDockOpp.SETRANGE("Source Name/No.", WhseReceiptHdr."No.");
            CrossDockOpp.DELETEALL;

            WhseCommentLine.SETRANGE("Table Name", WhseCommentLine."Table Name"::"Whse. Receipt");
            WhseCommentLine.SETRANGE(Type, WhseCommentLine.Type::" ");
            WhseCommentLine.SETRANGE("No.", WhseReceiptHdr."No.");
            WhseCommentLine.DELETEALL;

            WhseReceiptHdr.DELETE;
        END;

        PurchOrderHdr.RESET;
        IF PurchOrderHdr.GET(PurchOrderHdr."Document Type"::Order, PONo) THEN BEGIN
            PurchOrderHdr.VALIDATE(Status, PurchOrderHdr.Status::Open);
            PurchOrderHdr.MODIFY;
        END;


        PurchOrderLine.RESET;
        PurchOrderLine.SETRANGE("Document No.", PurchOrderHdr."No.");
        PurchOrderLine.SETRANGE("Line No.", POLineNo);
        IF PurchOrderLine.FINDFIRST THEN BEGIN
            PurchOrderLine.VALIDATE(Quantity, PurchOrderLine.Quantity + (QtyToReceive - PurchOrderLine."Outstanding Quantity"));
            PurchOrderLine.MODIFY;
        END;
        ReleasePurchDoc.PerformManualRelease(PurchOrderHdr);
        //>>EN1.67
    END;

    PROCEDURE CreatePOReceipt(PONo: Code[20]): Code[20]
    VAR
        PurchOrderHdr: Record 38;
        GetSourceDocInbound: Codeunit 5751;
        RelPurchDoc: Codeunit "Release Purchase Document";
        POReceiptNo: Code[20];

    BEGIN
        //EN1.83 + 1.86
        IF PurchOrderHdr.GET(PurchOrderHdr."Document Type"::Order, PONo) THEN BEGIN
            IF PurchOrderHdr.Status <> PurchOrderHdr.Status::Released THEN
                RelPurchDoc.RUN(PurchOrderHdr);
            //GetSourceDocInbound.CreateFromPurchOrder(PurchOrderHdr);
            POReceiptNo := GetPOReceipt(PurchOrderHdr."No.");
            if (POReceiptNo = '') then
                exit(CreateReceiptFromPurchaseOrder(PurchOrderHdr))
            else
                exit(POReceiptNo);
            //exit(GetPOReceipt(PurchOrderHdr."No."));
        END
        //EN1.83 + 1.86
    END;

    PROCEDURE CreateTOReceipt(TONo: Code[20]): Code[20]
    VAR
        TransferOrderHdr: Record "Transfer Header";
        GetSourceDocInbound: Codeunit 5751;
        RelTransDoc: Codeunit "Release Transfer Document";
        TOReceiptNo: Code[20];

    BEGIN
        //EN1.83 + 1.86
        IF TransferOrderHdr.GET(TONo) THEN BEGIN
            IF TransferOrderHdr.Status <> TransferOrderHdr.Status::Released THEN
                RelTransDoc.RUN(TransferOrderHdr);
            //GetSourceDocInbound.CreateFromPurchOrder(PurchOrderHdr);
            TOReceiptNo := GetTOReceipt(TransferOrderHdr."No.");
            if (TOReceiptNo = '') then
                exit(CreateReceiptFromTransferOrder(TransferOrderHdr))
            else
                exit(TOReceiptNo);
            //exit(GetPOReceipt(PurchOrderHdr."No."));
        END
        //EN1.83 + 1.86
    END;

    procedure CreateReceiptFromPurchaseOrder(PurchHeader: Record "Purchase Header"): Code[20]
    var
        WhseRqst: Record "Warehouse Request";
        GetSourceDocuments: Report "Get Source Documents";
        WhseRcptHeader: Record "Warehouse Receipt Header";
    begin
        WITH PurchHeader DO BEGIN
            TESTFIELD(Status, Status::Released);
            WhseRqst.SETRANGE(Type, WhseRqst.Type::Inbound);
            WhseRqst.SETRANGE("Source Type", DATABASE::"Purchase Line");
            WhseRqst.SETRANGE("Source Subtype", "Document Type");
            WhseRqst.SETRANGE("Source No.", "No.");
            WhseRqst.SETRANGE("Document Status", WhseRqst."Document Status"::Released);

            IF WhseRqst.FIND('-') THEN BEGIN
                GetSourceDocuments.UseRequestPage(FALSE);
                GetSourceDocuments.SETTABLEVIEW(WhseRqst);
                //<<EN1.01
                IF NOT GUIALLOWED THEN
                    GetSourceDocuments.SetHideDialog(TRUE);
                //>>EN1.01

                GetSourceDocuments.RUNMODAL;
                GetSourceDocuments.GetLastReceiptHeader(WhseRcptHeader);
                exit(WhseRcptHeader."No.");
            END;
        END;
    end;

    procedure CreateReceiptFromTransferOrder(TransHeader: Record "Transfer Header"): Code[20]
    var
        WhseRqst: Record "Warehouse Request";
        GetSourceDocuments: Report "Get Source Documents";
        WhseRcptHeader: Record "Warehouse Receipt Header";
    begin

        WITH TransHeader DO BEGIN
            TESTFIELD(Status, Status::Released);
            WhseRqst.SETRANGE(Type, WhseRqst.Type::Inbound);
            WhseRqst.SETRANGE("Source Type", DATABASE::"Transfer Line");
            WhseRqst.SETRANGE("Source Subtype", 1);
            WhseRqst.SETRANGE("Source No.", "No.");
            WhseRqst.SETRANGE("Document Status", WhseRqst."Document Status"::Released);

            IF WhseRqst.FIND('-') THEN BEGIN
                GetSourceDocuments.UseRequestPage(FALSE);
                GetSourceDocuments.SETTABLEVIEW(WhseRqst);
                //<<EN1.01
                IF NOT GUIALLOWED THEN
                    GetSourceDocuments.SetHideDialog(TRUE);
                //>>EN1.01
                GetSourceDocuments.RUNMODAL;
                GetSourceDocuments.GetLastReceiptHeader(WhseRcptHeader);
                exit(WhseRcptHeader."No.");
            END;
        END;
    end;

    PROCEDURE GetPOLocation(PONo: Code[20]; ICPartnerName: Text[30]): Code[20];
    VAR
        PurchHdr: Record 38;
    BEGIN
        //<<EN1.87
        //IC Partner code is not implemented
        IF PurchHdr.GET(PurchHdr."Document Type"::Order, PONo) THEN
            EXIT(PurchHdr."Location Code");
        //>>EN1.87
    END;

    PROCEDURE UpdateLocationOnPO(PONo: Code[20]; NewLocationCode: Code[10]; ICPartnerName: Text[30]);
    VAR
        PurchHdr: Record 38;
        PurchLine: Record 39;
        RelPurchDoc: Codeunit 415;
    BEGIN
        //<<EN1.87
        //IC Partner code is not implemented
        IF PurchHdr.GET(PurchHdr."Document Type"::Order, PONo) THEN BEGIN
            IF PurchHdr.Status = PurchHdr.Status::Released THEN
                RelPurchDoc.Reopen(PurchHdr);

            PurchHdr.VALIDATE("Location Code", NewLocationCode);
            PurchHdr.MODIFY;

            PurchLine.RESET;
            PurchLine.SETRANGE(PurchLine."Document No.", PONo);
            PurchLine.SETRANGE(Type, PurchLine.Type::Item);
            IF PurchLine.FINDSET THEN
                REPEAT
                    IF PurchLine."Outstanding Quantity" <> 0 THEN BEGIN
                        PurchLine.VALIDATE("Location Code", NewLocationCode);
                        PurchLine.MODIFY(TRUE);
                    END;
                UNTIL PurchLine.NEXT = 0;
        END;
        //>>EN1.87
    END;

    PROCEDURE CreateInvPutwayIfNotExist(DocNo: Code[20]; IsPO: Boolean): Boolean;
    VAR
        WhseActHeader: Record 5766;
        PurchaseOrder: Record 38;
        TransferOrder: Record 5740;
    BEGIN
        //EN1.84
        WhseActHeader.RESET;
        WhseActHeader.SETFILTER(WhseActHeader."Source No.", DocNo);
        WhseActHeader.SETFILTER(WhseActHeader.Type, '=%1', WhseActHeader.Type::"Invt. Put-away");
        IF IsPO THEN
            WhseActHeader.SETFILTER(WhseActHeader."Source Document", '=%1', WhseActHeader."Source Document"::"Purchase Order")
        ELSE
            WhseActHeader.SETFILTER(WhseActHeader."Source Document", '=%1', WhseActHeader."Source Document"::"Inbound Transfer");
        IF WhseActHeader.FINDFIRST THEN
            EXIT(TRUE)
        ELSE BEGIN
            IF IsPO THEN BEGIN
                IF PurchaseOrder.GET(PurchaseOrder."Document Type"::Order, DocNo) THEN BEGIN
                    PurchaseOrder.CreateInvtPutAwayPick;
                    EXIT(TRUE);
                END;
            END ELSE BEGIN
                IF TransferOrder.GET(DocNo) THEN BEGIN
                    TransferOrder.CreateInvtPutAwayPick;
                    EXIT(TRUE);
                END;
            END;
        END;
        //EN1.84
    END;

    PROCEDURE UpdateInvPutawayLine(DocNo: Code[20]; LineNo: Integer; ScannedBin: Code[20]; Qty: Decimal; ReceiveAll: Boolean);
    VAR
        WhseActLine: Record 5767;
    BEGIN
        //<<EN1.95
        WhseActLine.RESET;
        WhseActLine.SETRANGE("Source No.", DocNo);
        IF NOT ReceiveAll THEN
            WhseActLine.SETRANGE("Line No.", LineNo);
        WhseActLine.SETFILTER(WhseActLine."Activity Type", '=%1', WhseActLine."Activity Type"::"Invt. Put-away");
        IF WhseActLine.FINDSET THEN
            REPEAT
                IF NOT ReceiveAll THEN BEGIN
                    WhseActLine.VALIDATE("Bin Code", ScannedBin);
                    WhseActLine.VALIDATE("Qty. to Handle", Qty);
                END ELSE
                    WhseActLine.VALIDATE("Qty. to Handle", WhseActLine."Qty. Outstanding");
                WhseActLine.MODIFY;
            UNTIL WhseActLine.NEXT = 0;
        //>>EN1.95
    END;

    PROCEDURE PostWhseActLine(DocNo: Code[20]; LineNo: Integer; ReceiveAll: Boolean);
    VAR
        Selection: Integer;
        WhseActLinePost: Codeunit 7324;
        WhseActLine: Record 5767;
        Text000: TextConst ENU = '&Receive,Receive &and Invoice;ESM=&Recibir,Recibir &y facturar;FRC=&Recevoir,Recevoir &et facturer;ENC=&Receive,Receive &and Invoice';
    BEGIN
        //<<EN1.95
        WhseActLine.RESET;
        WhseActLine.SETRANGE("Source No.", DocNo);
        IF NOT ReceiveAll THEN
            WhseActLine.SETRANGE("Line No.", LineNo);
        WhseActLine.SETFILTER(WhseActLine."Activity Type", '=%1', WhseActLine."Activity Type"::"Invt. Put-away");
        IF WhseActLine.FINDFIRST THEN BEGIN
            WhseActLinePost.SetInvoiceSourceDoc(FALSE);
            WhseActLinePost.RUN(WhseActLine);
        END;
        //>>EN1.95
    END;

    PROCEDURE ReceiveFullReceipt(ReceiptNo: Code[20]);
    VAR
        WhseRcptLine: Record 7317;
        PutawayDocNo: Code[20];
    BEGIN
        //<<EN1.50
        WhseRcptLine.RESET;
        WhseRcptLine.SETRANGE("No.", ReceiptNo);
        IF WhseRcptLine.FINDFIRST THEN
            WhseRcptLine.AutofillQtyToReceive(WhseRcptLine);

        //PostWHReceipt(ReceiptNo, PutawayDocNo);
        PostWHReceipt(ReceiptNo);
        //>>EN1.50
    END;

    PROCEDURE UpdateICPurchaseOrder(PONo: Code[20]; POLineNo: Integer; QtyToReceive: Decimal; ICPartnerName: Text[250]);
    VAR
        PurchHdr: Record 38;
        PurchLine: Record 39;
        LTXT001: TextConst ENU = 'PO No. %1 Line No. %2 Item No. %3 has already received qty %4';
        ICPartner: Record 413;
        IsFullyReceived: Boolean;
    BEGIN
        //<<EN1.43
        ICPartner.RESET;
        ICPartner.SETRANGE("Inbox Details", ICPartnerName);
        IF ICPartner.FINDFIRST THEN BEGIN
            PurchHdr.RESET;
            PurchHdr.CHANGECOMPANY(ICPartner."Inbox Details");
            PurchHdr.SETRANGE("Document Type", PurchHdr."Document Type"::Order);
            PurchHdr.SETRANGE("No.", PONo);
            IF PurchHdr.FINDFIRST THEN BEGIN
                CLEAR(PurchLine);
                PurchLine.CHANGECOMPANY(ICPartner."Inbox Details");
                IF PurchLine.GET(PurchLine."Document Type"::Order, PurchHdr."No.", POLineNo) THEN BEGIN
                    //TR  IF PurchLine."Handheld Recvd. Qty" + QtyToReceive < PurchLine."Handheld Recvd. Qty" THEN
                    //TR  ERROR(STRSUBSTNO(LTXT001, PONo, POLineNo, PurchLine."No.", PurchLine."Handheld Recvd. Qty"));

                    //TR  PurchLine."Handheld Recvd. Qty" := PurchLine."Handheld Recvd. Qty" + QtyToReceive;
                    PurchLine.MODIFY;
                END;

                IsFullyReceived := TRUE;
                PurchLine.RESET;
                PurchLine.CHANGECOMPANY(ICPartner."Inbox Details");
                PurchLine.SETRANGE("Document Type", PurchHdr."Document Type"::Order);
                PurchLine.SETRANGE("Document No.", PONo);
                IF PurchLine.FINDSET THEN
                    REPEAT
                    //TR IF PurchLine."Handheld Recvd. Qty" <> PurchLine.Quantity THEN
                    //TR IsFullyReceived := FALSE;
                    UNTIL (PurchLine.NEXT = 0);// or (not isfullyreceived);

                //TR IF IsFullyReceived THEN
                //TR    PurchHdr."PO Receiving Status" := PurchHdr."PO Receiving Status"::Full
                //TR  ELSE
                //TR     PurchHdr."PO Receiving Status" := PurchHdr."PO Receiving Status"::Partial;

                PurchHdr.MODIFY;
            END;
        END ELSE
            ERROR('%1 not found', ICPartnerName);
        //>>EN1.43
    END;

    PROCEDURE UpdatePurchaseOrder(PONo: Code[20]; POLineNo: Integer; QtyToReceive: Decimal);
    VAR
        PurchHdr: Record 38;
        PurchLine: Record 39;
        LTXT001: TextConst ENU = 'PO No. %1 Line No. %2 Item No. %3 has already received qty %4';
        ICPartner: Record 413;
        IsFullyReceived: Boolean;
    BEGIN
        //<<EN1.67
        PurchHdr.RESET;
        PurchHdr.SETRANGE("Document Type", PurchHdr."Document Type"::Order);
        PurchHdr.SETRANGE("No.", PONo);
        IF PurchHdr.FINDFIRST THEN BEGIN
            CLEAR(PurchLine);
            IF PurchLine.GET(PurchLine."Document Type"::Order, PurchHdr."No.", POLineNo) THEN BEGIN
                //TR IF PurchLine."Handheld Recvd. Qty" + QtyToReceive < PurchLine."Handheld Recvd. Qty" THEN
                //TR   ERROR(STRSUBSTNO(LTXT001, PONo, POLineNo, PurchLine."No.", PurchLine."Handheld Recvd. Qty"));

                //TR  PurchLine."Handheld Recvd. Qty" := PurchLine."Handheld Recvd. Qty" + QtyToReceive;
                PurchLine.MODIFY;
            END;

            IsFullyReceived := TRUE;
            PurchLine.RESET;
            PurchLine.SETRANGE("Document Type", PurchHdr."Document Type"::Order);
            PurchLine.SETRANGE("Document No.", PONo);
            IF PurchLine.FINDSET THEN
                REPEAT
                //TR   IF PurchLine."Handheld Recvd. Qty" <> PurchLine.Quantity THEN
                //TR     IsFullyReceived := FALSE;
                UNTIL (PurchLine.NEXT = 0);// or (not isfullyreceived);

            //TR  IF IsFullyReceived THEN
            //TR     PurchHdr."PO Receiving Status" := PurchHdr."PO Receiving Status"::Full
            //TR  ELSE
            //TR    PurchHdr."PO Receiving Status" := PurchHdr."PO Receiving Status"::Partial;

            PurchHdr.MODIFY;
        END;
        //>>EN1.67
    END;

    PROCEDURE ClearEmptyReceiptByLoadNo(LoadNo: Code[20]);
    VAR
        WhseRcptLine: Record 7317;
        WhseRcptHdr: Record 7316;
        WhseRcptHdr2: Record 7316;
    BEGIN
        //<<EN1.55v
        WhseRcptHdr.RESET;
        //TR WhseRcptHdr.SETRANGE("Souce Doc. No.", LoadNo);
        IF WhseRcptHdr.FINDSET THEN
            REPEAT
                WhseRcptLine.RESET;
                WhseRcptLine.SETRANGE("No.", WhseRcptHdr."No.");
                IF NOT WhseRcptLine.FINDFIRST THEN BEGIN
                    WhseRcptHdr2.GET(WhseRcptHdr."No.");
                    WhseRcptHdr2.DELETE(TRUE);
                END;
            UNTIL WhseRcptHdr.NEXT = 0;
        //>>EN1.55
    END;

    PROCEDURE ClearEmptyReceipt(ReceiptNo: Code[20]);
    VAR
        WhseRcptHdr: Record 7316;
        WhseRpctLine: Record 7317;
    BEGIN
        //<<EN1.55
        WhseRpctLine.RESET;
        WhseRpctLine.SETRANGE("No.", ReceiptNo);
        IF NOT WhseRpctLine.FINDFIRST THEN BEGIN
            IF WhseRcptHdr.GET(ReceiptNo) THEN
                WhseRcptHdr.DELETE(TRUE);
        END;
        //>>EN1.55
    END;

    PROCEDURE GetPOReceipt(PONum: Code[20]): Code[20]
    var
        WhseRcptHdr: Record 7316;
        WhseRpctLine: Record 7317;
    begin
        WhseRpctLine.RESET;
        WhseRpctLine.SETRANGE("Source No.", PONum);
        IF WhseRpctLine.FINDFIRST THEN BEGIN
            IF WhseRcptHdr.GET(WhseRpctLine."No.") THEN
                Exit(WhseRcptHdr."No.");
        END;
    end;

    PROCEDURE GetTOReceipt(TONum: Code[20]): Code[20]
    var
        WhseRcptHdr: Record 7316;
        WhseRpctLine: Record 7317;
    begin
        WhseRpctLine.RESET;
        WhseRpctLine.SETRANGE("Source No.", TONum);
        IF WhseRpctLine.FINDFIRST THEN BEGIN
            IF WhseRcptHdr.GET(WhseRpctLine."No.") THEN
                Exit(WhseRcptHdr."No.");
        END;
    end;

    //**************************************************************************StockCountMethods**************************************************************

    PROCEDURE BinScannedForStockCount(LocCode: Code[10]; BinCode: Code[10]; WMSUserID: Code[20]; ActionType: Option " ",StockCount,Adjustment,Movement): Boolean;
    VAR
        //TR StkCountTrack: Record 50088;
        StkCountDate: Date;
    BEGIN
        //TR IF StkCountTrack.IsStockCountStarted(LocCode) THEN BEGIN
        //TR StkCountDate := StkCountTrack.GetOpenStockCountDate(LocCode);
        //TR StkCountTrack.UpdateStockCountBin(LocCode,BinCode,StkCountDate,WMSUserID,ActionType);
        //TR  END;
    END;

    //**************************************************************************Utils**************************************************************


    PROCEDURE GetItemDefaultBin(LocationCode: Code[10]; ItemNo: Code[20]): Code[20];
    VAR
        BinContent: Record 7302;
    BEGIN
        //<<EN1.11
        BinContent.RESET;
        BinContent.SETRANGE("Location Code", LocationCode);
        BinContent.SETRANGE("Item No.", ItemNo);
        BinContent.SETRANGE(Fixed, TRUE);
        IF BinContent.FINDFIRST THEN
            EXIT(BinContent."Bin Code")
        ELSE BEGIN
            BinContent.RESET;
            BinContent.SETRANGE("Location Code", LocationCode);
            BinContent.SETRANGE("Item No.", ItemNo);
            IF BinContent.FINDFIRST THEN
                EXIT(BinContent."Bin Code");
        END;
        //>>EN1.11
    END;

    PROCEDURE GetBinInfo(LocCode: Code[10]; BinCOde: Code[20]; VAR Zone: Code[10]; VAR SpEquip: Code[10]; VAR BinTypeCode: Code[10]; VAR Blocked: Integer; VAR IsEmpty: Boolean; VAR PalletCapUnit: Integer; VAR AllowMultiple: Boolean; VAR EnforceCodeDate: Boolean);
    VAR
        Bin: Record 7354;
    BEGIN
        //<<EN1.11
        IF Bin.GET(LocCode, BinCOde) THEN BEGIN
            Zone := Bin."Zone Code";
            SpEquip := Bin."Special Equipment Code";
            BinTypeCode := Bin."Bin Type Code";
            Blocked := Bin."Block Movement";
            IsEmpty := Bin.Empty;
            //TR PalletCapUnit := Bin."Pallet Capacity Unit";
            //<<EN1.57
            //TR AllowMultiple := Bin."Allow Multiple Items";
            //TR EnforceCodeDate := Bin."Enforce Code Date";
            //>>EN1.57
        END;
        //>>EN1.11
    END;



    PROCEDURE AddSalesLineComment(DocumentNo: Code[20]; DocumentLineNo: Integer; TableName: Option "Whse. Activity Header","Whse. Receipt","Whse. Shipment","Internal Put-away","Internal Pick","Rgstrd. Whse. Activity Header","Posted Whse. Receipt","Posted Whse. Shipment","Posted Invt. Put-Away","Posted Invt. Pick",,,"Staged Pick","Bill Of Lading";
        Type: Option " ","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick"; UserID: Code[20]; Message: Text[250]);
    VAR
        SaleCommentLine: Record 44;
        NextCommentLineNo: Integer;
    BEGIN
        //<EN1.78
        SaleCommentLine.RESET;
        SaleCommentLine.SETRANGE("Document Type", SaleCommentLine."Document Type"::Order);

        SaleCommentLine.SETRANGE("No.", DocumentNo);
        IF SaleCommentLine.FINDLAST THEN
            NextCommentLineNo := SaleCommentLine."Line No." + 10000
        ELSE
            NextCommentLineNo := 10000;

        SaleCommentLine.INIT;
        //SalesCommentLine."Table Name" := TableName;
        SaleCommentLine."Document Type" := SaleCommentLine."Document Type"::Order;
        SaleCommentLine."No." := DocumentNo;
        SaleCommentLine."Line No." := NextCommentLineNo;
        SaleCommentLine.Date := TODAY;
        //TR SaleCommentLine.Comment :=
        //TR STRSUBSTNO(TEXT50013,FORMAT(TIME),UserID,Message);
        IF SaleCommentLine.INSERT THEN;
        //>>EN1.78
    END;

    PROCEDURE ClearEmptyBinContents(LocCode: Code[10]; ZoneCode: Code[10]; BinCode: Code[10]);
    BEGIN
        //<<EN1.41
        //TR ENSysUtils.ClearEmptyBinContents(LocCode,ZoneCode,BinCode);
        //>>EN1.41
    END;


    //******************************************************************************************Local Functions*****************************************************************
    LOCAL PROCEDURE GetWMSItemJnlLine(JnlTempName: Code[10]; JnlBatchName: Code[10]; LocationCode: Code[10]; VAR WhseJnlLine: Record 7311);
    VAR
        WhseJnlBatch: Record 7310;
        NoSeriesMgt: Codeunit 396;
        NextLineNo: Integer;
        NextDocNo: Code[20];
    BEGIN
        WhseJnlBatch.GET(JnlTempName, JnlBatchName, LocationCode);
        IF WhseJnlBatch."No. Series" <> '' THEN BEGIN
            WhseJnlLine.SETRANGE("Journal Template Name", JnlTempName);
            WhseJnlLine.SETRANGE("Journal Batch Name", JnlBatchName);
            WhseJnlLine.SETRANGE("Location Code", LocationCode);
            //<<EN1.58
            IF NOT WhseJnlLine.FIND('-') THEN BEGIN
                IF WhseJnlBatch."No. Series" <> '' THEN
                    NextDocNo := NoSeriesMgt.GetNextNo(WhseJnlBatch."No. Series", TODAY, FALSE)
                ELSE
                    NextDocNo := JnlBatchName;
            END ELSE
                NextDocNo := JnlBatchName;

        END ELSE
            NextDocNo := JnlBatchName;
        //>>EN1.58

        WhseJnlLine.RESET;
        WhseJnlLine.SETRANGE("Journal Template Name", JnlTempName);
        WhseJnlLine.SETRANGE("Journal Batch Name", JnlBatchName);
        IF WhseJnlLine.FINDLAST THEN
            NextLineNo := WhseJnlLine."Line No." + 10000
        ELSE
            NextLineNo := 10000;

        WhseJnlLine.INIT;
        WhseJnlLine."Journal Template Name" := JnlTempName;
        WhseJnlLine."Journal Batch Name" := JnlBatchName;
        WhseJnlLine."Location Code" := LocationCode;
        WhseJnlLine."Line No." := NextLineNo;
        WhseJnlLine."Whse. Document No." := NextDocNo;
    END;



    PROCEDURE SavePurchaseOrderAsPDF(PONo: Code[20]);
    VAR
        PurchHdr: Record 38;
        PurchaseSetup: Record 312;
        PONum: Code[20];
        FileName: Text[250];
        POReport: Report 10122;
    //TR DeliveryNote: Report 50091;
    BEGIN
        //<<EN1.34
        IF PurchHdr.GET(PurchHdr."Document Type"::Order, PONo) THEN BEGIN
            PurchaseSetup.GET;
            CLEAR(POReport);
            //TR POReport.SetValues(PurchHdr."Document Type",PurchHdr."No.");
            //TR POReport.USEREQUESTFORM(FALSE);
            //TR FileName := STRSUBSTNO('%1PO_%2.pdf',PurchaseSetup."Purchase Order Exp. Path",FORMAT(PurchHdr."No."));
            //TR IF EXISTS(FileName) THEN
            //TR  ERASE(FileName);

            //TR POReport.SAVEASPDF(FileName);
            AddFileLinkOnPurchaseOrder(PurchHdr."No.", FileName, 'Purchase Order');
        END;

        //>>EN1.35
    END;

    LOCAL PROCEDURE AddFileLinkOnPurchaseOrder(OrderNo: Code[20]; FileName: Text[255]; Description: Text[30]);
    VAR
        purchHdr: Record 38;
        RecLink: Record 2000000068;
    BEGIN
        //EN1.34
        IF purchHdr.GET(purchHdr."Document Type"::Order, OrderNo) THEN BEGIN
            RecLink.RESET;
            RecLink.SETRANGE(Type, RecLink.Type::Link);
            RecLink.SETRANGE(Company, COMPANYNAME);
            RecLink.SETRANGE(URL1, FileName);
            RecLink.SETRANGE(Description, Description);
            IF NOT RecLink.FINDFIRST THEN
                purchHdr.ADDLINK(FileName, Description);
        END;
    END;


    LOCAL PROCEDURE AddFileLinkOnPurchaseReceipt(DocNo: Code[20]; FileName: Text[255]; Description: Text[30]);
    VAR
        PurchRecHdr: Record 120;
        RecLink: Record 2000000068;
    BEGIN
        //EN1.37
        IF PurchRecHdr.GET(DocNo) THEN BEGIN
            RecLink.RESET;
            RecLink.SETRANGE(Type, RecLink.Type::Link);
            RecLink.SETRANGE(Company, COMPANYNAME);
            RecLink.SETRANGE(URL1, FileName);
            RecLink.SETRANGE(Description, Description);
            IF NOT RecLink.FINDFIRST THEN
                PurchRecHdr.ADDLINK(FileName, Description);
        END;
    END;


    LOCAL PROCEDURE AddFileLinkOnPurchaseInvoice(DocNo: Code[20]; FileName: Text[255]; Description: Text[30]);
    VAR
        PurchInvHdr: Record 122;
        RecLink: Record 2000000068;
    BEGIN
        //EN1.37
        IF PurchInvHdr.GET(DocNo) THEN BEGIN
            RecLink.RESET;
            RecLink.SETRANGE(Type, RecLink.Type::Link);
            RecLink.SETRANGE(Company, COMPANYNAME);
            RecLink.SETRANGE(URL1, FileName);
            RecLink.SETRANGE(Description, Description);
            IF NOT RecLink.FINDFIRST THEN
                PurchInvHdr.ADDLINK(FileName, Description);
        END;
    END;

    procedure UpdateTakePlaceLine(pintFieldNo: Integer; WhseActLine: record "Warehouse Activity Line")
    var
        lrecWhseActivityLine: Record "Warehouse Activity Line";
        TakeLineNo: Integer;
        PlaceLineNo: Integer;
        lintUpToLineNo: Integer;
        lintPlaceLineCount: Integer;
        LineNo: Integer;
    begin
        //Update Place line if there is a single place to single take
        GetWhseTakePlaceLineNo(WhseActLine, TakeLineNo, PlaceLineNo);
        If WhseActLine."Action Type" = WhseActLine."Action Type"::Place then
            LineNo := TakeLineNo
        else
            LineNo := PlaceLineNo;
        IF lrecWhseActivityLine.get(WhseActLine."Activity Type", WhseActLine."No.", LineNo) then begin
            CASE pintFieldNo OF
                WhseActLine.FIELDNO(WhseActLine."Qty. to Handle"):
                    BEGIN
                        lrecWhseActivityLine."Qty. to Handle" := ROUND(WhseActLine."Qty. to Handle (Base)" / lrecWhseActivityLine."Qty. per Unit of Measure", 0.00001);
                    END;
                WhseActLine.FIELDNO(WhseActLine."Lot No."):
                    BEGIN
                        lrecWhseActivityLine."Lot No." := WhseActLine."Lot No.";
                    END;
                WhseActLine.FIELDNO("Serial No."):
                    BEGIN
                        lrecWhseActivityLine."Serial No." := WhseActLine."Serial No.";
                    END;
            END;

            lrecWhseActivityLine.MODIFY;
            Commit;
        end;

    end;

    local procedure GetWhseTakePlaceLineNo(WhseActLine: Record "Warehouse Activity Line"; Var TakeLine: Integer; var PlaceLine: Integer)
    var
        WhActLine: Record "Warehouse Activity Line";
    begin
        IF WhseActLine."Action Type" = WhseActLine."Action Type"::Take THEN begin
            WhActLine.RESET;
            WhActLine.SetRange("No.", WhseActLine."No.");
            WhActLine.SetRange("Parent Line No. ELA", WhseActLine."Line No.");
            WhActLine.SetFilter("Line No.", '<>%1', WhseActLine."Line No.");
            IF WhActLine.FindFirst() THEN begin
                TakeLine := WhActLine."Parent Line No. ELA";
                PlaceLine := WhActLine."Line No.";
            end;
        end else begin
            TakeLine := WhseActLine."Parent Line No. ELA";
            PlaceLine := WhseActLine."Line No.";
        end;
    end;
}
