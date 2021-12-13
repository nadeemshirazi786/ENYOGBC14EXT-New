page 14228835 "Combination Deal Factbox ELA"
{
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = Item;
    Editable = false;
    Caption = 'Combination Deals';

    layout
    {
        area(Content)
        {
            field(Deals; GetDeals)
            {
                ApplicationArea = All;
                trigger OnDrillDown()
                var
                    lpagDeals: Page "Combination Deals List ELA";
                begin
                    lpagDeals.FillData(Rec);
                    lpagDeals.RUNMODAL;
                end;
            }
            fixed("")
            {
                group(Control50003)
                {
                    Caption = 'Item Ref.';
                    field("Control50004"; ItemRefArr[1])
                    {
                        Caption = '';
                        ApplicationArea = All;
                    }
                    field("Control50005"; ItemRefArr[2])
                    {
                        Caption = '';
                        ApplicationArea = All;
                    }
                    field(Control50006; ItemRefArr[3])
                    {
                        Caption = '';
                        ApplicationArea = All;
                    }
                    field(Control50007; ItemRefArr[4])
                    {
                        Caption = '';
                        ApplicationArea = All;
                    }
                    field(Control50008; ItemRefArr[5])
                    {
                        Caption = '';
                        ApplicationArea = All;
                    }
                }
                group(Control50014)
                {
                    Caption = 'Price';
                    field(Control50013; PriceArr[1])
                    {
                        ApplicationArea = All;
                        BlankNumbers = BlankZero;
                    }
                    field(Control50012; PriceArr[2])
                    {
                        ApplicationArea = All;
                        BlankNumbers = BlankZero;
                    }
                    field(Control50011; PriceArr[3])
                    {
                        ApplicationArea = All;
                        BlankNumbers = BlankZero;
                    }
                    field(Control50010; PriceArr[4])
                    {
                        ApplicationArea = All;
                        BlankNumbers = BlankZero;
                    }
                    field(Control50009; PriceArr[5])
                    {
                        ApplicationArea = All;
                        BlankNumbers = BlankZero;
                    }
                }
            }
        }
    }

    var
        ItemRefArr: array[100] of Code[30];
        PriceArr: array[100] of Decimal;

    procedure GetDeals(): Integer
    var
        lpagDeals: Page "Combination Deals List ELA";
        lrecTempDetLine: Record "EN Order Rule Detail Line";
        i: Integer;
    begin
        lpagDeals.FillData(Rec);
        lpagDeals.GetRecs(lrecTempDetLine);
        CLEAR(ItemRefArr);
        CLEAR(PriceArr);
        IF lrecTempDetLine.FINDSET THEN
            REPEAT
                i += 1;
                ItemRefArr[i] := lrecTempDetLine."Item Ref. No.";
                PriceArr[i] := lrecTempDetLine."Unit Price";
            UNTIL (lrecTempDetLine.NEXT = 0) OR (i >= 100);

        EXIT(lrecTempDetLine.COUNT);
    end;
}