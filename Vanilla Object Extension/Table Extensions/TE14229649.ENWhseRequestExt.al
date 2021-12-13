tableextension 14229649 "Whse Request ELA" extends "Warehouse Request"
{
    fields
    {
        field(14228835; "Seal No. ELA"; Code[20])
        {
            Caption = 'Seal No.';
            DataClassification = ToBeClassified;
        }
        field(14228851; "Pallet Code ELA"; Code[10])
        {
            Caption = 'Pallet Code';
        }
    }

    var
        myInt: Integer;
}