tableextension 14229613 "Finance Cue ELA" extends "Finance Cue"
{
    fields
    {
        field(14228910; "Open Sales Payments ELA"; Integer)
        {
            Caption = 'Open Sales Payments';
            FieldClass = FlowField;
            CalcFormula = Count("EN Sales Payment Header" WHERE(Status = FILTER(Open | Shipping)));
        }
        field(14228911; "Shipping Sales Payments ELA"; Integer)
        {
            Caption = 'Shipping Sales Payments';
            FieldClass = FlowField;
            CalcFormula = Count("EN Sales Payment Header" WHERE(Status = CONST(Shipping)));
        }
        field(14228912; "Complete Sales Payments ELA"; Integer)
        {
            Caption = 'Complete Sales Payments';
            FieldClass = FlowField;
            CalcFormula = Count("EN Sales Payment Header" WHERE(Status = CONST(Complete)));

        }
    }
}