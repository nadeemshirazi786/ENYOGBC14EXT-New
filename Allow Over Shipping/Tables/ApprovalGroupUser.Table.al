table 50051 "Approval Group User"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.


    fields
    {
        field(1; "Approval Group"; Code[10])
        {
            TableRelation = "Approval Group";
        }
        field(2; User; Code[50])
        {
            TableRelation = "User Setup";
        }
    }

    keys
    {
        key(Key1; "Approval Group", User)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

