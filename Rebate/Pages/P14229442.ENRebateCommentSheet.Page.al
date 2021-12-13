page 14229442 "Rebate Comment Sheet ELA"
{

    // ENRE1.00
    //   ENRE1.00 - new form


    AutoSplitKey = true;
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Rebate Comment Line ELA";

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

