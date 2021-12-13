page 14228860 "EN Order Rule Detail Line"
{


    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = all;
    SourceTable = "EN Order Rule Detail Line";

    layout
    {
        area(content)
        {
            repeater(GeneralRepeater)
            {
                field("Item No."; "Item No.")
                {
                }
                field("Unit Price"; "Unit Price")
                {
                }
                field("Delivered Price"; "Delivered Price")
                {
                }
                field("Sales Allowance Amount"; "Sales Allowance Amount")
                {
                }
                field("Start Date"; "Start Date")
                {
                }
                field("Reason Code"; "Reason Code")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

