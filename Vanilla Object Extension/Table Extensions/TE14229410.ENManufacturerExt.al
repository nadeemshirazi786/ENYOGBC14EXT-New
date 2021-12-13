tableextension 14229410 "Manufacturer ELA" extends Manufacturer
{
    //ENRE1.00 2021-09-08 AJ
    fields
    {
        // Add changes to table fields here
        field(14228800; "Vendor No. ELA"; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = Vendor;
        }
    }

    var
        myInt: Integer;
}