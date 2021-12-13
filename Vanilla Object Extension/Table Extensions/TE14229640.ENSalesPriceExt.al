tableextension 14228862 "EN Sales Price Ext" extends "Sales Price"
{
    fields
    {
        field(14228850; "Ship-To Code ELA"; Code[10])
        {
            Caption = 'Ship-To Code';
            TableRelation = IF ("Sales Type" = CONST(Customer)) "Ship-to Address".Code WHERE("Customer No." = FIELD("Sales Code"));
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                IF "Ship-To Code ELA" <> '' THEN BEGIN
                    TESTFIELD("Sales Type", "Sales Type"::Customer);
                END;
            end;
        }
        field(14228851; "Delivered Unit Price ELA"; Decimal)
        {
            Caption = 'Delivered Unit Price';
            AutoFormatType = 2;
            AutoFormatExpression = "Currency Code";
            DataClassification = ToBeClassified;
        }
        field(14228852; "Delivery Allowance ELA"; Decimal)
        {
            Caption = 'Delivery Allowance';
            AutoFormatType = 2;
            AutoFormatExpression = "Currency Code";
            DataClassification = ToBeClassified;
        }
        field(14228853; "Sales Allowance ELA"; Decimal)
        {
            Caption = 'Sales Allowance';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(14228854; "Adv Sls Prc WShtBatchName ELA"; Code[50])
        {
            Caption = 'Adv Sls Price Wksht Batch Name';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(14228855; "Specific Pricing Rank ELA"; Integer)
        {
            Caption = 'Specific Pricing Rank';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(14228856; "Description ELA"; Text[100])
        {
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(Item.Description WHERE("No." = FIELD("Item No.")));

        }
        field(14228857; "Description 2 ELA"; Text[100])
        {
            Caption = 'Description 2';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(Item."Description 2" WHERE("No." = FIELD("Item No.")));

        }
        field(14228858; "Item Category Code ELA"; Code[20])
        {
            Caption = 'Item Category Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(Item."Item Category Code" WHERE("No." = FIELD("Item No.")));

        }
        field(14228859; "Sales Type ELA"; Enum "EN Sales Type")
        {
            Caption = 'EN Sales Type';
            //OptionCaption = 'Customer,"Customer Price Group","All Customers",Campaign,,,,,,,"Customer Buying Group","Price List Group"';
            //OptionMembers = Customer,"Customer Price Group","All Customers",Campaign,,,,,,,"Customer Buying Group","Price List Group";
            trigger OnValidate()
            begin

            end;

        }
        field(14228860; "Last Direct Cost ELA"; Decimal)
        {
            Caption = 'Last Direct Cost';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(Item."Last Direct Cost" WHERE("No." = FIELD("Item No.")));
            BlankZero = true;
            DecimalPlaces = 0 : 5;
        }
        field(14228861; "Reason Code ELA"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code".Code;
            DataClassification = ToBeClassified;
        }
        field(14228862; "Dlvry. Chg. Allow InvDisc ELA"; Boolean)
        {
            Caption = 'Dlvry. Chg. Allow Inv. Disc.';
            InitValue = true;
            DataClassification = ToBeClassified;
        }
        field(14228863; "Dlvry. Allw. Allow InvDisc ELA"; Boolean)
        {
            Caption = 'Dlvry. Allowance Allow Inv. Disc.';
            InitValue = true;
            DataClassification = ToBeClassified;
        }
        field(14228864; "Date Filter ELA"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;

        }
        field(14228865; "Min. Qty. Filter ELA"; Decimal)
        {
            Caption = 'Min. Qty. Filter';
            FieldClass = FlowFilter;

        }
        field(14228866; "Sales Type Filter ELA"; Enum "EN Sales Type")
        {
            Caption = 'Sales Type Filter';
            FieldClass = FlowFilter;

        }
        field(14228867; "Sales Code Filter ELA"; Code[20])
        {
            Caption = 'Sales Code Filter';
            FieldClass = FlowFilter;

        }
        field(14228868; "Ship-To Filter ELA"; Code[10])
        {
            Caption = 'Ship-To Filter';
            FieldClass = FlowFilter;

        }
        field(14228869; "Price Rule ELA"; Boolean)
        {
            Caption = 'Price Rule';
            DataClassification = ToBeClassified;
        }
        field(14228870; "Price Rule Code ELA"; Code[10])
        {
            Caption = 'Price Rule Code';
            TableRelation = "EN Price Rule";
            DataClassification = ToBeClassified;
        }
    }
}
