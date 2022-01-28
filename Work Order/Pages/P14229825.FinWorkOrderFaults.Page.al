page 14229825 "Fin. Work Order Faults ELA"
{
    Editable = false;
    PageType = List;
    SourceTable = "Fin. Work Order Fault ELA";

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

