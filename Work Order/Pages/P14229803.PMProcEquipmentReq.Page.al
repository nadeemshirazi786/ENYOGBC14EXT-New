page 14229803 "PM Proc. Equipment Req. ELA"
{
    AutoSplitKey = true;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "PM Resource ELA";

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
                field(Type; Type)
                {
                }
                field("No."; "No.")
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

