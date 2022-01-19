page 14229812 "WO Item Consumption"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF8566SHR
    //   20100520 - Set "PM Work Order No." and "PM WO Line No." EDITABLE = No
    //            - Added fields:
    //              "Purchase Order No."
    //              "Purchase Receipt No."
    //              "Purchase Receipt Line No."
    //              "Applies-to Entry"
    // 
    // JF10366SHR
    //   20101102 - Add Description and Description 2 to page

    AutoSplitKey = true;
    DelayedInsert = true;
    PageType = List;
    SourceTable = Table23019262;

    layout
    {
        area(content)
        {
            repeater()
            {
                field("PM Work Order No."; "PM Work Order No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("PM Procedure Code"; "PM Procedure Code")
                {
                    Visible = false;
                }
                field("PM Proc. Version No."; "PM Proc. Version No.")
                {
                    Visible = false;
                }
                field("PM WO Line No."; "PM WO Line No.")
                {
                    Editable = false;
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
                field("Variant Code"; "Variant Code")
                {
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                }
                field("Bin Code"; "Bin Code")
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
                field("Qty. to Consume"; "Qty. to Consume")
                {
                }
                field("Purchase Order No."; "Purchase Order No.")
                {
                }
                field("Purchase Receipt No."; "Purchase Receipt No.")
                {
                }
                field("Purchase Receipt Line No."; "Purchase Receipt Line No.")
                {
                }
                field("Applies-to Entry"; "Applies-to Entry")
                {
                }
            }
        }
    }

    actions
    {
    }
}

