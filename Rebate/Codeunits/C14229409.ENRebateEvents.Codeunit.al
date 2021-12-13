codeunit 14229409 "Rebate Events ELA"
{
    // ENRE1.00 2021-09-08 AJ

    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, 414, 'OnBeforeModifySalesDoc', '', false, false)]  // Rebate Sales Document
    local procedure rd(VAR SalesHeader: Record "Sales Header"; PreviewMode: Boolean; VAR IsHandled: Boolean)
    var
        gReleaseSalesDocFunctions: Codeunit "Rebate Sales Functions ELA";
    begin
        gReleaseSalesDocFunctions.rdCalculateRebates(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnAfterGLFinishPosting', '', false, false)]  // Gen. Jnl.-Post Line
    LOCAL procedure rdOnAfterGLFinishPosting(GLEntry: Record "G/L Entry"; VAR GenJnlLine: Record "Gen. Journal Line"; IsTransactionConsistent: Boolean; FirstTransactionNo: Integer; VAR GLRegister: Record "G/L Register"; VAR TempGLEntryBuf: Record "G/L Entry" TEMPORARY; VAR NextEntryNo: Integer; VAR NextTransactionNo: Integer)
    begin

        FinishRebatePosting(GenJnlLine);
    end;

    local procedure FinishRebatePosting(VAR precGenJnlLine: Record "Gen. Journal Line") //Gen. Jnl.-Post Line
    //<<ENRE1.00
    var
        lrecPostedRebateEntry: Record "Rebate Ledger Entry ELA";
    begin


        IF (precGenJnlLine."Rebate Code ELA" <> '') AND (precGenJnlLine."Posted Rebate Entry No. ELA" <> 0) THEN BEGIN
            lrecPostedRebateEntry.GET(precGenJnlLine."Posted Rebate Entry No. ELA");

            lrecPostedRebateEntry."Posted To G/L" := TRUE;

            CASE lrecPostedRebateEntry."Functional Area" OF
                lrecPostedRebateEntry."Functional Area"::Sales:
                    BEGIN

                        IF NOT lrecPostedRebateEntry."G/L Posting Only" THEN
                            lrecPostedRebateEntry."Posted To Customer" := TRUE;

                    END;
                lrecPostedRebateEntry."Functional Area"::Purchase:
                    BEGIN
                        IF NOT lrecPostedRebateEntry."G/L Posting Only" THEN
                            lrecPostedRebateEntry."Posted To Vendor" := TRUE;
                    END;
            END;

            lrecPostedRebateEntry.MODIFY;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnAfterInitOldDtldCVLedgEntryBuf', '', false, false)] //Gen. Jnl.-Post Line


    local procedure OnAfterInitOldDtldCVLedgEntryBuf(VAR DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer"; VAR NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; VAR OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; VAR PrevNewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; VAR PrevOldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; VAR GenJnlLine: Record "Gen. Journal Line")
    var
        gTransferCustomFields: Codeunit "Transfer Custom Fields ELA";
    begin
        gTransferCustomFields.GenJnlLineTOCVLedgEntryBuf(GenJnlLine, OldCVLedgEntryBuf);
    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnAfterInitNewDtldCVLedgEntryBuf', '', false, false)] //Gen. Jnl.-Post Line
    local procedure OnAfterInitNewDtldCVLedgEntryBuf(VAR DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer"; VAR NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; VAR OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; VAR PrevNewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; VAR PrevOldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; VAR GenJnlLine: Record "Gen. Journal Line")
    begin
        IF NOT OldCVLedgEntryBuf.Open THEN BEGIN
            PayRebateEntries(OldCVLedgEntryBuf);
        End;
    end;

    [EventSubscriber(ObjectType::Table, 382, 'OnAfterSetClosedFields', '', false, false)]  //Gen. Jnl.-Post Line
    local procedure OnAfterSetClosedFields(VAR CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer")
    begin
        PayRebateEntries(CVLedgerEntryBuffer);
    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnBeforeApplyCustLedgEntry', '', false, false)] //Gen. Jnl.-Post Line
    local procedure OnBeforeApplyCustLedgEntry(VAR NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; VAR DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer"; VAR GenJnlLine: Record "Gen. Journal Line"; Cust: Record Customer; VAR IsAmountToApplyCheckHandled: Boolean)
    begin
        IF NewCVLedgEntryBuf."Amount to Apply" = 0 THEN BEGIN
            //ApplyCommissionEntries(NewCVLedgEntryBuf);
            PayRebateEntries(NewCVLedgEntryBuf);
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 12, 'OnBeforeApplyVendLedgEntry', '', false, false)] //Gen. Jnl.-Post Line

    local procedure OnBeforeApplyVendLedgEntry(VAR NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; VAR DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer"; VAR GenJnlLine: Record "Gen. Journal Line"; Vend: Record Vendor; VAR IsAmountToApplyCheckHandled: Boolean)
    begin
        //<<ENRE1.00
        IF (NewCVLedgEntryBuf."Amount to Apply" = 0) AND (NewCVLedgEntryBuf."Rebate Source Type ELA" <> 0) THEN BEGIN
            PayRebateEntries(NewCVLedgEntryBuf);
        END; //>>ENRE1.00
    end;

    [EventSubscriber(ObjectType::Codeunit, 17, 'OnReverseGLEntryOnBeforeInsertGLEntry', '', false, false)] //Gen. Jnl.-Post Reverse

    local procedure OnReverseGLEntryOnBeforeInsertGLEntry(VAR GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line"; GLEntry2: Record "G/L Entry")
    var
        TempCustLedgEntry: Record "Cust. Ledger Entry";
        TempVendLedgEntry: Record "Vendor Ledger Entry";
    begin
        CASE TRUE OF
            TempCustLedgEntry.GET(GLEntry2."Entry No."):
                BEGIN
                    IF TempCustLedgEntry."Reversed Entry No." <> 0 THEN
                        TempCustLedgEntry.TESTFIELD("Posted Rebate Entry No. ELA", 0); //ENRE1.00
                END;
            TempVendLedgEntry.GET(GLEntry2."Entry No."):
                BEGIN
                    IF TempVendLedgEntry."Reversed Entry No." <> 0 THEN
                        TempVendLedgEntry.TESTFIELD("Posted Rebate Entry No. ELA", 0);  //ENRE1.00
                end;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 17, 'OnReverseVendLedgEntryOnBeforeInsertVendLedgEntry', '', false, false)] //Gen. Jnl.-Post Reverse
    local procedure OnReverseVendLedgEntryOnBeforeInsertVendLedgEntry(VAR NewVendLedgEntry: Record "Vendor Ledger Entry"; VendLedgEntry: Record "Vendor Ledger Entry")
    begin
        IF VendLedgEntry."Reversed Entry No." <> 0 THEN BEGIN
            VendLedgEntry.TESTFIELD("Posted Rebate Entry No. ELA", 0);//ENRE1.00
        end;
    end;

    procedure PayRebateEntries(VAR precCVLedgEntryBuf: Record "CV Ledger Entry Buffer")
    //<<ENRE1.00
    var
        lrecPostedRebateEntry: Record "Rebate Ledger Entry ELA";
    begin


        IF precCVLedgEntryBuf."Posted Rebate Entry No. ELA" <> 0 THEN BEGIN
            lrecPostedRebateEntry.SETRANGE("Entry No.", precCVLedgEntryBuf."Posted Rebate Entry No. ELA");

            IF NOT lrecPostedRebateEntry.ISEMPTY THEN BEGIN
                lrecPostedRebateEntry.FINDSET(TRUE);

                REPEAT
                    CASE lrecPostedRebateEntry."Functional Area" OF
                        lrecPostedRebateEntry."Functional Area"::Sales:
                            lrecPostedRebateEntry."Paid to Customer" := TRUE;
                        lrecPostedRebateEntry."Functional Area"::Purchase:
                            lrecPostedRebateEntry."Paid-by Vendor" := TRUE;
                    END;

                    lrecPostedRebateEntry.MODIFY;
                UNTIL lrecPostedRebateEntry.NEXT = 0;
            END;
        END;
    End;
    //>>ENRE1.00
    [EventSubscriber(ObjectType::Codeunit, 415, 'OnBeforeModifyPurchDoc', '', false, false)] // Release Purchase Document

    local procedure OnBeforeModifyPurchDoc(VAR PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; VAR IsHandled: Boolean)
    var
        gReleasePurchDocFunctions: Codeunit "Rebate Purchase Functions ELA";
    begin
        gReleasePurchDocFunctions.rdCalculateRebates(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', false, false)] // Sales Post

    local procedure OnAfterPostSalesDoc(VAR SalesHeader: Record "Sales Header"; VAR GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean)
    begin
        //<<ENRE1.00
        SalesSetup.Get;

        IF NOT PreviewMode THEN BEGIN
            IF SalesSetup."Post Rbt on Document Post ELA" THEN BEGIN
                IF SalesHeader.Invoice THEN BEGIN
                    lrecRebate.RESET;

                    lrecRebate.SETFILTER("Rebate Type", '%1|%2|%3', lrecRebate."Rebate Type"::"Off-Invoice", lrecRebate."Rebate Type"::Everyday,
                                                                  lrecRebate."Rebate Type"::Commodity);

                    CLEAR(grptPostRebate);

                    IF SalesHeader."Document Type" IN [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice] THEN BEGIN
                        grptPostRebate.SetRebateLedgerFilters('', lrecRebate, SalesInvHdrNo);
                    END ELSE BEGIN
                        grptPostRebate.SetRebateLedgerFilters('', lrecRebate, SalesCrMemoHdrNo);
                    END;

                    grptPostRebate.USEREQUESTPAGE(FALSE);
                    grptPostRebate.RUN;
                END;
            END;
        END;
        //>>ENRE1.00
        //<<ENRE1.00
        IF NOT PreviewMode THEN BEGIN
            IF grecPurchSetup."Post SB Rbt on SDoc Post ELA" THEN BEGIN
                IF SalesHeader.Invoice THEN BEGIN
                    lrecPurchRebate.RESET;
                    lrecPurchRebate.SETFILTER("Rebate Type", '%1', lrecPurchRebate."Rebate Type"::"Sales-Based");
                    CLEAR(grptPostRebate);
                    IF SalesHeader."Document Type" IN [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice] THEN BEGIN
                        grptPostSBRebate.SetRebateLedgerFilters('', lrecPurchRebate, SalesInvHdrNo);
                    END ELSE BEGIN
                        grptPostSBRebate.SetRebateLedgerFilters('', lrecPurchRebate, SalesCrMemoHeader."No.");
                    END;
                    grptPostSBRebate.USEREQUESTPAGE(FALSE);
                    grptPostSBRebate.RUN;
                END;
            END;
        END;
        //>>ENRE1.00


    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterFinalizePosting', '', false, false)]// Sales Post

    local procedure OnAfterFinalizePosting(VAR SalesHeader: Record "Sales Header"; VAR SalesShipmentHeader: Record "Sales Shipment Header"; VAR SalesInvoiceHeader: Record "Sales Invoice Header"; VAR SalesCrMemoHeader: Record "Sales Cr.Memo Header"; VAR ReturnReceiptHeader: Record "Return Receipt Header"; VAR GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
        SalesSetup.Get;
        //<<ENRE1.00
        IF NOT PreviewMode THEN BEGIN

            IF SalesHeader.Invoice THEN BEGIN
                IF SalesSetup."Register Rbt on Doc. Post ELA" THEN BEGIN
                    IF SalesHeader."Document Type" IN [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice] THEN BEGIN
                        lrrfHeader.GETTABLE(SalesInvoiceHeader);
                        lrrfHeader.SETPOSITION(SalesInvoiceHeader.GETPOSITION);
                    END ELSE BEGIN
                        lrrfHeader.GETTABLE(SalesCrMemoHeader);
                        lrrfHeader.SETPOSITION(SalesCrMemoHeader.GETPOSITION);
                    END;

                    gcduRebateMgt.BypassPurchRebates(TRUE);
                    // we will check whether to post these below

                    gcduRebateMgt.CalcSalesDocRebate(lrrfHeader, FALSE, TRUE);
                    COMMIT;
                END;
            END;
        END;

        //>>ENRE1.00
        //<<ENRE1.00

        IF NOT PreviewMode THEN BEGIN

            IF SalesHeader.Invoice THEN BEGIN
                grecPurchSetup.GET;
                IF grecPurchSetup."Register SB Rbt SDoc Post ELA" THEN BEGIN
                    IF SalesHeader."Document Type" IN [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice] THEN BEGIN
                        lrrfHeader.GETTABLE(SalesInvoiceHeader);
                        lrrfHeader.SETPOSITION(SalesInvoiceHeader.GETPOSITION);
                    END ELSE BEGIN
                        lrrfHeader.GETTABLE(SalesCrMemoHeader);
                        lrrfHeader.SETPOSITION(SalesCrMemoHeader.GETPOSITION);
                    END;
                    gcduPurchRebateMgt.CalcSalesBasedPurchRebate(lrrfHeader, FALSE, TRUE);
                    COMMIT;
                END;
            END;

        END; //>>ENRE1.00
    end;

    [EventSubscriber(ObjectType::Codeunit, 5063, 'OnAfterAutoArchiveSalesDocument', '', false, false)]// Approvals Mgmt.
    local procedure OnAfterAutoArchiveSalesDocument(VAR SalesHeader: Record "Sales Header")

    begin
        //<<ENRE1.00
        lrrfHeader.GETTABLE(SalesHeader);
        lrrfHeader.SETVIEW(SalesHeader.GETVIEW);
        gcduRebateMgt.DeleteRebateEntryLines(lrrfHeader);
        lrrfHeader.GETTABLE(SalesHeader);
        lrrfHeader.SETVIEW(SalesHeader.GETVIEW);
        gcduPurchRebateMgt.DeleteSBRebateEntryLines(lrrfHeader); //>>ENRE1.00
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostCommitSalesDoc', '', false, false)]
    local procedure OnBeforePostCommitSalesDoc(VAR SalesHeader: Record "Sales Header"; VAR GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; VAR ModifyHeader: Boolean; VAR CommitIsSuppressed: Boolean; VAR TempSalesLineGlobal: Record "Sales Line" TEMPORARY)
    var

    begin
        //<<ENRE1.00



        IF (SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo") THEN BEGIN
            IF (SalesHeader."Applies-to Doc. Type" = SalesHeader."Applies-to Doc. Type"::Invoice) AND (SalesHeader."Applies-to Doc. No." <> '') THEN BEGIN
                gblnAppliedCredit := TRUE;
            END;
        END;


        //-- Only calculate rebates if calculating commissions on post AND you are calculating commissions after rebates

        IF NOT PreviewMode THEN BEGIN

            IF (SalesSetup."Calc Commissions on Post ELA") AND
               (SalesSetup."Calc. Comm. After Rebates ELA") THEN BEGIN


                IF (SalesHeader.Invoice) OR ((SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo") AND (NOT gblnAppliedCredit)) THEN BEGIN

                    lrrfHeader.GETTABLE(SalesHeader);
                    lrrfHeader.SETVIEW(SalesHeader.GETVIEW);

                    gcduRebateMgt.BypassPurchRebates(TRUE);

                    gcduRebateMgt.CalcSalesDocRebate(lrrfHeader, FALSE, TRUE);
                END;
            END;
        END;
        //>>ENRE1.00

    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterFinalizePosting', '', false, false)]
    local procedure rdOnAfterFinalizePosting(VAR PurchHeader: Record "Purchase Header"; VAR PurchRcptHeader: Record "Purch. Rcpt. Header"; VAR PurchInvHeader: Record "Purch. Inv. Header"; VAR PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; VAR ReturnShptHeader: Record "Return Shipment Header"; VAR GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; CommitIsSupressed: Boolean)
    begin
        PurchSetup.Get;
        //<ENRE1.00>
        IF NOT PreviewMode THEN BEGIN

            IF PurchHeader.Invoice THEN BEGIN
                IF PurchSetup."Register Rbt on Doc. Post ELA" THEN BEGIN
                    IF PurchHeader."Document Type" IN [PurchHeader."Document Type"::Order, PurchHeader."Document Type"::Invoice] THEN BEGIN
                        lrrfHeader.GETTABLE(PurchInvHeader);
                        lrrfHeader.SETPOSITION(PurchInvHeader.GETPOSITION);
                    END ELSE BEGIN
                        lrrfHeader.GETTABLE(PurchCrMemoHdr);
                        lrrfHeader.SETPOSITION(PurchCrMemoHdr.GETPOSITION);
                    END;

                    gcduPurchRebateMgt.CalcPurchDocRebate(lrrfHeader, FALSE, TRUE);
                    COMMIT;
                END;
            END;

        END;
        //</ENRE1.00>
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostPurchaseDoc', '', false, false)] // Purch- Post

    local procedure OnAfterPostPurchaseDoc(VAR PurchaseHeader: Record "Purchase Header"; VAR GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]; CommitIsSupressed: Boolean)
    begin


        PurchSetup.Get;
        //<ENRE1.00>
        IF NOT PreviewMode THEN BEGIN
            IF PurchSetup."Post Rbt on Document Post ELA" THEN BEGIN
                IF PurchaseHeader.Invoice THEN BEGIN
                    lrecPurchRebate.RESET;
                    lrecPurchRebate.SETFILTER("Rebate Type", '%1|%2',
                      lrecPurchRebate."Rebate Type"::"Off-Invoice", lrecPurchRebate."Rebate Type"::Everyday);
                    CLEAR(grptPostPurchRebate);
                    IF PurchaseHeader."Document Type" IN [PurchaseHeader."Document Type"::Order, PurchaseHeader."Document Type"::Invoice] THEN BEGIN
                        grptPostPurchRebate.SetRebateLedgerFilters('', lrecPurchRebate, PurchInvHdrNo);
                    END ELSE BEGIN
                        grptPostPurchRebate.SetRebateLedgerFilters('', lrecPurchRebate, PurchCrMemoHdrNo);
                    END;
                    grptPostPurchRebate.USEREQUESTPAGE(FALSE);
                    grptPostPurchRebate.RUN;
                END;
            END;
        END;
        //</ENRE1.00>

    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforeDeleteAfterPosting', '', false, false)] // Purch- Post
    local procedure OnBeforeDeleteAfterPosting(VAR PurchaseHeader: Record "Purchase Header"; VAR PurchInvHeader: Record "Purch. Inv. Header"; VAR PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; VAR SkipDelete: Boolean; CommitIsSupressed: Boolean)
    begin
        //<ENRE1.00>
        lrrfHeader.GETTABLE(PurchaseHeader);
        lrrfHeader.SETVIEW(PurchaseHeader.GETVIEW);
        gcduPurchRebateMgt.DeleteRebateEntryLines(lrrfHeader);
        //<ENRE1.00>
    end;

    var
        SalesHeader: Record "Sales Header";

        lrecRebate: Record "Rebate Header ELA";
        lrrfHeader: RecordRef;

        PurchSetup: Record "Purchases & Payables Setup";
        SalesSetup: Record "Sales & Receivables Setup";

        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PreviewMode: Boolean;

        grptPostRebate: Report "Post Rebates ELA";
        grptPostPurchRebate: Report "Post Purchase Rebates ELA";
        grecPurchSetup: Record "Purchases & Payables Setup";
        gcduPurchRebateMgt: Codeunit "Purchase Rebate Management ELA";
        lrecPurchRebate: Record "Purchase Rebate Header ELA";
        grptPostSBRebate: Report "Post Purchase Rebates ELA";
        gblnAppliedCredit: Boolean;
        gcduRebateMgt: Codeunit "Rebate Management ELA";

}