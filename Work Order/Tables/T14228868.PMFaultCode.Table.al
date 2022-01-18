table 23019281 "PM Fault Code"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    DrillDownPageID = 23019281;
    LookupPageID = 23019281;

    fields
    {
        field(1; "PM Fault Area"; Code[10])
        {
            TableRelation = "PM Fault Area";
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

