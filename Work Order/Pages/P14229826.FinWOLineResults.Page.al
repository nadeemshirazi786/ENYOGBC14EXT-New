page 14229826 "Fin. WO Line Results ELA"
{
    DelayedInsert = true;
    Editable = false;
    PageType = List;
    SourceTable = "Fin. WO Line Results ELA";

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
                field("PM Measure Code"; "PM Measure Code")
                {
                }
                field("PM Procedure Code"; "PM Procedure Code")
                {
                    Visible = false;
                }
                field("Result No."; "Result No.")
                {
                }
                field("Result Value"; "Result Value")
                {
                }
            }
        }
    }

    actions
    {
    }
}

