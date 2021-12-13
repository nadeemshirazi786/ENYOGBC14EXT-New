page 14229102 "EN Document Line Extra Charges"
{


    Caption = 'Document Line Extra Charges';
    DataCaptionFields = "Table ID", "Document Type", "Document No.", "Line No.";
    PageType = List;
    SourceTable = "EN Document Extra Charge";

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Extra Charge Code"; "Extra Charge Code")
                {
                }
                field(Charge; Charge)
                {
                }
                field("Currency Code"; "Currency Code")
                {
                    Editable = false;
                    Lookup = false;
                    Visible = false;
                }
                field("Charge (LCY)"; "Charge (LCY)")
                {
                    Visible = false;
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

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
    end;
}

