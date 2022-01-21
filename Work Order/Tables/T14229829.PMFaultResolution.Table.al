table 14229829 "PM Fault Resolution ELA"
{
    DrillDownPageID = "PM Fault Resolutions";
    LookupPageID = "PM Fault Resolutions";

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

