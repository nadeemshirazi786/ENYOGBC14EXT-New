//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Codeunit EN WMS Management (ID 14229224).
/// </summary>
codeunit 14229224 "WMS Management ELA"
{
    procedure PerformWHReceive(var WarehouseRequest: Record "Warehouse Request")
    var
        Location: Record Location;
        WhseRcptLines: page "Whse. Receipt Lines";
        WhseRcptLine: Record "Warehouse Receipt Line";
    begin
        Location.get(WarehouseRequest."Location Code");
        if Location.RequireReceive(WarehouseRequest."Location Code") then begin
            CreateWhseReceipt(WarehouseRequest);
            WhseRcptLine.SetRange("Source Type", 39);
            WhseRcptLine.SetRange("Source Subtype", WarehouseRequest."Source Subtype");
            WhseRcptLine.SetRange("Source No.", WarehouseRequest."Source No.");
            WhseRcptLines.SetTableView(WhseRcptLine);
            WhseRcptLines.Run();
            //      action("Whse. Receipt Lines")
            // {
            //     ApplicationArea = Warehouse;
            //     Caption = 'Whse. Receipt Lines';
            //     Image = ReceiptLines;
            //     RunObject = Page "Whse. Receipt Lines";
            //     RunPageLink = "Source Type" = CONST(39),
            //                   "Source Subtype" = FIELD("Document Type"),
            //                   "Source No." = FIELD("No.");
            //     RunPageView = SORTING("Source Type", "Source Subtype", "Source No.", "Source Line No.");
            //     ToolTip = 'View ongoing warehouse receipts for the document, in advanced warehouse configurations.';
            // }
        end else
            if location.RequirePutaway(WarehouseRequest."Location Code") then
                CreateReceiptWithInvtPutaway(WarehouseRequest)
            else
                PerformPOReceive(WarehouseRequest);
    end;

    local procedure CreateWhseReceipt(WarehouseRequest: Record "Warehouse Request")
    var
        // WhseReceiptLine: Record "Warehouse Receipt Line";
        // WhseReceiptHdr: Record "Warehouse Receipt Header";
        // GetSourceDocuments: Report "Get Source Documents";
        GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
        PurchaseHeader: record "Purchase Header";
        // WhseReceipt: Page "Warehouse Receipt";
        ReceiptNo: code[20];
    begin
        // check if receipt no exists and then if any other receipt iwth location is same
        // code needs to be revised
        // WhseReceiptLine.SETCURRENTKEY("Source Type", "Source Subtype", "Source No.");
        // WhseReceiptLine.SETRANGE("Source Type", WarehouseRequest."Source Type");
        // WhseReceiptLine.SETRANGE("Source Subtype", WarehouseRequest."Source Subtype");
        // WhseReceiptLine.SETRANGE("Source No.", WarehouseRequest."Source No.");
        // WhseReceiptLine.SETRANGE("Location Code", WarehouseRequest."Location Code");
        // IF WhseReceiptLine.find('-') THEN
        //     ReceiptNo := WhseReceiptLine."No.";

        // IF WhseReceiptLine.next <> 0 THEN
        //     REPEAT
        //         IF WhseReceiptLine."Location Code" <> WarehouseRequest."Location Code" THEN
        //             ERROR(text14229221);
        //         WhseReceiptLine.SETRANGE("Source Type", WarehouseRequest."Source Type");
        //         WhseReceiptLine.SETRANGE("Source Subtype", WarehouseRequest."Source Subtype");
        //         WhseReceiptLine.SETRANGE("Source No.", WarehouseRequest."Source No.");
        //         WhseReceiptLine.SETRANGE("Location Code", WarehouseRequest."Location Code");
        //         IF WhseReceiptLine.FIND('-') THEN BEGIN
        //             IF ReceiptNo <> WhseReceiptLine."No." THEN
        //                 ERROR(Text14229220);
        //         END ELSE BEGIN
        //             IF ReceiptNo <> '' THEN
        //                 ERROR(Text14229220);
        //         END;
        //     UNTIL WarehouseRequest.NEXT = 0;

        // IF ReceiptNo = '' THEN BEGIN
        //     WhseReceiptHdr.VALIDATE("Location Code", WarehouseRequest."Location Code");
        //     WhseReceiptHdr.INSERT(TRUE);
        //     ReceiptNo := WhseReceiptHdr."No.";

        //     GetSourceDocuments.USEREQUESTPAGE(FALSE);
        //     GetSourceDocuments.SETTABLEVIEW(WarehouseRequest);
        //     GetSourceDocuments.SetOneCreatedReceiptHeader(WhseReceiptHdr);
        //     GetSourceDocuments.RUNMODAL;

        //     GetSourceDocInbound.CreateFromPurchOrder(Rec);
        //     COMMIT;
        // END;

        // WhseReceiptHdr.GET(ReceiptNo);
        // WhseReceiptHdr.FILTERGROUP(9);
        // WhseReceiptHdr.SETRECFILTER;
        // WhseReceiptHdr.FILTERGROUP(0);
        // WhseReceipt.SETTABLEVIEW(WhseReceiptHdr);
        // WhseReceipt.Run();

        if WarehouseRequest."Source Document" = WarehouseRequest."Source Document"::"Purchase Order" then begin
            PurchaseHeader.get(PurchaseHeader."Document Type"::Order, WarehouseRequest."Source No.");
            GetSourceDocInbound.CreateFromPurchOrderHideDialog(PurchaseHeader);
        end;
    end;

    local procedure CreateReceiptWithInvtPutaway(WarehouseRequest: Record "Warehouse Request")
    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
        WhseReceiptHdr: Record "Warehouse Receipt Header";
        GetSourceDocuments: Report "Get Source Documents";
        WhseReceipt: Page "Warehouse Receipt";
        ReceiptNo: code[20];
        WhseActivityHdr: Record "Warehouse Activity Header";
        InventoryPutAway: Page "Inventory Put-away";
    begin
        WhseActivityHdr.SETCURRENTKEY("Source Document", "Source No.", "Location Code");
        WhseActivityHdr.SETRANGE("Source Document", WarehouseRequest."Source Document");
        WhseActivityHdr.SETRANGE("Source No.", WarehouseRequest."Source No.");
        WhseActivityHdr.SETRANGE("Location Code", WarehouseRequest."Location Code");
        IF NOT WhseActivityHdr.FINDFirst THEN BEGIN
            CLEAR(WhseActivityHdr);
            WhseActivityHdr.VALIDATE(Type, WhseActivityHdr.Type::"Invt. Put-away");
            WhseActivityHdr.INSERT(TRUE);
            WhseActivityHdr.VALIDATE("Location Code", WarehouseRequest."Location Code");
            WhseActivityHdr.VALIDATE("Source Document", WarehouseRequest."Source Document");
            WhseActivityHdr.VALIDATE("Source No.", WarehouseRequest."Source No.");
            WhseActivityHdr.MODIFY(TRUE);
            COMMIT;
        END;

        WhseActivityHdr.RESET;
        WhseActivityHdr.FILTERGROUP(9);
        WhseActivityHdr.SETRECFILTER;
        WhseActivityHdr.FILTERGROUP(0);
        InventoryPutAway.SETTABLEVIEW(WhseActivityHdr);
        InventoryPutAway.RUN
    end;

    local procedure PerformPOReceive(WarehouseRequest: Record "Warehouse Request")
    var
        PurchaseOrder: page "Purchase Order";
        PurchaseHeader: Record "Purchase Header";
        TransferOrder: page "Transfer Order";
        TransferHeader: Record "Transfer Header";
        SalesReturnOrder: page "Sales Return Order";
        SalesHeader: Record "Sales Header";
    begin
        case WarehouseRequest."Source Document" of
            WarehouseRequest."Source Document"::"Purchase Order":
                begin
                    PurchaseHeader.get(WarehouseRequest."Source Document", WarehouseRequest."Source No.");
                    PurchaseOrder.SetTableView(PurchaseHeader);
                    //todo #14 @Kamranshehzad add line to filter line location
                    PurchaseOrder.Run();
                end;

            WarehouseRequest."Source Document"::"Inbound Transfer":
                begin
                    TransferHeader.Get(WarehouseRequest."Source No.");
                    TransferOrder.SetTableView(TransferHeader);
                    //todo #15 @Kamranshehzad add line to filter line location
                    TransferOrder.Run();
                end;

            WarehouseRequest."Source Document"::"Sales Return Order":
                begin
                    SalesHeader.get(WarehouseRequest."Source Document", WarehouseRequest."Source No.");
                    SalesReturnOrder.SetTableView(SalesHeader);
                    //todo #17 #16 @Kamranshehzad add line to filter line location
                    SalesReturnOrder.Run();
                end;
        end
    end;

    var
        Text14229220: Label 'Orders for different locations cannot be combined.';
        text14229221: Label 'Another receipt with different location';
}
