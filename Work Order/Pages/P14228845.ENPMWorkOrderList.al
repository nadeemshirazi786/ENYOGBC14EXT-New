page 14228845 "PM Work Order List ELA"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Work Order Header";
    CardPageId = "Work Order ELA";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    SaveValues = true;
    Editable = false;
    Caption = 'PM Work Order List';
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
                field("PM Procedure Code"; "PM Procedure Code")
                {
                    ApplicationArea = All;
                }
                field("PM Proc. Version No."; "PM Proc. Version No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("PM Group Code"; "PM Group Code")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Contains Critical Control"; "Contains Critical Control")
                {
                    ApplicationArea = All;
                }
                field("Person Responsible"; "Person Responsible")
                {
                    ApplicationArea = All;
                }
                field("Work Order Date"; "Work Order Date")
                {
                    ApplicationArea = All;
                }
                field("Maintenance Time"; "Maintenance Time")
                {
                    ApplicationArea = All;
                }
                field("Maintenance UOM"; "Maintenance UOM")
                {
                    ApplicationArea = All;
                }
            }

        }
        area(FactBoxes)
        {
            part("PM Work Order Factbox"; "PM Work Ord Stat. Factbox ELA")
            {
                ApplicationArea = all;
                SubPageLink = "PM Work Order No." = FIELD("PM Work Order No."), "PM Proc. Version No." = FIELD("PM Proc. Version No."), "PM Procedure Code" = FIELD("PM Procedure Code");
                ShowFilter = false;
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