page 14229417 "Commodity Allocations ELA"
{
   
    // ENRE1.00
    //   ENRE1.00 - New page
    //   ENRE1.00 - renumbered
    // 
    // ENRE1.00
    //   ENRE1.00 - commodity related modifictaions


    Caption = 'Commodity Allocations';
    PageType = List;
    SourceTable = "Commodity Allocation Line ELA";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Recipient Agency No."; "Recipient Agency No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                }
                field("Commodity No."; "Commodity No.")
                {
                    ApplicationArea = All;
                }
                field("Ending Date"; "Ending Date")
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
                field("Quantity Used"; "Quantity Used")
                {
                    ApplicationArea = All;
                }
                field("Amount (LCY) Used"; "Amount (LCY) Used")
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
            group("<Action23019012>")
            {
                Caption = 'Commodity Allocation';
                action("<Action23019013>")
                {
                    ApplicationArea = All;
                    Caption = 'Recipient Agency';
                    Image = AddWatch;
                    RunObject = Page "Recipient Agencies ELA";
                    RunPageLink = "No." = FIELD("Recipient Agency No.");
                }
            }
        }
    }
}

