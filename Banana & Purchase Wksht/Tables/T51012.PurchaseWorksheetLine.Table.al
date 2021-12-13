table 51012 "Purchase Worksheet Line"
{
    fields
    {
        field(1; "Order Date"; Date)
        {
        }
        field(2; "Order No."; Integer)
        {
        }
        field(3; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(4; Quantity; Decimal)
        {
        }
        field(5; "Unit Price"; Decimal)
        {
        }
        field(6; "Variant Code"; Code[20])
        {
            Description = 'JF09582SPK';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
    }

    keys
    {
        key(Key1; "Order Date", "Order No.", "Item No.", "Variant Code")
        {
            Clustered = true;
        }
        key(Key2; "Order Date", "Item No.", "Variant Code")
        {
        }
    }

}

