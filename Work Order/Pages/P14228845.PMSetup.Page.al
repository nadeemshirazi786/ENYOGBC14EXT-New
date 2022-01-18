page 23019254 "PM Setup"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF000xxMG
    //   20071101 - remove MRO Item category from form as it is not used anywhere in the system

    PageType = Card;
    SourceTable = Table23019254;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("PM Procedure Nos."; "PM Procedure Nos.")
                {
                }
                field("PM Work Order Nos."; "PM Work Order Nos.")
                {
                }
                field("Notify User on Order Creation"; "Notify User on Order Creation")
                {
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
    }
}

