tableextension 14229413 "Inventory Comment Line ELA" extends "Inventory Comment Line"
{
    //ENRE1.00 2021-09-08 AJ
    fields
    {
        // Add changes to table fields here
        field(14228800; "Document Line No. ELA"; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
    }

    var
        myInt: Integer;
}