table 51002 "Banana Worksheet Column"
{
    LookupPageID = "Banana Worksheet Columns";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(2; "Banana Preference Code"; Code[10])
        {
            TableRelation = "Banana Preference";
        }
        field(3; "Column Heading"; Code[15])
        {
        }
        field(4; Sequence; Integer)
        {
        }
        field(5; Input; Boolean)
        {
        }
        field(6; "Order"; Boolean)
        {
        }
        field(7; "Input Preference Code"; Code[10])
        {
            TableRelation = "Banana Worksheet Column"."Banana Preference Code" WHERE("Item No." = FIELD("Item No."),
                                                                                      Input = CONST(true));
        }
        field(8; "Location Code"; Code[10])
        {
            Description = 'JF10807SPK';
            Enabled = false;
            TableRelation = Location;
        }
        field(9; "Variant Code"; Code[20])
        {
            Description = 'JF09582';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Banana Preference Code")
        {
            Clustered = true;
        }
        key(Key2; Sequence)
        {
        }
    }
}

