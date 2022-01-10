table 14229000 "EN Vendor Price Group"
{

    Caption = 'Vendor Price Group';
    LookupPageID = 14229000;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10; Description; Text[50])
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
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }

}

