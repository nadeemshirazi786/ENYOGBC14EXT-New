table 14228834 "Phys. Inv. Ledger Detail ELA"
{
    DrillDownPageID = "Phys. Inv. Ledger Details ELA";
    LookupPageID = "Phys. Inv. Ledger Details ELA";

    fields
    {
        field(32; "Phys. Inv. Ledger Entry No."; Integer)
        {
            TableRelation = "Phys. Inventory Ledger Entry"."Entry No.";
        }
        field(35; "Entry No."; Integer)
        {
        }
        field(40; "Quantity (Base) (Count)"; Decimal)
        {
            BlankZero = true;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(50; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(60; "Location Code"; Code[10])
        {
            TableRelation = Location;
        }
        field(70; "Quantity (Count)"; Decimal)
        {
            BlankZero = true;
            DecimalPlaces = 0 : 5;
        }
        field(80; "Unit of Measure Code"; Code[10])
        {
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(90; "Created By"; Code[50])
        {
            Editable = false;
        }
        field(100; "Date Created"; Date)
        {
            Editable = false;
        }
        field(110; "Last Date Modified"; Date)
        {
            Editable = false;
        }
        field(120; "Modified By"; Code[50])
        {
            Editable = false;
        }
        field(130; Description; Text[50])
        {
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
            SumIndexFields = "Quantity (Base) (Count)", "Quantity (Count)";
        }
        key(Key2; "Phys. Inv. Ledger Entry No.")
        {
            SumIndexFields = "Quantity (Base) (Count)", "Quantity (Count)";
        }
    }

    fieldgroups
    {
    }
}

