codeunit 14229413 "Rebate Jnl.-Post Line ELA"
{
    // ENRE1.00 2021-09-08 AJ

    // ENRE1.00  - set posting date with journal posting date when rebate ledger posting date is blank
    // ENRE1.00  - modifed how Adjustment field is set
    // ENRE1.00  - need to set "Accrual Customer No." and "Posted to Customer" correctly
    // ENRE1.00  - Modified Code function to handle Purchase Adjustments
    // ENRE1.00  - Modified Function - Code
    // ENRE1.00  - new events

    Permissions = TableData "Rebate Ledger Entry ELA" = imd,
                  TableData "Rebate Journal Line ELA" = imd,
                  TableData "Rebate Register ELA" = imd;
    TableNo = "Rebate Journal Line ELA";

    trigger OnRun()
    begin
        RebateJnlLine.Copy(Rec);
        CheckLine := true;
        Code;
        Rec := RebateJnlLine;
    end;

    var
        grecCurrencyExchange: Record "Currency Exchange Rate";
        RebateJnlLine: Record "Rebate Journal Line ELA";
        CheckLine: Boolean;
        RebateJnlCheckLine: Codeunit "Rebate Jnl.-Check Line ELA";
        RebateLedgEntry: Record "Rebate Ledger Entry ELA";
        NextEntryNo: Integer;
        RebateReg: Record "Rebate Register ELA";


    procedure "Code"()
    var
        lrecRebateHeader: Record "Rebate Header ELA";
        lrecSalesInvHeader: Record "Sales Invoice Header";
        lrecSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        lrecRebateLedgerEntry: Record "Rebate Ledger Entry ELA";
        lrecCustomer: Record Customer;
        lrecSalesInvLine: Record "Sales Invoice Line";
        lrecSalesCrMemoLine: Record "Sales Cr.Memo Line";
        lcodDocCurrCode: Code[10];
        lrecPurchRebateHeader: Record "Purchase Rebate Header ELA";
        lrecPurchInvHeader: Record "Purch. Inv. Header";
        lrecPurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        lrecVendor: Record Vendor;
        lrecPurchInvLine: Record "Purch. Inv. Line";
        lrecPurchCrMemoLine: Record "Purch. Cr. Memo Line";
        lrecCurrency: Record Currency;
    begin

        //<ENRE1.00>
        rdOnBeforePostRebateJnlLine(RebateJnlLine);
        //</ENRE1.00>

        with RebateJnlLine do begin
            if CheckLine then
                RebateJnlCheckLine.Run(RebateJnlLine);
            if NextEntryNo = 0 then begin
                RebateLedgEntry.LockTable;
                if RebateLedgEntry.FindLast then begin
                    NextEntryNo := RebateLedgEntry."Entry No." + 1;
                end else begin
                    NextEntryNo := 1;
                end;
            end else
                NextEntryNo := RebateLedgEntry."Entry No." + 1;

            //<ENRE1.00>
            if RebateJnlLine."Applies-To Source Type" in [
                            RebateJnlLine."Applies-To Source Type"::"Posted Sales Invoice",
                            RebateLedgEntry."Source Type"::"Posted Cr. Memo",
                            RebateJnlLine."Applies-To Source Type"::Customer] then begin

                //</ENRE1.00>

                lrecRebateHeader.Get("Rebate Code");

                RebateLedgEntry."Entry No." := NextEntryNo;

                RebateLedgEntry."Rebate Batch Name" := "Rebate Batch Name";

                RebateLedgEntry."Functional Area" := RebateLedgEntry."Functional Area"::Sales;

                case RebateJnlLine."Applies-To Source Type" of
                    RebateJnlLine."Applies-To Source Type"::"Posted Sales Invoice":
                        begin
                            RebateLedgEntry."Source Type" := RebateLedgEntry."Source Type"::"Posted Invoice";

                            lrecSalesInvHeader.Get("Applies-To Source No.");
                            lrecSalesInvLine.Get("Applies-To Source No.", "Applies-To Source Line No.");

                            lcodDocCurrCode := lrecSalesInvHeader."Currency Code";

                            RebateLedgEntry."Item No." := lrecSalesInvLine."No.";
                            RebateLedgEntry."Bill-to Customer No." := lrecSalesInvHeader."Bill-to Customer No.";
                            RebateLedgEntry."Sell-to Customer No." := lrecSalesInvHeader."Sell-to Customer No.";
                        end;
                    RebateJnlLine."Applies-To Source Type"::"Posted Sales Cr. Memo":
                        begin
                            RebateLedgEntry."Source Type" := RebateLedgEntry."Source Type"::"Posted Cr. Memo";

                            lrecSalesCrMemoHeader.Get("Applies-To Source No.");
                            lrecSalesCrMemoLine.Get("Applies-To Source No.", "Applies-To Source Line No.");

                            lcodDocCurrCode := lrecSalesCrMemoHeader."Currency Code";

                            RebateJnlLine."Amount (LCY)" := -RebateJnlLine."Amount (LCY)";

                            RebateLedgEntry."Item No." := lrecSalesCrMemoLine."No.";
                            RebateLedgEntry."Bill-to Customer No." := lrecSalesCrMemoHeader."Bill-to Customer No.";
                            RebateLedgEntry."Sell-to Customer No." := lrecSalesCrMemoHeader."Sell-to Customer No.";
                        end;
                    RebateJnlLine."Applies-To Source Type"::Customer:
                        begin
                            RebateLedgEntry."Source Type" := RebateLedgEntry."Source Type"::Customer;

                            lrecCustomer.Get(RebateJnlLine."Applies-To Source No.");

                            lcodDocCurrCode := '';

                            RebateLedgEntry."Bill-to Customer No." := lrecCustomer."Bill-to Customer No.";

                            RebateLedgEntry."Sell-to Customer No." := lrecCustomer."No.";

                            if RebateLedgEntry."Bill-to Customer No." = '' then
                                RebateLedgEntry."Bill-to Customer No." := RebateLedgEntry."Sell-to Customer No.";
                        end;
                end;

                RebateLedgEntry.Validate("Source No.", "Applies-To Source No.");
                RebateLedgEntry."Source Line No." := "Applies-To Source Line No.";

                //<ENRE1.00>
                if RebateLedgEntry."Posting Date" = 0D then begin
                    RebateLedgEntry."Posting Date" := RebateJnlLine."Posting Date";
                end;
                //</ENRE1.00>

                RebateLedgEntry."Rebate Code" := RebateJnlLine."Rebate Code";

                RebateLedgEntry."Amount (LCY)" := "Amount (LCY)";

                if lrecRebateHeader."Currency Code" <> '' then begin
                    //<ENRE1.00>
                    lrecCurrency.Get(lrecRebateHeader."Currency Code");
                    RebateLedgEntry."Amount (RBT)" := Round(grecCurrencyExchange.ExchangeAmtLCYToFCY("Posting Date",
                                                             lrecRebateHeader."Currency Code", RebateJnlLine."Amount (LCY)",
                                                             grecCurrencyExchange.ExchangeRate("Posting Date",
                                                             lrecRebateHeader."Currency Code")),
                                                             lrecCurrency."Amount Rounding Precision");
                    RebateLedgEntry."Currency Code (RBT)" := lrecRebateHeader."Currency Code";
                    //</ENRE1.00>

                end else begin
                    RebateLedgEntry."Amount (RBT)" := RebateLedgEntry."Amount (LCY)";
                    //<ENRE1.00>
                    RebateLedgEntry."Currency Code (RBT)" := '';
                    //</ENRE1.00>
                end;

                if lrecRebateHeader."Rebate Type" <> lrecRebateHeader."Rebate Type"::"Lump Sum" then begin
                    if lcodDocCurrCode <> '' then begin
                        //<ENRE1.00>
                        lrecCurrency.Get(lcodDocCurrCode);
                        RebateLedgEntry."Amount (DOC)" := Round(grecCurrencyExchange.ExchangeAmtLCYToFCY("Posting Date",
                                                                lcodDocCurrCode, RebateJnlLine."Amount (LCY)",
                                                                grecCurrencyExchange.ExchangeRate("Posting Date", lcodDocCurrCode)),
                                                                lrecCurrency."Amount Rounding Precision");
                        RebateLedgEntry."Currency Code (DOC)" := lcodDocCurrCode;
                        //</ENRE1.00>
                    end else begin
                        RebateLedgEntry."Amount (DOC)" := RebateLedgEntry."Amount (LCY)";
                        //<ENRE1.00>
                        RebateLedgEntry."Currency Code (DOC)" := '';
                        //</ENRE1.00>
                    end;
                end;

                RebateLedgEntry."Posted To G/L" := false;
                RebateLedgEntry."Rebate Document No." := RebateJnlLine."Document No.";
                RebateLedgEntry."Date Created" := RebateJnlLine."Posting Date";
                RebateLedgEntry."Paid to Customer" := false;

                //<ENRE1.00>
                RebateLedgEntry."Post-to Customer No." := RebateJnlLine."Applies-To Customer No.";
                RebateLedgEntry."Posted To Customer" := false;
                //</ENRE1.00>

                RebateLedgEntry."Rebate Description" := lrecRebateHeader.Description;

                RebateLedgEntry."Reason Code" := "Reason Code";

                //<ENRE1.00>
                RebateLedgEntry.Adjustment := RebateJnlLine.Adjustment;
                //</ENRE1.00>

                //<ENRE1.00>
                OnBeforeInsertRebateLedgerEntry(RebateLedgEntry, RebateJnlLine);
                //</ENRE1.00>

                RebateLedgEntry.Insert(true);

                //<ENRE1.00>
                OnAfterInsertRebateLEdgerEntry(RebateLedgEntry, RebateJnlLine);
                //</ENRE1.00>

                //<ENRE1.00>
            end else begin
                lrecPurchRebateHeader.Get("Rebate Code");

                RebateLedgEntry."Entry No." := NextEntryNo;

                RebateLedgEntry."Rebate Batch Name" := "Rebate Batch Name";

                RebateLedgEntry."Functional Area" := RebateLedgEntry."Functional Area"::Purchase;

                case RebateJnlLine."Applies-To Source Type" of
                    RebateJnlLine."Applies-To Source Type"::"Posted Purch. Invoice":
                        begin
                            RebateLedgEntry."Source Type" := RebateLedgEntry."Source Type"::"Posted Invoice";

                            lrecPurchInvHeader.Get("Applies-To Source No.");
                            lrecPurchInvLine.Get("Applies-To Source No.", "Applies-To Source Line No.");

                            lcodDocCurrCode := lrecPurchInvHeader."Currency Code";

                            RebateLedgEntry."Item No." := lrecPurchInvLine."No.";
                            RebateLedgEntry."Pay-to Vendor No." := lrecPurchInvHeader."Pay-to Vendor No.";
                            RebateLedgEntry."Buy-from Vendor No." := lrecPurchInvHeader."Buy-from Vendor No.";
                        end;
                    RebateJnlLine."Applies-To Source Type"::"Posted Purch. Cr. Memo":
                        begin
                            RebateLedgEntry."Source Type" := RebateLedgEntry."Source Type"::"Posted Cr. Memo";

                            lrecPurchCrMemoHeader.Get("Applies-To Source No.");
                            lrecPurchCrMemoLine.Get("Applies-To Source No.", "Applies-To Source Line No.");

                            lcodDocCurrCode := lrecPurchCrMemoHeader."Currency Code";

                            RebateJnlLine."Amount (LCY)" := -RebateJnlLine."Amount (LCY)"; //should this be positive?

                            RebateLedgEntry."Item No." := lrecPurchCrMemoLine."No.";
                            RebateLedgEntry."Pay-to Vendor No." := lrecPurchCrMemoHeader."Pay-to Vendor No.";
                            RebateLedgEntry."Buy-from Vendor No." := lrecPurchCrMemoHeader."Buy-from Vendor No.";

                        end;
                    RebateJnlLine."Applies-To Source Type"::Vendor:
                        begin
                            RebateLedgEntry."Source Type" := RebateLedgEntry."Source Type"::Vendor;

                            lrecVendor.Get(RebateJnlLine."Applies-To Source No.");

                            lcodDocCurrCode := '';

                            RebateLedgEntry."Pay-to Vendor No." := lrecVendor."Pay-to Vendor No.";

                            RebateLedgEntry."Buy-from Vendor No." := lrecVendor."No.";

                            if RebateLedgEntry."Pay-to Vendor No." = '' then
                                RebateLedgEntry."Bill-to Customer No." := RebateLedgEntry."Buy-from Vendor No.";


                        end;
                end;

                RebateLedgEntry.Validate("Source No.", "Applies-To Source No.");
                RebateLedgEntry."Source Line No." := "Applies-To Source Line No.";

                //<ENRE1.00>
                if RebateLedgEntry."Posting Date" = 0D then begin
                    RebateLedgEntry."Posting Date" := RebateJnlLine."Posting Date";
                end;
                //</ENRE1.00>

                RebateLedgEntry."Rebate Code" := RebateJnlLine."Rebate Code";

                RebateLedgEntry."Amount (LCY)" := "Amount (LCY)";

                if lrecRebateHeader."Currency Code" <> '' then begin
                    //<ENRE1.00>
                    lrecCurrency.Get(lrecPurchRebateHeader."Currency Code");
                    RebateLedgEntry."Amount (RBT)" := Round(grecCurrencyExchange.ExchangeAmtLCYToFCY("Posting Date",
                                                                                               lrecPurchRebateHeader."Currency Code",
                                                                                               RebateJnlLine."Amount (LCY)",
                                                                                               grecCurrencyExchange.ExchangeRate("Posting Date",
                                                                                               lrecPurchRebateHeader."Currency Code")),
                                                                                               lrecCurrency."Amount Rounding Precision");
                    RebateLedgEntry."Currency Code (RBT)" := lrecPurchRebateHeader."Currency Code";
                    //</ENRE1.00>

                end else begin
                    RebateLedgEntry."Amount (RBT)" := RebateLedgEntry."Amount (LCY)";
                    //<ENRE1.00>
                    RebateLedgEntry."Currency Code (RBT)" := '';
                    //</ENRE1.00>
                end;

                if lrecPurchRebateHeader."Rebate Type" <> lrecPurchRebateHeader."Rebate Type"::"Lump Sum" then begin
                    if lcodDocCurrCode <> '' then begin
                        //<ENRE1.00>
                        lrecCurrency.Get(lcodDocCurrCode);
                        RebateLedgEntry."Amount (DOC)" := Round(grecCurrencyExchange.ExchangeAmtLCYToFCY("Posting Date", lcodDocCurrCode,
                                                                                                   RebateJnlLine."Amount (LCY)",
                                                                                                   grecCurrencyExchange.ExchangeRate(
                                                                                                   "Posting Date", lcodDocCurrCode)),
                                                                                                   lrecCurrency."Amount Rounding Precision");
                        RebateLedgEntry."Currency Code (DOC)" := lcodDocCurrCode;
                        //</ENRE1.00>
                    end else begin
                        RebateLedgEntry."Amount (DOC)" := RebateLedgEntry."Amount (LCY)";
                        //<ENRE1.00>
                        RebateLedgEntry."Currency Code (DOC)" := '';
                        //</ENRE1.00>
                    end;
                end;

                RebateLedgEntry."Posted To G/L" := false;
                RebateLedgEntry."Rebate Document No." := RebateJnlLine."Document No.";
                RebateLedgEntry."Date Created" := RebateJnlLine."Posting Date";
                RebateLedgEntry."Paid-by Vendor" := false;

                //<ENRE1.00>
                RebateLedgEntry."Post-to Vendor No." := RebateJnlLine."Applies-To Vendor No.";
                RebateLedgEntry."Posted To Vendor" := false;
                //</ENRE1.00>

                RebateLedgEntry."Rebate Description" := lrecPurchRebateHeader.Description;

                RebateLedgEntry."Reason Code" := "Reason Code";

                //<ENRE1.00>
                RebateLedgEntry.Adjustment := RebateJnlLine.Adjustment;
                //</ENRE1.00>


                //<ENRE1.00>
                OnBeforeInsertRebateLedgerEntry(RebateLedgEntry, RebateJnlLine);
                //</ENRE1.00>

                RebateLedgEntry.Insert(true);

                //<ENRE1.00>
                OnAfterInsertRebateLEdgerEntry(RebateLedgEntry, RebateJnlLine);
                //</ENRE1.00>
            end;
            //</ENRE1.00>

            if RebateReg."No." = 0 then begin
                RebateReg.LockTable;

                if (not RebateReg.FindLast) or (RebateReg."To Entry No." <> 0) then begin
                    RebateReg.Init;
                    RebateReg."No." := RebateReg."No." + 1;
                    RebateReg."From Entry No." := NextEntryNo;
                    RebateReg."To Entry No." := NextEntryNo;
                    RebateReg."Creation Date" := Today;
                    RebateReg."Source Code" := 'RBTJNL';
                    RebateReg."Journal Batch Name" := "Rebate Batch Name";
                    RebateReg."User ID" := UserId;
                    RebateReg.Insert;
                end;
            end;

            RebateReg."To Entry No." := NextEntryNo;
            RebateReg.Modify;
        end;

        //<ENRE1.00>
        rdOnAfterPostRebateJnlLine(RebateJnlLine);
        //</ENRE1.00>
    end;

    [IntegrationEvent(TRUE, TRUE)]

    procedure rdOnBeforePostRebateJnlLine(var pRebateJournalLine: Record "Rebate Journal Line ELA")
    begin
    end;

    [IntegrationEvent(TRUE, TRUE)]

    procedure rdOnAfterPostRebateJnlLine(var pRebateJournalLine: Record "Rebate Journal Line ELA")
    begin
    end;

    [IntegrationEvent(TRUE, TRUE)]
    local procedure OnBeforeInsertRebateLedgerEntry(var pRebateLedgerEntry: Record "Rebate Ledger Entry ELA"; var pRebateJournalLine: Record "Rebate Journal Line ELA")
    begin
    end;

    [IntegrationEvent(TRUE, TRUE)]
    local procedure OnAfterInsertRebateLEdgerEntry(var pRebateLedgerEntry: Record "Rebate Ledger Entry ELA"; var pRebateJournalLine: Record "Rebate Journal Line ELA")
    begin
    end;
}

