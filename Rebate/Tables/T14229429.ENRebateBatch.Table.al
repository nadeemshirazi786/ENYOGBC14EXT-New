table 14229429 "Rebate Batch ELA"
{
    // ENRE1.00 2021-09-08 AJ

    Caption = 'Rebate Batch';
    DrillDownPageID = "Rebate Batches ELA";
    LookupPageID = "Rebate Batches ELA";

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(10; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(20; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

