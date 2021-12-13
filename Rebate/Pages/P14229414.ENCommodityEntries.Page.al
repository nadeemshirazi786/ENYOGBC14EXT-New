page 14229414 "Commodity Entries ELA"
{

    // ENRE1.00
    //    - new page

    Caption = 'Commodity Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Commodity Entry ELA";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Commodity No."; "Commodity No.")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Amount (LCY)"; "Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Recipient Agency No."; "Recipient Agency No.")
                {
                    ApplicationArea = All;
                }
                field("Rebate Entry No."; "Rebate Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Functional Area"; "Functional Area")
                {
                    ApplicationArea = All;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                }
                field("Source Line No."; "Source Line No.")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control23019017; Notes)
            {
                ApplicationArea = All;
            }
            systempart(Control23019018; Links)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }
}

