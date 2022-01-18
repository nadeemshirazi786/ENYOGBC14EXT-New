table 23019289 "PM Step Comment"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.


    fields
    {
        field(1; "Step Code"; Code[10])
        {
            TableRelation = "PM Step".Code;
        }
        field(2; "Line No."; Integer)
        {
        }
        field(10; Comments; Text[125])
        {
        }
        field(50; Spaces; Integer)
        {
        }
        field(51; NewLine; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Step Code", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        grecFixedAsset: Record "Fixed Asset";
        grecResource: Record Resource;
}

