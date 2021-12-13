table 14229101 "EN Document Extra Charge"
{

    Caption = 'Document Extra Charge';
    DrillDownPageID = "EN Document Line Extra Charges";
    LookupPageID = "EN Document Line Extra Charges";

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            NotBlank = true;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            NotBlank = true;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Extra Charge Code"; Code[10])
        {
            Caption = 'Extra Charge Code';
            NotBlank = true;
            TableRelation = "EN Extra Charge";

            trigger OnValidate()
            begin
                if ("Line No." = 0) and ("Extra Charge Code" <> xRec."Extra Charge Code") then begin
                    ExtraCharge.Get("Extra Charge Code");
                    "Allocation Method" := ExtraCharge."Allocation Method";
                end;
            end;
        }
        field(5; "Charge (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Charge ($)';
            Editable = false;

            trigger OnValidate()
            var
                Currency2: Record Currency;
            begin

                if "Currency Code" <> '' then begin
                    Currency2.Get("Currency Code");
                    Charge :=
                      Round(
                        CurrExchRate.ExchangeAmtLCYToFCY(WorkDate, "Currency Code", "Charge (LCY)", "Currency Factor"),
                        Currency2."Amount Rounding Precision")
                end else begin
                    Currency2.InitRoundingPrecision;
                    Charge :=
                      Round("Charge (LCY)", Currency2."Amount Rounding Precision");
                end;

            end;
        }
        field(6; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;

            trigger OnValidate()
            begin

                if "Vendor No." = '' then
                    Validate("Currency Code", '')
                else begin

                    Vendor.Get("Vendor No.");
                    Validate("Currency Code", Vendor."Currency Code");
                end;

            end;
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

            trigger OnValidate()
            begin

                if "Currency Code" <> xRec."Currency Code" then begin
                    UpdateCurrencyFactor;
                    Validate(Charge);
                end;
            end;
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

            trigger OnValidate()
            var
                Currency2: Record Currency;
            begin

                Currency2.InitRoundingPrecision;
                if "Currency Code" <> '' then
                    "Charge (LCY)" :=
                      Round(
                        CurrExchRate.ExchangeAmtFCYToLCY(WorkDate, "Currency Code", Charge, "Currency Factor"),
                        Currency2."Amount Rounding Precision")
                else
                    "Charge (LCY)" :=
                      Round(Charge, Currency2."Amount Rounding Precision");
            end;
        }
        field(11; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
    }

    keys
    {
        key(Key1; "Table ID", "Document Type", "Document No.", "Line No.", "Extra Charge Code")
        {
            Clustered = true;
            SumIndexFields = "Charge (LCY)", Charge;
        }
        key(Key2; "Extra Charge Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestStatusOpen;
    end;

    trigger OnInsert()
    begin
        TestStatusOpen;
    end;

    trigger OnModify()
    begin
        TestStatusOpen;
    end;

    trigger OnRename()
    begin
        TestStatusOpen;
    end;

    var
        PurchHeader: Record "Purchase Header";
        TransHeader: Record "Transfer Header";
        ExtraCharge: Record "EN Extra Charge";
        Vendor: Record Vendor;
        CurrExchRate: Record "Currency Exchange Rate";


    procedure TestStatusOpen()
    begin

        case "Table ID" of
            DATABASE::"Purchase Header", DATABASE::"Purchase Line":
                begin

                    PurchHeader.Get("Document Type", "Document No.");
                    PurchHeader.TestField(Status, PurchHeader.Status::Open);

                end;
            DATABASE::"Transfer Header", DATABASE::"Transfer Line":
                begin
                    TransHeader.Get("Document No.");
                    TransHeader.TestField(Status, TransHeader.Status::Open);
                end;
        end;

    end;


    procedure UpdateCurrencyFactor()
    begin

        if "Currency Code" <> '' then
            "Currency Factor" := CurrExchRate.ExchangeRate(WorkDate, "Currency Code")
        else
            "Currency Factor" := 0;
    end;


    procedure InitRecord()
    var
        PurchHeader: Record "Purchase Header";
    begin

        if "Table ID" in [DATABASE::"Purchase Header", DATABASE::"Purchase Line"] then
            if "Line No." <> 0 then begin
                PurchHeader.Get("Document Type", "Document No.");
                Validate("Currency Code", PurchHeader."Currency Code");
            end;
    end;
}

