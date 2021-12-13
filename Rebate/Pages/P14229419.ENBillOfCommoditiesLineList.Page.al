page 14229419 "Bill of Commod. Line List ELA"
{

    // ENRE1.00
    //   ENRE1.00 - New page
    //   ENRE1.00 - renumbered
    // 
    // ENRE1.00
    //   ENRE1.00 - removed Replaces and Replaced by Fields
    //            - New fields for Replacements info

    
    PageType = List;
    SourceTable = "Item BOC Line ELA";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item BOC No."; "Item BOC No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Commodity No."; "Commodity No.")
                {
                    ApplicationArea = All;
                }
                field("Quantity per"; "Quantity per")
                {
                    ApplicationArea = All;
                }
                field("Unit Amount"; "Unit Amount")
                {
                    ApplicationArea = All;
                }
                field("Replacement Commodity No."; "Replacement Commodity No.")
                {
                    ApplicationArea = All;
                }
                field("Replacement Quantity per"; "Replacement Quantity per")
                {
                    ApplicationArea = All;
                }
                field("Replacement Unit Amount"; "Replacement Unit Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("<Action23019008>")
            {
                Caption = '&Line';
                action("Show Document")
                {
                    ApplicationArea = All;
                    Caption = 'Show Document';
                    Image = View;
                    RunObject = Page "Bill of Commodities ELA";
                    RunPageLink = "No." = FIELD("Item BOC No.");
                    ShortCutKey = 'Shift+F7';
                }
            }
        }
    }
}

