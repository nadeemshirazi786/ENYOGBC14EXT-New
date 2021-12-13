page 14228882 "EN C&C Order Summary Factbox"
{
    Caption = 'Summary';
    PageType = CardPart;
    SourceTable = "Sales Header";

    layout
    {
        area(content)
        {
            field(Amount; Amount)
            {
                Caption = 'Item Total';
                Editable = false;
            }
            field("""Amount Including VAT"" - Amount"; "Amount Including VAT" - Amount)
            {
                Caption = 'Tax';
                Editable = false;
            }
            field("Amount Including VAT"; "Amount Including VAT")
            {
                Caption = 'Order Total';
                Editable = false;
            }
            field("Cash Tendered"; "Cash Tendered ELA")
            {
                Caption = 'Amount Tendered';
                Editable = false;

                trigger OnDrillDown()
                begin
                    CCReceiveCash;
                end;
            }
            field("Cash Applied (Current)"; "Cash Applied (Current) ELA")
            {
                Caption = 'Applied to this order';
                Editable = false;

                trigger OnDrillDown()
                begin

                    CCReceiveCash;
                end;
            }
            field("Cash Applied (Other)"; "Cash Applied (Other) ELA")
            {
                Caption = 'Applied to other orders';
                Editable = false;

                trigger OnDrillDown()
                begin

                    CCReceiveCash;
                end;
            }
            field("Change Due"; ChangeDue())
            {
                Caption = 'Change Due';
                Editable = false;

                trigger OnDrillDown()
                begin

                    CCReceiveCash;
                end;
            }
            group("Credit Checks")
            {
                Caption = 'Credit Checks';
                field(OverLimit; OverLimit)
                {
                    Caption = 'Over Limit';
                    Editable = false;
                }
                field(OverDue; OverDue)
                {
                    Caption = 'Overdue';
                    Editable = false;
                }
                field("<Balance>"; grecCustomer."Balance (LCY)")
                {
                    Caption = 'Balance($)';

                    trigger OnDrillDown()
                    var
                        lrecDtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
                        lrecCustomer: Record Customer;
                        lrecCustLedgEntry: Record "Cust. Ledger Entry";
                    begin

                        lrecDtldCustLedgEntry.SetRange("Customer No.", "Bill-to Customer No.");
                        lrecCustomer.Get("Bill-to Customer No.");
                        lrecCustomer.CopyFilter("Global Dimension 1 Filter", lrecDtldCustLedgEntry."Initial Entry Global Dim. 1");
                        lrecCustomer.CopyFilter("Global Dimension 2 Filter", lrecDtldCustLedgEntry."Initial Entry Global Dim. 2");
                        lrecCustomer.CopyFilter("Currency Filter", lrecDtldCustLedgEntry."Currency Code");
                        lrecCustLedgEntry.DrillDownOnEntries(lrecDtldCustLedgEntry);
                    end;
                }
                field("<Total Incl. this Order>"; grecCustomer."Balance (LCY)" + "Amount Including VAT")
                {
                    Caption = 'Total Incl. this Order';
                }
            }
            group(Totals)
            {
                Caption = 'Totals';
                field(TotalCases; TotalCases)
                {
                    Caption = 'Cases';
                    Editable = false;
                }
                field(TotalLbs; TotalLbs)
                {
                    Caption = 'Lbs.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin



        Clear(grecCustomer);
        if grecCustomer.Get("Bill-to Customer No.") then begin
            grecCustomer.CalcFields("Balance (LCY)");
        end;

        ibCheckOverLimit;
        ibCheckOverdue;
    end;

    var
        "--From Original--": Integer;
        CashOrder: Boolean;
        OverLimit: Boolean;
        OverDue: Boolean;
        TotalCases: Decimal;
        TotalLbs: Decimal;
        AppliedEntered: Decimal;
        CalcTaxCalled: Boolean;
        grecCustomer: Record Customer;


    procedure "--From-Original Form--"()
    begin
    end;




    procedure ChangeDue() Change: Decimal
    begin
        Change := "Cash Tendered ELA" - "Cash Applied (Current) ELA" - "Cash Applied (Other) ELA";
    end;

    local procedure "MIN"(num1: Decimal; num2: Decimal): Decimal
    begin
        if num1 <= num2 then
            exit(num1)
        else
            exit(num2);
    end;


    procedure "MAX"(num1: Decimal; num2: Decimal): Decimal
    begin
        if num1 >= num2 then
            exit(num1)
        else
            exit(num2);
    end;


    procedure SaveCashAppl()
    var

    begin
        Modify;
    end;


    procedure CalcTotalTax(DocType: Integer; DocNo: Code[20])
    var
        SalesHdr: Record "Sales Header";
        TaxSalesline: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin

        SalesHdr.Get(DocType, DocNo);

        CalcTaxCalled := true;

        ReleaseSalesDoc.PerformManualRelease(SalesHdr);
        Rec := SalesHdr;

        UpdateTotals(true);
        CalcTaxCalled := false;
        CurrPage.Update;
    end;

    procedure CalcTotal(DocType: Integer; DocNo: Code[20]; LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        SlsHdr: Record "Sales Header";
    begin
        SalesLine.SetRange("Document Type", DocType);
        SalesLine.SetRange("Document No.", DocNo);
        SalesLine.CalcSums("Line Amount", "Amount Including VAT");
        TotalLbs := 0;
        TotalCases := 0;
        with SalesLine do begin
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            if SalesLine.Find('-') then begin
                repeat
                    //case true of
                    // SalesLine."Unit of Measure Code" = 'LB':
                    //     TotalLbs := TotalLbs + SalesLine.Quantity;
                    // SalesLine."Unit of Measure Code" <> 'LB':
                    //     TotalCases := TotalCases + SalesLine.Quantity;


                    IF UPPERCASE("Unit of Measure Code") = 'PER LB' THEN
                        TotalLbs += Quantity
                    ELSE
                        TotalCases += Quantity;
                until Next = 0;
            end;
        end;
    end;


    procedure TotalOrder()
    var
        SalesHdr: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        CalcTotalTax("Document Type", "No."); // double call needed to avoid undetermined bug

        SalesHdr.Get("Document Type", "No.");

        ReleaseSalesDoc.PerformManualReopen(SalesHdr);

        Commit;
        CCReceiveCash;

    end;


    procedure UpdateTotals(IncludeLine: Boolean)
    begin
        CalcTotal("Document Type", "No.", 0);
        SaveCashAppl;
    end;


    procedure CCReceiveCash()
    var
        lpagCnCReceiveCash: Page "EN C&C Receive Cash";
    begin
        lpagCnCReceiveCash.SetOrder(Rec);
        lpagCnCReceiveCash.Editable(true);
        lpagCnCReceiveCash.RunModal;
    end;


    procedure ibCheckOverLimit()
    var
        lrecCustomer: Record Customer;
    begin

        OverLimit := false;
        Clear(lrecCustomer);
        if lrecCustomer.Get("Bill-to Customer No.") then begin
            lrecCustomer.CalcFields("Balance (LCY)");
            if lrecCustomer."Credit Limit (LCY)" = 0 then
                OverLimit := false;
            if (lrecCustomer."Credit Limit (LCY)" - lrecCustomer."Balance (LCY)") < 0 then begin
                OverLimit := true;
            end;
        end;
    end;


    procedure ibCheckOverdue()
    var
        lrecCustomer: Record Customer;
        CustLedger: Record "Cust. Ledger Entry";
        DueDate: Date;
        OverdueAmount: Decimal;
        SalesSetup: Record "Sales & Receivables Setup";
    begin

        SalesSetup.Get;
        OverDue := false;
        Clear(lrecCustomer);
        if lrecCustomer.Get("Bill-to Customer No.") then begin
            DueDate := Today - lrecCustomer."Credit Grace Period (Days) ELA";
            CustLedger.SetCurrentKey("Customer No.", Open, Positive, "Due Date");
            CustLedger.SetRange("Customer No.", lrecCustomer."No.");
            CustLedger.SetRange(Open, true);
            CustLedger.SetFilter("Due Date", '<%1', DueDate);
            if CustLedger.Find('-') then begin
                repeat
                    CustLedger.CalcFields("Remaining Amount");
                    if (CustLedger."Remaining Amount" < 0) or (CustLedger."Remaining Amount" >= SalesSetup."C&C Min Overdue Invoice ELA") then
                        OverdueAmount += CustLedger."Remaining Amount";
                until CustLedger.Next = 0;
            end;
            if OverdueAmount > 0 then
                OverDue := true;
        end;
    end;


    procedure TotalOrderNotCash()
    var
        SalesHdr: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        CalcTotalTax("Document Type", "No."); // double call needed to avoid undetermined bug
        SalesHdr.Get("Document Type", "No.");
        ReleaseSalesDoc.PerformManualReopen(SalesHdr);
        Commit;
    end;
}

