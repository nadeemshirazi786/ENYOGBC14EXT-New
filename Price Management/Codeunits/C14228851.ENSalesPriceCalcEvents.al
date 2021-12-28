/// <summary>
/// Codeunit EN Sales Price Calc Events (ID 14228851).
/// </summary>
codeunit 14228851 "EN Sales Price Calc Events"
{


    /// <summary>
    /// OnBeforeUpdateUnitPrice.
    /// </summary>
    /// <param name="Var SalesLine">Record "Sales Line".</param>
    /// <param name="xSalesLine">Record "Sales Line".</param>
    /// <param name="CalledByFieldNo">Integer.</param>
    /// <param name="CurrFieldNo">Integer.</param>
    /// <param name="Handled">VAR Boolean.</param>
    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeUpdateUnitPrice', '', true, true)]
    procedure OnBeforeUpdateUnitPrice(Var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CurrFieldNo: Integer; var Handled: Boolean)
    var
        lblnUpdateUnitPrice: Boolean;
        SalesHeader: Record "Sales Header";
        Currency: Record Currency;
        PriceCalcMgt: Codeunit "EN Sales Price Calc. Mgt.";
    begin
        Handled := true;
        IF SalesLine."Lock Pricing ELA" then begin
            Handled := true;
            SalesLine.UpdateAmounts;
            Exit;
        end;

        //lblnUpdateUnitPrice := CurrFieldNo IN [FIELDNO("Green Quantity"), FIELDNO("Breaking Quantity"),FIELDNO("Color Quantity"), FIELDNO("No Gas Quantity")];
        //IF (CalledByFieldNo <> CurrFieldNo) AND (CurrFieldNo <> FIELDNO("Requested Order Qty.")) AND (NOT lblnUpdateUnitPrice) THEN BEGIN
        //    IF (CalledByFieldNo <> CurrFieldNo) AND (CurrFieldNo <> 0) THEN BEGIN
        //        EXIT;
        //    END;
        //END;

        IF SalesLine."Sell Item at Cost ELA" then begin
            SalesLine.VALIDATE("Unit Price", SalesLine."Unit Cost");
            Handled := true;
            Exit;
        end;

        SalesLine.TESTFIELD(SalesLine."Document No.");
        IF (SalesLine."Document Type" <> SalesHeader."Document Type") OR (SalesLine."Document No." <> SalesHeader."No.") THEN BEGIN
            SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
            IF SalesHeader."Currency Code" = '' THEN
                Currency.InitRoundingPrecision
            ELSE BEGIN
                SalesHeader.TESTFIELD("Currency Factor");
                Currency.GET(SalesHeader."Currency Code");
                Currency.TESTFIELD("Amount Rounding Precision");
            END;
        END;

        SalesLine.TESTFIELD(SalesLine."Qty. per Unit of Measure");


        CASE SalesLine.Type OF
            SalesLine.Type::Item, SalesLine.Type::Resource:
                BEGIN
                    //IF NOT gblnSuspendPriceCalc THEN BEGIN
                    PriceCalcMgt.FindSalesLinePrice(SalesHeader, SalesLine, CalledByFieldNo);
                    PriceCalcMgt.FindSalesLineLineDisc(SalesHeader, SalesLine);
                    PriceCalcMgt.FindSalesLineLineDiscAmt(SalesHeader, SalesLine);
                    SalesLine.CalcBestDiscPct(SalesLine);

                    //END;
                END;
            SalesLine.Type::"G/L Account":
                BEGIN
                    IF (SalesLine."Ref. Item No. ELA" <> '') THEN BEGIN
                        //AND (NOT gblnSuspendPriceCalc) THEN BEGIN
                        PriceCalcMgt.FindSalesLinePrice(SalesHeader, SalesLine, CalledByFieldNo);
                        PriceCalcMgt.FindSalesLineLineDisc(SalesHeader, SalesLine);
                        PriceCalcMgt.FindSalesLineLineDiscAmt(SalesHeader, SalesLine);
                        SalesLine.CalcBestDiscPct(SalesLine);
                    END;
                END;
        END;

        //IF NOT gblnSuspendPriceCalc THEN
        //    SalesLine."Unit Price Approved By" := '';

        SalesLine.VALIDATE(SalesLine."Unit Price");
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnValidateNoOnCopyFromTempSalesLine', '', true, true)]
    procedure OnValidateNoOnCopyFromTempSalesLine(VAR SalesLine: Record "Sales Line"; VAR TempSalesLine: Record "Sales Line" TEMPORARY)
    begin

        IF SalesLine.Type <> SalesLine.Type::" " THEN BEGIN
            SalesLine."Requested Order Qty. ELA" := TempSalesLine."Requested Order Qty. ELA";
        END;

        IF SalesLine."Document Type" = SalesLine."Document Type"::Quote THEN BEGIN
            SalesLine.CheckItemAlreadyonLine(SalesLine."Document No.");
        END;
        SalesLine."EDI Line No. ELA" := TempSalesLine."EDI Line No. ELA";




    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterAssignHeaderValues', '', true, true)]
    procedure OnAfterAssignHeaderValues(VAR SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
        SalesLine."Sales Price UOM ELA" := SalesLine.GetSalesPriceUOM;
        SalesLine."Pallet Code ELA" := SalesHeader."Pallet Code ELA";
        SalesLine."Backorder Tolerance % ELA" := SalesHeader."Backorder Tolerance % ELA";
    end;
    /// <summary>
    /// OnAfterAssignItemValues.
    /// </summary>
    /// <param name="VAR SalesLine">Record "Sales Line".</param>
    /// <param name="Item">Record Item.</param>
    [EventSubscriber(ObjectType::Table, 37, 'OnAfterAssignItemValues', '', true, true)]
    procedure OnAfterAssignItemValues(VAR SalesLine: Record "Sales Line"; Item: Record Item)
    var
        lCustomer: Record Customer;
    begin
        SalesLine.TestItemDocumentBlock;


        IF lCustomer.GET(SalesLine."Sell-to Customer No.") THEN BEGIN
            SalesLine."Sell Item at Cost ELA" := lCustomer."Sell Items at Cost ELA";
        END;
        SalesLine."Shelf No. ELA" := Item."Shelf No.";

        IF SalesLine."Sell Item at Cost ELA" THEN BEGIN
            SalesLine."Allow Invoice Disc." := FALSE;
            SalesLine."Allow Line Disc." := FALSE;
        END;
        SalesLine."Size Code ELA" := Item."Size Code ELA";
        SalesLine."Unit of Measure Code" := SalesLine.GetSalesUOM();
        SalesLine.GetUnitCost;
        SalesLine."Ref. Item No. ELA" := SalesLine."No.";

        IF SalesLine."Document Type" = SalesLine."Document Type"::Quote THEN
            SalesLine.VALIDATE(Quantity, 1);
    end;
    /// <summary>
    /// OnAfterCheckSellToCust.
    /// </summary>
    /// <param name="VAR SalesHeader">Record "Sales Header".</param>
    /// <param name="xSalesHeader">Record "Sales Header".</param>
    /// <param name="Customer">Record Customer.</param>
    [EventSubscriber(ObjectType::Table, 36, 'OnAfterCheckSellToCust', '', true, true)]
    procedure OnAfterCheckSellToCust(VAR SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        SalesHeader.SetPriceDiscGroups(SalesHeader.FIELDNO(SalesHeader."Sell-to Customer No."));
    end;
    /// <summary>
    /// OnAfterCheckBillToCust.
    /// </summary>
    /// <param name="VAR SalesHeader">Record "Sales Header".</param>
    /// <param name="xSalesHeader">Record "Sales Header".</param>
    /// <param name="Customer">Record Customer.</param>
    [EventSubscriber(ObjectType::Table, 36, 'OnAfterCheckBillToCust', '', true, true)]
    procedure OnAfterCheckBillToCust(VAR SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        SalesHeader.SetPriceDiscGroups(SalesHeader.FIELDNO(SalesHeader."Bill-to Customer No."));
    end;
    /// <summary>
    /// OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr.
    /// </summary>
    /// <param name="VAR SalesHeader">Record "Sales Header".</param>
    /// <param name="ShipToAddress">Record "Ship-to Address".</param>
    [EventSubscriber(ObjectType::Table, 36, 'OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr', '', true, true)]
    procedure OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr(VAR SalesHeader: Record "Sales Header"; ShipToAddress: Record "Ship-to Address")
    begin
        SalesHeader.SetPriceDiscGroups(SalesHeader.FIELDNO(SalesHeader."Ship-to Code"));
    end;
    /// <summary>
    /// OnAfterCopyShipToCustomerAddressFieldsFromCustomer.
    /// </summary>
    /// <param name="VAR SalesHeader">Record "Sales Header".</param>
    /// <param name="SellToCustomer">Record Customer.</param>
    [EventSubscriber(ObjectType::Table, 36, 'OnAfterCopyShipToCustomerAddressFieldsFromCustomer', '', true, true)]
    procedure OnAfterCopyShipToCustomerAddressFieldsFromCustomer(VAR SalesHeader: Record "Sales Header"; SellToCustomer: Record Customer)
    begin
        SalesHeader.SetPriceDiscGroups(SalesHeader.FIELDNO(SalesHeader."Ship-to Code"));
    end;
    /// <summary>
    /// OnValidateBilltoCustomerTemplateCodeBeforeRecreateSalesLines.
    /// </summary>
    /// <param name="VAR SalesHeader">Record "Sales Header".</param>
    /// <param name="CallingFieldNo">Integer.</param>
    [EventSubscriber(ObjectType::Table, 36, 'OnValidateBilltoCustomerTemplateCodeBeforeRecreateSalesLines', '', true, true)]
    procedure OnValidateBilltoCustomerTemplateCodeBeforeRecreateSalesLines(VAR SalesHeader: Record "Sales Header"; CallingFieldNo: Integer)
    begin
        SalesHeader.SetPriceDiscGroups(SalesHeader.FIELDNO(SalesHeader."Bill-to Customer Template Code"));
    end;
    /// <summary>
    /// EN850OnBeforeInsertItemLedgEntry.
    /// </summary>
    /// <param name="VAR ItemLedgerEntry">Record "Item Ledger Entry".</param>
    /// <param name="ItemJournalLine">Record "Item Journal Line".</param>
    /// <param name="TransferItem">Boolean.</param>
    [EventSubscriber(ObjectType::Codeunit, 22, 'OnBeforeInsertItemLedgEntry', '', true, true)]
    procedure OnBeforeInsertItemLedgEntry(VAR ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; TransferItem: Boolean)
    var
        lENSetup: Record "Sales & Receivables Setup";
        lItem: Record Item;
        lItemUoM: Record "Item Unit of Measure";
        lText001: Label 'The %1 can not be calculated for %2 %3.';
    begin
        IF lENSetup.GET and lENSetup."Mandatory Item Rep UOM ELA" THEN begin
            lItem.GET(ItemLedgerEntry."Item No.");
            IF NOT lItemUoM.GET(ItemLedgerEntry."Item No.", lItem."Reporting UOM ELA") THEN BEGIN

                ERROR(lText001, ItemLedgerEntry.FIELDCAPTION("Reporting Qty. ELA"), ItemLedgerEntry.FIELDCAPTION("Item No."), ItemLedgerEntry."Item No.");
            END;

            ItemLedgerEntry."Reporting UOM ELA" := lItem."Reporting UOM ELA";
            ItemLedgerEntry."Reporting Qty. ELA" := lItem.TransfToRepUOMValue(ItemLedgerEntry.Quantity);
            ItemLedgerEntry."Rep. Qty. per UOM ELA" := lItemUoM."Qty. per Unit of Measure";
            IF ItemLedgerEntry.MODIFY THEN;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 87, 'OnBeforeInsertSalesOrderLine', '', true, true)]
    procedure OnBeforeInsertSalesOrderLine(VAR SalesOrderLine: Record "Sales Line"; SalesOrderHeader: Record "Sales Header"; BlanketOrderSalesLine: Record "Sales Line"; BlanketOrderSalesHeader: Record "Sales Header")
    begin
        SalesOrderLine."Original Order Qty. ELA" := SalesOrderLine.Quantity;
    end;

    [EventSubscriber(ObjectType::Page, 6510, 'OnBeforeAddToGlobalRecordSet', '', true, true)]
    procedure OnBeforeAddToGlobalRecordSet(VAR TrackingSpecification: Record "Tracking Specification"; EntriesExist: Boolean)
    var
        ldecQtyPerUOM: Decimal;

    begin


        TrackingSpecification."Quantity (Source UOM) ELA" := TrackingSpecification."Quantity (Base)" / TrackingSpecification."Qty. per Unit of Measure";

        ldecQtyPerUOM := TrackingSpecification."Qty. per Unit of Measure";
        IF (
          (ldecQtyPerUOM = 0)
        ) THEN BEGIN
            ldecQtyPerUOM := 1;
        END;
        TrackingSpecification."Quantity (Source UOM) ELA" := TrackingSpecification."Quantity (Base)" / ldecQtyPerUOM;


    end;
}
