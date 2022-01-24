page 14229806 "PM Measure Code Values"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    DelayedInsert = true;
    PageType = List;
    SourceTable = "PM Measure Code Value ELA";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("PM Measure Code"; "PM Measure Code")
                {
                    Visible = false;
                }
                field(Code; Code)
                {
                }
                field(Description; Description)
                {
                }
            }
        }
    }

    actions
    {
    }
}

