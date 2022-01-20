page 14229824 "Fin. WO Comments"
{
    AutoSplitKey = true;
    DelayedInsert = true;
    Editable = false;
    PageType = List;
    SourceTable = "Fin. WO Comment ELA";

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
                field(Comments; Comments)
                {
                }
            }
        }
    }

    actions
    {
    }
}

