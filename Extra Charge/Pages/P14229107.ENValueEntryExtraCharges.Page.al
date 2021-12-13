page 14229107 "EN Value Entry Extra Charges"
{
    Caption = 'Value Entry Extra Charges';
    DataCaptionExpression = GetCaption;
    Editable = false;
    PageType = List;
    SourceTable = "EN Value Entry Extra Charge";

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
                field(Charge; Charge)
                {
                }
                field("Charge Posted to G/L"; "Charge Posted to G/L")
                {
                }
                field("Expected Charge"; "Expected Charge")
                {
                }
                field("Expected Charge Posted to G/L"; "Expected Charge Posted to G/L")
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

    var
        CurrEntryNo: Integer;
        SourceTableName: Text[100];

    [Scope('Internal')]
    procedure GetCaption(): Text[250]
    var
        ObjTransl: Record "Object Translation";
        NewTableID: Integer;
    begin
        SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, DATABASE::"Value Entry");

        if GetFilter("Entry No.") = '' then
            CurrEntryNo := 0
        else
            if GetRangeMin("Entry No.") = GetRangeMax("Entry No.") then
                CurrEntryNo := GetRangeMin("Entry No.")
            else
                CurrEntryNo := 0;

        exit(StrSubstNo('%1 %2', SourceTableName, Format(CurrEntryNo)));
    end;
}

