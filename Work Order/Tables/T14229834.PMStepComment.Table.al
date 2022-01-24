table 14229834 "PM Step Comment ELA"
{
    fields
    {
        field(1; "Step Code"; Code[10])
        {
            TableRelation = "PM Step ELA".Code;
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

