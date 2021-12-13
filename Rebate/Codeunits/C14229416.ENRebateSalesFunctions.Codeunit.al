codeunit 14229416 "Rebate Sales Functions ELA"
{
    // ENRE1.00 2021-08-26 AJ


    trigger OnRun()
    begin
    end;

    var
        gblnSkipContLine: Boolean;
        grecInvSetup: Record "Inventory Setup";
        gcodItemNo: Code[20];
        gblnSkipInit: Boolean;
        gFromStatistics: Boolean;
        gAddUntracked: Boolean;
        gblnSuppressErrors: Boolean;


    procedure IsCatchWeightItem(pcodItemNo: Code[20]; pblnTestNetWeight: Boolean): Boolean
    var
        lrecItem: Record Item;
        lrecItemTrackingCode: Record "Item Tracking Code";
        ltext000: Label 'Item No. %1 is defined as a catch weight item, however no %2 is defined on the Item Card.';
    begin
        //<ENRE1.00>
        if pcodItemNo = '' then
            exit;

        if lrecItem.Get(pcodItemNo) then begin
            //<ENRE1.00>
            if lrecItem."Item Tracking Code" = '' then begin
                exit(false);
            end;
            //</ENRE1.00>

            lrecItemTrackingCode.Get(lrecItem."Item Tracking Code");

            //<ENRE1.00>
            if lrecItemTrackingCode."Variable Weight Tracking ELA" then begin
                //<ENRE1.00>
                if pblnTestNetWeight and (lrecItem."Net Weight" = 0) then
                    //</ENRE1.00>
                    Error(ltext000, lrecItem."No.", lrecItem.FieldCaption("Net Weight"));
            end;
            //</ENRE1.00>

            exit(lrecItemTrackingCode."Variable Weight Tracking ELA");
            //</ENRE1.00>
        end;

        exit(false);
    end;


    procedure GetCatchWeightSettings(var precItemTrackingCode: Record "Item Tracking Code"; var pblnCatchWeightRequired: Boolean)
    begin
        //<ENRE1.00>
        pblnCatchWeightRequired := false;

        if precItemTrackingCode.Code = '' then begin
            Clear(precItemTrackingCode);
            exit;
        end else
            precItemTrackingCode.Get(precItemTrackingCode.Code);

        pblnCatchWeightRequired :=
        //<ENRE1.00>
          (precItemTrackingCode."Variable Weight Tracking ELA");
        //</ENRE1.00>
        //</ENRE1.00>
    end;


    procedure HasCatchWeightOnHand(pcodItemNo: Code[20]; pcodVariantCode: Code[20]; pcodSerialNo: Code[20]): Boolean
    var
        lrecSerialInfo: Record "Serial No. Information";
    begin
        //<ENRE1.00>
        if (pcodSerialNo = '') or (pcodItemNo = '') then
            exit;

        if lrecSerialInfo.Get(pcodItemNo, pcodVariantCode, pcodSerialNo) then begin
            lrecSerialInfo.CalcFields(Inventory);
            exit(lrecSerialInfo.Inventory <> 0);
        end;
        //</ENRE1.00>
    end;


    procedure UpdateCatchWeightHistory(pcodItemNo: Code[20]; pcodVariantCode: Code[20]; pcodSerialNo: Code[20]; pdecNewUnitWeight: Decimal; pblnBypassConfirm: Boolean)
    var
        lText000: Label 'In order to update catch weight history, you must provide an item no. and serial no.';
        lrecItemLedgEntry: Record "Item Ledger Entry";
        lrecWhseEntry: Record "Warehouse Entry";
        lText001: Label 'Process cancelled by user.';
        lText002: Label 'Are you sure you want to update the catch weight for Item No. %1, Variant Code %2, Serial No. %3 to %4 %5?';
        lText003: Label 'Item No. is not set up as a catch weight item.';
        lintSign: Integer;
        ldlgWindow: Dialog;
        lintTotalCount: BigInteger;
        lintCounter: BigInteger;
        lText004: Label 'Updating Item Ledger Entries @1@@@@@@@@@@@';
        lText005: Label 'Updating Warehouse Entries @1@@@@@@@@@@@';
    begin
        //<ENRE1.00>
        if (pcodItemNo = '') or (pcodSerialNo = '') then
            Error(lText000);

        //-- Make sure we have a positive number here
        pdecNewUnitWeight := Abs(pdecNewUnitWeight);

        grecInvSetup.Get;

        if IsCatchWeightItem(pcodItemNo, false) then begin
            if (not pblnBypassConfirm) and (GuiAllowed) then begin
                if not Confirm(lText002, false, pcodItemNo, pcodVariantCode, pcodSerialNo,
                               pdecNewUnitWeight, grecInvSetup."Standard Weight UOM ELA") then
                    Error(lText001);
            end;

            //-- Item Ledger
            lrecItemLedgEntry.SetRange("Item No.", pcodItemNo);
            lrecItemLedgEntry.SetRange("Variant Code", pcodVariantCode);
            lrecItemLedgEntry.SetRange("Serial No.", pcodSerialNo);

            if not lrecItemLedgEntry.IsEmpty then begin
                lrecItemLedgEntry.FindSet(true);

                if GuiAllowed then begin
                    lintTotalCount := lrecItemLedgEntry.Count;
                    lintCounter := 0;

                    ldlgWindow.Open(lText004);
                end;

                repeat
                    if GuiAllowed then begin
                        lintCounter += 1;
                        ldlgWindow.Update(1, Round(lintCounter / lintTotalCount) * 10000);
                    end;

                    if lrecItemLedgEntry.Quantity < 1 then
                        lintSign := -1
                    else
                        lintSign := 1;

                    lrecItemLedgEntry."Net Weight ELA" := pdecNewUnitWeight * lintSign;
                    lrecItemLedgEntry.Modify;
                until lrecItemLedgEntry.Next = 0;

                if GuiAllowed then begin
                    ldlgWindow.Close;
                end;
            end;

            //-- Warehouse Entry
            lrecWhseEntry.SetRange("Item No.", pcodItemNo);
            lrecWhseEntry.SetRange("Variant Code", pcodVariantCode);
            lrecWhseEntry.SetRange("Serial No.", pcodSerialNo);

            if not lrecWhseEntry.IsEmpty then begin
                lrecWhseEntry.FindSet(true);

                if GuiAllowed then begin
                    lintTotalCount := lrecWhseEntry.Count;
                    lintCounter := 0;

                    ldlgWindow.Open(lText005);
                end;

                repeat
                    if GuiAllowed then begin
                        lintCounter += 1;
                        ldlgWindow.Update(1, Round(lintCounter / lintTotalCount) * 10000);
                    end;

                    if lrecWhseEntry.Quantity < 1 then
                        lintSign := -1
                    else
                        lintSign := 1;

                    lrecWhseEntry.Weight := pdecNewUnitWeight * lintSign;
                    lrecWhseEntry.Modify;
                until lrecWhseEntry.Next = 0;

                if GuiAllowed then begin
                    ldlgWindow.Close;
                end;
            end;
        end else begin
            if not pblnBypassConfirm then
                Error(lText003, pcodItemNo);
        end;
        //</ENRE1.00>
    end;


    procedure GetCatchWeightILE(var precTempReservEntry: Record "Reservation Entry"; pcodItemNo: Code[20]; pcodLotNo: Code[50]; pcodSerialNo: Code[50]): Decimal
    var
        lrecILE: Record "Item Ledger Entry";
    begin
        //<ENRE1.00>
        if ((pcodLotNo = '') and (pcodSerialNo = '')) or
           (pcodItemNo = '')
        then
            exit(0);


        lrecILE.SetRange("Item No.", pcodItemNo);
        //<ENRE1.00>
        if precTempReservEntry."Location Code" <> '' then begin
            lrecILE.SetRange("Location Code", precTempReservEntry."Location Code");
        end;
        //</ENRE1.00>
        if pcodLotNo <> '' then
            lrecILE.SetRange("Lot No.", pcodLotNo);
        if pcodSerialNo <> '' then
            lrecILE.SetRange("Serial No.", pcodSerialNo);

        lrecILE.CalcSums("Net Weight ELA");

        exit(lrecILE."Net Weight ELA");
        //</ENRE1.00>
    end;


    procedure CalcNetWeightTotals(pintTableID: Integer; var prfRecordRef: RecordRef; var pdecTotalNet: Decimal; var pdecToShipRecNet: Decimal; var pdecShippedReceivedNet: Decimal; var pdecToInvoiceNet: Decimal; var pdecInvoicedNet: Decimal; poptDirection: Option Outbound,Inbound)
    var
        lrecItem: Record Item;
        lrecItemTrackingCode: Record "Item Tracking Code";
        lrecWRLine: Record "Warehouse Receipt Line";
        lrecPurchaseLine: Record "Purchase Line";
        lrecWSLine: Record "Warehouse Shipment Line";
        lrecSalesLine: Record "Sales Line";
        lintTableID: Integer;
        lrecTransferLine: Record "Transfer Line";
    begin
        //<ENRE1.00>
        pdecToShipRecNet := 0;
        pdecShippedReceivedNet := 0;
        pdecToInvoiceNet := 0;
        pdecInvoicedNet := 0;
        pdecTotalNet := 0;

        if not CheckValues(pintTableID, prfRecordRef, poptDirection) then
            exit;

        lrecItem.Get(gcodItemNo);
        if lrecItem."Item Tracking Code" = '' then begin
            //Non Tracked
            if lrecItem.Get(gcodItemNo) then begin
                CalcNetWeightNonTracked(pintTableID, prfRecordRef, pdecTotalNet, pdecToShipRecNet, pdecShippedReceivedNet, pdecToInvoiceNet, pdecInvoicedNet, poptDirection);
            end;

        end else begin
            //Tracked

            case pintTableID of
                DATABASE::"Warehouse Receipt Line":
                    //,Sales Order,,,Sales Return Order,Purchase Order,,,Purchase Return Order,Inbound Transfer
                    begin
                        prfRecordRef.SetTable(lrecWRLine);
                        case lrecWRLine."Source Document" of
                            lrecWRLine."Source Document"::"Purchase Order",
                            lrecWRLine."Source Document"::"Purchase Return Order":
                                begin
                                    lintTableID := DATABASE::"Purchase Line";
                                    lrecPurchaseLine.Get(lrecWRLine."Source Subtype", lrecWRLine."Source No.", lrecWRLine."Source Line No.");
                                    prfRecordRef.GetTable(lrecPurchaseLine);
                                    prfRecordRef.SetTable(lrecPurchaseLine);
                                end;
                            lrecWRLine."Source Document"::"Sales Order",
                            lrecWRLine."Source Document"::"Sales Return Order":
                                begin
                                    lintTableID := DATABASE::"Sales Line";
                                    lrecSalesLine.Get(lrecWRLine."Source Subtype", lrecWRLine."Source No.", lrecWRLine."Source Line No.");
                                    prfRecordRef.GetTable(lrecSalesLine);
                                    prfRecordRef.SetTable(lrecSalesLine);
                                end;
                            lrecWRLine."Source Document"::"Inbound Transfer":
                                begin
                                    lintTableID := DATABASE::"Transfer Line";
                                    lrecTransferLine.Get(lrecWRLine."Source No.", lrecWRLine."Source Line No.");
                                    prfRecordRef.GetTable(lrecTransferLine);
                                    prfRecordRef.SetTable(lrecTransferLine);
                                end;
                        end;
                    end;
                DATABASE::"Warehouse Shipment Line":
                    //,Sales Order,,,Sales Return Order,Purchase Order,,,Purchase Return Order,,Outbound Transfer,,,,,,,,Service Order
                    begin
                        prfRecordRef.SetTable(lrecWSLine);
                        case lrecWSLine."Source Document" of
                            lrecWSLine."Source Document"::"Sales Order":
                                begin
                                    lintTableID := DATABASE::"Sales Line";
                                    lrecSalesLine.Get(lrecWSLine."Source Subtype", lrecWSLine."Source No.", lrecWSLine."Source Line No.");
                                    prfRecordRef.GetTable(lrecSalesLine);
                                    prfRecordRef.SetTable(lrecSalesLine);
                                end;
                            lrecWSLine."Source Document"::"Purchase Order",
                            lrecWSLine."Source Document"::"Purchase Return Order":
                                begin
                                    lintTableID := DATABASE::"Purchase Line";
                                    lrecPurchaseLine.Get(lrecWSLine."Source Subtype", lrecWSLine."Source No.", lrecWSLine."Source Line No.");
                                    prfRecordRef.GetTable(lrecPurchaseLine);
                                    prfRecordRef.SetTable(lrecPurchaseLine);
                                end;
                            lrecWSLine."Source Document"::"Outbound Transfer":
                                begin
                                    lintTableID := DATABASE::"Transfer Line";
                                    lrecTransferLine.Get(lrecWSLine."Source No.", lrecWSLine."Source Line No.");
                                    prfRecordRef.GetTable(lrecTransferLine);
                                    prfRecordRef.SetTable(lrecTransferLine);
                                end;
                        end;
                    end;
                else
                    lintTableID := pintTableID;
            end;


            CalcNetWeightTracked(lintTableID, prfRecordRef, pdecTotalNet, pdecToShipRecNet, pdecShippedReceivedNet, pdecToInvoiceNet, pdecInvoicedNet, poptDirection);
        end;
        //</ENRE1.00>
    end;

    local procedure CheckValues(pintTableID: Integer; var prfRecordRef: RecordRef; poptDirection: Option Outbound,Inbound): Boolean
    var
        lrecItem: Record Item;
        lrecPurchaseLine: Record "Purchase Line";
        lrecSalesLine: Record "Sales Line";
        lrecTransferLine: Record "Transfer Line";
        lrecItemJnlLine: Record "Item Journal Line";
        lrecWRLine: Record "Warehouse Receipt Line";
        lrecWSLine: Record "Warehouse Shipment Line";
        lProdOrderLine: Record "Prod. Order Line";
        lrecItemTrackingCode: Record "Item Tracking Code";
        ltxtItem: Text;
        lfrFieldRef: FieldRef;
        ldecQtyBase: Decimal;
        lblnAdjustment: Boolean;
        lblnCorrection: Boolean;
    begin
        //<ENRE1.00>
        case pintTableID of
            DATABASE::"Sales Line":
                begin
                    prfRecordRef.SetTable(lrecSalesLine);

                    lfrFieldRef := prfRecordRef.Field(lrecSalesLine.FieldNo(Type));
                    ltxtItem := Format(lfrFieldRef.Value);
                    if ltxtItem <> Format(lrecSalesLine.Type::Item) then
                        exit;

                    lfrFieldRef := prfRecordRef.Field(lrecSalesLine.FieldNo("Quantity (Base)"));
                    ldecQtyBase := lfrFieldRef.Value;
                    if ldecQtyBase = 0 then begin
                        exit;
                    end;

                    lfrFieldRef := prfRecordRef.Field(lrecSalesLine.FieldNo("No."));
                    gcodItemNo := Format(lfrFieldRef.Value);
                    if gcodItemNo = '' then
                        exit;

                end;
            DATABASE::"Purchase Line":
                begin
                    prfRecordRef.SetTable(lrecPurchaseLine);
                    lfrFieldRef := prfRecordRef.Field(lrecPurchaseLine.FieldNo(Type));
                    ltxtItem := Format(lfrFieldRef.Value);
                    if ltxtItem <> Format(lrecPurchaseLine.Type::Item) then
                        exit;

                    lfrFieldRef := prfRecordRef.Field(lrecPurchaseLine.FieldNo("Quantity (Base)"));
                    ldecQtyBase := lfrFieldRef.Value;
                    if ldecQtyBase = 0 then
                        exit;

                    lfrFieldRef := prfRecordRef.Field(lrecPurchaseLine.FieldNo("No."));
                    gcodItemNo := Format(lfrFieldRef.Value);
                    if gcodItemNo = '' then
                        exit;

                end;

            DATABASE::"Transfer Line":
                begin
                    prfRecordRef.SetTable(lrecTransferLine);

                    case poptDirection of
                        poptDirection::Outbound:
                            begin
                                lfrFieldRef := prfRecordRef.Field(lrecTransferLine.FieldNo("Quantity (Base)"));
                                ldecQtyBase := lfrFieldRef.Value;
                                if ldecQtyBase = 0 then
                                    exit;
                            end;
                        poptDirection::Inbound:
                            begin

                                lfrFieldRef := prfRecordRef.Field(lrecTransferLine.FieldNo("Quantity (Base)"));
                                ldecQtyBase := lfrFieldRef.Value;
                                if ldecQtyBase = 0 then
                                    exit;
                            end;
                    end;

                    lfrFieldRef := prfRecordRef.Field(lrecTransferLine.FieldNo("Item No."));
                    gcodItemNo := Format(lfrFieldRef.Value);
                    if gcodItemNo = '' then
                        exit;
                end;


            DATABASE::"Item Journal Line":
                begin
                    lfrFieldRef := prfRecordRef.Field(lrecItemJnlLine.FieldNo("Quantity (Base)"));
                    ldecQtyBase := lfrFieldRef.Value;
                    if ldecQtyBase = 0 then
                        exit;

                    lfrFieldRef := prfRecordRef.Field(lrecItemJnlLine.FieldNo("Item No."));
                    gcodItemNo := Format(lfrFieldRef.Value);
                    if gcodItemNo = '' then
                        exit;

                    lfrFieldRef := prfRecordRef.Field(lrecItemJnlLine.FieldNo(Adjustment));
                    lblnAdjustment := lfrFieldRef.Value;
                    if lblnAdjustment then
                        exit;

                    lfrFieldRef := prfRecordRef.Field(lrecItemJnlLine.FieldNo(Correction));
                    lblnCorrection := lfrFieldRef.Value;
                    if lblnCorrection then
                        exit;

                end;


            DATABASE::"Warehouse Receipt Line":
                begin
                    lfrFieldRef := prfRecordRef.Field(lrecWRLine.FieldNo("Qty. (Base)"));
                    ldecQtyBase := lfrFieldRef.Value;
                    if ldecQtyBase = 0 then
                        exit;

                    lfrFieldRef := prfRecordRef.Field(lrecWRLine.FieldNo("Item No."));
                    gcodItemNo := Format(lfrFieldRef.Value);
                    if gcodItemNo = '' then
                        exit;

                end;


            DATABASE::"Warehouse Shipment Line":
                begin
                    lfrFieldRef := prfRecordRef.Field(lrecWSLine.FieldNo("Qty. (Base)"));
                    ldecQtyBase := lfrFieldRef.Value;
                    if ldecQtyBase = 0 then
                        exit;

                    lfrFieldRef := prfRecordRef.Field(lrecWSLine.FieldNo("Item No."));
                    gcodItemNo := Format(lfrFieldRef.Value);
                    if gcodItemNo = '' then
                        exit;

                end;

            //<ENRE1.00>
            DATABASE::"Prod. Order Line":
                begin
                    lfrFieldRef := prfRecordRef.Field(lProdOrderLine.FieldNo("Quantity (Base)"));
                    ldecQtyBase := lfrFieldRef.Value;
                    if ldecQtyBase = 0 then
                        exit;

                    lfrFieldRef := prfRecordRef.Field(lProdOrderLine.FieldNo("Item No."));
                    gcodItemNo := Format(lfrFieldRef.Value);
                    if gcodItemNo = '' then
                        exit;

                end;
        //</ENRE1.00>

        end;


        exit(true);
        //</ENRE1.00>
    end;

    local procedure CalcNetWeightNonTracked(pintTableID: Integer; var prfRecordRef: RecordRef; var pdecTotalNet: Decimal; var pdecToShipRecNet: Decimal; var pdecShippedReceivedNet: Decimal; var pdecToInvoiceNet: Decimal; var pdecInvoicedNet: Decimal; poptDirection: Option Outbound,Inbound)
    var
        lrecPurchaseLine: Record "Purchase Line";
        lrecSalesLine: Record "Sales Line";
        lrecTransferLine: Record "Transfer Line";
        lrecItemJnlLine: Record "Item Journal Line";
        lrecWRLine: Record "Warehouse Receipt Line";
        lrecWSLine: Record "Warehouse Shipment Line";
        lProdOrderLine: Record "Prod. Order Line";
        lrecItem: Record Item;
        ldecQty: Decimal;
        lfrFieldRef: FieldRef;
    begin
        //<ENRE1.00>
        //Non Tracked
        if lrecItem.Get(gcodItemNo) then begin
            case pintTableID of
                DATABASE::"Sales Line":
                    begin

                        prfRecordRef.SetTable(lrecSalesLine);

                        lfrFieldRef := prfRecordRef.Field(lrecSalesLine.FieldNo("Qty. to Ship (Base)"));
                        ldecQty := lfrFieldRef.Value;
                        pdecToShipRecNet := lrecItem."Net Weight" * Abs(ldecQty);

                        lfrFieldRef := prfRecordRef.Field(lrecSalesLine.FieldNo("Qty. Shipped (Base)"));
                        ldecQty := lfrFieldRef.Value;
                        pdecShippedReceivedNet := lrecItem."Net Weight" * Abs(ldecQty);

                        lfrFieldRef := prfRecordRef.Field(lrecSalesLine.FieldNo("Quantity (Base)"));
                        ldecQty := lfrFieldRef.Value;
                        pdecTotalNet := lrecItem."Net Weight" * Abs(ldecQty);

                        lfrFieldRef := prfRecordRef.Field(lrecSalesLine.FieldNo("Qty. to Invoice (Base)"));
                        ldecQty := lfrFieldRef.Value;
                        pdecToInvoiceNet := lrecItem."Net Weight" * Abs(ldecQty);

                        lfrFieldRef := prfRecordRef.Field(lrecSalesLine.FieldNo("Qty. Invoiced (Base)"));
                        ldecQty := lfrFieldRef.Value;
                        pdecInvoicedNet := lrecItem."Net Weight" * Abs(ldecQty);

                    end;
                DATABASE::"Purchase Line":
                    begin
                        prfRecordRef.SetTable(lrecPurchaseLine);

                        lfrFieldRef := prfRecordRef.Field(Abs(lrecPurchaseLine.FieldNo("Qty. to Receive (Base)")));
                        ldecQty := lfrFieldRef.Value;
                        pdecToShipRecNet := lrecItem."Net Weight" * ldecQty;

                        lfrFieldRef := prfRecordRef.Field(Abs(lrecPurchaseLine.FieldNo("Qty. Received (Base)")));
                        ldecQty := lfrFieldRef.Value;
                        pdecShippedReceivedNet := lrecItem."Net Weight" * ldecQty;

                        lfrFieldRef := prfRecordRef.Field(Abs(lrecPurchaseLine.FieldNo("Quantity (Base)")));
                        ldecQty := lfrFieldRef.Value;
                        pdecTotalNet := lrecItem."Net Weight" * ldecQty;

                        lfrFieldRef := prfRecordRef.Field(Abs(lrecPurchaseLine.FieldNo("Qty. to Invoice (Base)")));
                        ldecQty := lfrFieldRef.Value;
                        pdecToInvoiceNet := lrecItem."Net Weight" * ldecQty;

                        lfrFieldRef := prfRecordRef.Field(Abs(lrecPurchaseLine.FieldNo("Qty. Invoiced (Base)")));
                        ldecQty := lfrFieldRef.Value;
                        pdecInvoicedNet := lrecItem."Net Weight" * ldecQty;
                    end;

                DATABASE::"Transfer Line":
                    begin
                        prfRecordRef.SetTable(lrecTransferLine);

                        case poptDirection of
                            poptDirection::Outbound:
                                begin

                                    lfrFieldRef := prfRecordRef.Field(Abs(lrecTransferLine.FieldNo("Qty. to Ship (Base)")));
                                    ldecQty := lfrFieldRef.Value;
                                    pdecToShipRecNet := lrecItem."Net Weight" * ldecQty;

                                    lfrFieldRef := prfRecordRef.Field(Abs(lrecTransferLine.FieldNo("Qty. Shipped (Base)")));
                                    ldecQty := lfrFieldRef.Value;
                                    pdecShippedReceivedNet := lrecItem."Net Weight" * ldecQty;

                                    lfrFieldRef := prfRecordRef.Field(Abs(lrecTransferLine.FieldNo("Quantity (Base)")));
                                    ldecQty := lfrFieldRef.Value;
                                    pdecTotalNet := lrecItem."Net Weight" * ldecQty;

                                    pdecToInvoiceNet := 0;
                                    pdecInvoicedNet := 0;
                                end;
                            poptDirection::Inbound:
                                begin
                                    lfrFieldRef := prfRecordRef.Field(Abs(lrecTransferLine.FieldNo("Qty. to Receive (Base)")));
                                    ldecQty := lfrFieldRef.Value;
                                    pdecToShipRecNet := lrecItem."Net Weight" * ldecQty;

                                    lfrFieldRef := prfRecordRef.Field(Abs(lrecTransferLine.FieldNo("Qty. Received (Base)")));
                                    ldecQty := lfrFieldRef.Value;
                                    pdecShippedReceivedNet := lrecItem."Net Weight" * ldecQty;

                                    lfrFieldRef := prfRecordRef.Field(Abs(lrecTransferLine.FieldNo("Quantity (Base)")));
                                    ldecQty := lfrFieldRef.Value;
                                    pdecTotalNet := lrecItem."Net Weight" * ldecQty;

                                    pdecToInvoiceNet := 0;
                                    pdecInvoicedNet := 0;

                                end;
                        end;
                    end;

                DATABASE::"Item Journal Line":
                    begin
                        prfRecordRef.SetTable(lrecItemJnlLine);
                        //Purchase,Sale,Positive Adjmt.,Negative Adjmt.,Transfer,Consumption,Output, ,Assembly Consumption,Assembly Output
                        case lrecItemJnlLine."Entry Type" of
                            lrecItemJnlLine."Entry Type"::Purchase, lrecItemJnlLine."Entry Type"::Sale,
                            lrecItemJnlLine."Entry Type"::"Positive Adjmt.", lrecItemJnlLine."Entry Type"::"Negative Adjmt.",
                            lrecItemJnlLine."Entry Type"::Transfer, lrecItemJnlLine."Entry Type"::Consumption, lrecItemJnlLine."Entry Type"::"Assembly Consumption":
                                begin
                                    lfrFieldRef := prfRecordRef.Field(Abs(lrecItemJnlLine.FieldNo("Quantity (Base)")));
                                end;

                            lrecItemJnlLine."Entry Type"::Output, lrecItemJnlLine."Entry Type"::"Assembly Output":
                                begin
                                    lfrFieldRef := prfRecordRef.Field(Abs(lrecItemJnlLine.FieldNo("Output Quantity (Base)")));
                                end;
                        end;

                        ldecQty := lfrFieldRef.Value;
                        pdecToShipRecNet := lrecItem."Net Weight" * ldecQty;
                        pdecShippedReceivedNet := lrecItem."Net Weight" * ldecQty;
                        pdecTotalNet := lrecItem."Net Weight" * ldecQty;
                        pdecToInvoiceNet := lrecItem."Net Weight" * ldecQty;
                        pdecInvoicedNet := lrecItem."Net Weight" * ldecQty;

                    end;

                DATABASE::"Warehouse Receipt Line":
                    begin
                        prfRecordRef.SetTable(lrecWRLine);

                        lfrFieldRef := prfRecordRef.Field(lrecWRLine.FieldNo("Qty. to Receive (Base)"));
                        ldecQty := lfrFieldRef.Value;
                        pdecToShipRecNet := lrecItem."Net Weight" * ldecQty;

                        lfrFieldRef := prfRecordRef.Field(lrecWRLine.FieldNo("Qty. Received (Base)"));
                        ldecQty := lfrFieldRef.Value;
                        pdecShippedReceivedNet := lrecItem."Net Weight" * ldecQty;

                        lfrFieldRef := prfRecordRef.Field(lrecWRLine.FieldNo("Qty. (Base)"));
                        ldecQty := lfrFieldRef.Value;
                        pdecTotalNet := lrecItem."Net Weight" * ldecQty;

                        pdecToInvoiceNet := 0;
                        pdecInvoicedNet := 0;

                    end;

                DATABASE::"Warehouse Shipment Line":
                    begin
                        prfRecordRef.SetTable(lrecWSLine);

                        lfrFieldRef := prfRecordRef.Field(lrecWSLine.FieldNo("Qty. to Ship (Base)"));
                        ldecQty := lfrFieldRef.Value;
                        pdecToShipRecNet := lrecItem."Net Weight" * ldecQty;

                        lfrFieldRef := prfRecordRef.Field(lrecWSLine.FieldNo("Qty. Shipped (Base)"));
                        ldecQty := lfrFieldRef.Value;
                        pdecShippedReceivedNet := lrecItem."Net Weight" * ldecQty;

                        lfrFieldRef := prfRecordRef.Field(lrecWSLine.FieldNo("Qty. (Base)"));
                        ldecQty := lfrFieldRef.Value;
                        pdecTotalNet := lrecItem."Net Weight" * ldecQty;

                        pdecToInvoiceNet := 0;
                        pdecInvoicedNet := 0;

                    end;

                //<ENRE1.00>
                DATABASE::"Prod. Order Line":
                    begin
                        prfRecordRef.SetTable(lProdOrderLine);

                        lfrFieldRef := prfRecordRef.Field(Abs(lProdOrderLine.FieldNo("Quantity (Base)")));
                        ldecQty := lfrFieldRef.Value;
                        pdecToShipRecNet := lrecItem."Net Weight" * ldecQty;

                        lfrFieldRef := prfRecordRef.Field(Abs(lProdOrderLine.FieldNo("Finished Qty. (Base)")));
                        ldecQty := lfrFieldRef.Value;
                        pdecShippedReceivedNet := lrecItem."Net Weight" * ldecQty;

                        lfrFieldRef := prfRecordRef.Field(Abs(lProdOrderLine.FieldNo("Quantity (Base)")));
                        ldecQty := lfrFieldRef.Value;
                        pdecTotalNet := lrecItem."Net Weight" * ldecQty;

                        lfrFieldRef := prfRecordRef.Field(Abs(lProdOrderLine.FieldNo("Quantity (Base)")));
                        ldecQty := lfrFieldRef.Value;
                        pdecToInvoiceNet := lrecItem."Net Weight" * ldecQty;

                        lfrFieldRef := prfRecordRef.Field(Abs(lProdOrderLine.FieldNo("Finished Qty. (Base)")));
                        ldecQty := lfrFieldRef.Value;
                        pdecInvoicedNet := lrecItem."Net Weight" * ldecQty;
                    end;

            //</ENRE1.00>


            end;
        end;
        //</ENRE1.00>
    end;

    local procedure CalcNetWeightTracked(pintTableID: Integer; var prfRecordRef: RecordRef; var pdecTotalNet: Decimal; var pdecToShipRecNet: Decimal; var pdecShippedReceivedNet: Decimal; var pdecToInvoiceNet: Decimal; var pdecInvoicedNet: Decimal; poptDirection: Option Outbound,Inbound)
    var
        lrecTrackingSpecification: Record "Tracking Specification";
        lrecTrackingSpecificationTMP: Record "Tracking Specification" temporary;
        lrecPurchaseLine: Record "Purchase Line";
        lrecSalesLine: Record "Sales Line";
        lrecTransferLine: Record "Transfer Line";
        lrecItemJnlLine: Record "Item Journal Line";
        lrecItem: Record Item;
        lrecItemTrackingCode: Record "Item Tracking Code";
        lcduPurchLineResv: Codeunit "Purch. Line-Reserve";
        lcduPurchLineResv2: Codeunit "Purch. Line-Reserve ELA";
        lcduSalesLineResv: Codeunit "Sales Line-Reserve";
        lcduSalesLineResv2: Codeunit "Sales Line-Reserve ELA";
        lcduTransLineReserve: Codeunit "Transfer Line-Reserve";
        lcduTransLineReserve2: Codeunit "Transfer Line-Reserve ELA";
        lcduItemJnlLineResv: Codeunit "Item Jnl. Line-Reserve";
        lcduItemJnlLineResv2: Codeunit "Item Jnl. Line-Reserve ELA";
        lProdOrderLineReserve: Codeunit "Prod. Order Line-Reserve";
        lProdOrderLineReserve2: Codeunit "Prod. Order Line-Reserve ELA";
        lpagItemTrackingLines: Page "Item Tracking Lines";
        ldecResult: Decimal;
        ldecQty: Decimal;
        lfrFieldRef: FieldRef;
        lProdOrderLine: Record "Prod. Order Line";
        ldecTotalTrackedQty: Decimal;
        ldecTotalQty: Decimal;
        lDummyQty: Decimal;
    begin
        //<ENRE1.00>
        lrecItem.Get(gcodItemNo);
        lrecItemTrackingCode.Get(lrecItem."Item Tracking Code");

        case pintTableID of
            DATABASE::"Sales Line":
                begin
                    prfRecordRef.SetTable(lrecSalesLine);
                    lcduSalesLineResv2.InitTrackingSpecification(lrecSalesLine, lrecTrackingSpecification);
                    lpagItemTrackingLines.SetSourceSpec(lrecTrackingSpecification, lrecSalesLine."Shipment Date");
                    //<ENRE1.00>
                    if gFromStatistics or gAddUntracked then begin
                        ldecTotalQty := lrecSalesLine.Quantity;
                    end;
                    //</ENRE1.00>
                end;
            DATABASE::"Purchase Line":
                begin
                    prfRecordRef.SetTable(lrecPurchaseLine);
                    lcduPurchLineResv2.InitTrackingSpecification(lrecPurchaseLine, lrecTrackingSpecification);
                    lpagItemTrackingLines.SetSourceSpec(lrecTrackingSpecification, lrecPurchaseLine."Expected Receipt Date");

                    //<ENRE1.00>
                    if gFromStatistics or gAddUntracked then begin
                        ldecTotalQty := lrecPurchaseLine.Quantity;
                    end;
                    //</ENRE1.00>
                end;
            DATABASE::"Transfer Line":
                begin
                    prfRecordRef.SetTable(lrecTransferLine);
                    case poptDirection of
                        poptDirection::Outbound:
                            begin
                                lcduTransLineReserve2.InitTrackingSpecification(lrecTransferLine, lrecTrackingSpecification, lrecTransferLine."Shipment Date", 0);
                                lpagItemTrackingLines.SetSourceSpec(lrecTrackingSpecification, lrecTransferLine."Shipment Date");
                            end;
                        poptDirection::Inbound:
                            begin
                                lcduTransLineReserve2.InitTrackingSpecification(lrecTransferLine, lrecTrackingSpecification, lrecTransferLine."Receipt Date", 1);
                                lpagItemTrackingLines.SetSourceSpec(lrecTrackingSpecification, lrecTransferLine."Receipt Date");
                            end;
                    end;
                end;

            DATABASE::"Item Journal Line":
                begin
                    prfRecordRef.SetTable(lrecItemJnlLine);
                    lcduItemJnlLineResv2.InitTrackingSpecification(lrecItemJnlLine, lrecTrackingSpecification);
                    lpagItemTrackingLines.SetSourceSpec(lrecTrackingSpecification, lrecItemJnlLine."Posting Date");

                end;

            //<ENRE1.00>
            DATABASE::"Prod. Order Line":
                begin
                    prfRecordRef.SetTable(lProdOrderLine);
                    lProdOrderLineReserve2.InitTrackingSpecification(lProdOrderLine, lrecTrackingSpecification);
                    lpagItemTrackingLines.SetSourceSpec(lrecTrackingSpecification, lProdOrderLine."Due Date");

                end;
        //</ENRE1.00>


        end;
        lpagItemTrackingLines.ReturnTrackingSpecifications(lrecTrackingSpecificationTMP);

        if not lrecTrackingSpecificationTMP.IsEmpty then begin

            lrecTrackingSpecificationTMP.FindSet;
            repeat
                //tracked catch weight
                //<ENRE1.00>
                if lrecItemTrackingCode.Code <> '' then begin
                    //</ENRE1.00>
                    pdecTotalNet := pdecTotalNet + lrecTrackingSpecificationTMP."Net Weight ELA";
                    pdecToShipRecNet := pdecToShipRecNet + lrecTrackingSpecificationTMP."Net Weight to Handle ELA";
                    pdecShippedReceivedNet := pdecShippedReceivedNet + lrecTrackingSpecificationTMP."Net Weight Handled ELA";
                    pdecToInvoiceNet := pdecToInvoiceNet + lrecTrackingSpecificationTMP."Net Weight to Invoice ELA";
                    pdecInvoicedNet := pdecInvoicedNet + lrecTrackingSpecificationTMP."Net Weight Invoiced ELA";

                    //<ENRE1.00>
                    if gFromStatistics or gAddUntracked then begin
                        ldecTotalTrackedQty += lrecTrackingSpecificationTMP."Quantity (Base)";
                    end;
                    //</ENRE1.00>
                end else begin
                    //tracked non-catch weight
                    if lrecItem.Get(gcodItemNo) then begin
                        case pintTableID of
                            DATABASE::"Sales Line":
                                begin
                                    prfRecordRef.SetTable(lrecSalesLine);
                                end;
                            DATABASE::"Purchase Line":
                                begin
                                    prfRecordRef.SetTable(lrecPurchaseLine);
                                end;
                            DATABASE::"Transfer Line":
                                begin
                                    prfRecordRef.SetTable(lrecTransferLine);
                                end;

                            DATABASE::"Item Journal Line":
                                begin
                                    prfRecordRef.SetTable(lrecItemJnlLine);
                                end;
                            //<ENRE1.00>
                            DATABASE::"Prod. Order Line":
                                begin
                                    prfRecordRef.SetTable(lProdOrderLine);
                                end;
                        //</ENRE1.00>

                        end;

                        pdecTotalNet := pdecTotalNet + (lrecItem."Net Weight" * lrecTrackingSpecificationTMP."Quantity (Base)");
                        pdecToShipRecNet := pdecToShipRecNet + (lrecItem."Net Weight" * lrecTrackingSpecificationTMP."Qty. to Handle (Base)");
                        pdecShippedReceivedNet := pdecShippedReceivedNet + (lrecItem."Net Weight" * lrecTrackingSpecificationTMP."Quantity Handled (Base)");
                        pdecToInvoiceNet := pdecToInvoiceNet + (lrecItem."Net Weight" * lrecTrackingSpecificationTMP."Qty. to Invoice (Base)");
                        pdecInvoicedNet := pdecInvoicedNet + (lrecItem."Net Weight" * lrecTrackingSpecificationTMP."Quantity Invoiced (Base)");

                    end;
                end;
            until lrecTrackingSpecificationTMP.Next = 0;
        end;

        //<ENRE1.00>
        if gFromStatistics or gAddUntracked then begin
            AddUntrackedWeights(ldecTotalQty, ldecTotalTrackedQty, lrecItem, pdecTotalNet, lDummyQty);
        end;
        //</ENRE1.00>

        //</ENRE1.00>
    end;


    procedure CalcLineWeight(var precrefLine: RecordRef; pdecPrecision: Decimal; poptWeightTypeToCalc: Option "Gross if Not Zero Else Net","Net Only","Gross Only"; poptUseQuantity: Option Full,Outstanding,ShipRec,Invoice; poptDirection: Option Outbound,Inbound) pdecWeight: Decimal
    var
        lrecLineWeightStats: Record "Line Weight Statistics ELA";
        ldecTotalWeight: Decimal;
        ldecWeightOutstanding: Decimal;
        lctxtTheCalcLineWeightDoesNot: Label 'The CalcLineWeight function does not support Table %1';
        ldecWeightToShipReceive: Decimal;
        ldecWeightToInvoice: Decimal;
    begin
        //<ENRE1.00>
        pdecWeight := 0;

        if (
          (not CheckValues(precrefLine.Number, precrefLine, poptDirection))
        ) then begin
            exit;
        end;

        if pdecPrecision = 0 then
            pdecPrecision := 0.00001;

        //<ENRE1.00>
        CalcLineWeightStats(precrefLine, lrecLineWeightStats, poptDirection);

        Clear(ldecTotalWeight);
        Clear(ldecWeightOutstanding);

        case poptWeightTypeToCalc of
            poptWeightTypeToCalc::"Gross if Not Zero Else Net":
                begin
                    if (
                      (lrecLineWeightStats."Total Gross Weight" <> 0)
                    ) then begin
                        ldecTotalWeight := lrecLineWeightStats."Total Gross Weight";
                        ldecWeightOutstanding := lrecLineWeightStats."Gross Weight Outstanding";
                        //<ENRE1.00>
                        ldecWeightToShipReceive := lrecLineWeightStats."Gross Weight to Ship/Receive";
                        ldecWeightToInvoice := lrecLineWeightStats."Gross Weight to Invoice";
                        //</ENRE1.00>
                    end else begin
                        ldecTotalWeight := lrecLineWeightStats."Total Net Weight";
                        ldecWeightOutstanding := lrecLineWeightStats."Net Weight Outstanding";
                        //<ENRE1.00>
                        ldecWeightToShipReceive := lrecLineWeightStats."Net Weight to Ship/Receive";
                        ldecWeightToInvoice := lrecLineWeightStats."Net Weight to Invoice";
                        //</ENRE1.00>
                    end;
                end;
            poptWeightTypeToCalc::"Net Only":
                begin
                    ldecTotalWeight := lrecLineWeightStats."Total Net Weight";
                    ldecWeightOutstanding := lrecLineWeightStats."Net Weight Outstanding";
                    //<ENRE1.00>
                    ldecWeightToShipReceive := lrecLineWeightStats."Net Weight to Ship/Receive";
                    ldecWeightToInvoice := lrecLineWeightStats."Net Weight to Invoice";
                    //</ENRE1.00>
                end;
            poptWeightTypeToCalc::"Gross Only":
                begin
                    ldecTotalWeight := lrecLineWeightStats."Total Gross Weight";
                    ldecWeightOutstanding := lrecLineWeightStats."Gross Weight Outstanding";
                    //<ENRE1.00>
                    ldecWeightToShipReceive := lrecLineWeightStats."Gross Weight to Ship/Receive";
                    ldecWeightToInvoice := lrecLineWeightStats."Gross Weight to Invoice";
                    //</ENRE1.00>
                end;
        end;

        //<ENRE1.00>
        case poptUseQuantity of
            poptUseQuantity::Full:
                begin
                    pdecWeight := ldecTotalWeight;
                end;
            poptUseQuantity::Outstanding:
                begin
                    pdecWeight := ldecWeightOutstanding;
                end;
            poptUseQuantity::ShipRec:
                begin
                    pdecWeight := ldecWeightToShipReceive
                end;
            poptUseQuantity::Invoice:
                begin
                    pdecWeight := ldecWeightToInvoice
                end;
        end;
        //</ENRE1.00>

        //</ENRE1.00>

        exit(Round(pdecWeight, pdecPrecision));
        //</ENRE1.00>
    end;


    procedure CalcLineWeightStats(var precrefLine: RecordRef; var precLineVariableWeightStats: Record "Line Weight Statistics ELA"; poptDirection: Option Outbound,Inbound)
    var
        lcodItem: Code[20];
        lrecItem: Record Item;
        lrecItemTrackingCode: Record "Item Tracking Code";
        ldecTotalQty: Decimal;
        ldecOutstandingQty: Decimal;
        ldecQtyToShipReceive: Decimal;
        ldecQtyToInvoice: Decimal;
        ldecTotalTrackedQty: Decimal;
        ldecTrackedQtyOutstanding: Decimal;
        ldecTrackedQtyToShip: Decimal;
        ldecTrackedQtyShipped: Decimal;
        ldecTrackedQtyToInvoice: Decimal;
        ldecTrackedQtyInvoiced: Decimal;
        lrecSalesLine: Record "Sales Line";
        lrecPurchaseLine: Record "Purchase Line";
        lrecTransferLine: Record "Transfer Line";
        ldecTotalWeight: Decimal;
        ldecWeightToShipReceive: Decimal;
        ldecWeightShippedReceived: Decimal;
        ldecWeightToInvoice: Decimal;
        ldecWeightInvoiced: Decimal;
        lctxtTheCalcLineWeightDoesNot: Label 'The CalcLineWeight function does not support Table %1';
        ldecGrossWeightDeltaPer: Decimal;
    begin
        //<ENRE1.00>
        Clear(precLineVariableWeightStats);

        if (
          (not CheckValues(precrefLine.Number, precrefLine, poptDirection))
        ) then begin
            exit;
        end;

        case precrefLine.Number of
            DATABASE::"Sales Line":
                begin

                    precrefLine.SetTable(lrecSalesLine);

                    ldecTotalQty := lrecSalesLine."Quantity (Base)";
                    ldecOutstandingQty := lrecSalesLine."Outstanding Qty. (Base)";
                    if (
                      (lrecSalesLine."Document Type" in [lrecSalesLine."Document Type"::"Credit Memo", lrecSalesLine."Document Type"::"Return Order"])
                    ) then begin
                        ldecQtyToShipReceive := lrecSalesLine."Return Qty. to Receive (Base)";
                    end else begin
                        ldecQtyToShipReceive := lrecSalesLine."Qty. to Ship (Base)";
                    end;
                    ldecQtyToInvoice := lrecSalesLine."Qty. to Invoice (Base)";

                    lcodItem := lrecSalesLine."No.";

                end;
            DATABASE::"Purchase Line":
                begin

                    precrefLine.SetTable(lrecPurchaseLine);

                    ldecTotalQty := lrecPurchaseLine."Quantity (Base)";
                    ldecOutstandingQty := lrecPurchaseLine."Outstanding Qty. (Base)";
                    if (
                      (lrecPurchaseLine."Document Type" in [lrecPurchaseLine."Document Type"::"Credit Memo", lrecPurchaseLine."Document Type"::"Return Order"])
                    ) then begin
                        ldecQtyToShipReceive := lrecPurchaseLine."Return Qty. to Ship (Base)";
                    end else begin
                        ldecQtyToShipReceive := lrecPurchaseLine."Qty. to Receive (Base)";
                    end;
                    ldecQtyToInvoice := lrecPurchaseLine."Qty. to Invoice (Base)";

                    lcodItem := lrecPurchaseLine."No.";

                end;
            DATABASE::"Transfer Line":
                begin

                    precrefLine.SetTable(lrecTransferLine);

                    ldecTotalQty := lrecTransferLine."Quantity (Base)";
                    if (
                      (poptDirection = poptDirection::Outbound)
                    ) then begin
                        ldecOutstandingQty := lrecTransferLine."Quantity (Base)" - lrecTransferLine."Qty. Shipped (Base)";
                        ldecQtyToShipReceive := lrecTransferLine."Qty. to Ship (Base)";
                    end else begin
                        ldecOutstandingQty := lrecTransferLine."Quantity (Base)" - lrecTransferLine."Qty. Received (Base)";
                        ldecQtyToShipReceive := lrecTransferLine."Qty. to Receive (Base)";
                    end;

                    lcodItem := lrecTransferLine."Item No.";

                end;
            else begin
                    // The CalcLineWeight function does not support Table %1
                    Error(lctxtTheCalcLineWeightDoesNot, precrefLine.Number);
                end;
        end;

        lrecItem.Get(lcodItem);

        ldecTotalTrackedQty := 0;
        ldecTrackedQtyOutstanding := 0;
        ldecTrackedQtyToShip := 0;
        ldecTrackedQtyShipped := 0;
        ldecTrackedQtyToInvoice := 0;
        ldecTrackedQtyInvoiced := 0;

        if (
          (lrecItem."Item Tracking Code" <> '')
        ) then begin
            CalcQuantityTracked(precrefLine, ldecTotalTrackedQty, ldecTrackedQtyToShip, ldecTrackedQtyShipped, ldecTrackedQtyToInvoice, ldecTrackedQtyInvoiced, poptDirection);
            //<ENRE1.00>
        end;
        //</ENRE1.00>

        CalcNetWeightTotals(precrefLine.Number,
                                precrefLine,
                                ldecTotalWeight,
                                ldecWeightToShipReceive,
                                ldecWeightShippedReceived,
                                ldecWeightToInvoice,
                                ldecWeightInvoiced,
                                poptDirection);

        precLineVariableWeightStats."Net Weight Outstanding" := ldecWeightToShipReceive;
        precLineVariableWeightStats."Net Weight to Ship/Receive" := ldecWeightToShipReceive;

        //<ENRE1.00>
        precLineVariableWeightStats."Total Net Weight" := ldecTotalWeight;
        //</ENRE1.00>

        precLineVariableWeightStats."Net Weight to Invoice" := ldecWeightToInvoice;

        //<ENRE1.00>
        ldecTotalTrackedQty := ldecTotalTrackedQty;
        //</ENRE1.00>
        ldecTrackedQtyOutstanding := ldecTrackedQtyToShip;

        //<ENRE1.00>
        if not gFromStatistics then begin
            //</ENRE1.00>
            if (
              (ldecTrackedQtyToShip > ldecQtyToShipReceive)
            ) then begin
                precLineVariableWeightStats."Net Weight to Ship/Receive" *= ldecQtyToShipReceive / ldecTrackedQtyToShip;
                ldecTrackedQtyToShip := ldecQtyToShipReceive;
            end;

            if (
              (ldecTrackedQtyToInvoice > ldecQtyToInvoice)
            ) then begin
                precLineVariableWeightStats."Net Weight to Invoice" *= ldecQtyToInvoice / ldecTrackedQtyToInvoice;
                ldecTrackedQtyToInvoice := ldecQtyToInvoice;
            end;
            //<ENRE1.00>
        end;
        //</ENRE1.00>

        /*
        ldecGrossWeightDeltaPer := 0;
        
        IF(
          ( lrecItem."Gross Weight" <> 0 )
        )THEN BEGIN
          ldecGrossWeightDeltaPer := lrecItem."Gross Weight" - lrecItem."Net Weight";
          //<ENRE1.00>
          precLineVariableWeightStats."Total Gross Weight" := lrecItem."Gross Weight" * ldecTotalQty;
          //</ENRE1.00>
          precLineVariableWeightStats."Gross Weight Outstanding" := precLineVariableWeightStats."Net Weight Outstanding";
          precLineVariableWeightStats."Gross Weight to Ship/Receive" := precLineVariableWeightStats."Net Weight to Ship/Receive";
          precLineVariableWeightStats."Gross Weight to Invoice" := precLineVariableWeightStats."Net Weight to Invoice";
        END;
        
        precLineVariableWeightStats."Total Gross Weight" += ldecTotalTrackedQty * ldecGrossWeightDeltaPer;
        precLineVariableWeightStats."Gross Weight Outstanding" += ldecTrackedQtyOutstanding * ldecGrossWeightDeltaPer;
        precLineVariableWeightStats."Gross Weight to Ship/Receive" += ldecTrackedQtyToShip * ldecGrossWeightDeltaPer;
        precLineVariableWeightStats."Gross Weight to Invoice" += ldecTrackedQtyToInvoice * ldecGrossWeightDeltaPer;
        */

        //<ENRE1.00>
        if (lrecItem."Item Tracking Code" <> '') then begin
            //tracked
            if IsCatchWeightItem(lrecItem."No.", false) then begin
                //variable
                ldecGrossWeightDeltaPer := 0;

                if (lrecItem."Gross Weight" <> 0) then begin
                    ldecGrossWeightDeltaPer := lrecItem."Gross Weight" - lrecItem."Net Weight";
                    //<ENRE1.00>
                    precLineVariableWeightStats."Total Gross Weight" := ldecTotalWeight;
                    //</ENRE1.00>
                    precLineVariableWeightStats."Gross Weight Outstanding" := precLineVariableWeightStats."Net Weight Outstanding";
                    precLineVariableWeightStats."Gross Weight to Ship/Receive" := precLineVariableWeightStats."Net Weight to Ship/Receive";
                    precLineVariableWeightStats."Gross Weight to Invoice" := precLineVariableWeightStats."Net Weight to Invoice";
                end;

                precLineVariableWeightStats."Total Gross Weight" += ldecTotalTrackedQty * ldecGrossWeightDeltaPer;
                precLineVariableWeightStats."Gross Weight Outstanding" += ldecTrackedQtyOutstanding * ldecGrossWeightDeltaPer;
                precLineVariableWeightStats."Gross Weight to Ship/Receive" += ldecTrackedQtyToShip * ldecGrossWeightDeltaPer;
                precLineVariableWeightStats."Gross Weight to Invoice" += ldecTrackedQtyToInvoice * ldecGrossWeightDeltaPer;
            end else begin
                //non variable
                precLineVariableWeightStats."Total Gross Weight" := lrecItem."Gross Weight" * ldecTotalQty;
                precLineVariableWeightStats."Gross Weight Outstanding" += ldecTrackedQtyOutstanding * lrecItem."Gross Weight";
                precLineVariableWeightStats."Gross Weight to Ship/Receive" += ldecTrackedQtyToShip * lrecItem."Gross Weight";
                precLineVariableWeightStats."Gross Weight to Invoice" += ldecTrackedQtyToInvoice * lrecItem."Gross Weight";
            end;
        end else begin
            //non tracked
            precLineVariableWeightStats."Total Gross Weight" += ldecTotalQty * lrecItem."Gross Weight";
            precLineVariableWeightStats."Gross Weight Outstanding" += ldecOutstandingQty * lrecItem."Gross Weight";
            precLineVariableWeightStats."Gross Weight to Ship/Receive" += ldecQtyToShipReceive * lrecItem."Gross Weight";
            precLineVariableWeightStats."Gross Weight to Invoice" += ldecQtyToInvoice * lrecItem."Gross Weight";
        end;
        //</ENRE1.00>

        //<ENRE1.00>
        if (
          (not gFromStatistics)
          //<ENRE1.00>
          and (lrecItem."Item Tracking Code" <> '')
        //</ENRE1.00>
        ) then begin
            //<ENRE1.00>
            AddUntrackedWeights(ldecTotalQty, ldecTotalTrackedQty, lrecItem,
              precLineVariableWeightStats."Total Net Weight", precLineVariableWeightStats."Total Gross Weight");

            AddUntrackedWeights(ldecOutstandingQty, ldecTrackedQtyOutstanding, lrecItem,
              precLineVariableWeightStats."Net Weight Outstanding", precLineVariableWeightStats."Gross Weight Outstanding");

            AddUntrackedWeights(ldecQtyToShipReceive, ldecTrackedQtyToShip, lrecItem,
              precLineVariableWeightStats."Net Weight to Ship/Receive", precLineVariableWeightStats."Gross Weight to Ship/Receive");

            AddUntrackedWeights(ldecQtyToInvoice, ldecTrackedQtyToInvoice, lrecItem,
              precLineVariableWeightStats."Net Weight to Invoice", precLineVariableWeightStats."Gross Weight to Invoice");
            //<ENRE1.00>
        end;
        //</ENRE1.00>

        //</ENRE1.00>

    end;


    procedure CalcSalesOrderWeightStats(precSalesHeader: Record "Sales Header"; var prgrecTotalSalesLine: array[3] of Record "Sales Line")
    var
        i: Integer;
        lrecSalesLine: Record "Sales Line";
        lrecref: RecordRef;
        lrecLineWeightStats: Record "Line Weight Statistics ELA";
        lcduWeightManagement: Codeunit "Rebate Sales Functions ELA";
    begin

        //<ENRE1.00>
        for i := 1 to 3 do begin
            Clear(prgrecTotalSalesLine[i]."Net Weight");
            Clear(prgrecTotalSalesLine[i]."Gross Weight");
        end;

        lrecSalesLine.SetRange("Document Type", precSalesHeader."Document Type");
        lrecSalesLine.SetRange("Document No.", precSalesHeader."No.");
        lrecSalesLine.SetRange(lrecSalesLine.Type, lrecSalesLine.Type::Item);
        if (
          (not lrecSalesLine.IsEmpty)
        ) then begin
            lrecSalesLine.Find('-');
            repeat
                Clear(lrecref);
                lrecref.GetTable(lrecSalesLine);
                Clear(lrecLineWeightStats);
                //<ENRE1.00>
                lcduWeightManagement.rdSetFromStatistics(true);
                //</ENRE1.00>
                lcduWeightManagement.CalcLineWeightStats(lrecref, lrecLineWeightStats, 0);

                prgrecTotalSalesLine[1]."Net Weight" += lrecLineWeightStats."Total Net Weight";
                prgrecTotalSalesLine[1]."Gross Weight" += lrecLineWeightStats."Total Gross Weight";
                prgrecTotalSalesLine[2]."Net Weight" += lrecLineWeightStats."Net Weight to Invoice";
                prgrecTotalSalesLine[2]."Gross Weight" += lrecLineWeightStats."Gross Weight to Invoice";
                prgrecTotalSalesLine[3]."Net Weight" += lrecLineWeightStats."Net Weight to Ship/Receive";
                prgrecTotalSalesLine[3]."Gross Weight" += lrecLineWeightStats."Gross Weight to Ship/Receive";

            until lrecSalesLine.Next = 0;
        end;

        for i := 1 to 3 do begin
            prgrecTotalSalesLine[i]."Net Weight" := Round(prgrecTotalSalesLine[i]."Net Weight", 0.00001);
            prgrecTotalSalesLine[i]."Gross Weight" := Round(prgrecTotalSalesLine[i]."Gross Weight", 0.00001);
        end;

        //</ENRE1.00>
    end;


    procedure CalcSalesDocWeightStats(precSalesHeader: Record "Sales Header"; var precTotalSalesLine: Record "Sales Line")
    var
        lrgrecTotalSalesLine: array[3] of Record "Sales Line";
    begin

        //<ENRE1.00>
        CalcSalesOrderWeightStats(precSalesHeader, lrgrecTotalSalesLine);

        precTotalSalesLine."Net Weight" := lrgrecTotalSalesLine[1]."Net Weight";
        precTotalSalesLine."Gross Weight" := lrgrecTotalSalesLine[1]."Gross Weight";
        //</ENRE1.00>
    end;


    procedure CalcPurchOrderWeightStats(precPurchHeader: Record "Purchase Header"; var prgrecTotalPurchLine: array[3] of Record "Purchase Line")
    var
        i: Integer;
        lrecPurchLine: Record "Purchase Line";
        lrecref: RecordRef;
        lrecLineWeightStats: Record "Line Weight Statistics ELA";
        lcduWeightManagement: Codeunit "Rebate Sales Functions ELA";
    begin

        //<ENRE1.00>
        for i := 1 to 3 do begin
            Clear(prgrecTotalPurchLine[i]."Net Weight");
            Clear(prgrecTotalPurchLine[i]."Gross Weight");
        end;

        lrecPurchLine.SetRange("Document Type", precPurchHeader."Document Type");
        lrecPurchLine.SetRange("Document No.", precPurchHeader."No.");
        lrecPurchLine.SetRange(lrecPurchLine.Type, lrecPurchLine.Type::Item);
        if (
          (not lrecPurchLine.IsEmpty)
        ) then begin
            lrecPurchLine.Find('-');
            repeat
                Clear(lrecref);
                lrecref.GetTable(lrecPurchLine);
                Clear(lrecLineWeightStats);
                //<ENRE1.00>
                lcduWeightManagement.rdSetFromStatistics(true);
                //</ENRE1.00>
                lcduWeightManagement.CalcLineWeightStats(lrecref, lrecLineWeightStats, 0);

                prgrecTotalPurchLine[1]."Net Weight" += lrecLineWeightStats."Total Net Weight";
                prgrecTotalPurchLine[1]."Gross Weight" += lrecLineWeightStats."Total Gross Weight";
                prgrecTotalPurchLine[2]."Net Weight" += lrecLineWeightStats."Net Weight to Invoice";
                prgrecTotalPurchLine[2]."Gross Weight" += lrecLineWeightStats."Gross Weight to Invoice";
                prgrecTotalPurchLine[3]."Net Weight" += lrecLineWeightStats."Net Weight to Ship/Receive";
                prgrecTotalPurchLine[3]."Gross Weight" += lrecLineWeightStats."Gross Weight to Ship/Receive";

            until lrecPurchLine.Next = 0;
        end;

        for i := 1 to 3 do begin
            prgrecTotalPurchLine[i]."Net Weight" := Round(prgrecTotalPurchLine[i]."Net Weight", 0.00001);
            prgrecTotalPurchLine[i]."Gross Weight" := Round(prgrecTotalPurchLine[i]."Gross Weight", 0.00001);
        end;

        //</ENRE1.00>
    end;


    procedure CalcPurchDocWeightStats(precPurchHeader: Record "Purchase Header"; var precTotalPurchLine: Record "Purchase Line")
    var
        lrgrecTotalPurchLine: array[3] of Record "Purchase Line";
    begin

        //<ENRE1.00>
        CalcPurchOrderWeightStats(precPurchHeader, lrgrecTotalPurchLine);

        precTotalPurchLine."Net Weight" := lrgrecTotalPurchLine[1]."Net Weight";
        precTotalPurchLine."Gross Weight" := lrgrecTotalPurchLine[1]."Gross Weight";
        //</ENRE1.00>
    end;


    procedure CalcPostedLineWeight(var precrefLine: RecordRef; pdecPrecision: Decimal; poptWeightTypeToCalc: Option "Gross if Not Zero Else Net","Net Only","Gross Only") pdecWeight: Decimal
    var
        lrecLineWeightStats: Record "Line Weight Statistics ELA";
        lctxtTheCalcPostedLineWeightDoesNot: Label 'The CalcPostedLineWeight function does not support Table %1';
    begin
        //<ENRE1.00>
        pdecWeight := 0;

        if pdecPrecision = 0 then
            pdecPrecision := 0.00001;

        //<ENRE1.00>
        CalcPostedLineWeightStats(precrefLine, lrecLineWeightStats);

        case poptWeightTypeToCalc of
            poptWeightTypeToCalc::"Gross if Not Zero Else Net":
                begin
                    pdecWeight := lrecLineWeightStats."Total Net Weight";
                    if (
                      (lrecLineWeightStats."Total Gross Weight" <> 0)
                    ) then begin
                        pdecWeight := lrecLineWeightStats."Total Gross Weight";
                    end;
                end;
            poptWeightTypeToCalc::"Gross Only":
                begin
                    pdecWeight := lrecLineWeightStats."Total Gross Weight";
                end;
            poptWeightTypeToCalc::"Net Only":
                begin
                    pdecWeight := lrecLineWeightStats."Total Net Weight";
                end;
        end;
        //</ENRE1.00>

        exit(Round(pdecWeight, pdecPrecision));
        //</ENRE1.00>
    end;


    procedure CalcPostedLineWeightStats(var precrefLine: RecordRef; var precLineVariableWeightStats: Record "Line Weight Statistics ELA")
    var
        lintType: Integer;
        lrecItem: Record Item;
        ldecQty: Decimal;
        ldecLineNetWeight: Decimal;
        lrecSalesShipmentLine: Record "Sales Shipment Line";
        lrecSalesInvoiceLine: Record "Sales Invoice Line";
        lrecSalesCreditMemoLine: Record "Sales Cr.Memo Line";
        lrecPurchaseReceiptLine: Record "Purch. Rcpt. Line";
        lrecPurchaseInvoiceLine: Record "Purch. Inv. Line";
        lrecPurchaseCreditMemoLine: Record "Purch. Cr. Memo Line";
        lrecTransferShipmentLine: Record "Transfer Shipment Line";
        lrecTransferReceiptLine: Record "Transfer Receipt Line";
        lrecReturnShipmentLine: Record "Return Shipment Line";
        lrecReturnReceiptLine: Record "Return Receipt Line";
        lcodItem: Code[20];
        ldecGrossWeightDeltaPer: Decimal;
        lctxtTheCalcPostedLineWeightDoesNot: Label 'The CalcPostedLineWeight function does not support Table %1';
    begin
        //<ENRE1.00>
        case precrefLine.Number of
            DATABASE::"Sales Shipment Line":
                begin

                    precrefLine.SetTable(lrecSalesShipmentLine);
                    lintType := lrecSalesShipmentLine.Type;
                    lcodItem := lrecSalesShipmentLine."No.";
                    ldecQty := lrecSalesShipmentLine."Quantity (Base)";
                    ldecLineNetWeight := lrecSalesShipmentLine."Line Net Weight ELA";

                end;
            DATABASE::"Sales Invoice Line":
                begin

                    precrefLine.SetTable(lrecSalesInvoiceLine);
                    lintType := lrecSalesInvoiceLine.Type;
                    lcodItem := lrecSalesInvoiceLine."No.";
                    ldecQty := lrecSalesInvoiceLine."Quantity (Base)";
                    ldecLineNetWeight := lrecSalesInvoiceLine."Line Net Weight ELA";

                end;
            DATABASE::"Sales Cr.Memo Line":
                begin

                    precrefLine.SetTable(lrecSalesCreditMemoLine);
                    lintType := lrecSalesCreditMemoLine.Type;
                    lcodItem := lrecSalesCreditMemoLine."No.";
                    ldecQty := lrecSalesCreditMemoLine."Quantity (Base)";
                    ldecLineNetWeight := lrecSalesCreditMemoLine."Line Net Weight ELA";

                end;
            DATABASE::"Purch. Rcpt. Line":
                begin

                    precrefLine.SetTable(lrecPurchaseReceiptLine);
                    lintType := lrecPurchaseReceiptLine.Type;
                    lcodItem := lrecPurchaseReceiptLine."No.";
                    ldecQty := lrecPurchaseReceiptLine."Quantity (Base)";
                    ldecLineNetWeight := lrecPurchaseReceiptLine."Line Net Weight ELA";

                end;
            DATABASE::"Purch. Inv. Line":
                begin

                    precrefLine.SetTable(lrecPurchaseInvoiceLine);
                    lintType := lrecPurchaseInvoiceLine.Type;
                    lcodItem := lrecPurchaseInvoiceLine."No.";
                    ldecQty := lrecPurchaseInvoiceLine."Quantity (Base)";
                    ldecLineNetWeight := lrecPurchaseInvoiceLine."Line Net Weight ELA";

                end;
            DATABASE::"Purch. Cr. Memo Line":
                begin

                    precrefLine.SetTable(lrecPurchaseCreditMemoLine);
                    lintType := lrecPurchaseCreditMemoLine.Type;
                    lcodItem := lrecPurchaseCreditMemoLine."No.";
                    ldecQty := lrecPurchaseCreditMemoLine."Quantity (Base)";
                    ldecLineNetWeight := lrecPurchaseCreditMemoLine."Line Net Weight ELA";

                end;
            DATABASE::"Transfer Shipment Line":
                begin

                    precrefLine.SetTable(lrecTransferShipmentLine);
                    lintType := lrecSalesShipmentLine.Type::Item;
                    lcodItem := lrecTransferShipmentLine."Item No.";
                    ldecQty := lrecTransferShipmentLine."Quantity (Base)";
                    ldecLineNetWeight := lrecTransferShipmentLine."Line Net Weight ELA";

                end;
            DATABASE::"Transfer Receipt Line":
                begin

                    precrefLine.SetTable(lrecTransferReceiptLine);
                    lintType := lrecPurchaseReceiptLine.Type::Item;
                    lcodItem := lrecTransferReceiptLine."Item No.";
                    ldecQty := lrecTransferReceiptLine."Quantity (Base)";
                    ldecLineNetWeight := lrecTransferReceiptLine."Line Net Weight ELA";

                end;
            DATABASE::"Return Shipment Line":
                begin

                    precrefLine.SetTable(lrecReturnShipmentLine);
                    lintType := lrecReturnShipmentLine.Type;
                    lcodItem := lrecReturnShipmentLine."No.";
                    ldecQty := lrecReturnShipmentLine."Quantity (Base)";
                    ldecLineNetWeight := lrecReturnShipmentLine."Line Net Weight ELA";

                end;
            DATABASE::"Return Receipt Line":
                begin

                    precrefLine.SetTable(lrecReturnReceiptLine);
                    lintType := lrecReturnReceiptLine.Type;
                    lcodItem := lrecReturnReceiptLine."No.";
                    ldecQty := lrecReturnReceiptLine."Quantity (Base)";
                    ldecLineNetWeight := lrecReturnReceiptLine."Line Net Weight ELA";

                end;
            //<ENRE1.00>
            /* DATABASE::"Direct Transfer Line": BEGIN

               precrefLine.SETTABLE( lrecDirectTransferLine );
               lintType := lrecSalesShipmentLine.Type::Item;
               lcodItem := lrecDirectTransferLine."Item No.";
               ldecQty := lrecDirectTransferLine."Quantity (Base)";
               ldecLineNetWeight := lrecDirectTransferLine."Line Net Weight";

             END;*/
            //</ENRE1.00>
            else begin
                    // The CalcPostedLineWeight function does not support Table %1
                    Error(lctxtTheCalcPostedLineWeightDoesNot, precrefLine.Number);
                end;
        end;

        if (
          (lintType <> lrecSalesShipmentLine.Type::Item)
          or (ldecQty = 0)
        ) then begin
            exit;
        end;

        lrecItem.Get(lcodItem);

        if (
          (not IsCatchWeightItem(lrecItem."No.", false))
        ) then begin
            precLineVariableWeightStats."Total Net Weight" := lrecItem."Net Weight" * ldecQty;
            precLineVariableWeightStats."Total Gross Weight" := lrecItem."Gross Weight" * ldecQty;
            exit;
        end;

        precLineVariableWeightStats."Total Net Weight" := ldecLineNetWeight;

        ldecGrossWeightDeltaPer := 0;

        if (
          (lrecItem."Gross Weight" <> 0)
        ) then begin
            ldecGrossWeightDeltaPer := lrecItem."Gross Weight" - lrecItem."Net Weight";
            precLineVariableWeightStats."Total Gross Weight" := precLineVariableWeightStats."Total Net Weight";
        end;

        precLineVariableWeightStats."Total Gross Weight" += ldecQty * ldecGrossWeightDeltaPer;
        //</ENRE1.00>

    end;

    local procedure CalcQuantityTracked(var prfRecordRef: RecordRef; var pdecTotalQuantity: Decimal; var pdecQuantityToShipReceive: Decimal; var pdecQuantityShippedReceived: Decimal; var pdecQuantityToInvoice: Decimal; var pdecQuantityInvoiced: Decimal; poptDirection: Option Outbound,Inbound)
    var
        lrecTrackingSpecification: Record "Tracking Specification";
        lrecTrackingSpecificationTMP: Record "Tracking Specification" temporary;
        lrecPurchaseLine: Record "Purchase Line";
        lrecSalesLine: Record "Sales Line";
        lrecTransferLine: Record "Transfer Line";
        lcduPurchLineResv: Codeunit "Purch. Line-Reserve";
        lcduPurchLineResv2: Codeunit "Purch. Line-Reserve ELA";
        lcduSalesLineResv: Codeunit "Sales Line-Reserve";
        lcduSalesLineResv2: Codeunit "Sales Line-Reserve ELA";
        lcduTransLineReserve: Codeunit "Transfer Line-Reserve";
        lcduItemJnlLineResv: Codeunit "Item Jnl. Line-Reserve";
        lcduTransLineReserve2: Codeunit "Transfer Line-Reserve ELA";
        lcduItemJnlLineResv2: Codeunit "Item Jnl. Line-Reserve ELA";
        lpagItemTrackingLines: Page "Item Tracking Lines";
        lrecItem: Record Item;
        lrecItemTrackingCode: Record "Item Tracking Code";
        lfrFieldRef: FieldRef;
        lctxtTheCalcQuantityTracked: Label 'The CalcQuantityTracking function does not support Table %1';
    begin
        //<ENRE1.00>
        case prfRecordRef.Number of
            DATABASE::"Sales Line":
                begin
                    prfRecordRef.SetTable(lrecSalesLine);
                    lcduSalesLineResv2.InitTrackingSpecification(lrecSalesLine, lrecTrackingSpecification);
                    lpagItemTrackingLines.SetSourceSpec(lrecTrackingSpecification, lrecSalesLine."Shipment Date");
                end;
            DATABASE::"Purchase Line":
                begin
                    prfRecordRef.SetTable(lrecPurchaseLine);
                    lcduPurchLineResv2.InitTrackingSpecification(lrecPurchaseLine, lrecTrackingSpecification);
                    lpagItemTrackingLines.SetSourceSpec(lrecTrackingSpecification, lrecPurchaseLine."Expected Receipt Date");
                end;
            DATABASE::"Transfer Line":
                begin
                    prfRecordRef.SetTable(lrecTransferLine);
                    case poptDirection of
                        poptDirection::Outbound:
                            begin
                                lcduTransLineReserve2.InitTrackingSpecification(lrecTransferLine, lrecTrackingSpecification, lrecTransferLine."Shipment Date", 0);
                                lpagItemTrackingLines.SetSourceSpec(lrecTrackingSpecification, lrecTransferLine."Shipment Date");
                            end;
                        poptDirection::Inbound:
                            begin
                                lcduTransLineReserve2.InitTrackingSpecification(lrecTransferLine, lrecTrackingSpecification, lrecTransferLine."Receipt Date", 1);
                                lpagItemTrackingLines.SetSourceSpec(lrecTrackingSpecification, lrecTransferLine."Receipt Date");
                            end;
                    end;
                end;
            else begin
                    // The CalcQuantityTracking function does not support Table %1
                    Error(lctxtTheCalcQuantityTracked, prfRecordRef.Number);
                end;
        end;
        lpagItemTrackingLines.ReturnTrackingSpecifications(lrecTrackingSpecificationTMP);

        lrecItem.Get(lrecTrackingSpecification."Item No.");
        lrecItemTrackingCode.Get(lrecItem."Item Tracking Code");

        if not lrecTrackingSpecificationTMP.IsEmpty then begin
            lrecTrackingSpecificationTMP.FindSet;
            repeat
                if (
                  (lrecTrackingSpecificationTMP."Net Weight to Handle ELA" <> 0)
                  or (not lrecItemTrackingCode."Variable Weight Tracking ELA")
                ) then begin
                    pdecQuantityToShipReceive += lrecTrackingSpecificationTMP."Qty. to Handle (Base)";
                end;
                pdecQuantityShippedReceived += lrecTrackingSpecificationTMP."Quantity Handled (Base)";
                //<ENRE1.00>
                if (
                  (lrecTrackingSpecificationTMP."Net Weight to Invoice ELA" <> 0)
                  or (not lrecItemTrackingCode."Variable Weight Tracking ELA")
                ) then begin
                    pdecQuantityToInvoice += lrecTrackingSpecificationTMP."Qty. to Invoice (Base)";
                end;
                pdecQuantityInvoiced += lrecTrackingSpecificationTMP."Quantity Invoiced (Base)";
                //</ENRE1.00>

                //<ENRE1.00>
                pdecTotalQuantity += lrecTrackingSpecificationTMP."Quantity (Base)";
            //</ENRE1.00>
            until lrecTrackingSpecificationTMP.Next = 0;
        end;
        //<ENRE1.00>
    end;


    procedure CheckTolerances(pcodItemNo: Code[20]; pdecQty: Decimal; pdecNW: Decimal; pblnAdjCorrect: Boolean; pblnHideError: Boolean): Boolean
    var
        lrecItem: Record Item;
        lrecItemTrackingCode: Record "Item Tracking Code";
        ldecTolerance: Decimal;
        ldecMin: Decimal;
        ldecMax: Decimal;
        lText000: Label 'The weight entered for Item No. %1 doesn''t fall within the variable weight tolerance.';
        ldecUnitWeight: Decimal;
    begin
        //<ENRE1.00>
        if not pblnAdjCorrect then begin
            if IsCatchWeightItem(pcodItemNo, false) then begin
                lrecItem.Get(pcodItemNo);
                lrecItemTrackingCode.Get(lrecItem."Item Tracking Code");
                if lrecItemTrackingCode."Variable Weight Tol Pct. ELA" <> 0 then begin
                    ldecTolerance := lrecItemTrackingCode."Variable Weight Tol Pct. ELA" * lrecItem."Net Weight" / 100;
                    ldecMin := lrecItem."Net Weight" - ldecTolerance;
                    ldecMax := lrecItem."Net Weight" + ldecTolerance;
                    if pdecQty <> 0 then begin
                        ldecUnitWeight := pdecNW / pdecQty;
                        if (ldecUnitWeight < ldecMin) or
                           (ldecUnitWeight > ldecMax) then begin
                            if pblnHideError then begin
                                exit(false);
                            end else begin
                                Error(lText000, pcodItemNo);
                            end;
                        end;
                    end;
                end;
            end;
        end;
        exit(true);
        //</ENRE1.00>
    end;

    local procedure AddUntrackedWeights(pdecTotalQuantity: Decimal; pdecTrackedQuantity: Decimal; precItem: Record Item; var pdecNetWeight: Decimal; var pdecGrossWeight: Decimal)
    var
        ldecUntrackedQty: Decimal;
    begin
        //<ENRE1.00>
        if (
          (pdecTrackedQuantity < pdecTotalQuantity)
        ) then begin
            ldecUntrackedQty := pdecTotalQuantity - pdecTrackedQuantity;

            pdecNetWeight += precItem."Net Weight" * ldecUntrackedQty;
            pdecGrossWeight += precItem."Gross Weight" * ldecUntrackedQty;
        end;
        //</ENRE1.00>
    end;


    procedure rdAddUntracked(pAddUntracked: Boolean)
    begin
        //<ENRE1.00>
        gAddUntracked := pAddUntracked;
        //</RD64371SHR>
    end;


    procedure rdSetFromStatistics(pFromStatistics: Boolean)
    begin
        //<ENRE1.00>
        gFromStatistics := pFromStatistics;
        //</ENRE1.00>
    end;


    procedure CalcUnroundedNetWeight(var precItem: Record Item): Decimal
    var
        lrecInventorySetup: Record "Inventory Setup";
        lrecUOM: Record "Unit of Measure";
        lJMText001: Label 'There are no %1 Units of Measure found in the %2 table for Item %3.';
        lrecItemUOM: Record "Item Unit of Measure";
        lblnWeightFound: Boolean;
        lJMText002: Label 'There are no Weight Unit of Measure Contstants setup.';
        lrecUOM2: Record "Unit of Measure";
        ldecWeight: Decimal;
    begin
        lrecInventorySetup.Get;

        //Find any Units of Measure in the constants table
        lrecUOM.SetRange("UOM Group Code ELA", lrecInventorySetup."Weight UOM Group ELA");

        if lrecUOM.FindSet then begin
            while not lblnWeightFound do begin
                lblnWeightFound := lrecItemUOM.Get(precItem."No.", lrecUOM.Code);

                if not lblnWeightFound then
                    if lrecUOM.Next = 0 then begin
                        if gblnSuppressErrors then
                            exit
                        else
                            Error(lJMText001, lrecInventorySetup."Weight UOM Group ELA", lrecItemUOM.TableName, precItem."No.");
                    end;
            end;

            if lblnWeightFound then begin
                lrecUOM2.Get(lrecInventorySetup."Standard Weight UOM ELA");

                if lrecUOM.Code = lrecUOM2.Code then begin
                    ldecWeight := 1 / lrecItemUOM."Qty. per Unit of Measure";
                end else begin
                    ldecWeight := lrecUOM."Std. Qty. Per UOM ELA" /
                                  lrecUOM2."Std. Qty. Per UOM ELA" /
                                  lrecItemUOM."Qty. per Unit of Measure";
                end;
            end;
        end else begin
            if gblnSuppressErrors then
                exit
            else
                Error(lJMText002);
        end;

        exit(ldecWeight);
    end;


    procedure CalcDeliveredPrice(pintSourceType: Integer; pintSourceSubType: Integer; pintSourceNo: Code[20]; pintSourceRefNo: Integer; pdecBasePrice: Decimal): Decimal
    var
        lrecSalesLine: Record "Sales Line";
        lrecSalesInvLine: Record "Sales Invoice Line";
        lrecSalesCrMemoLine: Record "Sales Cr.Memo Line";
        ldecResult: Decimal;
    begin
        //<ENRE1.00>

        //<ENRE1.00>
        // return Base Price instead of ZERO if no Delivery Charges or Allowances apply
        ldecResult := pdecBasePrice;
        //</ENRE1.00>

        case pintSourceType of
            DATABASE::"Sales Line":
                begin
                    if lrecSalesLine.Get(pintSourceSubType, pintSourceNo, pintSourceRefNo) then begin
                        if lrecSalesLine.Type <> lrecSalesLine.Type::Item then
                            exit(ldecResult);
                    end;

                    ldecResult := pdecBasePrice;

                    lrecSalesLine.SetRange("Document Type", pintSourceSubType);
                    lrecSalesLine.SetRange("Document No.", pintSourceNo);
                    lrecSalesLine.SetRange("Line No.");
                    lrecSalesLine.SetRange("Attached to Line No.", pintSourceRefNo);
                    lrecSalesLine.SetFilter("Item Charge Type ELA", '%1|%2',
                                            lrecSalesLine."Item Charge Type ELA"::"Delivery Charge",
                                            lrecSalesLine."Item Charge Type ELA"::"Delivery Allowance");

                    //-- Don't want to create a key just for this. Just loop through and add up amounts since there will only be few records
                    if lrecSalesLine.FindSet then begin
                        repeat
                            ldecResult += lrecSalesLine."Unit Price";
                        until lrecSalesLine.Next = 0;
                    end;
                end;
            DATABASE::"Sales Invoice Line":
                begin
                    if lrecSalesInvLine.Get(pintSourceNo, pintSourceRefNo) then begin
                        if lrecSalesInvLine.Type <> lrecSalesInvLine.Type::Item then
                            exit(ldecResult);
                    end;

                    ldecResult := pdecBasePrice;

                    lrecSalesInvLine.SetRange("Document No.", pintSourceNo);
                    lrecSalesInvLine.SetRange("Line No.");
                    lrecSalesInvLine.SetRange("Attached to Line No.", pintSourceRefNo);
                    lrecSalesInvLine.SetFilter("Item Charge Type ELA", '%1|%2',
                                               lrecSalesInvLine."Item Charge Type ELA"::"Delivery Charge",
                                               lrecSalesInvLine."Item Charge Type ELA"::"Delivery Allowance");

                    //-- Don't want to create a key just for this. Just loop through and add up amounts since there will only be few records
                    if lrecSalesInvLine.FindSet then begin
                        repeat
                            ldecResult += lrecSalesInvLine."Unit Price";
                        until lrecSalesInvLine.Next = 0;
                    end;
                end;
            DATABASE::"Sales Cr.Memo Line":
                begin
                    if lrecSalesCrMemoLine.Get(pintSourceNo, pintSourceRefNo) then begin
                        if lrecSalesCrMemoLine.Type <> lrecSalesCrMemoLine.Type::Item then
                            exit(ldecResult);
                    end;

                    ldecResult := pdecBasePrice;

                    lrecSalesCrMemoLine.SetRange("Document No.", pintSourceNo);
                    lrecSalesCrMemoLine.SetRange("Line No.");
                    lrecSalesCrMemoLine.SetRange("Attached to Line No.", pintSourceRefNo);
                    lrecSalesCrMemoLine.SetFilter("Item Charge Type ELA", '%1|%2',
                                                  lrecSalesCrMemoLine."Item Charge Type ELA"::"Delivery Charge",
                                                  lrecSalesCrMemoLine."Item Charge Type ELA"::"Delivery Allowance");

                    //-- Don't want to create a key just for this. Just loop through and add up amounts since there will only be few records
                    if lrecSalesCrMemoLine.FindSet then begin
                        repeat
                            ldecResult += lrecSalesCrMemoLine."Unit Price";
                        until lrecSalesCrMemoLine.Next = 0;
                    end;
                end;
        end;

        exit(ldecResult);
        //</ENRE1.00>
    end;


    procedure UpdtePromCostOnPlanningLines(lrecJobTask: Record "Job Task")
    var
        lrecJobPlanningLine: Record "Job Planning Line";
        ldecQtyPerPlanLine: Decimal;
        ldecQtyRem: Decimal;
        lrecJob: Record Job;
        lrecGLSetup: Record "General Ledger Setup";
        ldecRoundingLimit: Decimal;
        lrecCurrency: Record Currency;
        ldecLastTotalQty: Decimal;
        ldecTotalPromoCost: Decimal;
        ldecRemTotalCost: Decimal;
        ldecLastLineTotalCost: Decimal;
        lintInsertedLineCount: Integer;
    begin
        //<ENRE1.00>

        if (
          (lrecJobTask."Job No." = '')
          and (lrecJobTask."Job Task No." = '')
        ) then begin
            exit;
        end;

        lrecJobPlanningLine.SetRange("Job No.", lrecJobTask."Job No.");
        lrecJobPlanningLine.SetRange("Job Task No.", lrecJobTask."Job Task No.");

        if (
          (lrecJobPlanningLine.IsEmpty)
        ) then begin
            exit;
        end;

        lintInsertedLineCount := lrecJobPlanningLine.Count;

        ldecQtyPerPlanLine := lrecJobTask."Quantity ELA" / lintInsertedLineCount;
        ldecTotalPromoCost := lrecJobTask."Quantity ELA" * lrecJobTask."Unit Cost ELA";

        lrecJob.Get(lrecJobTask."Job No.");
        ldecRoundingLimit := SetRoundingPrecision(lrecJob);

        ldecRemTotalCost := ldecTotalPromoCost;
        ldecLastLineTotalCost := Round(ldecQtyPerPlanLine * lrecJobTask."Unit Cost ELA", ldecRoundingLimit);
        ldecQtyRem := lrecJobTask."Quantity ELA";
        lrecJobPlanningLine.FindSet;
        repeat
            lrecJobPlanningLine.SetUpdateFromParent(lrecJobTask);
            lrecJobPlanningLine.Validate(lrecJobPlanningLine.Quantity, ldecQtyPerPlanLine);
            lrecJobPlanningLine.ClearUpdateFromParent;
            lrecJobPlanningLine.Validate(lrecJobPlanningLine."Total Promotion Cost ELA",
              Round(ldecQtyPerPlanLine * lrecJobPlanningLine."Promotion Unit Cost ELA", ldecRoundingLimit));
            ldecRemTotalCost := Round((ldecRemTotalCost - lrecJobPlanningLine."Total Promotion Cost ELA"), ldecRoundingLimit);
            lrecJobPlanningLine.Modify;
        until lrecJobPlanningLine.Next = 0;

        //Add remainder cost to last planning line
        if ldecRemTotalCost <> 0 then begin
            ldecLastLineTotalCost := ldecLastLineTotalCost + ldecRemTotalCost;
            lrecJobPlanningLine.SetUpdateFromParent(lrecJobTask);
            lrecJobPlanningLine.Validate(lrecJobPlanningLine.Quantity, (ldecLastLineTotalCost / lrecJobTask."Unit Cost ELA"));
            lrecJobPlanningLine.ClearUpdateFromParent;
            lrecJobPlanningLine.Validate(lrecJobPlanningLine."Total Promotion Cost ELA", Round(ldecLastLineTotalCost, ldecRoundingLimit));
            lrecJobPlanningLine.Modify;
        end;

        //</ENRE1.00>
    end;


    procedure SetRoundingPrecision(lrecJob: Record Job): Decimal
    var
        lrecGLSetup: Record "General Ledger Setup";
        lrecCurrency: Record Currency;
        ldecRoundingLimit: Decimal;
    begin
        //<ENRE1.00>

        Clear(lrecGLSetup);
        Clear(lrecCurrency);
        Clear(ldecRoundingLimit);

        //Set Default Rounding Limit
        ldecRoundingLimit := 0.01;

        // Set rounding precision based on currency of Job
        if lrecJob."No." <> '' then begin
            if lrecGLSetup.Get then begin
                if lrecJob."Currency Code" = '' then begin
                    if lrecGLSetup."Amount Rounding Precision" <> 0 then
                        ldecRoundingLimit := lrecGLSetup."Amount Rounding Precision"
                    else
                        ldecRoundingLimit := 0.01;
                end;
                if lrecJob."Currency Code" <> '' then begin
                    if lrecCurrency.Get(lrecJob."Currency Code") then begin
                        if lrecCurrency."Amount Rounding Precision" <> 0 then
                            ldecRoundingLimit := lrecCurrency."Amount Rounding Precision"
                        else
                            ldecRoundingLimit := 0.01;
                    end else begin
                        ldecRoundingLimit := 0.01;
                    end;
                end;
            end;
        end;

        exit(ldecRoundingLimit);
        //</ENRE1.00>
    end;


    procedure rdCalculateRebates(var SalesHeader: Record "Sales Header")
    var
        lSalesReceivablesSetup: Record "Sales & Receivables Setup";
        lRecordRef: RecordRef;
        lRebateManagement: Codeunit "Rebate Management ELA";
        lPurchasesPayablesSetup: Record "Purchases & Payables Setup";
        lPurchaseRebateManagement: Codeunit "Purchase Rebate Management ELA";
    begin
        //<ENRE1.00>

        lSalesReceivablesSetup.Get;
        if lSalesReceivablesSetup."Calculate Rbt on Release ELA" then begin
            lRecordRef.GetTable(SalesHeader);
            lRecordRef.SetView(SalesHeader.GetView);

            //<ENRE1.00>
            lRebateManagement.BypassPurchRebates(true);
            //</ENRE1.00>

            lRebateManagement.CalcSalesDocRebate(lRecordRef, false, true);
        end;
        //</ENRE1.00>

        //<ENRE1.00>
        lPurchasesPayablesSetup.Get;
        if lPurchasesPayablesSetup."Calc SB Rbt on Release ELA" then begin
            lRecordRef.GetTable(SalesHeader);
            lRecordRef.SetView(SalesHeader.GetView);
            lPurchaseRebateManagement.CalcSalesBasedPurchRebate(lRecordRef, false, true);
        end;
        //</ENRE1.00>
    end;
}

