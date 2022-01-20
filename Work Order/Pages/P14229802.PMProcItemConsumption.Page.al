page 14229802 "PM Proc. Item Consumption ELA"
{
    AutoSplitKey = true;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "PM Item Consumption ELA";

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

