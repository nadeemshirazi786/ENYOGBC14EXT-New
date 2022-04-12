codeunit 14228882 "EN Sales CC Event Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterSalesInvHeaderInsert', '', true, true)]
    procedure OnAfterSalesInvHeaderInsert(VAR SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean)
    begin
        SalesInvHeader."Source Type ELA" := SalesHeader."Source Type ELA";
        SalesInvHeader."Source Subtype ELA" := SalesHeader."Source Subtype ELA";
        SalesInvHeader."Source ID ELA" := SalesHeader."Source ID ELA";
        SalesInvHeader."Authorized Amount ELA" := SalesHeader."Authorized Amount ELA";
        SalesInvHeader."Authorized User ELA" := SalesHeader."Authorized User ELA";
        SalesInvHeader."Cash & Carry ELA" := SalesHeader."Cash & Carry ELA";
        SalesInvHeader."Cash Applied (Current) ELA" := SalesHeader."Cash Applied (Current) ELA";
        SalesInvHeader."Cash Applied (Other) ELA" := SalesHeader."Cash Applied (Other) ELA";
        SalesInvHeader."Cash Tendered ELA" := SalesHeader."Cash Tendered ELA";
        SalesInvHeader."Cash vs Amount Incld Tax ELA" := SalesHeader."Cash vs Amount Incld Tax ELA";
        SalesInvHeader."Stop Arrival Time ELA" := SalesHeader."Stop Arrival Time ELA";
        SalesInvHeader."Non-Commissionable ELA" := SalesHeader."Non-Commissionable ELA";
        SalesInvHeader."Approved By ELA" := SalesHeader."Approved By ELA";
        SalesInvHeader."Approval Status ELA" := SalesHeader."Approval Status ELA";
        SalesInvHeader."Order Template Location ELA" := SalesHeader."Order Template Location ELA";
        SalesInvHeader."Entered Amount to Apply ELA" := SalesHeader."Entered Amount to Apply ELA";
        SalesInvHeader."Change Due ELA" := SalesHeader."Change Due ELA";
        SalesInvHeader."Entered Amount to Apply ELA" := SalesHeader."Entered Amount to Apply ELA";
        SalesInvHeader.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterSalesInvLineInsert', '', true, true)]
    procedure OnAfterSalesInvLineInsertUpdate(VAR SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSuppressed: Boolean; VAR SalesHeader: Record "Sales Header"; VAR TempItemChargeAssgntSales: Record "Item Charge Assignment (Sales)")
    begin
        SalesInvLine."Authrzed Price below Cost ELA" := SalesLine."Authrzed Price below Cost ELA";
        SalesInvLine."Authorized Unit Price ELA" := SalesLine."Authorized Unit Price ELA";
        SalesInvLine."To be Authorized ELA" := SalesLine."To be Authorized ELA";
        SalesInvLine."Requested Order Qty. ELA" := SalesLine."Requested Order Qty. ELA";
        SalesInvLine.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostBalancingEntry', '', true, true)]
    local procedure OnBeforePostBalancingEntry(VAR GenJnlLine: Record "Gen. Journal Line"; SalesHeader: Record "Sales Header"; VAR TotalSalesLine: Record "Sales Line"; VAR TotalSalesLineLCY: Record "Sales Line"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)

    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        TotalSalesLine2: Record "Sales Line";
        GenJnlLine2: Record "Gen. Journal Line";
        TotalSalesLineLCY2: Record "Sales Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DocType: Option;
        DocNo: Code[20];
        SourceCode: Code[10];
    begin

        //<JF12847KV>
    //     gblnSetAppliedAmt := true;
    //     if gblnSetAppliedAmt THEN
    //         GenJnlLine.Amount := -SalesHeader."Cash Applied (Current) ELA"
    //     ELSE
    //         //</JF12847KV>
    //         GenJnlLine.Amount :=
    // TotalSalesLine2."Amount Including VAT" + CustLedgEntry."Remaining Pmt. Disc. Possible";
    //     GenJnlLine."Source Currency Code" := SalesHeader."Currency Code";
    //     //<JF12847KV>
    //     IF gblnSetAppliedAmt THEN
    //         GenJnlLine."Source Currency Amount" := -SalesHeader."Cash Applied (Current) ELA"
    //     ELSE
    //         //</JF12847KV>
    //         GenJnlLine."Source Currency Amount" := GenJnlLine.Amount;
    //     GenJnlLine.Correction := SalesHeader.Correction;
    //     CustLedgEntry.CALCFIELDS(Amount);
    //     //JF12847
    //     IF gblnSetAppliedAmt THEN BEGIN
    //         GenJnlLine."Amount (LCY)" := -SalesHeader."Cash Applied (Current) ELA";
    //     END ELSE BEGIN
    //         //</JF12847KV>
    //         IF CustLedgEntry.Amount = 0 THEN
    //             GenJnlLine."Amount (LCY)" := TotalSalesLineLCY2."Amount Including VAT"
    //         ELSE
    //             GenJnlLine."Amount (LCY)" :=
    //               TotalSalesLineLCY2."Amount Including VAT" +
    //               ROUND(
    //                 CustLedgEntry."Remaining Pmt. Disc. Possible" /
    //                 CustLedgEntry."Adjusted Currency Factor");
    //         //<JF12847KV>
    //     END;
    //     //</JF12847KV>
    //     IF SalesHeader."Currency Code" = '' THEN
    //         GenJnlLine."Currency Factor" := 1
    //     ELSE
    //         GenJnlLine."Currency Factor" := SalesHeader."Currency Factor";
    //     GenJnlLine."Applies-to Doc. Type" := DocType;
    //     GenJnlLine."Applies-to Doc. No." := DocNo;
    //     GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
    //     GenJnlLine."Source No." := SalesHeader."Bill-to Customer No.";
    //     GenJnlLine."Source Code" := SourceCode;
    //     GenJnlLine."Posting No. Series" := SalesHeader."Posting No. Series";
    //     GenJnlLine."IC Partner Code" := SalesHeader."Sell-to IC Partner Code";
    //     GenJnlLine."Salespers./Purch. Code" := SalesHeader."Salesperson Code";
    //     GenJnlLine."Allow Zero-Amount Posting" := TRUE;

    //     //<JF00085JJ>
    //     GenJnlLine."Ship-to/Order Address Code" := SalesHeader."Ship-to Code";
    //     //</JF00085JJ>
    //     IF (gblnSetAppliedAmt) AND (SalesHeader."Cash Applied (Current) ELA" <> 0) THEN //<JFKV>
    //         GenJnlPostLine.RunWithCheck(GenJnlLine2);
    //     // grecGenJnlLine_AdditionalPaymentsToPost.copy(GenJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostBalancingEntry', '', true, true)]
    local procedure OnAfterPostBalancingEntry(VAR GenJnlLine: Record "Gen. Journal Line"; VAR SalesHeader: Record "Sales Header"; VAR TotalSalesLine: Record "Sales Line"; VAR TotalSalesLineLCY: Record "Sales Line"; CommitIsSuppressed: Boolean; VAR GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        ENCCPg: Page "EN Sales Order C&C Card";
        CustLedgEntry: Record "Cust. Ledger Entry";
        TotalSalesLine2: Record "Sales Line";
        GenJnlLine2: Record "Gen. Journal Line";
        SalesHeader2:Record "Sales Header";
        TotalSalesLineLCY2: Record "Sales Line";
        //GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DocType: Option;
        DocNo: Code[20];
        SourceCode: Code[10];
    //GenJnlLine2:Record "Gen. Journal Line";
    begin

        gblnSetAppliedAmt := true;
        if gblnSetAppliedAmt THEN
            GenJnlLine2.Amount := -SalesHeader2."Cash Applied (Current) ELA"
        ELSE
            //</JF12847KV>
            GenJnlLine2.Amount :=
    TotalSalesLine2."Amount Including VAT" + CustLedgEntry."Remaining Pmt. Disc. Possible";
        GenJnlLine2."Source Currency Code" := SalesHeader2."Currency Code";
        //<JF12847KV>
        IF gblnSetAppliedAmt THEN
            GenJnlLine2."Source Currency Amount" := -SalesHeader2."Cash Applied (Current) ELA"
        ELSE
            //</JF12847KV>
            GenJnlLine2."Source Currency Amount" := GenJnlLine.Amount;
        GenJnlLine2.Correction := SalesHeader2.Correction;
        CustLedgEntry.CALCFIELDS(Amount);
        //JF12847
        IF gblnSetAppliedAmt THEN BEGIN
            GenJnlLine2."Amount (LCY)" := -SalesHeader2."Cash Applied (Current) ELA";
        END ELSE BEGIN
            //</JF12847KV>
            IF CustLedgEntry.Amount = 0 THEN
                GenJnlLine2."Amount (LCY)" := TotalSalesLineLCY2."Amount Including VAT"
            ELSE
                GenJnlLine2."Amount (LCY)" :=
                  TotalSalesLineLCY2."Amount Including VAT" +
                  ROUND(
                    CustLedgEntry."Remaining Pmt. Disc. Possible" /
                    CustLedgEntry."Adjusted Currency Factor");
            //<JF12847KV>
        END;
        //</JF12847KV>
        IF SalesHeader2."Currency Code" = '' THEN
            GenJnlLine2."Currency Factor" := 1
        ELSE
            GenJnlLine2."Currency Factor" := SalesHeader2."Currency Factor";
        GenJnlLine2."Applies-to Doc. Type" := DocType;
        GenJnlLine2."Applies-to Doc. No." := DocNo;
        GenJnlLine2."Source Type" := GenJnlLine."Source Type"::Customer;
        GenJnlLine2."Source No." := SalesHeader2."Bill-to Customer No.";
        GenJnlLine2."Source Code" := SourceCode;
        GenJnlLine2."Posting No. Series" := SalesHeader2."Posting No. Series";
        GenJnlLine2."IC Partner Code" := SalesHeader2."Sell-to IC Partner Code";
        GenJnlLine2."Salespers./Purch. Code" := SalesHeader2."Salesperson Code";
        GenJnlLine2."Allow Zero-Amount Posting" := TRUE;

        //<JF00085JJ>
        GenJnlLine2."Ship-to/Order Address Code" := SalesHeader2."Ship-to Code";
        //</JF00085JJ>
        IF (gblnSetAppliedAmt) AND (SalesHeader2."Cash Applied (Current) ELA" <> 0) THEN //<JFKV>
            GenJnlPostLine.RunWithCheck(GenJnlLine2);
        IF (SalesHeader."Cash&CarryApplied")
        THEN BEGIN
            If GenJnlLine.Get(SalesHeader."CC Applied Jnl Template", SalesHeader."CC Applied Jnl Batch", SalesHeader."CC Applied Line") then begin

                lcduGenJnlPostBatch.RUN(GenJnlLine);

            end
        END;
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterCopyFromItem', '', true, true)]
    local procedure OnAfterCopyItem(var SalesLine: Record "Sales Line"; Item: Record Item)
    begin
        SalesLine.Validate("Size Code ELA", Item."Size Code ELA");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr', '', true, true)]
    local procedure OrderTemplateLocation(var SalesHeader: Record "Sales Header")
    begin
        //SalesHeader.Validate("Order Template Location ELA", SalesHeader."Ship-to Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, 7302, 'OnInitWhseJnlLineCopyFromItemJnlLine', '', true, true)]
    local procedure OnInitWhseJnlLineFromItemJnlLine(var WarehouseJournalLine: Record "Warehouse Journal Line"; ItemJournalLine: Record "Item Journal Line")
    var
        Location: Record Location;

    begin
        IF Location.GET(ItemJournalLine."Location Code") THEN;
        IF Location."Directed Put-away and Pick" THEN BEGIN
            WarehouseJournalLine.Quantity := ROUND(ItemJournalLine."Quantity (Base)" / ItemJournalLine."Qty. per Unit of Measure", 0.00001);
            WarehouseJournalLine."Unit of Measure Code" := ItemJournalLine."Unit of Measure Code";
            WarehouseJournalLine."Qty. per Unit of Measure" := ItemJournalLine."Qty. per Unit of Measure";
        END ELSE BEGIN
            IF UseBaseUOM(ItemJournalLine."Item No.", ItemJournalLine."Variant Code", ItemJournalLine."Location Code") THEN BEGIN
                WarehouseJournalLine.Quantity := ItemJournalLine."Quantity (Base)";
                WarehouseJournalLine."Unit of Measure Code" := GetBaseUOM(ItemJournalLine."Item No.");
                WarehouseJournalLine."Qty. per Unit of Measure" := 1;
            END ELSE BEGIN
                WarehouseJournalLine.Quantity := ItemJournalLine.Quantity;
                WarehouseJournalLine."Unit of Measure Code" := ItemJournalLine."Unit of Measure Code";
                WarehouseJournalLine."Qty. per Unit of Measure" := ItemJournalLine."Qty. per Unit of Measure";
            END;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 7301, 'OnInitWhseEntryCopyFromWhseJnlLine', '', true, true)]
    local procedure OnInitWhseEntryCopyFromWhseJnlLine(VAR WarehouseEntry: Record "Warehouse Entry"; WarehouseJournalLine: Record "Warehouse Journal Line"; OnMovement: Boolean; Sign: Integer)
    var
        Location: Record Location;

    begin
        IF Location.GET(WarehouseJournalLine."Location Code") THEN;
        IF Location."Directed Put-away and Pick" THEN BEGIN
            WarehouseEntry.Quantity := WarehouseJournalLine."Qty. (Absolute)" * Sign;
            WarehouseEntry."Unit of Measure Code" := WarehouseJournalLine."Unit of Measure Code";
            WarehouseEntry."Qty. per Unit of Measure" := WarehouseJournalLine."Qty. per Unit of Measure";
        END ELSE BEGIN

            IF UseBaseUOM(WarehouseJournalLine."Item No.", WarehouseJournalLine."Variant Code", WarehouseJournalLine."Location Code") THEN BEGIN
                WarehouseEntry.Quantity := WarehouseJournalLine."Qty. (Absolute, Base)" * Sign;
                WarehouseEntry."Unit of Measure Code" := GetBaseUOM(WarehouseJournalLine."Item No.");
                WarehouseEntry."Qty. per Unit of Measure" := 1;
            END ELSE BEGIN
                WarehouseEntry.Quantity := WarehouseJournalLine."Qty. (Absolute)" * Sign;
                WarehouseEntry."Unit of Measure Code" := WarehouseJournalLine."Unit of Measure Code";
                WarehouseEntry."Qty. per Unit of Measure" := WarehouseJournalLine."Qty. per Unit of Measure";
            END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5760, 'OnBeforeInsertTempWhseJnlLine', '', true, true)]
    local procedure OnBeforeInsertTempWhseJnlLine(VAR TempWarehouseJournalLine: Record "Warehouse Journal Line" temporary; PostedWhseReceiptLine: Record "Posted Whse. Receipt Line")
    var
        Location: Record Location;

    begin
        IF Location.GET(PostedWhseReceiptLine."Location Code") THEN;

        IF Location."Directed Put-away and Pick" THEN BEGIN
            TempWarehouseJournalLine."Qty. (Absolute)" := PostedWhseReceiptLine.Quantity;
            TempWarehouseJournalLine."Unit of Measure Code" := PostedWhseReceiptLine."Unit of Measure Code";
            TempWarehouseJournalLine."Qty. per Unit of Measure" := PostedWhseReceiptLine."Qty. per Unit of Measure";
        END ELSE BEGIN
            IF UseBaseUOM(PostedWhseReceiptLine."Item No.", PostedWhseReceiptLine."Variant Code", PostedWhseReceiptLine."Location Code") THEN BEGIN
                TempWarehouseJournalLine."Qty. (Absolute)" := PostedWhseReceiptLine."Qty. (Base)";
                TempWarehouseJournalLine."Unit of Measure Code" := GetBaseUOM(PostedWhseReceiptLine."Item No.");
                TempWarehouseJournalLine."Qty. per Unit of Measure" := 1;
            END ELSE BEGIN
                TempWarehouseJournalLine."Qty. (Absolute)" := PostedWhseReceiptLine.Quantity;
                TempWarehouseJournalLine."Unit of Measure Code" := PostedWhseReceiptLine."Unit of Measure Code";
                TempWarehouseJournalLine."Qty. per Unit of Measure" := PostedWhseReceiptLine."Qty. per Unit of Measure";
            END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 7307, 'OnBeforeWhseJnlRegisterLine', '', true, true)]
    procedure OnBeforeWhseJnlRegisterLine(VAR WarehouseJournalLine: Record "Warehouse Journal Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        Location: Record Location;

    begin
        IF Location.GET(WarehouseActivityLine."Location Code") THEN;

        IF Location."Directed Put-away and Pick" THEN BEGIN
            WarehouseJournalLine.Quantity := WarehouseActivityLine."Qty. to Handle";
            WarehouseJournalLine."Unit of Measure Code" := WarehouseActivityLine."Unit of Measure Code";
            WarehouseJournalLine."Qty. per Unit of Measure" := WarehouseActivityLine."Qty. per Unit of Measure";
        END ELSE BEGIN
            IF UseBaseUOM(WarehouseActivityLine."Item No.", WarehouseActivityLine."Variant Code", WarehouseActivityLine."Location Code") THEN BEGIN
                WarehouseJournalLine.Quantity := WarehouseActivityLine."Qty. to Handle (Base)";
                WarehouseJournalLine."Unit of Measure Code" := GetBaseUOM(WarehouseActivityLine."Item No.");
                WarehouseJournalLine."Qty. per Unit of Measure" := 1;
            END ELSE BEGIN
                WarehouseJournalLine.Quantity := WarehouseActivityLine."Qty. to Handle";
                WarehouseJournalLine."Unit of Measure Code" := WarehouseActivityLine."Unit of Measure Code";
                WarehouseJournalLine."Qty. per Unit of Measure" := WarehouseActivityLine."Qty. per Unit of Measure";
            END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 414, 'OnBeforeSalesLineFind', '', true, true)]
    local procedure OnBeforeSalesLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        lrecCustomer: Record Customer;
        ltxtText000: TextConst ENU = 'A %1 is required for %2 %3 on Sales %4 No. %5';
    begin

        IF NOT (SalesHeader."Document Type" IN [SalesHeader."Document Type"::Quote,
                                                    SalesHeader."Document Type"::Order,
                                                    SalesHeader."Document Type"::Invoice]) THEN
            EXIT;

        IF SalesHeader."Ship-to Code" <> '' THEN
            EXIT;

        IF SalesHeader."Sell-to Customer No." <> '' THEN BEGIN
            IF lrecCustomer.GET(SalesHeader."Sell-to Customer No.") THEN BEGIN
                IF lrecCustomer."Req. Ship-To on Sale Doc ELA" THEN BEGIN
                    IF SalesHeader."Ship-to Code" = '' THEN
                        ERROR(ltxtText000, SalesHeader.FIELDCAPTION("Ship-to Code"), SalesHeader.FIELDCAPTION("Sell-to Customer No."),
                              SalesHeader."Sell-to Customer No.", SalesHeader."Document Type", SalesHeader."No.");
                END;
            END;
        END;
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterUpdateWithWarehouseShip', '', true, true)]
    procedure OnAfterUpdateWithWarehouseShip(SalesHeader: Record "Sales Header"; VAR SalesLine: Record "Sales Line")
    var
        Location: Record Location;
    begin
        IF SalesLine.Type = SalesLine.Type::Item THEN
            CASE TRUE OF
                (SalesLine."Document Type" IN [SalesLine."Document Type"::Quote, SalesLine."Document Type"::Order]) AND (SalesLine.Quantity >= 0):
                    IF Location.RequireShipment(SalesLine."Location Code")
                        AND NOT SalesLine.yogIsCashAndCarry(SalesLine)
                    THEN
                        SalesLine.VALIDATE(SalesLine."Qty. to Ship", 0)
                    ELSE
                        SalesLine.VALIDATE(SalesLine."Qty. to Ship", SalesLine."Outstanding Quantity");
                // SalesLine.VALIDATE(SalesLine."Qty. to Ship", 0);
                //SalesLine."Qty. to Ship" := SalesLine."Outstanding Quantity";
                (SalesLine."Document Type" IN [SalesLine."Document Type"::Quote, SalesLine."Document Type"::Order]) AND (SalesLine.Quantity < 0):
                    IF Location.RequireReceive(SalesLine."Location Code") THEN
                        SalesLine.VALIDATE(SalesLine."Qty. to Ship", 0)
                    ELSE
                        SalesLine.VALIDATE(SalesLine."Qty. to Ship", SalesLine."Outstanding Quantity");
                //SalesLine."Qty. to Ship" := SalesLine."Outstanding Quantity";
                (SalesLine."Document Type" = SalesLine."Document Type"::"Return Order") AND (SalesLine.Quantity >= 0):
                    IF Location.RequireReceive(SalesLine."Location Code") THEN
                        SalesLine.VALIDATE(SalesLine."Return Qty. to Receive", 0)
                    ELSE
                        SalesLine.VALIDATE(SalesLine."Return Qty. to Receive", SalesLine."Outstanding Quantity");
                (SalesLine."Document Type" = SalesLine."Document Type"::"Return Order") AND (SalesLine.Quantity < 0):
                    IF Location.RequireShipment(SalesLine."Location Code") THEN
                        SalesLine.VALIDATE(SalesLine."Return Qty. to Receive", 0)
                    ELSE
                        SalesLine.VALIDATE(SalesLine."Return Qty. to Receive", SalesLine."Outstanding Quantity");
            END;
        SalesLine.SetDefaultQuantity;
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnCheckWarehouseOnBeforeShowDialog', '', true, true)]
    procedure ASOnCheckWarehouseOnBeforeShowDialog(SalesLine: Record "Sales Line"; Location: Record Location; ShowDialog: Option " ",Message,Error; VAR DialogText: Text[50])
    var
        gblnHideWhseShowDlgMsg: Boolean;
        gblnHideWhseShowDlgErr: Boolean;
        Text016: TextConst ENU = '%1 is required for %2 = %3.';
        Text017: TextConst ENU = '\The entered information may be disregarded by warehouse operations.';
    begin

        //<YOG43312AC>
        gblnHideWhseShowDlgMsg := gblnHideWhseShowDlgMsg OR SalesLine.yogIsCashAndCarry(SalesLine);
        //</YOG43312AC>

        CASE ShowDialog OF
            ShowDialog::Message:
                //<JF3826DD>
                BEGIN
                    IF NOT gblnHideWhseShowDlgMsg THEN BEGIN
                        MESSAGE(Text016 + Text017, DialogText, SalesLine.FieldCaption("Line No."), SalesLine."Line No.");
                    END;
                END;
            //</JF3826DD>
            ShowDialog::Error:
                //<JF3826DD>
                BEGIN
                    IF NOT gblnHideWhseShowDlgErr THEN BEGIN
                        ERROR(Text016, DialogText, SalesLine.FIELDCAPTION("Line No."), SalesLine."Line No.");
                    END;
                END;
        //</JF3826DD>

        end;

        ShowDialog := ShowDialog::" ";

    END;

    local procedure UseBaseUOM(pcodItemNo: Code[20];
pcodVariantCode:
    Code[10];
pcodLocation:
    Code[10]):
            Boolean
    var
        lrecSKU: Record "Stockkeeping Unit";
        Location:
                Record Location;
    begin
        GetLocation(pcodLocation);
        IF lrecSKU.GET(pcodLocation, pcodItemNo, pcodVariantCode) THEN BEGIN
            EXIT(NOT lrecSKU."Allow Multi-UOM Bin Contnt ELA");
        END ELSE BEGIN
            IF Location.Get(pcodLocation) then
                EXIT(NOT Location."Allow Multi-UOM Bin Contnt ELA");
        END;
    end;

    local procedure GetBaseUOM(ItemNo: Code[20]): Code[10]
    var
        Item: Record Item;
    begin
        GetItem(ItemNo);
        IF Item.Get(ItemNo) then
            EXIT(Item."Base Unit of Measure");
    end;

    LOCAL procedure GetItem(ItemNo: Code[20])
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        IF ItemNo = Item."No." THEN
            EXIT;

        Item.GET(ItemNo);
        IF Item."Item Tracking Code" <> '' THEN
            ItemTrackingCode.GET(Item."Item Tracking Code")
        ELSE
            CLEAR(ItemTrackingCode);
    end;

    LOCAL procedure GetLocation(LocationCode: Code[10])
    var
        Location: Record Location;
    begin
        IF LocationCode = '' THEN
            CLEAR(Location)
        ELSE
            IF Location.Code <> LocationCode THEN
                Location.GET(LocationCode);
    end;

    procedure SetGenJournalLineOfAdditionalPaymentsToPost(precGenJnlLine_AdditionalPaymentsToPost: Record "Gen. Journal Line")
    begin
        grecGenJnlLine_AdditionalPaymentsToPost.COPY(precGenJnlLine_AdditionalPaymentsToPost);
        gblnPostAdditionalPayments := TRUE;
    end;

    procedure SetApplyAmount(pdecAmountToApply: Decimal)
    begin
        gdecAmountToApply := pdecAmountToApply;
        gblnSetAppliedAmt := TRUE;
    end;

    var
        grecGenJnlLine_AdditionalPaymentsToPost: Record "Gen. Journal Line";
        gblnPostAdditionalPayments: Boolean;
        lcduGenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        gblnSetAppliedAmt: Boolean;
        gdecAmountToApply: Decimal;

}