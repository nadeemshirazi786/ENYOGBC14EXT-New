table 51018 "User-Defined Fields - Item ELA"
{
    
    DrillDownPageID = "User-Def. Fields - Item ELA";
    LookupPageID = "User-Def. Fields - Item ELA";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            TableRelation = Item."No.";
        }
        field(50000; "Swell Allowance Percentage"; Decimal)
        {
        }
        field(50001; "Bottle Deposit - Sales"; Boolean)
        {
        }
        field(50002; "Pack Size"; Text[30])
        {
        }
        field(50003; "Bottle Deposit - Purchase"; Boolean)
        {
        }
        field(50010; "Ad 1"; Boolean)
        {
        }
        field(50011; "Ad 2"; Boolean)
        {
        }
        field(50012; "Ad 3"; Boolean)
        {
        }
        field(50013; "Ad 4"; Boolean)
        {
        }
        field(50014; "Ad 5"; Boolean)
        {
        }
        field(50015; "Ad 6"; Boolean)
        {
        }
        field(50016; "Ad 7"; Boolean)
        {
        }
        field(50017; "Ad 8"; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Item No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

