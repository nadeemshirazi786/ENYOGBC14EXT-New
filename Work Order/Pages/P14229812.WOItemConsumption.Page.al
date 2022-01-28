page 14229812 "WO Item Consumption ELA"
{
    AutoSplitKey = true;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "WO Item Consumption ELA";

    layout
    {
        area(content)
        {
            repeater(General)
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

