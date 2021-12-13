table 14228910 "EN Sales Payment Header"
{
    // ENSP1.00 2020-04-14 AF
    //      Created new table

    Caption = 'Sales Payment Header';
    DataCaptionFields = "No.", "Customer Name";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                SalesSetup.Get;
                if ("No." <> xRec."No.") then begin
                    NoSeriesMgt.TestManual(SalesSetup."Sales Payment Nos. ELA");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            begin
                if (xRec."Customer No." <> "Customer No.") and (xRec."Customer No." <> '') then begin
                    CheckNoTenderExists;
                    CheckNoLinesExists;
                end;

                Customer.Get("Customer No.");
                "Customer Name" := Customer.Name;
            end;
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
        }
        field(4; Amount; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum("EN Sales Payment Line".Amount WHERE("Document No." = FIELD("No.")));
            Caption = 'Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Amount Tendered"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum("EN Sales Payment Tender Entry".Amount WHERE("Document No." = FIELD("No.")));
            Caption = 'Amount Tendered';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Allow Posting w/ Balance"; Boolean)
        {
            Caption = 'Allow Posting w/ Balance';

            trigger OnValidate()
            begin
                UpdateStatus;
            end;
        }
        field(10; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(11; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(12; "Posting No."; Code[20])
        {
            Caption = 'Posting No.';
        }
        field(13; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";

            trigger OnLookup()
            begin
                SalesPaymentHeader := Rec;
                SalesSetup.Get;
                SalesSetup.TestField("Posted Sales Payment Nos. ELA");
                if NoSeriesMgt.LookupSeries(SalesSetup."Posted Sales Payment Nos. ELA", "Posting No. Series") then
                    Validate("Posting No. Series");
                Rec := SalesPaymentHeader;
            end;

            trigger OnValidate()
            begin
                if ("Posting No. Series" <> '') then begin
                    SalesSetup.Get;
                    SalesSetup.TestField("Posted Sales Payment Nos. ELA");
                    NoSeriesMgt.TestSeries(SalesSetup."Posted Sales Payment Nos. ELA", "Posting No. Series");
                end;
                TestField("Posting No.", '');
            end;
        }
        field(14; "Min. Posting Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Min. Posting Entry No.';
            Editable = false;
            TableRelation = "Cust. Ledger Entry";
        }
        field(15; "Max. Posting Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Max. Posting Entry No.';
            Editable = false;
            TableRelation = "Cust. Ledger Entry";
        }
        field(16; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'Open,Shipping,Complete';
            OptionMembers = Open,Shipping,Complete;
        }
        field(17; "Customer Balance ($)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Min. Posting Entry No.", "Max. Posting Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CheckNoTenderExists;

        SalesPaymentLine.Reset;
        SalesPaymentLine.SetRange("Document No.", "No.");
        SalesPaymentLine.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        SalesSetup.Get;
        if ("No." = '') then begin
            SalesSetup.TestField("Sales Payment Nos. ELA");
            NoSeriesMgt.InitSeries(SalesSetup."Sales Payment Nos. ELA", xRec."No. Series", "Posting Date", "No.", "No. Series");
        end;
        NoSeriesMgt.SetDefaultSeries("Posting No. Series", SalesSetup."Posted Sales Payment Nos. ELA");

        "Posting Date" := WorkDate;
    end;

    trigger OnRename()
    begin
        Error(Text000, TableCaption);
    end;

    var
        SalesSetup: Record "Sales & Receivables Setup";
        SalesPaymentHeader: Record "EN Sales Payment Header";
        SalesPaymentLine: Record "EN Sales Payment Line";
        SalesPaymentTenderEntry: Record "EN Sales Payment Tender Entry";
        Customer: Record Customer;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text000: Label 'You cannot rename a %1.';
        Text001: Label 'Lines exist for %1 %2.';
        Text002: Label 'Tender Entries exist for %1 %2.';
        Text003: Label 'Payment %1 has a Balance of $%2.';
        Text004: Label '<Precision,2:2><Standard Format,0>';
        Text005: Label 'Adding Order #1##################';
        Text006: Label 'Order';
        Text007: Label 'Orders';
        Text008: Label 'Adding Entry #1##################';
        Text009: Label 'Entry';
        Text010: Label 'Entries';
        Text011: Label 'No';
        Text012: Label 'One';
        Text013: Label '%1 added to Payment.';


    procedure AssistEditNo(OldSalesPaymentHeader: Record "EN Sales Payment Header"): Boolean
    begin
        SalesSetup.Get;
        SalesPaymentHeader := Rec;
        SalesSetup.TestField("Sales Payment Nos. ELA");
        if NoSeriesMgt.SelectSeries(
            SalesSetup."Sales Payment Nos. ELA", OldSalesPaymentHeader."No. Series", "No. Series")
        then begin
            NoSeriesMgt.SetSeries("No.");
            Rec := SalesPaymentHeader;
            exit(true);
        end;
    end;

    local procedure CheckNoLinesExists()
    begin
        SalesPaymentLine.Reset;
        SalesPaymentLine.SetRange("Document No.", "No.");
        if SalesPaymentLine.FindSet then
            Error(Text001, TableCaption, "No.");
    end;

    local procedure CheckNoTenderExists()
    begin
        SalesPaymentTenderEntry.Reset;
        SalesPaymentTenderEntry.SetRange("Document No.", "No.");
        if SalesPaymentTenderEntry.FindSet then
            Error(Text002, TableCaption, "No.");
    end;


    procedure CheckBalance()
    begin
        CalcFields(Amount, "Amount Tendered");
        if not "Allow Posting w/ Balance" then
            if (Amount <> "Amount Tendered") then
                Error(Text003, "No.", GetAmountStr(Amount - "Amount Tendered"));
    end;


    procedure UpdateStatusFromLine(var SalesPmtLine: Record "EN Sales Payment Line"; DeletingLine: Boolean): Boolean
    var
        OldSalesPmtLine: Record "EN Sales Payment Line";
    begin
        if DeletingLine or (not SalesPmtLine."Allow Order Changes") then begin
            CalcFields(Amount, "Amount Tendered");
            if OldSalesPmtLine.Get(SalesPmtLine."Document No.", SalesPmtLine."Line No.") then
                Amount := Amount - OldSalesPmtLine.Amount;
            if not DeletingLine then
                Amount := Amount + SalesPmtLine.Amount;
            if ("Amount Tendered" = Amount) or "Allow Posting w/ Balance" then begin
                SalesPaymentLine.Reset;
                SalesPaymentLine.SetRange("Document No.", "No.");
                SalesPaymentLine.SetFilter("Line No.", '<>%1', SalesPmtLine."Line No.");
                SalesPaymentLine.SetRange(Type, SalesPaymentLine.Type::Order);
                SalesPaymentLine.SetRange("Allow Order Changes", true);
                if SalesPaymentLine.IsEmpty then begin
                    if DeletingLine or (SalesPmtLine.Type <> SalesPmtLine.Type::Order) or
                       (SalesPmtLine."Order Shipment Status" = SalesPmtLine."Order Shipment Status"::Complete)
                    then begin
                        SalesPaymentLine.SetRange("Allow Order Changes");
                        SalesPaymentLine.SetFilter(
                          "Order Shipment Status", '<>%1', SalesPaymentLine."Order Shipment Status"::Complete);
                        if SalesPaymentLine.IsEmpty then
                            exit(SetStatus(Status::Complete));
                    end;
                    exit(SetStatus(Status::Shipping));
                end;
            end;
        end;
        exit(SetStatus(Status::Open));
    end;


    procedure UpdateStatus(): Boolean
    var
        BlankSalesPmtLine: Record "EN Sales Payment Line";
    begin
        exit(UpdateStatusFromLine(BlankSalesPmtLine, true));
    end;

    procedure SetStatus(NewStatus: Integer): Boolean
    begin
        if (Status <> NewStatus) then begin
            Status := NewStatus;
            exit(true);
        end;
    end;


    procedure GetBalance(CalculateAmounts: Boolean): Decimal
    begin
        if CalculateAmounts then
            CalcFields(Amount, "Amount Tendered");
        exit(Amount - "Amount Tendered");
    end;


    procedure GetAmountStr(Amt: Decimal): Text[30]
    begin
        exit(Format(Amt, 0, Text004));
    end;


    procedure IsInvoicePosted(): Boolean
    begin
        exit("Min. Posting Entry No." <> 0);
    end;


    procedure InvoiceEntriesExist(var CustLedgEntry: Record "Cust. Ledger Entry"): Boolean
    begin
        if IsInvoicePosted() then begin
            CustLedgEntry.Reset;
            CustLedgEntry.SetRange("Entry No.", "Min. Posting Entry No.", "Max. Posting Entry No.");
            exit(CustLedgEntry.FindSet);
        end;
    end;


    procedure AddOrders()
    var
        SalesHeader: Record "Sales Header";
        SalesOrderList: Page "Sales Order List";
        OneEntry: Boolean;
        ExistingPaymentLine: Record "EN Sales Payment Line";
        LinesAdded: Integer;
        StatusWindow: Dialog;
    begin
        TestField("Customer No.");
        SalesHeader.Reset;
        SalesHeader.SetCurrentKey("Document Type", "Combine Shipments", "Bill-to Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Bill-to Customer No.", "Customer No.");
        SalesHeader.SetFilter("Currency Code", '%1', '');
        SalesOrderList.SetTableView(SalesHeader);
        SalesOrderList.LookupMode(true);
        if (SalesOrderList.RunModal = ACTION::LookupOK) then begin
            SalesOrderList.GetSelectionFilter(SalesHeader);
            if SalesHeader.FindSet then begin
                PrepareNewPmtLine;
                OneEntry := (SalesHeader.Count = 1);
                if not OneEntry then
                    StatusWindow.Open(Text005);
                repeat
                    if OneEntry or (not SalesHeader.OnSalesPaymentELA(ExistingPaymentLine)) then begin
                        if not OneEntry then
                            StatusWindow.Update(1, SalesHeader."No.");
                        SalesPaymentLine."Line No." := SalesPaymentLine."Line No." + 10000;
                        SalesPaymentLine.Validate(Type, SalesPaymentLine.Type::Order);
                        SalesPaymentLine.Validate("No.", SalesHeader."No.");
                        SalesPaymentLine.Insert(true);
                        LinesAdded := LinesAdded + 1;
                    end;
                until (SalesHeader.Next = 0);
                if not OneEntry then
                    StatusWindow.Close;
            end;
            ReportNewPmtLines(Text006, Text007, LinesAdded);
        end;
    end;


    procedure AddOpenEntries()
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        CustLedgEntries: Page "Customer Ledger Entries";
        OneEntry: Boolean;
        ExistingPaymentLine: Record "EN Sales Payment Line";
        ExistingTenderEntry: Record "EN Sales Payment Tender Entry";
        LinesAdded: Integer;
        StatusWindow: Dialog;
    begin
        TestField("Customer No.");
        CustLedgEntry.Reset;
        CustLedgEntry.SetCurrentKey("Customer No.");
        CustLedgEntry.SetRange("Customer No.", "Customer No.");
        CustLedgEntry.SetRange(Open, true);
        CustLedgEntry.SetFilter("Currency Code", '%1', '');
        CustLedgEntries.SetTableView(CustLedgEntry);
        CustLedgEntries.LookupMode(true);
        if (CustLedgEntries.RunModal = ACTION::LookupOK) then begin
            CustLedgEntries.GetSelectionFilter(CustLedgEntry);
            if CustLedgEntry.FindSet then begin
                PrepareNewPmtLine;
                OneEntry := (CustLedgEntry.Count = 1);
                if not OneEntry then
                    StatusWindow.Open(Text008);
                repeat
                    if OneEntry or
                       ((not CustLedgEntry.OnSalesPaymentELA(ExistingPaymentLine)) and
                        (not CustLedgEntry.IsSalesPaymentTenderELA(ExistingTenderEntry)))
                    then begin
                        if not OneEntry then
                            StatusWindow.Update(1, CustLedgEntry."Document No.");
                        SalesPaymentLine."Line No." := SalesPaymentLine."Line No." + 10000;
                        SalesPaymentLine.Validate(Type, SalesPaymentLine.Type::"Open Entry");
                        SalesPaymentLine."Entry No." := CustLedgEntry."Entry No.";
                        SalesPaymentLine.Validate("No.", CustLedgEntry."Document No.");
                        SalesPaymentLine.Insert(true);
                        LinesAdded := LinesAdded + 1;
                    end;
                until (CustLedgEntry.Next = 0);
                if not OneEntry then
                    StatusWindow.Close;
            end;
            ReportNewPmtLines(Text009, Text010, LinesAdded);
        end;
    end;

    local procedure PrepareNewPmtLine()
    begin
        SalesPaymentLine.Reset;
        SalesPaymentLine.SetRange("Document No.", "No.");
        if not SalesPaymentLine.FindLast then begin
            SalesPaymentLine."Document No." := "No.";
            SalesPaymentLine."Line No." := 0;
        end;
        SalesPaymentLine.Init;
    end;

    local procedure ReportNewPmtLines(SingularText: Text[30]; PluralText: Text[30]; LinesAdded: Integer)
    var
        MsgText: Text[80];
    begin
        case LinesAdded of
            0:
                MsgText := StrSubstNo('%1 %2', Text011, PluralText);
            1:
                MsgText := StrSubstNo('%1 %2', Text012, SingularText);
            else
                MsgText := StrSubstNo('%1 %2', LinesAdded, PluralText);
        end;
        Message(Text013, MsgText);
    end;


    procedure DoCashPayment()
    var
        CashPaymentPage: Page "EN Sales Payments - Cash";
    begin
        CashPaymentPage.SetPayment(Rec);
        CashPaymentPage.LookupMode(true); // P8001149
        CashPaymentPage.RunModal;
    end;


    procedure DoNonCashPayment()
    var
        NonCashPaymentPage: Page "EN Sales Payments - Check";
    begin
        NonCashPaymentPage.SetPayment(Rec);
        NonCashPaymentPage.LookupMode(true); // P8001149
        NonCashPaymentPage.RunModal;
    end;


    procedure Print()
    var
        SalesPayment: Record "EN Sales Payment Header";
        SalesPaymentRpt: Report "EN Sales Payment - Unposted";
    begin
        SalesPayment.Get("No.");
        SalesPayment.SetRecFilter;
        SalesPaymentRpt.SetTableView(SalesPayment);
        SalesPaymentRpt.RunModal;
    end;


    procedure PrintPickTickets()
    var
        SalesPaymentLine: Record "EN Sales Payment Line";
        SalesHeader: Record "Sales Header";
    begin
        CheckBalance;
        SalesPaymentLine.SetRange("Document No.", "No.");
        SalesPaymentLine.SetRange(Type, SalesPaymentLine.Type::Order);
        if SalesPaymentLine.FindSet then
            repeat
                SalesHeader.Get(SalesHeader."Document Type"::Order, SalesPaymentLine."No.");
                SalesHeader.PrintTermMktPickTicketELA(false);
            until SalesPaymentLine.Next = 0;
    end;


    procedure GetCustomerBalance(): Decimal
    begin
        if Customer.Get("Customer No.") then
            Customer.CalcFields("Balance (LCY)");
        exit(Customer."Balance (LCY)");
    end;
}

