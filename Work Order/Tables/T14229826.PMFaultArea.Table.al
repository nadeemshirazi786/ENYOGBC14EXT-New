table 14229826 "PM Fault Area ELA"
{
    DrillDownPageID = 23019280;
    LookupPageID = 23019280;

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

