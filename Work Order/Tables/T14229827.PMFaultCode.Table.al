table 14229827 "PM Fault Code ELA"
{
    DrillDownPageID = "PM Fault Codes";
    LookupPageID = "PM Fault Codes";

    fields
    {
        field(1; "PM Fault Area"; Code[10])
        {
            TableRelation = "PM Fault Area ELA";
        }
        field(2; "Code"; Code[10])
        {
        }
        field(3; Description; Text[50])
        {
        }
    }

    keys
    {
        key(Key1; "PM Fault Area", "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

