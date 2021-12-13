tableextension 14229415 "Return Receipt Line ELA" extends "Return Receipt Line"
{
    //ENRE1.00 2021-09-08 AJ
    fields
    {
        // Add changes to table fields here
        field(14228800; "Line Net Weight ELA"; Decimal)
        {
            Caption = 'Line Net Weight';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Description = 'ENRE1.00';
            Editable = false;
        }
    }

    var
        myInt: Integer;
}