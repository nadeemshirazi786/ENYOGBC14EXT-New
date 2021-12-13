table 14228914 "EN Posted Sales Payment Line"
{
    // ENSP1.00 2020-04-14 HR
    //     Created new table

    Caption = 'Posted Sales Payment Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "EN Posted Sales Payment Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(4; Type; Enum "EN Sales Payment Line Type")
        {
            Caption = 'Type';
        }
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(6; "Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Entry No.';
            TableRelation = IF (Type = CONST("Open Entry")) "Cust. Ledger Entry"."Entry No."
            ELSE
            IF (Type = CONST("Payment Fee")) "Cust. Ledger Entry"."Entry No.";
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = Amount;
        }
        key(Key2; Type, "No.")
        {
        }
        key(Key3; Type, "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

