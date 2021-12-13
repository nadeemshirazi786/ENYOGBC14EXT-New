table 14228861 "EN Order Rule Sales Line"
{



    fields
    {
        field(1; "Document Type"; Option)
        {
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(2; "Document No."; Code[20])
        {
        }
        field(3; "Line No."; Integer)
        {
        }
        field(4; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(10; "Item Not Setup"; Boolean)
        {
        }
        field(11; "Item Min. Qty."; Boolean)
        {
        }
        field(12; "Item Order Multiple"; Boolean)
        {
        }
        field(13; "Item Category Not Setup"; Boolean)
        {
        }
        field(14; "Item Category Min. Qty."; Boolean)
        {
        }
        field(15; "Item Category Order Multiple"; Boolean)
        {
        }
        field(16; "Combination Not Setup"; Boolean)
        {
        }
        field(17; "Combination Min. Qty."; Boolean)
        {
        }
        field(18; "Expected Min. Qty."; Decimal)
        {
        }
        field(19; "Expected Order Multiple"; Decimal)
        {
        }
        field(20; "Expected Combination Min. Qty."; Decimal)
        {
        }
        field(21; "Combination Unit Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
        }
        field(30; "Combination Delivered Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
        }
        field(31; "Sales Allowance Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
        }
        field(32; "Currency Code"; Code[10])
        {
            TableRelation = Currency;
        }
        field(33; "Item Not Allowed"; Boolean)
        {
            Description = 'JF00025MG';
        }
        field(34; "Category Not Allowed"; Boolean)
        {
            Description = 'JF00025MG';
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

