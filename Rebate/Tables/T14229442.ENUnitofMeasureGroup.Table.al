table 14229442 "Unit of Measure Group ELA"
{

    // ENRE1.00 2021-09-08 AJ

    DrillDownPageID = "Unit of Measure Group ELA"; //Unit of Measure Group
    LookupPageID = "Unit of Measure Group ELA";

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

