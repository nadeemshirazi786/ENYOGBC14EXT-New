tableextension 14229620 "EN Value Entry ELA" extends "Value Entry"
{
    fields
    {
        field(14229100; "New Order Type ELA"; Enum "EN Value Entry Order Type")
        {
            Caption = 'New Order Type';
            DataClassification = ToBeClassified;
        }
        field(14229101; "Extra Charge ELA"; Decimal)
        {
            Caption = 'Extra Charge';
            DataClassification = ToBeClassified;
        }
        field(14229102; "Extra Charge (Expected) ELA"; Decimal)
        {
            Caption = 'Extra Charge (Expected)';
            DataClassification = ToBeClassified;
        }
        field(14229103; "Extra Charge (ACY) ELA"; Decimal)
        {
            Caption = 'Extra Charge (ACY)';
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}