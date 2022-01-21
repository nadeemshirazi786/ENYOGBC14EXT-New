table 14229805 "PM Measure ELA"
{
    DrillDownPageID = "PM Measure Codes";
    LookupPageID = "PM Measure Codes";

    fields
    {
        field(1; "Code"; Code[20])
        {
        }
        field(2; Description; Text[80])
        {
        }
        field(3; "Value Type"; Option)
        {
            OptionCaption = 'Boolean,Code,Text,Decimal,Date,Time';
            OptionMembers = Boolean,"Code",Text,Decimal,Date,Time;

            trigger OnValidate()
            begin
                if "Value Type" = "Value Type"::Decimal then
                    "Decimal Rounding Precision" := 0.00001
                else
                    "Decimal Rounding Precision" := 0;
            end;
        }
        field(4; "Default Unit of Measure Code"; Code[10])
        {
            TableRelation = "Unit of Measure";
        }
        field(5; "PM Measure Group"; Code[10])
        {
        }
        field(6; "Decimal Rounding Precision"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            InitValue = 0.00001;
            MinValue = 0;
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

    trigger OnDelete()
    begin
        grecPMCodeValues.SetRange("PM Measure Code", Code);
        grecPMCodeValues.DeleteAll;
    end;

    var
        grecPMCodeValues: Record "PM Measure Code Value ELA";
}

