table 14229829 "PM Fault Resolution ELA"
{
    DrillDownPageID = "PM Fault Resolutions ELA";
    LookupPageID = "PM Fault Resolutions ELA";

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

