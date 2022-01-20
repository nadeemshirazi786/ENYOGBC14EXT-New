page 14229813 "WO Resources"
{
    AutoSplitKey = true;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "WO Resource ELA";

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
                    Visible = false;
                }
                field(Type; Type)
                {
                }
                field("No."; "No.")
                {
                }
                field(Description; Description)
                {
                }
                field(Quantity; Quantity)
                {
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                }
                field("Work Type Code"; "Work Type Code")
                {
                }
                field("Unit Cost"; "Unit Cost")
                {
                }
                field("Total Cost"; "Total Cost")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }
}

