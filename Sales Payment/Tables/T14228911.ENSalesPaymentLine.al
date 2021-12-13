table 14228911 "EN Sales Payment Line"
{
    // ENSP1.00 2020-04-14 AF
    //     Created new table

    Caption = 'Sales Payment Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "EN Sales Payment Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(4; Type; Enum "EN Sales Payment Line Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            begin
                CheckType;

                SalesPaymentLine := Rec;
                Init;
                Type := SalesPaymentLine.Type;

                if SalesPayment.Get("Document No.") then
                    "Customer No." := SalesPayment."Customer No.";
                UpdateStatus;
            end;
        }
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(Order)) "Sales Header"."No." WHERE("Document Type" = CONST(Order));

            trigger OnValidate()
            var
                SearchPaymentLine: Record "EN Sales Payment Line";
                SearchTenderEntry: Record "EN Sales Payment Tender Entry";
                SearchPayment: Record "EN Sales Payment Header";
            begin
                CheckType;

                SalesPaymentLine := Rec;
                Init;
                Type := SalesPaymentLine.Type;
                "No." := SalesPaymentLine."No.";
                "Entry No." := SalesPaymentLine."Entry No.";

                SalesPayment.Get("Document No.");
                SalesPayment.TestField("Customer No.");
                "Customer No." := SalesPayment."Customer No.";
                if ("No." <> '') then
                    case Type of
                        Type::Order:
                            begin
                                SalesHeader.Get(SalesHeader."Document Type"::Order, "No.");
                                if SalesHeader.OnSalesPaymentELA(SalesPaymentLine) then
                                    MatchPmtLine(SalesPaymentLine);
                                SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);
                                SalesHeader.TestField("Bill-to Customer No.", "Customer No.");
                                SalesHeader.TestField("Currency Code", '');
                                
                                ReleaseSalesDoc.Run(SalesHeader);
                                "Entry No." := 0;
                                Description := StrSubstNo('%1 %2', SalesHeader."Document Type", SalesHeader."No.");
                                SalesHeader.CalcFields("Amount Including VAT");
                                Amount := SalesHeader."Amount Including VAT";
                            end;
                        Type::"Open Entry":
                            begin
                                CustLedgEntry.Reset;
                                CustLedgEntry.SetCurrentKey("Document No.");
                                CustLedgEntry.SetRange("Customer No.", "Customer No.");
                                CustLedgEntry.SetRange(Open, true);
                                CustLedgEntry.SetFilter("Document No.", "No." + '*');
                                if ("Entry No." <> 0) then
                                    if CustLedgEntry.Get("Entry No.") then
                                        if not CustLedgEntry.Find then
                                            CustLedgEntry."Entry No." := 0;
                                if (CustLedgEntry."Entry No." = 0) then
                                    CustLedgEntry.FindFirst;
                                if CustLedgEntry.OnSalesPaymentELA(SearchPaymentLine) then
                                    MatchPmtLine(SearchPaymentLine);
                                if CustLedgEntry.IsSalesPaymentTenderELA(SearchTenderEntry) then
                                    Error(Text000, Type, "No.", SearchTenderEntry."Document No.");
                                if CustLedgEntry.IsSalesPaymentInvoiceELA(SearchPayment) then
                                    Error(Text000, Type, "No.", SearchPayment."No.");
                                CustLedgEntry.TestField("Currency Code", '');
                                "No." := CustLedgEntry."Document No.";
                                "Entry No." := CustLedgEntry."Entry No.";
                                Description := CustLedgEntry.Description;
                                CustLedgEntry.CalcFields("Remaining Amount");
                                Amount := CustLedgEntry."Remaining Amount";
                            end;
                    end;
                UpdateStatus;
            end;
        }
        field(6; "Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Entry No.';
            TableRelation = IF (Type = CONST("Open Entry")) "Cust. Ledger Entry" WHERE(Open = CONST(true))
            ELSE
            IF (Type = CONST("Payment Fee")) "EN Sales Payment Tender Entry";
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            Editable = false;
        }
        field(9; "Allow Order Changes"; Boolean)
        {
            Caption = 'Allow Order Changes';

            trigger OnValidate()
            begin
                TestField(Type, Type::Order);
                TestField("No.");
                Modify;
                SalesHeader.Get(SalesHeader."Document Type"::Order, "No.");
                
                if "Allow Order Changes" then
                    ReleaseSalesDoc.Reopen(SalesHeader)
                else begin
                    ReleaseSalesDoc.Run(SalesHeader);
                    SalesHeader.CalcFields("Amount Including VAT");
                    Amount := SalesHeader."Amount Including VAT";
                end;
                UpdateStatus;
            end;
        }
        field(10; "Order Shipment Status"; Enum "EN Sales Payment Shipment Status")
        {
            Caption = 'Order Shipment Status';
            Editable = false;
        }
        field(11; "Shipments Exist"; Boolean)
        {
            CalcFormula = Exist("Sales Line" WHERE("Document Type" = CONST(Order),
                                                    "Document No." = FIELD("No."),
                                                    "Quantity Shipped" = FILTER(<> 0)));
            Caption = 'Shipments Exist';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Shipments Pending"; Boolean)
        {
            CalcFormula = Exist("Sales Line" WHERE("Document Type" = CONST(Order),
                                                    "Document No." = FIELD("No."),
                                                    "Outstanding Quantity" = FILTER(<> 0)));
            Caption = 'Shipments Pending';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = Amount;
        }
        key(Key2; Type, "No.")
        {
        }
        key(Key3; Type, "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CheckType;
        CheckPosted(false);
        UpdateHeaderStatus(true);
    end;

    trigger OnInsert()
    begin
        CheckPosted(true);
        UpdateHeaderStatus(false);
    end;

    trigger OnModify()
    begin
        CheckType;
        CheckPosted(false);
        UpdateHeaderStatus(false);
    end;

    var
        SalesPayment: Record "EN Sales Payment Header";
        SalesPaymentLine: Record "EN Sales Payment Line";
        SalesHeader: Record "Sales Header";
        CustLedgEntry: Record "Cust. Ledger Entry";
        PaymentMethod: Record "Payment Method";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        Text000: Label '%1 %2 is already associated with Sales Payment %3.';
        Text001: Label 'Orders cannot be added or changed. Sales Payment %1 has been invoiced.';
        Text002: Label 'Payment Fee lines cannot be modified.';
        

    local procedure CheckType()
    begin
        if (CurrFieldNo <> 0) and (xRec.Type = Type::"Payment Fee") then
            Error(Text002);
    end;

    local procedure CheckPosted(InsertingLine: Boolean)
    begin
        if ((not InsertingLine) and (xRec.Type = Type::Order)) or
           (InsertingLine and (Type = Type::Order))
        then begin
            SalesPayment.Get("Document No.");
            if (SalesPayment."Min. Posting Entry No." <> 0) then
                Error(Text001, SalesPayment."No.");
        end;
    end;

    local procedure MatchPmtLine(var SalesPaymentLine2: Record "EN Sales Payment Line")
    begin
        if (SalesPaymentLine2."Document No." <> "Document No.") or
           (SalesPaymentLine2."Line No." <> "Line No.")
        then
            Error(Text000, Type, "No.", SalesPaymentLine2."Document No.");
    end;


    procedure LookupNo(var Text: Text[1024]): Boolean
    var
        SalesOrderList: Page "Sales Order List";
        CustLedgEntries: Page "Customer Ledger Entries";
        EntryFound: Boolean;
    begin
        SalesPayment.Get("Document No.");
        SalesPayment.TestField("Customer No.");
        "Customer No." := SalesPayment."Customer No.";
        case Type of
            Type::Order:
                begin
                    SalesHeader.Reset;
                    SalesHeader.SetCurrentKey("Document Type", "Combine Shipments", "Bill-to Customer No.");
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    SalesHeader.SetRange("Bill-to Customer No.", "Customer No.");
                    SalesHeader.SetFilter("Currency Code", '%1', '');
                    if (Text <> '') then begin
                        SalesHeader.SetFilter("No.", "No." + '*');
                        if SalesHeader.FindFirst then
                            SalesOrderList.SetRecord(SalesHeader);
                        SalesHeader.SetRange("No.");
                    end;
                    SalesOrderList.SetTableView(SalesHeader);
                    SalesOrderList.LookupMode(true);
                    if (SalesOrderList.RunModal = ACTION::LookupOK) then begin
                        SalesOrderList.GetRecord(SalesHeader);
                        Text := SalesHeader."No.";
                        "Entry No." := 0;
                        exit(true);
                    end;
                end;
            Type::"Open Entry":
                begin
                    CustLedgEntry.Reset;
                    CustLedgEntry.SetCurrentKey("Customer No.");
                    CustLedgEntry.SetRange("Customer No.", "Customer No.");
                    CustLedgEntry.SetRange(Open, true);
                    CustLedgEntry.SetFilter("Currency Code", '%1', '');
                    if (Text <> '') then begin
                        CustLedgEntry.SetFilter("Document No.", "No." + '*');
                        if ("Entry No." <> 0) then
                            if CustLedgEntry.Get("Entry No.") then
                                if CustLedgEntry.Find then begin
                                    CustLedgEntries.SetRecord(CustLedgEntry);
                                    EntryFound := true;
                                end;
                        if not EntryFound then
                            if CustLedgEntry.FindFirst then
                                CustLedgEntries.SetRecord(CustLedgEntry);
                        CustLedgEntry.SetRange("Document No.");
                    end;
                    CustLedgEntries.SetTableView(CustLedgEntry);
                    CustLedgEntries.LookupMode(true);
                    if (CustLedgEntries.RunModal = ACTION::LookupOK) then begin
                        CustLedgEntries.GetRecord(CustLedgEntry);
                        Text := CustLedgEntry."Document No.";
                        "Entry No." := CustLedgEntry."Entry No.";
                        exit(true);
                    end;
                end;
        end;
    end;


    procedure UpdateStatus(): Boolean
    var
        OldStatus: Enum "EN Sales Payment Shipment Status";
    begin
        OldStatus := "Order Shipment Status";

        "Order Shipment Status" := "Order Shipment Status"::" ";
        if (Type = Type::Order) and ("No." <> '') and (not "Allow Order Changes") then begin
            CalcFields("Shipments Pending");
            if not "Shipments Pending" then
                "Order Shipment Status" := "Order Shipment Status"::Complete
            else begin
                CalcFields("Shipments Exist");
                if "Shipments Exist" then
                    "Order Shipment Status" := "Order Shipment Status"::Partial;
            end;
        end;
        exit("Order Shipment Status" <> OldStatus);
    end;

    local procedure UpdateHeaderStatus(DeletingLine: Boolean)
    begin
        SalesPayment.Get("Document No.");
        if SalesPayment.UpdateStatusFromLine(Rec, DeletingLine) then
            SalesPayment.Modify(true);
    end;


    procedure ShowOrder(PageEditable: Boolean)
    var
        SalesOrderPage: Page "Sales Order";
    begin
        TestField(Type, Type::Order);
        TestField("No.");
        SalesHeader.Get(SalesHeader."Document Type"::Order, "No.");
        SalesOrderPage.Editable(PageEditable);
        SalesOrderPage.SetRecord(SalesHeader);
        SalesOrderPage.Run;
    end;
}

