page 14228918 "EN Sales Payments - Check"
{
    // ENSP1.00 2020-04-14 HR
    //      Created new page

    Caption = 'Sales Payments - Check';
    PageType = Card;
    SaveValues = true;
    SourceTable = "EN Sales Payment Header";

    layout
    {
        area(content)
        {
            group(Payment)
            {
                group(Control37002012)
                {
                    ShowCaption = false;
                    field("Check No."; CardCheckNo)
                    {
                        Caption = 'Check No.';

                        trigger OnValidate()
                        begin
                            SetPaymentType;
                        end;
                    }
                    field(PaymentAmount; PaymentAmount)
                    {
                        Caption = 'Payment Amount';
                        Editable = NOT IsVoid;
                        MinValue = 0;

                        trigger OnValidate()
                        var
                            ExpectedAmount: Decimal;
                        begin
                            BasePaymentAmount := GetBasePaymentAmount();
                            ExpectedAmount := BasePaymentAmount;
                            if (PaymentAmount > ExpectedAmount) then
                                if not Confirm(Text001, false,
                                         GetAmountStr(PaymentAmount - BasePaymentAmount),
                                         GetAmountStr(PaymentAmount))
                                then
                                    PaymentAmount := ExpectedAmount;
                            if (PaymentAmount <> ExpectedAmount) then
                                BasePaymentAmount := PaymentAmount;
                        end;
                    }
                    field(CheckMethodCode; CheckMethodCode)
                    {
                        Caption = 'Payment Method';
                        NotBlank = true;
                        TableRelation = "Payment Method" WHERE("Cash Tender Method ELA" = CONST(false),
                                                                "Bal. Account No." = FILTER(<> ''));

                        trigger OnValidate()
                        begin
                            SetPaymentMethod(true);
                        end;
                    }
                }
            }
            fixed(Sale)
            {
                group(Control37002013)
                {
                    ShowCaption = false;
                    field("'Customer No.:'"; 'Customer No.:')
                    {
                    }
                    field("'Customer Name:'"; 'Customer Name:')
                    {
                    }
                    field("'Total:'"; 'Total:')
                    {
                    }
                    field("'Paid:'"; 'Paid:')
                    {
                    }
                    field("'Balance:'"; 'Balance:')
                    {
                        AutoFormatType = 1;
                    }
                }
                group(Control37002017)
                {
                    ShowCaption = false;
                    field("Customer No."; "Customer No.")
                    {
                        Editable = false;
                        Lookup = false;
                    }
                    field("Customer Name"; "Customer Name")
                    {
                    }
                    field(Amount; Amount)
                    {
                        BlankZero = false;
                        DrillDown = false;
                    }
                    field("Amount Tendered"; "Amount Tendered")
                    {
                        BlankZero = false;
                        DrillDown = false;
                    }
                    field("GetBalance(FALSE) "; GetBalance(false))
                    {
                        AutoFormatType = 1;
                        BlankZero = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("P&ost")
            {
                Caption = 'P&ost';
                Ellipsis = true;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'F9';

                trigger OnAction()
                begin
                    if PostNonCash() then
                        CurrPage.Close;
                end;
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        Get(SalesPaymentHeader."No.");
        CalcFields(Amount, "Amount Tendered");
        exit(true);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(0);
    end;

    trigger OnOpenPage()
    begin
        Get(SalesPaymentHeader."No.");
        CalcFields(Amount, "Amount Tendered");
        SetPaymentMethod(false);
        if (CheckMethodCode = '') then
            InitPaymentMethod;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (CloseAction = ACTION::LookupOK) then // P8001149
            exit(PostNonCash());
    end;

    var
        SalesPaymentHeader: Record "EN Sales Payment Header";
        PaymentAmount: Decimal;
        BasePaymentAmount: Decimal;
        CheckMethodCode: Code[10];
        PaymentMethod: Record "Payment Method";
        CardCheckNo: Code[20];
        PaymentType: Option New,,Void;
        PrevPaymentAmount: Decimal;
        [InDataSet]
        PrevPaymentExists: Boolean;
        [InDataSet]
        IsVoid: Boolean;
        SalesPaymentMgmt: Codeunit "EN Sales Payment-Post";
        Text001: Label 'The payment exceeds the amount due from the customer by $%1.\\Are you sure you want to record the payment of $%2?';
        Text002: Label 'Nothing to Post.';
        Text005: Label 'Post payment %1 %2 (for $%3)?';
        Text008: Label 'Void payment %1 %2 (for $%3)?';


    procedure SetPayment(var SalesPaymentHeader2: Record "EN Sales Payment Header")
    begin
        SalesPaymentHeader.Copy(SalesPaymentHeader2);
    end;

    local procedure LoadPaymentMethod(TestMethodCode: Boolean)
    var
        PaymentMethodCode: Code[10];
    begin
        PaymentMethodCode := CheckMethodCode;
        Clear(PaymentMethod);
        if not PaymentMethod.Get(PaymentMethodCode) then
            Clear(PaymentMethodCode)
        else
            if PaymentMethod."Cash Tender Method ELA" or (PaymentMethod."Bal. Account No." = '') then
                Clear(PaymentMethodCode);
        if TestMethodCode and (PaymentMethodCode = '') then begin
            if (PaymentMethod.Code = '') then
                PaymentMethod.Get(PaymentMethodCode);
            PaymentMethod.TestField("Cash Tender Method ELA", false);
            PaymentMethod.TestField("Bal. Account No.");
        end;
        CheckMethodCode := PaymentMethodCode;
    end;

    local procedure SetPaymentMethod(TestMethodCode: Boolean)
    begin
        LoadPaymentMethod(TestMethodCode);
        CardCheckNo := '';
        SetPaymentType;
    end;

    local procedure InitPaymentMethod()
    begin
        PaymentMethod.SetRange("Cash Tender Method ELA", false);
        PaymentMethod.SetFilter("Bal. Account No.", '<>%1', '');
        if PaymentMethod.FindFirst then begin
            CheckMethodCode := PaymentMethod.Code;
            SetPaymentMethod(false);
        end;
    end;

    local procedure SetPaymentType()
    begin
        PrevPaymentExists := GetPrevPaymentAmount(PrevPaymentAmount);
        if not PrevPaymentExists then
            PaymentType := PaymentType::New
        else
            PaymentType := PaymentType::Void;
        SetPaymentAmount;
    end;

    local procedure GetPrevPaymentAmount(var PrevPmtAmount: Decimal): Boolean
    var
        SalesTenderEntry: Record "EN Sales Payment Tender Entry";
    begin
        if SalesTenderEntry.FindPending("No.", CheckMethodCode, CardCheckNo) then
            PrevPmtAmount := SalesTenderEntry.Amount
        else
            PrevPmtAmount := 0;
        exit(PrevPmtAmount <> 0);
    end;

    local procedure SetPaymentAmount()
    begin
        IsVoid := (PaymentType = PaymentType::Void);
        BasePaymentAmount := GetBasePaymentAmount();
        PaymentAmount := BasePaymentAmount;
    end;

    local procedure GetBasePaymentAmount() BaseAmount: Decimal
    begin
        if IsVoid then
            BaseAmount := PrevPaymentAmount
        else begin
            BaseAmount := GetBalance(false) + PrevPaymentAmount;
            if (BaseAmount < 0) then
                BaseAmount := 0;
        end;
    end;

    local procedure PostNonCash(): Boolean
    var
        SalesPaymentPost: Codeunit "EN Sales Payment-Post";
    begin
        LoadPaymentMethod(true);
        if (PaymentAmount = 0) then
            Error(Text002);
        if not Confirm(GetConfirmPostMsg()) then
            exit(false);
        case PaymentType of
            PaymentType::New:
                SalesPaymentPost.AuthorizeNonCashTender(Rec, PaymentMethod, CardCheckNo, PaymentAmount);
            PaymentType::Void:
                SalesPaymentPost.VoidNonCashTender(Rec, PaymentMethod, CardCheckNo, PaymentAmount);
        end;
        Commit;
        exit(true);
    end;

    local procedure GetConfirmPostMsg(): Text[250]
    begin
        case PaymentType of
            PaymentType::New:
                exit(StrSubstNo(Text005, CheckMethodCode, CardCheckNo, GetAmountStr(PaymentAmount)));
            PaymentType::Void:
                exit(StrSubstNo(Text008, CheckMethodCode, CardCheckNo, GetAmountStr(PaymentAmount)));
        end;
    end;


    procedure VoidNonCashEntry(var SalesTenderEntry: Record "EN Sales Payment Tender Entry")
    begin
        PaymentMethod.Get(SalesTenderEntry."Payment Method Code");
        CheckMethodCode := PaymentMethod.Code;
        Get(SalesTenderEntry."Document No.");
        CalcFields(Amount, "Amount Tendered");
        SalesPaymentHeader := Rec;
        CardCheckNo := SalesTenderEntry."Card/Check No.";
        PaymentType := PaymentType::Void;
        PrevPaymentExists := GetPrevPaymentAmount(PrevPaymentAmount);
        SetPaymentAmount;
        PostNonCash;
    end;
}

