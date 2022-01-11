table 14228823 "Bank Deposit Wksht Entry ELA"
{
    DrillDownPageID = "Bank Deposit Worksheet ELA";
    LookupPageID = "Bank Deposit Worksheet ELA";

    fields
    {
        field(10; "Bank Deposit Batch Name"; Code[10])
        {
            TableRelation = "Bank Deposit Wksht Batch ELA".Name;
        }
        field(20; "Line No."; Integer)
        {
        }
        field(25; "Entry Type"; Option)
        {
            OptionCaption = 'Payment,Adjustment';
            OptionMembers = Payment,Adjustment;
        }
        field(30; "Posting Date"; Date)
        {
        }
        field(31; "Sell-To Customer No."; Code[20])
        {
            Editable = false;
            TableRelation = Customer."No.";
        }
        field(40; "Bill-To Customer No."; Code[20])
        {
            TableRelation = Customer."No.";

            trigger OnValidate()
            begin
                if "Bill-To Customer No." <> xRec."Bill-To Customer No." then begin
                    Clear("Applies-To Document Type");
                    Validate("Applies-To Document No.", '');
                end;

                jfCalcfields;
            end;
        }
        field(50; "Ship-To Code"; Code[20])
        {
            Editable = false;
            TableRelation = "Ship-to Address"."Customer No." WHERE("Customer No." = FIELD("Sell-To Customer No."));
        }
        field(60; "Applies-To Document Type"; Option)
        {
            OptionCaption = ' ,Invoice,Credit Memo';
            OptionMembers = " ",Invoice,"Credit Memo";

            trigger OnValidate()
            begin
                if "Applies-To Document Type" <> xRec."Applies-To Document Type" then
                    Validate("Applies-To Document No.", '');
            end;
        }
        field(70; "Applies-To Document No."; Code[20])
        {

            trigger OnLookup()
            begin
                TestField("Applies-To Document Type");

                CustLedgEntry.SetCurrentKey("Customer No.", Open, Positive, "Due Date");

                CustLedgEntry.FilterGroup(10);
                if "Bill-To Customer No." <> '' then
                    CustLedgEntry.SetRange("Customer No.", "Bill-To Customer No.")
                else
                    CustLedgEntry.SetRange("Customer No.");
                CustLedgEntry.SetRange(Open, true);

                case "Applies-To Document Type" of
                    "Applies-To Document Type"::Invoice:
                        begin
                            CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
                        end;
                    "Applies-To Document Type"::"Credit Memo":
                        begin
                            CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::"Credit Memo");
                        end;
                end;

                CustLedgEntry.FilterGroup(0);

                if PAGE.RunModal(PAGE::"Customer Ledger Entries", CustLedgEntry) = ACTION::LookupOK then begin
                    Validate("Applies-To Document No.", CustLedgEntry."Document No.");
                end;
            end;

            trigger OnValidate()
            begin
                if "Applies-To Document No." <> '' then begin
                    TestField("Applies-To Document Type");
                end;

                jfGetCustLedger;
                jfGetAppliesToDocInfo;
                jfCalcfields;
            end;
        }
        field(80; "Applies-To Cust. Ledger No."; Integer)
        {
            Editable = false;
        }
        field(90; "Amount To Apply"; Decimal)
        {
        }
        field(100; "Reason Code"; Code[10])
        {
            TableRelation = "Reason Code".Code;
        }
        field(110; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(120; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Cust. Ledg. Entry".Amount WHERE("Entry Type" = FILTER("Initial Entry" | "Unrealized Loss" | "Unrealized Gain" | "Realized Loss" | "Realized Gain" | "Payment Discount" | "Payment Discount (VAT Excl.)" | "Payment Discount (VAT Adjustment)" | "Payment Tolerance" | "Payment Discount Tolerance" | "Payment Tolerance (VAT Excl.)" | "Payment Tolerance (VAT Adjustment)" | "Payment Discount Tolerance (VAT Excl.)" | "Payment Discount Tolerance (VAT Adjustment)"),
                                                                         "Cust. Ledger Entry No." = FIELD("Applies-To Cust. Ledger No.")));
            Caption = 'Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(130; "Remaining Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Cust. Ledg. Entry".Amount WHERE("Cust. Ledger Entry No." = FIELD("Applies-To Cust. Ledger No.")));
            Caption = 'Remaining Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(140; "Due Date"; Date)
        {
            Caption = 'Due Date';
            Editable = false;

            trigger OnValidate()
            var
                ReminderEntry: Record "Reminder/Fin. Charge Entry";
            begin
            end;
        }
        field(150; "Pmt. Discount Date"; Date)
        {
            Caption = 'Pmt. Discount Date';
            Editable = false;
        }
        field(160; "Original Pmt. Disc. Possible"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Original Pmt. Disc. Possible';
            Editable = false;
        }
        field(170; "Original Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Cust. Ledg. Entry".Amount WHERE("Cust. Ledger Entry No." = FIELD("Applies-To Cust. Ledger No."),
                                                                         "Entry Type" = FILTER("Initial Entry")));
            Caption = 'Original Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(180; "Remaining Pmt. Disc. Possible"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Remaining Pmt. Disc. Possible';
            Editable = false;
        }
        field(190; "Pmt. Disc. Tolerance Date"; Date)
        {
            Caption = 'Pmt. Disc. Tolerance Date';
            Editable = false;
        }
        field(200; "Max. Payment Tolerance"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Max. Payment Tolerance';
            Editable = false;
        }
        field(210; "Check No."; Code[20])
        {
            Caption = 'Check No.';
        }
        field(215; "Check Total Amount"; Decimal)
        {

            trigger OnValidate()
            begin
                Validate("Amount To Apply", "Check Total Amount");
            end;
        }
        field(220; "Reference No."; Code[20])
        {
        }
        field(230; "Deposit Batch No."; Code[20])
        {
        }
        field(10000; "EDI Internal Doc. No."; Code[10])
        {
            Caption = 'EDI Internal Doc. No.';
            Editable = false;
        }
        field(10010; "EDI Trade Partner"; Code[20])
        {
            Caption = 'EDI Trade Partner';
        }
        field(10020; "EDI Bill-To Customer No."; Code[20])
        {
            TableRelation = Customer;
        }
        field(10040; "EDI Applies-To Document No."; Code[20])
        {

            trigger OnValidate()
            begin
                //-- Try to find an open invoice first and then try a credit memo
                "Applies-To Document Type" := "Applies-To Document Type"::Invoice;
                "Applies-To Document No." := "EDI Applies-To Document No.";

                if jfGetCustLedger then begin
                    Validate("Applies-To Document No.");
                end else begin
                    //-- Try Credit Memo
                    "Applies-To Document Type" := "Applies-To Document Type"::"Credit Memo";

                    if jfGetCustLedger then begin
                        Validate("Applies-To Document No.");
                    end else begin
                        //-- no valid document found
                        Clear("Applies-To Document Type");
                        Clear("Applies-To Document No.");
                    end;
                end;
            end;
        }
        field(10041; "EDI Reason Code"; Code[20])
        {

            trigger OnValidate()
            begin
                // if "EDI Reason Code" <> '' then begin
                //     gcduJXEDI.jfGetReasonNavCode("EDI Trade Partner", "EDI Reason Code", "Reason Code");
                // end else begin
                //     "Reason Code" := '';
                // end;
            end;
        }
    }

    keys
    {
        key(Key1; "Bank Deposit Batch Name", "Line No.")
        {
            Clustered = true;
            SumIndexFields = "Amount To Apply";
        }
        key(Key2; "EDI Internal Doc. No.")
        {
            Enabled = false;
        }
    }

    fieldgroups
    {
    }

    var
        grecDepBatch: Record "Bank Deposit Wksht Batch ELA";
        grecDepWorksheetLine: Record "Bank Deposit Wksht Entry ELA";
        gcduNoSeriesMgmt: Codeunit NoSeriesManagement;
        jfText000: Label 'DEFAULT';
        jfText001: Label 'Default Journal';
        //EDIIntegration: Codeunit Codeunit14000363;
        //gcduJXEDI: Codeunit Codeunit23019005;
        CustLedgEntry: Record "Cust. Ledger Entry";

    [Scope('Internal')]
    procedure OpenJnl(var CurrentBatchName: Code[10]; var CurrentBankName: Text[30]; var BankDepWkshtLine: Record "Bank Deposit Wksht Entry ELA")
    begin
        CheckBatch(CurrentBatchName, CurrentBankName);
        BankDepWkshtLine.FilterGroup := 2;
        BankDepWkshtLine.SetRange("Bank Deposit Batch Name", CurrentBatchName);
        BankDepWkshtLine.FilterGroup := 0;
    end;

    [Scope('Internal')]
    procedure CheckName(CurrentBatchName: Code[10]; var CurrentBankAcctName: Text[30]; var BankDepWkshtLine: Record "Bank Deposit Wksht Entry ELA")
    var
        lrecBankAcct: Record "Bank Account";
    begin
        grecDepBatch.Get(CurrentBatchName);

        if lrecBankAcct.Get(grecDepBatch."Bank Account No.") then
            CurrentBankAcctName := lrecBankAcct.Name;
    end;

    [Scope('Internal')]
    procedure CheckBatch(var CurrentBatchName: Code[10]; var CurrentBankAcctName: Text[30])
    var
        lrecBankAcct: Record "Bank Account";
    begin
        CurrentBankAcctName := '';

        if not grecDepBatch.Get(CurrentBatchName) then begin
            grecDepBatch.Init;

            grecDepBatch.Name := jfText000;
            grecDepBatch.Description := jfText001;

            if grecDepBatch.Insert(true) then begin
                Commit;
            end else begin
                grecDepBatch.Get(grecDepBatch.Name);

                if lrecBankAcct.Get(grecDepBatch."Bank Account No.") then
                    CurrentBankAcctName := lrecBankAcct.Name;
            end;

            CurrentBatchName := grecDepBatch.Name
        end else begin
            if lrecBankAcct.Get(grecDepBatch."Bank Account No.") then
                CurrentBankAcctName := lrecBankAcct.Name;
        end;
    end;

    [Scope('Internal')]
    procedure SetName(CurrentBatchName: Code[10]; var BankDepWkshtLine: Record "Bank Deposit Wksht Entry ELA")
    begin
        BankDepWkshtLine.FilterGroup := 2;
        BankDepWkshtLine.SetRange("Bank Deposit Batch Name", CurrentBatchName);
        BankDepWkshtLine.FilterGroup := 0;
        if BankDepWkshtLine.Find('-') then;
    end;

    [Scope('Internal')]
    procedure LookupName(var CurrentBatchName: Code[10]; var CurrentBankAcctName: Text[30]; var BankDepWkshtLine: Record "Bank Deposit Wksht Entry ELA"): Boolean
    var
        BankDepBatch: Record "Bank Deposit Wksht Batch ELA";
        lrecBankAcct: Record "Bank Account";
    begin
        Commit;

        BankDepBatch.Name := BankDepWkshtLine.GetRangeMax("Bank Deposit Batch Name");

        if PAGE.RunModal(0, BankDepBatch) = ACTION::LookupOK then begin
            CurrentBatchName := BankDepBatch.Name;

            CurrentBankAcctName := '';

            if lrecBankAcct.Get(BankDepBatch."Bank Account No.") then
                CurrentBankAcctName := lrecBankAcct.Name;

            SetName(CurrentBatchName, BankDepWkshtLine);
        end;
    end;

    [Scope('Internal')]
    procedure SetUpNewLine(LastBankDepWkshtLine: Record "Bank Deposit Wksht Entry ELA")
    begin
        if grecDepBatch.Get("Bank Deposit Batch Name") then;

        grecDepWorksheetLine.SetRange("Bank Deposit Batch Name", "Bank Deposit Batch Name");

        if grecDepWorksheetLine.FindFirst then begin
            "Posting Date" := LastBankDepWkshtLine."Posting Date";
        end else begin
            "Posting Date" := WorkDate;
        end;
    end;

    [Scope('Internal')]
    procedure jfCalcfields()
    begin
        CalcFields(Amount, "Remaining Amount");
    end;

    [Scope('Internal')]
    procedure jfGetCustLedger(): Boolean
    var
        ldecAmountToApply: Decimal;
        ldecRemAmount: Decimal;
    begin
        "Currency Code" := '';
        "Due Date" := 0D;
        "Pmt. Discount Date" := 0D;
        "Original Pmt. Disc. Possible" := 0;
        "Remaining Pmt. Disc. Possible" := 0;
        "Pmt. Disc. Tolerance Date" := 0D;
        "Max. Payment Tolerance" := 0;
        "Applies-To Cust. Ledger No." := 0;
        "Original Amount" := 0;
        "Amount To Apply" := 0;

        if "Applies-To Document No." <> '' then begin
            CustLedgEntry.SetCurrentKey("Customer No.", Open, Positive, "Due Date");

            if "Bill-To Customer No." <> '' then
                CustLedgEntry.SetRange("Customer No.", "Bill-To Customer No.")
            else
                CustLedgEntry.SetRange("Customer No.");

            CustLedgEntry.SetRange(Open, true);

            case "Applies-To Document Type" of
                "Applies-To Document Type"::Invoice:
                    begin
                        CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
                    end;
                "Applies-To Document Type"::"Credit Memo":
                    begin
                        CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::"Credit Memo");
                    end;
            end;

            CustLedgEntry.SetRange("Document No.", "Applies-To Document No.");

            if CustLedgEntry.FindFirst then begin
                "Currency Code" := CustLedgEntry."Currency Code";
                "Due Date" := CustLedgEntry."Due Date";
                "Pmt. Discount Date" := CustLedgEntry."Pmt. Discount Date";
                "Original Pmt. Disc. Possible" := CustLedgEntry."Original Pmt. Disc. Possible";
                "Remaining Pmt. Disc. Possible" := CustLedgEntry."Remaining Pmt. Disc. Possible";
                "Pmt. Disc. Tolerance Date" := CustLedgEntry."Pmt. Disc. Tolerance Date";
                "Max. Payment Tolerance" := CustLedgEntry."Max. Payment Tolerance";
                "Original Amount" := CustLedgEntry."Original Amount";
                "Bill-To Customer No." := CustLedgEntry."Customer No.";
                "Applies-To Cust. Ledger No." := CustLedgEntry."Entry No.";

                CustLedgEntry.CalcFields("Remaining Amount");

                ldecRemAmount := CustLedgEntry."Remaining Amount";

                if "Posting Date" <= CustLedgEntry."Pmt. Disc. Tolerance Date" then
                    ldecRemAmount -= CustLedgEntry."Remaining Pmt. Disc. Possible";

                if "Check Total Amount" < ldecAmountToApply then begin
                    ldecAmountToApply := "Check Total Amount";
                end else begin
                    ldecAmountToApply := ldecRemAmount;
                end;

                Validate("Amount To Apply", ldecAmountToApply);

                exit(true);
            end;
        end;

        exit(false);
    end;

    [Scope('Internal')]
    procedure jfGetAppliesToDocInfo()
    var
        lrecSalesInvHeader: Record "Sales Invoice Header";
        lrecSalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        "Sell-To Customer No." := '';
        "Ship-To Code" := '';

        case "Applies-To Document Type" of
            "Applies-To Document Type"::Invoice:
                begin
                    if lrecSalesInvHeader.Get("Applies-To Document No.") then begin
                        "Sell-To Customer No." := lrecSalesInvHeader."Sell-to Customer No.";
                        "Ship-To Code" := lrecSalesInvHeader."Ship-to Code";
                    end;
                end;
            "Applies-To Document Type"::"Credit Memo":
                begin
                    if lrecSalesCrMemoHeader.Get("Applies-To Document No.") then begin
                        "Sell-To Customer No." := lrecSalesCrMemoHeader."Sell-to Customer No.";
                        "Ship-To Code" := lrecSalesCrMemoHeader."Ship-to Code";
                    end;
                end;
        end;
    end;

    [Scope('Internal')]
    procedure jfCreateBankDeposit(var precBankDepositWksht: Record "Bank Deposit Wksht Entry ELA"): Code[20]
    var
        lrecBankDepBatch: Record "Bank Deposit Wksht Batch ELA";
        lrecDepositHeader: Record "Deposit Header";
        lrecDepositLine: Record "Gen. Journal Line";
        ljfText000: Label 'A %1 already exists for Journal Template %2, Batch %3. You must post or delete it before continuing.';
        lrecBankDepositWkshtDEL: Record "Bank Deposit Wksht Entry ELA";
        lintLineNo: Integer;
        lcodCurrency: Code[10];
        ljfText001: Label 'You cannot create a Deposit using multiple currencies.';
        ljfText002: Label 'Nothing to Post';
        lrecGLSetup: Record "General Ledger Setup";
        lcduNoSeriesMgmt: Codeunit NoSeriesManagement;
    begin
        if precBankDepositWksht.FindSet(true) then begin
            lcodCurrency := precBankDepositWksht."Currency Code";

            //-- Get Batch
            lrecBankDepBatch.Get(precBankDepositWksht."Bank Deposit Batch Name");

            lrecBankDepBatch.TestField("Deposit Template Name");
            lrecBankDepBatch.TestField("Deposit Batch Name");
            lrecBankDepBatch.TestField("Bank Account No.");

            //<JF8715MG>
            //-- In order to stop partially created deposits, generate a Deposit No. now and commit it
            // - deleted code
            //</JF8715MG>

            //-- Create Bank Deposit Header (will error on insert if one already exists for given batch)
            lrecDepositHeader.SetRange("Journal Template Name", lrecBankDepBatch."Deposit Template Name");
            lrecDepositHeader.SetRange("Journal Batch Name", lrecBankDepBatch."Deposit Batch Name");

            if not lrecDepositHeader.FindFirst then
                lrecDepositHeader.Insert(true)
            else
                Error(ljfText000,
                      lrecDepositHeader.TableCaption,
                      lrecDepositHeader."Journal Template Name",
                      lrecDepositHeader."Journal Batch Name");

            lrecDepositHeader.Validate("Bank Account No.", lrecBankDepBatch."Bank Account No.");

            //-- Create Deposit Lines (Gen. Journal Lines)
            lrecDepositLine.SetRange("Journal Template Name", lrecDepositHeader."Journal Template Name");
            lrecDepositLine.SetRange("Journal Batch Name", lrecDepositHeader."Journal Batch Name");

            if lrecDepositLine.FindLast then
                lintLineNo := lrecDepositLine."Line No." + 10000
            else
                lintLineNo := 10000;

            repeat
                if lcodCurrency <> precBankDepositWksht."Currency Code" then
                    Error(ljfText001);

                lrecDepositLine.Init;

                lrecDepositLine.Validate("Journal Template Name", lrecDepositHeader."Journal Template Name");
                lrecDepositLine.Validate("Journal Batch Name", lrecDepositHeader."Journal Batch Name");

                lrecDepositLine.Validate("Line No.", lintLineNo);

                lrecDepositLine.Validate("Posting Date", precBankDepositWksht."Posting Date");

                lrecDepositLine."Bal. Account Type" := lrecDepositLine."Bal. Account Type"::"Bank Account";

                lrecDepositLine."Account Type" := lrecDepositLine."Account Type"::Customer;
                lrecDepositLine.Validate("Account No.", precBankDepositWksht."Bill-To Customer No.");

                lrecDepositLine.Validate("Document Date", precBankDepositWksht."Posting Date");

                if precBankDepositWksht."Entry Type" = precBankDepositWksht."Entry Type"::Adjustment then begin
                    //<JF3120MG>
                    if precBankDepositWksht."Amount To Apply" < 0 then begin
                        lrecDepositLine.Validate("Document Type", lrecDepositLine."Document Type"::Refund);
                        lrecDepositLine.Validate("Debit Amount", -precBankDepositWksht."Amount To Apply");
                    end else begin
                        lrecDepositLine.Validate(Amount, precBankDepositWksht."Amount To Apply");
                    end;
                    //</JF3120MG>
                end else begin
                    lrecDepositLine.Validate("Document Type", lrecDepositLine."Document Type"::Payment);
                    lrecDepositLine.Validate("Credit Amount", precBankDepositWksht."Amount To Apply");
                end;

                lrecDepositLine."Document No." := precBankDepositWksht."Check No.";

                case precBankDepositWksht."Applies-To Document Type" of
                    precBankDepositWksht."Applies-To Document Type"::Invoice:
                        lrecDepositLine."Applies-to Doc. Type" := lrecDepositLine."Applies-to Doc. Type"::Invoice;
                    precBankDepositWksht."Applies-To Document Type"::"Credit Memo":
                        lrecDepositLine."Applies-to Doc. Type" := lrecDepositLine."Applies-to Doc. Type"::"Credit Memo";
                end;

                lrecDepositLine.Validate("Applies-to Doc. No.", precBankDepositWksht."Applies-To Document No.");
                lrecDepositLine.Validate("Reason Code", precBankDepositWksht."Reason Code");

                lrecDepositLine."External Document No." := lrecDepositHeader."No."; //-- this follows std. NAV usage of this field

                lrecDepositLine."Bill-to/Pay-to No." := precBankDepositWksht."Bill-To Customer No.";
                lrecDepositLine."Sell-to/Buy-from No." := precBankDepositWksht."Sell-To Customer No.";
                lrecDepositLine."Ship-to/Order Address Code" := precBankDepositWksht."Ship-To Code";

                lrecDepositLine."Bank Reference No. ELA" := precBankDepositWksht."Reference No.";

                // lrecDepositLine."EDI Internal Doc. No." := precBankDepositWksht."EDI Internal Doc. No.";
                // lrecDepositLine."EDI Trade Partner" := precBankDepositWksht."EDI Trade Partner";
                // lrecDepositLine."EDI Applies-To Document No." := precBankDepositWksht."EDI Applies-To Document No.";
                // lrecDepositLine."EDI Reason Code" := precBankDepositWksht."EDI Reason Code";

                lrecDepositLine.Insert(true);

                lintLineNo += 10000;

                lrecBankDepositWkshtDEL.Get(precBankDepositWksht."Bank Deposit Batch Name", precBankDepositWksht."Line No.");
                lrecBankDepositWkshtDEL.Delete;
            until precBankDepositWksht.Next = 0;

            lrecDepositHeader.CalcFields("Total Deposit Lines");

            lrecDepositHeader."Total Deposit Amount" := lrecDepositHeader."Total Deposit Lines";
            lrecDepositHeader.Modify(true);

            exit(lrecDepositHeader."No.");
        end else begin
            Error(ljfText002);
        end;
    end;
}

