page 14228814 "Order Sheet Batches"
{
    // Copyright Axentia Solutions Corp.  1999-2010.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // //<JF00042DO>
    // 
    // JF09573AC
    //   20101004 - add fields
    //     - 23019000 Location Code

    PageType = List;
    SourceTable = "Order Sheet Batch";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control1101769000)
            {
                ShowCaption = false;
                field(Name; Name)
                {

                }
                field(Description; Description)
                {

                }
                field("Location Code"; "Location Code")
                {
                    // ShowCaption = false;
                    // Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Order Sheet")
            {
                Caption = 'Order Sheet';
                action(Customers)
                {
                    Caption = 'Customers';
                    RunObject = Page "Order Sheet Customers";
                    RunPageLink = "Order Sheet Batch Name" = FIELD(Name);
                }
                action(Items)
                {
                    Caption = 'Items';
                    RunObject = Page "Order Sheet Items";
                    RunPageLink = "Order Sheet Batch Name" = FIELD(Name);
                }
                separator(Action1101769011)
                {
                }
                action("Get Customer Order Rule Items")
                {
                    Caption = 'Get Customer Order Rule Items';

                    trigger OnAction()
                    begin
                        jfdoGetOrderRuleItems;
                    end;
                }
            }
        }
    }
}

