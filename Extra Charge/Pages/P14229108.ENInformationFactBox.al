page 14229108 "EN Information FactBox"
{

    Caption = 'Information';
    PageType = CardPart;
    SourceTable = "Buffer ELA";
    SourceTableTemporary = true;
    Editable = false;
    layout
    {
        area(content)
        {
                field(""; Rec.Text300)
                {
                    ShowCaption = false;
                    MultiLine = true;
                    ToolTip = 'Specifies the value of the Text300 field';
                    ApplicationArea = All;
                }
            
        }
    }
    procedure SetInfoRec(precBuffer: Record "Buffer ELA")
    begin

        Rec.DELETEALL;
        Rec := precBuffer;
        Rec.INSERT;
        CurrPage.UPDATE(FALSE);
    end;
}
