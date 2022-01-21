table 14229833 "PM Step ELA"
{
    DrillDownPageID = "PM Steps";
    LookupPageID = "PM Steps";

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

