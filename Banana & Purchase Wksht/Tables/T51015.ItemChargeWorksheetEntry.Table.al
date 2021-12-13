table 51015 "Item Charge Worksheet Entry"
{
    PasteIsValid = false;

    fields
    {
        field(1; "Applies-To Document Type"; Enum ApplToDocType)
        {
        }
        field(2; "Applies-To Document No."; Code[20])
        {
            TableRelation = IF ("Applies-To Functional Area" = CONST(Purchase)) "Purchase Header"."No." WHERE("Document Type" = FIELD("Applies-To Document Type"))
            ELSE
            IF ("Applies-To Functional Area" = CONST(Sales)) "Sales Header"."No." WHERE("Document Type" = FIELD("Applies-To Document Type"))
            ELSE
            IF ("Applies-To Functional Area" = CONST(Transfer)) "Transfer Header"."No.";
        }
        field(3; "Applies-To Document Line No."; Integer)
        {
            BlankZero = true;
            TableRelation = IF ("Applies-To Functional Area" = CONST(Purchase)) "Purchase Line"."Line No." WHERE("Document Type" = FIELD("Applies-To Document Type"),
                                                                                                                "Document No." = FIELD("Applies-To Document No."))
            ELSE
            IF ("Applies-To Functional Area" = CONST(Sales)) "Sales Line"."Line No." WHERE("Document Type" = FIELD("Applies-To Document Type"),
                                                                                                                                                                                                   "Document No." = FIELD("Applies-To Document No."))
            ELSE
            IF ("Applies-To Functional Area" = CONST(Transfer)) "Transfer Line"."Line No." WHERE("Derived From Line No." = FILTER(0));
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; "Item Charge No."; Code[20])
        {
            Caption = 'Item Charge No.';
            NotBlank = true;
            TableRelation = "Item Charge";

            trigger OnValidate()
            var
                lrecItemCharge: Record "Item Charge";
            begin
            end;
        }
        field(6; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(7; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(8; "Qty. to Assign"; Decimal)
        {
            BlankZero = true;
            Caption = 'Qty. to Assign';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                Validate("Amount to Assign");
            end;
        }
        field(10; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';

            trigger OnValidate()
            begin
                Validate("Amount to Assign");
                jfCalcLCYField(FieldNo("Unit Cost"));
            end;
        }
        field(11; "Amount to Assign"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount to Assign';
            Editable = false;

            trigger OnValidate()
            begin
                if "Applies-To Functional Area" = "Applies-To Functional Area"::Purchase then begin
                    grecPurchHeader.Get("Applies-To Document Type", "Applies-To Document No.");

                    if not grecCurrency.Get(grecPurchHeader."Currency Code") then
                        grecCurrency.InitRoundingPrecision;

                    "Amount to Assign" := Round("Qty. to Assign" * "Unit Cost", grecCurrency."Amount Rounding Precision");

                    jfCalcLCYField(FieldNo("Amount to Assign"));
                end else
                    if "Applies-To Functional Area" = "Applies-To Functional Area"::Sales then begin
                        grecSalesHeader.Get("Applies-To Document Type", "Applies-To Document No.");

                        if not grecCurrency.Get(grecSalesHeader."Currency Code") then
                            grecCurrency.InitRoundingPrecision;

                        "Amount to Assign" := Round("Qty. to Assign" * "Unit Cost", grecCurrency."Amount Rounding Precision");

                        jfCalcLCYField(FieldNo("Amount to Assign"));
                    end;
            end;
        }
        field(12; "Distribution Type"; Enum DistributionType)
        {

        }
        field(13; "Unit Cost (LCY)"; Decimal)
        {
            Editable = false;
        }
        field(14; "Amount To Assign (LCY)"; Decimal)
        {
            Editable = false;
        }
        field(15; "Posting Date"; Date)
        {

            trigger OnValidate()
            begin
                UpdateCurrencyFactor;

                jfCalcAllLCYFields;
            end;
        }
        field(16; "Cost Type"; Enum CostType)
        {

            trigger OnValidate()
            begin
                if "Cost Type" = "Cost Type"::Document then
                    "Applies-To Document Line No." := 0
                else
                    "Distribution Type" := "Distribution Type"::Amount;
            end;
        }
        field(17; "Currency Code"; Code[10])
        {
            Editable = false;
            TableRelation = Currency;

            trigger OnValidate()
            begin
            end;
        }
        field(18; "Unit of Measure Code"; Code[10])
        {
            TableRelation = "Unit of Measure";
        }
        field(19; "Vendor No."; Code[20])
        {
            TableRelation = Vendor;

            trigger OnValidate()
            var
                lrecVendor: Record Vendor;

            begin
                if "Vendor No." <> '' then begin
                    lrecVendor.Get("Vendor No.");
                    Validate("Currency Code", lrecVendor."Currency Code");
                end else begin
                    Validate("Currency Code", '');
                end;
                UpdateCurrencyFactor;
                jfCalcAllLCYFields;
            end;
        }
        field(20; "Applies-To Functional Area"; Enum ApplToFunctionalArea)
        {

        }
        field(21; Processed; Boolean)
        {
            Editable = false;
        }
        field(23; "Document No."; Code[20])
        {
            Editable = false;
            TableRelation = IF ("Document Type" = CONST("Purchase Invoice")) "Purchase Header"."No." WHERE("Document Type" = CONST(Invoice),
                                                                                                          "No." = FIELD("Document No."))
            ELSE
            IF ("Document Type" = CONST("Purchase Order")) "Purchase Header"."No." WHERE("Document Type" = CONST(Order),
                                                                                                                                                                                           "No." = FIELD("Document No."));
        }
        field(24; "Currency Factor"; Decimal)
        {
            DecimalPlaces = 0 : 15;

            trigger OnValidate()
            begin
                jfCalcAllLCYFields;
            end;
        }
        field(25; "Make Invoice"; Boolean)
        {
        }
        field(26; "Document Type"; Enum DocType)
        {
            Caption = 'Document Type';
            Description = 'JF12265SHR';
            Editable = false;
        }
        field(27; "Accrue Item Charges on Rcpt."; Boolean)
        {
            Caption = 'Accrue Item Charges on Rcpt.';
            Description = 'JF12265SHR';

            trigger OnValidate()
            begin
                if "Accrue Item Charges on Rcpt." then begin
                    "Document Type" := "Document Type"::"Purchase Order";
                end else begin
                    "Document Type" := "Document Type"::"Purchase Invoice";
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Applies-To Functional Area", "Applies-To Document Type", "Applies-To Document No.", "Applies-To Document Line No.", "Line No.")
        {
            Clustered = true;
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount To Assign (LCY)";
        }
        key(Key2; "Vendor No.", "Posting Date", "Applies-To Document Type", "Applies-To Document No.")
        {
            MaintainSIFTIndex = false;
        }
        key(Key3; "Item No.", "Item Charge No.", "Vendor No.", "Posting Date")
        {
            SumIndexFields = "Amount to Assign", "Amount To Assign (LCY)";
        }
        key(Key4; "Applies-To Document Type", "Applies-To Document No.", "Applies-To Document Line No.")
        {
        }
        key(Key5; "Vendor No.", "Posting Date", "Accrue Item Charges on Rcpt.", "Applies-To Document Type", "Applies-To Document No.")
        {
        }
    }

    trigger OnInsert()
    begin
        grecPurchSetup.Get;
    end;

    trigger OnModify()
    begin
        TestField("Document No.", '');
    end;

    var
        Text000: Label 'You cannot assign item charges to the %1 because it has been invoiced. Instead you can get the posted document line and then assign the item charge to that line.';
        grecPurchHeader: Record "Purchase Header";
        grecSalesHeader: Record "Sales Header";
        grecTransHeader: Record "Transfer Header";
        grecCurrency: Record Currency;
        grecPurchSetup: Record "Purchases & Payables Setup";
        gcduItemChargeAssgntPurch: Codeunit "Item Charge Assgnt. (Purch.)";
        gblnHideMessage: Boolean;
        gcon000: Label 'Purchase %1 No. %2, Line No. %3 was succcessfully created for the item charge.';

    [Scope('Internal')]
    procedure jfCalcLCYField(pintFieldNo: Integer)
    var
        lrecCurrExchRate: Record "Currency Exchange Rate";
        lrecPurchHeader: Record "Purchase Header";
        ldteUseDate: Date;
    begin
        case pintFieldNo of
            FieldNo("Unit Cost"):
                begin
                    ldteUseDate := "Posting Date";
                    "Unit Cost (LCY)" := lrecCurrExchRate.ExchangeAmtFCYToLCY(
                                         ldteUseDate, "Currency Code", "Unit Cost",
                                         "Currency Factor");

                end;
            FieldNo("Amount to Assign"):
                begin
                    ldteUseDate := "Posting Date";
                    "Amount To Assign (LCY)" := lrecCurrExchRate.ExchangeAmtFCYToLCY(
                                                ldteUseDate, "Currency Code", "Amount to Assign",
                                                "Currency Factor");

                end;
        end;
    end;

    [Scope('Internal')]
    procedure jfCalcAllLCYFields()
    begin
        jfCalcLCYField(FieldNo("Amount to Assign"));
        jfCalcLCYField(FieldNo("Unit Cost"));
    end;

    local procedure UpdateCurrencyFactor()
    var
        Currencydate: Date;
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if "Currency Code" <> '' then begin
            if "Posting Date" <> 0D then begin
                Currencydate := WorkDate
            end else begin
                Currencydate := "Posting Date";
            end;

            "Currency Factor" := CurrExchRate.ExchangeRate(Currencydate, "Currency Code");
        end else
            "Currency Factor" := 0;
    end;
}

