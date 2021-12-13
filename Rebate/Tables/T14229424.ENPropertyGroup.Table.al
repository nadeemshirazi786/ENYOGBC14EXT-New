table 14229424 "Property Group ELA"
{
    // ENRE1.00 2021-09-08 AJ

    DrillDownPageID = "Property Groups ELA"; //Property Groups
    LookupPageID = "Property Groups ELA";

    fields
    {
        field(1; "Code"; Code[10])
        {
        }
        field(2; Description; Text[50])
        {
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

