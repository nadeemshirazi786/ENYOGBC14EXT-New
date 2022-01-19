page 14229823 "Fin. WO Resources"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    AutoSplitKey = true;
    DelayedInsert = true;
    Editable = false;
    PageType = List;
    SourceTable = Table23019273;

    layout
    {
        area(content)
        {
            repeater()
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
                    RunObject = Page 202;
                    RunPageLink = Document No.=FIELD(PM Work Order No.);
                    RunPageView = SORTING(Document No.,Posting Date);
                    ShortCutKey = 'Ctrl+F7';
                }
            }
        }
    }
}

