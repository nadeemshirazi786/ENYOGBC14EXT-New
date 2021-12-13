table 14229104 "EN Posted Doc. Extra Charges"
{


    Caption = 'Posted Document Extra Charge';
    DrillDownPageID = "EN Pstd. DocLine Extra Charges";
    LookupPageID = "EN Pstd. DocLine Extra Charges";

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Extra Charge Code"; Code[10])
        {
            Caption = 'Extra Charge Code';
        }
        field(5; "Charge (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Charge ($)';
        }
        field(6; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(7; "Allocation Method"; Option)
        {
            Caption = 'Allocation Method';
            OptionCaption = ' ,Amount,Quantity,Weight,Volume,Pallet';
            OptionMembers = " ",Amount,Quantity,Weight,Volume,Pallet;
        }
        field(8; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(9; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
        }
        field(10; Charge; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Charge';
        }
        field(50000; "Posting Date"; Date)
        {

        }
        field(50001; Status; Option)
        {

            OptionMembers = ,Open,Interim,Closed;
        }
        field(50002; "EC Invoice No."; Code[10])
        {

        }
        field(50003; "EC Inv Posting Date"; Date)
        {

        }
        field(50004; "Source Line No."; Integer)
        {

        }
    }

    keys
    {
        key(Key1; "Table ID", "Document No.", "Line No.", "Extra Charge Code")
        {
            Clustered = true;
            SumIndexFields = "Charge (LCY)", Charge;
        }
        key(Key2; "Document No.", "Table ID")
        {
            SumIndexFields = "Charge (LCY)", Charge;
        }
        key(Key3; "Posting Date", Status, "Charge (LCY)")
        {
        }
    }

    fieldgroups
    {
    }

    var
        CurrExchRate: Record "Currency Exchange Rate";


    procedure UpdateCurrencyFactor(PostingDate: Date)
    begin

        if "Currency Code" <> '' then
            "Currency Factor" := CurrExchRate.ExchangeRate(PostingDate, "Currency Code")
        else
            "Currency Factor" := 0;
    end;


    procedure ChargeLCYToCharge(PostingDate: Date)
    var
        Currency2: Record Currency;
    begin

        if "Currency Code" <> '' then begin
            Currency2.Get("Currency Code");
            Charge :=
              Round(
                CurrExchRate.ExchangeAmtLCYToFCY(PostingDate, "Currency Code", "Charge (LCY)", "Currency Factor"),
                Currency2."Amount Rounding Precision")
        end else begin
            Currency2.InitRoundingPrecision;
            Charge :=
              Round("Charge (LCY)", Currency2."Amount Rounding Precision");
        end;
    end;
}

