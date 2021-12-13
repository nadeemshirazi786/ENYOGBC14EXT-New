page 14228883 "EN C&C Receive Cash"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = StandardDialog;
    SourceTable = "Sales Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Tendered; Tendered)
                {
                    Caption = 'Amount Tendered';
                    Editable = true;

                    trigger OnValidate()
                    begin
                        Tendered := MAX(0, Tendered);

                        AppliedToOrder := AppliedToOrderLogic(Tendered);

                        ApplyToOtherOrders := MIN(ApplyToOtherOrders, Tendered - AppliedToOrder);
                    end;
                }
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
                field(AppliedToOrder; AppliedToOrder)
                {
                    Caption = 'Applied to This Order';
                    Editable = true;

                    trigger OnValidate()
                    var
                        lctxtBalAccountNoMayNotBeBLANK: Label 'The %1 may not be ''%2''. Would you like to set the %3 to %4?';
                    begin

                        AppliedToOrder := AppliedToOrderLogic(AppliedToOrder);
                    end;
                }
                field(ApplyToOtherOrders; ApplyToOtherOrders)
                {
                    Caption = 'Apply to Other Orders';

                    trigger OnValidate()
                    begin
                        ApplyToOtherOrders := MIN(ApplyToOtherOrders, Tendered - AppliedToOrder);
                        ApplyToOtherOrders := MAX(0, ApplyToOtherOrders);
                    end;
                }
                field(Applied; Applied)
                {
                    Caption = 'Applied to Other Orders';
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        Payment: Record "Gen. Journal Line";
                        ApplyPymt: Codeunit "Gen. Jnl.-Apply";
                    begin

                        CreatePayment(Payment);
                        ApplyPymt.Run(Payment);

                        Applied := CalcApplied;
                    end;
                }
                field("Change Due"; ChangeDue())
                {
                    Caption = 'Change Due';
                    Editable = false;
                }
                field("<Balance>"; grecCustomer."Balance (LCY)")
                {
                    Caption = 'Balance($)';
                    Editable = false;

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
                field("<Total Incl. this order>"; grecCustomer."Balance (LCY)" + "Amount Including VAT")
                {
                    Caption = 'Total Incl. this Order';
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
        SalesHeader.GET(Rec."Document Type", Rec."No.");

        Tendered := SalesHeader."Cash Tendered ELA";
        AppliedToOrder := SalesHeader."Cash Applied (Current) ELA";
        ApplyToOtherOrders := SalesHeader."Entered Amount to Apply ELA";
        Applied := CalcApplied();

        Clear(grecCustomer);
        if grecCustomer.Get(SalesHeader."Bill-to Customer No.") then begin
            grecCustomer.CalcFields("Balance (LCY)");
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var

        lctxtAppliedAmoundDoesNotMatchAmountToApply: Label 'The amount Applied to other orders does not match the Amount to Apply to Other Orders.';
        lAmountRemaining: Decimal;
    begin
        lAmountRemaining := ibGetPaymentAmount();
        Applied := CalcApplied();

        if (
          (CloseAction = ACTION::OK)
        ) then begin
            SalesHeader.GET(Rec."Document Type", Rec."No.");
            SalesHeader."Cash vs Amount Incld Tax ELA" := "Amount Including VAT";
            SalesHeader."Cash Tendered ELA" := Tendered;
            SalesHeader."Cash Applied (Current) ELA" := AppliedToOrder;
            SalesHeader."Entered Amount to Apply ELA" := ApplyToOtherOrders;
            SalesHeader."Cash Applied (Other) ELA" := Applied;
            SalesHeader.Modify(true);
            Commit;


        end else begin

            Tendered := "Cash Tendered ELA";
            AppliedToOrder := "Cash Applied (Current) ELA";
            ApplyToOtherOrders := "Entered Amount to Apply ELA";

        end;
        if (
          ((ApplyToOtherOrders <> Applied) or (ApplyToOtherOrders <> lAmountRemaining))
        ) then begin
            Error(lctxtAppliedAmoundDoesNotMatchAmountToApply);
        end;
    end;

    var
        Tendered: Decimal;
        Applied: Decimal;
        AppliedToOrder: Decimal;
        ApplyToOtherOrders: Decimal;
        grecGenJnlLine_ExistingPayment: Record "Gen. Journal Line";
        grecCustomer: Record Customer;
        gpagSalesOrderCC: Page "EN Sales Order C&C Card";
        grecUserSetup: Record "User Setup";
        grecSalesAndRecSetup: Record "Sales & Receivables Setup";
        SalesHeader: Record "Sales Header";


    procedure ChangeDue() Change: Decimal
    begin
        Change := Tendered - AppliedToOrder - ApplyToOtherOrders;
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


    procedure SetOrder(precSalesHeader: Record "Sales Header")
    begin

        precSalesHeader.TestField("No.");

        FilterGroup(10);

        SetRange("Document Type", precSalesHeader."Document Type");
        SetRange("No.", precSalesHeader."No.");

        FilterGroup(0);
    end;


    procedure CreatePayment(var Payment: Record "Gen. Journal Line")
    var
        SalesSetup: Record "Sales & Receivables Setup";
        SalesHeader: Record "Sales Header";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        lrecPaymentMethod: Record "Payment Method";
        lintNextLine: Integer;
    begin

        SalesSetup.Get;
        SalesHeader.Get("Document Type", "No.");
        YGGetUserSetupForCCInfo;

        if (grecUserSetup.IsEmpty) or (grecUserSetup."CC Journal Template ELA" = '') then begin
            Payment.SetRange("Journal Template Name", grecSalesAndRecSetup."C&C Journal Template ELA");
            Payment.SetRange("Journal Batch Name", grecSalesAndRecSetup."C&C Cash Journal Batch ELA");
        end
        else begin
            Payment.SetRange("Journal Template Name", grecUserSetup."CC Journal Template ELA");
            Payment.SetRange("Journal Batch Name", grecUserSetup."CC Cash Journal Batch ELA");
        end;
        Payment.SetRange("Document No.", "No.");
        if not Payment.FindFirst then begin
            Payment.SetRange("Document No.");
            if Payment.FindLast then
                lintNextLine := Payment."Line No." + 10000
            else
                lintNextLine := 10000;

            Payment.Init;
            if (grecUserSetup.IsEmpty) or (grecUserSetup."CC Journal Template ELA" = '') then begin
                Payment.SetRange("Journal Template Name", grecSalesAndRecSetup."C&C Journal Template ELA");
                Payment.SetRange("Journal Batch Name", grecSalesAndRecSetup."C&C Cash Journal Batch ELA");
                Payment."Journal Template Name" := grecSalesAndRecSetup."C&C Cash Journal Batch ELA";
                Payment."Journal Batch Name" := grecSalesAndRecSetup."C&C Cash Journal Batch ELA";
            end
            else begin
                Payment.SetRange("Journal Template Name", grecUserSetup."CC Journal Template ELA");
                Payment.SetRange("Journal Batch Name", grecUserSetup."CC Cash Journal Batch ELA");
                Payment."Journal Template Name" := grecUserSetup."CC Journal Template ELA";
                Payment."Journal Batch Name" := grecUserSetup."CC Cash Journal Batch ELA";

            end;


            Payment."Line No." := lintNextLine;
            Payment.Insert;
        end;

        if (grecUserSetup.IsEmpty) or (grecUserSetup."CC Journal Template ELA" = '') then begin
            GenJnlTemplate.Get(grecSalesAndRecSetup."C&C Journal Template ELA");
            GenJnlTemplate.Get(grecSalesAndRecSetup."C&C Cash Journal Batch ELA");
        end
        else begin
            GenJnlTemplate.Get(grecUserSetup."CC Journal Template ELA");

            GenJnlBatch.Get(grecUserSetup."CC Journal Template ELA", grecUserSetup."CC Cash Journal Batch ELA");
        end;

        Payment.Validate("Posting Date", SalesHeader."Posting Date");
        Payment.Validate("Document Type", Payment."Document Type"::Payment);
        Payment.Validate("Document No.", "No.");
        Payment.Validate("Account Type", Payment."Account Type"::Customer);
        Payment.Validate("Account No.", SalesHeader."Bill-to Customer No.");
        Payment."Source Code" := GenJnlTemplate."Source Code";
        Payment."Reason Code" := GenJnlBatch."Reason Code";
        Payment."Posting No. Series" := GenJnlBatch."Posting No. Series";

        lrecPaymentMethod.Get('CASHCARRY');
        Payment.Validate("Payment Method Code", lrecPaymentMethod.Code);

        Evaluate(Payment."Bal. Account Type", Format(lrecPaymentMethod."Bal. Account Type"));
        Payment.Validate("Bal. Account Type");

        Payment.Validate("Bal. Account No.", lrecPaymentMethod."Bal. Account No.");


        Payment.Validate(Amount, -ApplyToOtherOrders);
        Payment.Modify;
        Commit;
    end;


    procedure CalcApplied() Applied: Decimal
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgEntry.Reset;
        CustLedgEntry.SetCurrentKey("Customer No.", Open, Positive);
        CustLedgEntry.SetRange("Customer No.", "Bill-to Customer No.");
        CustLedgEntry.SetRange(Open, true);
        CustLedgEntry.SetRange("Applies-to ID", "No.");
        if CustLedgEntry.Find('-') then begin
            repeat
                Applied += CustLedgEntry."Amount to Apply";
            until CustLedgEntry.Next = 0;
        end;
    end;

    local procedure AppliedToOrderLogic(pdecAppliedToOrder: Decimal) pdecResult: Decimal
    begin
        if (
          (pdecAppliedToOrder > 0)
        ) then begin
            SetBalAccountNoIfNone;
            TestField("Bal. Account No.");
        end;

        pdecAppliedToOrder := MIN(pdecAppliedToOrder, Tendered - ApplyToOtherOrders);

        pdecAppliedToOrder := MAX(0, pdecAppliedToOrder);

        pdecAppliedToOrder := MIN(pdecAppliedToOrder, "Amount Including VAT");

        exit(pdecAppliedToOrder);
    end;

    local procedure SetBalAccountNoIfNone()
    begin
        if (
          ("Bal. Account No." = '')
        ) then begin
            if (true

            ) then begin
                Validate("Payment Method Code", 'CASHCARRY');
                Modify(true);
            end;
        end;
    end;


    procedure YGGetUserSetupForCCInfo()
    begin

        grecUserSetup.SetFilter("User ID", UserId);
        if grecUserSetup.FindFirst then;

        if grecSalesAndRecSetup.FindFirst then;
    end;


    procedure ibGetPaymentAmount(): Decimal
    var
        SalesSetup: Record "Sales & Receivables Setup";
        SalesHeader: Record "Sales Header";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        lrecPaymentMethod: Record "Payment Method";
        lintNextLine: Integer;
        lPayment: Record "Gen. Journal Line";
        lAmountRemaining: Decimal;
    begin

        lAmountRemaining := 0;
        SalesSetup.Get;
        SalesHeader.Get("Document Type", "No.");
        YGGetUserSetupForCCInfo;

        if (grecUserSetup.IsEmpty) or (grecUserSetup."CC Journal Template ELA" = '') then begin
            lPayment.SetRange("Journal Template Name", grecSalesAndRecSetup."C&C Journal Template ELA");
            lPayment.SetRange("Journal Batch Name", grecSalesAndRecSetup."C&C Cash Journal Batch ELA");
        end else begin
            lPayment.SetRange("Journal Template Name", grecUserSetup."CC Journal Template ELA");
            lPayment.SetRange("Journal Batch Name", grecUserSetup."CC Cash Journal Batch ELA");
        end;

        lPayment.SetRange("Document Type", lPayment."Document Type"::Payment);
        lPayment.SetRange("Document No.", "No.");
        if lPayment.FindFirst then begin
            lPayment.Validate(Amount, -ApplyToOtherOrders);
            lPayment.Modify;
            Commit;

            lAmountRemaining := lPayment.Amount;
        end;

        exit(-1 * lAmountRemaining);
    end;
}

