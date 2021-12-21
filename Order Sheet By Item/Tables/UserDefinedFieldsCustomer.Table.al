table 14228819 "User-Defined Fields - Customer"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    DrillDownPageID = "User-Defined Fields - Customer";
    LookupPageID = "User-Defined Fields - Customer";

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            TableRelation = Customer."No.";
        }
        field(50000;Notes;Text[30])
        {
        }
        field(50001;"Prices on Invoice";Boolean)
        {
        }
        field(50002;"Print Receivables";Boolean)
        {
        }
    }

    keys
    {
        key(Key1;"Customer No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

