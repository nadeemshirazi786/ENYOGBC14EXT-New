page 14228837 "Sales Price Factbox ELA"
{
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Buffer ELA";
    Editable = false;
    SourceTableTemporary = true;
    RefreshOnActivate = true;
    Caption = 'Sales Price FactBox';

    layout
    {
        area(Content)
        {
            field(gTitle; gTitle)
            {
                Caption = 'gTitle';
                Visible = false;
            }
            repeater("Item Ref.")
            {
                field(Code1; Code1)
                {
                    ApplicationArea = All;
                }
                field(Control50013; PriceArr[1])
                {
                    ApplicationArea = All;
                    BlankNumbers = BlankZero;
                    CaptionClass = TitleArr[1];
                    Caption = 'TitleArr[1]';
                    trigger OnDrillDown()
                    begin
                        DrillDown(TitleArr[1]);
                    end;
                }
                field(Control50012; PriceArr[2])
                {
                    ApplicationArea = All;
                    BlankNumbers = BlankZero;
                    CaptionClass = TitleArr[2];
                    Caption = 'TitleArr[2]';
                    trigger OnDrillDown()
                    begin
                        DrillDown(TitleArr[2]);
                    end;
                }
                field(Control50011; PriceArr[3])
                {
                    ApplicationArea = All;
                    BlankNumbers = BlankZero;
                    CaptionClass = TitleArr[3];
                    Caption = 'TitleArr[3]';
                    trigger OnDrillDown()
                    begin
                        DrillDown(TitleArr[3]);
                    end;
                }
                field(Control50010; PriceArr[4])
                {
                    ApplicationArea = All;
                    BlankNumbers = BlankZero;
                    CaptionClass = TitleArr[4];
                    Caption = 'TitleArr[4]';
                    trigger OnDrillDown()
                    begin
                        DrillDown(TitleArr[4]);
                    end;
                }
                field(Control50009; PriceArr[5])
                {
                    ApplicationArea = All;
                    BlankNumbers = BlankZero;
                    CaptionClass = TitleArr[5];
                    Caption = 'TitleArr[5]';
                    trigger OnDrillDown()
                    begin
                        DrillDown(TitleArr[5]);
                    end;
                }

            }
        }
    }


    var
        ItemRefArr: array[100] of Code[30];
        PriceArr: array[5] of Decimal;
        TitleArr: array[5] of Code[10];
        gSalesType: Option "Customer","Customer Price Group","All Customers","Campaign","Customer Buying Group","Price List Group";
        gItemNo: Code[20];
        gItemSalesPriceCalculation: Record "EN Sales Price";
        gTitle: Text;

    procedure esCalcCurrPrice(): Decimal
    var
        lcduSalesPriceCalcMgt: Codeunit "EN Sales Price Calc. Mgt.";
        lrecItem: Record Item;
    begin
        IF lrecItem.GET(gItemNo) THEN
            EXIT(lcduSalesPriceCalcMgt.ExecutePriceCalcCalcultion(gItemSalesPriceCalculation, lrecItem));
    end;

    procedure Set(VAR NewItem: Record Item; SalesType: Option "Customer","Customer Price Group","All Customers","Campaign","Customer Buying Group","Price List Group")
    var
        ItemUOM: Record "Item Unit of Measure";
        UOMCount: Integer;
        lBufferTMP: Record "Buffer ELA" temporary;
        lCodeKey: Code[20];
        lIntKey: Integer;
        lChr: Char;
    begin
        gSalesType := SalesType;
        gItemNo := NewItem."No.";
        CLEAR(TitleArr);
        gTitle := NewItem.Description;

        ItemUOM.SETFILTER("Item No.", NewItem."No.");
        ItemUOM.SETFILTER(Code, '<>%1', 'PALLET');
        IF NOT ItemUOM.FINDFIRST THEN BEGIN
            EXIT;
        END;
        UOMCount := 100;
        REPEAT
            lBufferTMP.Key1 := FORMAT((ROUND(ItemUOM."Qty. per Unit of Measure", 0.00001) * 100000) + 10000000);
            lBufferTMP.Key2 := FORMAT(UOMCount);
            lBufferTMP.Code1 := ItemUOM.Code;
            lBufferTMP.INSERT;
            UOMCount += 1;
        UNTIL ItemUOM.NEXT = 0;
        lBufferTMP.ASCENDING(FALSE);
        lBufferTMP.FINDFIRST;
        UOMCount := 0;
        REPEAT
            UOMCount += 1;
            TitleArr[UOMCount] := lBufferTMP.Code1;
        UNTIL lBufferTMP.NEXT = 0;

        lChr := 0;
        FOR UOMCount := 1 TO 5 DO BEGIN
            IF TitleArr[UOMCount] = '' THEN BEGIN
                TitleArr[UOMCount] := FORMAT(lChr);
            END;
        END;
        CurrPage.ACTIVATE(TRUE);
    end;

    procedure SetIpcFilters(pUomCode: Code[10]): Boolean
    begin
        WITH gItemSalesPriceCalculation DO BEGIN
            RESET;
            SETFILTER(Type, '%1', Type::Item);
            SETFILTER(Code, gItemNo);
            SETFILTER("Sales Type", '%1', gSalesType);
            SETFILTER("Starting Date", '%1|<=%2', 0D, WORKDATE);
            SETFILTER("Ending Date", '%1|>=%2', 0D, WORKDATE);
            //SETRANGE("Ending Date");
            SETFILTER("Unit of Measure Code", pUomCode);
            SETFILTER("Sales Code", Code2);
            EXIT(FINDFIRST);
        END;
    end;

    procedure DrillDown(pUomCode: Code[10])
    var
        lIpcPage: Page "EN Price List Line";
    begin
        IF NOT SetIpcFilters(pUomCode) THEN BEGIN
            EXIT;
        END;
        lIpcPage.SETRECORD(gItemSalesPriceCalculation);
        lIpcPage.SETTABLEVIEW(gItemSalesPriceCalculation);
        lIpcPage.LOOKUPMODE(FALSE);
        lIpcPage.RUNMODAL;
    end;

    trigger OnOpenPage()
    begin

        DELETEALL;
        Key1 := '1';
        Code1 := 'MAIN CC';
        Code2 := 'PGA SALE';
        INSERT;
        Key1 := '2';
        Code1 := 'MAIN DEL';
        Code2 := 'PGA SALE';
        INSERT;
        Key1 := '3';
        Code1 := 'SHAW';
        Code2 := 'SHAW SALE';
        INSERT;
        Key1 := '4';
        Code1 := 'MB1';
        Code2 := 'MB SALE';
        INSERT;
    end;

    trigger OnAfterGetRecord()
    var
        x: Integer;
    begin
        CLEAR(PriceArr);
        FOR x := 1 TO 5 DO BEGIN
            IF TitleArr[x] <> '' THEN BEGIN
                IF SetIpcFilters(TitleArr[x]) THEN BEGIN
                    IF Code1 <> 'MAIN DEL' THEN BEGIN
                        PriceArr[x] := esCalcCurrPrice;
                    END ELSE BEGIN
                        PriceArr[x] := gItemSalesPriceCalculation.isCalcDelUnitCost
                    END;
                END
            END;
        END;
        CurrPage.UPDATE(FALSE);
    end;
}