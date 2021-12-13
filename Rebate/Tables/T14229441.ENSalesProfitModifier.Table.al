table 14229441 "Sales Profit Modifier ELA"
{

    // ENRE1.00 2021-09-08 AJ

    DrillDownPageID = "Sales Profit Modifier List ELA"; //Sales Profit Modifier List
    LookupPageID = "Sales Profit Modifier List ELA";

    fields
    {
        field(1; "Entry No."; Integer)
        {
        }
        field(2; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(3; "Document No."; Code[20])
        {
        }
        field(4; "Document Line No."; Integer)
        {
        }
        field(5; "Source Type"; Option)
        {
            OptionCaption = 'Purchase Rebate';
            OptionMembers = "Purchase Rebate";
        }
        field(6; "Source No."; Code[20])
        {
        }
        field(7; "Amount (LCY)"; Decimal)
        {
        }
        field(8; Amount; Decimal)
        {
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Document Type", "Document No.", "Document Line No.", "Source Type")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }
}

