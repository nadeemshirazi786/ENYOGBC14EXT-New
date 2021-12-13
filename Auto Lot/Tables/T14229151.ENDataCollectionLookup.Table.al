table 14229151 "EN Data Collection Lookup ELA"
{
    Caption = 'Data Collection Lookup';
    fields
    {
        field(1; "Data Element Code"; Code[10])
        {
            Caption = 'Data Element Code';

        }
        field(2; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Data Element Code", "Code")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }
}

