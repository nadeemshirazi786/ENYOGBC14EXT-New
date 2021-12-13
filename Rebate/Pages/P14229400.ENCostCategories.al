page 14229400 "Cost Categories ELA"
{

    // ENRE1.00
    //    - Removed fields not being used:
    //    22 Manually Entered Cost
    //    30 Exclude Cost in Totals


    Caption = 'Cost Categories';
    PageType = List;
    SourceTable = "Cost Categories ELA";
    UsageCategory = Lists;

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
                field(Usage; Usage)
                {
                    ApplicationArea = All;
                }
                field("Cost Type"; "Cost Type")
                {
                    ApplicationArea = All;
                }
                field("Item Charge Filter"; "Item Charge Filter")
                {
                    ApplicationArea = All;
                }
                field("IC Inclusion"; "IC Inclusion")
                {
                    ApplicationArea = All;
                }
                field("Reporting Sequence"; "Reporting Sequence")
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

