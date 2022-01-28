//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Codeunit EN Shipment Dashboard Mgmt. (ID 14229225).
/// </summary>
codeunit 14229225 "Shipment Mgmt. ELA"
{

    trigger OnRun()
    begin
        //RelenishBin('WH148','','','10102-12');
        //MESSAGE(FORMAT('%1',GetAavailQtyInLoc('00008-02','CASE','WH148')))
    end;

    var
        WhseSetup: Record "Warehouse Setup";
        // ProdLoadRegMgt: Codeunit "Prod. Load Reg. Mgmt.";
        WMServices: Codeunit "WMS Activity Mgmt. ELA";
        WMSLoginMgt: Codeunit "App. Login Mgmt. ELA";
        ENSysUtils: Codeunit "WMS Util ELA";
        ReleaseWhseShipment: Codeunit "Whse.-Shipment Release";
        Window: Dialog;
        TEXT14229200: Label 'Applying Cuts #1#############';
        TTEXT14229201: Label 'Posting Shipments for Document No. #1#############';
        TEXT14229202: Label 'Creating Pick Ticket For Document No. #1#############';
        TEXT14229204: Label 'Adding Orders on Dashboard. Document No. #1###########';
        TEXT14229205: Label 'Do you want to apply cuts on Document No. %1 ? Cuts will update the quantities on Sales Order.';
        TEXT14229206: Label 'Document No. %1 has un-registered Bill of lading %2';
        TEXT14229207: Label 'Do you want to delete Shipment No. %1 ?';
        TEXT14229208: Label 'Document No. %1 Shipment No. %2 Item No. %3 is not marked compeleted. Please check before posting.';
        TEXT14229209: Label 'Item No. %1 on Document No. %2 is already released to pick. To add quantity, please add a new line with location WH148 and release the order. To remove quantity, contact shipping.';
        TEXT14229210: Label 'Item No. %1 on Document No. %2 is already Picked. To add quantity, please add a new line with location WH148 and release the order. You cannot remove this item from this order now.';
        TEXT14229211: Label 'Bill of Lading does not exists for Order No. %1';
        TEXT14229212: Label 'Do you want to print Labels for bulk pick lines?';
        TEXT14229213: Label 'Bill of lading for order %1 is already registered. You cannot make any changes to it.';
        TEXT14229214: Label 'enter message';
        TEXT14229215: Label 'enter message';
        TEXT14229216: Label 'enter message';
        TEXT14229217: Label 'Bill of lading %1 for sales order %2 is already registered';
        TEXT14229218: Label 'Customer %1 is not allowed to do multiple shipments';
        RelSalesDoc: Codeunit "Release Sales Document";
        ReleaseTransferDoc: Codeunit "Release Transfer Document";
        LocCode: Code[20];

    procedure "--Shipment"()
    begin
    end;

    /// <summary>
    /// CreateWHShipment.
    /// </summary>
    /// <param name="SalesHeader">Record "Sales Header".</param>
    /// <param name="WhseShipHdr">VAR Record "Warehouse Shipment Header".</param>
    procedure CreateWHShipment(SalesHeader: Record "Sales Header"; var WhseShipHdr: Record "Warehouse Shipment Header")
    var
        WhseRqst: Record "Warehouse Request";
        // WhseShipHdr: Record "Warehouse Shipment Header";
        WHseshiphdr2: record "warehouse shipment header" temporary;
        WhseShipLine: record "Warehouse shipment Line";
        GetSourceDocuments: Report "Get Source Documents";
        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
    // SalesDBMgt: Codeunit "Sales Dashboard Mgmt.";
    begin
        if SalesHeader.Status = SalesHeader.Status::Open then
            RelSalesDoc.Run(SalesHeader);

        WhseRqst.SetRange(Type, WhseRqst.Type::Outbound);
        WhseRqst.SetRange("Source Type", DATABASE::"Sales Line");
        WhseRqst.SetRange("Source Subtype", SalesHeader."Document Type");
        WhseRqst.SetRange("Source No.", SalesHeader."No.");
        WhseRqst.SetRange("Document Status", WhseRqst."Document Status"::Released);
        if WhseRqst.FindFirst then begin
            GetSourceDocuments.SetHideDialog(true);
            GetSourceDocuments.UseRequestPage(false);
            GetSourceDocuments.SetTableView(WhseRqst);
            GetSourceDocuments.RunModal;
            GetSourceDocuments.GetLastShptHeader(WhseShipHdr);

            if (WhseShipHdr."No." = '') then begin
                WhseShipLine.reset;
                whseshipline.setrange("Source No.", SalesHeader."No.");
                if whseshipline.findset then begin

                    repeat
                        if not whseshiphdr2.get(whseshipline."Source No.") then begin
                            WHseshiphdr2.init;
                            WHseshiphdr2."No." := WhseShipLine."No.";
                            whseshiphdr2.insert;
                            whseshiphdr.get(whseshiphdr2."No.");
                            AddToShipmentDashbrd(WhseShipHdr);
                        end;

                    until whseshipline.next = 0;
                end;
            end;
            // GetSourceDocOutbound.CreateFromSalesOrderHideDialog(SalesHeader);
            // GetSourceDocOutbound.GetOutboundDocs(WhseShipHdr);
        end;

        // AddToShipmentDashbrd(WhseShipHdr);
        //CreateProdSalesOrder(SalesHeader."No."); //tbr
    end;

    /// <summary>
    /// AddApprovedOrders.
    /// </summary>
    procedure AddApprovedOrders()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ShipDashBrd: Record "Shipment Dashboard ELA";
        WsheShipHdr: Record "Warehouse Shipment Header";
        WsheShipLine: Record "Warehouse Shipment Line";
    begin
        WsheShipHdr.Reset;
        if WsheShipHdr.FindSet then
            repeat
                ShipDashBrd.Reset;
                ShipDashBrd.SetRange("Shipment No.", WsheShipHdr."No.");
                ShipDashBrd.SetRange(Level, 0);
                if not ShipDashBrd.FindFirst then begin
                    AddToShipmentDashbrd(WsheShipHdr);
                    ChangeWHShipmentStatus(WsheShipHdr."No.", 1);
                end;

            until WsheShipHdr.Next = 0;
    end;

    /// <summary>
    /// AddToShipmentDashbrd.
    /// </summary>
    /// <param name="WsheShipHdr">Record "Warehouse Shipment Header".</param>
    procedure AddToShipmentDashbrd(WsheShipHdr: Record "Warehouse Shipment Header")
    var
        SalesLine: Record "Sales Line";
        SalesHeader: record "Sales Header";
        WsheShipLine: Record "Warehouse Shipment Line";
        ShipDashBrd: Record "Shipment Dashboard ELA";
        ShipDashBrdLine: Record "Shipment Dashboard ELA";
        WMSRole: Record "App. Role ELA";
        WhseRqst: Record "Warehouse Request";
        ShipToName: Text[50];
        CurrParentID: Integer;
        AvailableQty: Decimal;
        MaxUOMQty: Decimal;
    begin
        Clear(ShipToName);
        Clear(CurrParentID);


        //<<EN1.73
        IF WsheShipHdr."Trip No. ELA" <> '' THEN
            ShipDashBrd.SETRANGE("Trip No.", WsheShipHdr."Trip No. ELA")
        ELSE //>>EN1.73
            ShipDashBrd.SETRANGE("Shipment No.", WsheShipHdr."No.");
        IF ShipDashBrd.FINDFIRST THEN
            CurrParentID := ShipDashBrd.ID
        ELSE BEGIN
            ShipDashBrd.Init;
            ShipDashBrd.ID := 0;
            ShipDashBrd.Level := 0;

            ShipDashBrd."Shipment No." := WsheShipHdr."No.";
            ShipDashBrd."Shipment Date" := WsheShipHdr."Shipment Date";
            ShipDashBrd.Location := WsheShipHdr."Location Code";
            ShipDashBrd."Last Updated" := CurrentDateTime;
            ShipDashBrd."External Doc. No." := WsheShipHdr."External Document No.";
            // ShipDashBrd.Status := WsheShipHdr.Status;
            ShipDashBrd."Shipment Method Code" := WsheShipHdr."Shipment Method Code";
            ShipDashBrd."Trip No." := WsheShipHdr."Trip No. ELA";
            if ShipDashBrd.Insert then begin
                CurrParentID := ShipDashBrd.ID;
                ShipDashBrd."Parent ID" := CurrParentID;
                ShipDashBrd.Modify;
            end;
        end;

        WsheShipLine.Reset;
        WsheShipLine.SetRange(WsheShipLine."No.", WsheShipHdr."No.");
        if WsheShipLine.FindSet then begin
            SalesHeader.get(SalesHeader."Document Type"::Order, WsheShipLine."Source No.");
            repeat
                ShipDashBrdLine.Reset;
                ShipDashBrdLine.SetRange(Level, 1);
                ShipDashBrdLine.SetRange("Shipment No.", WsheShipLine."No.");
                ShipDashBrdLine.SetRange("Shipment Line No.", WsheShipLine."Line No.");
                if not ShipDashBrdLine.FindFirst then begin
                    ShipDashBrdLine.Init;
                    ShipDashBrdLine.ID := 0;
                    ShipDashBrdLine.Level := 1;
                    ShipDashBrdLine."Parent ID" := CurrParentID;
                    ShipDashBrdLine."Shipment No." := WsheShipLine."No.";
                    ShipDashBrdLine."Shipment Line No." := WsheShipLine."Line No.";
                    ShipDashBrdLine."Destination No." := SalesHeader."Sell-to Customer No.";
                    ShipDashBrdLine."Ship-to Name" := WsheShipLine."Source Ship-to ELA";
                    ShipDashBrdLine."External Doc. No." := WsheShipHdr."External Document No.";
                    ShipDashBrdLine."Source No." := WsheShipLine."Source No.";
                    ShipDashBrdLine."Source Line No." := WsheShipLine."Source Line No.";
                    ShipDashBrdLine."Source Type" := WsheShipLine."Source Type";
                    ShipDashBrdLine."Source Subtype" := WsheShipLine."Source Subtype";
                    ShipDashBrdLine."Source Document" := WsheShipLine."Source Document";
                    ShipDashBrdLine."Ship-to Code" := SalesHeader."Ship-to Code";
                    ShipDashBrdLine."Ship-to Name" := SalesHeader."Ship-to Name";
                    ShipDashBrdLine."Ship-to Address" := SalesHeader."Ship-to Address";
                    ShipDashBrdLine."Ship-to Address 2" := SalesHeader."Ship-to Address 2";
                    ShipDashBrdLine."Ship-to City" := SalesHeader."Ship-to City";
                    ShipDashBrdLine."Ship-to State" := SalesHeader."Ship-to County";
                    ShipDashBrdLine."Ship-to Zip Code" := SalesHeader."Ship-to Post Code";
                    ShipDashBrdLine."Ship-to Country" := SalesHeader."Ship-to Country/Region Code";
                    ShipDashBrdLine."Ship-to Contact" := SalesHeader."Ship-to Contact";
                    ShipDashBrdLine."Shipment Date" := WsheShipHdr."Shipment Date";
                    ShipDashBrdLine."Item No." := WsheShipLine."Item No.";
                    ShipDashBrdLine."Item Description" := WsheShipLine.Description;
                    ShipDashBrdLine."Unit of Measure Code" := WsheShipLine."Unit of Measure Code";
                    ShipDashBrdLine."Qty. Reqd." := WsheShipLine.Quantity;
                    ShipDashBrdLine.Completed := false;
                    ShipDashBrdLine.Location := WsheShipLine."Location Code";
                    ShipDashBrdLine."Trip No." := WsheShipHdr."Trip No. ELA";
                    // ShipDashBrdLine."Assigned Role" := GetShipmentRole(WsheShipLine."Item No.",
                    // WsheShipLine."Unit of Measure Code", WsheShipLine.Quantity); //<<EN1.05 //tbr
                    // ShipDashBrdLine."Receive To Pick" := WsheShipLine."Receive To Pick"; //<<EN1.11 //tbr
                    ShipDashBrdLine.Insert(true);
                    AvailableQty := GetQuantityAvailable(ShipDashBrdLine);
                    ShipDashBrdLine."Qty. Avail." := AvailableQty;
                    ShipDashBrdLine.Modify;
                end;
            until WsheShipLine.Next = 0;

            ShipDashBrd."Source Type" := ShipDashBrdLine."Source Type";
            ShipDashBrd."Source Subtype" := ShipDashBrdLine."Source Subtype";
            ShipDashBrd."Source Document" := ShipDashBrdLine."Source Document";
            ShipDashBrd.Modify;
        end;

        //<<EN1.08
        ShipDashBrd.Reset;
        ShipDashBrd.SetRange("Shipment No.", '');
        ShipDashBrd.DeleteAll;
        //>>EN1.08
    end;


    procedure RemoveOrderFromShipmentDashBrd(OrderNo: Code[20]; ShipmentNo: Code[20])
    var
        WHShipmentHdr: Record "Warehouse Shipment Header";
        WHShipmentLine: Record "Warehouse Shipment Line";
        ShipDashbrd: Record "Shipment Dashboard ELA";
        ShipDashbrd2: Record "Shipment Dashboard ELA";
    begin
        //<<EN1.08
        ChangeWHShipmentStatus(ShipmentNo, 0);
        if WHShipmentHdr.Get(ShipmentNo) then begin
            WHShipmentLine.Reset;
            WHShipmentLine.SetRange("No.", WHShipmentHdr."No.");
            if WHShipmentLine.FindSet then
                repeat
                    if WHShipmentLine."Qty. Outstanding" = 0 then
                        WHShipmentLine.Delete;
                until WHShipmentLine.Next = 0;

            WHShipmentLine.Reset;
            WHShipmentLine.SetRange("No.", WHShipmentHdr."No.");
            if not WHShipmentLine.FindFirst then
                WHShipmentHdr.Delete(true)
            else
                Error('pending shipment lines exist');
        end;
        //>>EN1.08

        //<<EN1.15
        ShipDashbrd.Reset;
        ShipDashbrd.SetRange(Level, 1);
        ShipDashbrd.SetRange("Source No.", OrderNo);
        ShipDashbrd.SetRange("Shipment No.", ShipmentNo);
        //ShipDashbrd.SETRANGE(Completed,TRUE);
        ShipDashbrd.DeleteAll;

        ShipDashbrd2.Reset;
        ShipDashbrd2.SetRange(Level, 1);
        ShipDashbrd2.SetRange("Source No.", OrderNo);
        ShipDashbrd2.SetFilter("Shipment No.", '<>%1', ShipmentNo);
        if not ShipDashbrd2.FindFirst then begin
            ShipDashbrd2.Reset;
            //ShipDashbrd2.SETRANGE(Level,0);
            ShipDashbrd2.SetRange("Source No.", OrderNo);
            ShipDashbrd2.DeleteAll;
        end;
        Commit;
        //>>EN1.15
    end;

    /// <summary>
    /// DeleteWHShipmentInfo.
    /// </summary>
    /// <param name="ShipmentNo">Code[20].</param>
    procedure DeleteWHShipmentInfo(ShipmentNo: Code[20])
    var
        ShipDashbrd: Record "Shipment Dashboard ELA";
        WHShipment: Record "Warehouse Shipment Header";
        WHShipmentLine: Record "Warehouse Shipment Line";
    // BillOfLadingHdr: Record "Bill of Lading Header";
    begin
        if Confirm(TEXT14229207, false, ShipmentNo) then begin
            DeleteWHShipDoc(ShipmentNo);
            ShipDashbrd.Reset;
            ShipDashbrd.SetRange("Shipment No.", ShipmentNo);
            if ShipDashbrd.FindSet then begin
                repeat
                    if ShipDashbrd.Delete then;
                until ShipDashbrd.Next = 0;
            end;
        end;
    end;

    local procedure DeleteWHShipDoc(ShipmentNo: Code[20])
    var
        WHShipHdr: Record "Warehouse Shipment Header";
    begin
        ChangeWHShipmentStatus(ShipmentNo, 0);
        if WHShipHdr.Get(ShipmentNo) then begin
            WHShipHdr.Delete(true);
        end;
    end;

    local procedure DeleteShipDashboard()
    begin
    end;

    procedure CleanupPostedDocs(var TmpWhseShipList: Record "Warehouse Shipment Header" temporary)
    var
        SalesHdr: Record "Sales Header";
        WhseShipHdr: Record "Warehouse Shipment Header";
        WhseShipLine: Record "Warehouse Shipment Line";
        ShipDashbrd: Record "Shipment Dashboard ELA";
        DontDelete: Boolean;
    begin
        //<<EN1.33
        TmpWhseShipList.Reset;
        if TmpWhseShipList.FindSet then
            repeat
                if WhseShipHdr.Get(TmpWhseShipList."No.") then begin
                    DontDelete := false;
                    WhseShipLine.Reset;
                    WhseShipLine.SetRange("No.", WhseShipHdr."No.");
                    if WhseShipLine.FindSet then
                        repeat
                            if WhseShipLine."Qty. Outstanding" <> 0 then
                                DontDelete := true;
                        until WhseShipLine.Next = 0;

                    if not DontDelete then begin
                        CleanupWHShipments(TmpWhseShipList."No.");
                        // CleanupShipmentDashbrd(TmpWhseShipList."Source Order No.", TmpWhseShipList."No.");
                    end;
                end;
            // end else
            //  tbr
            // CleanupShipmentDashbrd(TmpWhseShipList."Source Order No.", TmpWhseShipList."No.");
            until TmpWhseShipList.Next = 0;
        //>>EN1.33
    end;

    procedure CleanupWHShipments(ShipmentNo: Code[20])
    var
        WhseShipHdr: Record "Warehouse Shipment Header";
    begin
        //<<EN1.33
        if WhseShipHdr.Get(ShipmentNo) then begin
            ChangeWHShipmentStatus(ShipmentNo, 0);
            if WhseShipHdr.Delete(true) then;
        end;
        //>>EN1.33
    end;

    /// <summary>
    /// DeleteShipmentFromShipmentManagement.
    /// </summary>
    /// <param name="WarehouseShipmentLine">record "Warehouse Shipment Line".</param>
    procedure DeleteShipmentFromShipmentManagement(WarehouseShipmentLine: record "Warehouse Shipment Line")
    var
        ShipmentDashBrd: Record "Shipment Dashboard ELA";
    begin
        ShipmentDashBrd.reset;
        ShipmentDashBrd.SetRange("Shipment No.", WarehouseShipmentLine."No.");
        ShipmentDashBrd.SetRange("Shipment Line No.", WarehouseShipmentLine."Line No.");
        ShipmentDashBrd.SetRange("Source No.", WarehouseShipmentLine."Source No.");
        ShipmentDashBrd.SetRange("Source Line No.", WarehouseShipmentLine."Source Line No.");
        if ShipmentDashBrd.FindSet() then
            ShipmentDashBrd.Delete();

        ShipmentDashBrd.reset;
        ShipmentDashBrd.SetRange(Level, 1);
        ShipmentDashBrd.SetRange("Shipment No.", WarehouseShipmentLine."No.");
        if ShipmentDashBrd.Count = 0 then begin
            ShipmentDashBrd.reset;
            ShipmentDashBrd.SetRange(Level, 0);
            ShipmentDashBrd.SetRange("Shipment No.", WarehouseShipmentLine."No.");
            ShipmentDashBrd.DeleteAll();
        end;
    end;

    procedure CleanupShipmentDashbrd(SalesOrderNo: Code[20]; ShipmentNo: Code[20])
    var
        ShipDashbrd: Record "Shipment Dashboard ELA";
    begin
        //<<EN1.33
        ShipDashbrd.Reset;
        ShipDashbrd.SetRange(Level, 1);
        ShipDashbrd.SetRange("Source No.", SalesOrderNo);
        if ShipmentNo <> '' then
            ShipDashbrd.SetRange("Shipment No.", ShipmentNo);

        ShipDashbrd.DeleteAll;

        /*
        ShipDashbrd.RESET;
        ShipDashbrd.SETRANGE(Level,1);
        ShipDashbrd.SETRANGE("Source No.",SalesOrderNo);
        ShipDashbrd.SETFILTER("Shipment No.",'<>%1',ShipmentNo);
        IF NOT ShipDashbrd.FINDFIRST THEN BEGIN
          ShipDashbrd.RESET;
          ShipDashbrd.SETRANGE("Source No.",SalesOrderNo);
          ShipDashbrd.DELETEALL;
        END;
        */

        ShipDashbrd.Reset;
        ShipDashbrd.SetRange(Level, 1);
        ShipDashbrd.SetRange("Source No.", SalesOrderNo);
        //ShipDashbrd.SETFILTER("Shipment No.",'<>%1',ShipmentNo);
        if not ShipDashbrd.FindFirst then begin
            ShipDashbrd.Reset;
            ShipDashbrd.SetRange("Source No.", SalesOrderNo);
            ShipDashbrd.DeleteAll;
        end;
        //>>EN1.33

    end;

    procedure ResetSDBShipment(ShipmentNo: Code[20]; ShipmentLineNo: Integer; OrderNo: Code[20])
    var
        ShipDashBrd: Record "Shipment Dashboard ELA";
    begin
        ShipDashBrd.Reset;
        ShipDashBrd.SetRange("Shipment No.", ShipmentNo);
        ShipDashBrd.SetRange("Shipment Line No.", ShipmentLineNo);
        ShipDashBrd.SetRange(Completed, false);
        if ShipDashBrd.FindFirst then
            if ShipDashBrd."Full Pick" then begin
                // ShipDashBrd.Validate(Status, ShipDashBrd.Status::Open);
                ShipDashBrd.Validate("Full Pick", false);
                ShipDashBrd.Modify;
            end;

        ShipDashBrd.Reset;
        ShipDashBrd.SetRange("Shipment No.", OrderNo); //1.37
        ShipDashBrd.SetRange(Level, 0);
        ShipDashBrd.SetRange("Full Pick", true);
        ShipDashBrd.SetRange(Completed, false);
        if ShipDashBrd.FindFirst then begin
            ShipDashBrd.Validate("Full Pick", false);
            ShipDashBrd.Modify;
        end;
    end;

    procedure ChangeWHShipmentStatus(ShipmentNo: Code[20]; SetStatus: Option Open,Released)
    var
        WhseShipHdr: Record "Warehouse Shipment Header";
    begin
        //<<EN1.07
        if WhseShipHdr.Get(ShipmentNo) then begin
            case SetStatus of
                SetStatus::Open:
                    //IF WhseShipHdr.Status <> WhseShipHdr.Status::Open THEN
                    ReleaseWhseShipment.Reopen(WhseShipHdr);
                SetStatus::Released:
                    //IF WhseShipHdr.Status <> WhseShipHdr.Status::Released THEN
                    ReleaseWhseShipment.Release(WhseShipHdr);
            end;
        end;
        //>>EN1.07
    end;

    procedure ApplyCutQty(WhseShipNo: Code[20]; UserCode: Code[20])
    var
        ShipDashbrd: Record "Shipment Dashboard ELA";
    begin
        ShipDashbrd.Reset;
        ShipDashbrd.SetRange(Select, true);
        // ShipDashbrd.SetRange("Source No.", OrderNo);
        ShipDashbrd.setrange("Shipment No.", WhseShipNo);
        ShipDashbrd.SetRange("Locked By User ID", UserCode);
        ShipDashbrd.SetRange("Ship Action", ShipDashbrd."Ship Action"::Cut);
        ShipDashbrd.SetRange(Completed, false);
        ShipDashbrd.SetRange(ShipDashbrd."Full Pick", false);
        if ShipDashbrd.FindSet then
            if Confirm(StrSubstNo(TEXT14229205, ShipDashbrd."Source No."), false) then begin
                repeat
                    Window.Open(TEXT14229200);
                    Window.Update(1, ShipDashbrd."Source No." + ' Line No. ' + Format(ShipDashbrd."Source Line No."));
                    Window.Close;
                    ShipDashbrd.Validate("Qty. To Ship");

                    if ShipDashbrd."Qty. To Ship" = 0 then begin
                        ShipDashbrd.Validate(Completed, true);
                        ShipDashbrd.Modify;
                    end;

                until ShipDashbrd.Next = 0;
            end;
    end;

    procedure ApplyBulkCutQty(WhseShipNo: Code[20]; TripID: Code[20]; UserCode: Code[20])
    var
        ShipDashbrd: Record "Shipment Dashboard ELA";
    begin
        ShipDashbrd.Reset;
        IF TripID <> '' then
            ShipDashbrd.setrange("Trip No.", TripID)
        else
            ShipDashbrd.setrange("Shipment No.", WhseShipNo);
        ShipDashbrd.SetRange(Select, true);
        if ShipDashbrd.FindSet then
            if Confirm(StrSubstNo(TEXT14229205, ShipDashbrd."Source No."), false) then begin
                repeat
                    ShipDashbrd."Ship Action" := ShipDashbrd."Ship Action"::Cut;
                    ShipDashbrd.ApplyShipAction(false);
                    ShipDashbrd.Modify();


                until ShipDashbrd.Next = 0;
            end;

    end;

    /// <summary>
    /// DeleteOrphanLines.
    /// </summary>
    /// <param name="ShipmentDashbord">Record "EN Shipment Dashboard".</param>
    procedure DeleteOrphanLines(ShipmentDashbord: Record "Shipment Dashboard ELA")
    var
        WhseShipHdr: Record "Warehouse Shipment Header";
        ReleaseWhseShipment: Codeunit "Whse.-Shipment Release";
        WhseShipLine: Record "Warehouse Shipment Line";
        OrigWhseShipmentStatus: Option Open,Released;
    begin
        WhseShipHdr.Get(ShipmentDashbord."Shipment No.");
        OrigWhseShipmentStatus := WhseShipHdr.Status;
        if WhseShipHdr.Status = WhseShipHdr.Status::Released then
            ReleaseWhseShipment.Reopen(WhseShipHdr);

        if WhseShipLine.Get(ShipmentDashbord."Shipment No.", ShipmentDashbord."Shipment Line No.") then
            WhseShipLine.Delete;

        ReleaseWhseShipment.Release(WhseShipHdr);
    end;

    procedure PostWHShipments(SalesOrderNo: Code[20]; DoPostInvoice: Boolean)
    var
        WhseShipHdr: Record "Warehouse Shipment Header";
        TmpWhseShipHdr: Record "Warehouse Shipment Header" temporary;
        WhseShipLine: Record "Warehouse Shipment Line";
        ShipDashbrd: Record "Shipment Dashboard ELA";
        ShipDashbrd2: Record "Shipment Dashboard ELA";
        // BillOfLadHdr: Record "Bill of Lading Header";
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        SalesPostYN: Codeunit "Sales-Post (Yes/No)";
        SkipWeekendPosting: Boolean;
        NewPostingDate: Date;
        IsICCustomer: Boolean;
        ShipDate: Date;
        RespCode: Code[10];
        NextPostingDate: Date;
        ICPartnerCode: Code[10];
        CurrWeekNo: Integer;
        NewPostingWeekNo: Integer;
        CurrYear: Integer;
        NewPostingyear: Integer;
        DoPost: Boolean;
    begin
        //<<EN1.12
        ShipDashbrd.Reset;
        ShipDashbrd.SetRange(Select, true);
        ShipDashbrd.SetRange(Level, 1);
        ShipDashbrd.SetRange("Source No.", SalesOrderNo);
        ShipDashbrd.SetRange(Completed, false);
        if ShipDashbrd.FindFirst then
            Error(StrSubstNo(TEXT14229208, ShipDashbrd."Source No.", ShipDashbrd."Shipment No.", ShipDashbrd."Item No."));
        //>>EN1.12

        //<<EN1.15 + EN1.31
        WhseShipHdr.Reset;
        //ShipDashbrd.SETRANGE(Select,TRUE); //<<EN1.17
        // WhseShipHdr.SetRange("Source Order No.", SalesOrderNo);
        if WhseShipHdr.FindSet then
            repeat
                if not TmpWhseShipHdr.Get(WhseShipHdr."No.") then begin
                    TmpWhseShipHdr.Init;
                    TmpWhseShipHdr."No." := WhseShipHdr."No.";
                    // TmpWhseShipHdr."Source Order No." := WhseShipHdr."Source Order No.";
                    TmpWhseShipHdr."Posting Date" := WhseShipHdr."Posting Date";
                    TmpWhseShipHdr.Insert;
                end;
            until WhseShipHdr.Next = 0
        else
            CleanupShipmentDashbrd(SalesOrderNo, '');

        //>>EN1.31
        TmpWhseShipHdr.Reset;
        if TmpWhseShipHdr.FindSet then
            repeat
                if WhseShipHdr.Get(TmpWhseShipHdr."No.") then begin
                    CleanupPostedDocs(TmpWhseShipHdr);
                    WhseShipHdr.CalcFields("Completely Picked");
                    if WhseShipHdr."Completely Picked" then begin
                        // PostShipDoc(WhseShipHdr."Source Order No.", WhseShipHdr."No.");
                        // DeleteFromShipmentDashBrd(WhseShipHdr."Source Order No.", WhseShipHdr."No.");
                    end;
                end;
            //>>EN1.31
            until TmpWhseShipHdr.Next = 0;
        //>>EN1.15

        WhseSetup.Get;
        /*
        tbr
        if WhseSetup."Post Invoice with Shipment" and DoPostInvoice then begin
            WhseShipHdr.Reset;
            WhseShipHdr.SetRange("Source Order No.", SalesOrderNo);
            if not WhseShipHdr.FindFirst then begin
                //tbr
                // BillOfLadHdr.Reset;
                // BillOfLadHdr.SetRange("Sales Order No.", SalesOrderNo);
                // if BillOfLadHdr.FindSet then
                //     //<<EN1.54
                //     repeat
                //         if BillOfLadHdr.Status <> BillOfLadHdr.Status::Registered then
                //             exit;
                //     until BillOfLadHdr.Next = 0;
                //>>EN1.54
                //<<EN1.34
                if SalesHeader.Get(SalesHeader."Document Type"::Order, SalesOrderNo) then
                    if Customer.Get(SalesHeader."Sell-to Customer No.") then begin
                        if Customer."Do not Auto Post" then
                            exit;
                        SkipWeekendPosting := false;
                        if Customer."Skip Weekend for Auto Posting" then
                            SkipWeekendPosting := true;
                        //<<EN1.36
                        //CurrPostingDate := GetNextPostingDate(SalesHeader."Shipment Date",SkipWeekendPosting);
                        ShipDate := SalesHeader."Shipment Date";
                        //IF SalesHeader."Posting Date" > SalesHeader."Shipment Date" THEN
                        //  NewPostingDate := SalesHeader."Posting Date"
                        //ELSE
                        NewPostingDate := SalesHeader."Shipment Date";
                        RespCode := SalesHeader."IC Source Ship-to";
                        if SalesHeader."IC Source Ship-to" <> '' then
                            IsICCustomer := true;
                        ICPartnerCode := SalesHeader."IC Source Partner";
                        NewPostingDate := ENSysUtils.GetNextPostingDate(SalesHeader."Sell-to Customer No.", RespCode, ShipDate, NewPostingDate,
                          IsICCustomer, ICPartnerCode);
                        //skip back date posting.
                        CurrWeekNo := Date2DWY(Today, 2);
                        NewPostingWeekNo := Date2DWY(NewPostingDate, 2);
                        CurrYear := Date2DWY(Today, 3);
                        NewPostingyear := Date2DWY(NewPostingDate, 3);
                        DoPost := false;
                        if (NewPostingWeekNo >= CurrWeekNo) and (NewPostingyear = CurrYear) then
                            DoPost := true
                        else
                            if NewPostingyear > CurrYear then
                                DoPost := true
                            else
                                DoPost := false;
                        //message('New Posting date %1 Posting: %2',Newpostingdate,dopost);
                        if not DoPost then
                            exit;
                        //IF NewPostingDate > SalesHeader."Posting Date" THEN BEGIN
                        SalesHeader.Validate("Posting Date", NewPostingDate);
                        SalesHeader.Modify(true);
                        //END;
                        //IF SalesHeader."Posting Date" < TODAY THEN
                        //EXIT;
                        //>>EN1.36
                        if SalesHeader.Status = SalesHeader.Status::Released then
                            CODEUNIT.Run(CODEUNIT::"Sales-Post (Yes/No)", SalesHeader);
                    end;
                //>>EN1.33 + EN1.34
            end;
            */
        // end;
        //>>EN1.31

        // CleanupPostedDocs(TmpWhseShipHdr);
    end;

    procedure CheckForRegBillOfLading(SalesOrderNo: Code[20])
    var
    // BillOfLadingHdr: Record "Bill of Lading Header";
    begin
        //tbr
        //<<EN1.15
        // BillOfLadingHdr.Reset;
        // BillOfLadingHdr.SetRange("Sales Order No.", SalesOrderNo);
        // //<<EN1.52
        // if BillOfLadingHdr.FindSet then begin
        //     BillOfLadingHdr.SetFilter(BillOfLadingHdr.Status, '<>%1', BillOfLadingHdr.Status::Registered);
        //     if BillOfLadingHdr.FindFirst then
        //         Error(TEXT006, SalesOrderNo, BillOfLadingHdr."No.");
        //     //>>EN1.52
        // end else
        //     Error(TEXT011, SalesOrderNo);
        //>>EN1.15
    end;

    local procedure PostShipDoc(OrderNo: Code[20]; ShipmentNo: Code[20])
    var
        WhseShipLine: Record "Warehouse Shipment Line";
        ShipDashbrd: Record "Shipment Dashboard ELA";
        ShipDashbrd2: Record "Shipment Dashboard ELA";
        // BillOfLadHdr: Record "Bill of Lading Header";
        WhsePostShipment: Codeunit "Whse.-Post Shipment";
    begin
        //<<En1.15
        Window.Open(TTEXT14229201);
        Window.Update(1, ShipDashbrd."Source No.");
        Window.Close;
        WhseShipLine.Reset;
        WhseShipLine.SetRange("No.", ShipmentNo);
        //<<EN1.17
        if WhseShipLine.FindFirst then begin
            WhsePostShipment.SetPostingSettings(false);
            WhsePostShipment.SetPrint(false);
            WhsePostShipment.Run(WhseShipLine);
            Clear(WhsePostShipment);
        end;
        //>>EN1.15 + EN1.17
    end;

    procedure CreateDeliveryLoadHdr(OrderNo: Code[20]; LocationCode: Code[10]): Code[20]
    var
        // DeliverLoadHdr: Record "Delivery Load Header";
        AllowMultipleShip: Boolean;
        LoadCount: Integer;
        SalesHdr: Record "Sales Header";
        Customer: Record Customer;
    begin
        //<<EN1.48
        //tbr
        // AllowMultipleShip := false;
        // if SalesHdr.Get(SalesHdr."Document Type"::Order, OrderNo) then begin
        //     Customer.Get(SalesHdr."Sell-to Customer No.");
        //     AllowMultipleShip := Customer."Allow multiple shipments/order";

        //     DeliverLoadHdr.Reset;
        //     DeliverLoadHdr.SetRange("Load Type", DeliverLoadHdr."Load Type"::"Shipment Load");
        //     DeliverLoadHdr.SetRange("Source Document Type", DeliverLoadHdr."Source Document Type"::"Sales Order");
        //     DeliverLoadHdr.SetRange("Source Document No.", OrderNo);
        //     if DeliverLoadHdr.Find('-') then begin
        //         if (DeliverLoadHdr.Count > 1) and not AllowMultipleShip then
        //             Error(StrSubstNo(TXT50010, Customer."No."))
        //         else
        //             exit(DeliverLoadHdr."Load ID");
        //     end else begin
        //         DeliverLoadHdr.Init;
        //         DeliverLoadHdr.Validate("Load Type", DeliverLoadHdr."Load Type"::"Shipment Load");
        //         DeliverLoadHdr.Insert(true);
        //         DeliverLoadHdr.Validate("Source Document Type", DeliverLoadHdr."Source Document Type"::"Sales Order");
        //         DeliverLoadHdr.Validate("Source Document No.", OrderNo);
        //         ;
        //         DeliverLoadHdr.Validate("Source Location", LocationCode); //EN1.53
        //         DeliverLoadHdr."Created On" := CurrentDateTime;
        //         DeliverLoadHdr."Created By" := UserId;
        //         DeliverLoadHdr.Modify;
        //         exit(DeliverLoadHdr."Load ID");   //EN1.x 7/6
        //     end;
        // end else
        //     Error('Sales header not exists');
        // //>>EN1.48
    end;

    // procedure "--Util"()
    // begin
    // end;

    // procedure UseShipmentBoard(): Boolean
    // var
    //     WhseSetup: Record "Warehouse Setup";
    // begin
    //     //<<EN1.07
    //     WhseSetup.Get;
    //     // exit(WhseSetup."Enable WMS System");
    //     //>>EN1.07
    // end;

    procedure GetQuantityAvailable(ShipDashbrd: Record "Shipment Dashboard ELA"): Decimal
    var
        Item: Record Item;
        Location: Record Location;
        ItemLedgEntry: Record "Item Ledger Entry";
        ShipDashbrd2: Record "Shipment Dashboard ELA";
        // WMSMgt: Codeunit "WMS Management";
        QtyAllocated: Decimal;
        ILEQty: Decimal;
        QtyFound: Decimal;
    begin
        //<<EN1.12
        // WhseSetup.Get;
        // if WhseSetup."Use Receive To Pick On Pick" and
        //    ShipDashbrd."Receive To Pick"
        // then begin
        // QtyFound := CheckIfProdSalesOrderRevd(ShipDashbrd."Source No.", ShipDashbrd."Item No.");
        //<<EN1.26
        if QtyFound = 0 then begin
            Location.Get(ShipDashbrd.Location);
            // if not Location."Ship Assigned Prod. Sales Ord." then
            QtyFound := GetAavailQtyInLoc(ShipDashbrd."Item No.", ShipDashbrd."Unit of Measure Code", ShipDashbrd.Location);
        end;
        //>>EN1.26
        exit(QtyFound);
        // end;
        //>>EN1.12

        exit(GetAavailQtyInLoc(ShipDashbrd."Item No.", ShipDashbrd."Unit of Measure Code", ShipDashbrd.Location)); //<<EN1.10
    end;

    procedure GetAavailQtyInLoc(ItemNo: Code[20]; ItemUOM: Code[10]; LocationCode: Code[10]): Decimal
    var
        Item: Record Item;
        Location: Record Location;
        WhseEntry: Record "Warehouse Entry";
        QtyInWhseBase: Decimal;
        QtyInWhse: Decimal;
        QtyOnPickBinsBase: Decimal;
        QtyOnPickBins: Decimal;
        QtyOnOutboundBinsBase: Decimal;
        SubTotalBase: Decimal;
        SubTotal: Decimal;
        QtyReservedOnPickShipBase: Decimal;
        QtyReservedOnPickShip: Decimal;
        LineReservedQtyBase: Decimal;
        LineReservedQty: Decimal;
        TotalAvailQtyBase: Decimal;
        BinContent: Record "Bin Content";
        TotalBinQty: Decimal;
        ToBeRecvd: Decimal;
        ToBeShipped: Decimal;
    begin
        Item.Get(ItemNo);
        Location.Get(LocationCode);
        TotalBinQty := 0;
        BinContent.Reset;
        BinContent.SetRange("Location Code", LocationCode);
        BinContent.SetRange("Item No.", ItemNo);
        BinContent.SetRange("Unit of Measure Code", ItemUOM);
        if BinContent.FindSet then begin
            repeat
                TotalBinQty := TotalBinQty + BinContent.CalcQtyAvailToPickUOM();
            until BinContent.Next = 0;

            //todo #7 @Kamranshehzad revise thisfunction.
            // use ship/receive bin flag is better option for now it should work. (incase if you need to have multiple ship/rec bins)
            ToBeRecvd := GetAavailQtyInBin(ItemNo, ItemUOM, LocationCode, Location."Receipt Bin Code");
            ToBeShipped := GetAavailQtyInBin(ItemNo, ItemUOM, LocationCode, Location."Shipment Bin Code");
            TotalBinQty := TotalBinQty - ToBeRecvd - ToBeShipped;
        end;
        exit(TotalBinQty);
    end;


    /// <summary>
    /// GetAavailQtyInBin.
    /// </summary>
    /// <param name="ItemNo">Code[20].</param>
    /// <param name="ItemUOM">Code[10].</param>
    /// <param name="LocationCode">Code[10].</param>
    /// <param name="BinCode">Code[20].</param>
    /// <returns>Return value of type Decimal.</returns>
    procedure GetAavailQtyInBin(ItemNo: Code[20]; ItemUOM: Code[10]; LocationCode: Code[10]; BinCode: Code[20]): Decimal
    var
        BinContent: Record "Bin Content";
        TotalQty: Decimal;
    begin
        BinContent.Reset;
        BinContent.SetRange(BinContent."Location Code", LocationCode);
        BinContent.SetRange(BinContent."Bin Code", BinCode);
        BinContent.SetRange(BinContent."Item No.", ItemNo);
        BinContent.SetRange(BinContent."Variant Code", '');
        BinContent.SetRange(BinContent."Unit of Measure Code", ItemUOM);
        if BinContent.FindSet then
            repeat
                TotalQty := TotalQty + BinContent.CalcQtyAvailToPickUOM();
            until BinContent.Next = 0;
        exit(TotalQty);
    end;

    procedure GetAvailableQty(ItemNo: Code[20]; LocationCode: Code[10]): Decimal
    var
        Item: Record Item;
        ItemLedgEntry: Record "Item Ledger Entry";
        ShipDashbrd2: Record "Shipment Dashboard ELA";
        QtyAllocated: Decimal;
        ILEQty: Decimal;
    begin
        ItemLedgEntry.Reset;
        ItemLedgEntry.SetRange("Item No.", ItemNo);
        ItemLedgEntry.SetRange("Drop Shipment", false);
        ItemLedgEntry.SetRange("Location Code", LocationCode);
        if ItemLedgEntry.FindSet then
            repeat
                ILEQty := ILEQty + ItemLedgEntry."Remaining Quantity";
            until ItemLedgEntry.Next = 0;
        exit(ILEQty);
    end;

    procedure GetTotalQtyInLoc(ItemNo: Code[20]; ItemUOM: Code[10]; LocationCode: Code[10]): Decimal
    var
        Item: Record Item;
        Location: Record Location;
        WhseEntry: Record "Warehouse Entry";
        // CreatePick: Codeunit "Create Pick";
        // UOMManagement: Codeunit "Unit of Measure Management";
        QtyInWhseBase: Decimal;
        QtyInWhse: Decimal;
        QtyOnPickBinsBase: Decimal;
        QtyOnPickBins: Decimal;
        QtyOnOutboundBinsBase: Decimal;
        SubTotalBase: Decimal;
        SubTotal: Decimal;
        QtyReservedOnPickShipBase: Decimal;
        QtyReservedOnPickShip: Decimal;
        LineReservedQtyBase: Decimal;
        LineReservedQty: Decimal;
        TotalAvailQtyBase: Decimal;
        BinContent: Record "Bin Content";
        TotalBinQty: Decimal;
        ToBeRecvd: Decimal;
        ToBeShipped: Decimal;
    begin
        //<<EN1.17   + EN1.48
        Item.Get(ItemNo);
        Location.Get(LocationCode);
        TotalBinQty := 0;
        /*   //this is duplicating quantity after key change //EN1.48
        BinContent.RESET;
        BinContent.SETRANGE("Location Code",LocationCode);
        BinContent.SETRANGE("Item No.",ItemNo);
        //BinContent.SETRANGE("Unit of Measure Code",ItemUOM);
        IF BinContent.FINDSET THEN BEGIN
          REPEAT
            TotalBinQty := TotalBinQty + GetTotalQtyInBins(ItemNo,BinContent."Unit of Measure Code",LocationCode,BinContent."Bin Code");
           // Message('Bin no %1 Item no %2 Qty 3',Bincontent."bin code","bincontent"."item no.", TotalBinQty);
          UNTIL BinContent.NEXT = 0;
        
          // use ship/receive bin flag is better option for now it should work. (incase if you need to have multiple ship/rec bins)
          //ToBeRecvd := GetAavailQtyInBin(ItemNo,ItemUOM,LocationCode,Location."Receipt Bin Code");
          //ToBeShipped := GetAavailQtyInBin(ItemNo,wItemUOM,LocationCode,Location."Shipment Bin Code");
          //TotalBinQty := TotalBinQty - ToBeRecvd - ToBeShipped;
          END;
        EXIT(TotalBinQty);
        */
        //>>EN1.17

        BinContent.Reset;
        BinContent.SetRange(BinContent."Location Code", LocationCode);
        BinContent.SetRange(BinContent."Item No.", ItemNo);
        BinContent.SetRange(BinContent."Variant Code", '');
        BinContent.SetFilter("Block Movement", '<>%1&<>%2', BinContent."Block Movement"::Outbound, BinContent."Block Movement"::All);
        //EN1.58
        if ItemUOM <> '' then                                     //EN1.x 03/27/2019
            BinContent.SetRange(BinContent."Unit of Measure Code", ItemUOM);
        if BinContent.FindSet then
            repeat
                TotalBinQty := TotalBinQty + BinContent.CalcQtyUOM()
            until BinContent.Next = 0;
        exit(TotalBinQty);
        //>>EN1.48

    end;

    procedure GetTotalQtyInBins(ItemNo: Code[20]; ItemUOM: Code[10]; LocationCode: Code[10]; BinCode: Code[20]): Decimal
    var
        BinContent: Record "Bin Content";
        QtyInBins: Decimal;
    begin
        //<<EN1.45
        BinContent.Reset;
        BinContent.SetRange(BinContent."Location Code", LocationCode);
        BinContent.SetRange(BinContent."Bin Code", BinCode);
        BinContent.SetRange(BinContent."Item No.", ItemNo);
        BinContent.SetRange(BinContent."Variant Code", '');
        BinContent.SetRange(BinContent."Unit of Measure Code", ItemUOM);
        if BinContent.FindFirst then
            exit(BinContent.CalcQtyUOM());
        //>>EN1.45
    end;

    procedure UpdateAllShipStockInfo()
    var
        ShipDashBrd: Record "Shipment Dashboard ELA";
    begin
        ShipDashBrd.Reset;
        ShipDashBrd.SetRange(Completed, false);
        if ShipDashBrd.FindSet then
            repeat
                UpdateShipStockInfo(ShipDashBrd);
            until ShipDashBrd.Next = 0;
    end;

    procedure UpdateShipStockInfo(ShipDashbrd: Record "Shipment Dashboard ELA")
    var
        AvailableQty: Decimal;
    begin
        AvailableQty := GetQuantityAvailable(ShipDashbrd);
        ShipDashbrd."Qty. Avail." := AvailableQty;
        if AvailableQty >= ShipDashbrd."Qty. Reqd." then
            ShipDashbrd.Validate("Qty. To Ship", ShipDashbrd."Qty. Reqd.")
        else
            ShipDashbrd.Validate("Qty. To Ship", 0);

        ShipDashbrd.Modify(true);
    end;

    procedure UpdateShipDashbrdStatus(ShipmentNo: Code[20])
    var
        ShipDashbrd: Record "Shipment Dashboard ELA";
        ShipDashbrd2: Record "Shipment Dashboard ELA";
    begin
        ShipDashbrd.Reset;
        ShipDashbrd.SetRange("Shipment No.", ShipmentNo);
        ShipDashbrd.SetRange(Level, 0);
        if ShipDashbrd.FindFirst then begin
            ShipDashbrd2.Reset;
            ShipDashbrd2.SetRange("Shipment No.", ShipmentNo);
            ShipDashbrd2.SetRange(Completed, false);
            ShipDashbrd2.SetRange(Level, 1);
            if not ShipDashbrd2.FindFirst then begin
                ShipDashbrd.Select := false;
                ShipDashbrd.Validate(Completed, true);
                ShipDashbrd.Modify;
            end else begin
                ShipDashbrd.Select := false;
                ShipDashbrd.Completed := false;
                ShipDashbrd.Modify;
            end;
        end;
    end;

    procedure UpdateDatesOnRelDocs(SalesOrderNo: Code[20]; NewShipDate: Date; NewPickupDate: Date)
    var
        WhseShipHdr: Record "Warehouse Shipment Header";
        ShipDashbrd: Record "Shipment Dashboard ELA";
        // ProdSaleOrder: Record "Prod. Sales Order";
        SalesHdr: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        //<<EN1.04 + EN1.29
        WhseShipHdr.Reset;
        // WhseShipHdr.SetRange("Source Order No.", SalesOrderNo);
        if WhseShipHdr.FindSet then begin
            repeat
                if WhseShipHdr."Shipment Date" <> NewShipDate then
                    WhseShipHdr.Validate("Shipment Date", NewShipDate);
                // if NewPickupDate <> 0D then  //EN1.33
                // WhseShipHdr."Pickup Date" := NewPickupDate;
                WhseShipHdr.Modify;
            until WhseShipHdr.Next = 0;

            ShipDashbrd.Reset;
            ShipDashbrd.SetRange("Source No.", SalesOrderNo);
            // ShipDashbrd.SetRange("Source Type", ShipDashbrd."Source Type"::"37"); //tbr
            ShipDashbrd.SetRange("Source Subtype", ShipDashbrd."Source Subtype"::"1");
            ShipDashbrd.ModifyAll("Shipment Date", NewShipDate);
            // if NewPickupDate <> 0D then //EN1.33
            //     ShipDashbrd.ModifyAll("Pickup Date", NewPickupDate);

            if SalesHdr.Get(SalesHdr."Document Type"::Order, SalesOrderNo) then begin
                if SalesHdr.Status = SalesHdr.Status::Released then
                    ReleaseSalesDoc.Reopen(SalesHdr);

                SalesHdr."Shipment Date" := NewShipDate;
                SalesHdr.UpdateSalesLines(SalesHdr.FieldCaption("Shipment Date"), false);
                SalesHdr.Modify(true);

                ReleaseSalesDoc.Run(SalesHdr);
            end;
        end;

        /*
        ProdSaleOrder.RESET;
        ProdSaleOrder.SETRANGE("Sales Order No.",SalesOrderNo);
        ProdSaleOrder.MODIFYALL(ProdSaleOrder."Shipment Date",NewShipDate);
        */ //en1.33
           //>>EN1.04 + EN1.29

    end;


    //tbr

    // procedure GetSuggestedBin(LocationCode: Code[10]; ItemNo: Code[20]; ItemUOM: Code[10]; QtyRequired: Decimal; AssignedRole: Code[20]; var ZoneCode: Code[10]; var BinCode: Code[20])
    // var
    //     lZoneSequenceRel: Record "Zone Sequence Relationship";
    //     lBin: Record Bin;
    //     lBinContent: Record "Bin Content";
    //     lWMSRole: Record "EN App. Role";
    //     lUseBulkPick: Boolean;
    // begin
    //     Clear(ZoneCode);
    //     Clear(BinCode);
    //     lWMSRole.Get(AssignedRole);
    //     if lWMSRole."Role Type" = lWMSRole."Role Type"::"Bulk Pick" then
    //         lUseBulkPick := true;

    //     lZoneSequenceRel.Reset;
    //     //lzone.setrange("Bin Type Code",'PUTPICK');
    //     lZoneSequenceRel.SetCurrentKey("Zone Code", Sequence);
    //     lZoneSequenceRel.SetRange("Bulk Pick", lUseBulkPick);
    //     if lZoneSequenceRel.FindSet then
    //         repeat
    //             lBinContent.Reset;
    //             lBinContent.SetRange("Location Code", lZoneSequenceRel."Location Code");
    //             lBinContent.SetRange("Zone Code", lZoneSequenceRel."Related Zone Code");
    //             lBinContent.SetRange("Item No.", ItemNo);
    //             lBinContent.SetRange("Unit of Measure Code", ItemUOM);
    //             if lBinContent.FindSet then
    //                 repeat
    //                     if lBinContent.Quantity >= QtyRequired then begin
    //                         ZoneCode := lBinContent."Zone Code";
    //                         BinCode := lBinContent."Bin Code";
    //                         exit;
    //                     end;
    //                 until lBinContent.Next = 0;
    //         until lZoneSequenceRel.Next = 0;
    // end;

    //tbr
    // procedure GetShipmentRole(ItemNo: Code[20]; UOM: Code[10]; ReqdQty: Decimal): Code[20]
    // var
    //     ItemUOM: Record "Item Unit of Measure";
    //     WMSRole: Record "EN App. Role";
    //     MaxUOMQty: Decimal;
    // begin
    //     //<<EN1.05
    //     ItemUOM.Get(ItemNo, UOM);

    //     // MaxUOMQty := ProdLoadRegMgt.GetMaxUOMQty(ItemNo);
    //     // if ReqdQty / MaxUOMQty >= 1 then
    //     //     exit(WMSRole.GetRole(Format(WMSRole."Role Type"::"Bulk Pick"), LocCode))       //EN1.64
    //     // else
    //     //     exit(WMSRole.GetRole(Format(WMSRole."Role Type"::"Aisle Pick"), LocCode))       //EN1.64
    //     //>>EN1.05
    // end;

    procedure UpdateCompletedStatus(OrderNo: Code[20])
    var
        ShipmentDashbrd: Record "Shipment Dashboard ELA";
        ShipmentDashbrd2: Record "Shipment Dashboard ELA";
    begin
        //<<EN1.15
        ShipmentDashbrd.Reset;
        ShipmentDashbrd.SetRange(Level, 0);
        ShipmentDashbrd.SetRange("Source No.", OrderNo);
        if ShipmentDashbrd.FindFirst then begin
            ShipmentDashbrd.Completed := true;
            ShipmentDashbrd.Modify;
        end;
        //>>EN1.15
    end;

    procedure UpdateProcessedLine(ShipmentNo: Code[20]; ShipmentLineNo: Integer; Processed: Boolean)
    var
        ShipDashBrd: Record "Shipment Dashboard ELA";
        SetAllLinesProcessed: Boolean;
    begin
        // if UseShipmentBoard then begin
        ShipDashBrd.Reset;
        ShipDashBrd.SetRange("Shipment No.", ShipmentNo);
        ShipDashBrd.SetRange("Shipment Line No.", ShipmentLineNo);
        if ShipDashBrd.FindFirst then begin
            ShipDashBrd.Completed := Processed;
            ShipDashBrd.Modify;
        end;

        ShipDashBrd.Reset;
        ShipDashBrd.SetRange("Shipment No.", ShipmentNo);
        ShipDashBrd.SetRange(Level, 1);
        ShipDashBrd.SetRange(Completed, false);
        if ShipDashBrd.Count = 0 then
            SetAllLinesProcessed := true
        else
            SetAllLinesProcessed := false;

        ShipDashBrd.Reset;
        ShipDashBrd.SetRange("Shipment No.", ShipmentNo);
        ShipDashBrd.SetRange(Level, 0);
        if ShipDashBrd.FindFirst then begin
            ShipDashBrd.Completed := SetAllLinesProcessed;
            ShipDashBrd.Modify;
        end;
        // end;
    end;


    procedure WhseShipmentQCComplete(ShipmentDocumentNo: Code[20]; ShipmentDocumentLineNo: Integer; QCComplete: Boolean)
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        ShipmentDashLine: Record "Shipment Dashboard ELA";
    begin
        IF WhseShipmentLine.Get(ShipmentDocumentNo, ShipmentDocumentLineNo) then begin
            WhseShipmentLine."QC Completed ELA" := QCComplete;
            WhseShipmentLine.Modify;
        end;

        ShipmentDashLine.RESET;
        ShipmentDashLine.SetRange(Level, 1);
        ShipmentDashLine.SetRange("Shipment No.", ShipmentDocumentNo);
        ShipmentDashLine.SetRange("Shipment Line No.", ShipmentDocumentLineNo);
        IF ShipmentDashLine.FindFirst() then begin
            ShipmentDashLine."QC Completed" := QCComplete;
            ShipmentDashLine.Modify();
        end;
    end;

    procedure WhseShipmentReleaseToQC(ShipmentDocumentNo: Code[20]; ShipmentDocumentLineNo: Integer; ReleaseToQC: Boolean)
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        ShipmentDashLine: Record "Shipment Dashboard ELA";
    begin
        IF WhseShipmentLine.Get(ShipmentDocumentNo, ShipmentDocumentLineNo) then begin
            WhseShipmentLine."Release to QC ELA" := ReleaseToQC;

            WhseShipmentLine.Modify;
        end;

        ShipmentDashLine.RESET;
        ShipmentDashLine.SetRange(Level, 1);
        ShipmentDashLine.SetRange("Shipment No.", ShipmentDocumentNo);
        ShipmentDashLine.SetRange("Shipment Line No.", ShipmentDocumentLineNo);
        IF ShipmentDashLine.FindFirst() then begin
            ShipmentDashLine."Release to QC" := ReleaseToQC;
            ShipmentDashLine.Modify();
        end;
    end;

    procedure WhseShipmentAssignQCUser(ShipmentDocumentNo: Code[20]; ShipmentDocumentLineNo: Integer; AssignedUser: Code[20])
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        ShipmentDashLine: Record "Shipment Dashboard ELA";
    begin
        IF WhseShipmentLine.Get(ShipmentDocumentNo, ShipmentDocumentLineNo) then begin
            WhseShipmentLine."Assigned QC User ELA" := AssignedUser;

            WhseShipmentLine.Modify;
        end;

        ShipmentDashLine.RESET;
        ShipmentDashLine.SetRange(Level, 1);
        ShipmentDashLine.SetRange("Shipment No.", ShipmentDocumentNo);
        ShipmentDashLine.SetRange("Shipment Line No.", ShipmentDocumentLineNo);
        IF ShipmentDashLine.FindFirst() then begin
            ShipmentDashLine."Assigned QC User" := AssignedUser;
            ShipmentDashLine.Modify();
        end;
    end;
    /* procedure UpdateShipmentDashQCComplete(WhseShpLine: Record "Warehouse Shipment Line")
     var
         ShipDashBrd: Record "Shipment Dashboard ELA";
     begin
         ShipDashBrd.Reset;
         ShipDashBrd.SetRange("Shipment No.", WhseShpLine."No.");
         ShipDashBrd.SetRange("Shipment Line No.", WhseShpLine."Line No.");
         if ShipDashBrd.FindFirst then begin
             ShipDashBrd.TestField("Release to QC", true);
             ShipDashBrd."QC Completed" := WhseShpLine."QC Completed ELA";
             ShipDashBrd.Modify;
         end;
     end;

     procedure UpdateShipmentLineDashQCComplete(ShpmntDash: Record "Shipment Dashboard ELA")
     var
         ShipmentLine: Record "Warehouse Shipment Line";
     begin
         if ShipmentLine.GET(ShpmntDash."Shipment No.", ShpmntDash."Shipment Line No.") then begin
             ShipmentLine.TestField("Release to QC ELA", true);
             ShipmentLine."QC Completed ELA" := ShpmntDash."QC Completed";
             ShipmentLine.Modify;
         end;

     end;*/


    /*procedure WhseShipmentReleaseToQC(ShipmentDocumentNo: Code[20]; ShipmentDocumentLineNo: Integer; ReleaseToQC: Boolean; AssignedQCUser: Code[20])
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        ShipmentDashLine: Record "Shipment Dashboard ELA";
    begin
        IF ReleaseToQC Then begin
            IF AssignedQCUser <> '' THEN begin
                IF WhseShipmentLine.Get(ShipmentDocumentNo, ShipmentDocumentLineNo) then begin
                    WhseShipmentLine."Release to QC ELA" := ReleaseToQC;
                    WhseShipmentLine."Assigned QC User ELA" := AssignedQCUser;
                    WhseShipmentLine.Modify;
                end;

                ShipmentDashLine.RESET;
                ShipmentDashLine.SetRange(Level, 1);
                ShipmentDashLine.SetRange("Shipment No.", ShipmentDocumentNo);
                ShipmentDashLine.SetRange("Shipment Line No.", ShipmentDocumentLineNo);
                IF ShipmentDashLine.FindFirst() then begin
                    ShipmentDashLine."Release to QC" := ReleaseToQC;
                    ShipmentDashLine."Assigned QC User" := AssignedQCUser;
                    ShipmentDashLine.Modify();
                end;
            end else
                ERROR('QC User must be assigned to Shipment Line.');
        end else begin
            IF WhseShipmentLine.Get(ShipmentDocumentNo, ShipmentDocumentLineNo) then begin
                WhseShipmentLine."Release to QC ELA" := ReleaseToQC;
                WhseShipmentLine."Assigned QC User ELA" := '';
                WhseShipmentLine.Modify;
            end;

            ShipmentDashLine.RESET;
            ShipmentDashLine.SetRange(Level, 1);
            ShipmentDashLine.SetRange("Shipment No.", ShipmentDocumentNo);
            ShipmentDashLine.SetRange("Shipment Line No.", ShipmentDocumentLineNo);
            IF ShipmentDashLine.FindFirst() then begin
                ShipmentDashLine."Release to QC" := ReleaseToQC;
                ShipmentDashLine."Assigned QC User" := '';
                ShipmentDashLine.Modify();
            end;

        end;



    end;

    procedure UpdateShipmentDashAssignedToQC(WhseShpLine: Record "Warehouse Shipment Line")
    var
        ShipDashBrd: Record "Shipment Dashboard ELA";
    begin
        ShipDashBrd.Reset;
        ShipDashBrd.SetRange("Shipment No.", WhseShpLine."No.");
        ShipDashBrd.SetRange("Shipment Line No.", WhseShpLine."Line No.");
        if ShipDashBrd.FindFirst then begin
            ShipDashBrd.TestField("Release to QC", true);
            ShipDashBrd."Assigned QC User" := WhseShpLine."Assigned QC User ELA";
            ShipDashBrd.Modify;
        end;
    end;

    procedure UpdateShipmentLineDashAssignedToQC(ShpmntDash: Record "Shipment Dashboard ELA")
    var
        ShipmentLine: Record "Warehouse Shipment Line";
    begin
        if ShipmentLine.GET(ShpmntDash."Shipment No.", ShpmntDash."Shipment Line No.") then begin
            ShipmentLine.TestField("Release to QC ELA", true);
            ShipmentLine."Assigned QC User ELA" := ShpmntDash."Assigned QC User";
            ShipmentLine.Modify;
        end;

    end;*/

    procedure UpdateProcessedQty(ShipmentNo: Code[20]; ShipmentLineNo: Integer; PickedQty: Decimal)
    var
        ShipDashBrd: Record "Shipment Dashboard ELA";
    begin
        //<<EN1.17
        ShipDashBrd.Reset;
        ShipDashBrd.SetRange("Shipment No.", ShipmentNo);
        ShipDashBrd.SetRange("Shipment Line No.", ShipmentLineNo);
        if ShipDashBrd.FindFirst then begin
            ShipDashBrd."Picked Qty." := PickedQty;
            if ShipDashBrd."Qty. To Ship" = PickedQty then
                ShipDashBrd.Completed := true;

            ShipDashBrd.Modify;
        end;
        //>>EN1.17
    end;

    /*  procedure UpdateShipmentLineDashReleaseQC(ShpmntDash: Record "Shipment Dashboard ELA")
      var
          ShipmentLine: Record "Warehouse Shipment Line";
          AssignedQCUser: Report "Assigned QC User ELA";
          lAction: Action;
      begin
          IF ShpmntDash."Release to QC" then begin
              AssignedQCUser.SetShipmentDoc(ShpmntDash."Shipment No.", ShpmntDash."Shipment Line No.", ShpmntDash."Release to QC");
              AssignedQCUser.RunModal();
          end else
              WhseShipmentReleaseToQC(ShpmntDash."Shipment No.", ShpmntDash."Shipment Line No.", ShpmntDash."Release to QC", '');

          /*if ShipmentLine.GET(ShpmntDash."Shipment No.", ShpmntDash."Shipment Line No.") then begin
              ShipmentLine.TestField("Qty. Picked");
              ShipmentLine."Release to QC ELA" := ShpmntDash."Release to QC";
              ShipmentLine.Modify;
              Commit;
              IF ShpmntDash."Release to QC" THEN BEGIN
                  AssignedQCUser.SetShipmentDoc(ShipmentLine."No.", ShipmentLine."Line No.");
                  AssignedQCUser.RunModal();
                  IF NOT AssignedQCUser.ExecutedOk then begin
                      ERROR('QC User must be assigned to Shipment Line.');
                  end;
              END ELSE
                  ShipmentLine."Assigned QC User ELA" := '';

          end;
      end;

      procedure UpdateShipmentDashReleaseQC(WhseShpLine: Record "Warehouse Shipment Line")
      var
          ShipDashBrd: Record "Shipment Dashboard ELA";
          AssignedQCUser: Report "Assigned QC User ELA";
      begin
          IF WhseShpLine."Release to QC ELA" then begin
              AssignedQCUser.SetShipmentDoc(WhseShpLine."No.", WhseShpLine."Line No.", WhseShpLine."Release to QC ELA");
              AssignedQCUser.RunModal();
          end else
              WhseShipmentReleaseToQC(WhseShpLine."No.", WhseShpLine."Line No.", WhseShpLine."Release to QC ELA", '');

          /* ShipDashBrd.Reset;
           ShipDashBrd.SetRange("Shipment No.", WhseShpLine."No.");
           ShipDashBrd.SetRange("Shipment Line No.", WhseShpLine."Line No.");
           if ShipDashBrd.FindFirst then begin
               ShipDashBrd.TestField("Picked Qty.");
               ShipDashBrd."Release to QC" := WhseShpLine."Release to QC ELA";
               ShipDashBrd.Modify;
               Commit;
               IF WhseShpLine."Release to QC ELA" THEN begin
                   AssignedQCUser.SetShipmentDoc(ShipDashBrd."Shipment No.", ShipDashBrd."Shipment Line No.");
                   AssignedQCUser.RunModal();
                   IF NOT AssignedQCUser.ExecutedOk then begin
                       ERROR('QC User must be assigned to Shipment Line.');
                   end;
               end else
                   ShipDashBrd."Assigned QC User" := '';


           end;
      end;
  */

    procedure IsOrderFullyPicked(OrderNo: Code[20]): Boolean
    var
        ShipDashbrd: Record "Shipment Dashboard ELA";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        IsFullyPicked: Boolean;
    begin
        //<<EN1.23
        IsFullyPicked := true;
        ShipDashbrd.Reset;
        ShipDashbrd.SetRange("Source No.", OrderNo);
        if ShipDashbrd.FindSet then
            repeat
                if ShipDashbrd."Qty. Reqd." <> ShipDashbrd."Picked Qty." then
                    IsFullyPicked := false;
            until ShipDashbrd.Next = 0;

        exit(IsFullyPicked);
    end;

    procedure CheckBOLQtyAgainstPickedQty(OrderNo: Code[20]): Boolean
    var
        ShipDashbrd: Record "Shipment Dashboard ELA";
        // BillOfLadingDet: Record "EN Bill of Lading Detail";
        SalesLine: Record "Sales Line";
        WhseShipLine: Record "Warehouse Shipment Line";
        PstdWhseShipLine: Record "Posted Whse. Shipment Line";
        Item: Record Item;
        TotalBOLQty: Decimal;
        TotalPickedQty: Decimal;
        TotalSLQty: Decimal;
    begin
        //<<EN1.28
        //tbr
        // BillOfLadingDet.Reset;
        // BillOfLadingDet.SetRange(BillOfLadingDet."Order No.", OrderNo);
        // BillOfLadingDet.SetFilter("Line Status", '<>%1', BillOfLadingDet."Line Status"::Deleted);
        // if BillOfLadingDet.FindSet(false, false) then
        //     repeat
        //         TotalBOLQty := TotalBOLQty + BillOfLadingDet."Qty on Pallet";
        //     until BillOfLadingDet.Next = 0;

        //<<EN1.33
        WhseShipLine.Reset;
        WhseShipLine.SetRange("Source No.", OrderNo);
        if WhseShipLine.FindSet(false, false) then
            repeat
                TotalPickedQty := TotalPickedQty + WhseShipLine.Quantity;
            until WhseShipLine.Next = 0;

        PstdWhseShipLine.Reset;
        PstdWhseShipLine.SetRange("Source No.", OrderNo);
        if PstdWhseShipLine.FindSet(false, false) then
            repeat
                TotalPickedQty := TotalPickedQty + PstdWhseShipLine.Quantity;
            until PstdWhseShipLine.Next = 0;

        /*
        ShipDashbrd.RESET;   // change to sales line as well....
        ShipDashbrd.SETRANGE("Source No.",OrderNo);
        IF ShipDashbrd.FINDSET THEN
          REPEAT
             TotalPickedQty := TotalPickedQty + ShipDashbrd."Picked Qty.";
          UNTIL ShipDashbrd.NEXT = 0;
        */

        //<<EN1.37
        SalesLine.Reset;
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", OrderNo);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet(false, false) then
            repeat
                Item.Get(SalesLine."No.");
                // if not Item."Use for Handling Charges" then begin
                TotalSLQty := TotalSLQty + SalesLine.Quantity;
            // end;
            until SalesLine.Next = 0;

        if (TotalBOLQty <> TotalPickedQty) or (TotalBOLQty <> TotalSLQty) then
            exit(true)
        else
            exit(false);
        //>>EN1.28 + EN1.33

    end;


    procedure GetNextPostingDate(CurrPostingDate: Date; SkipWeekendPosting: Boolean): Date
    var
        DayOfWeek: Integer;
    begin
        //<<EN1.34
        if not SkipWeekendPosting then
            exit(CurrPostingDate);

        DayOfWeek := Date2DWY(CurrPostingDate, 1);
        case DayOfWeek of
            1, 2, 3, 4:
                exit(CurrPostingDate);
            5:
                exit(CalcDate('<3d>', CurrPostingDate));
            6:
                exit(CalcDate('<2d>', CurrPostingDate));
            7:
                exit(CalcDate('<1d>', CurrPostingDate));
        end;
        //>>EN1.34
    end;

    procedure UpdateShipmentQtyFromSO(SalesLine: Record "Sales Line")
    var
        WhseShipHdr: Record "Warehouse Shipment Header";
        WhseShipLine: Record "Warehouse Shipment Line";
        WhseShipLine2: Record "Warehouse Shipment Line";
        WhseShipLineCopy: Record "Warehouse Shipment Line" temporary;
        WhseActivityLineCopy: Record "Warehouse Activity Line";
        ShipDashbrd: Record "Shipment Dashboard ELA";
        ShipDashBrd2: Record "Shipment Dashboard ELA";
        // BillofLadingHdr: Record "Bill of Lading Header";
        ReleaseWhseShipment: Codeunit "Whse.-Shipment Release";
        OrigWhseShipmentStatus: Option Open,Released;
    begin
        //<<EN1.32 + EN1.39
        //IF IsBOLRegistered(SalesLine."Document No.") THEN
        //IF BillofLadingHdr.GET(SalesLine."Document No.") THEN
        //IF BillofLadingHdr.Status = B illofLadingHdr.Status::Registered THEN
        //  ERROR(STRSUBSTNO(TEXT013,SalesLine."Document No."));
        //>>EN1.32 + EN1.39

        //<<EN1.13
        WhseShipHdr.Reset;
        // WhseShipHdr.SetRange("Source Order No.", SalesLine."Document No.");
        if WhseShipHdr.FindSet then
            repeat
                WhseShipLine.Reset;
                WhseShipLine.SetRange("No.", WhseShipHdr."No.");
                WhseShipLine.SetRange("Source Line No.", SalesLine."Line No.");
                if WhseShipLine.FindFirst then begin
                    ValidateShipLineForWhseAct(SalesLine."Document No.", SalesLine."Line No."); //EN1.37
                                                                                                /*
                                                                                                WhseActivityLine.RESET;
                                                                                                WhseActivityLine.SETRANGE("Activity Type",WhseActivityLine."Activity Type"::Pick);
                                                                                                WhseActivityLine.SETRANGE("Source No.",SalesLine."Document No.");
                                                                                                WhseActivityLine.SETRANGE("Source Line No.",SalesLine."Line No.");
                                                                                                IF WhseActivityLine.FINDFIRST THEN
                                                                                                  ERROR(STRSUBSTNO(TEXT009,SalesLine."No.",SalesLine."Document No."));
                                                                                                RegWhseActivityLine.RESET;
                                                                                                RegWhseActivityLine.SETRANGE("Activity Type",WhseActivityLine."Activity Type"::Pick);
                                                                                                RegWhseActivityLine.SETRANGE("Source No.",SalesLine."Document No.");
                                                                                                RegWhseActivityLine.SETRANGE("Source Line No.",SalesLine."Line No.");
                                                                                                IF RegWhseActivityLine.FINDFIRST THEN
                                                                                                  ERROR(STRSUBSTNO(TEXT010,SalesLine."No.",SalesLine."Document No."));
                                                                                                */

                    OrigWhseShipmentStatus := WhseShipHdr.Status;
                    if WhseShipHdr.Status = WhseShipHdr.Status::Released then
                        ReleaseWhseShipment.Reopen(WhseShipHdr);

                    WhseShipLineCopy.Copy(WhseShipLine);
                    WhseShipLine.Delete;

                    Clear(WhseShipLine);
                    WhseShipLine.Init;
                    WhseShipLine.Copy(WhseShipLineCopy);
                    //<<EN1.37
                    if (SalesLine."No." <> WhseShipLine."No.") and (WhseShipLine.Quantity = 0) then
                        WhseShipLine.Validate("Item No.", SalesLine."No.");
                    //>>EN1.37
                    WhseShipLine.Description := SalesLine.Description; //EN1.XX 11/5
                    WhseShipLine.Quantity := SalesLine.Quantity;
                    WhseShipLine."Qty. (Base)" := SalesLine."Quantity (Base)";
                    WhseShipLine."Qty. Outstanding" := SalesLine."Outstanding Quantity";
                    WhseShipLine."Qty. Outstanding (Base)" := SalesLine."Outstanding Qty. (Base)";
                    WhseShipLine."Orig. Asked Qty. ELA" := SalesLine."Orig. Asked Qty. ELA";
                    WhseShipLine."Last Modified Qty. ELA" := SalesLine."Last Modified Qty. ELA";
                    WhseShipLine.Insert;

                    ShipDashbrd.Reset;
                    ShipDashbrd.SetRange("Source No.", SalesLine."Document No.");
                    ShipDashbrd.SetRange("Source Line No.", SalesLine."Line No.");
                    if ShipDashbrd.FindFirst then begin
                        //<<EN1.37
                        if (SalesLine."No." <> ShipDashbrd."Item No.") and (ShipDashbrd."Qty. Reqd." = 0) then begin
                            ShipDashbrd.Validate("Item No.", SalesLine."No.");
                            ShipDashbrd."Item Description" := SalesLine.Description;
                            ShipDashbrd."Unit of Measure Code" := SalesLine."Unit of Measure";
                        end;
                        //>>EN1.37
                        ShipDashbrd."Item Description" := SalesLine.Description; //EN1.xx 11/5
                        ShipDashbrd."Qty. Reqd." := SalesLine.Quantity;
                        ShipDashbrd."Qty. To Ship" := SalesLine."Qty. to Ship";
                        ShipDashbrd."Orig. Ordered Qty." := SalesLine."Orig. Asked Qty. ELA";
                        ShipDashbrd."Last Modified Qty." := SalesLine."Last Modified Qty. ELA";
                        ShipDashbrd.Modify;
                    end;

                    if OrigWhseShipmentStatus = OrigWhseShipmentStatus::Released then
                        ReleaseWhseShipment.Release(WhseShipHdr);
                end;
            until WhseShipHdr.Next = 0;
        //>>EN1.13

    end;

    procedure DeleteShipmentLinesFromSO(SalesOrderNo: Code[20]; SalesLineNo: Integer)
    var
        WhseShipHdr: Record "Warehouse Shipment Header";
        WhseShipHdr2: Record "Warehouse Shipment Header";
        WhseShipLine: Record "Warehouse Shipment Line";
        WhseShipLine2: Record "Warehouse Shipment Line";
        ShipDashbrd: Record "Shipment Dashboard ELA";
        WhseShipRel: Codeunit "Whse.-Shipment Release";
    begin
        //<<EN1.37
        WhseShipHdr.Reset;
        // WhseShipHdr.SetRange("Source Order No.", SalesOrderNo);
        if WhseShipHdr.FindSet then
            repeat
                WhseShipLine.Reset;
                WhseShipLine.SetRange("No.", WhseShipHdr."No.");
                WhseShipLine.SetRange("Source No.", SalesOrderNo);
                WhseShipLine.SetRange("Source Line No.", SalesLineNo);
                if WhseShipLine.FindSet then begin
                    WhseShipRel.Reopen(WhseShipHdr);
                    repeat
                        WhseShipLine.Delete;
                    until WhseShipLine.Next = 0;

                    WhseShipLine2.Reset;
                    WhseShipLine2.SetRange("No.", WhseShipHdr."No.");
                    WhseShipLine2.SetFilter(Quantity, '<>%1', 0);
                    if WhseShipLine2.Count > 0 then begin
                        if WhseShipHdr2.Get(WhseShipHdr."No.") then
                            WhseShipRel.Release(WhseShipHdr2);
                    end else begin
                        if WhseShipHdr2.Get(WhseShipHdr."No.") then
                            if WhseShipHdr2.Delete(true) then;
                    end;

                    ShipDashbrd.Reset;
                    ShipDashbrd.SetRange("Source No.", SalesOrderNo);
                    ShipDashbrd.SetRange("Source Line No.", SalesLineNo);
                    if ShipDashbrd.FindSet then
                        repeat
                            ShipDashbrd.Delete;
                        until ShipDashbrd.Next = 0;
                end;
            until WhseShipHdr.Next = 0;
        //>>EN1.37
    end;

    procedure ValidateShipLineForWhseAct(SalesOrderNo: Code[20]; SalesLineNo: Integer)
    var
        WhseActivityLine: Record "Warehouse Activity Line";
        RegWhseActivityLine: Record "Registered Whse. Activity Line";
    begin
        //<<EN1.37
        WhseActivityLine.Reset;
        WhseActivityLine.SetRange("Activity Type", WhseActivityLine."Activity Type"::Pick);
        WhseActivityLine.SetRange("Source No.", SalesOrderNo);
        WhseActivityLine.SetRange("Source Line No.", SalesLineNo);
        if WhseActivityLine.FindFirst then
            Error(StrSubstNo(TEXT14229209, WhseActivityLine."Item No.", SalesOrderNo));

        RegWhseActivityLine.Reset;
        RegWhseActivityLine.SetRange("Activity Type", WhseActivityLine."Activity Type"::Pick);
        RegWhseActivityLine.SetRange("Source No.", SalesOrderNo);
        RegWhseActivityLine.SetRange("Source Line No.", SalesLineNo);
        if RegWhseActivityLine.FindFirst then
            Error(StrSubstNo(TEXT14229210, WhseActivityLine."Item No.", SalesOrderNo));
        //>>EN1.37
    end;

    procedure CleanOrphanedEntries()
    var
        Shipdashbrd: Record "Shipment Dashboard ELA";
        Shipdashbrd2: Record "Shipment Dashboard ELA";
        WhseShipHdr: Record "Warehouse Shipment Header";
        SalesHdr: Record "Sales Header";
    begin
        //<<EN1.38
        Shipdashbrd.Reset;
        Shipdashbrd.SetRange(Level, 0);
        if Shipdashbrd.FindSet then
            repeat
                if not SalesHdr.Get(SalesHdr."Document Type"::Order, Shipdashbrd."Source No.") then begin
                    WhseShipHdr.Reset;
                    // WhseShipHdr.SetRange("Source Order No.", Shipdashbrd."Source No.");
                    if WhseShipHdr.FindFirst then begin
                        ReleaseWhseShipment.Reopen(WhseShipHdr);
                        if WhseShipHdr.Delete(true) then;
                    end;
                    Shipdashbrd2.Reset;
                    Shipdashbrd2.SetRange("Source No.", Shipdashbrd."Source No.");
                    if Shipdashbrd2.FindSet then
                        repeat
                            DeleteWHShipmentInfo(Shipdashbrd2."Shipment No.");
                        until Shipdashbrd2.Next = 0;
                end;
            until Shipdashbrd.Next = 0;
        //>>EN1.38
    end;

    procedure DeleteWhseShipRelDocs(DocNo: Code[20])
    var
        WhseShipHdr: Record "Warehouse Shipment Header";
        WhseShipLine: Record "Warehouse Shipment Line";
    begin
        //<<EN1.39
        if not IsBOLRegistered(DocNo) then begin
            WhseShipHdr.Reset;
            // WhseShipHdr.SetRange("Source Order No.", DocNo);
            if WhseShipHdr.FindSet then
                repeat
                    WhseShipLine.Reset;
                    WhseShipLine.SetRange("No.", WhseShipHdr."No.");
                    if WhseShipLine.FindSet then
                        repeat
                            ValidateShipLineForWhseAct(WhseShipLine."Source No.", WhseShipLine."Source Line No.");
                        until WhseShipLine.Next = 0;
                until WhseShipHdr.Next = 0;

            WhseShipHdr.Reset;
            // WhseShipHdr.SetRange("Source Order No.", DocNo);
            if WhseShipHdr.FindSet then
                repeat
                    DeleteWHShipmentInfo(WhseShipHdr."No.");
                until WhseShipHdr.Next = 0;
        end else
            Error(StrSubstNo(TEXT14229213, DocNo));
        //>>EN1.39
    end;

    procedure IsBOLRegistered(SalesOrderNo: Code[20]): Boolean
    var
    // BillOfLadingHdr: Record "Bill of Lading Header";
    begin
        //<<EN1.39
        //tbr
        // //IF BillOfLadingHdr.GET(SalesOrderNo) THEN begin
        // BillOfLadingHdr.Reset;
        // BillOfLadingHdr.SetRange("Sales Order No.", SalesOrderNo);
        // if BillOfLadingHdr.FindFirst then
        //     if BillOfLadingHdr.Status = BillOfLadingHdr.Status::Registered then
        //         exit(true)
        //     else
        //         exit(false);
        //>>EN1.39
    end;

    procedure "--Picking"()
    begin
    end;

    /// <summary>
    /// CreatePickTicketFromWhseShipment.
    /// </summary>
    /// <param name="WhseShptNo">Code[20].</param>
    /// <param name="UserCode">Code[20].</param>
    procedure CreatePickTicketFromWhseShipment(WhseShptNo: Code[20]; UserCode: Code[20]; TripID: Code[20])
    var
        ShipDashBrd: Record "Shipment Dashboard ELA";
        WsheShipHdr: Record "Warehouse Shipment Header";
        WsheShipLine: Record "Warehouse Shipment Line";
        TmpWhseShipHdr: Record "Warehouse Shipment Header" temporary;
        CreatePickFromWhseShpt: Report "Whse.-Shipment - Create Pick";
        WhsePickRqst: record "Whse. Pick Request";
        GetWhseSourceDocuments: Report "Get Outbound Source Documents";
        ShipmentFilter: Text[1024];
        LocationCode: Code[20];
        WhseWorkSheetLine: record "Whse. Worksheet Line";
        WhseCreatePick: Report "Create Pick";
        WkshPickLine: record "Whse. Worksheet Line";
    // ProcessReplenish: Codeunit "Process Replinishment";
    // SortActivity: Option " ",Item,Document,"Shelf/Bin No.","Due Date","Ship-To","Bin Ranking","Action Type";
    begin
        ApplyCutQty(WhseShptNo, UserCode);
        ShipDashBrd.Reset;
        ShipDashBrd.SetRange(Level, 1);
        If TripID <> '' then
            ShipDashBrd.SetRange(ShipDashBrd."Trip No.", TripID)
        else
            ShipDashBrd.SetRange("Shipment No.", WhseShptNo);
        ShipDashBrd.SetRange("Locked By User ID", UserCode);
        ShipDashBrd.SetRange(Select, true);
        //ShipDashBrd.SETRANGE("Pick Ticket Created",FALSE);
        ShipDashBrd.SetRange(Completed, false);
        if ShipDashBrd.FindSet then
            repeat
                if not TmpWhseShipHdr.Get(ShipDashBrd."Shipment No.") then begin
                    TmpWhseShipHdr.Init;
                    TmpWhseShipHdr."No." := ShipDashBrd."Shipment No.";
                    TmpWhseShipHdr.Insert;

                    LocationCode := ShipDashBrd.Location;
                    WhseWorkSheetLine.RESET;
                    WhseWorkSheetLine.SetRange("Whse. Document Type", WhseWorkSheetLine."Whse. Document Type"::Shipment);
                    WhseWorkSheetLine.SetRange("Whse. Document No.", TmpWhseShipHdr."No.");
                    IF NOT WhseWorkSheetLine.FindFirst() THEN begin
                        WhsePickRqst.Reset;
                        WhsePickRqst.SetFilter("Document No.", TmpWhseShipHdr."No.");
                        WhsePickRqst.SetRange("Document Type", WhsePickRqst."Document Type"::Shipment);
                        //WhsePickRqst.SETRANGE(Status, WhsePickRqst.Status::Released);
                        WhsePickRqst.SETRANGE("Completely Picked", FALSE);
                        WhsePickRqst.SETRANGE("Location Code", ShipDashBrd.Location);
                        IF WhsePickRqst.FINDSET THEN begin
                            CLEAR(GetWhseSourceDocuments);
                            GetWhseSourceDocuments.SetPickWkshName('PICK', 'DEFAULT', LocationCode);
                            GetWhseSourceDocuments.USEREQUESTPAGE(FALSE);
                            GetWhseSourceDocuments.SETTABLEVIEW(WhsePickRqst);
                            GetWhseSourceDocuments.RUNMODAL;
                            CLEAR(GetWhseSourceDocuments);
                        end;
                    end;

                    /* if WsheShipHdr.Get(ShipDashBrd."Shipment No.") then begin
                         if WsheShipHdr.Status = WsheShipHdr.Status::Open then
                             ReleaseWhseShipment.Release(WsheShipHdr);

                         WsheShipLine.Reset;
                         WsheShipLine.SetRange("No.", WsheShipHdr."No.");
                         WsheShipLine.SetFilter(Quantity, '>0');
                         WsheShipLine.SetRange("Completely Picked", false);
                         if WsheShipLine.FindFirst then begin
                             WsheShipLine.SetHideValidationDialog(true);
                             WsheShipLine.CreatePickDoc(WsheShipLine, WsheShipHdr);
                             /*Clear(CreatePickFromWhseShpt);
                             CreatePickFromWhseShpt.Initialize('', 3, false, true, false);
                             CreatePickFromWhseShpt.SetWhseShipmentLine(WsheShipLine, WsheShipHdr);
                             CreatePickFromWhseShpt.SetHideValidationDialog(true);
                             CreatePickFromWhseShpt.UseRequestPage(false);
                             CreatePickFromWhseShpt.RunModal;
                             Clear(CreatePickFromWhseShpt);
                        end;
                    end;*/
                end;
            until ShipDashBrd.Next() = 0;

        WhseWorkSheetLine.RESET;
        IF WhseWorkSheetLine.FindSet() THEN begin
            WkshPickLine.COPY(WhseWorkSheetLine);
            WhseCreatePick.SetWkshPickLine(WkshPickLine);
            WhseCreatePick.UseRequestPage(FALSE);
            WhseCreatePick.RUN();
            /*IF WhseCreatePick.GetResultMessage THEN
                AutofillQtyToHandle(Rec);*/
            CLEAR(WhseCreatePick);
        end;
    end;


    //     ShipDashBrd.Reset;
    //     ShipDashBrd.SetRange(Level, 1);
    //     // ShipDashBrd.SetRange("Source No.", SalesOrderNo);
    //     ShipDashBrd.SetRange("Shipment No.", WhseShptNo);
    //     ShipDashBrd.SetRange("Locked By User ID", UserCode);
    //     ShipDashBrd.SetRange(Select, true);
    //     //ShipDashBrd.SETRANGE("Pick Ticket Created",FALSE);
    //     ShipDashBrd.SetRange(Completed, false);
    //     if ShipDashBrd.FindSet then
    //         repeat
    //             if not TmpWsheShipHdr.Get(ShipDashBrd."Shipment No.") then begin
    //                 TmpWsheShipHdr.Init;
    //                 TmpWsheShipHdr."No." := ShipDashBrd."Shipment No.";
    //                 TmpWsheShipHdr.Insert;
    //             end;
    //         until ShipDashBrd.Next = 0;

    //     TmpWsheShipHdr.Reset;
    //     if TmpWsheShipHdr.FindSet then begin
    //         repeat
    //             if WsheShipHdr.Get(TmpWsheShipHdr."No.") then begin
    //                 if WsheShipHdr.Status = WsheShipHdr.Status::Open then
    //                     ReleaseWhseShipment.Release(WsheShipHdr);

    //                 WsheShipLine.Reset;
    //                 WsheShipLine.SetRange("No.", WsheShipHdr."No.");
    //                 WsheShipLine.SetFilter(Quantity, '>0');
    //                 WsheShipLine.SetRange("Completely Picked", false);
    //                 if WsheShipLine.FindFirst then begin
    //                     Clear(CreatePickFromWhseShpt);
    //                     CreatePickFromWhseShpt.Initialize('', 3, false, true, false);
    //                     CreatePickFromWhseShpt.SetWhseShipmentLine(WsheShipLine, WsheShipHdr);
    //                     CreatePickFromWhseShpt.SetHideValidationDialog(true);
    //                     CreatePickFromWhseShpt.UseRequestPage(false);
    //                     CreatePickFromWhseShpt.RunModal;
    //                     Clear(CreatePickFromWhseShpt);
    //                 end;
    //             end;
    //         until TmpWsheShipHdr.Next = 0;
    //     end;
    // end;


    /// <summary>
    /// ReleasePickDocument.
    /// </summary>
    /// <param name="PickTicketNo">code[20].</param>
    procedure ReleasePickDocument(PickTicketNo: code[20])
    var
        WhseActLine: record "Warehouse Activity Line";
        WhseActLine2: record "Warehouse Activity Line";
    begin
        WhseActLine.reset;
        whseactline.setrange("No.", PickTicketNo);
        whseactline.setrange("Activity type", whseactline."Activity Type"::Pick);
        WhseActLine.SetRange("Released To Pick ELA", false);
        whseactline.setrange("Action Type", whseactline."Action Type"::Take);
        if whseactline.findset then
            repeat
                WhseActLine."Released To Pick ELA" := true;
                WhseActLine."Released At ELA" := CurrentDateTime;

                WhseActLine2.reset;
                whseactline2.setrange("No.", PickTicketNo);
                whseactline2.setrange("Activity type", whseactline2."Activity Type"::Pick);
                WhseActLine2.SetRange("Released To Pick ELA", false);
                whseactline2.setrange("Action Type", whseactline2."Action Type"::Place);
                whseactline2.setrange("Whse. Document Type", WhseActLine."Whse. Document Type");
                WhseActLine2.setrange("Whse. Document No.", WhseActline."WHse. Document No.");
                WhseActLine2.setrange("Whse. Document Line No.", WhseActline."WHse. Document Line No.");
                if WhseActLine2.findset then
                    repeat
                        WhseActLine2."Released To Pick ELA" := true;
                        WhseActLine2."Released At ELA" := CurrentDateTime;
                        if (WhseActLine."Trip No. ELA" <> WhseActLine2."Trip No. ELA") then
                            WhseActLine2."Trip No. ELA" := WhseActLine."Trip No. ELA";
                        WhseActLine2.modify;
                    until WhseActLine2.next = 0;

                whseactline.modify;

            until whseactline.next = 0;
    end;

    procedure UpdatePickTicketStatus(ShipmentNo: Code[20]; ShipmentLineNo: Integer; PickCreated: Boolean)
    var
        ShipDashBrd: Record "Shipment Dashboard ELA";
        SetAllLinesPickCreated: Boolean;
    begin
        //IF NOT PickCreated THEN EXIT;
        // if UseShipmentBoard then begin
        ShipDashBrd.Reset;
        ShipDashBrd.SetRange("Shipment No.", ShipmentNo);
        ShipDashBrd.SetRange("Shipment Line No.", ShipmentLineNo);
        if ShipDashBrd.FindFirst then begin
            ShipDashBrd.CalcFields("Qty. On Pick");
            ShipDashBrd."Qty. To Ship" := 0;
            if ShipDashBrd."Picked Qty." + ShipDashBrd."Qty. On Pick" <> ShipDashBrd."Qty. Reqd." then begin
                ShipDashBrd."Partial Pick" := true;
            end else
                ShipDashBrd."Partial Pick" := false;

            if (ShipDashBrd."Qty. On Pick" > 0) or (ShipDashBrd."Picked Qty." > 0) then
                ShipDashBrd."Full Pick" := true
            else
                ShipDashBrd."Full Pick" := false;

            ShipDashBrd.Modify;
        end;

        ShipDashBrd.Reset;
        ShipDashBrd.SetRange("Shipment No.", ShipmentNo);
        ShipDashBrd.SetRange(Level, 1);
        ShipDashBrd.SetRange("Full Pick", false);
        if ShipDashBrd.Count = 0 then
            SetAllLinesPickCreated := true
        else
            SetAllLinesPickCreated := false;

        ShipDashBrd.Reset;
        ShipDashBrd.SetRange("Shipment No.", ShipmentNo);
        ShipDashBrd.SetRange(Level, 0);
        if ShipDashBrd.FindFirst then begin
            ShipDashBrd."Full Pick" := SetAllLinesPickCreated;
            ShipDashBrd.Modify;
        end;
    end;

    procedure GenerateBinAllocation()
    begin
        // delete
    end;

    procedure DoAutoPick(PickDocNo: Code[20]; LocationCode: Code[10])
    var
        WhseActLine: Record "Warehouse Activity Line";
        WhseActLine1: Record "Warehouse Activity Line";
        WhseActLine2: Record "Warehouse Activity Line";
        WhseActLine3: Record "Warehouse Activity Line";
        Location: Record Location;
        PickDocLineNo: Integer;
    begin
        //<<EN1.10
        WhseActLine.Reset;
        WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::Pick);
        WhseActLine.SetRange("Action Type", WhseActLine."Action Type"::Take);
        WhseActLine.SetRange("No.", PickDocNo);
        // WhseActLine.SetRange("Receive To Pick", true);
        if WhseActLine.FindSet then
            repeat
                if WhseActLine1.Get(WhseActLine."Activity Type"::Pick, WhseActLine."No.", WhseActLine."Line No.") then begin
                    PickDocLineNo := WhseActLine."Line No.";
                    WhseActLine1.Validate("Qty. to Handle", WhseActLine1.Quantity);
                    WhseActLine1."Assigned App. User ELA" := UserId;
                    WhseActLine1.Modify;

                    WhseActLine2.Reset;
                    WhseActLine2.SetRange("Activity Type", WhseActLine2."Activity Type"::Pick);
                    WhseActLine2.SetRange("No.", PickDocNo);
                    WhseActLine2.SetRange("Action Type", WhseActLine2."Action Type"::Place);
                    // WhseActLine2.SetRange("Parent Line No.", PickDocLineNo);
                    if WhseActLine2.FindFirst then begin
                        WhseActLine2.Validate("Qty. to Handle", WhseActLine2.Quantity);
                        WhseActLine2."Assigned App. User ELA" := UserId;
                        WhseActLine2.Modify;
                    end;

                    WhseActLine3.Get(WhseActLine."Activity Type"::Pick, PickDocNo, PickDocLineNo);
                    // Clear(WhseActivityReg);
                    // WhseActivityReg.ShowHideDialog(false);
                    // WhseActivityReg.Run(WhseActLine3);
                    PickDocLineNo := 0;
                end;
            until WhseActLine.Next = 0;
        //>>EN1.10
    end;


    procedure DoAutoPickBySalesOrder(SalesOrderNo: Code[20]; LocationCode: Code[10])
    var
        WhseActLine: Record "Warehouse Activity Line";
        WhseActLine1: Record "Warehouse Activity Line";
        WhseActLine2: Record "Warehouse Activity Line";
        WhseActLine3: Record "Warehouse Activity Line";
        Location: Record Location;
    begin
        //<<EN1.12
        WhseActLine.Reset;
        WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::Pick);
        WhseActLine.SetRange("Action Type", WhseActLine."Action Type"::Take);
        WhseActLine.SetRange("Source No.", SalesOrderNo);
        // WhseActLine.SetRange("Receive To Pick", true);
        if WhseActLine.FindSet then
            repeat
                if WhseActLine1.Get(WhseActLine."Activity Type"::Pick, WhseActLine."No.", WhseActLine."Line No.") then begin
                    WhseActLine1.Validate("Qty. to Handle", WhseActLine1.Quantity);
                    WhseActLine1."Assigned App. User ELA" := UserId;
                    WhseActLine1.Modify;

                    WhseActLine2.Reset;
                    WhseActLine2.SetRange("Activity Type", WhseActLine2."Activity Type"::Pick);
                    WhseActLine2.SetRange("Source No.", SalesOrderNo);
                    WhseActLine2.SetRange("Action Type", WhseActLine2."Action Type"::Place);
                    // WhseActLine2.SetRange("Parent Line No.", WhseActLine."Line No.");
                    if WhseActLine2.FindFirst then begin
                        WhseActLine2.Validate("Qty. to Handle", WhseActLine2.Quantity);
                        WhseActLine2."Assigned App. User ELA" := UserId;
                        WhseActLine2.Modify;
                    end;

                    WhseActLine3.Get(WhseActLine."Activity Type"::Pick, WhseActLine."No.", WhseActLine."Line No.");
                    // WhseActivityReg.ShowHideDialog(false);
                    // WhseActivityReg.Run(WhseActLine3);
                end;
            until WhseActLine.Next = 0;
        //>>EN1.10
    end;

    // procedure CheckIfProdSalesOrderRevd(OrderNo: Code[20]; ItemNo: Code[20]): Decimal
    // var
    //     RegWhseActLine: Record "Registered Whse. Activity Line";
    //     WhseActLine: Record "Warehouse Activity Line";
    //     QtyRecvd: Decimal;
    // begin
    //     RegWhseActLine.Reset;
    //     RegWhseActLine.SetRange("Activity Type", RegWhseActLine."Activity Type"::"Put-away");
    //     RegWhseActLine.SetRange("Prod. Sales Order No.", OrderNo);
    //     RegWhseActLine.SetRange("Item No.", ItemNo);
    //     if RegWhseActLine.FindSet then begin
    //         repeat
    //             QtyRecvd := QtyRecvd + RegWhseActLine.Quantity;
    //         until RegWhseActLine.Next = 0;
    //         exit(QtyRecvd);
    //     end;

    //     QtyRecvd := 0;
    //     WhseActLine.Reset;
    //     WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::"Put-away");
    //     WhseActLine.SetRange("Prod. Sales Order No.", OrderNo);
    //     WhseActLine.SetRange("Item No.", ItemNo);
    //     if WhseActLine.FindSet then begin
    //         repeat
    //             QtyRecvd := QtyRecvd + WhseActLine.Quantity;
    //         until WhseActLine.Next = 0;
    //         exit(QtyRecvd);
    //     end;
    // end;

    // procedure AutoAssignPallets(SalesOrderNo: Code[20])
    // var
    //     WhseActLine: Record "Warehouse Activity Line";
    //     WhseActLine2: Record "Warehouse Activity Line";
    //     // PalletContMgt: Codeunit "Delivery Load Mgt.";
    //     WMSRole: Record "EN App. Role";
    //     ContID: Integer;
    //     PallNo: Integer;
    //     PallLineNo: Integer;
    //     ProdSalesOrderNo: Code[20];
    //     ProdSalesOrderLineNo: Integer;
    //     ProdSalesOrderLinePalletNo: Integer;
    //     DoPrintLabels: Boolean;
    //     LoadID: Code[20];
    // begin
    //     //<<EN1.19
    //     //<<EN1.20
    //     DoPrintLabels := false; //<<EN1.41
    //                             //IF CONFIRM(TEXT012,FALSE) THEN
    //                             //DoPrintLabels := TRUE;
    //                             //>>EN1.20

    //     WhseActLine.Reset;
    //     //WhseActLine.SETCURRENTKEY("No.","Item No.","Code Date",Quantity); //x
    //     WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::Pick);
    //     WhseActLine.SetRange("Source Type", WhseActLine."Source Type"::"37");
    //     WhseActLine.SetRange("Source Subtype", WhseActLine."Source Subtype"::"1");
    //     WhseActLine.SetRange("Source No.", SalesOrderNo);
    //     WhseActLine.SetRange("Action Type", WhseActLine."Action Type"::Take);
    //     WhseActLine.SetRange("Released To Pick", true);
    //     //WhseActLine.ASCENDING(TRUE);
    //     if WhseActLine.Find('-') then begin
    //         WhseActLine.SetCurrentKey("No.", "Item No.", "Code Date", Quantity);      //EN1.49
    //         WhseActLine.Ascending(false);
    //         if WhseActLine.Find('-') then
    //             repeat
    //                 WMSRole.Get(WhseActLine."Assigned Role");
    //                 //<<EN1.26
    //                 if ((WMSRole."Auto Assign Pick Pallets") and (WhseActLine."Load ID" = '')) or
    //                    ((WhseActLine."Receive To Pick") and (WhseActLine."Load ID" = '')) then begin
    //                     if WhseActLine."Receive To Pick" then begin
    //                         Error('Receive to pick is not allowed');
    //                         /* PalletContMgt.AddProdSalesOrderNoBOL(WhseActLine."Source No.",WhseActLine."Source Line No.");//,"Source Line No.");
    //                           PalletContMgt.GetProdSalesOrderPalletNo(WhseActLine."Source No.",WhseActLine."Source Line No.",
    //                             ContID,PallNo,PallLineNo,ProdSalesOrderNo,ProdSalesOrderLineNo,ProdSalesOrderLinePalletNo);

    //                           //WhseActLine."Container ID" := ContID;
    //                           WhseActLine."Pallet No." := PallNo;
    //                           WhseActLine."Pallet Line No." := PallLineNo;
    //                           WhseActLine."Prod. Sales Order No." := ProdSalesOrderNo;
    //                           WhseActLine."Prod. Sales Order Line No." := ProdSalesOrderLineNo;
    //                           WhseActLine."Prod. Sales Order Pallet No." := ProdSalesOrderLinePalletNo;
    //                           WhseActLine.MODIFY;

    //                           PalletContMgt.UpdateLine(ContID,PallNo,PallLineNo,2,WhseActLine."Source No.",WhseActLine."Source Line No.",0,
    //                             WhseActLine."Item No.",WhseActLine.Quantity,WhseActLine."Unit of Measure Code",TRUE,WhseActLine."No.",
    //                             WhseActLine."Line No.",WhseActLine."Code Date");    */     //EN1.51
    //                                                                                        //>>EN1.26
    //                     end else begin
    //                         //PalletContMgt.GetPalletNo(2,WhseActLine."Source No.",ContID,PallNo,PallLineNo);       //EN1.51
    //                         PalletContMgt.GetPalletNoFromConsign(2, WhseActLine."Source No.", LoadID, PallNo, PallLineNo, 1);    //EN1.51
    //                                                                                                                              //<<EN1.23
    //                                                                                                                              //WhseActLine."Container ID" := ContID;   //EN1.51
    //                         WhseActLine."Load ID" := LoadID;  //EN1.51
    //                         WhseActLine."Pallet No." := PallNo;
    //                         WhseActLine."Pallet Line No." := PallLineNo;
    //                         WhseActLine.Modify;
    //                         //>>EN1.23
    //                         /*PalletContMgt.UpdateLine(ContID,PallNo,PallLineNo,2,WhseActLine."Source No.",WhseActLine."Source Line No.",0,
    //                           WhseActLine."Item No.",WhseActLine.Quantity,WhseActLine."Unit of Measure Code",TRUE,WhseActLine."No.",
    //                           WhseActLine."Line No.",WhseActLine."Code Date");*/   //EN1.51

    //                         PalletContMgt.UpdatePalletLine(LoadID, PallNo, PallLineNo, 2, WhseActLine."Source No.", WhseActLine."Source Line No.", 0,
    //                           WhseActLine."Item No.", WhseActLine.Quantity, WhseActLine."Unit of Measure Code", true, WhseActLine."No.",
    //                           WhseActLine."Line No.", WhseActLine."Code Date", '', '', 0, WhseActLine.Weight);                //EN1.51
    //                                                                                                                           // PalletContMgt.ClosePallet(2,WhseActLine."Source No.",ContID,PallNo);
    //                         PalletContMgt.ClosePalletInConsign(LoadID, 2, WhseActLine."Source No.", PallNo);          //EN1.51
    //                     end;

    //                     WhseActLine2.Reset;
    //                     WhseActLine2.SetRange("Activity Type", WhseActLine."Activity Type");
    //                     WhseActLine2.SetRange("No.", WhseActLine."No.");
    //                     WhseActLine2.SetRange("Parent Line No.", WhseActLine."Line No.");
    //                     if WhseActLine2.FindSet then
    //                         repeat
    //                             WhseActLine2."Released To Pick" := true;
    //                             //WhseActLine2."Container ID" := ContID;                   //EN1.51
    //                             WhseActLine2."Load ID" := LoadID;                          //EN1.51
    //                             WhseActLine2."Pallet No." := PallNo;
    //                             WhseActLine2."Pallet Line No." := PallLineNo;
    //                             if WhseActLine2."Released To Pick" then begin
    //                                 WhseActLine2."Prod. Sales Order No." := ProdSalesOrderNo;
    //                                 WhseActLine2."Prod. Sales Order Line No." := ProdSalesOrderLineNo;
    //                                 WhseActLine2."Prod. Sales Order Pallet No." := ProdSalesOrderLinePalletNo;
    //                             end;

    //                             WhseActLine2.Modify;
    //                         until WhseActLine2.Next = 0;
    //                 end;
    //             until WhseActLine.Next = 0;

    //         Commit;
    //         if DoPrintLabels then
    //             PrintShippingPallets(SalesOrderNo);
    //     end;
    //     //>>EN1.19

    // end;

    // procedure PrintShippingPallets(SalesOrderNo: Code[20])
    // var
    //     WhseActLine: Record "Warehouse Activity Line";
    //     WhseActLine2: Record "Warehouse Activity Line";
    //     // PalletContMgt: Codeunit "Delivery Load Mgt.";
    //     WMSRole: Record "EN App. Role";
    //     ContID: Integer;
    //     PallNo: Integer;
    //     PallLineNo: Integer;
    //     DoPrintLabels: Boolean;
    // begin
    //     //<<EN1.22
    //     WhseActLine.Reset;
    //     WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::Pick);
    //     WhseActLine.SetRange("Source Type", WhseActLine."Source Type"::"37");
    //     WhseActLine.SetRange("Source Subtype", WhseActLine."Source Subtype"::"1");
    //     WhseActLine.SetRange("Source No.", SalesOrderNo);
    //     WhseActLine.SetRange("Action Type", WhseActLine."Action Type"::Take);
    //     WhseActLine.SetRange("Released To Pick", true);
    //     if WhseActLine.Find('-') then begin
    //         WhseActLine.SetCurrentKey("No.", "Item No.", "Bin Code", "Code Date", Quantity);
    //         WhseActLine.Ascending(false);
    //         if WhseActLine.Find('-') then
    //             repeat
    //                 WMSServices.PrintBillOfLadingPalletLabel(WhseActLine."Source No.", WhseActLine."Load ID",
    //                   WhseActLine."Pallet No.", false);
    //             until WhseActLine.Next = 0;
    //     end;
    //     //>>EN1.22
    // end;

    procedure "--Queue"()
    begin
    end;

    procedure AddShipmentToWMSQueue(WsheShipHdr: Record "Warehouse Shipment Header")
    begin
        Error('not in use addshipmenttowmsqueue');
    end;

    procedure AddActivityLineToWMSQueue(WsheActLine: Record "Warehouse Activity Line")
    begin
        Error('not in use addactivitylinetowmsqueue');
    end;

    procedure AddShipQtyToOrderLine(ShipDashBrdLine: Record "Shipment Dashboard ELA"; xReqdQty: Decimal)
    var
        SalesHdr: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        NewSalesLine: Record "Sales Line";
        NewLineQty: Decimal;
        NewLineNo: Integer;
    begin
        if xReqdQty < ShipDashBrdLine."Qty. To Ship" then begin
            NewLineQty := ShipDashBrdLine."Qty. To Ship" - xReqdQty;
            SalesHdr.Get(SalesHdr."Document Type"::Order, ShipDashBrdLine."Source No.");
            if SalesHdr.Status = SalesHdr.Status::Released then
                RelSalesDoc.Reopen(SalesHdr);

            SalesLine.Get(SalesHdr."Document Type", SalesHdr."No.", ShipDashBrdLine."Source Line No.");
            SalesLine2.Reset;
            SalesLine2.SetRange("Document Type", SalesHdr."Document Type");
            SalesLine2.SetRange("Document No.", SalesHdr."No.");
            if SalesLine2.FindLast then
                NewLineNo := SalesLine2."Line No." + 10000;

            NewSalesLine.Copy(SalesLine);
            NewSalesLine."Line No." := NewLineNo;
            NewSalesLine.Insert(true);
            NewSalesLine.Validate(Quantity, NewLineQty);
            NewSalesLine.Modify(true);
            RelSalesDoc.Run(SalesHdr);
        end;
    end;

    procedure AdjustShipQtyToOrderLine(var ShipDashbrd: Record "Shipment Dashboard ELA"; ShipmentNo: Code[20]; ShipmentLineNo: Integer; QtyToBeAdjusted: Decimal)
    var
        SalesHdr: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TransHdr: Record "Transfer Header";
        TransLine: Record "Transfer Line";
        WhseShipHdr: Record "Warehouse Shipment Header";
        WhseShipLine: Record "Warehouse Shipment Line";
        WhseShipLineCopy: Record "Warehouse Shipment Line" temporary;
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityLineCopy: Record "Warehouse Activity Line";
        ShipDashBrd2: Record "Shipment Dashboard ELA";
        // BillOfLadingDet: Record "Bill of Lading Detail";
        OrigWhseShipmentStatus: Option Open,Released;
        RedoWhseActLine: Boolean;
    begin
        //<<EN1.49
        if WhseShipHdr.Get(ShipDashbrd."Shipment No.") then begin
            OrigWhseShipmentStatus := WhseShipHdr.Status;
            if WhseShipHdr.Status = WhseShipHdr.Status::Released then
                ReleaseWhseShipment.Reopen(WhseShipHdr);

            if WhseShipLine.Get(ShipDashbrd."Shipment No.", ShipDashbrd."Shipment Line No.") then begin
                //tbr
                // BillOfLadingDet.Reset;
                // BillOfLadingDet.SetRange("Shipment No.", ShipDashbrd."Shipment No.");
                // BillOfLadingDet.SetRange("Shipment Line No.", ShipDashbrd."Shipment Line No.");
                // if BillOfLadingDet.FindFirst then
                //     BillOfLadingDet.Delete;

                WhseShipLineCopy.Copy(WhseShipLine);
                WhseShipLine.Delete;

                if ShipDashbrd."Source Document" = ShipDashbrd."Source Document"::"Sales Order" then begin
                    if SalesHdr.Get(SalesHdr."Document Type"::Order, ShipDashbrd."Source No.") then
                        if SalesHdr.Status = SalesHdr.Status::Released then
                            RelSalesDoc.Reopen(SalesHdr);

                    SalesLine.Get(SalesHdr."Document Type", SalesHdr."No.", ShipDashbrd."Source Line No.");
                    if ShipDashbrd."Qty. To Ship" > SalesLine.Quantity then
                        SalesLine."Ship Action ELA" := SalesLine."Ship Action ELA"::"Over Ship"
                    else
                        SalesLine."Ship Action ELA" := SalesLine."Ship Action ELA"::Cut;

                    SalesLine.Validate(Quantity, QtyToBeAdjusted);
                    SalesLine."Cut/Overship Qty. ELA" := ShipDashbrd."Cut/Overship"; //EN1.44
                    SalesLine."Completely Shipped" := (SalesLine."Outstanding Quantity" = 0); //<<EN1.08
                    SalesLine.Modify(true);
                end else
                    if ShipDashbrd."Source Document" = ShipDashbrd."Source Document"::"Outbound Transfer" then begin
                        // reopen to change qty on line.
                        if TransHdr.Get(ShipDashbrd."Source No.") then
                            if TransHdr.Status = TransHdr.Status::Released then
                                ReleaseTransferDoc.Reopen(TransHdr);
                        //Document No.,Line No.
                        if TransLine.Get(ShipDashbrd."Source No.", ShipDashbrd."Source Line No.") then begin
                            TransLine.Validate(Quantity, QtyToBeAdjusted);
                            TransLine."Completely Shipped" := (TransLine."Outstanding Quantity" = 0); //<<EN1.08
                            TransLine.Modify(true);
                        end;
                    end;

                WhseShipLine.Init;
                WhseShipLine.Copy(WhseShipLineCopy);
                WhseShipLine.Quantity := SalesLine.Quantity;

                //<<EN1.60
                WhseShipLine."Orig. Asked Qty. ELA" := SalesLine."Orig. Asked Qty. ELA";
                WhseShipLine."Last Modified Qty. ELA" := SalesLine."Last Modified Qty. ELA";
                //>>EN1.60

                WhseShipLine."Qty. (Base)" := SalesLine."Quantity (Base)";
                WhseShipLine."Qty. Outstanding" := SalesLine."Outstanding Quantity";
                WhseShipLine."Qty. Outstanding (Base)" := SalesLine."Outstanding Qty. (Base)";
                WhseShipLine."Cut/Overship Qty. ELA" := ShipDashbrd."Cut/Overship"; //<<EN1.44
                if SalesLine.Quantity = 0 then //EN1.44
                    WhseShipLine."Completely Picked" := true //EN1.44
                else //EN1.44
                    WhseShipLine."Completely Picked" :=
                      (WhseShipLine.Quantity = WhseShipLine."Qty. Picked") or (WhseShipLine."Qty. (Base)" =
                       WhseShipLine."Qty. Picked (Base)");  //<<EN1.15
                WhseShipLine.Insert;

                if ShipDashbrd."Source Document" = ShipDashbrd."Source Document"::"Sales Order" then begin
                    // RelSalesDoc.ExitIfNothingToRelease; // X 8/13  (replace process800 change with our own) // add this code....
                    RelSalesDoc.Run(SalesHdr);
                end else
                    if ShipDashbrd."Source Document" = ShipDashbrd."Source Document"::"Outbound Transfer" then
                        ReleaseTransferDoc.Reopen(TransHdr);

                if OrigWhseShipmentStatus = OrigWhseShipmentStatus::Released then
                    ReleaseWhseShipment.Release(WhseShipHdr);

                ShipDashbrd."Orig. Ordered Qty." := SalesLine."Orig. Asked Qty. ELA";
                //<<EN1.60
                ShipDashbrd."Last Modified Qty." := SalesLine."Last Modified Qty. ELA";  //>>EN1.60 //EN1.44
                                                                                         //<<EN1.15
                                                                                         //IF SalesLine.Quantity = 0 THEN
                ShipDashbrd.Completed := WhseShipLine."Completely Picked";
                //>>EN1.15
                ShipDashbrd.Modify;
            end;
        end; //EN1.49
    end;


    procedure CheckForPostedEntries(WhseActivLine: Record "Warehouse Activity Line")
    var
        RegWhseActLine: Record "Registered Whse. Activity Line";
    // BillofLadingDtl: Record "Bill of Lading Detail";
    begin
        // check for posted lines and they dont exists then delete the bol lines.
        RegWhseActLine.Reset;
        RegWhseActLine.SetRange("Pick Ticket No. ELA", WhseActivLine."No.");
        RegWhseActLine.SetRange("Pick Ticket Line No. ELA", WhseActivLine."Line No.");
        if not RegWhseActLine.FindFirst then begin
            //tbr
            // BillofLadingDtl.Reset;
            // BillofLadingDtl.SetRange("Pick Ticket No.", WhseActivLine."No.");
            // BillofLadingDtl.SetRange("Pick Ticket Line No.", WhseActivLine."Line No.");
            // if BillofLadingDtl.FindFirst then
            //     BillofLadingDtl.Delete(true);
        end;
    end;

    procedure UpdateRoleAssignment(SourceNo: Code[20]; SourceLineNo: Integer; SourceSubLineNo: Integer; SourceType: Integer; SourceSubType: Integer; AssignedRole: Code[20]; UpdateHeaders: Boolean; UpdateSource: Option " ",Shipment,"Task Queue",Activity,ShipBoard; ActivityType: Option " ","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick")
    var
        ShipDashbrd: Record "Shipment Dashboard ELA";
        WHShipHdr: Record "Warehouse Shipment Header";
        WHShipLine: Record "Warehouse Shipment Line";
        WhseRequest: Record "Warehouse Request";
        WhseActivityHdr: Record "Warehouse Activity Header";
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        if UpdateSource <> UpdateSource::ShipBoard then begin
            ShipDashbrd.Reset;
            ShipDashbrd.SetRange("Source No.", SourceNo);
            if not UpdateHeaders then begin
                ShipDashbrd.SetRange(Level, 1);
                ShipDashbrd.SetRange("Source Line No.", SourceLineNo);
                ShipDashbrd.SetRange("Source Type", SourceType);
                ShipDashbrd.SetRange("Source Subtype", SourceSubType);
            end;

            ShipDashbrd.SetRange(Completed, false);  //<<EN1.15
            if ShipDashbrd.FindSet then
                repeat
                    ShipDashbrd."Assigned App. Role" := AssignedRole;
                    ShipDashbrd.Modify;
                until ShipDashbrd.Next = 0;
        end;

        if UpdateSource <> UpdateSource::Shipment then begin
            if UpdateHeaders then begin
                WHShipHdr.Reset;
                // WHShipHdr.SetRange("Source Order No.", SourceNo);
                if WHShipHdr.FindFirst then begin
                    WHShipHdr."Assigned App. Role ELA" := AssignedRole;
                    WHShipHdr.Modify;
                end;
            end;

            WHShipLine.Reset;
            WHShipLine.SetRange("Source No.", SourceNo);
            if not UpdateHeaders then begin
                WHShipLine.SetRange("Source Line No.", SourceLineNo);
                WHShipLine.SetRange("Source Type", SourceType);
                WHShipLine.SetRange("Source Subtype", SourceSubType);

            end;
            WHShipLine.SetRange("Completely Picked", false);  //<<EN1.15
            if WHShipLine.FindSet then
                repeat
                    WHShipLine."Assigned App. Role ELA" := AssignedRole;
                    WHShipLine.Modify;
                until WHShipLine.Next = 0;
        end;

        if UpdateSource <> UpdateSource::Activity then begin
            WhseActivityLine.Reset;
            if ActivityType = ActivityType::Movement then begin
                WhseActivityLine.SetRange("No.", SourceNo);
                WhseActivityLine.SetRange("Line No.", SourceLineNo);
            end else begin
                WhseActivityLine.SetRange("Source No.", SourceNo);
                //<<EN1.15
                if not UpdateHeaders then begin
                    WhseActivityLine.SetRange("Source Line No.", SourceLineNo);
                    WhseActivityLine.SetRange("Source Type", SourceType);
                    WhseActivityLine.SetRange("Source Subtype", SourceSubType);
                    WhseActivityLine.SetRange("Source Subline No.", SourceSubLineNo);
                end;
                //>>EN1.15
            end;
            if WhseActivityLine.FindSet then
                repeat
                    WhseActivityLine."Assigned App. Role ELA" := AssignedRole;
                    WhseActivityLine.Modify;
                until WhseActivityLine.Next = 0;


        end;
    end;

    procedure UpdateUserAssignment(SourceNo: Code[20]; SourceLineNo: Integer; SourceSubLineNo: Integer; SourceType: Integer; SourceSubType: Integer; AssignedTo: Code[10]; UpdateHeaders: Boolean; UpdateSource: Option " ",Shipment,"Task Queue",Activity,ShipBoard; ActivityType: Option " ","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick")
    var
        ShipDashbrd: Record "Shipment Dashboard ELA";
        WHShipHdr: Record "Warehouse Shipment Header";
        WHShipLine: Record "Warehouse Shipment Line";
        WhseRequest: Record "Warehouse Request";
        WhseActivityHdr: Record "Warehouse Activity Header";
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        if UpdateSource <> UpdateSource::ShipBoard then begin
            ShipDashbrd.Reset;
            ShipDashbrd.SetRange("Source No.", SourceNo);
            if not UpdateHeaders then begin
                ShipDashbrd.SetRange(Level, 1);
                ShipDashbrd.SetRange("Source Line No.", SourceLineNo);
                ShipDashbrd.SetRange("Source Type", SourceType);
                ShipDashbrd.SetRange("Source Subtype", SourceSubType);
            end;

            ShipDashbrd.SetRange(Completed, false);
            if ShipDashbrd.FindSet then
                repeat
                    ShipDashbrd."Assigned App. User" := AssignedTo;
                    ShipDashbrd.Modify;
                until ShipDashbrd.Next = 0;
        end;

        if UpdateSource <> UpdateSource::Shipment then begin
            if UpdateHeaders then begin
                WHShipHdr.Reset;
                // WHShipHdr.SetRange("Source Order No.", SourceNo);
                if WHShipHdr.FindFirst then begin
                    WHShipHdr."Assigned To ELA" := AssignedTo;
                    WHShipHdr.Modify;
                end;
            end;

            WHShipLine.Reset;
            WHShipLine.SetRange("Source No.", SourceNo);
            if not UpdateHeaders then begin
                WHShipLine.SetRange("Source Line No.", SourceLineNo);
                WHShipLine.SetRange("Source Type", SourceType);
                WHShipLine.SetRange("Source Subtype", SourceSubType);
            end;

            WHShipLine.SetRange("Completely Picked", false);  //<<EN1.15
            if WHShipLine.FindSet then
                repeat
                    WHShipLine."Assigned To ELA" := AssignedTo;
                    WHShipLine.Modify;
                until WHShipLine.Next = 0;
        end;

        if UpdateSource <> UpdateSource::Activity then begin
            WhseActivityHdr.Reset;
            if ActivityType = ActivityType::Movement then
                WhseActivityHdr.SetRange("No.", SourceNo)
            else begin
                WhseActivityHdr.SetRange("Source No.", SourceNo);
            end;

            if WhseActivityHdr.FindFirst then begin
                if UpdateHeaders then begin
                    WhseActivityHdr."Assigned App. User ELA" := AssignedTo;
                    WhseActivityHdr.Modify;
                end;
            end;
            WhseActivityLine.Reset;
            if ActivityType = ActivityType::Movement then begin
                WhseActivityLine.SetRange("No.", SourceNo);
                WhseActivityLine.SetRange("Line No.", SourceLineNo);
            end else begin
                //<<EN1.15
                WhseActivityLine.SetRange("Source No.", SourceNo);
                if not UpdateHeaders then begin
                    WhseActivityLine.SetRange("Source Line No.", SourceLineNo);
                    WhseActivityLine.SetRange("Source Type", SourceType);
                    WhseActivityLine.SetRange("Source Subtype", SourceSubType);
                    WhseActivityLine.SetRange("Source Subline No.", SourceSubLineNo);
                end;
                //>>EN1.15
            end;

            if WhseActivityLine.FindSet then
                repeat
                    WhseActivityLine."Assigned App. User ELA" := AssignedTo;
                    //<<EN1.10
                    if AssignedTo <> '' then
                        WhseActivityLine."Released At ELA" := CurrentDateTime
                    else
                        WhseActivityLine."Released At ELA" := 0DT;
                    //>>EN1.10

                    WhseActivityLine.Modify;
                until WhseActivityLine.Next = 0;
        end;
    end;


    procedure UpdatePackingUnit(SourceNo: Code[20]; SourceLineNo: Integer; SourceSubLineNo: Integer; SourceType: Integer; SourceSubType: Integer; PackingUnit: Option; UpdateHeaders: Boolean; UpdateSource: Option " ",Shipment,"Task Queue",Activity,ShipBoard; ActivityType: Option " ","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick")
    var
        ShipDashbrd: Record "Shipment Dashboard ELA";
        WHShipHdr: Record "Warehouse Shipment Header";
        WHShipLine: Record "Warehouse Shipment Line";
        WhseRequest: Record "Warehouse Request";
        WhseActivityHdr: Record "Warehouse Activity Header";
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        //<<EN1.30
        if UpdateSource <> UpdateSource::ShipBoard then begin
            ShipDashbrd.Reset;
            ShipDashbrd.SetRange("Source No.", SourceNo);
            if not UpdateHeaders then begin
                ShipDashbrd.SetRange(Level, 1);
                ShipDashbrd.SetRange("Source Line No.", SourceLineNo);
                ShipDashbrd.SetRange("Source Type", SourceType);
                ShipDashbrd.SetRange("Source Subtype", SourceSubType);
            end;

            // ShipDashbrd.SetRange(Completed, false);
            // if ShipDashbrd.FindSet then
            //     repeat
            //         ShipDashbrd."Packing Unit" := PackingUnit;
            //         ShipDashbrd.Modify;
            //     until ShipDashbrd.Next = 0; //tbr
        end;

        if UpdateSource <> UpdateSource::Shipment then begin
            // if UpdateHeaders then begin
            //     WHShipHdr.Reset;
            //     WHShipHdr.SetRange("Source Order No.", SourceNo);
            //     if WHShipHdr.FindFirst then begin
            //         WHShipHdr."Packing Unit" := PackingUnit;
            //         WHShipHdr.Modify;
            //     end;
            // end; //tbr

            WHShipLine.Reset;
            WHShipLine.SetRange("Source No.", SourceNo);
            if not UpdateHeaders then begin
                WHShipLine.SetRange("Source Line No.", SourceLineNo);
                WHShipLine.SetRange("Source Type", SourceType);
                WHShipLine.SetRange("Source Subtype", SourceSubType);
            end;

            // WHShipLine.SetRange("Completely Picked", false);  //<<EN1.15
            // if WHShipLine.FindSet then
            //     repeat
            //         WHShipLine."Packing Unit" := PackingUnit;
            //         WHShipLine.Modify;
            //     until WHShipLine.Next = 0; //tbr
        end;

        if UpdateSource <> UpdateSource::Activity then begin
            WhseActivityHdr.Reset;
            if ActivityType = ActivityType::Movement then
                WhseActivityHdr.SetRange("No.", SourceNo)
            else begin
                WhseActivityHdr.SetRange("Source No.", SourceNo);
            end;

            if WhseActivityHdr.FindFirst then begin
                // if UpdateHeaders then begin
                //     WhseActivityHdr."Packing Unit" := PackingUnit;
                //     WhseActivityHdr.Modify;
                // end; //tbr

                WhseActivityLine.Reset;
                if ActivityType = ActivityType::Movement then begin
                    WhseActivityLine.SetRange("No.", SourceNo);
                    WhseActivityLine.SetRange("Line No.", SourceLineNo);
                end else begin
                    //<<EN1.15
                    WhseActivityLine.SetRange("Source No.", SourceNo);
                    if not UpdateHeaders then begin
                        WhseActivityLine.SetRange("Source Line No.", SourceLineNo);
                        WhseActivityLine.SetRange("Source Type", SourceType);
                        WhseActivityLine.SetRange("Source Subtype", SourceSubType);
                        WhseActivityLine.SetRange("Source Subline No.", SourceSubLineNo);
                    end;
                    //>>EN1.15
                end;

                // if WhseActivityLine.FindSet then
                //     repeat
                //         // WhseActivityLine."Packing Unit" := PackingUnit;
                //         WhseActivityLine.Modify;
                //     until WhseActivityLine.Next = 0;
            end;
        end;
        //>>EN1.30
    end;


    procedure UpdateUserRoleAssignmentX(SourceNo: Code[20]; SourceLineNo: Integer; SourceSubLineNo: Integer; SourceType: Integer; SourceSubType: Integer; AssignedTo: Code[10]; AssignedRole: Code[20]; UpdateHeaders: Boolean; UpdateSource: Option " ",Shipment,"Task Queue",Activity,ShipBoard; ActivityType: Option " ","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick")
    var
        ShipDashbrd: Record "Shipment Dashboard ELA";
        WHShipHdr: Record "Warehouse Shipment Header";
        WHShipLine: Record "Warehouse Shipment Line";
        WhseRequest: Record "Warehouse Request";
        WhseActivityHdr: Record "Warehouse Activity Header";
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        if UpdateSource <> UpdateSource::ShipBoard then begin
            ShipDashbrd.Reset;
            ShipDashbrd.SetRange("Source No.", SourceNo);
            if not UpdateHeaders then begin
                ShipDashbrd.SetRange(Level, 1);
                ShipDashbrd.SetRange("Source Line No.", SourceLineNo);
                ShipDashbrd.SetRange("Source Type", SourceType);
                ShipDashbrd.SetRange("Source Subtype", SourceSubType);
            end;

            if ShipDashbrd.FindSet then
                repeat
                    ShipDashbrd."Assigned App. User" := AssignedTo;
                    ShipDashbrd."Assigned App. Role" := AssignedRole;
                    ShipDashbrd.Modify;
                until ShipDashbrd.Next = 0;
        end;

        if UpdateSource <> UpdateSource::Shipment then begin
            if UpdateHeaders then begin
                WHShipHdr.Reset;
                // WHShipHdr.SetRange("Source Order No.", SourceNo);
                if WHShipHdr.FindFirst then begin
                    WHShipHdr."Assigned To ELA" := AssignedTo;
                    WHShipHdr."Assigned App. Role ELA" := AssignedRole;
                    WHShipHdr.Modify;

                    WHShipLine.Reset;
                    WHShipLine.SetRange("Source No.", SourceNo);
                    //WHShipLine.SETRANGE("Source Line No.",SourceLineNo);
                    WHShipLine.SetRange("Source Type", SourceType);
                    WHShipLine.SetRange("Source Subtype", SourceSubType);
                    if WHShipLine.FindSet then
                        repeat
                            WHShipLine."Assigned To ELA" := AssignedTo;
                            WHShipLine."Assigned App. Role ELA" := AssignedRole;
                            WHShipLine.Modify;
                        until WHShipLine.Next = 0;
                end;
            end else begin
                WHShipLine.Reset;
                WHShipLine.SetRange("Source No.", SourceNo);
                WHShipLine.SetRange("Source Line No.", SourceLineNo);
                WHShipLine.SetRange("Source Type", SourceType);
                WHShipLine.SetRange("Source Subtype", SourceSubType);
                if WHShipLine.FindSet then begin
                    WHShipLine."Assigned To ELA" := AssignedTo;
                    WHShipLine."Assigned App. Role ELA" := AssignedRole;
                    WHShipLine.Modify;
                end;
            end;
        end;

        if UpdateSource <> UpdateSource::Activity then begin
            WhseActivityHdr.Reset;
            if ActivityType = ActivityType::Movement then
                WhseActivityHdr.SetRange("No.", SourceNo)
            else begin
                WhseActivityHdr.SetRange("Source No.", SourceNo);
                //WhseActivityHdr.SETRANGE("Source Type",SourceType);
                //WhseActivityHdr.SETRANGE("Source Subtype",SourceSubType);
            end;

            if WhseActivityHdr.FindFirst then begin
                WhseActivityLine.Reset;
                if ActivityType = ActivityType::Movement then begin
                    WhseActivityLine.SetRange("No.", SourceNo);
                    WhseActivityLine.SetRange("Line No.", SourceLineNo);
                end else begin
                    WhseActivityLine.SetRange("Source No.", SourceNo);
                    WhseActivityLine.SetRange("Source Line No.", SourceLineNo);
                    WhseActivityLine.SetRange("Source Type", SourceType);
                    WhseActivityLine.SetRange("Source Subtype", SourceSubType);
                    WhseActivityLine.SetRange("Source Subline No.", SourceSubLineNo);
                end;
                if WhseActivityLine.FindSet then
                    repeat
                        WhseActivityLine."Assigned App. User ELA" := AssignedTo;
                        WhseActivityLine."Assigned App. Role ELA" := AssignedRole;
                        //<<EN1.10
                        if AssignedTo <> '' then
                            WhseActivityLine."Released At ELA" := CurrentDateTime
                        else
                            WhseActivityLine."Released At ELA" := 0DT;
                        //>>EN1.10

                        WhseActivityLine.Modify;
                    until WhseActivityLine.Next = 0;

                if UpdateHeaders then begin
                    WhseActivityHdr."Assigned App. User ELA" := AssignedTo;
                    WhseActivityHdr."Assigned App. Role ELA" := AssignedRole;
                    WhseActivityHdr.Modify;
                end;
            end;
        end;
    end;

    procedure LoadStockAdjustmentInfo(ItemNo: Code[20])
    var
        ShipDashBrd: Record "Shipment Dashboard ELA";
        // ShipStockAllocation: Record "Ship Stock Allocation";
        NextLineNo: Integer;
    begin
        // ShipStockAllocation.DeleteAll;
        NextLineNo := 1;
        ShipDashBrd.Reset;
        ShipDashBrd.SetRange(Level, 1);
        ShipDashBrd.SetRange("Item No.", ItemNo);
        if ShipDashBrd.FindSet then
            repeat
                //tbr
                // ShipStockAllocation.Init;
                // ShipStockAllocation.ID := NextLineNo;
                // ShipStockAllocation."Item No." := ShipDashBrd."Item No.";
                // ShipStockAllocation."Item Description" := ShipDashBrd."Item Description";
                // ShipStockAllocation."Shipment Date" := ShipDashBrd."Shipment Date";
                // ShipStockAllocation."Order No." := ShipDashBrd."Source No.";
                // ShipStockAllocation."Order Line No." := ShipDashBrd."Source Line No.";
                // ShipStockAllocation."Qty. Reqd." := ShipDashBrd."Qty. Reqd.";
                // ShipStockAllocation."Qty. Allocated" := 0;
                // ShipStockAllocation.Selected := true;
                // ShipStockAllocation."User ID" := UserId;
                // ShipStockAllocation.Insert;
                NextLineNo := NextLineNo + 1;
            until ShipDashBrd.Next = 0;
    end;


    procedure "--Bill of lading"()
    begin
    end;


    procedure CreateBillOfLading(DocumentNo: Code[20]; ShipmentDocNo: Code[20]; LoadID: Code[20]): Code[20]
    var
        // PalletContainerInfo: Record "Pallet Container Info";
        // BillOfLadingHdr: Record "Bill of Lading Header";
        SalesHdr: Record "Sales Header";
    // DeliveryLoadHdr: Record "Delivery Load Header";
    begin
        //<<EN1.15
        if (LoadID = '') then
            exit; // hf 6/25 ks
        // BillOfLadingHdr.Reset;
        // BillOfLadingHdr.SetRange("Sales Order No.", DocumentNo);
        // BillOfLadingHdr.SetRange("Load ID", LoadID);                //EN1.49
        // if not BillOfLadingHdr.FindFirst then begin
        //     Clear(BillOfLadingHdr);

        //     BillOfLadingHdr.Init;
        //     BillOfLadingHdr."No." := BillOfLadingHdr.GetNextBOLNo();
        //     BillOfLadingHdr.Insert;
        //     //<<EN1.41
        //     if SalesHdr.Get(SalesHdr."Document Type"::Order, DocumentNo) then
        //         BillOfLadingHdr."Source Document" := BillOfLadingHdr."Source Document"::"Sales Order"
        //     else
        //         BillOfLadingHdr."Source Document" := BillOfLadingHdr."Source Document"::"Outbound Transfer";
        //     //>>EN1.41
        //     BillOfLadingHdr.Validate("Sales Order No.", DocumentNo);
        //     BillOfLadingHdr.Validate("Load ID", LoadID);            //EN1.49
        //     BillOfLadingHdr.Status := BillOfLadingHdr.Status::"In Process";
        //     //<<EN1.49
        //     DeliveryLoadHdr.Reset;
        //     if DeliveryLoadHdr.Get(LoadID, 2) then begin
        //         //<<EN1.52
        //         BillOfLadingHdr."Product Temp." := DeliveryLoadHdr."Product Temp.";
        //         BillOfLadingHdr."Truck Temp." := DeliveryLoadHdr."Truck Temp.";
        //         BillOfLadingHdr."Seal No." := DeliveryLoadHdr."Seal No.";
        //         BillOfLadingHdr."Temp Tag No." := DeliveryLoadHdr."Temp Tag No.";
        //         BillOfLadingHdr.Loader := DeliveryLoadHdr.Loader;
        //         BillOfLadingHdr.Checker := DeliveryLoadHdr.Checker;
        //         BillOfLadingHdr."Door No." := DeliveryLoadHdr."Door No.";
        //         BillOfLadingHdr."Trailer No." := DeliveryLoadHdr."Trailer No.";
        //         BillOfLadingHdr."Shipper Person" := DeliveryLoadHdr."Shipper Person";
        //         BillOfLadingHdr."Carrier Name" := DeliveryLoadHdr."Carrier Name";
        //         BillOfLadingHdr."Carrier Person" := DeliveryLoadHdr."Carrier Person";
        //         BillOfLadingHdr."Shipment Method Code" := DeliveryLoadHdr."Shipment Method Code";
        //         BillOfLadingHdr."Loading Date" := DeliveryLoadHdr."Load Date";
        //         BillOfLadingHdr."External Document No." := DeliveryLoadHdr."External Document No.";
        //         BillOfLadingHdr."Customer PO No." := DeliveryLoadHdr."Customer PO No.";
        //         BillOfLadingHdr."Member PO No." := DeliveryLoadHdr."Member PO No.";
        //         BillOfLadingHdr."Ship-to Code" := DeliveryLoadHdr."Ship-to Code";
        //         BillOfLadingHdr."Ship-to" := DeliveryLoadHdr."Ship-to";
        //         //>>EN1.52
        //     end;
        //     //>>EN1.49
        //     BillOfLadingHdr.Modify;
        // end;

        // UpdateBOLFromRegisteredPicksCo(BillOfLadingHdr."No."); //<<EN1.15 + EN1.18 + EN1.49
        // exit(BillOfLadingHdr."No.");
        // //>>EN1.15
    end;


    procedure UpdateBOLFromRegisteredPicks(BillOfLadingNo: Code[20])
    var
        // BillOfLadingHdr: Record "EN WMS Bill of Lading Header";
        // BillOfLadingHdr2: Record "EN WMS Bill of Lading Header";
        // BillOfLadingDtl: Record "EN WMS Bill of Lading Detail";
        // PalletContainerInfo: Record "Pallet Container Info";
        WhseShipLine: Record "Warehouse Shipment Line";
        WhseActLine: Record "Warehouse Activity Line";
        RegWhseActLine: Record "Registered Whse. Activity Line";
        Item: Record Item;
        NextLineNo: Integer;
    begin
        // 
        //<<EN1.23
        // if BillOfLadingHdr.Get(BillOfLadingNo) then begin //EN1.14
        //                                                   //<<EN1.26
        //     if BillOfLadingHdr.Locked then
        //         exit;

        //     if GuiAllowed then
        //         if BillOfLadingHdr."Manual BOL" then
        //             if not Confirm('this bol is manually maintained. if you update then you may lose changes') then
        //                 exit;
        //     ////>>EN1.26

        //     BillOfLadingDtl.Reset;
        //     BillOfLadingDtl.SetRange("Bill of Lading No.", BillOfLadingNo);
        //     BillOfLadingDtl.DeleteAll;

        //     BillOfLadingDtl.Reset;
        //     BillOfLadingDtl.SetRange(BillOfLadingDtl."Bill of Lading No.", BillOfLadingNo);
        //     if BillOfLadingDtl.FindLast then
        //         NextLineNo := BillOfLadingDtl."Line No." + 10000
        //     else
        //         NextLineNo := 10000;

        //     PalletContainerInfo.Reset;
        //     PalletContainerInfo.SetRange("Source Doc. No.", BillOfLadingHdr."Sales Order No.");
        //     PalletContainerInfo.SetFilter("Line Status", '<>%1', PalletContainerInfo."Line Status"::Deleted);
        //     PalletContainerInfo.SetFilter("Pallet No.", '<>%1', 0);
        //     if PalletContainerInfo.FindSet then
        //         repeat
        //             WhseActLine.Reset;
        //             WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::Pick);
        //             WhseActLine.SetRange("Action Type", WhseActLine."Action Type"::Take);
        //             WhseActLine.SetRange("Container ID", PalletContainerInfo."Container ID");
        //             WhseActLine.SetRange("Pallet No.", PalletContainerInfo."Pallet No.");
        //             WhseActLine.SetRange("Pallet Line No.", PalletContainerInfo."Pallet Line No.");
        //             if WhseActLine.FindFirst then begin
        //                 BillOfLadingDtl.Reset;
        //                 BillOfLadingDtl.SetRange("Bill of Lading No.", BillOfLadingNo);
        //                 BillOfLadingDtl.SetRange("Container ID", WhseActLine."Container ID");
        //                 BillOfLadingDtl.SetRange("Pallet No.", WhseActLine."Pallet No.");
        //                 BillOfLadingDtl.SetRange("Pallet Line No.", WhseActLine."Pallet Line No.");
        //                 BillOfLadingDtl.SetRange("Pick Ticket No.", WhseActLine."No.");  //<<EN1.17
        //                 BillOfLadingDtl.SetRange("Pick Ticket Line No.", WhseActLine."Line No.");  //<<EN1.17
        //                 if not BillOfLadingDtl.FindFirst then begin
        //                     BillOfLadingDtl.Init;
        //                     BillOfLadingDtl."Bill of Lading No." := BillOfLadingNo;
        //                     BillOfLadingDtl."Line No." := NextLineNo;
        //                     BillOfLadingDtl."Order No." := WhseActLine."Source No.";
        //                     BillOfLadingDtl."Order Line No." := WhseActLine."Source Line No.";
        //                     BillOfLadingDtl."Order Sub Line No." := WhseActLine."Source Subline No.";
        //                     BillOfLadingDtl."Container ID" := WhseActLine."Container ID";
        //                     BillOfLadingDtl."Pallet No." := WhseActLine."Pallet No.";
        //                     BillOfLadingDtl."Pallet Line No." := WhseActLine."Pallet Line No.";
        //                     BillOfLadingDtl."Item No." := WhseActLine."Item No.";
        //                     BillOfLadingDtl.Description := WhseActLine.Description;
        //                     BillOfLadingDtl."Shipment No." := WhseActLine."Whse. Document No.";
        //                     BillOfLadingDtl."Shipment Line No." := WhseActLine."Whse. Document Line No.";
        //                     BillOfLadingDtl."Picked By" := WhseActLine."Assigned To";
        //                     //BillOfLadingDtl.Weight := WhseActLine.Weight;
        //                     BillOfLadingDtl.Validate("Product Date", WhseActLine."Code Date"); // EN1.40
        //                     BillOfLadingDtl."Pick Ticket No." := WhseActLine."No."; //EN1.23
        //                     BillOfLadingDtl."Pick Ticket Line No." := WhseActLine."Line No.";
        //                     //<<EN1.42
        //                     BillOfLadingDtl.Validate("Qty on Pallet", WhseActLine.Quantity);
        //                     if BillOfLadingDtl.Weight = 0 then
        //                         BillOfLadingDtl.Weight := WhseActLine.Weight;
        //                     //>>EN1.42
        //                     BillOfLadingDtl."Unit of Measure" := WhseActLine."Unit of Measure Code";
        //                     BillOfLadingDtl."Line Status" := PalletContainerInfo."Line Status"; //EN1.23
        //                     BillOfLadingDtl.Insert;
        //                     NextLineNo := NextLineNo + 10000;
        //                 end;
        //             end;
        //         until PalletContainerInfo.Next = 0;

        //     RegWhseActLine.Reset;
        //     RegWhseActLine.SetRange("Activity Type", RegWhseActLine."Activity Type"::Pick);
        //     RegWhseActLine.SetRange("Action Type", RegWhseActLine."Action Type"::Take);
        //     RegWhseActLine.SetRange("Source No.", BillOfLadingHdr."Sales Order No.");
        //     if RegWhseActLine.FindSet then
        //         repeat
        //             BillOfLadingDtl.Reset;
        //             BillOfLadingDtl.SetRange("Bill of Lading No.", BillOfLadingNo);
        //             BillOfLadingDtl.SetRange("Container ID", RegWhseActLine."Container ID");
        //             BillOfLadingDtl.SetRange("Pallet No.", RegWhseActLine."Pallet No.");
        //             BillOfLadingDtl.SetRange("Pallet Line No.", RegWhseActLine."Pallet Line No.");
        //             BillOfLadingDtl.SetRange("Pick Ticket No.", RegWhseActLine."Pick Ticket No");  //<<EN1.17
        //             BillOfLadingDtl.SetRange("Pick Ticket Line No.", RegWhseActLine."Pick Ticket Line No.");  //<<EN1.17
        //             if not BillOfLadingDtl.FindFirst then begin
        //                 BillOfLadingDtl.Init;
        //                 BillOfLadingDtl."Bill of Lading No." := BillOfLadingNo;
        //                 BillOfLadingDtl."Line No." := NextLineNo;
        //                 BillOfLadingDtl."Order No." := RegWhseActLine."Source No.";
        //                 BillOfLadingDtl."Order Line No." := RegWhseActLine."Source Line No.";
        //                 BillOfLadingDtl."Order Sub Line No." := RegWhseActLine."Source Subline No.";
        //                 BillOfLadingDtl."Container ID" := RegWhseActLine."Container ID";
        //                 BillOfLadingDtl."Pallet No." := RegWhseActLine."Pallet No.";
        //                 BillOfLadingDtl."Pallet Line No." := RegWhseActLine."Pallet Line No.";
        //                 BillOfLadingDtl."Item No." := RegWhseActLine."Item No.";
        //                 BillOfLadingDtl.Description := RegWhseActLine.Description;
        //                 BillOfLadingDtl."Shipment No." := RegWhseActLine."Whse. Document No.";
        //                 BillOfLadingDtl."Shipment Line No." := RegWhseActLine."Whse. Document Line No.";
        //                 BillOfLadingDtl."Picked By" := RegWhseActLine."Assigned To";
        //                 BillOfLadingDtl.Validate("Product Date", RegWhseActLine."Code Date"); // EN1.40
        //                 BillOfLadingDtl."Pick Ticket No." := RegWhseActLine."Pick Ticket No"; //EN1.23
        //                 BillOfLadingDtl."Pick Ticket Line No." := RegWhseActLine."Pick Ticket Line No.";
        //                 //<<EN1.42
        //                 BillOfLadingDtl.Validate("Qty on Pallet", RegWhseActLine.Quantity);
        //                 if BillOfLadingDtl.Weight = 0 then
        //                     BillOfLadingDtl.Weight := RegWhseActLine.Weight;
        //                 //>>EN1.42
        //                 BillOfLadingDtl."Unit of Measure" := RegWhseActLine."Unit of Measure Code";
        //                 BillOfLadingDtl."Line Status" := PalletContainerInfo."Line Status"; //EN1.23
        //                 BillOfLadingDtl.Insert;
        //                 NextLineNo := NextLineNo + 10000;
        //             end else begin
        //                 BillOfLadingDtl.Weight := RegWhseActLine.Weight;
        //                 BillOfLadingDtl.Validate("Product Date", RegWhseActLine."Code Date"); //EN1.40
        //                 BillOfLadingDtl."Pick Ticket No." := RegWhseActLine."Pick Ticket No"; //EN1.23
        //                 BillOfLadingDtl."Pick Ticket Line No." := RegWhseActLine."Pick Ticket Line No."; //EN1.23
        //                                                                                                  //<<EN1.42
        //                 BillOfLadingDtl.Validate("Qty on Pallet", BillOfLadingDtl."Qty on Pallet" + RegWhseActLine.Quantity);
        //                 if BillOfLadingDtl.Weight = 0 then
        //                     BillOfLadingDtl.Weight := RegWhseActLine.Weight;
        //                 //>>EN1.42
        //                 BillOfLadingDtl.Modify;
        //             end;
        //         until RegWhseActLine.Next = 0;
        // end;
        // //>>EN1.15 + EN1.23
    end;


    // procedure AddBillOfLadingLine(BillOfLadingNo: Code[20]; PalletContainerInfo: Record "Pallet Container Info")
    // var
    //     // BillOfLadingHdr: Record "Bill of Lading Header";
    //     // BillOfLadingDtl: Record "Bill of Lading Detail";
    //     WhseShipLine: Record "Warehouse Shipment Line";
    //     WhseActLine: Record "Warehouse Activity Line";
    //     RegWhseActLine: Record "Registered Whse. Activity Line";
    //     Item: Record Item;
    //     NextLineNo: Integer;
    // begin
    //     //<<EN1.14 + EN1.18 + EN1.23
    //     // if BillOfLadingHdr.Get(BillOfLadingNo) then begin
    //     //     BillOfLadingDtl.Reset;
    //     //     BillOfLadingDtl.SetRange(BillOfLadingDtl."Bill of Lading No.", BillOfLadingNo);
    //     //     if BillOfLadingDtl.FindLast then
    //     //         NextLineNo := BillOfLadingDtl."Line No." + 10000
    //     //     else
    //     //         NextLineNo := 10000;

    //     //     //<<EN1.15
    //     //     BillOfLadingDtl.Reset;
    //     //     BillOfLadingDtl.SetRange("Bill of Lading No.", BillOfLadingNo);
    //     //     BillOfLadingDtl.SetRange("Container ID", PalletContainerInfo."Container ID");
    //     //     BillOfLadingDtl.SetRange("Pallet No.", PalletContainerInfo."Pallet No.");
    //     //     BillOfLadingDtl.SetRange("Pallet Line No.", PalletContainerInfo."Pallet Line No.");
    //     //     BillOfLadingDtl.SetFilter("Line Status", '<>%1', BillOfLadingDtl."Line Status"::Deleted); //<<EN1.21
    //     //     if not BillOfLadingDtl.FindFirst then begin
    //     //         BillOfLadingDtl.Init;
    //     //         BillOfLadingDtl."Bill of Lading No." := BillOfLadingNo;
    //     //         BillOfLadingDtl."Line No." := NextLineNo;
    //     //         BillOfLadingDtl."Order No." := PalletContainerInfo."Source Doc. No.";
    //     //         BillOfLadingDtl."Order Line No." := PalletContainerInfo."Source Doc Line No.";
    //     //         BillOfLadingDtl."Order Sub Line No." := PalletContainerInfo."Source Doc Sub Line No.";
    //     //         BillOfLadingDtl."Container ID" := PalletContainerInfo."Container ID";
    //     //         BillOfLadingDtl."Pallet No." := PalletContainerInfo."Pallet No.";
    //     //         BillOfLadingDtl."Pallet Line No." := PalletContainerInfo."Pallet Line No.";
    //     //         BillOfLadingDtl."Item No." := PalletContainerInfo."Item No.";
    //     //         BillOfLadingDtl."Unit of Measure" := PalletContainerInfo."Unit of Measure";  //EN1.00
    //     //         BillOfLadingDtl.Insert;  //EN1.43
    //     //     end;

    //     //     BillOfLadingDtl.Validate("Qty on Pallet", PalletContainerInfo.Quantity); //En1.00

    //     //     WhseShipLine.Reset;
    //     //     WhseShipLine.SetRange("Source Type", WhseShipLine."Source Type"::"37");
    //     //     WhseShipLine.SetRange("Source Subtype", WhseShipLine."Source Subtype"::"1");
    //     //     WhseShipLine.SetRange("Source No.", PalletContainerInfo."Source Doc. No.");
    //     //     WhseShipLine.SetRange("Source Line No.", PalletContainerInfo."Source Doc Line No.");
    //     //     if WhseShipLine.FindFirst then begin
    //     //         //<<EN1.14
    //     //         if BillOfLadingHdr."Shipment Doc. No." = '' then begin
    //     //             BillOfLadingHdr."Shipment Doc. No." := WhseShipLine."No.";
    //     //         end;
    //     //         //>>EN1.14
    //     //         BillOfLadingDtl."Shipment No." := WhseShipLine."No.";
    //     //         BillOfLadingDtl."Shipment Line No." := WhseShipLine."Line No.";
    //     //         BillOfLadingDtl.Description := WhseShipLine.Description;
    //     //     end else begin
    //     //         if Item.Get(PalletContainerInfo."Item No.") then
    //     //             BillOfLadingDtl.Description := Item.Description;
    //     //     end;

    //     //     WhseActLine.Reset;
    //     //     WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::Pick);
    //     //     WhseActLine.SetRange("Source Type", WhseActLine."Source Type"::"37");
    //     //     WhseActLine.SetRange("Source Subtype", WhseActLine."Source Subtype"::"1");
    //     //     WhseActLine.SetRange("Source No.", PalletContainerInfo."Source Doc. No.");
    //     //     WhseActLine.SetRange("Source Line No.", PalletContainerInfo."Source Doc Line No.");
    //     //     WhseActLine.SetRange("Container ID", PalletContainerInfo."Container ID");
    //     //     WhseActLine.SetRange("Pallet No.", PalletContainerInfo."Pallet No.");
    //     //     WhseActLine.SetRange("Pallet Line No.", PalletContainerInfo."Pallet Line No.");
    //     //     if WhseActLine.FindFirst then begin
    //     //         BillOfLadingDtl.Validate("Product Date", PalletContainerInfo."Code Date"); //<<EN1.09
    //     //                                                                                    //EN1.42
    //     //         if BillOfLadingDtl.Weight = 0 then
    //     //             BillOfLadingDtl.Weight := WhseActLine.Weight; //<<EN1.14
    //     //                                                           //>>EN1.42
    //     //         BillOfLadingDtl."Pick Ticket No." := WhseActLine."No.";
    //     //         BillOfLadingDtl."Pick Ticket Line No." := WhseActLine."Line No.";
    //     //     end else begin
    //     //         RegWhseActLine.Reset;
    //     //         RegWhseActLine.SetRange("Activity Type", RegWhseActLine."Activity Type"::Pick);
    //     //         RegWhseActLine.SetRange("Activity Type", RegWhseActLine."Action Type"::Take); //EN1.38
    //     //         RegWhseActLine.SetRange("Source Type", WhseActLine."Source Type"::"37");
    //     //         RegWhseActLine.SetRange("Source Subtype", WhseActLine."Source Subtype"::"1");
    //     //         RegWhseActLine.SetRange("Source No.", PalletContainerInfo."Source Doc. No.");
    //     //         RegWhseActLine.SetRange("Source Line No.", PalletContainerInfo."Source Doc Line No.");
    //     //         RegWhseActLine.SetRange("Container ID", PalletContainerInfo."Container ID");
    //     //         RegWhseActLine.SetRange("Pallet No.", PalletContainerInfo."Pallet No.");
    //     //         RegWhseActLine.SetRange("Pallet Line No.", PalletContainerInfo."Pallet Line No.");
    //     //         if RegWhseActLine.FindFirst then begin
    //     //             BillOfLadingDtl.Validate("Product Date", PalletContainerInfo."Code Date");
    //     //             //EN1.42
    //     //             if BillOfLadingDtl.Weight = 0 then
    //     //                 BillOfLadingDtl.Weight := RegWhseActLine.Weight; //>>EN1.42
    //     //             BillOfLadingDtl."Pick Ticket No." := RegWhseActLine."Pick Ticket No";
    //     //             BillOfLadingDtl."Pick Ticket Line No." := RegWhseActLine."Pick Ticket Line No.";
    //     //             BillOfLadingDtl."Reg. Pick Ticket No." := RegWhseActLine."No.";
    //     //             BillOfLadingDtl."Reg. Pick Ticket Line No." := RegWhseActLine."Line No.";
    //     //         end;
    //     //     end;
    //     //     if BillOfLadingDtl."Product Date" = 0D then
    //     //         BillOfLadingDtl.Validate("Product Date", PalletContainerInfo."Code Date");

    //     //     //BillOfLadingDtl."Qty on Pallet" := PalletContainerInfo.Quantity;  //EN1.42
    //     //     //BillOfLadingDtl."Unit of Measure" := PalletContainerInfo."Unit of Measure"; //EN1.42
    //     //     BillOfLadingDtl."Line Status" := PalletContainerInfo."Line Status"; //<<EN1.24
    //     //     //<<EN1.40
    //     //     BillOfLadingDtl."Pick Ticket No." := PalletContainerInfo."Pick Ticket No.";
    //     //     BillOfLadingDtl."Pick Ticket Line No." := PalletContainerInfo."Pick Ticket Line No.";
    //     //     BillOfLadingDtl."Reg. Pick Ticket No." := PalletContainerInfo."Reg. Pick Ticket No.";
    //     //     BillOfLadingDtl."Reg. Pick Ticket Line No." := PalletContainerInfo."Reg. Pick Ticket Line No.";
    //     //     //>>EN1.40
    //     //     BillOfLadingDtl.Modify;
    //     // end;

    //     // MergeBillOfLadingLines(BillOfLadingNo); //EN1.43

    //     // BillOfLadingDtl.Reset;
    //     // BillOfLadingDtl.SetRange("Bill of Lading No.", BillOfLadingNo);
    //     // BillOfLadingDtl.SetRange("Container ID", PalletContainerInfo."Container ID");
    //     // BillOfLadingDtl.SetRange("Item No.", '');
    //     // BillOfLadingDtl.DeleteAll;

    //     //>>EN1.15 + EN1.18 + EN1.23 + EN1.43
    // end;

    // procedure SelectBillOfLadingLine(BillOfLadingNo: Code[20]; BillOfLadingLineNo: Integer; var ContainerID: Integer; var PalletNo: Integer; var PalletLineNo: Integer): Boolean
    // var
    //     BillOfLadingDet: Record "Bill of Lading Detail";
    // begin
    //     //<<EN1.06
    //     BillOfLadingDet.Reset;
    //     BillOfLadingDet.SetRange("Bill of Lading No.", BillOfLadingNo);
    //     // if PAGE.RunModal(0, BillOfLadingDet) = ACTION::LookupOK then begin
    //         ContainerID := BillOfLadingDet."Container ID";
    //         PalletNo := BillOfLadingDet."Pallet No.";
    //         PalletLineNo := BillOfLadingDet."Pallet Line No.";
    //         exit(true);
    //     // end;
    //     //>>EN1.06
    // end;

    // procedure DeleteFromBillOfLading(WhseActivLine: Record "Warehouse Activity Line"; IsFromPickTicket: Boolean)
    // var
    //     RegWhseActLine: Record "Registered Whse. Activity Line";
    //     // BillofLadingDtl: Record "Bill of Lading Detail";
    // // PalletContMgt: Codeunit "Delivery Load Mgt.";
    // // PalletContainerInfo: Record "Pallet Container Info";
    // begin
    //     // check for posted lines and they dont exists then delete the bol lines.
    //     //<<EN1.10 + EN1.23
    //     // RegWhseActLine.Reset;
    //     // RegWhseActLine.SetRange("Pick Ticket No", WhseActivLine."No.");
    //     // RegWhseActLine.SetRange("Pick Ticket Line No.", WhseActivLine."Line No.");
    //     if not RegWhseActLine.FindFirst then begin
    //         //<<EN1.53
    //         /*
    //           BillofLadingDtl.SETRANGE("Pick Ticket No.",WhseActivLine."No.");
    //           BillofLadingDtl.SETRANGE("Pick Ticket Line No.",WhseActivLine."Line No.");
    //         IF BillofLadingDtl.FINDFIRST THEN
    //           BillofLadingDtl.DELETE;
    //         */

    //         //PalletContMgt.DeleteLineFromContainer(WhseActivLine."Container ID",WhseActivLine."Pallet No.",WhseActivLine."Pallet Line No.",
    //         // PalletContainerInfo."Source Type"::"Bill Of Lading",WhseActivLine."Source No.",'');  //<<EN1.22 //EN1.53

    //         // PalletContMgt.DeletePalletLineFromContainer(WhseActivLine."Load ID", WhseActivLine."Pallet No.",
    //         //   WhseActivLine."Pallet Line No.", 2);// EN1.53
    //     end else
    //         //PalletContMgt.DeleteLine(WhseActivLine."Container ID",WhseActivLine."Pallet No.",WhseActivLine."Pallet Line No.",
    //         //PalletContainerInfo."Source Type"::"Bill Of Lading",WhseActivLine."Source No.",''); //<<EN1.24
    //         // PalletContMgt.DeletePalletLine(WhseActivLine."Load ID", 2, 0, WhseActivLine."Pallet No.",
    //         //    WhseActivLine."Pallet Line No.", '', IsFromPickTicket); //EN1.53 + EN1.55
    //     //>>EN1.10 +EN1.23

    // end;

    // procedure UpdateBOLFromRegisteredPicksCo(BillOfLadingNo: Code[20])
    // var
    //     BillOfLadingHdr: Record "EN WMS Bill of Lading Header";
    //     BillOfLadingHdr2: Record "EN WMS Bill of Lading Header";
    //     BillOfLadingDtl: Record "EN WMS Bill of Lading Detail";
    //     WhseShipLine: Record "Warehouse Shipment Line";
    //     WhseActLine: Record "Warehouse Activity Line";
    //     RegWhseActLine: Record "Registered Whse. Activity Line";
    //     Item: Record Item;
    //     NextLineNo: Integer;
    //     DeliveryLoadInfo: Record "Delivery Load Line";
    // begin
    //     //<<EN1.23
    //     if BillOfLadingHdr.Get(BillOfLadingNo) then begin //EN1.14
    //                                                       //<<EN1.26
    //         if BillOfLadingHdr.Locked then
    //             exit;

    //         if GuiAllowed then
    //             if BillOfLadingHdr."Manual BOL" then
    //                 if not Confirm('this bol is manually maintained. if you update then you may lose changes') then
    //                     exit;
    //         ////>>EN1.26

    //         BillOfLadingDtl.Reset;
    //         BillOfLadingDtl.SetRange("Bill of Lading No.", BillOfLadingNo);
    //         BillOfLadingDtl.DeleteAll;

    //         BillOfLadingDtl.Reset;
    //         BillOfLadingDtl.SetRange(BillOfLadingDtl."Bill of Lading No.", BillOfLadingNo);
    //         if BillOfLadingDtl.FindLast then
    //             NextLineNo := BillOfLadingDtl."Line No." + 10000
    //         else
    //             NextLineNo := 10000;

    //         DeliveryLoadInfo.Reset;
    //         DeliveryLoadInfo.SetRange("Source Doc. No.", BillOfLadingHdr."Sales Order No.");
    //         DeliveryLoadInfo.SetRange("Load ID", BillOfLadingHdr."Load ID");
    //         DeliveryLoadInfo.SetFilter("Line Status", '<>%1', DeliveryLoadInfo."Line Status"::Deleted);
    //         DeliveryLoadInfo.SetFilter("Pallet No.", '<>%1', 0);
    //         if DeliveryLoadInfo.FindSet then
    //             repeat
    //                 WhseActLine.Reset;
    //                 WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::Pick);
    //                 WhseActLine.SetRange("Action Type", WhseActLine."Action Type"::Take);
    //                 WhseActLine.SetRange("Load ID", DeliveryLoadInfo."Load ID");                         //En1.49
    //                 WhseActLine.SetRange("Pallet No.", DeliveryLoadInfo."Pallet No.");                //En1.49
    //                 WhseActLine.SetRange("Pallet Line No.", DeliveryLoadInfo."Pallet Line No.");      //En1.49
    //                 WhseActLine.SetRange("Item No.", DeliveryLoadInfo."Item No.");      //En1.49
    //                 if WhseActLine.FindFirst then begin

    //                     BillOfLadingDtl.Reset;
    //                     BillOfLadingDtl.SetRange("Bill of Lading No.", BillOfLadingNo);
    //                     BillOfLadingDtl.SetRange("Load No.", WhseActLine."Load ID");                       //EN1.49
    //                     BillOfLadingDtl.SetRange("Pallet No.", WhseActLine."Pallet No.");
    //                     BillOfLadingDtl.SetRange("Pallet Line No.", WhseActLine."Pallet Line No.");
    //                     BillOfLadingDtl.SetRange("Pick Ticket No.", WhseActLine."No.");            //<<EN1.17
    //                     BillOfLadingDtl.SetRange("Pick Ticket Line No.", WhseActLine."Line No.");  //<<EN1.17
    //                     BillOfLadingDtl.SetRange("Item No.", DeliveryLoadInfo."Item No.");      //En1.49
    //                     if not BillOfLadingDtl.FindFirst then begin

    //                         BillOfLadingDtl.Init;
    //                         BillOfLadingDtl."Bill of Lading No." := BillOfLadingNo;
    //                         BillOfLadingDtl."Line No." := NextLineNo;
    //                         BillOfLadingDtl."Order No." := WhseActLine."Source No.";
    //                         BillOfLadingDtl."Order Line No." := WhseActLine."Source Line No.";
    //                         BillOfLadingDtl."Order Sub Line No." := WhseActLine."Source Subline No.";
    //                         BillOfLadingDtl."Load No." := WhseActLine."Load ID";                            //EN1.49
    //                         BillOfLadingDtl."Pallet No." := WhseActLine."Pallet No.";
    //                         BillOfLadingDtl."Pallet Line No." := WhseActLine."Pallet Line No.";
    //                         BillOfLadingDtl."Item No." := WhseActLine."Item No.";
    //                         BillOfLadingDtl.Description := WhseActLine.Description;
    //                         BillOfLadingDtl."Shipment No." := WhseActLine."Whse. Document No.";
    //                         BillOfLadingDtl."Shipment Line No." := WhseActLine."Whse. Document Line No.";
    //                         BillOfLadingDtl."Picked By" := WhseActLine."Assigned To";
    //                         //BillOfLadingDtl.Weight := WhseActLine.Weight;
    //                         BillOfLadingDtl.Validate("Product Date", WhseActLine."Code Date"); // EN1.40
    //                         BillOfLadingDtl."Pick Ticket No." := WhseActLine."No."; //EN1.23
    //                         BillOfLadingDtl."Pick Ticket Line No." := WhseActLine."Line No.";
    //                         //<<EN1.42
    //                         BillOfLadingDtl.Validate("Qty on Pallet", WhseActLine.Quantity);
    //                         if BillOfLadingDtl.Weight = 0 then
    //                             BillOfLadingDtl.Weight := WhseActLine.Weight;
    //                         //>>EN1.42
    //                         BillOfLadingDtl."Unit of Measure" := WhseActLine."Unit of Measure Code";
    //                         BillOfLadingDtl."Line Status" := DeliveryLoadInfo."Line Status"; //EN1.23
    //                         BillOfLadingDtl.Insert;
    //                         NextLineNo := NextLineNo + 10000;
    //                     end;
    //                 end;
    //             //UNTIL PalletContainerInfo.NEXT = 0;                   //1.49
    //             until DeliveryLoadInfo.Next = 0;

    //         RegWhseActLine.Reset;
    //         RegWhseActLine.SetRange("Activity Type", RegWhseActLine."Activity Type"::Pick);
    //         RegWhseActLine.SetRange("Action Type", RegWhseActLine."Action Type"::Take);
    //         RegWhseActLine.SetRange("Source No.", BillOfLadingHdr."Sales Order No.");
    //         RegWhseActLine.SetRange("Load ID", BillOfLadingHdr."Load ID"); //EN1.49
    //         if RegWhseActLine.FindSet then
    //             repeat
    //                 BillOfLadingDtl.Reset;
    //                 BillOfLadingDtl.SetRange("Bill of Lading No.", BillOfLadingNo);
    //                 BillOfLadingDtl.SetRange("Load No.", RegWhseActLine."Load ID");                  //EN1.49
    //                 BillOfLadingDtl.SetRange("Pallet No.", RegWhseActLine."Pallet No.");
    //                 BillOfLadingDtl.SetRange("Pallet Line No.", RegWhseActLine."Pallet Line No.");
    //                 BillOfLadingDtl.SetRange("Pick Ticket No.", RegWhseActLine."Pick Ticket No");  //<<EN1.17
    //                 BillOfLadingDtl.SetRange("Pick Ticket Line No.", RegWhseActLine."Pick Ticket Line No.");  //<<EN1.17
    //                 BillOfLadingDtl.SetRange("Item No.", RegWhseActLine."Item No.");      //En1.49

    //                 if not BillOfLadingDtl.FindFirst then begin
    //                     BillOfLadingDtl.Init;
    //                     BillOfLadingDtl."Bill of Lading No." := BillOfLadingNo;
    //                     BillOfLadingDtl."Line No." := NextLineNo;
    //                     BillOfLadingDtl."Order No." := RegWhseActLine."Source No.";
    //                     BillOfLadingDtl."Order Line No." := RegWhseActLine."Source Line No.";
    //                     BillOfLadingDtl."Order Sub Line No." := RegWhseActLine."Source Subline No.";
    //                     BillOfLadingDtl."Load No." := RegWhseActLine."Load ID";  //EN1.49
    //                     BillOfLadingDtl."Pallet No." := RegWhseActLine."Pallet No.";
    //                     BillOfLadingDtl."Pallet Line No." := RegWhseActLine."Pallet Line No.";
    //                     BillOfLadingDtl."Item No." := RegWhseActLine."Item No.";
    //                     BillOfLadingDtl.Description := RegWhseActLine.Description;
    //                     BillOfLadingDtl."Shipment No." := RegWhseActLine."Whse. Document No.";
    //                     BillOfLadingDtl."Shipment Line No." := RegWhseActLine."Whse. Document Line No.";
    //                     BillOfLadingDtl."Picked By" := RegWhseActLine."Assigned To";
    //                     BillOfLadingDtl.Validate("Product Date", RegWhseActLine."Code Date"); // EN1.40
    //                     BillOfLadingDtl."Pick Ticket No." := RegWhseActLine."Pick Ticket No"; //EN1.23
    //                     BillOfLadingDtl."Pick Ticket Line No." := RegWhseActLine."Pick Ticket Line No.";
    //                     //<<EN1.42
    //                     BillOfLadingDtl.Validate("Qty on Pallet", RegWhseActLine.Quantity);
    //                     if BillOfLadingDtl.Weight = 0 then
    //                         BillOfLadingDtl.Weight := RegWhseActLine.Weight;
    //                     //>>EN1.42
    //                     BillOfLadingDtl."Unit of Measure" := RegWhseActLine."Unit of Measure Code";
    //                     BillOfLadingDtl."Line Status" := DeliveryLoadInfo."Line Status"; //EN1.23
    //                     BillOfLadingDtl.Insert;
    //                     NextLineNo := NextLineNo + 10000;
    //                 end else begin

    //                     BillOfLadingDtl.Weight := RegWhseActLine.Weight;
    //                     BillOfLadingDtl.Validate("Product Date", RegWhseActLine."Code Date"); //EN1.40
    //                     BillOfLadingDtl."Pick Ticket No." := RegWhseActLine."Pick Ticket No"; //EN1.23
    //                     BillOfLadingDtl."Pick Ticket Line No." := RegWhseActLine."Pick Ticket Line No."; //EN1.23
    //                                                                                                      //<<EN1.42
    //                     BillOfLadingDtl.Validate("Qty on Pallet", BillOfLadingDtl."Qty on Pallet" + RegWhseActLine.Quantity);
    //                     if BillOfLadingDtl.Weight = 0 then
    //                         BillOfLadingDtl.Weight := RegWhseActLine.Weight;
    //                     //>>EN1.42
    //                     BillOfLadingDtl.Modify;
    //                 end;
    //             until RegWhseActLine.Next = 0;
    //     end;
    //     //>>EN1.15 + EN1.23
    // end;

    // procedure AddBillOfLadingLineConsign(BillOfLadingNo: Code[20]; DeliveryLoadInfo: Record "Delivery Load Line")
    // var
    //     // BillOfLadingHdr: Record "Bill of Lading Header";
    //     // BillOfLadingDtl: Record "Bill of Lading Detail";
    //     WhseShipLine: Record "Warehouse Shipment Line";
    //     WhseActLine: Record "Warehouse Activity Line";
    //     RegWhseActLine: Record "Registered Whse. Activity Line";
    //     Item: Record Item;
    //     NextLineNo: Integer;
    // begin
    //     //<<EN1.14 + EN1.18 + EN1.23 + EN1.49
    //     if BillOfLadingHdr.Get(BillOfLadingNo) then begin
    //         BillOfLadingDtl.Reset;
    //         BillOfLadingDtl.SetRange(BillOfLadingDtl."Bill of Lading No.", BillOfLadingNo);
    //         if BillOfLadingDtl.FindLast then
    //             NextLineNo := BillOfLadingDtl."Line No." + 10000
    //         else
    //             NextLineNo := 10000;

    //         //<<EN1.53
    //         if DeliveryLoadInfo."Line Type" = DeliveryLoadInfo."Line Type"::Text then begin
    //             BillOfLadingDtl.Init;
    //             BillOfLadingDtl."Bill of Lading No." := BillOfLadingNo;
    //             BillOfLadingDtl."Line No." := NextLineNo;
    //             BillOfLadingDtl.Insert;
    //             BillOfLadingDtl."Order No." := DeliveryLoadInfo."Source Doc. No.";
    //             BillOfLadingDtl."Order Line No." := DeliveryLoadInfo."Source Doc Line No.";
    //             BillOfLadingDtl."Order Sub Line No." := DeliveryLoadInfo."Source Doc Sub Line No.";
    //             BillOfLadingDtl."Load No." := DeliveryLoadInfo."Load ID";
    //             BillOfLadingDtl."Line Type" := BillOfLadingDtl."Line Type"::Text;
    //             BillOfLadingDtl.Description := DeliveryLoadInfo."Item Description";
    //             BillOfLadingDtl.Modify;
    //         end else begin
    //             BillOfLadingDtl.Reset;
    //             BillOfLadingDtl.SetRange("Bill of Lading No.", BillOfLadingNo);
    //             BillOfLadingDtl.SetRange("Load No.", DeliveryLoadInfo."Load ID");
    //             BillOfLadingDtl.SetRange("Pallet No.", DeliveryLoadInfo."Pallet No.");
    //             BillOfLadingDtl.SetRange("Pallet Line No.", DeliveryLoadInfo."Pallet Line No.");
    //             BillOfLadingDtl.SetFilter("Line Status", '<>%1', BillOfLadingDtl."Line Status"::Deleted); //<<EN1.21
    //             BillOfLadingDtl.SetRange("Item No.", DeliveryLoadInfo."Item No.");   //6/24s

    //             if not BillOfLadingDtl.FindFirst then begin
    //                 BillOfLadingDtl.Init;
    //                 BillOfLadingDtl."Bill of Lading No." := BillOfLadingNo;
    //                 BillOfLadingDtl."Line No." := NextLineNo;
    //                 BillOfLadingDtl."Line Type" := BillOfLadingDtl."Line Type"::Item;
    //                 BillOfLadingDtl."Order No." := DeliveryLoadInfo."Source Doc. No.";
    //                 BillOfLadingDtl."Order Line No." := DeliveryLoadInfo."Source Doc Line No.";
    //                 BillOfLadingDtl."Order Sub Line No." := DeliveryLoadInfo."Source Doc Sub Line No.";
    //                 BillOfLadingDtl."Load No." := DeliveryLoadInfo."Load ID";
    //                 BillOfLadingDtl."Pallet No." := DeliveryLoadInfo."Pallet No.";
    //                 BillOfLadingDtl."Pallet Line No." := DeliveryLoadInfo."Pallet Line No.";
    //                 BillOfLadingDtl."Item No." := DeliveryLoadInfo."Item No.";
    //                 BillOfLadingDtl."Unit of Measure" := DeliveryLoadInfo."Unit of Measure";  //EN1.00
    //                 BillOfLadingDtl.Insert;  //EN1.43
    //             end;

    //             BillOfLadingDtl.Validate("Qty on Pallet", DeliveryLoadInfo.Quantity); //En1.00

    //             WhseShipLine.Reset;
    //             WhseShipLine.SetRange("Source Type", WhseShipLine."Source Type"::"37");
    //             WhseShipLine.SetRange("Source Subtype", WhseShipLine."Source Subtype"::"1");
    //             WhseShipLine.SetRange("Source No.", DeliveryLoadInfo."Source Doc. No.");
    //             WhseShipLine.SetRange("Source Line No.", DeliveryLoadInfo."Source Doc Line No.");
    //             if WhseShipLine.FindFirst then begin
    //                 //<<EN1.14
    //                 if BillOfLadingHdr."Shipment Doc. No." = '' then begin
    //                     BillOfLadingHdr."Shipment Doc. No." := WhseShipLine."No.";
    //                 end;
    //                 //>>EN1.14
    //                 BillOfLadingDtl."Shipment No." := WhseShipLine."No.";
    //                 BillOfLadingDtl."Shipment Line No." := WhseShipLine."Line No.";
    //                 BillOfLadingDtl.Description := WhseShipLine.Description;
    //             end else begin
    //                 if Item.Get(DeliveryLoadInfo."Item No.") then
    //                     BillOfLadingDtl.Description := Item.Description;
    //             end;

    //             WhseActLine.Reset;
    //             WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::Pick);
    //             WhseActLine.SetRange("Source Type", WhseActLine."Source Type"::"37");
    //             WhseActLine.SetRange("Source Subtype", WhseActLine."Source Subtype"::"1");
    //             WhseActLine.SetRange("Source No.", DeliveryLoadInfo."Source Doc. No.");
    //             WhseActLine.SetRange("Source Line No.", DeliveryLoadInfo."Source Doc Line No.");
    //             WhseActLine.SetRange("Load ID", DeliveryLoadInfo."Load ID");
    //             WhseActLine.SetRange("Pallet No.", DeliveryLoadInfo."Pallet No.");
    //             WhseActLine.SetRange("Pallet Line No.", DeliveryLoadInfo."Pallet Line No.");
    //             if WhseActLine.FindFirst then begin
    //                 BillOfLadingDtl.Validate("Product Date", DeliveryLoadInfo."Code Date"); //<<EN1.09
    //                                                                                         //EN1.42
    //                 if BillOfLadingDtl.Weight = 0 then
    //                     BillOfLadingDtl.Weight := WhseActLine.Weight; //<<EN1.14
    //                                                                   //>>EN1.42
    //                 BillOfLadingDtl."Pick Ticket No." := WhseActLine."No.";
    //                 BillOfLadingDtl."Pick Ticket Line No." := WhseActLine."Line No.";
    //             end else begin
    //                 RegWhseActLine.Reset;
    //                 RegWhseActLine.SetRange("Activity Type", RegWhseActLine."Activity Type"::Pick);
    //                 RegWhseActLine.SetRange("Activity Type", RegWhseActLine."Action Type"::Take); //EN1.38
    //                 RegWhseActLine.SetRange("Source Type", WhseActLine."Source Type"::"37");
    //                 RegWhseActLine.SetRange("Source Subtype", WhseActLine."Source Subtype"::"1");
    //                 RegWhseActLine.SetRange("Source No.", DeliveryLoadInfo."Source Doc. No.");
    //                 RegWhseActLine.SetRange("Source Line No.", DeliveryLoadInfo."Source Doc Line No.");
    //                 RegWhseActLine.SetRange("Load ID", DeliveryLoadInfo."Load ID");
    //                 RegWhseActLine.SetRange("Pallet No.", DeliveryLoadInfo."Pallet No.");
    //                 RegWhseActLine.SetRange("Pallet Line No.", DeliveryLoadInfo."Pallet Line No.");
    //                 if RegWhseActLine.FindFirst then begin
    //                     BillOfLadingDtl.Validate("Product Date", DeliveryLoadInfo."Code Date");
    //                     //EN1.42
    //                     if BillOfLadingDtl.Weight = 0 then
    //                         BillOfLadingDtl.Weight := RegWhseActLine.Weight; //>>EN1.42
    //                     BillOfLadingDtl."Pick Ticket No." := RegWhseActLine."Pick Ticket No";
    //                     BillOfLadingDtl."Pick Ticket Line No." := RegWhseActLine."Pick Ticket Line No.";
    //                     BillOfLadingDtl."Reg. Pick Ticket No." := RegWhseActLine."No.";
    //                     BillOfLadingDtl."Reg. Pick Ticket Line No." := RegWhseActLine."Line No.";
    //                 end;
    //             end;
    //             if BillOfLadingDtl."Product Date" = 0D then
    //                 BillOfLadingDtl.Validate("Product Date", DeliveryLoadInfo."Code Date");

    //             //BillOfLadingDtl."Qty on Pallet" := PalletContainerInfo.Quantity;  //EN1.42
    //             //BillOfLadingDtl."Unit of Measure" := PalletContainerInfo."Unit of Measure"; //EN1.42
    //             BillOfLadingDtl."Line Status" := DeliveryLoadInfo."Line Status"; //<<EN1.24
    //                                                                              //<<EN1.40
    //             BillOfLadingDtl."Pick Ticket No." := DeliveryLoadInfo."Pick Ticket No.";
    //             BillOfLadingDtl."Pick Ticket Line No." := DeliveryLoadInfo."Pick Ticket Line No.";
    //             BillOfLadingDtl."Reg. Pick Ticket No." := DeliveryLoadInfo."Reg. Pick Ticket No.";
    //             BillOfLadingDtl."Reg. Pick Ticket Line No." := DeliveryLoadInfo."Reg. Pick Ticket Line No.";
    //             //>>EN1.40
    //             BillOfLadingDtl.Modify;
    //         end;
    //     end;
    //     //>>EN1.53

    //     MergeBillOfLadingLines(BillOfLadingNo); //EN1.43

    //     BillOfLadingDtl.Reset;
    //     BillOfLadingDtl.SetRange("Bill of Lading No.", BillOfLadingNo);
    //     BillOfLadingDtl.SetRange("Load No.", DeliveryLoadInfo."Load ID");
    //     BillOfLadingDtl.SetRange("Item No.", '');
    //     BillOfLadingDtl.SetRange("Line Type", BillOfLadingDtl."Line Type"::Item);  //EN1.53
    //     BillOfLadingDtl.DeleteAll;

    //     //>>EN1.15 + EN1.18 + EN1.23 + EN1.43 + EN1.49
    // end;

    // procedure SelectBillOfLadingLineConsign(BillOfLadingNo: Code[20]; BillOfLadingLineNo: Integer; var LoadID: Code[20]; var PalletNo: Integer; var PalletLineNo: Integer): Boolean
    // var
    //     BillOfLadingDet: Record "Bill of Lading Detail";
    // begin
    //     //<<EN1.06
    //     Error('50003 SelectBillOfLadingLineConsign');
    //     BillOfLadingDet.Reset;
    //     BillOfLadingDet.SetRange("Bill of Lading No.", BillOfLadingNo);
    //     if PAGE.RunModal(0, BillOfLadingDet) = ACTION::LookupOK then begin
    //         LoadID := BillOfLadingDet."Load No."; //EN1.49
    //         PalletNo := BillOfLadingDet."Pallet No.";
    //         PalletLineNo := BillOfLadingDet."Pallet Line No.";
    //         exit(true);
    //     end;
    //     //>>EN1.06
    // end;

    // procedure DeleteFromBillOfLadingConsgin(WhseActivLine: Record "Warehouse Activity Line")
    // var
    //     RegWhseActLine: Record "Registered Whse. Activity Line";
    // // BillofLadingDtl: Record "Bill of Lading Detail";
    // // PalletContMgt: Codeunit "Delivery Load Mgt.";
    // // PalletContainerInfo: Record "Pallet Container Info";
    // begin
    //     // check for posted lines and they dont exists then delete the bol lines.
    //     //<<EN1.10 + EN1.23
    //     RegWhseActLine.Reset;
    //     RegWhseActLine.SetRange("Pick Ticket No", WhseActivLine."No.");
    //     RegWhseActLine.SetRange("Pick Ticket Line No.", WhseActivLine."Line No.");
    //     if not RegWhseActLine.FindFirst then begin
    //         // BillofLadingDtl.SetRange("Pick Ticket No.", WhseActivLine."No.");
    //         // BillofLadingDtl.SetRange("Pick Ticket Line No.", WhseActivLine."Line No.");
    //         // if BillofLadingDtl.FindFirst then
    //         //     BillofLadingDtl.Delete;

    //         // // PalletContMgt.DeletePalletLineFromContainer(
    //         //   WhseActivLine."Load ID", WhseActivLine."Pallet No.", WhseActivLine."Pallet Line No.", 2);  //<<EN1.22
    //     end else
    //         // PalletContMgt.DeletePalletLine(
    //         //   WhseActivLine."Load ID", 2, 0, WhseActivLine."Pallet No.", WhseActivLine."Pallet Line No.", '', false); //<<EN1.24 + EN1.55
    //     //>>EN1.10 +EN1.23
    // end;

    procedure GetShipmentLabelReportID(OrderNo: Code[20]): Integer
    var
        SalesHdr: Record "Sales Header";
        Customer: Record Customer;
    begin
        //<<EN1.21
        if SalesHdr.Get(SalesHdr."Document Type", OrderNo) then begin
            Customer.Get(SalesHdr."Sell-to Customer No.");
            // if Customer."Shipping Label Report ID" <> 0 then
            //     exit(Customer."Shipping Label Report ID")
            // else begin
            //     WhseSetup.Get;
            //     exit(WhseSetup."Def. Shipping Label Report ID");
            // end;
        end;
        //>>EN1.21
    end;

    // procedure MergeBillOfLadingLines(BillOfLadingNo: Code[20])
    // var
    //     // PalletContInfo: Record "Pallet Container Info";
    //     // PalletContInfo2: Record "Pallet Container Info";
    //     // BillOfLadingDet: Record "Bill of Lading Detail";
    //     // BillOfLadingDet2: Record "Bill of Lading Detail";
    //     PalletCount: array[100] of Integer;
    //     i: Integer;
    //     PrevPalletNo: Integer;
    //     CurrPalletNo: Integer;
    //     PalletList: Record "Integer" temporary;
    // begin
    //     //<<EN1.43
    //     i := 1;
    //     BillOfLadingDet.Reset;
    //     BillOfLadingDet.SetRange("Bill of Lading No.", BillOfLadingNo);
    //     BillOfLadingDet.SetRange("Line Type", BillOfLadingDet."Line Type"::Item);  //EN1.53
    //     if BillOfLadingDet.FindSet then begin
    //         repeat
    //             PalletList.Reset;
    //             PalletList.SetRange(Number, BillOfLadingDet."Pallet No.");
    //             if not PalletList.FindFirst then begin
    //                 PalletList.Init;
    //                 PalletList.Number := BillOfLadingDet."Pallet No.";
    //                 PalletList.Insert;
    //             end;
    //         until BillOfLadingDet.Next = 0;
    //     end;

    //     PalletList.Reset;
    //     if PalletList.FindSet then
    //         repeat
    //             BillOfLadingDet.Reset;
    //             BillOfLadingDet.SetRange("Bill of Lading No.", BillOfLadingNo);
    //             BillOfLadingDet.SetRange("Pallet No.", PalletList.Number);
    //             BillOfLadingDet.SetRange("Line Type", BillOfLadingDet."Line Type"::Item); //EN1.53
    //             if BillOfLadingDet.FindSet then
    //                 repeat
    //                     BillOfLadingDet2.Reset;
    //                     BillOfLadingDet2.SetRange("Bill of Lading No.", BillOfLadingDet."Bill of Lading No.");
    //                     BillOfLadingDet2.SetRange("Line Type", BillOfLadingDet."Line Type"::Item); //EN1.53
    //                     BillOfLadingDet2.SetRange("Pallet No.", BillOfLadingDet."Pallet No.");
    //                     BillOfLadingDet2.SetFilter("Line No.", '<>%1', BillOfLadingDet."Line No.");
    //                     BillOfLadingDet2.SetRange("Item No.", BillOfLadingDet."Item No.");
    //                     BillOfLadingDet2.SetRange("Unit of Measure", BillOfLadingDet."Unit of Measure");
    //                     BillOfLadingDet2.SetRange("Product Date", BillOfLadingDet."Product Date");
    //                     if BillOfLadingDet2.FindSet then
    //                         repeat
    //                             BillOfLadingDet.Validate("Qty on Pallet", BillOfLadingDet."Qty on Pallet" + BillOfLadingDet2."Qty on Pallet");
    //                             BillOfLadingDet.Modify;
    //                             BillOfLadingDet2.Delete;
    //                         until BillOfLadingDet2.Next = 0;
    //                 until BillOfLadingDet.Next = 0;
    //         until PalletList.Next = 0;
    //     //>>EN1.43
    // end;

    procedure "--Replenishment"()
    begin
    end;

    // procedure ReplenishBin(LocationCode: Code[20]; Zone: Code[10]; BinNo: Code[10]; ItemNo: Code[20])
    // var
    //     BinContent: Record "Bin Content";
    //     Location: Record Location;
    //     WhseWorkshtLine: Record "Whse. Worksheet Line";
    //     NewBatchName: Code[20];
    // begin
    //     //<<EN1.16
    //     //COMMIT;
    //     Location.Get(LocationCode);
    //     BinContent.Reset;
    //     BinContent.SetRange("Location Code", LocationCode);
    //     if Zone <> '' then
    //         BinContent.SetRange("Zone Code", Zone);

    //     if BinNo <> '' then
    //         BinContent.SetRange("Bin Code", BinNo);

    //     if ItemNo <> '' then
    //         BinContent.SetRange("Item No.", ItemNo);

    //     BinContent.SetRange("Bin Type Code", 'PICK');
    //     BinContent.SetRange(Fixed, true);
    //     if BinContent.FindFirst then begin
    //         BinContent.CalcFields(Quantity);
    //         if BinContent.Quantity <= BinContent."Min. Qty." + 15 then begin
    //             //WMSServices.GetBatchName(USERID,NewBatchName);
    //             NewBatchName := UserId;
    //             WMSServices.CreateWhseMovementWkSht(LocationCode, NewBatchName);
    //             CalcBinRepenish.InitializeRequest('MOVEMENT', NewBatchName, LocationCode, false, true, false);
    //             CalcBinRepenish.UseRequestPage(false);
    //             CalcBinRepenish.SetTableView(BinContent);
    //             CalcBinRepenish.Run;

    //             WhseWorkshtLine.Reset;
    //             WhseWorkshtLine.SetRange("Worksheet Template Name", 'MOVEMENT');
    //             WhseWorkshtLine.SetRange(Name, NewBatchName);
    //             WhseWorkshtLine.SetRange("Location Code", LocationCode);
    //             if WhseWorkshtLine.FindFirst then begin
    //                 CreateMovFromWhseSource.SetHideValidationDialog(true);
    //                 CreateMovFromWhseSource.UseRequestPage(false);
    //                 CreateMovFromWhseSource.SetWhseWkshLine(WhseWorkshtLine);
    //                 CreateMovFromWhseSource.Run;
    //             end;
    //         end;
    //     end;
    //     //>>EN1.16
    // end;

    procedure "--Adjustment"()
    begin
    end;

    // procedure AdjustRegPickLines(ContID: Integer; PalletNo: Integer; PalletLineNo: Integer; NewAdjQty: Decimal; UseProvidedAdjQty: Boolean)
    // var
    //     RegWhseActLine: Record "Registered Whse. Activity Line";
    // // AdjustWhseShipmentQty: Report "Adjust Whse. Shipment Qty";
    // begin
    //     //<<EN1.25
    //     RegWhseActLine.Reset;
    //     RegWhseActLine.SetRange("Activity Type", RegWhseActLine."Activity Type"::Pick);
    //     RegWhseActLine.SetRange("Container ID", ContID);
    //     RegWhseActLine.SetRange("Pallet No.", PalletNo);
    //     RegWhseActLine.SetRange("Pallet Line No.", PalletLineNo);
    //     //RegWhseActLine.SETRANGE("Pick Ticket No", PickTicketNo);
    //     //RegWhseActLine.SETRANGE("Pick Ticket Line No.",PickTicketLineNo);
    //     if RegWhseActLine.FindFirst then begin
    //         // AdjustWhseShipmentQty.SetParams(
    //         //   RegWhseActLine."Item No.", RegWhseActLine.Description,
    //         //   RegWhseActLine."Whse. Document No.", RegWhseActLine."Whse. Document Line No.",
    //         //   RegWhseActLine."Pick Ticket No", RegWhseActLine."Pick Ticket Line No.",
    //         //   RegWhseActLine."Container ID",
    //         //   RegWhseActLine."Pallet No.",
    //         //   RegWhseActLine."Pallet Line No.", NewAdjQty, UseProvidedAdjQty); //EN1.27
    //         // AdjustWhseShipmentQty.Run;
    //     end else
    //         // Error('Unable to find Cont. ID %1 Pallet No. %2 Pallet Line No. %3',
    //         //   ContID, PalletNo, PalletLineNo);
    //     //>>EN1.25
    // end;

    procedure AdjustRegPickLinesCosign(RegWhseActivityLine: Record "Registered Whse. Activity Line"; NewAdjQty: Decimal; UseProvidedAdjQty: Boolean)
    var
        RegWhseActLine: Record "Registered Whse. Activity Line";
        AdjustWhseShipmentQty: Report "Adjust Whse. Shipment Qty ELA";
    begin

        //<<EN1.50
        //<<EN1.25
        IF RegWhseActLine.Get(RegWhseActivityLine."Activity Type", RegWhseActivityLine."No.", RegWhseActivityLine."Line No.") THEN BEGIN
            AdjustWhseShipmentQty.SetParam(RegWhseActLine."Activity Type", RegWhseActLine."No.", RegWhseActLine."Line No.",
              RegWhseActLine."Item No.", RegWhseActLine.Description,
              RegWhseActLine."Whse. Document No.", RegWhseActLine."Whse. Document Line No.",
              RegWhseActLine."Container No. ELA",
              RegWhseActLine."Container Line No. ELA",
             NewAdjQty); //EN1.27
            AdjustWhseShipmentQty.RUN;
        END ELSE
            ERROR('Unable to find Registered Whse. Activity Line');
        //>>EN1.25
        //>>EN1.50

    end;

    // procedure RunPostAdjustmentOnConsign(OrderNo: Code[20]; LoadID: Code[20]; LoadType: Option)
    // var
    //     RegWhseActLine: Record "Registered Whse. Activity Line";
    //     // DelLoadHdr: Record "Delivery Load Header";
    //     // DelLoadLine: Record "Delivery Load Line";
    //     WhseWorkshtLine: Record "Whse. Worksheet Line";
    // // MovementWksht: Page "Movement Worksheet";
    // begin
    //     // 4/30/19 ks
    //     //Load ID,Load Type
    //     /*
    //     tbr
    //     DelLoadHdr.Get(LoadID, LoadType);
    //     DelLoadLine.Reset;
    //     DelLoadLine.SetRange("Load Type", LoadType);
    //     DelLoadLine.SetRange("Load ID", LoadID);
    //     //DelLoadLine.SETRANGE("Source Type",PalletContInfo."Source Type"::"Bill Of Lading");
    //     DelLoadLine.SetRange("Source Doc. No.", OrderNo);
    //     if DelLoadLine.FindSet then begin
    //         repeat
    //             if DelLoadLine."Qty. To Remove" <> 0 then
    //                 AdjustLineInConsign(DelLoadLine."Load ID", DelLoadLine."Load Type", DelLoadLine."Line No.");
    //         until DelLoadLine.Next = 0;

    //         WhseSetup.Get;
    //         if WhseSetup."Move Adjusted BOL Stock Back" then begin
    //             WhseWorkshtLine.Reset;
    //             WhseWorkshtLine.SetRange("Location Code", DelLoadHdr."Source Location");
    //             WhseWorkshtLine.SetRange("Worksheet Template Name", WhseSetup."WMS Movement Wksht Name");
    //             WhseWorkshtLine.SetRange(Name, WhseSetup."WMS Reverse Mov. Jnl Name");
    //             if WhseWorkshtLine.FindSet then begin
    //                 MovementWksht.SetTableView(WhseWorkshtLine);
    //                 MovementWksht.Run;
    //             end;
    //         end;
    //     end;
    //     */
    // end;

    // local procedure AdjustLine(ContID: Integer; PalletNo: Integer; PalletLineNo: Integer)
    // var
    //     WhseShipLine: Record "Warehouse Shipment Line";
    //     WhseShipLine2: Record "Warehouse Shipment Line";
    //     RegWhseActLine: Record "Registered Whse. Activity Line";
    //     RegWhseActLine2: Record "Registered Whse. Activity Line";
    //     PickedActLine: Record "Registered Whse. Activity Line";
    //     ShipDashBrd: Record "EN Shipment Dashboard";
    //     // PalletContInfo: Record "Pallet Container Info";
    //     // BillOfLadingDet: Record "Bill of Lading Detail";
    //     // BillOfLadingHdr: Record "Bill of Lading Header";
    //     WhseCommentLine: Record "Warehouse Comment Line";
    //     Location: Record Location;
    //     WeightPerUnit: Decimal;
    //     NewWeightPerUnit: Decimal;
    //     ShippedLinePickedQty: Decimal;
    //     TotalPickedLinesQty: Decimal;
    //     NewPickedQty: Decimal;
    //     QtyToReduce: Decimal;
    //     NewShippedQty: Decimal;
    //     // RtcWindow: DotNet Interaction;
    //     Window: Dialog;
    //     WinResponse: Text[30];
    //     WinMsg: Text[250];
    //     NextCommentLineNo: Integer;
    //     Comment: Text[250];
    //     ItemNo: Code[20];
    //     ItemDesc: Text[50];
    //     ItemUOM: Code[10];
    //     LocCode: Code[10];
    //     PutBackBin: Code[10];
    //     MovDocNo: Code[20];
    //     CodeDate: Date;
    //     NewEnteredQty: Decimal;
    //     ShipmentNo: Code[20];
    //     ShipmentLineNo: Integer;
    // begin
    //     //<<EN1.40
    //     if PalletContInfo.Get(ContID, PalletNo, PalletLineNo) then begin
    //         if PalletContInfo.Quantity = PalletContInfo."New Qty" then
    //             exit;

    //         if PalletContInfo."Qty. To Adjust" = 0 then
    //             exit;

    //         RegWhseActLine.Reset;
    //         RegWhseActLine.SetRange("Activity Type", RegWhseActLine."Activity Type"::Pick);
    //         RegWhseActLine.SetRange("Container ID", ContID);
    //         RegWhseActLine.SetRange("Pallet No.", PalletNo);
    //         RegWhseActLine.SetRange("Pallet Line No.", PalletLineNo);
    //         if RegWhseActLine.FindFirst then begin
    //             NewEnteredQty := PalletContInfo."New Qty";
    //             QtyToReduce := PalletContInfo."Qty. To Adjust";
    //             PalletNo := PalletContInfo."Pallet No.";
    //             PalletLineNo := PalletContInfo."Pallet Line No.";
    //             PalletContInfo.Validate(Quantity, NewEnteredQty);
    //             PalletContInfo.Modify;

    //             ItemNo := RegWhseActLine."Item No.";
    //             ItemDesc := RegWhseActLine.Description;
    //             ItemUOM := RegWhseActLine."Unit of Measure Code";
    //             LocCode := RegWhseActLine."Location Code";
    //             PutBackBin := RegWhseActLine."Bin Code";
    //             CodeDate := RegWhseActLine."Code Date";

    //             PickedActLine.Reset;
    //             PickedActLine.SetRange("Activity Type", PickedActLine."Activity Type"::Pick);
    //             PickedActLine.SetRange("Action Type", PickedActLine."Action Type"::Take);
    //             PickedActLine.SetRange("Whse. Document No.", RegWhseActLine."Whse. Document No.");
    //             PickedActLine.SetRange("Whse. Document Line No.", RegWhseActLine."Whse. Document Line No.");
    //             if PickedActLine.FindSet then
    //                 repeat
    //                     TotalPickedLinesQty := TotalPickedLinesQty + PickedActLine.Quantity;
    //                 until PickedActLine.Next = 0;

    //             TotalPickedLinesQty := TotalPickedLinesQty - QtyToReduce;

    //             if RegWhseActLine.Weight <> 0 then begin
    //                 if RegWhseActLine.Quantity > 0 then
    //                     WeightPerUnit := RegWhseActLine.Weight / RegWhseActLine.Quantity
    //                 else
    //                     WeightPerUnit := 0;

    //                 NewWeightPerUnit := WeightPerUnit * NewEnteredQty;
    //             end;

    //             RegWhseActLine."Original Qty" := RegWhseActLine.Quantity;
    //             RegWhseActLine.Quantity := NewEnteredQty;
    //             RegWhseActLine."Qty. (Base)" := NewEnteredQty * RegWhseActLine."Qty. per Unit of Measure";
    //             RegWhseActLine.Weight := NewWeightPerUnit;
    //             RegWhseActLine.Modify;

    //             ShipmentNo := '';
    //             ShipmentLineNo := 0;
    //             RegWhseActLine2.Reset;
    //             RegWhseActLine2.SetRange("Activity Type", RegWhseActLine."Activity Type"::Pick);
    //             RegWhseActLine2.SetRange("Action Type", RegWhseActLine."Action Type"::Place);
    //             RegWhseActLine2.SetRange("No.", RegWhseActLine."No.");
    //             RegWhseActLine2.SetRange("Parent Line No.", RegWhseActLine."Line No.");
    //             RegWhseActLine2.SetRange("Container ID", ContID);
    //             RegWhseActLine2.SetRange("Pallet No.", PalletNo);
    //             RegWhseActLine2.SetRange("Pallet Line No.", PalletLineNo);
    //             if RegWhseActLine2.FindFirst then begin
    //                 ShipmentNo := RegWhseActLine."Whse. Document No.";
    //                 ShipmentLineNo := RegWhseActLine."Whse. Document Line No.";
    //                 RegWhseActLine2.Quantity := RegWhseActLine.Quantity;
    //                 RegWhseActLine2."Qty. (Base)" := RegWhseActLine."Qty. (Base)";
    //                 RegWhseActLine2.Weight := RegWhseActLine.Weight;
    //                 RegWhseActLine2.Modify;
    //             end;

    //             //<<EN1.02
    //             if WhseShipLine.Get(ShipmentNo, ShipmentLineNo) then begin
    //                 Comment := StrSubstNo(TEXT14229214, UserId, WhseShipLine."Item No.", WhseShipLine."Qty. Picked", TotalPickedLinesQty);
    //                 WMSServices.AddWhseComment(ShipmentNo, ShipmentLineNo, WhseCommentLine."Table Name"::"Whse. Shipment", 0, UserId, Comment);
    //                 //>>EN1.02

    //                 WhseShipLine."Qty. Picked" := TotalPickedLinesQty;
    //                 WhseShipLine."Qty. Picked (Base)" := TotalPickedLinesQty * WhseShipLine."Qty. per Unit of Measure";
    //                 WhseShipLine."Qty. to Ship" := TotalPickedLinesQty;
    //                 WhseShipLine."Qty. to Ship (Base)" := TotalPickedLinesQty * WhseShipLine."Qty. per Unit of Measure";
    //                 WhseShipLine."Completely Picked" := false;
    //                 WhseShipLine.Modify;

    //                 /*
    //                 //<<EN1.02
    //                 IF WhseShipLine2.GET(ShipmentNo,ShipmentLineNo) THEN BEGIN
    //                   IF WhseShipLine2."Qty. Picked" = TotalPickedLinesQty THEN
    //                     ERROR(TXT009);
    //                 END;
    //                 //>>EN1.02
    //                 */
    //             end;// ELSE
    //                 // ERROR(TXT004);

    //             ShipDashBrd.Reset;
    //             ShipDashBrd.SetRange("Shipment No.", ShipmentNo);
    //             ShipDashBrd.SetRange("Shipment Line No.", ShipmentLineNo);
    //             if ShipDashBrd.FindFirst then begin
    //                 ShipDashBrd."Picked Qty." := TotalPickedLinesQty;
    //                 ShipDashBrd.Completed := false;
    //                 ShipDashBrd."Full Pick" := false;
    //                 ShipDashBrd.Modify;
    //             end;

    //             WhseSetup.Get; //<<EN1.02
    //             BillOfLadingDet.Reset;
    //             BillOfLadingDet.SetRange("Container ID", ContID);
    //             BillOfLadingDet.SetRange("Pallet No.", PalletNo);
    //             BillOfLadingDet.SetRange("Pallet Line No.", PalletLineNo);
    //             if BillOfLadingDet.FindFirst then begin
    //                 //<<EN1.02
    //                 if WhseSetup."Enforce Loading check on BOL" then
    //                     if BillOfLadingDet.Loaded then
    //                         Error(StrSubstNo(TEXT14229215, PalletNo));
    //                 //>>EN1.02

    //                 BillOfLadingHdr.Get(BillOfLadingDet."Bill of Lading No.");
    //                 if BillOfLadingHdr.Status = BillOfLadingHdr.Status::Registered then
    //                     Error(TEXT14229216);

    //                 BillOfLadingDet.Validate("Qty on Pallet", NewEnteredQty); //EN1.42
    //                 if BillOfLadingDet.Weight <> 0 then begin
    //                     if BillOfLadingDet."Qty on Pallet" <> 0 then
    //                         WeightPerUnit := BillOfLadingDet.Weight / BillOfLadingDet."Qty on Pallet"
    //                     else
    //                         WeightPerUnit := 0;

    //                     NewWeightPerUnit := WeightPerUnit * NewEnteredQty;
    //                 end;

    //                 BillOfLadingDet.Weight := NewWeightPerUnit;
    //                 BillOfLadingDet.Modify;
    //             end;

    //             if WhseSetup."Move Adjusted BOL Stock Back" then begin
    //                 Location.Get(LocCode);
    //                 CreateReverseJnl(LocCode, ItemNo, ItemUOM, Location."Shipment Bin Code", PutBackBin, QtyToReduce, CodeDate);
    //             end;
    //         end;
    //     end;

    //     /*
    //     create a new journal.
    //     add line on it.
    //     open up only for user posting.
    //     //<<EN1.02
    //     IF WhseSetup."Move Adjusted BOL Stock Back" THEN BEGIN
    //       IF NOT HideDialogBox THEN
    //         IF NOT CONFIRM(STRSUBSTNO(TXT010,QtyToReduce,ItemNo,ItemDesc,PutBackBin)) THEN
    //           EXIT;

    //       Location.GET(LocCode);
    //       WMSServices.CreateWMSMovement(Location."Shipment Bin Code",ItemNo,ItemUOM,QtyToReduce,PutBackBin,LocCode,MovDocNo,CodeDate,
    //         USERID);
    //       WMSServices.RegisterWMSMovement(MovDocNo,ItemNo,QtyToReduce,PutBackBin,USERID);
    //     END;
    //     */
    //     //>>EN1.40

    // end;

    // local procedure AdjustLineInConsign(LoadID: Code[20]; LoadType: Option; LineNo: Integer)
    // var
    //     WhseShipLine: Record "Warehouse Shipment Line";
    //     WhseShipLine2: Record "Warehouse Shipment Line";
    //     RegWhseActLine: Record "Registered Whse. Activity Line";
    //     RegWhseActLine2: Record "Registered Whse. Activity Line";
    //     PickedActLine: Record "Registered Whse. Activity Line";
    //     ShipDashBrd: Record "EN Shipment Dashboard";
    //     // DelLoadLine: Record "Delivery Load Line";
    //     // BillOfLadingDet: Record "EN WMS Bill of Lading Detail";
    //     // BillOfLadingHdr: Record "EN WMS Bill of Lading Header";
    //     WhseCommentLine: Record "Warehouse Comment Line";
    //     Location: Record Location;
    //     WeightPerUnit: Decimal;
    //     NewWeightPerUnit: Decimal;
    //     ShippedLinePickedQty: Decimal;
    //     TotalPickedLinesQty: Decimal;
    //     NewPickedQty: Decimal;
    //     QtyToReduce: Decimal;
    //     NewShippedQty: Decimal;
    //     Window: Dialog;
    //     WinResponse: Text[30];
    //     WinMsg: Text[250];
    //     NextCommentLineNo: Integer;
    //     Comment: Text[250];
    //     ItemNo: Code[20];
    //     ItemDesc: Text[50];
    //     ItemUOM: Code[10];
    //     LocCode: Code[10];
    //     PutBackBin: Code[10];
    //     MovDocNo: Code[20];
    //     CodeDate: Date;
    //     NewEnteredQty: Decimal;
    //     ShipmentNo: Code[20];
    //     ShipmentLineNo: Integer;
    // begin
    //     //<<EN1.40
    //     if DelLoadLine.Get(LoadID, LoadType, LineNo) then begin
    //         //IF PalletContInfo.GET(ContID,PalletNo,PalletLineNo) THEN BEGIN
    //         if DelLoadLine.Quantity = DelLoadLine."New Qty" then
    //             exit;

    //         if DelLoadLine."Qty. To Remove" = 0 then
    //             exit;

    //         RegWhseActLine.Reset;
    //         RegWhseActLine.SetRange("Activity Type", RegWhseActLine."Activity Type"::Pick);
    //         RegWhseActLine.SetRange("Load ID", LoadID);
    //         RegWhseActLine.SetRange("Pallet No.", DelLoadLine."Pallet No.");
    //         RegWhseActLine.SetRange("Pallet Line No.", DelLoadLine."Pallet Line No.");
    //         if RegWhseActLine.FindFirst then begin
    //             NewEnteredQty := DelLoadLine."New Qty";
    //             QtyToReduce := DelLoadLine."Qty. To Remove";
    //             //PalletNo := DelLoadLine."Pallet No.";
    //             //PalletLineNo := DelLoadLine."Pallet Line No.";
    //             DelLoadLine.Validate(Quantity, NewEnteredQty);
    //             DelLoadLine."Qty. To Remove" := 0;
    //             DelLoadLine."New Qty" := 0;
    //             DelLoadLine.Modify;

    //             ItemNo := RegWhseActLine."Item No.";
    //             ItemDesc := RegWhseActLine.Description;
    //             ItemUOM := RegWhseActLine."Unit of Measure Code";
    //             LocCode := RegWhseActLine."Location Code";
    //             PutBackBin := RegWhseActLine."Bin Code";
    //             CodeDate := RegWhseActLine."Code Date";

    //             PickedActLine.Reset;
    //             PickedActLine.SetRange("Activity Type", PickedActLine."Activity Type"::Pick);
    //             PickedActLine.SetRange("Action Type", PickedActLine."Action Type"::Take);
    //             PickedActLine.SetRange("Whse. Document No.", RegWhseActLine."Whse. Document No.");
    //             PickedActLine.SetRange("Whse. Document Line No.", RegWhseActLine."Whse. Document Line No.");
    //             if PickedActLine.FindSet then
    //                 repeat
    //                     TotalPickedLinesQty := TotalPickedLinesQty + PickedActLine.Quantity;
    //                 until PickedActLine.Next = 0;

    //             TotalPickedLinesQty := TotalPickedLinesQty - QtyToReduce;
    //             if RegWhseActLine.Weight <> 0 then begin
    //                 if RegWhseActLine.Quantity > 0 then
    //                     WeightPerUnit := RegWhseActLine.Weight / RegWhseActLine.Quantity
    //                 else
    //                     WeightPerUnit := 0;

    //                 NewWeightPerUnit := WeightPerUnit * NewEnteredQty;
    //             end;

    //             RegWhseActLine."Original Qty" := RegWhseActLine.Quantity;
    //             RegWhseActLine.Quantity := NewEnteredQty;
    //             RegWhseActLine."Qty. (Base)" := NewEnteredQty * RegWhseActLine."Qty. per Unit of Measure";
    //             RegWhseActLine.Weight := NewWeightPerUnit;
    //             RegWhseActLine.Modify;

    //             ShipmentNo := '';
    //             ShipmentLineNo := 0;
    //             RegWhseActLine2.Reset;
    //             RegWhseActLine2.SetRange("Activity Type", RegWhseActLine."Activity Type"::Pick);
    //             RegWhseActLine2.SetRange("Action Type", RegWhseActLine."Action Type"::Place);
    //             RegWhseActLine2.SetRange("No.", RegWhseActLine."No.");
    //             RegWhseActLine2.SetRange("Parent Line No.", RegWhseActLine."Line No.");
    //             RegWhseActLine2.SetRange("Load ID", LoadID);
    //             RegWhseActLine2.SetRange("Pallet No.", DelLoadLine."Pallet No.");
    //             RegWhseActLine2.SetRange("Pallet Line No.", DelLoadLine."Pallet Line No.");
    //             if RegWhseActLine2.FindFirst then begin
    //                 ShipmentNo := RegWhseActLine."Whse. Document No.";
    //                 ShipmentLineNo := RegWhseActLine."Whse. Document Line No.";
    //                 RegWhseActLine2.Quantity := RegWhseActLine.Quantity;
    //                 RegWhseActLine2."Qty. (Base)" := RegWhseActLine."Qty. (Base)";
    //                 RegWhseActLine2.Weight := RegWhseActLine.Weight;
    //                 RegWhseActLine2.Modify;
    //             end;

    //             if WhseShipLine.Get(ShipmentNo, ShipmentLineNo) then begin
    //                 Comment := StrSubstNo(TEXT14229214, UserId, WhseShipLine."Item No.", WhseShipLine."Qty. Picked", TotalPickedLinesQty);
    //                 WMSServices.AddWhseComment(ShipmentNo, ShipmentLineNo, WhseCommentLine."Table Name"::"Whse. Shipment", 0, UserId, Comment);
    //                 WhseShipLine."Qty. Picked" := TotalPickedLinesQty;
    //                 WhseShipLine."Qty. Picked (Base)" := TotalPickedLinesQty * WhseShipLine."Qty. per Unit of Measure";
    //                 WhseShipLine."Qty. to Ship" := TotalPickedLinesQty;
    //                 WhseShipLine."Qty. to Ship (Base)" := TotalPickedLinesQty * WhseShipLine."Qty. per Unit of Measure";
    //                 WhseShipLine."Completely Picked" := false;
    //                 WhseShipLine.Modify;
    //             end;

    //             ShipDashBrd.Reset;
    //             ShipDashBrd.SetRange("Shipment No.", ShipmentNo);
    //             ShipDashBrd.SetRange("Shipment Line No.", ShipmentLineNo);
    //             if ShipDashBrd.FindFirst then begin
    //                 ShipDashBrd."Picked Qty." := TotalPickedLinesQty;
    //                 ShipDashBrd.Completed := false;
    //                 ShipDashBrd."Full Pick" := false;
    //                 ShipDashBrd.Modify;
    //             end;

    //             WhseSetup.Get; //<<EN1.02
    //                            /*
    //                            BillOfLadingDet.RESET;
    //                            BillOfLadingDet.SETRANGE("Container ID",ContID);
    //                            BillOfLadingDet.SETRANGE("Pallet No.",PalletNo);
    //                            BillOfLadingDet.SETRANGE("Pallet Line No.",PalletLineNo);
    //                            IF BillOfLadingDet.FINDFIRST THEN BEGIN
    //                              //<<EN1.02
    //                              IF WhseSetup."Enforce Loading check on BOL" THEN
    //                                IF BillOfLadingDet.Loaded THEN
    //                                  ERROR(STRSUBSTNO(TXT015,PalletNo));
    //                              //>>EN1.02

    //                              BillOfLadingHdr.GET(BillOfLadingDet."Bill of Lading No.") ;
    //                              IF BillOfLadingHdr.Status = BillOfLadingHdr.Status::Registered THEN
    //                                ERROR(TXT016);

    //                              BillOfLadingDet.VALIDATE("Qty on Pallet",NewEnteredQty); //EN1.42
    //                              IF BillOfLadingDet.Weight <> 0 THEN BEGIN
    //                                IF BillOfLadingDet."Qty on Pallet" <> 0 THEN
    //                                  WeightPerUnit := BillOfLadingDet.Weight / BillOfLadingDet."Qty on Pallet"
    //                                ELSE
    //                                  WeightPerUnit := 0;

    //                                NewWeightPerUnit := WeightPerUnit * NewEnteredQty;
    //                              END;

    //                              BillOfLadingDet.Weight := NewWeightPerUnit;
    //                              BillOfLadingDet.MODIFY;
    //                            END;
    //                            */
    //             if WhseSetup."Move Adjusted BOL Stock Back" then begin
    //                 Location.Get(LocCode);
    //                 CreateReverseJnl(LocCode, ItemNo, ItemUOM, Location."Shipment Bin Code", PutBackBin, QtyToReduce, CodeDate);
    //             end;
    //         end;
    //     end;
    //     //>>EN1.40     // 4/30/19 ks
    // end;

    //     procedure CreateReverseJnl(LocationCode: Code[10]; ItemNo: Code[20]; ItemUOM: Code[10]; FromBinCode: Code[10]; ReverseBinCode: Code[10]; QtyToMove: Decimal; CodeDate: Date)
    //     var
    //         WhseSetup: Record "Warehouse Setup";
    //         WhseWorkshtLine: Record "Whse. Worksheet Line";
    //         NextLineNo: Integer;
    //         WkshtName: Code[10];
    //         BatchName: Code[10];
    //     begin
    //         //<<EN1.40
    //         WhseSetup.Get;

    //         WhseWorkshtLine.Reset;
    //         WhseWorkshtLine.SetRange("Location Code", LocationCode);
    //         WhseWorkshtLine.SetRange("Worksheet Template Name", WhseSetup."WMS Movement Wksht Name");
    //         WhseWorkshtLine.SetRange(Name, WhseSetup."WMS Reverse Mov. Jnl Name");
    //         if WhseWorkshtLine.FindLast then
    //             NextLineNo := WhseWorkshtLine."Line No." + 10000
    //         else
    //             NextLineNo := 10000;

    //         WhseWorkshtLine.Init;
    //         WhseWorkshtLine."Worksheet Template Name" := WhseSetup."WMS Movement Wksht Name";//'MOVEMENT';
    //         WhseWorkshtLine.Name := WhseSetup."WMS Reverse Mov. Jnl Name";//BatchName; //'DEFAULT'; //EN1.36
    //         WhseWorkshtLine."Location Code" := LocationCode;
    //         WhseWorkshtLine."Line No." := NextLineNo;
    //         WhseWorkshtLine.Insert;
    //         WhseWorkshtLine.Validate("Item No.", ItemNo);
    //         WhseWorkshtLine.Validate("From Bin Code", FromBinCode);
    //         WhseWorkshtLine.Validate("To Bin Code", ReverseBinCode);
    //         WhseWorkshtLine.Validate("Unit of Measure Code", ItemUOM); //EN1.16
    //         WhseWorkshtLine.Validate(Quantity, QtyToMove);
    //         WhseWorkshtLine."Code Date" := CodeDate;  //EN1.16
    //         WhseWorkshtLine."Whse. Document Type" := WhseWorkshtLine."Whse. Document Type"::"Whse. Mov.-Worksheet";
    //         WhseWorkshtLine."Whse. Document No." := 'DEFAULT';
    //         WhseWorkshtLine."Whse. Document Line No." := NextLineNo;
    //         WhseWorkshtLine.Modify;

    //         //>>EN1.40
    //     end;

    procedure UpdateShipmntInfoDocuments(SalesHeader: Record "Sales Header")
    var
        ShipmntDshbrd: Record "Shipment Dashboard ELA";
        // BillOfLadingHdr: Record "Bill of Lading Header";
        WhseShpmntHdr: Record "Warehouse Shipment Header";
    begin
        //<<EN1.47
        ShipmntDshbrd.Reset;
        ShipmntDshbrd.SetRange(ShipmntDshbrd."Source No.", SalesHeader."No.");
        if ShipmntDshbrd.FindSet then begin
            repeat
                ShipmntDshbrd."Ship-to Code" := SalesHeader."Ship-to Code";
                ShipmntDshbrd."Ship-to Name" := SalesHeader."Ship-to Name";
                ShipmntDshbrd."Ship-to Address" := SalesHeader."Ship-to Address";
                ShipmntDshbrd."Ship-to Address 2" := SalesHeader."Ship-to Address 2";
                ShipmntDshbrd."Ship-to City" := SalesHeader."Ship-to City";
                ShipmntDshbrd."Ship-to State" := SalesHeader."Ship-to County";
                ShipmntDshbrd."Ship-to Zip Code" := SalesHeader."Ship-to Post Code";
                ShipmntDshbrd."Ship-to Country" := SalesHeader."Ship-to Country/Region Code";
                ShipmntDshbrd."Ship-to Contact" := SalesHeader."Ship-to Contact";
                ShipmntDshbrd.Modify;
            until ShipmntDshbrd.Next = 0;
        end;

        //tbr

        // BillOfLadingHdr.Reset;
        // BillOfLadingHdr.SetRange(BillOfLadingHdr."Sales Order No.", SalesHeader."No.");
        // if BillOfLadingHdr.FindFirst then begin
        //     if BillOfLadingHdr.Status = BillOfLadingHdr.Status::Registered then
        //         Error(StrSubstNo(Txt001, BillOfLadingHdr."No.", BillOfLadingHdr."Sales Order No."));

        //     BillOfLadingHdr."Ship-to Code" := SalesHeader."Ship-to Code";
        //     BillOfLadingHdr."Consignee Name" := SalesHeader."Ship-to Name";
        //     BillOfLadingHdr."Consignee Street" := SalesHeader."Ship-to Address";
        //     if SalesHeader."Ship-to County" <> '' then
        //         BillOfLadingHdr."Consignee City and State" := SalesHeader."Ship-to City" + ', ' + SalesHeader."Sell-to County"
        //     else
        //         BillOfLadingHdr."Consignee City and State" := SalesHeader."Ship-to City";
        //     BillOfLadingHdr."Consignee Zip" := SalesHeader."Ship-to Post Code";
        //     BillOfLadingHdr."Consignee Telelphone No." := SalesHeader."Ship-to Contact";
        //     BillOfLadingHdr.Modify;
        // end;

        // WhseShpmntHdr.Reset;
        // WhseShpmntHdr.SetRange(WhseShpmntHdr."Source Order No.", SalesHeader."No.");
        // if WhseShpmntHdr.FindFirst then begin
        //     WhseShpmntHdr."Source Ship-to" := SalesHeader."Ship-to Code";
        //     WhseShpmntHdr."Source Ship-to Name" := SalesHeader."Ship-to Name";

        // WhseShpmntHdr."Source Ship-to Address" := SalesHeader."Ship-to Address";
        // WhseShpmntHdr."Source Ship-to Address 2" := SalesHeader."Ship-to Address 2";
        // WhseShpmntHdr."Source Ship-to City" := SalesHeader."Ship-to City";
        // WhseShpmntHdr."Source Ship-to State" := SalesHeader."Sell-to County";
        // WhseShpmntHdr."Source Ship-to Zip Code" := SalesHeader."Ship-to Post Code";
        // WhseShpmntHdr."Source Ship-to Country" := SalesHeader."Ship-to Country/Region Code";
        // WhseShpmntHdr."Source Ship-to Contact" := SalesHeader."Ship-to Contact";
        // WhseShpmntHdr.Modify;
        // end;
        //>>EN1.47
    end;
}