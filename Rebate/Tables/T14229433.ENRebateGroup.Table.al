table 14229433 "Rebate Group ELA"
{
    // ENRE1.00 2021-09-08 AJ

    LookupPageID = "Rebate Groups ELA";

    fields
    {
        field(10; "Code"; Code[20])
        {
        }
        field(20; Description; Text[50])
        {
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

