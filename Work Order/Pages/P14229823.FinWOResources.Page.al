page 14229823 "Fin. WO Resources ELA"
{
    AutoSplitKey = true;
    DelayedInsert = true;
    Editable = false;
    PageType = List;
    SourceTable = "Fin. WO Resource ELA";

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
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Resources)
            {
                Caption = 'Resources';
                action("Resource Ledger Entries")
                {
                    Caption = 'Resource Ledger Entries';
                    RunObject = Page "Resource Ledger Entries";
                    RunPageLink = "Document No."=FIELD("PM Work Order No.");
                    RunPageView = SORTING("Document No.","Posting Date");
                    ShortCutKey = 'Ctrl+F7';
                }
            }
        }
    }
}

