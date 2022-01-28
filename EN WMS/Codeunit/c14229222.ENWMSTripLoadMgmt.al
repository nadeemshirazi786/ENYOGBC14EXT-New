//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Codeunit EN WMS Trip Load Mgmt. (ID 14229222).
/// </summary>
codeunit 14229222 "WMS Trip Load Mgmt. ELA"
{

    //todo #4 @rpatelelation please work onthis codeunit

    var
        TEXT14229200: TextConst ENU = '%1 Trip Load No. %2 is not open';

    /// <summary>
    /// AddOrderOnTrip.
    /// </summary>
    /// <param name="LoadNo">code[20].</param>
    /// <param name="Direction">Option.</param>
    /// <param name="SourceDocType">Option.</param>
    /// <param name="SourceDocumentNo">Code[20].</param>
    /// <returns>Return value of type code[20].</returns>
    procedure AddOrderOnTrip(LoadNo: code[20]; Direction: Enum "WMS Trip Direction ELA"; SourceDocType: Enum "WMS Source Doc Type ELA";
         SourceDocumentNo: Code[20]): code[20]
    var
        Trip: record "Trip Load ELA";
        TripLoadOrder: Record "Trip Load Order ELA";
        SalesHeader: Record "Sales Header";
        TransferHeader: Record "Transfer Header";
        PurchaseHeader: record "Purchase Header";
    begin
        if trip.get(LoadNo, Direction) then begin
            if trip.Status IN [trip.Status::Open, trip.Status::"In Progress"] then begin
                if not TripLoadOrder.get(LoadNo, Direction, SourceDocType, SourceDocumentNo) then begin
                    if (SourceDocType = SourceDocType::"Sales Order") then
                        SalesHeader.Get(SalesHeader."Document Type"::Order, SourceDocumentNo)
                    else
                        if (SourceDocType = SourceDocType::"Transfer Order") then
                            TransferHeader.Get(SourceDocumentNo)
                        else
                            if (SourceDocType = SourceDocType::"Purchase Order") then
                                PurchaseHeader.get(PurchaseHeader."Document Type"::Order, SourceDocumentNo);

                    TripLoadOrder.init;
                    TripLoadOrder."Load No." := loadno;
                    TripLoadOrder.Direction := direction;
                    TripLoadOrder."Source Document Type" := SourceDocType;
                    TripLoadOrder."Source Document No." := SourceDocumentNo;
                    case TripLoadOrder."Source Document Type" of
                        TripLoadOrder."Source Document Type"::"Sales Order":
                            begin
                                TripLoadOrder."Source Code" := SalesHeader."Sell-to Customer No.";
                                TripLoadOrder."Source Type" := TripLoadOrder."Source Type"::Customer;
                                // TripLoadOrder."Destination Type" := TripLoadOrder."Destination Type"::Outbound;
                                TripLoadOrder."External Doc. No." := SalesHeader."External Document No.";
                                TripLoadOrder."Stop No." := SalesHeader."Stop No. ELA";
                            end;
                        TripLoadOrder."Source Document Type"::"Transfer Order":
                            begin
                                TripLoadOrder."Source Code" := TransferHeader."Transfer-to Code";
                                TripLoadOrder."Source Type" := TripLoadOrder."Source Type"::Location;
                                TripLoadOrder."External Doc. No." := TransferHeader."External Document No.";
                            end;

                        TripLoadOrder."Source Document Type"::"Purchase Order":
                            begin
                                TripLoadOrder."Source Code" := PurchaseHeader."Buy-from Vendor No.";
                                TripLoadOrder."Source Type" := TripLoadOrder."Source Type"::Vendor;
                                TripLoadOrder."External Doc. No." := PurchaseHeader."Your Reference";
                            end;
                    end;

                    TripLoadOrder.Insert(true);
                    exit(TripLoadOrder."Load No.");
                end else begin
                    Trip.Status := Trip.Status::Open;
                    trip.Modify();
                    exit(TripLoadOrder."Load No.");
                end;
            end else
                error(StrSubstNo(TEXT14229200, Direction, LoadNo));
        end;
    end;


    /// <summary>
    /// AddSalesOrderOnTrip.
    /// </summary>
    /// <param name="SourceDocumentType">Enum "EN WMS Source Doc Type".</param>
    /// <param name="SalesHeader">record "Sales Header".</param>
    /// <returns>Return value of type code[20].</returns>
    procedure AddSalesOrderOnTrip(SourceDocumentType: Enum "WMS Source Doc Type ELA"; SalesHeader: record "Sales Header"): code[20]
    var
        TripLoad: Record "Trip Load ELA";
        TripLoadOrder: Record "Trip Load Order ELA";
        ENTripDir: Enum "WMS Trip Direction ELA";
        TripNo: code[20];
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        TripLoad.reset;
        TripLoad.setrange("Load Date", SalesHeader."Shipment Date");
        TripLoad.SetRange("Route No.", SalesHeader."Route No. ELA");
        if NOT TripLoad.findfirst then begin
            IF SalesSetup."Auto Create Trip ELA" THEN begin
                TripNo := CreateTrip(TripLoad.Direction::Outbound, SalesHeader."Route No. ELA", SalesHeader."Shipment Date");
                TripLoad.get(TripNo, TripLoad.Direction::Outbound);
            end;
        end;

        TripLoadOrder.reset;
        TripLoadOrder.SetRange("Load No.", TripLoad."No.");
        TripLoadOrder.SetRange(Direction, TripLoad.Direction::Outbound);
        TripLoadOrder.SetRange("Source Document Type", TripLoadOrder."Source Document Type"::"Sales Order");
        TripLoadOrder.SetRange("Source Document No.", SalesHeader."No.");
        TripLoadOrder.SetRange("Shipment Date", SalesHeader."Shipment Date");
        if not TripLoadOrder.FindFirst() then
            exit(AddOrderOnTrip(TripLoad."No.", TripLoad.Direction::Outbound, SourceDocumentType, SalesHeader."No."));
    end;

    /// <summary>
    /// CheckIfDocumentToBeAddedOnShipmentLoad.
    /// </summary>
    /// <param name="SourceDocType">Option.</param>
    /// <param name="SourceDocumentNo">code[20].</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure CheckIfDocumentToBeAddedOnShipmentLoad(SourceDocType: Enum "WMS Source Doc Type ELA"; SourceDocumentNo: code[20]): Boolean
    var
        SalesHeader: Record "Sales header";
        Customer: Record "Customer";
        TransferHeader: record "Transfer Header";
        PurchaseHeader: Record "Purchase Header";
        TripLoad: Record "Trip Load ELA";
        TripLoadOrder: record "Trip Load Order ELA";
    begin
        if (SourceDocType = SourceDocType::"Sales Order") then begin
            SalesHeader.Get(SalesHeader."Document Type"::Order, SourceDocumentNo);
            TripLoadOrder.reset;
            TripLoadOrder.SetRange("Source Document Type", TripLoadOrder."Source Document Type"::"Sales Order");
            TripLoadOrder.SetRange("Source Document No.", SourceDocumentNo);
            TripLoadOrder.SetRange("Shipment Date", SalesHeader."Shipment Date");
            if TripLoadOrder.FindFirst() then
                exit(true);
        end else
            if (SourceDocType = SourceDocType::"Transfer Order") then begin
                TransferHeader.Get(SourceDocumentNo);
                TripLoadOrder.reset;
                TripLoadOrder.SetRange("Source Document Type", TripLoadOrder."Source Document Type"::"Transfer Order");
                TripLoadOrder.SetRange("Source Document No.", SourceDocumentNo);
                TripLoadOrder.SetRange("Shipment Date", TransferHeader."Shipment Date");
                if TripLoadOrder.FindFirst() then
                    exit(true);
            end else
                if (SourceDocType = SourceDocType::"Purchase Order") then begin
                    PurchaseHeader.get(PurchaseHeader."Document Type"::Order, SourceDocumentNo);
                    TripLoadOrder.reset;
                    TripLoadOrder.SetRange("Source Document Type", TripLoadOrder."Source Document Type"::"Purchase Order");
                    TripLoadOrder.SetRange("Source Document No.", SourceDocumentNo);
                    TripLoadOrder.SetRange("Shipment Date", PurchaseHeader."Pickup Date ELA");
                    if TripLoadOrder.FindFirst() then
                        exit(true);
                end;
    end;


    // procedure AddTransferOrderOnTrip(SourceDocumentType: Option; SalesHeader: record "Transfer Header")
    // var
    //     TripLoad: Record "EN Trip Load";
    //     TripLoadOrder: Record "EN Trip Load Order";

    //     TripNo: code[20];
    // begin
    //     TripLoad.reset;
    //     TripLoad.setrange("Load Date", SalesHeader."Shipment Date");
    //     TripLoad.SetRange("Route No.", SalesHeader."Delivery Route No.");
    //     if NOT TripLoad.findfirst then
    //         TripNo := CreateTrip(TripLoad.Direction::Outbound, SalesHeader."Delivery Route No.", SalesHeader."Shipment Date");

    //     TripLoadOrder.reset;
    //     TripLoadOrder.SetRange("Load No.", TripLoad."No.");
    //     TripLoadOrder.SetRange(Direction, TripLoad.Direction::Outbound);
    //     TripLoadOrder.SetRange("Source Document Type", TripLoadOrder."Source Document Type"::"Sales Order");
    //     TripLoadOrder.SetRange("Source Document No.", SalesHeader."No.");
    //     TripLoadOrder.SetRange("Shipment Date", SalesHeader."Shipment Date");
    //     if not TripLoadOrder.FindFirst() then
    //         AddOrderOnTrip(TripLoad."No.", TripLoad.Direction, SourceDocumentType, SalesHeader."No.");
    // end;

    /// <summary>
    /// CreateTrip.
    /// </summary>
    /// <param name="TripDirection">option.</param>
    /// <param name="RouteNo">code[10].</param>
    /// <param name="TripDate">Date.</param>
    /// <returns>Return value of type code[20].</returns>
    procedure CreateTrip(TripDirection: Enum "WMS Trip Direction ELA"; RouteNo: code[10]; TripDate: Date): code[20]
    var
        TripLoad: Record "Trip Load ELA";
    begin
        TripLoad.Init();
        TripLoad.Direction := TripDirection;
        TripLoad."Route No." := RouteNo;
        TripLoad."Load Date" := TripDate;
        TripLoad.Insert(true);
        exit(TripLoad."No.");
    end;

    /// <summary>
    /// RemoveOrderFromTrip.
    /// </summary>
    /// <param name="LoadNo">code[20].</param>
    /// <param name="Direction">Option.</param>
    /// <param name="SourceDocType">Option.</param>
    /// <param name="SourceDocumentNo">Code[20].</param>
    procedure RemoveOrderFromTrip(LoadNo: code[20]; Direction: Enum "WMS Trip Direction ELA"; SourceDocType: Enum "WMS Source Doc Type ELA";
        SourceDocumentNo: Code[20])
    var
        Trip: record "Trip Load ELA";
        TripLoadOrder: Record "Trip Load Order ELA";
    begin
        if trip.get(LoadNo, Direction) then begin
            if trip.Status <> trip.Status::Completed then begin
                if TripLoadOrder.get(LoadNo, Direction, SourceDocType, SourceDocumentNo) then
                    TripLoadOrder.Delete(true);
            end;
        end;
    end;

    /// <summary>
    /// RemoveOrderFromShipment.
    /// </summary>
    /// <param name="SourceDocument">Option.</param>
    /// <param name="SourceNo">Code[20].</param>
    /// <param name="TripNo">Code[20].</param>
    procedure RemoveOrderFromShipment(SourceDocument: Option; SourceNo: Code[20]; TripNo: Code[20])
    var
        Trip: Record "Trip Load ELA";
        TripLoadOrder: Record "Trip Load Order ELA";
        WhseShipmentLine: record "Warehouse Shipment Line";
    begin
        TripLoadOrder.reset;
        TripLoadOrder.SetRange("Load No.", TripNo);
        TripLoadOrder.SetRange(Direction, TripLoadOrder.Direction::Outbound);
        TripLoadOrder.SetRange("Source Document No.", SourceNo);
        if (SourceDocument = WhseShipmentLine."Source Document"::"Sales Order") then
            TripLoadOrder.SetRange("Source Document Type", TripLoadOrder."Source Document Type"::"Sales Order")
        else
            if (SourceDocument = WhseShipmentLine."Source Document"::"Outbound Transfer") then
                TripLoadOrder.SetRange("Source Document Type", TripLoadOrder."Source Document Type"::"Transfer Order");

        if TripLoadOrder.FindFirst() then
            RemoveOrderFromTrip(TripNo, TripLoadOrder.Direction, TripLoadOrder."Source Document Type",
                 TripLoadOrder."Source Document No.");
    end;
}
