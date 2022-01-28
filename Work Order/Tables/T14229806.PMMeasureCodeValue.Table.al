table 14229806 "PM Measure Code Value ELA"
{
    DrillDownPageID = "PM Measure Code Values ELA";
    LookupPageID = "PM Measure Code Values ELA";

    fields
    {
        field(1; "PM Measure Code"; Code[20])
        {
            TableRelation = "PM Measure ELA";

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
        grecPMMeasure: Record "PM Measure ELA";
}

