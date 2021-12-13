table 55025 "EN Sales Payment Cue"
{
    // ENSP1.00 2020-04-14 AF
    //     Created new table
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = ToBeClassified;
        }
        field(4; "Complete Sales Payments"; Integer)
        {
            CalcFormula = Count("EN Sales Payment Header" WHERE(Status = CONST(Complete)));
            FieldClass = FlowField;
        }
        field(5; "Open Sales Payments"; Integer)
        {
            CalcFormula = Count("EN Sales Payment Header" WHERE(Status = FILTER(Open | Shipping)));
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

