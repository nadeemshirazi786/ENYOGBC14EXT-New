page 14228816 "Order Sheet Details"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // //<JF00042DO>

    PageType = List;
    SourceTable = "Order Sheet Details";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1101769000)
            {
                ShowCaption = false;
                field("Entry No."; "Entry No.")
                {
                    //  ShowCaption = false;
                }
                field("Order Sheet Batch Name"; "Order Sheet Batch Name")
                {
                    // ShowCaption = false;
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    //ShowCaption = false;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    ShowCaption = false;
                }
                field("Requested Ship Date"; "Requested Ship Date")
                {
                    // ShowCaption = false;
                }
                field("External Doc. No."; "External Doc. No.")
                {
                    ShowCaption = false;
                }
                field("Item No."; "Item No.")
                {
                    //  ShowCaption = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ShowCaption = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    // ShowCaption = false;
                }
                field(Quantity; Quantity)
                {
                    //  ShowCaption = false;
                }
                field("Sales Order No."; "Sales Order No.")
                {
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
    }
}

