page 23019252 "PM Proc. Item Consumption"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF10366SHR
    //   20101102 - Add Description and Description 2 to page

    AutoSplitKey = true;
    DelayedInsert = true;
    PageType = List;
    SourceTable = Table23019252;

    layout
    {
        area(content)
        {
            repeater()
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
                field("Item No."; "Item No.")
                {
                }
                field(Description; Description)
                {
                }
                field("Description 2"; "Description 2")
                {
                    Visible = false;
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                }
                field("Quantity Installed"; "Quantity Installed")
                {
                }
                field("Planned Usage Qty."; "Planned Usage Qty.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

