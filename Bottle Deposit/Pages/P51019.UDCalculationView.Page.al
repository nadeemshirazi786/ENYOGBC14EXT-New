page 51019 "UD Calculation - View ELA"
{
    

    Caption = 'User-Defined Calculations - View';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    MultipleNewLines = false;
    PageType = List;
    SourceTable = "Buffer ELA";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control23019000)
            {
                Editable = false;
                ShowCaption = false;
                field(Key1; Key1)
                {
                    Caption = 'Code';
                    Visible = false;
                }
                field(Text1; Text1)
                {
                    Caption = 'Description';
                }
                field(Text300; Text300)
                {
                    Caption = 'Value';
                }
            }
        }
    }

    actions
    {
    }

    [Scope('Internal')]
    procedure jfSetForm(var precTempUDCalcValues: Record "Buffer ELA" temporary)
    var
        lrecUDCalculations: Record "UD Calculation ELA";
    begin
        //<JF8790MG>
        CLEAR(Rec);
        DELETEALL;

        IF precTempUDCalcValues.FINDSET THEN
        BEGIN
            REPEAT
                Rec.INIT;
                Rec.TRANSFERFIELDS(precTempUDCalcValues);
                Rec.INSERT;
            UNTIL precTempUDCalcValues.NEXT = 0;
        END;

        //-- go to beginning of recordset
        IF FINDSET THEN;
        //</JF8790MG>
    end;
}

