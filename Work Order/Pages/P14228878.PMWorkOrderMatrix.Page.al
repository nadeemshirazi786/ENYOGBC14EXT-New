page 23019290 "PM Work Order Matrix"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF.00007 - PM Work Order Generation
    //   20050302 - Created Form

    DataCaptionFields = Type, "No.";
    PageType = List;
    SourceTable = Table23019286;

    layout
    {
        area(content)
        {
            repeater()
            {
                field(Type; Type)
                {
                }
                field("No."; "No.")
                {
                }
                field("PM Procedure"; "PM Procedure")
                {
                }
                field("Last Work Order Date"; "Last Work Order Date")
                {
                }
                field("Work Order Freq."; "Work Order Freq.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

