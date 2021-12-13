table 14229409 "Commodity ELA"
{
    // ENRE1.00 2021-09-08 AJ


    DrillDownPageID = "Commodities ELA";
    LookupPageID = "Commodities ELA";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

