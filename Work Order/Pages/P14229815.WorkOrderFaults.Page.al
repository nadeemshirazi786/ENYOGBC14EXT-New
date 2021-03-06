page 14229815 "Work Order Faults ELA"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    AutoSplitKey = true;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Work Order Fault ELA";

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
                field("PM WO Line No."; "PM WO Line No.")
                {
                    Visible = false;
                }
                field("PM Proc. Version No."; "PM Proc. Version No.")
                {
                    Visible = false;
                }
                field("PM Procedure Code"; "PM Procedure Code")
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

