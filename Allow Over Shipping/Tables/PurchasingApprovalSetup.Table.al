table 50010 "Purchasing Approval Setup"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF45388SHR 20141222 - increased code to 50


    fields
    {
        field(1; Type; Option)
        {
            OptionMembers = User,Group;
        }
        field(2; "Code"; Code[50])
        {
            TableRelation = IF (Type = CONST (Group)) "Approval Group" ELSE
            IF (Type = CONST (User)) "User Setup";
        }
        field(10; "Purchase Limit ($)"; Decimal)
        {
        }
        field(12; "Allow Over Receive"; Boolean)
        {
        }
        field(13; "Over Receiving Tolerance (%)"; Decimal)
        {
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                IF "Over Receiving Tolerance (%)" <> 0 THEN BEGIN
                    TESTFIELD("Allow Over Receive");
                END;
            end;
        }
        field(14; "Allow Unit Cost Change"; Boolean)
        {
        }
        field(15; "Unit Cost Price Tolerance (%)"; Decimal)
        {
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                IF "Unit Cost Price Tolerance (%)" <> 0 THEN BEGIN
                    TESTFIELD("Allow Unit Cost Change");
                END;
            end;
        }
        field(16; "Allow Purch. Order Tol. Change"; Boolean)
        {
            Caption = 'Allow Purchase Order Tolerance Change';
        }
        field(17; "Allow Blnkt. Order Tol. Change"; Boolean)
        {
            Caption = 'Allow Blanket Order Tolerance Change';
        }
    }

    keys
    {
        key(Key1; Type, "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

