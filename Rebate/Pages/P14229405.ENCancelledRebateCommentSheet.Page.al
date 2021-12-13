page 14229405 "Cancel. Rbt Comment Sheet ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - new form

    Caption = 'Cancelled Rebate Comment Sheet';
    AutoSplitKey = true;
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Cancel Rbt Comment Line ELA";

    layout
    {
        area(content)
        {
            repeater(Control23019000)
            {
                ShowCaption = false;
                field(Date; Date)
                {
                    ApplicationArea = All;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Created By User ID"; "Created By User ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //<ENRE1.00>
        SetUpNewLine;
        //</ENRE1.00>
    end;
}

