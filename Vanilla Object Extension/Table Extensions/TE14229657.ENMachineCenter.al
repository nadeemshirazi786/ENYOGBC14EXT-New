tableextension 14229657 "Machine Center ELA" extends "Machine Center"
{
    fields
    {
        field(14229800; "Cycles ELA"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Max("PM Cycle History ELA".Cycles WHERE(Type = CONST("Machine Center"), "No." = FIELD("No.")));
            Editable = false;
            Caption = 'Cycles';
        }
        field(14229801; "Fixed Asset No. ELA"; Code[20])
        {
            Caption = 'Fixed Asset No.';
            Editable = false;
        }
        field(14229802; "Serial No. ELA"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}