page 14228843 "Work Order Faults ELA"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Work Order Fault";
    DelayedInsert = true;
    AutoSplitKey = true;
    Caption = 'Work Order Faults';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("PM Work Order No."; "PM Work Order No.")
                {
                    ApplicationArea = All;
                }
                field("PM WO Line No."; "PM WO Line No.")
                {
                    ApplicationArea = All;
                }
                field("PM Proc. Version No."; "PM Proc. Version No.")
                {
                    ApplicationArea = All;
                }
                field("PM Procedure Code"; "PM Procedure Code")
                {
                    ApplicationArea = All;
                }
                field("PM Fault Area"; "PM Fault Area")
                {
                    ApplicationArea = All;
                }
                field("PM Fault Code"; "PM Fault Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("PM Fault Effect"; "PM Fault Effect")
                {
                    ApplicationArea = All;
                }
                field("PM Fault Reason"; "PM Fault Reason")
                {
                    ApplicationArea = All;
                }
                field("PM Fault Resolution"; "PM Fault Resolution")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}