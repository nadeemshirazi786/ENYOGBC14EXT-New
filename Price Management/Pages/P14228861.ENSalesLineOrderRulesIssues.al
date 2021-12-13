page 14228861 "EN SalesLine OrderRules Issues"
{


    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SourceTable = "EN Order Rule Sales Line";

    layout
    {
        area(content)
        {
            label(gtxtMessage)
            {
                
                Style = Attention;
                StyleExpr = TRUE;
                Caption = 'The following Sales Lines do not meet the Customer Order Rules requirements and therefore this Sales Order cannot be processed.';
                
            }

            
            repeater(GeneralRepeater)
            {
                field("Line No."; "Line No.")
                {
                }
                field("Item No."; "Item No.")
                {
                }
                field("Item Not Allowed"; "Item Not Allowed")
                {
                }
                field("Item Not Setup"; "Item Not Setup")
                {
                }
                field("Item Min. Qty."; "Item Min. Qty.")
                {
                }
                field("Item Order Multiple"; "Item Order Multiple")
                {
                }
                field("Category Not Allowed"; "Category Not Allowed")
                {
                }
                field("Item Category Not Setup"; "Item Category Not Setup")
                {
                }
                field("Item Category Min. Qty."; "Item Category Min. Qty.")
                {
                }
                field("Item Category Order Multiple"; "Item Category Order Multiple")
                {
                }
                field("Combination Not Setup"; "Combination Not Setup")
                {
                }
                field("Combination Min. Qty."; "Combination Min. Qty.")
                {
                }
                field("Expected Min. Qty."; "Expected Min. Qty.")
                {
                }
                field("Expected Order Multiple"; "Expected Order Multiple")
                {
                }
                field("Expected Combination Min. Qty."; "Expected Combination Min. Qty.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

