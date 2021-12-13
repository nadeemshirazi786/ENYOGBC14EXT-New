table 14229157 "EN Lot No. Segment ELA"
{

    Caption = 'Lot No. Segment';

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
        }
        field(4; "Segment Code"; Code[10])
        {
            Caption = 'Segment Code';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; "Sequence No.")
        {
        }
    }

}

