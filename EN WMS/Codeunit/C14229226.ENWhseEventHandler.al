//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Codeunit EN WMS Release Sales Document (ID 14229226).
/// </summary>
codeunit 14229226 "Whse. Event Handler ELA"
{
    var
        Bin: Record Bin;
        Bin2: Record Bin;
        RemQtyToPutAway: Integer;
        SNRequired: Boolean;
        LNRequired: Boolean;
        TempTrackingSpecification: Record "Tracking Specification";
        ReservationFound: Boolean;
        Location: Record Location;
        Item: Record Item;
        WhseActivHeader: Record "Warehouse Activity Header";
        WhseRequest: Record "Warehouse Request";
        LineCreatedGlob: Boolean;
        AutoCreation: Boolean;
        NextLineNo: Integer;
        PostingDate: Date;
        VendorDocNo: Code[35];
        PurchHeader: Record "Purchase Header";
        CheckLineExist: Boolean;

    // SALES ORDER EVENTS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReleaseSalesDoc', '', true, true)]
    local procedure AddToTripLoad(var SalesHeader: Record "Sales Header")
    var
        TripLoadMgt: Codeunit "WMS Trip Load Mgmt. ELA";
        TripLoadOrder: Record "Trip Load Order ELA";
        TripNo: code[20];
        SalesSetup: Record "Sales & Receivables Setup";
        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
        Customer: Record Customer;
    begin
        SalesSetup.Get();

        if (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) then begin
            if STRPOS(SalesHeader."Order Template Location ELA", 'B') = 1 THEN BEGIN
                IF Customer.Get(SalesHeader."Sell-to Customer No.") THEN BEGIN
                    IF Customer."Auto. Add to Outbound Load ELA" THEN BEGIN
                        TripNo := TripLoadMgt.AddSalesOrderOnTrip(TripLoadOrder."Source Document Type"::"Sales Order", SalesHeader);
                        SalesHeader."Trip No. ELA" := TripNo;
                        SalesHeader.Modify();
                    END
                END;
            END;


            if (SalesSetup."Auto Create Whse. Shipment ELA") then begin
                GetSourceDocOutbound.CreateFromSalesOrder(SalesHeader);
            end;


        end;
    end;

    // // SALES DOCUMENT RELEASE 

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeSalesLineFind', '', TRUE, true)]
    // local procedure RelSalesDoc_OnBeforeSalesLineFind(VAR SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    // begin
    //     if not SalesLine.FindFirst() then
    //         exit;
    // end;


    // WH SHIPMENT EVENTS
    [EventSubscriber(ObjectType::Report, report::"Get Source Documents", 'OnAfterCreateShptHeader', '', true, true)]
    local procedure UpdateWhseShipmentHeader(VAR WarehouseShipmentHeader: Record "Warehouse Shipment Header";
         WarehouseRequest: Record "Warehouse Request"; SalesLine: Record "Sales Line")

    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.get(SalesHeader."Document Type"::Order, SalesLine."Document No.");
        // WarehouseShipmentHeader."Source Order No." := WarehouseRequest."Source No.";
        // WarehouseShipmentHeader."Source Document" := WarehouseShipmentHeader."Source Document"::"Sales Order";
        // WarehouseShipmentHeader."Source Address" := SalesHeader."Ship-to Address";
        // WarehouseShipmentHeader."Source Address 2" := SalesHeader."Ship-to Address 2";
        // WarehouseShipmentHeader."Source Ship-to City" := SalesHeader."Ship-to City";
        // WarehouseShipmentHeader."Source Ship-to Post Code" := SalesHeader."Ship-to Post Code";
        // WarehouseShipmentHeader."Source Ship-to County" := SalesHeader."Ship-to County";
        // WarehouseShipmentHeader."Source Ship-to Country" := SalesHeader."Ship-to Country/Region Code";
        // WarehouseShipmentHeader."Source Ship-to Name" := SalesHeader."Ship-to Name";
        // WarehouseShipmentHeader."Source Ship-to Name 2" := SalesHeader."Ship-to Name 2";
        // WarehouseShipmentHeader."Source Ship-to Contact" := SalesHeader."Ship-to Contact";
        WarehouseShipmentHeader."Trip No. ELA" := SalesHeader."Trip No. ELA";
        WarehouseShipmentHeader.Modify();
    end;


    //OnAfterWhseShptLineInsert
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Create Source Document", 'OnAfterWhseShptLineInsert', '', true, true)]
    local procedure UpdateWhseShptLineAfterInsert(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.get(SalesHeader."Document Type"::Order, WarehouseShipmentLine."Source No.");
        // WarehouseShipmentLine."Source Order No." := WarehouseRequest."Source No.";
        // WarehouseShipmentLine."Source Document" := WarehouseShipmentHeader."Source Document"::"Sales Order";
        WarehouseShipmentLine."Source Address ELA" := SalesHeader."Ship-to Address";
        WarehouseShipmentLine."Source Address 2 ELA" := SalesHeader."Ship-to Address 2";
        WarehouseShipmentLine."Source Ship-to City ELA" := SalesHeader."Ship-to City";
        WarehouseShipmentLine."Source Ship-to Post Code ELA" := SalesHeader."Ship-to Post Code";
        WarehouseShipmentLine."Source Ship-to County ELA" := SalesHeader."Ship-to County";
        WarehouseShipmentLine."Source Ship-to Country ELA" := SalesHeader."Ship-to Country/Region Code";
        WarehouseShipmentLine."Source Ship-to Name ELA" := SalesHeader."Ship-to Name";
        WarehouseShipmentLine."Source Ship-to Name 2 ELA" := SalesHeader."Ship-to Name 2";
        WarehouseShipmentLine."Source Ship-to Contact ELA" := SalesHeader."Ship-to Contact";
        WarehouseShipmentLine."Trip No. ELA" := SalesHeader."Trip No. ELA";
        WarehouseShipmentLine.Modify();
    end;

    [EventSubscriber(ObjectType::Table, 7320, 'OnBeforeWhseShptLineDelete', '', true, true)]
    local procedure OnBeforeWhseShptLineDelete(VAR WarehouseShipmentLine: Record "Warehouse Shipment Line")
    var
        ShipmentDashBrd: Record "Shipment Dashboard ELA";
        ShipmentMgmt: codeunit "Shipment Mgmt. ELA";
    begin
        ShipmentDashBrd.reset;
        ShipmentDashBrd.SetRange("Shipment No.", WarehouseShipmentLine."No.");
        ShipmentDashBrd.SetRange("Shipment Line No.", WarehouseShipmentLine."Line No.");
        ShipmentDashBrd.SetRange("Source No.", WarehouseShipmentLine."Source No.");
        ShipmentDashBrd.SetRange("Source Line No.", WarehouseShipmentLine."Source Line No.");
        if ShipmentDashBrd.FindSet() then begin
            ShipmentDashBrd.Delete();
            ShipmentMgmt.DeleteShipmentFromShipmentManagement(WarehouseShipmentLine);
        end;
    end;


    [EventSubscriber(ObjectType::Table, 7321, 'OnAfterCreatePickDoc', '', true, true)]
    local procedure OnAfterCreatePickDoc(VAR WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    var
        WhseShipLine: record "Warehouse Shipment Line";
        ItemUOM: record "Item Unit of Measure";
        TotalContainers: Integer;
        ContMgmt: Codeunit "Container Mgmt. ELA";
        WhseActLine: Record "Warehouse Activity Line";
        pick: Codeunit "Create Pick";
    begin
        WhseShipLine.reset;
        WhseShipLine.SetRange("No.", WarehouseShipmentHeader."No.");
        if WhseShipLine.FindFirst() then
            WhseShipLine.DeleteQtyToHandle(WhseShipLine);

        //Create Bulkpick containers
        /* if WhseShipLine.FINDSET then
             repeat
                 ItemUOM.RESET;
                 ItemUOM.SetFilter("Item No.", WhseShipLine."Item No.");
                 ItemUOM.SetFilter("Is Bulk", '%1', true);
                 IF ItemUOM.FindFirst() then begin
                     TotalContainers := ROUND(WhseShipLine.Quantity / ItemUOM."Qty. per Unit of Measure", 1, '=');
                     WhseActLine.RESET;
                     WhseActLine.SetFilter("Source No.", WhseShipLine."Source No.");
                     WhseActLine.SetRange("Source Line No.", WhseShipLine."Source Line No.");
                     WhseActLine.SetFilter("Action Type", '=%1', WhseActLine."Action Type"::Take);
                     if WhseActLine.FindFirst() then
                         ContMgmt.GenarateContainerContents(
                                 '', 1, 0, WhseShipLine."Source No.", WhseShipLine."Source Line No.", WhseShipLine."Item No.",
                                 WhseShipLine."Unit of Measure Code", ItemUOM."Qty. per Unit of Measure", TotalContainers, '', WhseShipLine."Location Code",
                                 2, WarehouseShipmentHeader."No.", 2, WhseActLine."No.");
                 end;

             until WhseShipLine.next = 0;*/

    end;

    [EventSubscriber(ObjectType::Codeunit, 5763, 'OnAfterPostWhseShipment', '', true, true)]
    local procedure OnAfterPostWhseShipment(VAR WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    var
        TriploadOrder: Record "Trip Load Order ELA";
        ShipmentDashBrd: record "Shipment Dashboard ELA";
    begin
        if TriploadOrder.Get(WarehouseShipmentHeader."Trip No. ELA") then begin
            TriploadOrder.validate("Shipment Posted", true);
            if WarehouseShipmentHeader."Shipping No." <> '' then
                TriploadOrder."Posted. Whse. Shipment No." := WarehouseShipmentHeader."Shipping No.";

            TriploadOrder.Modify();
        end;

        ShipmentDashBrd.SetRange("Shipment No.", WarehouseShipmentHeader."No.");
        ShipmentDashBrd.DeleteAll();
    end;

    // WH PICKING EVENTS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnBeforeWhseActivHeaderInsert', '', true, true)]
    local procedure OnBeforeWhseActivHeaderInsert(VAR WarehouseActivityHeader: Record "Warehouse Activity Header")
    var
    begin
        WarehouseActivityHeader."Created By ELA" := UserId;
        WarehouseActivityHeader."Created On Date Time ELA" := CurrentDateTime;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnBeforeWhseActivLineInsert', '', true, true)]
    local procedure CPOnBeforeWhseActivLineInsert(VAR WarehouseActivityLine: Record "Warehouse Activity Line"; WarehouseActivityHeader: Record "Warehouse Activity Header")
    var
        WhseShipHdr: Record "Warehouse Shipment Header";
    begin
        if WarehouseActivityLine."Whse. Document Type" = WarehouseActivityLine."Whse. Document Type"::Shipment then begin
            WhseShipHdr.Get(WarehouseActivityLine."Whse. Document No.");
            WarehouseActivityLine."Trip No. ELA" := WhseShipHdr."Trip No. ELA";
            WarehouseActivityHeader."Trip No. ELA" := WhseShipHdr."Trip No. ELA";
            WarehouseActivityHeader.Modify();
        end;
    end;

    // WH RECEIVING EVENTS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Create Source Document", 'OnAfterCreateRcptLineFromPurchLine', '', true, true)]
    local procedure OnAfterCreateRcptLineFromPurchLine(VAR WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseReceiptHeader: Record "Warehouse Receipt Header"; PurchaseLine: Record "Purchase Line")
    var
        ContainerContent: Record "Container Content ELA";
        WhseDocType: Enum "Whse. Doc. Type ELA";

    begin
        // ContainerContent.SetRange("Document Type", PurchaseLine."Document Type");
        ContainerContent.SetRange("Document No.", PurchaseLine."Document No.");
        ContainerContent.setrange("Whse. Document No.", '');
        ContainerContent.ModifyAll("Whse. Document Type", WhseDocType::Receipt);
        ContainerContent.modifyall("Whse. Document No.", WarehouseReceiptHeader."No.");

        // if container.FindSet() then
        //     repeat
        //         Container."Whse. Document No." := WarehouseReceiptHeader."No.";
        //         container.Modify();
        //     until Container.Next() = 0;
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnBeforePostSourceDocument', '', true, true)]
    // local procedure OnBeforePostSourceDocument(VAR WhseRcptLine: Record "Warehouse Receipt Line"; PurchaseHeader: Record "Purchase Header"; SalesHeader: Record "Sales Header"; TransferHeader: Record "Transfer Header")
    // var
    //     Container: record "EN Container";
    // begin
    //     Container.SetRange("Whse. Document Type", Container."Whse. Document Type"::Receipt);
    //     Container.SetRange("Whse. Document No.", WhseRcptLine."No.");
    //     Container.SetRange(Completed, false);
    //     Container.ModifyAll(Completed, true);
    // end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnBeforeRun', '', true, true)]
    local procedure WPROnBeforeRun(VAR WarehouseReceiptLine: Record "Warehouse Receipt Line")
    var
        Container: record "Container ELA";
    begin
        /* Container.SetRange("Whse. Document Type", Container."Whse. Document Type"::Receipt);
         Container.SetRange("Whse. Document No.", WarehouseReceiptLine."No.");
         Container.SetRange(Completed, false);
         Container.ModifyAll(Completed, true);*/
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnBeforePostedWhseRcptLineInsert', '', true, true)]
    local procedure WPROnBeforePostedWhseRcptLineInsert(VAR PostedWhseReceiptLine: Record "Posted Whse. Receipt Line"; WarehouseReceiptLine: Record "Warehouse Receipt Line")
    var
    begin
        if WarehouseReceiptLine."Received By ELA" = '' then
            PostedWhseReceiptLine."Received By ELA" := UserId()
        else
            PostedWhseReceiptLine."Received By ELA" := WarehouseReceiptLine."Received By ELA";

        PostedWhseReceiptLine."Received Date ELA" := Today();
        PostedWhseReceiptLine."Received Time ELA" := Time();
    end;


    // PUTAWAY EVENTS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Put-away", 'OnBeforeWhseActivLineInsert', '', true, true)]
    local procedure CPAOnBeforeWhseActivLineInsert(VAR WarehouseActivityLine: Record "Warehouse Activity Line"; PostedWhseRcptLine: Record "Posted Whse. Receipt Line")
    var
        Container: record "Container ELA";
        ContainerContent: Record "Container Content ELA";
    begin
        ContainerContent.SetRange("Whse. Document Type", ContainerContent."Whse. Document Type"::Receipt);
        ContainerContent.SetRange("Whse. Document No.", PostedWhseRcptLine."Whse. Receipt No.");
        ContainerContent.SetRange("Document No.", PostedWhseRcptLine."Source No.");
        ContainerContent.SetRange("Document Line No.", PostedWhseRcptLine."Source Line No.");
        ContainerContent.SetRange("Item No.", PostedWhseRcptLine."Item No.");
        ContainerContent.SetRange("Unit of Measure", PostedWhseRcptLine."Unit of Measure Code");
        if ContainerContent.FindFirst() then begin
            WarehouseActivityLine."Container No. ELA" := ContainerContent."Container No.";
            WarehouseActivityLine."Licnese Plate No. ELA" := ContainerContent."License Plate No.";
        end;



        WarehouseActivityLine."Received By ELA" := PostedWhseRcptLine."Received By ELA";
        WarehouseActivityLine."Received Date ELA" := PostedWhseRcptLine."Received Date ELA";
        WarehouseActivityLine."Received Time ELA" := PostedWhseRcptLine."Received Time ELA";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Put-away", 'OnBeforeCreateNewWhseActivity', '', true, true)]
    procedure CPAOnBeforeCreateNewWhseActivity(PostedWhseRcptLine: Record "Posted Whse. Receipt Line"; VAR WhseActivLine: Record "Warehouse Activity Line";
     VAR WhseActivHeader: Record "Warehouse Activity Header"; VAR Location: Record Location; InsertHeader: Boolean; Bin: Record Bin;
     ActionType: Option ,Take,Place; LineNo: Integer; BreakbulkNo: Integer; BreakbulkFilter: Boolean; QtyToHandleBase: Decimal;
     BreakPackage: Boolean; EmptyZoneBin: Boolean; Breakbulk: Boolean; CrossDockInfo: Option; PutAwayItemUOM: Record "Item Unit of Measure";
      DoNotFillQtytoHandle: Boolean; VAR IsHandled: Boolean)
    var


        ContainerContent: Record "Container Content ELA";
        repo: Report 7323;

        NewWhseActivLine: Record "Warehouse Activity Line" temporary;
        ParentLineNo: Integer;
    begin
        IsHandled := false;
        CASE ActionType OF
            ActionType::Take:
                BEGIN
                    WITH PostedWhseRcptLine DO BEGIN
                        IF (WhseActivHeader."No." = '') AND InsertHeader then BEGIN
                            WhseActivHeader.INIT;
                            WhseActivHeader.Type := WhseActivHeader.Type::"Put-away";
                            WhseActivHeader."Location Code" := "Location Code";
                            WhseActivHeader."Breakbulk Filter" := BreakbulkFilter;
                            OnBeforeWhseActivHeaderInsert(WhseActivHeader);
                            WhseActivHeader.INSERT(TRUE);
                        END;

                        ContainerContent.reset;
                        ContainerContent.SetRange("Whse. Document Type", ContainerContent."Whse. Document Type"::Receipt);
                        ContainerContent.SetRange("Whse. Document No.", PostedWhseRcptLine."Whse. Receipt No.");
                        ContainerContent.SetRange("Document No.", PostedWhseRcptLine."Source No.");
                        ContainerContent.SetRange("Document No.", PostedWhseRcptLine."Source No.");
                        ContainerContent.SetRange("Document Line No.", PostedWhseRcptLine."Source Line No.");
                        ContainerContent.SetRange("Item No.", PostedWhseRcptLine."Item No.");
                        ContainerContent.SetRange("Unit of Measure", PostedWhseRcptLine."Unit of Measure Code");
                        if ContainerContent.FINDSET() then begin
                            repeat
                                ParentLineNo := CreateWhseLine(PostedWhseRcptLine, NewWhseActivLine, ActionType::Take, 0, ContainerContent, BreakbulkNo, BreakbulkFilter,
                                QtyToHandleBase, Breakbulk, EmptyZoneBin, Breakbulk, CrossDockInfo, PutAwayItemUOM, DoNotFillQtytoHandle);
                                CreateWhseLine(PostedWhseRcptLine, NewWhseActivLine, ActionType::Place, ParentLineNo, ContainerContent, BreakbulkNo, BreakbulkFilter,
                                QtyToHandleBase, Breakbulk, EmptyZoneBin, Breakbulk, CrossDockInfo, PutAwayItemUOM, DoNotFillQtytoHandle)
                            until ContainerContent.next = 0;

                        end;
                    END;
                END;
        end;
        IsHandled := true;

    end;

    LOCAL procedure CreateWhseLine(PostedWhseRcptLine: Record "Posted Whse. Receipt Line"; var WhseActivLine: Record "Warehouse Activity Line";
    ActionType: Option "",Place,Take; ParentLineNo: Integer; var ContainerContent: Record "Container Content ELA"; BreakbulkNo: Integer; BreakbulkFilter: Boolean;
    QtyToHandleBase: Decimal; BreakPackage: Boolean; EmptyZoneBin: Boolean; Breakbulk: Boolean; CrossDockInfo: Option; PutAwayItemUOM: Record "Item Unit of Measure";
      DoNotFillQtytoHandle: Boolean): Integer
    var
        WhseActType: Enum "WMS Activity Type ELA";
        createPutaway: Codeunit "Create Put-away";
        UOMMgt: codeunit "Unit of Measure Management";
    begin
        WITH PostedWhseRcptLine DO BEGIN
            WhseActivLine.INIT;
            WhseActivLine."Activity Type" := WhseActivHeader.Type;
            WhseActivLine."No." := WhseActivHeader."No.";
            WhseActivLine."Line No." := GetLineNo(ActionType, WhseActivHeader."No.", PostedWhseRcptLine."Line No.");
            WhseActivLine."Action Type" := ActionType;
            WhseActivLine."Source Type" := "Source Type";
            WhseActivLine."Source Subtype" := "Source Subtype";
            WhseActivLine."Source No." := "Source No.";
            WhseActivLine."Source Line No." := "Source Line No.";
            WhseActivLine."Source Document" := "Source Document";
            IF WhseActivLine."Source Type" = 0 THEN
                WhseActivLine."Whse. Document Type" := WhseActivLine."Whse. Document Type"::"Internal Put-away"
            ELSE
                WhseActivLine."Whse. Document Type" := WhseActivLine."Whse. Document Type"::Receipt;
            WhseActivLine."Whse. Document No." := "No.";
            WhseActivLine."Whse. Document Line No." := "Line No.";
            WhseActivLine."Location Code" := Location.Code;
            WhseActivLine."Shelf No." := "Shelf No.";
            WhseActivLine."Due Date" := "Due Date";
            WhseActivLine."Starting Date" := "Starting Date";
            WhseActivLine."Breakbulk No." := BreakbulkNo;
            WhseActivLine."Original Breakbulk" := Breakbulk;
            IF BreakbulkFilter THEN
                WhseActivLine.Breakbulk := Breakbulk;
            CASE ActionType OF
                ActionType::Take:
                    BEGIN
                        WhseActivLine."Bin Code" := "Bin Code";
                        WhseActivLine."Zone Code" := "Zone Code";
                        ContainerContent."Activity Type" := WhseActType::"Put-away";
                        ContainerContent."Activity No." := WhseActivLine."No.";
                        ContainerContent."Activity Line No." := WhseActivLine."Line No.";
                        ContainerContent.Modify();
                    END;
                ActionType::Place:
                    BEGIN
                        IF NOT EmptyZoneBin THEN begin
                            WITH WhseActivLine DO BEGIN
                                "Bin Code" := Bin.Code;
                                "Zone Code" := Bin."Zone Code";
                                IF Location.IsBWReceive AND
                                   (CrossDockInfo <> "Cross-Dock Information"::"Cross-Dock Items") AND
                                   ((Bin.Code = PostedWhseRcptLine."Bin Code") OR Location.IsBinBWReceiveOrShip(Bin.Code))
                                THEN BEGIN
                                    Bin2.SETRANGE("Location Code", Location.Code);
                                    Bin2.SETFILTER(Code, '<>%1&<>%2&<>%3', Location."Receipt Bin Code", Location."Shipment Bin Code",
                                      PostedWhseRcptLine."Bin Code");
                                    IF Bin2.FINDFIRST THEN BEGIN
                                        "Bin Code" := Bin2.Code;
                                        "Zone Code" := Bin2."Zone Code";
                                    END ELSE BEGIN
                                        "Bin Code" := '';
                                        "Zone Code" := '';
                                    END;
                                END;
                            END;
                        end;
                    END;
                ELSE BEGIN
                        WhseActivLine."Bin Code" := '';
                        WhseActivLine."Zone Code" := '';
                    END
            END;
            IF WhseActivLine."Bin Code" <> '' THEN BEGIN
                WhseActivLine."Special Equipment Code" :=
                  createPutaway.GetSpecEquipmentCode(WhseActivLine."Bin Code");
                GetBin(WhseActivLine."Location Code", WhseActivLine."Bin Code");
                WhseActivLine.Dedicated := Bin.Dedicated;
                WhseActivLine."Bin Ranking" := Bin."Bin Ranking";
                WhseActivLine."Bin Type Code" := Bin."Bin Type Code";
            END;
            WhseActivLine."Item No." := "Item No.";
            WhseActivLine."Variant Code" := "Variant Code";
            WhseActivLine.Description := Description;
            WhseActivLine."Description 2" := "Description 2";
            WhseActivLine."Cross-Dock Information" := CrossDockInfo;
            IF BreakPackage OR (ActionType = 0) OR
               NOT Location."Directed Put-away and Pick"
            THEN BEGIN
                WhseActivLine."Unit of Measure Code" := "Unit of Measure Code";
                WhseActivLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
            END ELSE BEGIN
                WhseActivLine."Unit of Measure Code" := PutAwayItemUOM.Code;
                WhseActivLine."Qty. per Unit of Measure" := PutAwayItemUOM."Qty. per Unit of Measure";
            END;
            QtyToHandleBase := ContainerContent.Quantity;
            WhseActivLine.VALIDATE(
              Quantity, ROUND(QtyToHandleBase / WhseActivLine."Qty. per Unit of Measure", UOMMgt.QtyRndPrecision));
            IF QtyToHandleBase <> 0 THEN BEGIN
                WhseActivLine."Qty. (Base)" := QtyToHandleBase;
                WhseActivLine."Qty. to Handle (Base)" := QtyToHandleBase;
                WhseActivLine."Qty. Outstanding (Base)" := QtyToHandleBase;
            END;
            IF DoNotFillQtytoHandle THEN BEGIN
                WhseActivLine."Qty. to Handle" := 0;
                WhseActivLine."Qty. to Handle (Base)" := 0;
                WhseActivLine.Cubage := 0;
                WhseActivLine.Weight := 0;
            END;
            IF "Serial No." <> '' THEN
                WhseActivLine.TESTFIELD("Qty. per Unit of Measure", 1);
            WhseActivLine."Serial No." := "Serial No.";
            WhseActivLine."Lot No." := "Lot No.";
            WhseActivLine."Warranty Date" := "Warranty Date";
            WhseActivLine."Expiration Date" := "Expiration Date";
            WhseActivLine."Container No. ELA" := ContainerContent."Container No.";
            WhseActivLine."Container Line No. ELA" := ContainerContent."Line No.";
            WhseActivLine."Licnese Plate No. ELA" := ContainerContent."License Plate No.";
            WhseActivLine."Received By ELA" := PostedWhseRcptLine."Received By ELA";
            WhseActivLine."Received Date ELA" := PostedWhseRcptLine."Received Date ELA";
            WhseActivLine."Received Time ELA" := PostedWhseRcptLine."Received Time ELA";
            If ParentLineNo = 0 then
                WhseActivLine."Parent Line No. ELA" := WhseActivLine."Line No."
            else
                WhseActivLine."Parent Line No. ELA" := ParentLineNo;
            WhseActivLine.INSERT;
        end;
    end;

    LOCAL procedure GetBin(LocationCode: Code[10]; BinCode: Code[20])
    begin
        IF (Bin."Location Code" <> LocationCode) OR
           (Bin.Code <> BinCode)
        THEN
            Bin.GET(LocationCode, BinCode)
    end;

    local procedure GetLineNo(ActionType: Option ,Take,Place; "Document No.": Code[20]; SourceLineNo: Integer) LineNo: Integer
    var
        WhseActLine: Record "Warehouse Activity Line";
    begin

        WhseActLine.Reset();
        WhseActLine.SetCurrentKey("Activity Type", "No.", "Line No.");
        WhseActLine.SetRange("Action Type", ActionType);
        WhseActLine.SetRange("No.", "Document No.");
        If WhseActLine.FindLast() then begin
            exit(WhseActLine."Line No." + 10000);
        end else
            exit(SourceLineNo);
    end;

    [EventSubscriber(ObjectType::Table, 5767, 'OnBeforeDeleteWhseActivLine2', '', true, true)]
    procedure OnBeforeDeleteWhseActivLine2(VAR WarehouseActivityLine2: Record "Warehouse Activity Line"; CalledFromHeader: Boolean)
    var
        ContMgmt: Codeunit "Container Mgmt. ELA";
    begin

        ContMgmt.RemoveContentToContainerFromLineNo(WarehouseActivityLine2."Container No. ELA", WarehouseActivityLine2."Container Line No. ELA");
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Inventory Put-away", 'OnBeforeAutoCreatePutAwayLines', '', true, true)]
    procedure CPAOnBeforeAutoCreatePutAwayLines(WarehouseRequest: Record "Warehouse Request"; VAR WarehouseActivityHeader: Record "Warehouse Activity Header"; VAR LineCreated: Boolean; VAR IsHandled: Boolean)
    begin
        WhseActivHeader := WarehouseActivityHeader;
        AutoCreation := TRUE;
        CheckLineExist := False;
        GetLocation(WhseRequest."Location Code");
        WhseRequest := WarehouseRequest;
        GetSourceDocHeader;
        UpdateWhseActivHeader(WhseRequest);
        CASE WhseRequest."Source Document" OF
            WhseRequest."Source Document"::"Purchase Order":
                begin
                    CreatePutAwayLinesFromPurchase(PurchHeader);
                    IsHandled := true;
                end;
            WhseRequest."Source Document"::"Purchase Return Order":
                begin
                    CreatePutAwayLinesFromPurchase(PurchHeader);
                    IsHandled := true;
                end;
        END;
        LineCreated := LineCreatedGlob;
        if IsHandled then begin
            IF LineCreated THEN BEGIN
                WhseActivHeader.MODIFY;
            END;
        end;
        IsHandled := false;
        WarehouseActivityHeader := WhseActivHeader;
    end;

    local procedure CreatePutAwayLinesFromPurchase(PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
        NewWhseActivLine: Record "Warehouse Activity Line";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        Container: record "Container ELA";
        ContainerContent: Record "Container Content ELA";
        WhseActType: Enum "WMS Activity Type ELA";
    begin

        WITH PurchLine DO BEGIN
            IF NOT SetFilterPurchLine(PurchLine, PurchHeader) THEN
                EXIT;
            REPEAT
                ContainerContent.reset;
                // ContainerContent.SetRange("Whse. Document Type", ContainerContent."Whse. Document Type"::Receipt);
                ContainerContent.SetRange("Document No.", "Document No.");
                ContainerContent.SetRange("Document Line No.", "Line No.");
                ContainerContent.SetRange("Item No.", "No.");
                ContainerContent.SetRange("Unit of Measure", "Unit of Measure Code");
                if ContainerContent.FINDSET() then begin
                    repeat
                        FindNextLineNo;
                        RemQtyToPutAway := ContainerContent.Quantity;
                        NewWhseActivLine.INIT;
                        NewWhseActivLine."Activity Type" := WhseActivHeader.Type;
                        NewWhseActivLine."No." := WhseActivHeader."No.";
                        NewWhseActivLine."Line No." := NextLineNo;
                        NewWhseActivLine.SetSource(DATABASE::"Purchase Line", "Document Type", "Document No.", "Line No.", 0);
                        NewWhseActivLine."Location Code" := "Location Code";
                        IF "Bin Code" = '' THEN
                            NewWhseActivLine."Bin Code" := GetDefaultBinCode("No.", "Variant Code", "Location Code")
                        ELSE
                            NewWhseActivLine."Bin Code" := "Bin Code";
                        IF NOT Location."Bin Mandatory" THEN
                            NewWhseActivLine."Shelf No." := GetShelfNo("No.");
                        NewWhseActivLine."Item No." := "No.";
                        NewWhseActivLine."Variant Code" := "Variant Code";
                        NewWhseActivLine."Unit of Measure Code" := "Unit of Measure Code";
                        NewWhseActivLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
                        NewWhseActivLine.Description := Description;
                        NewWhseActivLine."Description 2" := "Description 2";
                        NewWhseActivLine."Due Date" := "Expected Receipt Date";
                        NewWhseActivLine."Container No. ELA" := ContainerContent."Container No.";
                        NewWhseActivLine."Container Line No. ELA" := ContainerContent."Line No.";
                        NewWhseActivLine."Licnese Plate No. ELA" := ContainerContent."License Plate No.";
                        IF "Document Type" = "Document Type"::Order THEN
                            NewWhseActivLine."Source Document" := NewWhseActivLine."Source Document"::"Purchase Order"
                        ELSE
                            NewWhseActivLine."Source Document" := NewWhseActivLine."Source Document"::"Purchase Return Order";
                        IF NOT ReservationFound AND SNRequired THEN
                            REPEAT
                                NewWhseActivLine."Line No." := NextLineNo;
                                InsertWhseActivLine(NewWhseActivLine, 1);
                            UNTIL RemQtyToPutAway <= 0
                        ELSE
                            InsertWhseActivLine(NewWhseActivLine, RemQtyToPutAway);

                        ContainerContent."Activity Type" := WhseActType::"Invt. Put-away";
                        ContainerContent."Activity No." := NewWhseActivLine."No.";
                        ContainerContent."Activity Line No." := NewWhseActivLine."Line No.";
                        ContainerContent.Modify();
                    until ContainerContent.Next = 0;

                end;
            Until Next = 0;

            /* IF NOT SetFilterPurchLine(PurchLine, PurchHeader) THEN BEGIN
                 EXIT;
             END;


             REPEAT
                 IF NOT NewWhseActivLine.ActivityExists(DATABASE::"Purchase Line", "Document Type", "Document No.", "Line No.", 0, 0) THEN BEGIN


                     ItemTrackingMgt.CheckWhseItemTrkgSetup("No.", SNRequired, LNRequired, FALSE);
                     IF SNRequired OR LNRequired THEN
                         ReservationFound :=
                           FindReservationEntry(DATABASE::"Purchase Line", "Document Type", "Document No.", "Line No.", SNRequired, LNRequired);

                     REPEAT

                     UNTIL RemQtyToPutAway <= 0;
                 END;
             UNTIL NEXT = 0;*/
        end;
    end;

    local procedure SetFilterPurchLine(VAR PurchLine: Record "Purchase Line"; PurchHeader: Record "Purchase Header"): Boolean
    begin
        WITH PurchLine DO BEGIN
            SETCURRENTKEY("Document Type", "Document No.", "Location Code");
            SETRANGE("Document Type", PurchHeader."Document Type");
            SETRANGE("Document No.", PurchHeader."No.");
            SETRANGE("Drop Shipment", FALSE);
            IF NOT CheckLineExist THEN
                SETRANGE("Location Code", WhseActivHeader."Location Code");
            SETRANGE(Type, Type::Item);
            IF PurchHeader."Document Type" = PurchHeader."Document Type"::Order THEN
                SETFILTER("Qty. to Receive", '>%1', 0)
            ELSE
                SETFILTER("Return Qty. to Ship", '<%1', 0);
            EXIT(FIND('-'));
        END;
    end;

    local procedure FindNextLineNo()
    var
        WhseActivLine: Record "Warehouse Activity Line";
        repor: Report 7323;

    begin
        WITH WhseActivHeader DO BEGIN
            WhseActivLine.SETRANGE("Activity Type", WhseActivLine."Activity Type"::"Invt. Put-away");
            WhseActivLine.SETRANGE("No.", "No.");
            IF WhseActivLine.FINDLAST THEN
                NextLineNo := WhseActivLine."Line No." + 10000
            ELSE
                NextLineNo := 10000;
        END;
    end;

    local procedure InsertWhseActivLine(VAR NewWhseActivLine: Record "Warehouse Activity Line"; PutAwayQty: Decimal)
    begin
        WITH NewWhseActivLine DO BEGIN
            IF Location."Bin Mandatory" THEN
                "Action Type" := "Action Type"::Place;

            "Serial No." := '';
            "Expiration Date" := 0D;
            IF ReservationFound THEN BEGIN
                CopyTrackingFromSpec(TempTrackingSpecification);
                VALIDATE(Quantity, CalcQty(TempTrackingSpecification."Qty. to Handle (Base)"));
                ReservationFound := FALSE;
            END ELSE
                IF (SNRequired OR LNRequired) AND (TempTrackingSpecification.NEXT <> 0) THEN BEGIN
                    CopyTrackingFromSpec(TempTrackingSpecification);
                    VALIDATE(Quantity, CalcQty(TempTrackingSpecification."Qty. to Handle (Base)"));
                END ELSE
                    VALIDATE(Quantity, PutAwayQty);
            VALIDATE("Qty. to Handle", 0);
        END;

        IF AutoCreation AND NOT LineCreatedGlob THEN BEGIN
            WhseActivHeader."No." := '';
            WhseActivHeader.INSERT(TRUE);
            UpdateWhseActivHeader(WhseRequest);
            NextLineNo := 10000;
            COMMIT;
        END;
        NewWhseActivLine."No." := WhseActivHeader."No.";
        NewWhseActivLine."Line No." := NextLineNo;
        NewWhseActivLine.INSERT;

        LineCreatedGlob := TRUE;
        NextLineNo := NextLineNo + 10000;
        RemQtyToPutAway -= NewWhseActivLine.Quantity;
    end;

    local procedure UpdateWhseActivHeader(WhseRequest: Record "Warehouse Request")
    begin
        WITH WhseRequest DO BEGIN
            IF WhseActivHeader."Source Document" = 0 THEN BEGIN
                WhseActivHeader."Source Document" := "Source Document";
                WhseActivHeader."Source Type" := "Source Type";
                WhseActivHeader."Source Subtype" := "Source Subtype";
            END ELSE
                WhseActivHeader.TESTFIELD("Source Document", "Source Document");
            IF WhseActivHeader."Source No." = '' THEN BEGIN
                WhseActivHeader."Source No." := "Source No.";
            END ELSE
                WhseActivHeader.TESTFIELD("Source No.", "Source No.");

            WhseActivHeader."Destination Type" := "Destination Type";
            WhseActivHeader."Destination No." := "Destination No.";
            WhseActivHeader."External Document No." := "External Document No.";
            WhseActivHeader."Expected Receipt Date" := "Expected Receipt Date";
            WhseActivHeader."Posting Date" := PostingDate;
            WhseActivHeader."External Document No.2" := VendorDocNo;
            GetLocation("Location Code");
        END;
    end;


    local procedure FindReservationEntry(SourceType: Integer; DocType: Integer; DocNo: Code[20]; DocLineNo: Integer; SNRequired: Boolean; LNRequired: Boolean): Boolean
    var
        ReservEntry: Record "Reservation Entry";
        ItemTrackMgt: Codeunit "Item Tracking Management";
    begin
        WITH ReservEntry DO BEGIN
            IF SourceType IN [DATABASE::"Prod. Order Line", DATABASE::"Transfer Line"] THEN BEGIN
                SetSourceFilter(SourceType, DocType, DocNo, -1, TRUE);
                SETRANGE("Source Prod. Order Line", DocLineNo)
            END ELSE
                SetSourceFilter(SourceType, DocType, DocNo, DocLineNo, TRUE);
            IF SNRequired THEN
                SETFILTER("Serial No.", '<>%1', '');
            IF LNRequired THEN
                SETFILTER("Lot No.", '<>%1', '');
            IF FINDFIRST THEN
                IF ItemTrackMgt.SumUpItemTracking(ReservEntry, TempTrackingSpecification, TRUE, TRUE) THEN
                    EXIT(TRUE);
        END;
    end;

    local procedure GetDefaultBinCode(ItemNo: Code[20]; VariantCode: Code[20]; LocationCode: Code[20]): Code[20]
    var
        WMSMgt: Codeunit "WMS Management";
        BinCode: Code[20];
    begin
        GetLocation(LocationCode);
        IF Location."Bin Mandatory" THEN
            IF WMSMgt.GetDefaultBin(ItemNo, VariantCode, LocationCode, BinCode) THEN
                EXIT(BinCode);
    end;

    local procedure GetLocation(LocationCode: Code[20])
    begin
        IF LocationCode = '' THEN
            CLEAR(Location)
        ELSE
            IF LocationCode <> Location.Code THEN
                Location.GET(LocationCode);
    end;

    local procedure GetShelfNo(ItemNo: Code[20]): Code[20]
    begin
        GetItem(ItemNo);
        EXIT(Item."Shelf No.");
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        IF ItemNo <> Item."No." THEN
            Item.GET(ItemNo);
    end;

    local procedure GetSourceDocHeader()
    begin
        CASE WhseRequest."Source Document" OF
            WhseRequest."Source Document"::"Purchase Order":
                BEGIN
                    PurchHeader.GET(PurchHeader."Document Type"::Order, WhseRequest."Source No.");
                    PostingDate := PurchHeader."Posting Date";
                    VendorDocNo := PurchHeader."Vendor Invoice No.";
                END;
            WhseRequest."Source Document"::"Purchase Return Order":
                BEGIN
                    PurchHeader.GET(PurchHeader."Document Type"::"Return Order", WhseRequest."Source No.");
                    PostingDate := PurchHeader."Posting Date";
                    VendorDocNo := PurchHeader."Vendor Cr. Memo No.";
                END;
        end;
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Inventory Put-away", 'OnBeforeCreatePutAwayLinesFromPurchaseLoop', '', true, true)]
    procedure CPAOnBeforeCreatePutAwayLinesFromPurchaseLoop(VAR WarehouseActivityHeader: Record "Warehouse Activity Header"; PurchaseHeader: Record "Purchase Header"; VAR IsHandled: Boolean; PurchaseLine: Record "Purchase Line")
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", 'OnAfterWhseShptLineModify', '', true, true)]
    procedure UWSOnAfterWhseShptLineModify(VAR WarehouseShipmentLine: Record "Warehouse Shipment Line")
    var
        ShipDashMgmt: Codeunit "Shipment Mgmt. ELA";
    begin

        //<<EN1.03
        IF WarehouseShipmentLine.Status = WarehouseShipmentLine.Status::"Completely Picked" THEN
            ShipDashMgmt.UpdateProcessedLine(WarehouseShipmentLine."No.", WarehouseShipmentLine."Line No.", TRUE);

        ShipDashMgmt.UpdateProcessedQty(WarehouseShipmentLine."No.", WarehouseShipmentLine."Line No.", WarehouseShipmentLine."Qty. Picked"); //<<EN1.07
                                                                                                                                             //>>EN1.03
    end;

    [EventSubscriber(ObjectType::Report, 5753, 'OnBeforeWhseReceiptHeaderInsert', '', true, true)]
    procedure OnBeforeWhseReceiptHeaderInsert(VAR WarehouseReceiptHeader: Record "Warehouse Receipt Header"; WarehouseRequest: Record "Warehouse Request")
    begin
        WarehouseReceiptHeader."Source Doc. No. ELA" := WarehouseRequest."Source No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse. Jnl.-Register Batch", 'OnBeforeCode', '', true, true)]
    procedure WhseJnlRegBatchOnBeforeCode(VAR WarehouseJournalLine: Record "Warehouse Journal Line"; VAR HideDialog: Boolean; VAR SuppressCommit: Boolean; VAR IsHandled: Boolean)
    begin
        HideDialog := NOT GuiAllowed;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post", 'OnBeforeCode', '', true, true)]
    procedure ItemJnlPostOnBeforeCode(VAR ItemJournalLine: Record "Item Journal Line"; VAR HideDialog: Boolean; VAR SuppressCommit: Boolean; VAR IsHandled: Boolean)

    begin
        HideDialog := NOT GuiAllowed;
    end;



}

