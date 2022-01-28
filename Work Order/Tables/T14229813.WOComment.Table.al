table 14229813 "WO Comment ELA"
{
    DrillDownPageID = "WO Comments ELA";
    LookupPageID = "WO Comments ELA";

    fields
    {
        field(1; "PM Work Order No."; Code[20])
        {
            TableRelation = "Work Order Header ELA"."PM Work Order No.";
        }
        field(2; "PM Proc. Version No."; Code[10])
        {
        }
        field(3; "PM WO Line No."; Integer)
        {
        }
        field(4; "Line No."; Integer)
        {
        }
        field(5; "PM Procedure Code"; Code[20])
        {
            TableRelation = "PM Procedure Header ELA".Code;
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
        key(Key1; "PM Work Order No.", "PM WO Line No.", "Line No.")
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

