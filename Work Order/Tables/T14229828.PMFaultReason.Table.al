table 14229828 "PM Fault Reason ELA"
{
    DrillDownPageID = "PM Fault Reasons ELA";
    LookupPageID = "PM Fault Reasons ELA";

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

