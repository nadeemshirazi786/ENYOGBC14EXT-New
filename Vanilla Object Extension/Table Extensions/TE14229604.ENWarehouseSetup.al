tableextension 14229604 "EN Warehouse Setup ELA" extends "Warehouse Setup"
{
    fields
    {
        field(14228880; "Cash Carry Pick Location ELA"; Code[10])
        {
            Caption = 'Cash Carry Pick Location';
            DataClassification = ToBeClassified;
        }
        field(14228881; "Cash Carry Reclass Templte ELA"; Code[10])
        {
            Caption = 'Cash Carry Reclass Template';
            DataClassification = ToBeClassified;
        }
        field(14228882; "Cash Carry Reclass Batch ELA"; Code[10])
        {
            Caption = 'Cash Carry Reclass Batch';
            DataClassification = ToBeClassified;
        }
    }
}