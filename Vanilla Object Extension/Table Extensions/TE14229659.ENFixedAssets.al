tableextension 14229659 "Fixed Assets ELA" extends "Fixed Asset"
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
        field(14229801; "Link To Type ELA"; Option)
        {
            OptionMembers = "","Work Center","Machine Center",Truck,Trailer;
            Caption = 'Link to Type';
            DataClassification = ToBeClassified;
        }
        field(14229802; "Link To No."; Code[20])
        {
            TableRelation = IF ("Link To Type ELA"=CONST("Machine Center")) "Machine Center"."No." ELSE IF ("Link To Type ELA"=CONST("Work Center")) "Work Center"."No." ;
            DataClassification = ToBeClassified;
        }
    }
    
    var
        myInt: Integer;
}