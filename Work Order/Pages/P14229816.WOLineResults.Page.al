page 14229816 "WO Line Results ELA"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    DelayedInsert = true;
    PageType = List;
    SourceTable = "WO Line Result ELA";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("PM Work Order No."; "PM Work Order No.")
                {
                    Visible = false;
                }
                field("PM Measure Code"; "PM Measure Code")
                {
                }
                field("PM Procedure Code"; "PM Procedure Code")
                {
                    Visible = false;
                }
                field("Result No."; "Result No.")
                {
                }
                field("Result Value"; "Result Value")
                {
                }
            }
        }
    }

    actions
    {
    }
}

