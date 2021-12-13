page 14229441 "Rebate Categories ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - add field
    //              * 120 Cost Category Code

    Caption = 'Rebate Categories';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Rebate Category ELA";

    layout
    {
        area(content)
        {
            repeater(Control1102631000)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Rebate Type"; "Rebate Type")
                {
                    ApplicationArea = All;
                }
                field("Calculation Basis"; "Calculation Basis")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Minimum Quantity (Base)"; "Minimum Quantity (Base)")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Post to Sub-Ledger"; "Post to Sub-Ledger")
                {
                    ApplicationArea = All;
                }
                field("Expense G/L Account No."; "Expense G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("Offset G/L Account No."; "Offset G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("Cost Category Code"; "Cost Category Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

