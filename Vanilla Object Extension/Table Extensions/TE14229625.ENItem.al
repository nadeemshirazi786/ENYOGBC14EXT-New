tableextension 14229625 "EN Item ELA" extends Item
{


    fields
    {
        field(14229400; "Rebate Group Code ELA"; Code[20])
        {
            Caption = 'Rebate Group Code';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "Rebate Group ELA";
        }
        field(14229401; "Purch. Rebate Group Code ELA"; Code[20])
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "Rebate Group ELA";
            Caption = 'Purch. Rebate Group Code';
        }
        field(14228850; "Item Price Group Code ELA"; Code[10])
        {
            Caption = 'Item Price Group Code';
            TableRelation = "EN Item Sales Price Group";
        }
        field(14228851; "Sales Price UOM ELA"; Code[10])
        {
            Caption = 'Sales Price Unit of Measure';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));

        }
        field(14228852; "Reporting UOM ELA"; Code[10])
        {
            Caption = 'Reporting UOM';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));

        }
        field(14228853; "Inventory AsOfDate Filter ELA"; Date)
        {
            Caption = 'Inventory As Of Date filter';
            FieldClass = FlowFilter;

        }

        field(14228856; "Brand Code ELA"; Code[20])
        {
            Caption = 'Brand Code';
            TableRelation = "EN Brand Code".Code;

        }
        field(14228857; "Block From Sales Doc ELA"; Boolean)
        {
            Caption = 'Block From Sales Documents';
        }
        field(14228858; "Block From Purch Doc ELA"; Boolean)
        {
            Caption = 'Block From Purchase Documents';
        }

        field(14228859; "Qty. on Hand (Rep. UOM) ELA"; Decimal)
        {
            Caption = 'Qty. on Hand (Rep. UOM)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum("Item Ledger Entry"."Reporting Qty. ELA"
                WHERE(
                    "Item No." = FIELD("No."),
                    "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                    "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                    "Location Code" = FIELD("Location Filter"),
                    "Drop Shipment" = FIELD("Drop Shipment Filter"),
                    "Variant Code" = FIELD("Variant Filter"),
                    "Lot No." = FIELD("Lot No. Filter"),
                    "Serial No." = FIELD("Serial No. Filter"),
                    "Posting Date" = FIELD("Inventory AsOfDate Filter ELA")));

        }
        field(14228880; "Minimum Price Delta ELA"; Decimal)
        {
            Caption = 'Minimum Price Delta';
            DataClassification = ToBeClassified;
        }
        field(14228881; "Item Type Code ELA"; Code[15])
        {
            Caption = 'Item Type Code';
            DataClassification = ToBeClassified;
        }
        field(14228882; "Estimated Average Cost ELA"; Decimal)
        {
            Caption = 'Estimated Average Cost';
            DataClassification = ToBeClassified;
        }
        field(14228900; "Supply Chain Group Code ELA"; Code[10])
        {
            Caption = 'Supply Chain Group Code';
            DataClassification = ToBeClassified;
        }
        field(14228901; "Country/Reg of Orign Reqd. ELA"; Boolean)
        {
            Caption = 'Country/Region of Origin Reqd.';
            DataClassification = ToBeClassified;
        }
        field(14228902; "Item Type ELA"; Enum "Terminal Market Item Type")
        {
            Caption = 'Item type';
        }
        field(14229100; "Costing Unit ELA"; Enum "EN Costing Unit")
        {
            Caption = 'Costing Unit';
            DataClassification = ToBeClassified;
        }
        field(14229101; "Pricing Unit ELA"; Enum "EN Costing Unit")
        {
            Caption = 'Pricing Unit';
            DataClassification = ToBeClassified;
        }
        field(14229150; "Lot No. Assignment Method ELA"; Option)
        {
            Caption = 'Lot No. Assignment Method';
            DataClassification = ToBeClassified;
            OptionMembers = "No. Series","Doc. No.","Doc. No.+Suffix","Date","Custom";
        }
        field(14229151; "Alternate Unit of Measure"; Code[10])
        {
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
            DataClassification = ToBeClassified;
        }
        field(14229152; "Catch Alternate Qtys."; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(51000; "Purchase Price Unit of Measure"; Code[10])
        {
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
            DataClassification = ToBeClassified;
        }
        field(51001; "Bottle Deposit - Sales"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(51002; "Bottle Deposit - Purchase"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(14229153; "Size Code ELA"; Code[10])
        {
            TableRelation = "EN Unit of Measure Size"."Code";
            Caption = 'Size Code';
            DataClassification = ToBeClassified;
        }
        field(14229154; "Size Description ELA"; Text[200])
        {
            Caption = 'Size Description';
            FieldClass = FlowField;
            CalcFormula = lookup("EN Unit of Measure Size".Description where("Code" = field("Size Code ELA")));
        }
        field(14229155; "Alternate Unit of Measure ELA"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(14229156; "Catch Alternate Qtys. ELA"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(14229157; "Shelf Life Requirement"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
        field(14229158; "Expiration Warning"; DateFormula)
        {
        }
        field(14229159; "Item Status ELA"; Option)
        {
            Caption = 'Item Status';
            OptionMembers = "New","Certified","Under Development","Closed";
        }
        field(14229311; "Unit Price Prot Level ELA"; Option)
        {
            OptionMembers = "None","Absolute","Cost Plus";
            DataClassification = ToBeClassified;
        }
        field(51003; "Global Group 1 Code ELA"; Code[20])
        {
            Caption = 'Global Group 1 Code';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                InvtSetup: Record "Inventory Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
            begin
                IF "Global Group 1 Code ELA" <> '' THEN BEGIN
                    InvtSetup.GET;
                    InvtSetup.TESTFIELD("Global Group 1 Code ELA");
                    GlobalGroupValue.GET(InvtSetup."Global Group 1 Code ELA", "Global Group 1 Code ELA");
                END;
            end;

            trigger OnLookup()
            var
                InvtSetup: Record "Inventory Setup";
                GlobalGroupValue: Record "Global Group Value ELA";
                GlobalGroupValues: Page "Global Group Values ELA";
            begin

                CLEAR(GlobalGroupValues);
                InvtSetup.GET;
                InvtSetup.TESTFIELD("Global Group 1 Code ELA");
                GlobalGroupValue.SETFILTER("Master Group", '%1', InvtSetup."Global Group 1 Code ELA");
                GlobalGroupValues.LOOKUPMODE := TRUE;
                GlobalGroupValues.SETTABLEVIEW(GlobalGroupValue);
                GlobalGroupValues.SETRECORD(GlobalGroupValue);
                IF GlobalGroupValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    GlobalGroupValues.GETRECORD(GlobalGroupValue);
                    "Global Group 1 Code ELA" := GlobalGroupValue.Code;
                END;
            end;
        }
        field(51004; "Global Group 2 Code ELA"; Code[20])
        {
            Caption = 'Global Group 2 Code';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                GlobalGroupValue: Record "Global Group Value ELA";
            begin
                IF "Global Group 2 Code ELA" <> '' THEN BEGIN
                    InvtSetup.GET;
                    InvtSetup.TESTFIELD("Global Group 2 Code ELA");
                    GlobalGroupValue.GET(InvtSetup."Global Group 2 Code ELA", "Global Group 2 Code ELA");
                END;
            end;

            trigger OnLookup()
            var
                GlobalGroupValue: Record "Global Group Value ELA";
                GlobalGroupValues: Page "Global Group Values ELA";
            begin
                CLEAR(GlobalGroupValues);
                InvtSetup.GET;
                InvtSetup.TESTFIELD("Global Group 2 Code ELA");
                GlobalGroupValue.SETFILTER("Master Group", '%1', InvtSetup."Global Group 2 Code ELA");
                GlobalGroupValues.LOOKUPMODE := TRUE;
                GlobalGroupValues.SETTABLEVIEW(GlobalGroupValue);
                GlobalGroupValues.SETRECORD(GlobalGroupValue);
                IF GlobalGroupValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    GlobalGroupValues.GETRECORD(GlobalGroupValue);
                    "Global Group 2 Code ELA" := GlobalGroupValue.Code;
                END;
            end;

        }
        field(51005; "Global Group 3 Code ELA"; Code[20])
        {
            Caption = 'Global Group 3 Code';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                GlobalGroupValue: Record "Global Group Value ELA";
            begin
                IF "Global Group 3 Code ELA" <> '' THEN BEGIN
                    InvtSetup.GET;
                    InvtSetup.TESTFIELD("Global Group 3 Code ELA");
                    GlobalGroupValue.GET(InvtSetup."Global Group 3 Code ELA", "Global Group 3 Code ELA");
                END;
            end;

            trigger OnLookup()
            var
                GlobalGroupValue: Record "Global Group Value ELA";
                GlobalGroupValues: Page "Global Group Values ELA";
            begin
                CLEAR(GlobalGroupValues);
                InvtSetup.GET;
                InvtSetup.TESTFIELD("Global Group 3 Code ELA");
                GlobalGroupValue.SETFILTER("Master Group", '%1', InvtSetup."Global Group 3 Code ELA");
                GlobalGroupValues.LOOKUPMODE := TRUE;
                GlobalGroupValues.SETTABLEVIEW(GlobalGroupValue);
                GlobalGroupValues.SETRECORD(GlobalGroupValue);
                IF GlobalGroupValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    GlobalGroupValues.GETRECORD(GlobalGroupValue);
                    "Global Group 3 Code ELA" := GlobalGroupValue.Code;
                END;
            end;
        }
        field(51006; "Global Group 4 Code ELA"; Code[20])
        {
            Caption = 'Global Group 4 Code';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                GlobalGroupValue: Record "Global Group Value ELA";
            begin
                IF "Global Group 4 Code ELA" <> '' THEN BEGIN
                    InvtSetup.GET;
                    InvtSetup.TESTFIELD("Global Group 4 Code ELA");
                    GlobalGroupValue.GET(InvtSetup."Global Group 4 Code ELA", "Global Group 4 Code ELA");
                END;
            end;

            trigger OnLookup()
            var
                GlobalGroupValue: Record "Global Group Value ELA";
                GlobalGroupValues: Page "Global Group Values ELA";
            begin
                CLEAR(GlobalGroupValues);
                InvtSetup.GET;
                InvtSetup.TESTFIELD("Global Group 4 Code ELA");
                GlobalGroupValue.SETFILTER("Master Group", '%1', InvtSetup."Global Group 4 Code ELA");
                GlobalGroupValues.LOOKUPMODE := TRUE;
                GlobalGroupValues.SETTABLEVIEW(GlobalGroupValue);
                GlobalGroupValues.SETRECORD(GlobalGroupValue);
                IF GlobalGroupValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    GlobalGroupValues.GETRECORD(GlobalGroupValue);
                    "Global Group 4 Code ELA" := GlobalGroupValue.Code;
                END;
            end;
        }
        field(51007; "Global Group 5 Code ELA"; Code[20])
        {
            Caption = 'Global Group 5 Code';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                GlobalGroupValue: Record "Global Group Value ELA";
            begin
                IF "Global Group 5 Code ELA" <> '' THEN BEGIN
                    InvtSetup.GET;
                    InvtSetup.TESTFIELD("Global Group 5 Code ELA");
                    GlobalGroupValue.GET(InvtSetup."Global Group 5 Code ELA", "Global Group 5 Code ELA");
                END;
            end;

            trigger OnLookup()
            var
                GlobalGroupValue: Record "Global Group Value ELA";
                GlobalGroupValues: Page "Global Group Values ELA";
            begin
                CLEAR(GlobalGroupValues);
                InvtSetup.GET;
                InvtSetup.TESTFIELD("Global Group 5 Code ELA");
                GlobalGroupValue.SETFILTER("Master Group", '%1', InvtSetup."Global Group 5 Code ELA");
                GlobalGroupValues.LOOKUPMODE := TRUE;
                GlobalGroupValues.SETTABLEVIEW(GlobalGroupValue);
                GlobalGroupValues.SETRECORD(GlobalGroupValue);
                IF GlobalGroupValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    GlobalGroupValues.GETRECORD(GlobalGroupValue);
                    "Global Group 5 Code ELA" := GlobalGroupValue.Code;
                END;
            end;

        }
        field(51008; "Customer No. Filter ELA"; Code[20])
        {
            Caption = 'Customer No. Filter';
        }
    }

    procedure TrackAlternateUnits(): Boolean
    begin
        EXIT("Alternate Unit of Measure" <> '');
    end;

    procedure AlternateQtyPerBase(): Decimal
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        IF NOT TrackAlternateUnits() THEN
            EXIT(1);
        ItemUnitOfMeasure.GET("No.", "Alternate Unit of Measure ELA");
        ItemUnitOfMeasure.TESTFIELD("Qty. per Unit of Measure");
        EXIT(1 / ItemUnitOfMeasure."Qty. per Unit of Measure");
    end;

    var
        gcduCustomFieldMgmt: Codeunit "User-Defined Fields Mgmt. ELA";
        InvtSetup: Record "Inventory Setup";

    trigger OnAfterInsert()
    begin
        gcduCustomFieldMgmt.jfInsertItemRecord("No.");
    end;

    procedure CalcNoStdPallets(pdecQuantityBase: Decimal; pblnRoundUp: Boolean; pdecPrecision: Decimal): Decimal
    var
        ldecStdPallets: Decimal;
        lrecENSalesSetup: Record "Sales & Receivables Setup";
        lrecItemUOM: Record "Item Unit of Measure";
    begin

        ldecStdPallets := 0;

        lrecENSalesSetup.GET;

        IF pdecPrecision = 0 THEN
            pdecPrecision := 0.00001;

        IF lrecENSalesSetup."Std. Pallet UOM Code ELA" <> '' THEN BEGIN
            IF lrecItemUOM.GET("No.", lrecENSalesSetup."Std. Pallet UOM Code ELA") THEN BEGIN
                IF lrecItemUOM."Qty. per Unit of Measure" <> 0 THEN BEGIN
                    IF pblnRoundUp THEN
                        ldecStdPallets := ROUND(pdecQuantityBase / lrecItemUOM."Qty. per Unit of Measure", pdecPrecision, '>')
                    ELSE
                        ldecStdPallets := ROUND(pdecQuantityBase / lrecItemUOM."Qty. per Unit of Measure", pdecPrecision);
                END;
            END;
        END;

        EXIT(ldecStdPallets);
    end;
    /// <summary>
    /// UnitCostRepUOM.
    /// </summary>
    /// <returns>Return variable rUnitCostRepUOM of type Decimal.</returns>
    procedure UnitCostRepUOM() rUnitCostRepUOM: Decimal
    var
        lItemUoM: Record "Item Unit of Measure";
    begin

        IF NOT lItemUoM.GET("No.", "Reporting UOM ELA") THEN BEGIN
            EXIT(0);
        END;

        EXIT("Unit Cost" * lItemUoM."Qty. per Unit of Measure");
    end;
    /// <summary>
    /// GetQtyOnSalesOrdRepUOM.
    /// </summary>
    /// <returns>Return value of type Decimal.</returns>
    procedure GetQtyOnSalesOrdRepUOM(): Decimal
    var
        lSalesLine: Record "Sales Line";
    begin


        lSalesLine.RESET;
        lSalesLine.SETCURRENTKEY("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Shipment Date");
        lSalesLine.SETRANGE("Document Type", lSalesLine."Document Type"::Order);
        lSalesLine.SETRANGE(Type, lSalesLine.Type::Item);
        lSalesLine.SETRANGE("No.", "No.");
        lSalesLine.CALCSUMS("Outstanding Qty. (Base)");
        EXIT(TransfToRepUOMValue(lSalesLine."Outstanding Qty. (Base)"));

    end;
    /// <summary>
    /// GetQtyOnPurchOrdRepUOM.
    /// </summary>
    /// <returns>Return value of type Decimal.</returns>
    procedure GetQtyOnPurchOrdRepUOM(): Decimal
    var
        lPurchLine: Record "Purchase Line";
    begin


        lPurchLine.RESET;
        lPurchLine.SETCURRENTKEY("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Expected Receipt Date");
        lPurchLine.SETRANGE("Document Type", lPurchLine."Document Type"::Order);
        lPurchLine.SETRANGE(Type, lPurchLine.Type::Item);
        lPurchLine.SETRANGE("No.", "No.");
        lPurchLine.CALCSUMS("Outstanding Qty. (Base)");
        EXIT(TransfToRepUOMValue(lPurchLine."Outstanding Qty. (Base)"));

    end;
    /// <summary>
    /// TransfToRepUOMValue.
    /// </summary>
    /// <param name="pSourceValue">Decimal.</param>
    /// <returns>Return variable rReptingUOMValue of type Decimal.</returns>
    procedure TransfToRepUOMValue(pSourceValue: Decimal) rReptingUOMValue: Decimal
    var
        lItemUoM: Record "Item Unit of Measure";
    begin

        IF (pSourceValue = 0) OR ("Reporting UOM ELA" = '') THEN BEGIN
            EXIT(0);
        END;

        IF NOT lItemUoM.GET("No.", "Reporting UOM ELA") THEN BEGIN
            EXIT(0);
        END;

        rReptingUOMValue := pSourceValue / lItemUoM."Qty. per Unit of Measure";

    end;
    /// <summary>
    /// UnitPriceRepUOM.
    /// </summary>
    /// <returns>Return variable rUnitCostRepUOM of type Decimal.</returns>
    procedure UnitPriceRepUOM() rUnitCostRepUOM: Decimal
    var
        lItemUoM: Record "Item Unit of Measure";
    begin

        IF NOT lItemUoM.GET("No.", "Reporting UOM ELA") THEN BEGIN
            EXIT(0);
        END;

        EXIT("Unit Price" * lItemUoM."Qty. per Unit of Measure");
    end;


}