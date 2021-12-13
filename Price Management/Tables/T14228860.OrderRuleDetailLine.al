table 14228860 "EN Order Rule Detail Line"
{


    Caption = 'Order Rule Detail';

    fields
    {
        field(1; "Sales Code"; Code[20])
        {
            TableRelation = IF ("Sales Type" = CONST("Customer")) Customer ELSE
            IF ("Sales Type" = CONST("Order Rule Group")) "EN Order Rule Group";
        }
        field(2; "Ship-To Address Code"; Code[10])
        {
            TableRelation = IF ("Sales Type" = CONST("Customer")) "Ship-to Address".Code WHERE("Customer No." = FIELD("Sales Code"));
        }
        field(3; "Item Type"; enum "EN Item Type Order Rule")
        {

        }
        field(4; "Item Ref. No."; Code[20])
        {
            Caption = 'Item Ref. No.';
            TableRelation = IF ("Item Type" = CONST("Item No.")) Item ELSE
            IF ("Item Type" = CONST("Item Category")) "Item Category";

        }
        field(5; "Start Date"; Date)
        {
            Editable = false;
        }
        field(6; "Unit of Measure Code"; Code[10])
        {
            TableRelation = IF ("Item Type" = CONST("Item No.")) "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item Ref. No.")) ELSE
            "Unit of Measure".Code;
        }
        field(10; "Sales Type"; enum "EN Sales Type Order Rule")
        {
            Caption = 'Sales Type';
        }
        field(20; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(25; "Unit Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';
            MinValue = 0;
        }
        field(26; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            FieldClass = Normal;
            TableRelation = Currency;
        }
        field(30; "Delivered Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
        }
        field(31; "Sales Allowance Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
        }
        field(32; "Reason Code"; Code[10])
        {
            TableRelation = "Reason Code".Code;
        }
        field(50000; "Ending Date"; Date)
        {
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Sales Type", "Sales Code", "Ship-To Address Code", "Item Type", "Item Ref. No.", "Start Date", "Unit of Measure Code", "Item No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        gconText001: Label 'Unit Price cannot be 0 for Sales Return No. %1, Line No. %4.';
        Text000: Label '%1 cannot be after %2';
}

