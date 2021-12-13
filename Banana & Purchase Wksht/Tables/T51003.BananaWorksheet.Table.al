table 51003 "Banana Worksheet"
{
    fields
    {
        field(1; "Line No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Customer No."; Code[20])
        {
            TableRelation = Customer;
        }
        field(3; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(4; "Preference Code"; Code[10])
        {
            TableRelation = "Banana Worksheet Column"."Banana Preference Code" WHERE("Item No." = FIELD("Item No."));
        }
        field(5; Date; Date)
        {
        }
        field(6; Quantity; Decimal)
        {
        }
        field(7; "PO Number"; Code[20])
        {
        }
        field(8; "Variant Code"; Code[20])
        {
            Description = 'JF09582';
        }
        field(9; "Ship-to Code"; Code[10])
        {
            Description = 'JF09155';
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Customer No."));
            ValidateTableRelation = false;
        }
        field(10; "Location Code"; Code[20])
        {
            Description = 'JF10807SPK';
            TableRelation = Location;
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Customer No.", "Ship-to Code", "Item No.", "Variant Code", "Location Code", "Preference Code", Date)
        {
            SumIndexFields = Quantity;
        }
    }
}

