page 14229105 "EN Pstd.Doc Hdr. Extra Charges"
{
    Caption = 'Posted Document Header Extra Charges';
    Editable = false;
    //ApplicationArea = all;
    //UsageCategory = Lists;
    PageType = List;
    SourceTable = "EN Posted Doc. Extra Charges";
    SourceTableView = WHERE("Line No." = CONST(0));

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
                field("Vendor No."; "Vendor No.")
                {
                }
                field("Allocation Method"; "Allocation Method")
                {
                }
                field("Currency Code"; "Currency Code")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    var
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
            exit(StrSubstNo('%1 %2', SourceTableName, CurrDocNo));
    end;
}

