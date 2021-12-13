/// <summary>
/// Page EN Order Rule Groups (ID 14228862).
/// </summary>
page 14228862 "EN Order Rule Groups"
{
    ApplicationArea = Basic, Suite;
    DeleteAllowed = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    UsageCategory = Administration;
    PageType = List;
    SourceTable = "EN Order Rule Group";

    layout
    {
        area(content)
        {
            repeater(GeneralRepeater)
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
            group("Order Rule Groups")
            {
                Caption = 'Order Rule Groups';
                action("Order Rule Details")
                {
                    Caption = 'Order Rule Details';
                    RunObject = Page "EN Order Rule Details";
                    RunPageLink = "Sales Type"=CONST("Order Rule Group"),
                                  "Sales Code"=FIELD(Code);
                    RunPageView = SORTING("Sales Type","Sales Code","Ship-To Address Code","Item Type","Item Ref. No.","Start Date","Unit of Measure Code");
                }
            }
        }
    }

    /// <summary>
    /// GetSelectionFilter.
    /// </summary>
    /// <returns>Return value of type Code[80].</returns>

    procedure GetSelectionFilter(): Code[80]
    var
        OrderRuleGr: Record "EN Order Rule Group";
        FirstOrderRuleGr: Code[30];
        LastOrderRuleGr: Code[30];
        SelectionFilter: Code[250];
        OrderRuleGrCount: Integer;
        More: Boolean;
    begin
        CurrPage.SETSELECTIONFILTER(OrderRuleGr);
        OrderRuleGrCount := OrderRuleGr.COUNT;
        IF OrderRuleGrCount > 0 THEN BEGIN
          OrderRuleGr.FIND('-');
          WHILE OrderRuleGrCount > 0 DO BEGIN
            OrderRuleGrCount := OrderRuleGrCount - 1;
            OrderRuleGr.MARKEDONLY(FALSE);
            FirstOrderRuleGr := OrderRuleGr.Code;
            More := (OrderRuleGrCount > 0);
            WHILE More DO
              IF OrderRuleGr.NEXT = 0 THEN
                More := FALSE
              ELSE
                IF NOT OrderRuleGr.MARK THEN
                  More := FALSE
                ELSE BEGIN
                  LastOrderRuleGr := OrderRuleGr.Code;
                  OrderRuleGrCount := OrderRuleGrCount - 1;
                  IF OrderRuleGrCount = 0 THEN
                    More := FALSE;
                END;
            IF SelectionFilter <> '' THEN
              SelectionFilter := SelectionFilter + '|';
            IF FirstOrderRuleGr = LastOrderRuleGr THEN
              SelectionFilter := SelectionFilter + FirstOrderRuleGr
            ELSE
              SelectionFilter := SelectionFilter + FirstOrderRuleGr + '..' + LastOrderRuleGr;
            IF OrderRuleGrCount > 0 THEN BEGIN
              OrderRuleGr.MARKEDONLY(TRUE);
              OrderRuleGr.NEXT;
            END;
          END;
        END;
        EXIT(SelectionFilter);
    end;
}

