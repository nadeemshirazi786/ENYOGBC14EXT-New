table 14228862 "EN Order Rule Group"
{


    Caption = 'Order Rule Group';
//    DrillDownPageID = 23019664;
//    LookupPageID = 23019664;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

