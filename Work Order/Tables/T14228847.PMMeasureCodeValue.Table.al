table 23019256 "PM Measure Code Value"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    DrillDownPageID = 23019256;
    LookupPageID = 23019256;

    fields
    {
        field(1; "PM Measure Code"; Code[20])
        {
            TableRelation = "PM Measure";

            trigger OnValidate()
            begin
                grecPMMeasure.Get("PM Measure Code");
                grecPMMeasure.TestField("Value Type", grecPMMeasure."Value Type"::Code);
            end;
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
        key(Key1; "PM Measure Code", "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        grecPMMeasure: Record "PM Measure";
}

