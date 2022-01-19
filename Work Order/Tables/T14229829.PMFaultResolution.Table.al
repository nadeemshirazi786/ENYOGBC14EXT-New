table 14229829 "PM Fault Resolution ELA"
{
    DrillDownPageID = 23019283;
    LookupPageID = 23019283;

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

