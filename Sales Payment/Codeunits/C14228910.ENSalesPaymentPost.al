codeunit 14228910 "EN Sales Payment-Post"
{
    // ENSP1.00 2020-04-14 HR
    //   Created new Codeunit

    Permissions = TableData "EN Sales Payment Tender Entry" = rimd,
                  TableData "EN Posted Sales Payment Header" = rimd,
                  TableData "EN Posted Sales Payment Line" = rimd;
    TableNo = "EN Sales Payment Header";



    var
        SalesPayment: Record "EN Sales Payment Header";
        SalesInvoice: Record "Sales Header";
        SalesSetup: Record "Sales & Receivables Setup";
        SourceCodeSetup: Record "Source Code Setup";
        LastTenderEntryNo: Integer;
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        UpdateAnalysisView: Codeunit "Update Analysis View";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        StatusWindow: Dialog;
        HideGUI: Boolean;
        Text000: Label 'The Amount has changed on %1 %2.';
        Text001: Label 'The Amount has changed on multiple lines.';
        Text002: Label 'Posting Payment %1...';
        Text003: Label '#1############################\\';
        Text004: Label 'Combining Orders/Fees      #2######';
        Text005: Label 'Posting Payments      #2######';
        Text006: Label 'Posting Applications      #2######';
        Text007: Label 'Sales Payment %1';
        Text008: Label 'Unable to post all payments.';
        Text009: Label 'Unable to authorize credit card.';
        Text010: Label 'Test mode is enabled for the MS Dynamics Online Payment Service.  No payment transaction has been performed.';

    trigger OnRun()
    begin
        InitCodeUnit(Rec);
        TestPayment;
        TestAmounts;
        AssignPostingNo;
        PostPaymentInvoice;
        PostTenderEntries;
        PostPaymentAppls;
        CreatePostedPayment;
    end;

    local procedure InitCodeUnit(var PaymentToPost: Record "EN Sales Payment Header")
    begin
        SalesPayment.Copy(PaymentToPost);
        SalesSetup.Get;
        SourceCodeSetup.Get;
    end;

    local procedure TestPayment()
    var
        SalesPaymentLine: Record "EN Sales Payment Line";
        SalesOrder: Record "Sales Header";
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        SalesPaymentLine.SetRange("Document No.", SalesPayment."No.");
        if SalesPaymentLine.FindSet then
            repeat
                SalesPaymentLine.TestField("Allow Order Changes", false);
                case SalesPaymentLine.Type of
                    SalesPaymentLine.Type::Order:
                        begin
                            SalesPaymentLine.TestField("No.");
                            SalesOrder.Get(SalesOrder."Document Type"::Order, SalesPaymentLine."No.");
                            SalesOrder.TestField(Status, SalesOrder.Status::Released);
                            SalesPaymentLine.TestField("Order Shipment Status", SalesPaymentLine."Order Shipment Status"::Complete);
                        end;
                    SalesPaymentLine.Type::"Open Entry":
                        begin
                            SalesPaymentLine.TestField("No.");
                            SalesPaymentLine.TestField("Entry No.");
                            CustLedgEntry.Get(SalesPaymentLine."Entry No.");
                            CustLedgEntry.TestField(Open, true);
                        end;
                end;
            until (SalesPaymentLine.Next = 0);
    end;

    local procedure TestAmounts()
    var
        SalesPaymentLine: Record "EN Sales Payment Line";
        SalesOrder: Record "Sales Header";
        CustLedgEntry: Record "Cust. Ledger Entry";
        NumAmountChanges: Integer;
        FirstLineChanged: Record "EN Sales Payment Line";
    begin
        SalesPaymentLine.SetRange("Document No.", SalesPayment."No.");
        if SalesPaymentLine.FindSet then
            repeat
                case SalesPaymentLine.Type of
                    SalesPaymentLine.Type::Order:
                        begin
                            SalesOrder.Get(SalesOrder."Document Type"::Order, SalesPaymentLine."No.");
                            SalesOrder.CalcFields("Amount Including VAT");
                            if (SalesPaymentLine.Amount <> SalesOrder."Amount Including VAT") then
                                FixLineAmount(
                                  SalesPaymentLine, SalesOrder."Amount Including VAT", NumAmountChanges, FirstLineChanged);
                        end;
                    SalesPaymentLine.Type::"Open Entry":
                        begin
                            CustLedgEntry.Get(SalesPaymentLine."Entry No.");
                            CustLedgEntry.CalcFields("Remaining Amount");
                            if (SalesPaymentLine.Amount <> CustLedgEntry."Remaining Amount") then
                                FixLineAmount(
                                  SalesPaymentLine, CustLedgEntry."Remaining Amount", NumAmountChanges, FirstLineChanged);
                        end;
                end;
            until (SalesPaymentLine.Next = 0);
        if (NumAmountChanges > 0) then begin
            Commit;
            if (NumAmountChanges = 1) then
                Error(Text000, FirstLineChanged.Type, FirstLineChanged."No.");
            Error(Text001);
        end;
        SalesPayment.CheckBalance;
    end;

    local procedure FixLineAmount(var SalesPaymentLine: Record "EN Sales Payment Line"; NewAmount: Decimal; var NumAmountChanges: Integer; var FirstLineChanged: Record "EN Sales Payment Line")
    begin
        SalesPaymentLine.Amount := NewAmount;
        SalesPaymentLine.UpdateStatus;
        SalesPaymentLine.Modify(true);
        if (NumAmountChanges = 0) then
            FirstLineChanged := SalesPaymentLine;
        NumAmountChanges := NumAmountChanges + 1;
    end;

    local procedure AssignPostingNo()
    begin
        if (SalesPayment."Posting No." = '') then begin
            SalesPayment."Posting No. Series" := SalesSetup."Posted Sales Payment Nos. ELA";
            if (SalesPayment."Posting No. Series" in ['', SalesPayment."No. Series"]) then
                SalesPayment."Posting No." := SalesPayment."No."
            else
                SalesPayment."Posting No." := NoSeriesMgt.GetNextNo(SalesPayment."Posting No. Series", SalesPayment."Posting Date", true);
            SalesPayment.Modify;
            Commit;
        end;
    end;

    local procedure PostPaymentInvoice()
    var
        SalesPost: Codeunit "Sales-Post";
        LastEntryBeforePost: Integer;
    begin
        if not SalesPayment.IsInvoicePosted() then begin
            CreatePaymentInvoice;
            if (SalesInvoice."No." <> '') then begin
                LastEntryBeforePost := GetLastCustEntryNo();
                if not SalesPost.Run(SalesInvoice) then begin
                    SalesInvoice.Find;
                    DeletePaymentInvoice;
                    Commit;
                    Error(GetLastErrorText());
                end;
                SalesPayment."Min. Posting Entry No." := LastEntryBeforePost + 1;
                SalesPayment."Max. Posting Entry No." := GetLastCustEntryNo();
                SalesPayment.Modify;
                Commit;
            end;
        end;
    end;

    local procedure GetLastCustEntryNo(): Integer
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        if CustLedgEntry.FindLast then
            exit(CustLedgEntry."Entry No.");
    end;

    local procedure CreatePaymentInvoice()
    var
        SalesPaymentLine: Record "EN Sales Payment Line";
        LineCount: Integer;
    begin
        if SalesInvoice.Get(SalesInvoice."Document Type"::Invoice, SalesPayment."No.") then
            DeletePaymentInvoice;
        Clear(SalesInvoice);
        SalesPaymentLine.SetRange("Document No.", SalesPayment."No.");
        if SalesPaymentLine.FindSet then begin
            if ShowStatusWindow then begin
                StatusWindow.Open(Text003 + Text004);
                StatusWindow.Update(1, StrSubstNo(Text002, SalesPayment."No."));
            end;
            repeat
                LineCount := LineCount + 1;
                if ShowStatusWindow() then
                    StatusWindow.Update(2, LineCount);
                case SalesPaymentLine.Type of
                    SalesPaymentLine.Type::Order:
                        AddOrderToInvoice(SalesPaymentLine); // P8001133
                end;
            until (SalesPaymentLine.Next = 0);
            if ShowStatusWindow() then
                StatusWindow.Close;
            Commit;
        end;
    end;

    local procedure AddOrderToInvoice(var SalesPaymentLine: Record "EN Sales Payment Line")
    var
        SalesShptHeader: Record "Sales Shipment Header";
        SalesShptLine: Record "Sales Shipment Line";
    begin
        SalesShptHeader.SetCurrentKey("Order No.");
        SalesShptHeader.SetRange("Order No.", SalesPaymentLine."No.");
        if SalesShptHeader.FindSet then
            repeat
                SalesShptLine.SetRange("Document No.", SalesShptHeader."No.");
                if SalesShptLine.FindSet then
                    repeat
                        CreateInvoiceHeader;
                        CreateInvoiceLine(SalesShptLine);
                    until (SalesShptLine.Next = 0);
            until (SalesShptHeader.Next = 0);
    end;

    local procedure CreateInvoiceHeader()
    var
        SalesInvoiceLine: Record "Sales Line";
    begin
        if (SalesInvoice."No." = '') then begin
            SalesInvoiceLine.LockTable;
            SalesInvoice."Document Type" := SalesInvoice."Document Type"::Invoice;
            SalesInvoice."No." := SalesPayment."No.";
            SalesInvoice.Insert(true);
            SalesInvoice.Validate("Sell-to Customer No.", SalesPayment."Customer No.");
            if (SalesInvoice."Bill-to Customer No." <> SalesInvoice."Sell-to Customer No.") then
                SalesInvoice.Validate("Bill-to Customer No.", SalesPayment."Customer No.");
            SalesInvoice.Validate("Payment Method Code", '');
            SalesInvoice.Validate("Posting Date", SalesPayment."Posting Date");
            SalesInvoice.Validate("Document Date", SalesPayment."Posting Date");
            SalesInvoice."Posting No." := SalesPayment."Posting No.";
            SalesInvoice."Posting No. Series" := '';
            if SetApplsForInvoice() then
                SalesInvoice."Applies-to ID" := SalesInvoice."No.";
            SalesInvoice.Modify;
        end;
    end;

    local procedure CreateInvoiceLine(SalesShptLine: Record "Sales Shipment Line")
    var
        SalesInvoiceLine: Record "Sales Line";
    begin
        // P8001133 - remove parameter for TempToLineDim
        if (SalesShptLine.Quantity <> 0) or (SalesShptLine.Type <> SalesShptLine.Type::Item) then begin
            SalesInvoiceLine.SetRange("Document Type", SalesInvoice."Document Type");
            SalesInvoiceLine.SetRange("Document No.", SalesInvoice."No.");
            SalesInvoiceLine."Document Type" := SalesInvoice."Document Type";
            SalesInvoiceLine."Document No." := SalesInvoice."No.";
            SalesShptLine.InsertInvLineFromShptLine(SalesInvoiceLine);
        end;
    end;

    local procedure DeletePaymentInvoice()
    var
        ReserveSalesLine: Codeunit "Sales Line-Reserve";
        SalesInvoiceLine: Record "Sales Line";
    begin
        ReleaseSalesDoc.Reopen(SalesInvoice);
        SalesInvoiceLine.SetRange("Document Type", SalesInvoice."Document Type"::Invoice);
        SalesInvoiceLine.SetRange("Document No.", SalesInvoice."No.");
        if SalesInvoiceLine.FindSet then
            repeat
                ReserveSalesLine.SetDeleteItemTracking(true);
                ReserveSalesLine.DeleteLine(SalesInvoiceLine);
                SalesInvoiceLine.Delete(true);
            until (SalesInvoiceLine.Next = 0);
        SalesInvoice.Find;
        SalesInvoice."Posting No." := '';
        SalesInvoice.Delete(true);
    end;

    local procedure SetApplsForInvoice() ApplyToEntriesFound: Boolean
    var
        SalesTenderEntry: Record "EN Sales Payment Tender Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        SalesTenderEntry.SetCurrentKey("Document No.", "Payment Method Code", "Card/Check No.");
        SalesTenderEntry.SetRange("Document No.", SalesPayment."No.");
        SalesTenderEntry.SetFilter("Cust. Ledger Entry No.", '<>0');
        if SalesTenderEntry.FindSet then
            repeat
                CustLedgEntry.Get(SalesTenderEntry."Cust. Ledger Entry No.");
                if SetEntryApplID(CustLedgEntry, false) then
                    ApplyToEntriesFound := true;
            until (SalesTenderEntry.Next = 0);
    end;

    local procedure PostTenderEntries()
    var
        SalesTenderEntry: Record "EN Sales Payment Tender Entry";
        PaymentMethod: Record "Payment Method";
        LineCount: Integer;
        PaymentsFailed: Boolean;
    begin
        SalesTenderEntry.SetCurrentKey("Document No.");
        SalesTenderEntry.SetRange("Document No.", SalesPayment."No.");
        SalesTenderEntry.SetRange("Cust. Ledger Entry No.", 0);
        SalesTenderEntry.SetRange("Voided by Entry No.", 0);
        SalesTenderEntry.SetFilter(Type, '<>%1', SalesTenderEntry.Type::Void);
        if SalesTenderEntry.FindSet then begin
            if ShowStatusWindow() then begin
                StatusWindow.Open(Text003 + Text005);
                StatusWindow.Update(1, StrSubstNo(Text002, SalesPayment."No."));
            end;
            repeat
                LineCount := LineCount + 1;
                if ShowStatusWindow() then
                    StatusWindow.Update(2, LineCount);
                PaymentMethod.Get(SalesTenderEntry."Payment Method Code");
                Clear(GenJnlPostLine);
                PostFromTenderEntry(PaymentMethod, SalesTenderEntry);
                Commit;
                if (SalesTenderEntry.Result <> SalesTenderEntry.Result::Posted) then
                    PaymentsFailed := true;
            until (SalesTenderEntry.Next = 0);
            if SalesPayment.UpdateStatus() then
                SalesPayment.Modify(true);
            Commit;
            if ShowStatusWindow() then
                StatusWindow.Close;
            if PaymentsFailed then
                Error(Text008);
        end;
    end;

    local procedure PostFromTenderEntry(var PaymentMethod: Record "Payment Method"; var SalesTenderEntry: Record "EN Sales Payment Tender Entry")
    var
        GenJnlLine: Record "Gen. Journal Line";
        CaptureFailed: Boolean;
        ApplyToEntriesFound: Boolean;
    begin
        GenJnlLine.Validate("Posting Date", SalesPayment."Posting Date");
        if (SalesTenderEntry.Type = SalesTenderEntry.Type::Payment) then
            GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Payment)
        else
            GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::" ");
        GenJnlLine.Validate("Document No.", SalesPayment."Posting No.");
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::Customer);
        GenJnlLine.Validate("Account No.", SalesPayment."Customer No.");
        GenJnlLine.Validate(Description, StrSubstNo(Text007, SalesPayment."No."));
        GenJnlLine.Validate(Amount, -SalesTenderEntry.Amount);
        case PaymentMethod."Bal. Account Type" of
            PaymentMethod."Bal. Account Type"::"G/L Account":
                GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
            PaymentMethod."Bal. Account Type"::"Bank Account":
                GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"Bank Account");
        end;
        GenJnlLine.Validate("Bal. Account No.", PaymentMethod."Bal. Account No.");
        if (SalesTenderEntry.Type = SalesTenderEntry.Type::Payment) then
            ApplyToEntriesFound := SetInvoiceAppls()
        else
            ApplyToEntriesFound := SetTenderAppls(SalesTenderEntry);
        if ApplyToEntriesFound then
            GenJnlLine."Applies-to ID" := SalesPayment."No.";
        GenJnlLine."Source Code" := SourceCodeSetup.Sales;

        GenJnlPostLine.RunWithCheck(GenJnlLine);

        FinishPaymentPosting(SalesTenderEntry);
    end;

    local procedure FinishPaymentPosting(var SalesTenderEntry: Record "EN Sales Payment Tender Entry")
    begin
        SalesTenderEntry."Cust. Ledger Entry No." := GetLastCustEntryNo();
        SalesTenderEntry.Result := SalesTenderEntry.Result::Posted;
        SalesTenderEntry.Modify;
    end;

    local procedure SetInvoiceAppls() ApplyToEntriesFound: Boolean
    var
        SalesTenderEntry: Record "EN Sales Payment Tender Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        if SalesPayment.InvoiceEntriesExist(CustLedgEntry) then
            repeat
                if SetEntryApplID(CustLedgEntry, true) then
                    ApplyToEntriesFound := true;
            until (CustLedgEntry.Next = 0);
        SalesTenderEntry.SetCurrentKey("Document No.", "Payment Method Code", "Card/Check No.");
        SalesTenderEntry.SetRange("Document No.", SalesPayment."No.");
        SalesTenderEntry.SetFilter("Cust. Ledger Entry No.", '<>0');
        if SalesTenderEntry.FindSet then
            repeat
                CustLedgEntry.Get(SalesTenderEntry."Cust. Ledger Entry No.");
                if SetEntryApplID(CustLedgEntry, true) then
                    ApplyToEntriesFound := true;
            until (SalesTenderEntry.Next = 0);
    end;

    local procedure SetTenderAppls(var ApplyingTenderEntry: Record "EN Sales Payment Tender Entry") ApplyToEntriesFound: Boolean
    var
        ApplyingPayment: Boolean;
        SalesTenderEntry: Record "EN Sales Payment Tender Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        ApplyingPayment := (ApplyingTenderEntry.Type = ApplyingTenderEntry.Type::Payment);
        SalesTenderEntry.SetCurrentKey("Document No.", "Payment Method Code", "Card/Check No.");
        SalesTenderEntry.SetRange("Document No.", ApplyingTenderEntry."Document No.");
        SalesTenderEntry.SetRange("Payment Method Code", ApplyingTenderEntry."Payment Method Code");
        SalesTenderEntry.SetRange("Card/Check No.", ApplyingTenderEntry."Card/Check No.");
        SalesTenderEntry.SetFilter("Cust. Ledger Entry No.", '<>0');
        if SalesTenderEntry.FindSet then
            repeat
                CustLedgEntry.Get(SalesTenderEntry."Cust. Ledger Entry No.");
                if SetEntryApplID(CustLedgEntry, ApplyingPayment) then
                    ApplyToEntriesFound := true;
            until (SalesTenderEntry.Next = 0);
    end;

    local procedure SetEntryApplID(var CustLedgEntry: Record "Cust. Ledger Entry"; ApplyingPayment: Boolean): Boolean
    var
        ApplyingLedgEntry: Record "Cust. Ledger Entry";
    begin
        if CustLedgEntry.Open and (CustLedgEntry.Positive = ApplyingPayment) then begin
            SetApplID(CustLedgEntry, ApplyingLedgEntry);
            exit(true);
        end;
    end;

    local procedure SetApplID(var CustLedgEntry: Record "Cust. Ledger Entry"; var ApplyingLedgEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgEntry.SetRecFilter;
        CustLedgEntry.CalcFields("Remaining Amount");
        CustEntrySetApplID.SetApplId(CustLedgEntry, ApplyingLedgEntry, SalesPayment."No.");
    end;

    local procedure PostPaymentAppls()
    var
        TempApplyingEntry: Record "Integer" temporary;
        TempApplyToEntry: Record "Integer" temporary;
        ApplyingLedgEntry: Record "Cust. Ledger Entry";
        ApplyToLedgEntry: Record "Cust. Ledger Entry";
        ApplDate: Date;
        MoreAppls: Boolean;
        CustLedgEntry: Record "Cust. Ledger Entry";
        ApplCount: Integer;
    begin
        InitTempApplEntries(TempApplyingEntry, TempApplyToEntry);
        if GetTempApplEntry(TempApplyingEntry, ApplyingLedgEntry) and
           GetTempApplEntry(TempApplyToEntry, ApplyToLedgEntry)
        then begin
            Clear(GenJnlPostLine);
            if ShowStatusWindow() then begin
                StatusWindow.Open(Text003 + Text006);
                StatusWindow.Update(1, StrSubstNo(Text002, SalesPayment."No."));
            end;
            GetTempMaxApplDate(TempApplyingEntry, ApplyingLedgEntry, ApplDate);
            GetTempMaxApplDate(TempApplyToEntry, ApplyToLedgEntry, ApplDate);
            repeat
                ApplCount := ApplCount + 1;
                if ShowStatusWindow() then
                    StatusWindow.Update(2, ApplCount);
                MoreAppls := GetTempApplEntry(TempApplyToEntry, ApplyToLedgEntry);
                if MoreAppls then begin
                    SetApplID(ApplyingLedgEntry, ApplyingLedgEntry);
                    ApplyingLedgEntry.Find;
                    repeat
                        SetApplID(ApplyToLedgEntry, ApplyingLedgEntry);
                    until not NextTempApplEntry(TempApplyToEntry, ApplyToLedgEntry);
                    Post1Application(ApplyingLedgEntry, ApplDate);
                    ApplyingLedgEntry.Find;
                    if not ApplyingLedgEntry.Open then
                        MoreAppls := NextTempApplEntry(TempApplyingEntry, ApplyingLedgEntry);
                end;
            until not MoreAppls;
            Commit;
            UpdateAnalysisView.UpdateAll(0, true);
            Commit;
            if ShowStatusWindow() then
                StatusWindow.Close;
        end;
    end;

    local procedure InitTempApplEntries(var TempApplyingEntry: Record "Integer" temporary; var TempApplyToEntry: Record "Integer" temporary)
    var
        SalesPaymentLine: Record "EN Sales Payment Line";
        CustLedgEntry: Record "Cust. Ledger Entry";
        SalesTenderEntry: Record "EN Sales Payment Tender Entry";
    begin
        TempApplyingEntry.DeleteAll;
        TempApplyToEntry.DeleteAll;
        SalesPaymentLine.SetRange("Document No.", SalesPayment."No.");
        SalesPaymentLine.SetRange(Type, SalesPaymentLine.Type::"Open Entry");
        if SalesPaymentLine.FindSet then
            repeat
                CustLedgEntry.Get(SalesPaymentLine."Entry No.");
                AddTempApplEntry(TempApplyingEntry, TempApplyToEntry, CustLedgEntry);
            until (SalesPaymentLine.Next = 0);
        SalesTenderEntry.SetCurrentKey("Document No.");
        SalesTenderEntry.SetRange("Document No.", SalesPayment."No.");
        SalesTenderEntry.SetFilter("Cust. Ledger Entry No.", '<>0');
        if SalesTenderEntry.FindSet then
            repeat
                CustLedgEntry.Get(SalesTenderEntry."Cust. Ledger Entry No.");
                AddTempApplEntry(TempApplyingEntry, TempApplyToEntry, CustLedgEntry);
            until (SalesTenderEntry.Next = 0);
        if SalesPayment.InvoiceEntriesExist(CustLedgEntry) then
            repeat
                AddTempApplEntry(TempApplyingEntry, TempApplyToEntry, CustLedgEntry);
            until (SalesPayment.Next = 0);
    end;

    local procedure AddTempApplEntry(var TempApplyingEntry: Record "Integer" temporary; var TempApplyToEntry: Record "Integer" temporary; var CustLedgEntry: Record "Cust. Ledger Entry")
    begin
        if CustLedgEntry.Open then
            if CustLedgEntry.Positive then begin
                TempApplyToEntry.Number := CustLedgEntry."Entry No.";
                TempApplyToEntry.Insert;
            end else begin
                TempApplyingEntry.Number := CustLedgEntry."Entry No.";
                TempApplyingEntry.Insert;
            end;
    end;

    local procedure GetTempApplEntry(var TempEntry: Record "Integer" temporary; var CustLedgEntry: Record "Cust. Ledger Entry"): Boolean
    begin
        if TempEntry.FindSet then
            repeat
                CustLedgEntry.Get(TempEntry.Number);
                if CustLedgEntry.Open then
                    exit(true);
            until (TempEntry.Next = 0);
    end;

    local procedure NextTempApplEntry(var TempEntry: Record "Integer" temporary; var CustLedgEntry: Record "Cust. Ledger Entry"): Boolean
    begin
        while (TempEntry.Next <> 0) do begin
            CustLedgEntry.Get(TempEntry.Number);
            if CustLedgEntry.Open then
                exit(true);
        end;
    end;

    local procedure GetTempMaxApplDate(var TempEntry: Record "Integer" temporary; var CustLedgEntry: Record "Cust. Ledger Entry"; var ApplDate: Date): Boolean
    begin
        repeat
            if (CustLedgEntry."Posting Date" > ApplDate) then
                ApplDate := CustLedgEntry."Posting Date";
        until not NextTempApplEntry(TempEntry, CustLedgEntry);
        GetTempApplEntry(TempEntry, CustLedgEntry);
    end;

    local procedure Post1Application(var ApplyingLedgEntry: Record "Cust. Ledger Entry"; ApplDate: Date)
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine."Document No." := SalesPayment."Posting No.";
        GenJnlLine."Posting Date" := ApplDate;
        GenJnlLine."Document Date" := ApplDate;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine."Account No." := ApplyingLedgEntry."Customer No.";
        ApplyingLedgEntry.CalcFields("Debit Amount", "Credit Amount", "Debit Amount (LCY)", "Credit Amount (LCY)");
        GenJnlLine.Correction :=
            (ApplyingLedgEntry."Debit Amount" < 0) or (ApplyingLedgEntry."Credit Amount" < 0) or
            (ApplyingLedgEntry."Debit Amount (LCY)" < 0) or (ApplyingLedgEntry."Credit Amount (LCY)" < 0);
        GenJnlLine."Document Type" := ApplyingLedgEntry."Document Type";
        GenJnlLine.Description := ApplyingLedgEntry.Description;
        GenJnlLine."Shortcut Dimension 1 Code" := ApplyingLedgEntry."Global Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := ApplyingLedgEntry."Global Dimension 2 Code";
        GenJnlLine."Dimension Set ID" := ApplyingLedgEntry."Dimension Set ID"; // P8001133
        GenJnlLine."Posting Group" := ApplyingLedgEntry."Customer Posting Group";
        GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
        GenJnlLine."Source No." := ApplyingLedgEntry."Customer No.";
        GenJnlLine."Source Code" := SourceCodeSetup.Sales;
        GenJnlLine."System-Created Entry" := true;

        GenJnlPostLine.CustPostApplyCustLedgEntry(GenJnlLine, ApplyingLedgEntry);
    end;

    procedure CreatePostedPayment()
    var
        SalesPaymentLine: Record "EN Sales Payment Line";
        PstdSalesPayment: Record "EN Posted Sales Payment Header";
        PstdSalesPaymentLine: Record "EN Posted Sales Payment Line";
        SalesTenderEntry: Record "EN Sales Payment Tender Entry";
        SalesTenderEntry2: Record "EN Sales Payment Tender Entry";
    begin
        PstdSalesPayment.TransferFields(SalesPayment);
        PstdSalesPayment."No." := SalesPayment."Posting No.";
        PstdSalesPayment."Sales Payment No." := SalesPayment."No.";
        PstdSalesPayment.Insert;
        PstdSalesPayment.CopyLinks(SalesPayment);
        SalesPaymentLine.SetRange("Document No.", SalesPayment."No.");
        if SalesPaymentLine.FindSet then
            repeat
                PstdSalesPaymentLine.TransferFields(SalesPaymentLine);
                PstdSalesPaymentLine."Document No." := PstdSalesPayment."No.";
                PstdSalesPaymentLine.Insert;
                SalesPaymentLine.Delete;
                if (SalesPaymentLine.Type = SalesPaymentLine.Type::Order) then
                    DeletePaymentOrder(SalesPaymentLine."No.");
            until (SalesPaymentLine.Next = 0);
        if (PstdSalesPayment."No." <> SalesPayment."No.") then
            SalesTenderEntry.SetCurrentKey("Document No.");
        SalesTenderEntry.SetRange("Document No.", SalesPayment."No.");
        if SalesTenderEntry.FindSet then
            repeat
                SalesTenderEntry2 := SalesTenderEntry;
                SalesTenderEntry2."Document No." := PstdSalesPayment."No.";
                SalesTenderEntry2.Modify;
            until (SalesTenderEntry.Next = 0);
        if SalesPayment.HasLinks then
            SalesPayment.DeleteLinks;
        SalesPayment.Delete;
        Commit;
    end;

    local procedure DeletePaymentOrder(SalesOrderNo: Code[20]): Boolean
    var
        SalesOrder: Record "Sales Header";
    begin
        if SalesOrder.Get(SalesOrder."Document Type"::Order, SalesOrderNo) then begin
            ReleaseSalesDoc.Reopen(SalesOrder);
            exit(SalesOrder.Delete(true));
        end;
    end;


    procedure PostCashTender(var SalesPaymentHeader: Record "EN Sales Payment Header"; var PaymentMethod: Record "Payment Method"; PaymentAmount: Decimal)
    var
        SalesTenderEntry: Record "EN Sales Payment Tender Entry";
    begin
        InitCodeUnit(SalesPaymentHeader);
        CheckPaymentMethod(PaymentMethod, true);
        AssignPostingNo;
        InsertTenderEntry(PaymentMethod, '', PaymentAmount);
        SalesTenderEntry.FindLast;
        PostFromTenderEntry(PaymentMethod, SalesTenderEntry);
        if SalesPayment.UpdateStatus() then
            SalesPayment.Modify(true);
        Commit;
    end;


    procedure AuthorizeNonCashTender(var SalesPaymentHeader: Record "EN Sales Payment Header"; var PaymentMethod: Record "Payment Method"; CardCheckNo: Code[20]; PaymentAmount: Decimal)
    var
        PrevTenderEntry: Record "EN Sales Payment Tender Entry";
        SalesTenderEntry: Record "EN Sales Payment Tender Entry";
        AuthorizedAmount: Decimal;
    begin
        InitCodeUnit(SalesPaymentHeader);
        CheckPaymentMethod(PaymentMethod, false);
        AssignPostingNo;
        if PrevTenderEntry.FindPending(SalesPayment."No.", PaymentMethod.Code, CardCheckNo) then begin
            if (GetAuthorizedAmount(PrevTenderEntry) < PaymentAmount) then
                VoidTenderEntry(PrevTenderEntry)
            else
                VoidTenderEntry(PrevTenderEntry);
            if SalesPayment.UpdateStatus() then
                SalesPayment.Modify(true);
            Commit;
        end;
        InsertTenderEntry(PaymentMethod, CardCheckNo, PaymentAmount);
        if SalesPayment.UpdateStatus() then
            SalesPayment.Modify(true);
        Commit;
    end;

    local procedure GetAuthorizedAmount(var SalesTenderEntry: Record "EN Sales Payment Tender Entry"): Decimal
    begin
        if (SalesTenderEntry."Authorization Entry No." = 0) then
            exit(SalesTenderEntry.Amount);
    end;


    procedure VoidNonCashTender(var SalesPaymentHeader: Record "EN Sales Payment Header"; var PaymentMethod: Record "Payment Method"; CardCheckNo: Code[20]; PaymentAmount: Decimal)
    var
        PrevTenderEntry: Record "EN Sales Payment Tender Entry";
    begin
        InitCodeUnit(SalesPaymentHeader);
        CheckPaymentMethod(PaymentMethod, false);
        AssignPostingNo;
        PrevTenderEntry.FindPending(SalesPayment."No.", PaymentMethod.Code, CardCheckNo);
        VoidTenderEntry(PrevTenderEntry);
        if SalesPayment.UpdateStatus() then
            SalesPayment.Modify(true);
        Commit;
    end;

    local procedure CheckPaymentMethod(var PaymentMethod: Record "Payment Method"; IsCash: Boolean)
    begin
        PaymentMethod.TestField(PaymentMethod."Cash Tender Method ELA", IsCash);
        PaymentMethod.TestField(PaymentMethod."Bal. Account No.");
    end;

    local procedure GetNextTenderEntryNo(): Integer
    var
        LastSalesTenderEntry: Record "EN Sales Payment Tender Entry";
    begin
        if (LastTenderEntryNo = 0) then
            if LastSalesTenderEntry.FindLast then
                LastTenderEntryNo := LastSalesTenderEntry."Entry No.";
        LastTenderEntryNo := LastTenderEntryNo + 1;
        exit(LastTenderEntryNo);
    end;

    local procedure InsertTenderEntry(var PaymentMethod: Record "Payment Method"; CardCheckNo: Code[20]; PaymentAmount: Decimal)
    var
        SalesTenderEntry: Record "EN Sales Payment Tender Entry";
    begin
        SalesTenderEntry.Init;
        SalesTenderEntry."Entry No." := GetNextTenderEntryNo();
        SalesTenderEntry."Document No." := SalesPayment."No.";
        SalesTenderEntry."Customer No." := SalesPayment."Customer No.";
        SalesTenderEntry."Payment Method Code" := PaymentMethod.Code;
        SalesTenderEntry."Card/Check No." := CardCheckNo;
        SalesTenderEntry.Description := PaymentMethod.Description;
        if (PaymentAmount > 0) then
            SalesTenderEntry.Type := SalesTenderEntry.Type::Payment
        else
            SalesTenderEntry.Type := SalesTenderEntry.Type::Refund;
        SalesTenderEntry.Amount := PaymentAmount;
        SalesTenderEntry.Insert;

    end;

    local procedure VoidTenderEntry(var PrevTenderEntry: Record "EN Sales Payment Tender Entry")
    var
        VoidEntry: Record "EN Sales Payment Tender Entry";
    begin
        VoidEntry := PrevTenderEntry;
        VoidEntry."Entry No." := GetNextTenderEntryNo();
        VoidEntry.Type := VoidEntry.Type::Void;
        VoidEntry.Amount := -VoidEntry.Amount;
        VoidEntry.Result := VoidEntry.Result::" ";
        VoidEntry.Insert;
        begin
            PrevTenderEntry."Voided by Entry No." := VoidEntry."Entry No.";
            PrevTenderEntry.Result := PrevTenderEntry.Result::Voided;
            PrevTenderEntry.Modify;
        end;
    end;

    local procedure FailTenderEntry(var SalesTenderEntry: Record "EN Sales Payment Tender Entry")
    var
        VoidEntry: Record "EN Sales Payment Tender Entry";
    begin
        VoidEntry := SalesTenderEntry;
        VoidEntry."Entry No." := GetNextTenderEntryNo();
        VoidEntry.Type := VoidEntry.Type::Void;
        VoidEntry.Amount := -VoidEntry.Amount;
        VoidEntry.Result := VoidEntry.Result::" ";
        VoidEntry.Insert;
        begin
            SalesTenderEntry."Voided by Entry No." := VoidEntry."Entry No.";
            SalesTenderEntry.Modify;
        end;
    end;


    procedure SetHideGUI(NewHideGUI: Boolean)
    begin
        HideGUI := NewHideGUI;
    end;

    local procedure ShowStatusWindow(): Boolean
    begin
        exit(GuiAllowed and (not HideGUI));
    end;


    procedure PrintAfterPosting(var SalesPayment2: Record "EN Sales Payment Header")
    var
        PostedSalesPayment: Record "EN Posted Sales Payment Header";
    begin
        PostedSalesPayment."No." := SalesPayment2."Posting No.";
        PostedSalesPayment.SetRecFilter;
        REPORT.Run(REPORT::"EN Sales Payment - Posted", false, false, PostedSalesPayment);
    end;
}

