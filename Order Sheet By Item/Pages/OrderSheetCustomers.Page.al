page 14228815 "Order Sheet Customers"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // //<JF00042DO>

    AutoSplitKey = true;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Order Sheet Customers";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control1101769000)
            {
                ShowCaption = false;
                field("Order Sheet Batch Name"; "Order Sheet Batch Name")
                {
                   // ShowCaption = false;
                   // Visible = false;
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                   /// ShowCaption = false;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                   // ShowCaption = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Customer")
            {
                Caption = '&Customer';
                action("Order Rules")
                {
                    Caption = 'Order Rules';
                    RunObject = Page "EN Order Rule Details";
                    RunPageLink = "Sales Code" = FIELD("Sell-to Customer No.");
                }
                action("Item Prices")
                {
                    Caption = 'Item Prices';
                    RunObject = Page "Sales Prices";
                    RunPageLink = "Sales Type" = CONST(Customer), "Sales Code" = FIELD("Sell-to Customer No.");
                }
            }
        }
    }
}

