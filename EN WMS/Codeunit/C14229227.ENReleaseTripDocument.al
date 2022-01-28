/// <summary>
/// Codeunit Release Trip Document (ID 142292227).
/// </summary>
codeunit 14229227 "Release Trip Document ELA"
{
    TableNo = "Trip Load ELA";
    Permissions = TableData "Trip Load ELA" = rm;

    trigger OnRun()
    begin
        ENTripLoad.Copy(Rec);
        Code();
        rec := ENTripLoad;
    end;

    var
        ENTripLoad: Record "Trip Load ELA";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";

    /// <summary>
    /// CloseTrip.
    /// </summary>
    /// <param name="Rec">Record "EN Trip Load".</param>
    procedure CloseTrip(Rec: Record "Trip Load ELA")
    var
        TripLoadOrders: Record "Trip Load Order ELA";
        AllOrdersArePosted: Boolean;
    begin

        AllOrdersArePosted := true;
        TripLoadOrders.reset;
        TripLoadOrders.SetRange("Load No.", rec."No.");
        if TripLoadOrders.findset then
            repeat
                // if TripLoadOrders."Posted. Whse. Shipment No." = '' then
                if not TripLoadOrders."Shipment Posted" then
                    AllOrdersArePosted := false;
            until TripLoadOrders.Next() = 0;

        if AllOrdersArePosted then begin
            Rec.Status := Rec.Status::Completed;
            Rec.Modify();
        end else
            error('All orders on trip needs to be posted');
    end;

    /// <summary>
    /// ReOpen.
    /// </summary>
    /// <param name="ENTripLoad">VAR Record "EN Trip Load".</param>
    procedure ReOpen(var ENTripLoad: Record "Trip Load ELA")
    var
        SalesHeader: Record "Sales Header";
        TripLoadOrders: Record "Trip Load Order ELA";
    begin
        TripLoadOrders.reset;
        TripLoadOrders.SetRange("Load No.", ENTripLoad."No.");
        if TripLoadOrders.findset then
            repeat
                // if TripLoadOrders."Source Document Type" = TripLoadOrders."Source Document Type"::"Sales Order" then begin

                // end;
                ENTripLoad.Status := ENTripLoad.Status::Open;
                ENTripLoad.Modify();
            until TripLoadOrders.Next() = 0;
    end;

    /// <summary>
    /// Code.
    /// </summary>
    local procedure Code()
    var
        SalesHeader: Record "Sales Header";
        TripLoadOrders: Record "Trip Load Order ELA";
        WhseShipNo: code[20];
    begin
        TripLoadOrders.reset;
        TripLoadOrders.SetRange("Load No.", ENTripLoad."No.");
        if TripLoadOrders.findset then
            repeat
                if TripLoadOrders."Source Document Type" = TripLoadOrders."Source Document Type"::"Sales Order" then begin
                    IF NOT SalesHeader.get(SalesHeader."Document Type"::Order, TripLoadOrders."Source Document No.") THEN
                        Error(
                            StrSubstNo(
                                'Unable to find %1 %2',
                            TripLoadOrders."Source Document Type"::"Sales Order",
                            SalesHeader."No."));


                    WhseShipNo := GetWhseShipmentByTripLoad(TripLoadOrders."Load No.");
                    AddOrderToWhseShipment(TripLoadOrders, WhseShipNo);
                    TripLoadOrders."Whse. Shipment No." := WhseShipNo;
                    TripLoadOrders.Modify();

                    ENTripLoad.Status := ENTripLoad.Status::"In Progress";
                    ENTripLoad.Modify();

                    IF NOT SalesHeader.FIND('=><') THEN
                        SalesHeader.INIT;
                end;

            until TripLoadOrders.Next() = 0;
    end;

    // procedure CreateWhseShipmentFromTrip(ENTripLoad: Record "EN Trip Load")
    // var
    //     ENTripLoadOrder: Record "EN Trip Load Order";
    //     SalesHeader: record "Sales Header";
    //     WhseRqst: record "Warehouse Request";
    //     WhseShptHeader: Record "Warehouse Shipment Header";
    //     WhseShptLine: Record "Warehouse Shipment Line";
    //     WhseShipNo: code[20];
    //     GetSourceDocuments: Report "Get Source Documents";
    // begin
    //     // todo @FSubhani1 need create multiple shipment for whse shipments
    //     // ENTripLoadOrder.reset;
    //     // // ks dont think we need whse shipment no on trip orders as there can be mulitple shipments.

    //     // // ENTripLoadOrder.SetFilter("Whse. Shipment No.", '=''');
    //     // // ENTripLoadOrder.SetFilter("Posted. Whse. Shipment No.", '<>''');
    //     // if ENTripLoadOrder.Findset() then
    //     //     repeat
    //     //         SalesHeader.get(SalesHeader."Document Type"::Order, ENTripLoadOrder."Source Document No.");
    //     //         GetSourceDocOutbound.CreateFromSalesOrderHideDialog(SalesHeader);
    //     //         WhseShptLine.reset;
    //     //         WhseShptLine.SetRange("Source No.", ENTripLoadOrder."Source Document No.");
    //     //         WhseShptLine.SetRange("Source Document", WhseShptLine."Source Document"::"Sales Order");
    //     //         if WhseShptLine.FindFirst() then begin
    //     //             WhseShptHeader.get(WhseShptLine."No.");
    //     //         end;

    //     //     until ENTripLoadOrder.Next() = 0;

    //     ENTripLoadOrder.reset;
    //     ENTripLoadOrder.SetRange("Load No.", ENTripLoad."No.");
    //     ENTripLoadOrder.SetRange(Direction, ENTripLoad.Direction::Outbound);
    //     ENTripLoadOrder.SetFilter("Whse. Shipment No.", '<>''');
    //     if ENTripLoadOrder.FindSet() then
    //         repeat
    //             WhseShptHeader.reset;
    //             WhseShptHeader.SetRange("Trip No.", ENTripLoad."No.");
    //             if not WhseShptHeader.FindFirst() then begin
    //                 WhseShptHeader.init;
    //                 WhseShptHeader.Insert(true);
    //                 WhseShptHeader.Validate("Location Code", ENTripLoad.Location);
    //                 WhseShptHeader.Validate("Posting Date", ENTripLoad."Load Date");
    //                 WhseShptHeader.validate("Shipment Date", ENTripLoad."Load Date");
    //                 WhseShptHeader."Trip No." := ENTripLoad."No.";
    //                 WhseShptHeader.Modify(true);
    //                 ENTripLoadOrder."Whse. Shipment No." := WhseShptHeader."No.";
    //                 ENTripLoadOrder.Modify();
    //             end else begin
    //                 GetSourceDocuments.SetOneCreatedShptHeader(WhseShptHeader);
    //                 GetSourceDocuments.SetHideDialog(TRUE);
    //                 GetSourceDocuments.SetSkipBlocked(TRUE);
    //                 GetSourceDocuments.USEREQUESTPAGE(FALSE);
    //                 GetSourceDocuments.SETTABLEVIEW(WhseRqst);
    //                 GetSourceDocuments.RUNMODAL;

    //                 WhseShptHeader.FINDFIRST;
    //                 WhseShptHeader."Document Status" := WhseShptHeader.GetDocumentStatus(0);
    //                 WhseShptHeader.MODIFY;
    //                 ENTripLoadOrder."Whse. Shipment No." := WhseShptHeader."No.";
    //                 ENTripLoadOrder.Modify();
    //             end;
    //         until ENTripLoadOrder.Next() = 0;
    // end;

    local procedure GetWhseShipmentByTripLoad(TripNo: Code[20]): code[20]
    var
        WhseShptHeader: Record "Warehouse Shipment Header";
        WhseShptHeader2: Record "Warehouse Shipment Header";
    begin
        WhseShptHeader.reset;
        WhseShptHeader.SetRange("Trip No. ELA", TripNo);
        if not WhseShptHeader.FindFirst() then begin
            WhseShptHeader2.Insert(true);
            WhseShptHeader2.Validate("Location Code", ENTripLoad.Location);
            WhseShptHeader2.Validate("Posting Date", ENTripLoad."Load Date");
            WhseShptHeader2.validate("Shipment Date", ENTripLoad."Load Date");
            WhseShptHeader2."Trip No. ELA" := ENTripLoad."No.";
            WhseShptHeader2.Modify(true);
            exit(WhseShptHeader2."No.");
        end else
            exit(WhseShptHeader."No.");
    end;

    local procedure AddOrderToWhseShipment(TripLoadOrders: Record "Trip Load Order ELA"; WhseShipmentNo: code[20])
    var
        WhseRqst: record "Warehouse Request";
        WhseShptHeader: record "Warehouse Shipment Header";
        GetSourceDocuments: Report "Get Source Documents";
    begin
        WhseRqst.reset;
        if TripLoadOrders."Source Document Type" = TripLoadOrders."Source Document Type"::"Sales Order" then
            WhseRqst.SetRange("Source Document", WhseRqst."Source Document"::"Sales Order");

        WhseRqst.SetRange("Source No.", TripLoadOrders."Source Document No.");
        WhseRqst.FindFirst();
        WhseShptHeader.get(WhseShipmentNo);

        GetSourceDocuments.SetOneCreatedShptHeader(WhseShptHeader);
        GetSourceDocuments.SetHideDialog(TRUE);
        GetSourceDocuments.SetSkipBlocked(TRUE);
        GetSourceDocuments.USEREQUESTPAGE(FALSE);
        GetSourceDocuments.SETTABLEVIEW(WhseRqst);
        GetSourceDocuments.RUNMODAL;

        WhseShptHeader.FINDFIRST;
        WhseShptHeader."Document Status" := WhseShptHeader.GetDocumentStatus(0);
        WhseShptHeader.MODIFY;
    end;
}
