page 14229809 "PM Fault Possibilities ELA"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    AutoSplitKey = true;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "PM Fault Possibilities ELA";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("PM Procedure Code"; "PM Procedure Code")
                {
                    Visible = false;
                }
                field("Version No."; "Version No.")
                {
                    Visible = false;
                }
                field("PM Procedure Line No."; "PM Procedure Line No.")
                {
                    Visible = false;
                }
                field("PM Fault Area"; "PM Fault Area")
                {
                }
                field("PM Fault Code"; "PM Fault Code")
                {
                }
                field(Description; Description)
                {
                }
                field("PM Fault Effect"; "PM Fault Effect")
                {
                }
                field("PM Fault Reason"; "PM Fault Reason")
                {
                }
                field("PM Fault Resolution"; "PM Fault Resolution")
                {
                }
            }
        }
    }

    actions
    {
    }
}

