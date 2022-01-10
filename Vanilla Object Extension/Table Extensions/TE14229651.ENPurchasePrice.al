tableextension 14229651 "Purchase Price ELA" extends "Purchase Price"
{
    fields
    {
        field(14229000; "Upcharge Type ELA"; Enum "EN Upcharge Type")
        {
            Caption = 'Upcharge Type';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                isCalcYogAmounts("Unit of Measure Code");
            end;
        }
        field(14229001; "Upcharge Value ELA"; Decimal)
        {
            Caption = 'Upcharge Value';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                isCalcYogAmounts("Unit of Measure Code");
            end;
        }
        field(14229002; "Billback Type ELA"; Enum "EN Billback Type")
        {
            Caption = 'Billback Type';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                isCalcYogAmounts("Unit of Measure Code");
            end;
        }
        field(14229003; "Billback Value ELA"; Decimal)
        {
            Caption = 'Billback Value';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                isCalcYogAmounts("Unit of Measure Code");
            end;
        }
        field(14229004; "Discount 1 Type ELA"; Enum "EN Discount 1 Type")
        {
            Caption = 'Discount 1 Type';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                isCalcYogAmounts("Unit of Measure Code");
            end;
        }
        field(14229005; "Discount 1 Value ELA"; Decimal)
        {
            Caption = 'Discount 1 Value';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                isCalcYogAmounts("Unit of Measure Code");
            end;
        }
        field(14229006; "Upcharge Amount ELA"; Decimal)
        {
            Caption = 'Upcharge Amount';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                isCalcYogAmounts("Unit of Measure Code");
            end;
        }
        field(14229007; "Billback Amount ELA"; Decimal)
        {
            Caption = 'Billback Amount';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                isCalcYogAmounts("Unit of Measure Code");
            end;
        }
        field(14229008; "List Cost ELA"; Decimal)
        {
            Caption = 'List Cost';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229009; "Freight Type ELA"; enum "EN Freight Type")
        {
            Caption = 'Freight Type';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                isCalcYogAmounts("Unit of Measure Code");
            end;
        }
        field(14229010; "Freight Value ELA"; Decimal)
        {
            Caption = 'Freight Value';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                isCalcYogAmounts("Unit of Measure Code");
            end;
        }
        field(14229011; "Freight Amount ELA"; Decimal)
        {
            Caption = 'Freight Amount';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                isCalcYogAmounts("Unit of Measure Code");
            end;
        }
        field(14229012; "Item Description ELA"; Text[100])
        {
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(Item.Description WHERE("No." = FIELD("Item No.")));
        }
        field(14229013; "Location Code ELA"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(14229014; "Purchase Type ELA"; Enum "EN Purchase Type")
        {
            Caption = 'Purchase Type';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin

                IF "Purchase Type ELA" <> xRec."Purchase Type ELA" THEN BEGIN
                    VALIDATE("Vendor No.", '');
                    VALIDATE("Order Address Code ELA", '');
                END;

            end;
        }
        field(14229015; "Order Address Code ELA"; Code[10])
        {
            Caption = 'Order Address Code';
            TableRelation = IF ("Purchase Type ELA" = CONST(Vendor)) "Order Address".Code WHERE("Vendor No." = FIELD("Vendor No."));
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin

                IF "Order Address Code ELA" <> '' THEN BEGIN
                    TESTFIELD("Purchase Type ELA", "Purchase Type ELA"::Vendor);
                END;
            end;
        }
        field(14229016; "Specific Pricing Rank ELA"; Integer)
        {
            Caption = 'Specific Pricing Rank';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229017; "Reason Code ELA"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = ToBeClassified;
            TableRelation = "Reason Code".Code;
        }
        field(14229018; "Discount 1 Amount ELA"; Decimal)
        {
            Caption = 'Discount 1 Amount';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                isCalcYogAmounts("Unit of Measure Code");
            end;
        }
        modify("Vendor No.")
        {
            trigger OnAfterValidate()
            begin

                IF "Vendor No." <> '' THEN BEGIN
                    CASE "Purchase Type ELA" OF
                        "Purchase Type ELA"::"All Vendors":
                            ERROR(ELAText001, FIELDCAPTION("Vendor No."));
                        "Purchase Type ELA"::"Vendor Price Group":
                            BEGIN
                                //nothing at this time
                            END;
                        "Purchase Type ELA"::Vendor:
                            BEGIN
                                Vend.GET("Vendor No.");
                                "Currency Code" := Vend."Currency Code";
                            END;
                    END;
                END;
            end;
        }
        modify("Direct Unit Cost")
        {
            trigger OnAfterValidate()
            begin
                isCalcYogAmounts("Unit of Measure Code");
            end;
        }
    }
    keys
    {
        key(Key1; "Purchase Type ELA", "Location Code ELA")
        {
        }
    }
    trigger OnBeforeInsert()
    begin

        IF "Purchase Type ELA" = "Purchase Type ELA"::"All Vendors" THEN
            "Vendor No." := ''
        ELSE
            TESTFIELD("Vendor No.");
    end;

    trigger OnBeforeModify()
    begin
        isCalcYogAmounts("Unit of Measure Code");
    end;

    trigger OnBeforeRename()
    begin

        IF "Purchase Type ELA" <> "Purchase Type ELA"::"All Vendors" THEN
            TESTFIELD("Vendor No.");
    end;

    procedure isCalcYogAmounts(pcodUOM: Code[20])
    begin

        "Upcharge Amount ELA" := 0;
        "Billback Amount ELA" := 0;
        "Discount 1 Amount ELA" := 0;
        "List Cost ELA" := 0;

        IF "Upcharge Type ELA" = "Upcharge Type ELA"::Amount THEN
            "Upcharge Amount ELA" := isUOMConvert("Item No.", pcodUOM, "Unit of Measure Code", "Upcharge Value ELA", 0.01)
        ELSE
            "Upcharge Amount ELA" := ROUND("Direct Unit Cost" * "Upcharge Value ELA" / 100, 0.01);

        IF "Billback Type ELA" = "Billback Type ELA"::Amount THEN
            "Billback Amount ELA" := isUOMConvert("Item No.", pcodUOM, "Unit of Measure Code", "Billback Value ELA", 0.01)
        ELSE
            "Billback Amount ELA" := ROUND("Direct Unit Cost" * "Billback Value ELA" / 100, 0.01);


        IF "Discount 1 Type ELA" = "Discount 1 Type ELA"::Amount THEN
            "Discount 1 Amount ELA" := isUOMConvert("Item No.", pcodUOM, "Unit of Measure Code", "Discount 1 Value ELA", 0.01)
        ELSE
            "Discount 1 Amount ELA" := ROUND("Direct Unit Cost" * "Discount 1 Value ELA" / 100, 0.01);



        IF "Freight Type ELA" = "Freight Type ELA"::Amount THEN
            "Freight Amount ELA" := isUOMConvert("Item No.", pcodUOM, "Unit of Measure Code", "Freight Value ELA", 0.01)
        ELSE
            "Freight Amount ELA" := ROUND("Direct Unit Cost" * "Freight Value ELA" / 100, 0.01);

        "List Cost ELA" := "Direct Unit Cost";  // "Direct Unit Cost" is already in correct UOM when is comes from COD7010 Purch. Price Calc. Mgt.
    end;

    procedure isUOMConvert(pcodItemNo: Code[20]; pcodFromUOM: Code[10]; pcodToUOM: Code[10]; pdecQtyToConvert: Decimal; pdecRoundingPrec: Decimal): Decimal
    begin

        IF pcodFromUOM = pcodToUOM THEN
            EXIT(pdecQtyToConvert);
        IF pdecQtyToConvert = 0 THEN
            EXIT(0);
        IF NOT isGetItemUOMs(pcodItemNo, pcodFromUOM, pcodToUOM) THEN
            EXIT(0);
        IF ROUND(grecFromUOM."Qty. per Unit of Measure", 1.0) = grecFromUOM."Qty. per Unit of Measure" THEN
            EXIT(ROUND(pdecQtyToConvert * grecFromUOM."Qty. per Unit of Measure" / grecToUOM."Qty. per Unit of Measure", pdecRoundingPrec))
        ELSE
            EXIT(ROUND(pdecQtyToConvert * grecToUOM."Qty. per Base UOM ELA" / grecFromUOM."Qty. per Base UOM ELA", pdecRoundingPrec));
    end;

    procedure isGetItemUOMs(pcodItemNo: Code[20]; pcodFromUOM: Code[20]; pcodToUOM: Code[20]): Boolean
    begin

        IF (grecFromUOM."Item No." <> pcodItemNo) OR (grecFromUOM.Code <> pcodFromUOM) THEN BEGIN
            IF NOT grecFromUOM.GET(pcodItemNo, pcodFromUOM) THEN
                EXIT(FALSE);
        END;
        IF (grecToUOM."Item No." <> pcodItemNo) OR (grecToUOM.Code <> pcodToUOM) THEN BEGIN
            IF NOT grecToUOM.GET(pcodItemNo, pcodToUOM) THEN
                EXIT(FALSE);
        END;
        EXIT(TRUE);
    end;


    var
        grecFromUOM: Record "Item Unit of Measure";
        grecToUOM: Record "Item Unit of Measure";
        vend: Record Vendor;
        ELAText001: Label '%1 must be blank.';
}