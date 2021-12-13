page 14229106 "EN Pstd. DocLine Extra Charges"
{


    Caption = 'Posted Document Line Extra Charges';

    Editable = false;
    PageType = List;
    SourceTable = "EN Posted Doc. Extra Charges";

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

    var
        CurrLineNo: Integer;
        CurrTableID: Integer;
        SourceTableName: Text[100];


    procedure GetCaption(): Text[250]
    var
        ObjTransl: Record "Object Translation";
        NewTableID: Integer;
        CurrDocNo: Code[20];
    begin
        if not Evaluate(NewTableID, GetFilter("Table ID")) then
            exit('');

        if NewTableID = 0 then
            SourceTableName := ''
        else
            if NewTableID <> CurrTableID then
                SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, NewTableID);

        CurrTableID := NewTableID;

        if GetFilter("Line No.") = '' then
            CurrLineNo := 0
        else
            if GetRangeMin("Line No.") = GetRangeMax("Line No.") then
                CurrLineNo := GetRangeMin("Line No.")
            else
                CurrLineNo := 0;

        if GetFilter("Document No.") = '' then
            CurrDocNo := ''
        else
            if GetRangeMin("Document No.") = GetRangeMax("Document No.") then
                CurrDocNo := GetRangeMin("Document No.")
            else
                CurrDocNo := '';

        if NewTableID = 0 then
            exit('')
        else
            if CurrLineNo = 0 then
                exit(StrSubstNo('%1 %2', SourceTableName, CurrDocNo))
            else
                exit(StrSubstNo('%1 %2 %3', SourceTableName, CurrDocNo, Format(CurrLineNo)));
    end;
}

