page 14229808 "PM Proc. Comments"
{
    AutoSplitKey = true;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "PM Proc. Comment ELA";

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

