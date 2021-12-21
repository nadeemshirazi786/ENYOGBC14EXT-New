page 14228817 "Order Sheet Items"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // //<JF00042DO>
    // 
    // JF4953DD - Order Sheet Items Additions
    //   20090820 - Added Fields to the Tablebox: (Widened Form a little)
    //              * 60        "On Special"                    Boolean
    //              * 65        "Item Description"              Text 30
    // 
    // JF5918SHR
    //   20091102 - Added field to form
    //              * 66         "Item Description 2"
    // 
    // JF6603MG
    //   20091209 - Add new field
    //              * 67 Backordered Item

    DelayedInsert = true;
    PageType = List;
    SourceTable = "Order Sheet Items";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1101769000)
            {
                ShowCaption = false;
                field("Order Sheet Batch Name"; "Order Sheet Batch Name")
                {

                }
                field("Item No."; "Item No.")
                {

                }
                field("Item Description"; "Item Description")
                {

                }
                field("Item Description 2"; "Item Description 2")
                {

                }
                field("Variant Code"; "Variant Code")
                {
                    ShowCaption = false;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {

                }
                field("On Special"; "On Special")
                {

                }
                field("Backordered Item"; "Backordered Item")
                {

                }
            }
        }
    }

    actions
    {
    }
}

