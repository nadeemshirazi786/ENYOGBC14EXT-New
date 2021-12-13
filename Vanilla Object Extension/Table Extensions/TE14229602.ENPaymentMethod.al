tableextension 14229602 "EN Payment Method ELA" extends "Payment Method"
{
    fields
    {
        field(14228880; "Cash ELA"; Boolean)
        {
            Caption = 'Cash';
            DataClassification = ToBeClassified;
        }
        field(14228910; "Cash Tender Method ELA"; Boolean)
        {
            Caption = 'Cash Tender Method';
            DataClassification = ToBeClassified;

        }
        field(14228850; "Automatic Refund ELA"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Automatic Refund';
        }
    }
}