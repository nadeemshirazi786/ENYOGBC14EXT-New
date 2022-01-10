page 14229000 " EN Vendor Price Groups"
{

    Caption = 'Vendor Price Groups';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "EN Vendor Price Group";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Code)
                {
                }
                field(Description; Description)
                {
                }

            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Vendor &Price Group")
            {
                Caption = 'Vendor &Price Group';
                action("Purchase &Prices")
                {
                    Caption = 'Purchase &Prices';
                    RunObject = Page 7012;
                    RunPageLink = "Purchase Type ELA" = CONST("Vendor Price Group"), "Vendor No." = FIELD(Code);

                }
            }
        }
    }

    [Scope('Internal')]
    procedure GetSelectionFilter(): Code[80]
    var
        VendPriceGr: Record "EN Vendor Price Group";
        FirstVendPriceGr: Code[30];
        LastVendPriceGr: Code[30];
        SelectionFilter: Code[250];
        VendPriceGrCount: Integer;
        More: Boolean;
    begin
        CurrPage.SETSELECTIONFILTER(VendPriceGr);
        VendPriceGrCount := VendPriceGr.COUNT;
        IF VendPriceGrCount > 0 THEN BEGIN
            VendPriceGr.FIND('-');
            WHILE VendPriceGrCount > 0 DO BEGIN
                VendPriceGrCount := VendPriceGrCount - 1;
                VendPriceGr.MARKEDONLY(FALSE);
                FirstVendPriceGr := VendPriceGr.Code;
                LastVendPriceGr := FirstVendPriceGr;
                More := (VendPriceGrCount > 0);
                WHILE More DO
                    IF VendPriceGr.NEXT = 0 THEN
                        More := FALSE
                    ELSE
                        IF NOT VendPriceGr.MARK THEN
                            More := FALSE
                        ELSE BEGIN
                            LastVendPriceGr := VendPriceGr.Code;
                            VendPriceGrCount := VendPriceGrCount - 1;
                            IF VendPriceGrCount = 0 THEN
                                More := FALSE;
                        END;
                IF SelectionFilter <> '' THEN
                    SelectionFilter := SelectionFilter + '|';
                IF FirstVendPriceGr = LastVendPriceGr THEN
                    SelectionFilter := SelectionFilter + FirstVendPriceGr
                ELSE
                    SelectionFilter := SelectionFilter + FirstVendPriceGr + '..' + LastVendPriceGr;
                IF VendPriceGrCount > 0 THEN BEGIN
                    VendPriceGr.MARKEDONLY(TRUE);
                    VendPriceGr.NEXT;
                END;
            END;
        END;
        EXIT(SelectionFilter);
    end;
}

