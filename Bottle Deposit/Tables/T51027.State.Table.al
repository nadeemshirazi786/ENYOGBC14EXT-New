table 51027 "State ELA"
{
    LookupPageID = "State ELA";

    fields
    {
        field(1; State; Code[30])
        {
        }
        field(2; Name; Text[30])
        {
        }
        field(3; "Bottle Deposit ELA"; Decimal)
        {
        }
        field(4; "Bottle Deposit Account"; Code[10])
        {
            TableRelation = "G/L Account"."No.";
        }
    }

    keys
    {
        key(Key1; State)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

