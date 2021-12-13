page 14229422 "Bill of Commodities Sform ELA"
{

    // 
    // ENRE1.00
    //   ENRE1.00 - New page
    //   ENRE1.00 - renumbered
    // 
    // ENRE1.00
    //   ENRE1.00 - removed Replaces and Replaced by Fields
    //            - New fields for Replacements info
    // 
    // ENRE1.00
    //   ENRE1.00 - split key property need to be set to no


    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Item BOC Line ELA";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
    }
}

