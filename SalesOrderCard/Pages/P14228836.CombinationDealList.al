page 14228836 "Combination Deals List ELA"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "EN Order Rule Detail Line";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(group)
            {
                field("Item Ref. No."; "Item Ref. No.")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    procedure FillData(precItem: Record Item)
    var
        lrecRuleDetLine: Record "EN Order Rule Detail Line";
        lrecRuleDetLine2: Record "EN Order Rule Detail Line";
        lrecRuleHeader: Record "EN Order Rule Detail";
    begin
        DELETEALL; //it is temp

        lrecRuleDetLine.SETRANGE("Sales Code", 'MAIN');
        lrecRuleDetLine.SETRANGE("Item Type", lrecRuleDetLine."Item Type"::Combination);
        lrecRuleDetLine.SETFILTER("Start Date", '%1..%2', 0D, WORKDATE);
        lrecRuleDetLine.SETFILTER("Ending Date", '%1|>=%2', 0D, WORKDATE);
        lrecRuleDetLine.SETRANGE("Item No.", precItem."No.");
        IF lrecRuleDetLine.FINDSET THEN
            REPEAT
                lrecRuleHeader.SETRANGE("Item Ref. No.", lrecRuleDetLine."Item Ref. No.");
                IF lrecRuleHeader.FIND('-') THEN BEGIN
                    IF (lrecRuleHeader."End Date" = 0D) OR (lrecRuleHeader."End Date" >= WORKDATE) THEN BEGIN
                        lrecRuleDetLine2 := lrecRuleDetLine;
                        lrecRuleDetLine2.SETRECFILTER;
                        lrecRuleDetLine2.SETFILTER("Start Date", '>%1', lrecRuleDetLine."Start Date");
                        IF lrecRuleDetLine2.ISEMPTY THEN BEGIN
                            Rec := lrecRuleDetLine;
                            IF INSERT THEN;
                        END;
                    END;
                END;
            UNTIL lrecRuleDetLine.NEXT = 0;
        RESET;
    end;

    procedure GetRecs(VAR precTempDetLine:  Record "EN Order Rule Detail Line" temporary)
    begin
        precTempDetLine.DELETEALL;
        IF FINDSET THEN
            REPEAT
                precTempDetLine := Rec;
                precTempDetLine.INSERT;
            UNTIL NEXT = 0;
    end;

    var
        myInt: Integer;
}