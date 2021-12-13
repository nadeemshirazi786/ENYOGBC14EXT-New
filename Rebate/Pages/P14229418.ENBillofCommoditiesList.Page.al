page 14229418 "Bill of Commodities List ELA"
{

    // ENRE1.00 2021-09-08 AJ

    //    - New page
    //    - renumbered
    // 
    // ENRE1.00
    //    - cardformid property update


    Caption = 'Bill of Commodities';
    CardPageID = "Bill of Commodities List ELA";
    Editable = false;
    PageType = List;
    SourceTable = "Item BOC Header ELA";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Commodity Relationship"; "Commodity Relationship")
                {
                    ApplicationArea = All;
                }
                field("No. Servings"; "No. Servings")
                {
                    ApplicationArea = All;
                }
                field("Net Weight"; "Net Weight")
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

