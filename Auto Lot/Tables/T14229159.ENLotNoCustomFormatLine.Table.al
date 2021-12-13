table 14229159 "EN Lot No. Custm Frmt Line ELA"
{

    Caption = 'Lot No. Custom Format Line';

    fields
    {
        field(1; "Custom Format Code"; Code[10])
        {
            Caption = 'Custom Format Code';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Code,Text';
            OptionMembers = "Code",Text;
        }
        field(4; Segment; Code[10])
        {
            Caption = 'Segment';
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(6; "Segment Code"; Code[10])
        {
            Caption = 'Segment Code';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Custom Format Code", "Line No.")
        {
            Clustered = true;
        }
    }

}

