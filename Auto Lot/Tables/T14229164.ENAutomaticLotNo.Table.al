table 14229155 "EN Automatic Lot No. ELA"
{
    Caption = 'Automatic Lot No.';

    fields
    {
        field(1; Root; Code[50])
        {
            Caption = 'Root';
        }
        field(2; Suffix; Integer)
        {
            Caption = 'Suffix';
        }
    }

    keys
    {
        key(Key1; Root)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

