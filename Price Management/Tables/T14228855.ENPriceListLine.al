/// <summary>
/// Table EN Price List Line (ID 14228855).
/// </summary>
table 14228855 "EN Sales Price"
{
    Caption = 'EN Price List Line';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
            TableRelation = If ("Type" = filter(0)) Item else
            if (Type = Filter(1)) "EN Item Sales Price Group".Code;

            trigger OnValidate()
            begin

                IF xRec.Code <> Code THEN BEGIN
                    "Variant Code" := '';
                    "Unit of Measure Code" := '';
                END;

                isSetPriceProtLevel;
            end;
        }
        field(2; "Sales Code"; Code[20])
        {
            Caption = 'Sales Code';
            DataClassification = ToBeClassified;
            TableRelation =
            If ("Sales Type" = filter(0)) Customer
            else
            if ("Sales Type" = Filter(1)) "Customer Price Group"
            else
            if ("Sales Type" = Filter(3)) Campaign
            else
            if ("Sales Type" = Filter(4)) "EN Customer Buying Group"
            else
            if ("Sales Type" = Filter(5)) "EN Price List Group";
            trigger OnValidate()
            begin


                IF "Sales Code" <> '' THEN BEGIN
                    CASE "Sales Type" OF
                        "Sales Type"::"All Customers":
                            ERROR(Text001, FIELDCAPTION("Sales Code"));
                        "Sales Type"::Campaign:
                            BEGIN
                                Campaign.GET("Sales Code");
                                "Starting Date" := Campaign."Starting Date";
                                "Ending Date" := Campaign."Ending Date";
                            END;
                    END;
                END;
            end;
        }
        field(3; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin

                IF ("Starting Date" > "Ending Date") AND ("Ending Date" <> 0D) THEN
                    ERROR(Text000, FIELDCAPTION("Starting Date"), FIELDCAPTION("Ending Date"));

                IF CurrFieldNo = 0 THEN
                    EXIT ELSE
                    IF "Sales Type" = "Sales Type"::Campaign THEN
                        ERROR(Text003, FIELDCAPTION("Starting Date"), FIELDCAPTION("Ending Date"), FIELDCAPTION("Sales Type"), ("Sales Type"));
            end;
        }
        field(4; "Sales Type"; Enum "EN Sales Type")
        {
            Caption = 'Sales Type';
            DataClassification = ToBeClassified;
            trigger OnValidate()

            begin

                IF "Sales Type" <> xRec."Sales Type" THEN
                    VALIDATE("Sales Code", '');

                IF "Sales Type" = "Sales Type"::Campaign THEN
                    "Unit Price Protection Level" := "Unit Price Protection Level"::Absolute;

            end;
        }
        field(5; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            DataClassification = ToBeClassified;
        }
        field(6; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = ToBeClassified;
            trigger OnValidate()

            begin

                VALIDATE("Starting Date");

                IF CurrFieldNo = 0 THEN
                    EXIT ELSE
                    IF "Sales Type" = "Sales Type"::Campaign THEN
                        ERROR(Text003, FIELDCAPTION("Starting Date"), FIELDCAPTION("Ending Date"), FIELDCAPTION("Sales Type"), ("Sales Type"));

            end;
        }
        field(7; Type; Enum "EN Price Type")
        {
            Caption = 'Type';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin

                IF xRec.Type <> Type THEN
                    VALIDATE(Code, '');
            end;
        }
        field(8; GUID; Guid)
        {
            Caption = 'GUID';
            DataClassification = ToBeClassified;
        }
        field(9; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = ToBeClassified;
            TableRelation =
                IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD(Code))
            ELSE
            IF (Type = FILTER(<> Item)) "Unit of Measure".Code;
        }
        field(10; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = ToBeClassified;
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD(Code));
            trigger OnValidate()
            begin

                TESTFIELD(Type, Type::Item);
            end;
        }
        field(11; "Del. Unit Cost Calc. Type"; Enum "EN Del. Unit Cost Calc. Type")
        {
            Caption = 'Del. Unit Cost Calc. Type';
            DataClassification = ToBeClassified;
        }
        field(12; "Del. Unit Cost Value"; Decimal)
        {
            Caption = 'Del. Unit Cost Value';
            DataClassification = ToBeClassified;
        }
        field(13; Billback; Decimal)
        {
            Caption = 'Billback';
            DataClassification = ToBeClassified;
        }
        field(14; "Contract Price"; Boolean)
        {
            Caption = 'Contract Price';
            DataClassification = ToBeClassified;
        }
        field(15; "Contract Code"; Code[20])
        {
            Caption = 'Contract Code';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin

                IF "Contract Code" <> '' THEN BEGIN
                    VALIDATE("Contract Price", TRUE);
                    ////PriceContract.GET("Contract Code");
                    ////"Starting Date" := PriceContract."Start Date";
                    ////"Ending Date" := PriceContract."End Date";
                END ELSE
                    VALIDATE("Contract Price", FALSE);
            end;
        }
        field(16; "Ship-From Location"; Code[10])
        {
            Caption = 'Ship-From Location';
            DataClassification = ToBeClassified;
            TableRelation = Location.Code;
        }
        field(17; "Starting Order Date"; Date)
        {
            Caption = 'Starting Order Date';
            DataClassification = ToBeClassified;
        }
        field(18; "Ending Order Date"; Date)
        {
            Caption = 'Ending Order Date';
            DataClassification = ToBeClassified;
        }
        field(19; "Calculation Cost Base"; Enum "EN Calculation Cost Base")
        {
            Caption = 'Calculation Cost Base';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin

                IF "Calculation Cost Base" = "Calculation Cost Base"::"Alt. Cost (Base)" THEN
                    "Calculation Type" := "Calculation Type"::"Value";
            end;
        }
        field(20; "Calculation Type"; Enum "EN Calculation Type")
        {
            Caption = 'Calculation Type';
            DataClassification = ToBeClassified;
        }
        field(21; Value; Decimal)
        {
            Caption = 'Value';
            DataClassification = ToBeClassified;
        }
        field(22; "Rounding Precision"; Decimal)
        {
            Caption = 'Rounding Precision';
            DataClassification = ToBeClassified;
        }
        field(23; "Price Calc. Treatment"; Enum "EN Price Calc. Treatment")
        {
            Caption = 'Price Calc. Treatment';
            DataClassification = ToBeClassified;
        }
        field(24; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = ToBeClassified;
            TableRelation = "Reason Code".Code;
        }
        field(25; "Rounding Method"; Code[10])
        {
            Caption = 'Rounding Method';
            DataClassification = ToBeClassified;
            TableRelation = "Rounding Method".Code;
        }
        field(26; "Alternate Sales Cost Filter"; Code[10])
        {
            Caption = 'Alternate Sales Cost Filter';
            DataClassification = ToBeClassified;
        }
        field(27; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            DataClassification = ToBeClassified;
        }
        field(28; "Price Rule"; Boolean)
        {
            Caption = 'Price Rule';
            DataClassification = ToBeClassified;
        }
        field(29; "Price Rule Code"; Code[10])
        {
            Caption = 'Price Rule Code';
            DataClassification = ToBeClassified;
            TableRelation = "EN Price Rule";
        }
        field(30; "Calculated Price"; Decimal)
        {
            Caption = 'Calculated Price';
            DataClassification = ToBeClassified;
        }
        field(31; "Price Calc. Ranking"; Integer)
        {
            Caption = 'Price Calc. Ranking';
            DataClassification = ToBeClassified;
        }
        field(32; "Unit Price Protection Level"; Enum "EN Unit Price Protection Level")
        {
            Caption = 'Unit Price Protection Level';
            DataClassification = ToBeClassified;
        }
        field(33; "Calculation Base Price"; Decimal)
        {
            Caption = 'Calculation Base Price';
            DataClassification = ToBeClassified;
        }
        field(34; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
            DataClassification = ToBeClassified;
        }
        field(35; "VAT Bus. Posting Gr. (Price)"; Boolean)
        {
            Caption = 'Tax Bus. Posting Gr. (Price)';
            TableRelation = "VAT Business Posting Group";
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; Type, Code, "Sales Type", "Sales Code", "Starting Date", "Variant Code", "Unit of Measure Code", "Minimum Quantity", "Contract Price", "Ship-From Location")
        {
            Clustered = true;
        }
        key(SalesType; "Sales Type", "Sales Code", Type, Code, "Starting Date", "Variant Code", "Unit of Measure Code", "Minimum Quantity")
        {

        }
        key(PriceRank; "Price Calc. Ranking")
        {

        }
        key(GUIDKey; "GUID")
        {

        }
    }
    trigger OnInsert()
    begin

        IF "Sales Type" = "Sales Type"::"All Customers" THEN
            "Sales Code" := ''
        ELSE
            TESTFIELD("Sales Code");
        TESTFIELD(Code);

        SetGUID;
        isSetPriceProtLevel;

    end;

    trigger OnModify()
    begin
        isSetPriceProtLevel;
    end;

    trigger OnRename()
    begin

        IF "Sales Type" <> "Sales Type"::"All Customers" THEN
            TESTFIELD("Sales Code");
        TESTFIELD(Code);
    end;

    var
        CustPriceGr: Record "Customer Price Group";
        Cust: Record "Customer";
        Campaign: Record "Campaign";
        ////PriceContract:Record "Price Contract";

        Text000: Label '%1 cannot be after %2';
        Text001: Label '%1 must be blank.';
        Text003: Label 'You can only change the %1 and %2 from the Campaign Card when %3 = %4';
        Text004: Label 'Margin Calculation types must use a Cost Based Calulation.  Please choose a Calculation Base that is Cost Based.';

    /// <summary>
    /// SetGUID.
    /// </summary>
    /// <returns>Return value of type Boolean.</returns>
    procedure SetGUID(): Boolean
    begin

        IF ISNULLGUID(GUID) THEN BEGIN
            GUID := CREATEGUID;
            EXIT(TRUE);

        end;
    end;

    /// <summary>
    /// isCalcDelUnitCost.
    /// </summary>
    /// <returns>Return value of type Decimal.</returns>
    procedure isCalcDelUnitCost(): Decimal
    var
        ldecPrice: Decimal;
        lcduSalesPriceCalcMgt: Codeunit "EN Sales Price Calc. Mgt.";
        lrecItem: Record "Item";
        lrecGLSetup: Record "General Ledger Setup";
    begin

        IF (Type <> Type::Item) THEN EXIT(0);
        IF NOT lrecItem.GET(Code) THEN EXIT(0);
        ldecPrice := lcduSalesPriceCalcMgt.ExecutePriceCalcCalcultion(Rec, lrecItem);
        IF "Del. Unit Cost Value" <> 0 THEN BEGIN
            CASE "Del. Unit Cost Calc. Type" OF
                "Del. Unit Cost Calc. Type"::Value:
                    BEGIN
                        ldecPrice += "Del. Unit Cost Value";
                    END;
                "Del. Unit Cost Calc. Type"::Percent:
                    BEGIN
                        ldecPrice += ldecPrice * ("Del. Unit Cost Value" / 100)
                    END;
            END;
        END;
        EXIT(ROUND(ldecPrice, 0.01));

    end;

    /// <summary>
    /// isSetPriceProtLevel.
    /// </summary>
    procedure isSetPriceProtLevel()
    var
        lItem: Record "Item";
    begin

        IF NOT ISNULLGUID(GUID) THEN
            EXIT;

        IF (Type <> Type::Item) OR (Code = '') THEN
            EXIT;
        IF NOT lItem.GET(Code) THEN
            EXIT;
        //"Unit Price Protection Level" := lItem."Unit Price Protection Level";

    end;

}
