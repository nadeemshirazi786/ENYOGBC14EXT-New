/// <summary>
/// Page EN Item Sales Price Group (ID 14228854).
/// </summary>
page 14228854 "EN Item Sales Price Group"
{

    Caption = 'EN Item Sales Price Group';
    PageType = List;
    SourceTable = "EN Item Sales Price Group";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    /// <summary>
    /// GetSelectionFilter.
    /// </summary>
    /// <returns>Return value of type Code[80].</returns>
    procedure GetSelectionFilter(): Code[80];
    var
        lrecItemSalesPriceGroup: Record "EN Item Sales Price Group";
        FirstItemDiscGr: Code[30];
        LastItemDiscGr: Code[30];
        SelectionFilter: Code[250];
        lrecItemPriceGrCount: Integer;
        More: Boolean;
    begin
        CurrPage.SETSELECTIONFILTER(lrecItemSalesPriceGroup);
        lrecItemPriceGrCount := lrecItemSalesPriceGroup.COUNT;
        IF lrecItemPriceGrCount > 0 THEN BEGIN
            lrecItemSalesPriceGroup.FIND('-');
            WHILE lrecItemPriceGrCount > 0 DO BEGIN
                lrecItemPriceGrCount := lrecItemPriceGrCount - 1;
                lrecItemSalesPriceGroup.MARKEDONLY(FALSE);
                FirstItemDiscGr := lrecItemSalesPriceGroup.Code;
                LastItemDiscGr := FirstItemDiscGr;
                More := (lrecItemPriceGrCount > 0);
                WHILE More DO
                    IF lrecItemSalesPriceGroup.NEXT = 0 THEN
                        More := FALSE
                    ELSE
                        IF NOT lrecItemSalesPriceGroup.MARK THEN
                            More := FALSE
                        ELSE BEGIN
                            LastItemDiscGr := lrecItemSalesPriceGroup.Code;
                            lrecItemPriceGrCount := lrecItemPriceGrCount - 1;
                            IF lrecItemPriceGrCount = 0 THEN
                                More := FALSE;
                        END;
                IF SelectionFilter <> '' THEN
                    SelectionFilter := SelectionFilter + '|';
                IF FirstItemDiscGr = LastItemDiscGr THEN
                    SelectionFilter := SelectionFilter + FirstItemDiscGr
                ELSE
                    SelectionFilter := SelectionFilter + FirstItemDiscGr + '..' + LastItemDiscGr;
                IF lrecItemPriceGrCount > 0 THEN BEGIN
                    lrecItemSalesPriceGroup.MARKEDONLY(TRUE);
                    lrecItemSalesPriceGroup.NEXT;
                END;
            END;
        END;
        EXIT(SelectionFilter);

    end;

}
