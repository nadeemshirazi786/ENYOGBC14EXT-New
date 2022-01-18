table 23019259 "PM Fault Possibilities"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF43484SHR 20141014 - add version no. to primary key

    DrillDownPageID = 23019259;
    LookupPageID = 23019259;

    fields
    {
        field(1; "PM Procedure Code"; Code[20])
        {
            TableRelation = "PM Procedure Header".Code;
        }
        field(2; "Version No."; Code[10])
        {
            TableRelation = "PM Procedure Header"."Version No." WHERE (Code = FIELD ("PM Procedure Code"));
        }
        field(3; "PM Procedure Line No."; Integer)
        {
        }
        field(4; "Line No."; Integer)
        {
            Description = 'DO NOT USE Field No. 5';
        }
        field(10; "PM Fault Area"; Code[10])
        {
            TableRelation = "PM Fault Area";
        }
        field(11; "PM Fault Code"; Code[10])
        {
            TableRelation = "PM Fault Code".Code WHERE ("PM Fault Area" = FIELD ("PM Fault Area"));
        }
        field(12; Description; Text[50])
        {
        }
        field(15; "PM Fault Effect"; Code[10])
        {
            TableRelation = "PM Fault Effect";
        }
        field(16; "PM Fault Reason"; Code[10])
        {
            TableRelation = "PM Fault Reason";
        }
        field(17; "PM Fault Resolution"; Code[10])
        {
            TableRelation = "PM Fault Resolution";
        }
    }

    keys
    {
        key(Key1; "PM Procedure Code", "Version No.", "PM Procedure Line No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        grecFixedAsset: Record "Fixed Asset";
        grecResource: Record Resource;
}

