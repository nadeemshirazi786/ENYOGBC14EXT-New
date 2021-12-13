page 14229104 "EN Extra Charge Posting Setup"
{


    Caption = 'Extra Charge Posting Setup';
    DataCaptionFields = "Gen. Bus. Posting Group", "Gen. Prod. Posting Group";
    PageType = List;
    ApplicationArea = all;
    UsageCategory = Administration;
    SourceTable = "EN Extra Charge Posting Setup";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Extra Charge Code"; "Extra Charge Code")
                {
                }
                field("Direct Cost Applied Account"; "Direct Cost Applied Account")
                {
                }
                field("Invt. Accrual Acc. (Interim)"; "Invt. Accrual Acc. (Interim)")
                {
                }

            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

