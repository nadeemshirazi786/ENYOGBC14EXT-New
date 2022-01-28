table 14229833 "PM Step ELA"
{
    DrillDownPageID = "PM Steps ELA";
    LookupPageID = "PM Steps ELA";

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

