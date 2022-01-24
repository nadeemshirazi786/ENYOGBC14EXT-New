table 14229830 "PM Fault Effect ELA"
{
    DrillDownPageID = "PM Fault Effects";
    LookupPageID = "PM Fault Effects";

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

