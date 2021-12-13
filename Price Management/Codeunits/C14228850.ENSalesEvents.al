/// <summary>
/// Codeunit EN Sales Events (ID 14228850).
/// </summary>
/// TEST Merge
codeunit 14228850 "EN Sales Events"
{

    /// <summary>
    /// UpdateItemCostOnBeforeReleaseSalesDoc.
    /// </summary>
    /// <param name="VAR SalesHeader">Record "Sales Header".</param>
    /// <param name="PreviewMode">Boolean.</param>
    [EventSubscriber(ObjectType::Codeunit, 414, 'OnBeforeReleaseSalesDoc', '', true, true)]
    procedure UpdateItemCostOnBeforeReleaseSalesDoc(VAR SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    var
        SalesSetup: Record "Sales & Receivables Setup";
        lcduOrderRules: codeunit "EN Order Rule Functions";

    begin
        IF SalesSetup.Get() and SalesSetup."Update ItemCost on Release ELA" then
            UpdateItemUnitCosts(SalesHeader);

        IF NOT lcduOrderRules.cbCheckOrder(SalesHeader) THEN BEGIN
            ERROR('');
        END;
    end;
    /// <summary>
    /// UpdateItemCostOnBeforePostSalesDoc.
    /// </summary>
    /// <param name="VAR SalesHeader">Record "Sales Header".</param>
    /// <param name="CommitIsSuppressed">Boolean.</param>
    /// <param name="PreviewMode">Boolean.</param>
    /// <param name="VAR HideProgressWindow">Boolean.</param>
    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostSalesDoc', '', true, true)]
    procedure UpdateItemCostOnBeforePostSalesDoc(VAR SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; VAR HideProgressWindow: Boolean)
    var
        lSalesSetup: Record "Sales & Receivables Setup";
    begin
        IF lSalesSetup.Get() and
            ((lSalesSetup."Update ItemCost on Invoice ELA" and SalesHeader.Invoice) OR (lSalesSetup."Update ItemCost on Spmt ELA" and SalesHeader.Ship))
        then
            UpdateItemUnitCosts(SalesHeader);

    end;

    local procedure UpdateItemUnitCosts(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        ItemLedgEntry: Record "Item Ledger Entry";
        OrigQtyPer: Decimal;
    begin
        SalesLine.Reset;
        SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SETRANGE("Drop Shipment", FALSE);
        SalesLine.SETRANGE(Type, SalesLine.Type::Item);
        SalesLine.SETFILTER("No.", '<>%1', '');

        IF SalesLine.FINDSET(TRUE) THEN BEGIN
            REPEAT
                SalesLine.SuspendStatusCheck(TRUE);

                OrigQtyPer := SalesLine."Qty. per Unit of Measure";

                IF SalesLine."Appl.-to Item Entry" <> 0 then begin
                    ItemLedgEntry.GET(SalesLine."Appl.-to Item Entry");
                    SalesLine.CalcUnitCostExt(ItemLedgEntry);
                end else begin
                    IF SalesLine."Appl.-from Item Entry" <> 0 THEN BEGIN
                        ItemLedgEntry.GET(SalesLine."Appl.-from Item Entry");
                        SalesLine.CalcUnitCostExt(ItemLedgEntry);
                    end else begin
                        SalesLine.GetUnitCost;
                    end;
                end;
                SalesLine."Qty. per Unit of Measure" := OrigQtyPer;
                SalesLine.MODIFY;

            UNTIL SalesLine.NEXT = 0;
            COMMIT;
        END;

    END;
    /// <summary>
    /// UpdateCrMemoRefNoOnBeforeSalseCrMemoInsert.
    /// </summary>
    /// <param name="VAR SalesCrMemoHeader">Record "Sales Cr.Memo Header".</param>
    /// <param name="SalesHeader">Record "Sales Header".</param>
    /// <param name="CommitIsSuppressed">Boolean.</param>
    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforeSalesCrMemoHeaderInsert', '', true, true)]
    procedure UpdateCrMemoRefNoOnBeforeSalseCrMemoInsert(VAR SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean)
    begin
        SalesCrMemoHeader."CM Ref No. ELA" := SalesHeader."No.";
    end;

    /// <summary>
    /// OnPostOnAfterProcessAutoRefund.
    /// </summary>
    /// <param name="SalesHeader">Record "Sales Header".</param>
    /// <param name="VAR IsScheduledPosting">Boolean.</param>
    /// <param name="VAR DocumentIsPosted">Boolean.</param>
    [EventSubscriber(ObjectType::Page, 44, 'OnPostOnAfterSetDocumentIsPosted', '', true, true)]
    procedure OnPostOnAfterProcessAutoRefund(SalesHeader: Record "Sales Header"; VAR IsScheduledPosting: Boolean; VAR DocumentIsPosted: Boolean)
    begin
        IF (SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo") OR (SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order")
        THEN BEGIN
            ProcessAutomaticRefund(SalesHeader);
        End;

    end;

    local procedure ProcessAutomaticRefund(SalesHeader: Record "Sales Header")
    var
        GenJournalLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        lSalesSetup: Record "Sales & Receivables Setup";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        GenJnlBatch: Record "Gen. Journal Batch";
        CustLedgEntry: Record "Cust. Ledger Entry";
        UserSetup: Record "User Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        JLDocumentNo: Code[20];
        Text14228850: Label 'CC Cash Journal Template must have a value on EN Sales Setup Page.';
    begin
        UserSetup.SETFILTER("User ID", USERID);
        IF UserSetup.FINDFIRST THEN;

        IF (SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo") OR
           (SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order") THEN BEGIN
            SalesCrMemoHeader.SETFILTER("CM Ref No. ELA", SalesHeader."No.");
            IF SalesCrMemoHeader.FINDFIRST AND
              PaymentMethod.GET(SalesHeader."Payment Method Code") AND
              PaymentMethod."Automatic Refund ELA"
            THEN BEGIN
                IF lSalesSetup.GET AND (lSalesSetup."C&C Credits Journal Batch" <> '') THEN BEGIN
                    IF (UserSetup.ISEMPTY) OR (UserSetup."CC Journal Template ELA" = '') THEN BEGIN
                        GenJnlBatch.SETFILTER("Journal Template Name", lSalesSetup."C&C Journal Template ELA");
                        GenJnlBatch.SETFILTER(Name, lSalesSetup."C&C Credits Journal Batch");
                    END ELSE BEGIN
                        GenJnlBatch.SETFILTER("Journal Template Name", UserSetup."CC Journal Template ELA");
                        GenJnlBatch.SETFILTER(Name, UserSetup."CC Credit Journal Batch ELA");
                    END;
                    IF GenJnlBatch.FINDFIRST THEN;
                    JLDocumentNo := NoSeriesMgt.GetNextNo(GenJnlBatch."No. Series", SalesHeader."Posting Date", FALSE);
                    IF JLDocumentNo <> '' THEN BEGIN
                        IF (UserSetup.ISEMPTY) OR (UserSetup."CC Journal Template ELA" = '') THEN BEGIN
                            GenJournalLine."Journal Batch Name" := lSalesSetup."C&C Credits Journal Batch";
                            GenJournalLine."Journal Template Name" := lSalesSetup."C&C Journal Template ELA";
                        End ELSE BEGIN
                            GenJournalLine."Journal Batch Name" := UserSetup."CC Credit Journal Batch ELA";
                            GenJournalLine."Journal Template Name" := UserSetup."CC Journal Template ELA";
                        END;
                        GenJournalLine."Line No." := 10000;
                        GenJournalLine."Posting Date" := SalesCrMemoHeader."Posting Date";
                        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Refund;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                        GenJournalLine.VALIDATE("Account No.", SalesHeader."Bill-to Customer No.");
                        GenJournalLine."Sell-to/Buy-from No." := SalesHeader."Sell-to Customer No.";
                        GenJournalLine."Document No." := JLDocumentNo;
                        GenJournalLine."Bal. Account No." := PaymentMethod."Bal. Account No.";
                        CustLedgEntry.SETCURRENTKEY("Customer No.", Open, Positive);
                        CustLedgEntry.SETRANGE("Customer No.", GenJournalLine."Account No.");
                        CustLedgEntry.SETRANGE(Open, TRUE);
                        CustLedgEntry.SETFILTER("Document No.", SalesCrMemoHeader."No.");
                        IF CustLedgEntry.FINDFIRST THEN BEGIN
                            GenJournalLine."Applies-to Doc. Type" := CustLedgEntry."Document Type"::"Credit Memo";
                            GenJournalLine."Applies-to Doc. No." := CustLedgEntry."Document No.";
                            CustLedgEntry.CALCFIELDS("Remaining Amount", "Remaining Amt. (LCY)");
                            GenJournalLine.Amount := CustLedgEntry."Remaining Amount" * -1;
                            GenJournalLine."Document Date" := SalesHeader."Document Date";
                            GenJournalLine."Ship-to/Order Address Code" := SalesCrMemoHeader."Ship-to Code";
                            GenJournalLine."Amount (LCY)" := CustLedgEntry."Remaining Amt. (LCY)" * -1;
                            GenJournalLine."Balance (LCY)" := CustLedgEntry."Remaining Amt. (LCY)" * -1;
                            GenJournalLine."Payment Method Code" := SalesHeader."Payment Method Code";
                            GenJournalLine."Source Code" := CustLedgEntry."Source Code"
                        END;
                    END;
                    GenJournalLine.INSERT;
                    CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post", GenJournalLine);
                END ELSE BEGIN
                    ERROR(Text14228850);
                END;
            END;
        END;

    END;

    /// <summary>
    /// ArchiveSQuoteBeforeReleaseSalesDoc.
    /// </summary>
    /// <param name="VAR SalesHeader">Record "Sales Header".</param>
    /// <param name="PreviewMode">Boolean.</param>
    [EventSubscriber(ObjectType::Codeunit, 414, 'OnBeforeReleaseSalesDoc', '', true, true)]
    procedure ArchiveSQuoteBeforeReleaseSalesDoc(VAR SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    Var
        ENSalesSetup: Record "Sales & Receivables Setup";
        ArchiveManagement: Codeunit ArchiveManagement;
    begin
        IF ENSalesSetup.GET AND ENSalesSetup."Archive S.Quote on Release ELA" AND (SalesHeader."Document Type" = SalesHeader."Document Type"::Quote) then
            ArchiveManagement.ArchSalesDocumentNoConfirm(SalesHeader);
    end;

}