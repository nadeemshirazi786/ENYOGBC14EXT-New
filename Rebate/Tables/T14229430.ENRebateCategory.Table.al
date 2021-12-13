table 14229430 "Rebate Category ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //              - add field
    //              * 120 Cost Category Code
    // 
    // ENRE1.00
    //              - Renamed Field
    //              - Def. Customer Sub-Ledger Usage to Post to Sub-Ledger
    // 
    // ENRE1.00
    //              - Modified Field
    //              - Def. Rebate Type - Added option Guranteed Cost Deal
    //              - Modified Function
    //              - Def. Rebate Type - OnValidate
    //              - Def. Calculation Basis - OnValidate
    // 
    // 
    // 


    DrillDownPageID = "Rebate Categories ELA";
    LookupPageID = "Rebate Categories ELA";

    fields
    {
        field(10; "Code"; Code[20])
        {
        }
        field(20; Description; Text[50])
        {
        }
        field(30; "Expense G/L Account No."; Code[20])
        {
            TableRelation = "G/L Account";

            trigger OnValidate()
            var
                lrecGLAcct: Record "G/L Account";
            begin
            end;
        }
        field(40; "Calculation Basis"; Option)
        {
            OptionCaption = 'Pct. Sale($),($)/Unit,Lump Sum,Guaranteed Cost Deal,Commodity';
            OptionMembers = "Pct. Sale($)","($)/Unit","Lump Sum","Guaranteed Cost Deal",Commodity;
        }
        field(50; "Unit of Measure Code"; Code[10])
        {
            TableRelation = "Unit of Measure";
        }
        field(60; "Minimum Quantity (Base)"; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(80; "Currency Code"; Code[10])
        {
            TableRelation = Currency;
        }
        field(90; "Rebate Type"; Option)
        {
            Description = 'ENRE1.00';
            OptionCaption = 'Off-Invoice,Everyday,Lump Sum,Sales-Based,Commodity';
            OptionMembers = "Off-Invoice",Everyday,"Lump Sum","Sales-Based",Commodity;

            trigger OnValidate()
            begin
                if "Rebate Type" <> xRec."Rebate Type" then
                    Clear("Post to Sub-Ledger");
            end;
        }
        field(100; "Post to Sub-Ledger"; Option)
        {
            Description = 'ENRE1.00';
            OptionCaption = 'Post,Do Not Post';
            OptionMembers = Post,"Do Not Post";

            trigger OnValidate()
            begin
                if "Post to Sub-Ledger" = "Post to Sub-Ledger"::"Do Not Post" then
                    if "Rebate Type" = "Rebate Type"::"Lump Sum" then
                        FieldError("Rebate Type");
            end;
        }
        field(110; "Offset G/L Account No."; Code[20])
        {
            TableRelation = "G/L Account";
        }
        field(120; "Cost Category Code"; Code[10])
        {
            Caption = 'Cost Category Code';
            Description = 'ENRE1.00';
            TableRelation = "Cost Categories ELA";
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

