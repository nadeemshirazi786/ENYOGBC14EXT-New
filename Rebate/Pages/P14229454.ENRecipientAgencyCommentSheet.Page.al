page 14229454 "Reci. Agency Comment Sheet ELA"
{

    // ENRE1.00
    //   ENRE1.00 - New page
    //   ENRE1.00 - renumbered


    AutoSplitKey = true;
    Caption = 'Recipient Agency Comment Sheet';
    DataCaptionFields = "No.";
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "Reci. Agency Comment Line ELA";

    layout
    {
        area(content)
        {
            repeater(Control1)
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
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine;
    end;
}

