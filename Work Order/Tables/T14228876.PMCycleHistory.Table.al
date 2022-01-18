table 23019295 "PM Cycle History"
{
    DrillDownPageID = 23019295;
    LookupPageID = 23019295;

    fields
    {
        field(1; Type; Option)
        {
            OptionCaption = ' ,Machine Center,Work Center,Fixed Asset';
            OptionMembers = " ","Machine Center","Work Center","Fixed Asset";
        }
        field(2; "No."; Code[20])
        {
            TableRelation = IF (Type = CONST ("Machine Center")) "Machine Center"
            ELSE
            IF (Type = CONST ("Work Center")) "Work Center"
            ELSE
            IF (Type = CONST ("Fixed Asset")) "Fixed Asset";
        }
        field(3; "Cycle Date"; DateTime)
        {
        }
        field(4; Cycles; Decimal)
        {
        }
        field(50001; MA; Decimal)
        {

            trigger OnValidate()
            begin
                //DP 20101215
                jfCalcTotalMiles(Rec);
                //DP
            end;
        }
        field(50002; CT; Decimal)
        {

            trigger OnValidate()
            begin
                //DP 20101215
                jfCalcTotalMiles(Rec);
                //DP
            end;
        }
        field(50003; RI; Decimal)
        {

            trigger OnValidate()
            begin
                //DP 20101215
                jfCalcTotalMiles(Rec);
                //DP
            end;
        }
        field(50004; NH; Decimal)
        {

            trigger OnValidate()
            begin
                //DP 20101215
                jfCalcTotalMiles(Rec);
                //DP
            end;
        }
        field(50005; "Total Miles"; Decimal)
        {
            FieldClass = Normal;
        }
        field(50006; "New Mileage"; Decimal)
        {
        }
    }

    keys
    {
        key(Key1; Type, "No.", "Cycle Date")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    [Scope('Internal')]
    procedure jfCalcTotalMiles(var precPMCycleHistory: Record "PM Cycle History")
    begin

        //DP20101012

        with precPMCycleHistory do begin
            "Total Miles" := (MA + RI + CT + NH);
        end;
        //DP
    end;
}

