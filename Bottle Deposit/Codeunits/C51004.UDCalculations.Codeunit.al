codeunit 51004 "UD Calculations ELA"
{
    trigger OnRun()
    begin
    end;

    procedure jfUOMConvert(pcodItem: Code[20]; pcodFromUOM: Code[10]; pcodToUOM: Code[10]; pdecQuantity: Decimal): Decimal
    var
        lrecItem: Record Item;
        lrecItemUOM: Record "Item Unit of Measure";
        ldecFactor1: Decimal;
        ldecFactor2: Decimal;
        ldecResult: Decimal;
        ErrTxt: Label 'Could not convert %1 to %2 for item %3, no Item Unit of Measure record found for %4';
    begin
        IF pcodFromUOM = pcodToUOM THEN
            EXIT(pdecQuantity);
        lrecItem.GET(pcodItem);
        lrecItemUOM.SETRANGE("Item No.", pcodItem);
        lrecItemUOM.SETRANGE(Code, pcodFromUOM);
        IF NOT lrecItemUOM.FINDFIRST THEN
            EXIT(0);
        IF lrecItemUOM."Qty. per Unit of Measure" > lrecItemUOM."Qty. per Base UOM ELA" THEN
            ldecFactor1 := 1 / lrecItemUOM."Qty. per Unit of Measure"
        ELSE
            ldecFactor1 := lrecItemUOM."Qty. per Base UOM ELA";

        lrecItemUOM.SETRANGE(Code, pcodToUOM);
        IF NOT lrecItemUOM.FINDFIRST THEN
            EXIT(0);
        IF lrecItemUOM."Qty. per Unit of Measure" > lrecItemUOM."Qty. per Base UOM ELA" THEN
            ldecFactor2 := 1 / lrecItemUOM."Qty. per Unit of Measure"
        ELSE
            ldecFactor2 := lrecItemUOM."Qty. per Base UOM ELA";

        IF ldecFactor1 > ldecFactor2 THEN
            ldecResult := pdecQuantity * ldecFactor2 / ldecFactor1
        ELSE
            ldecResult := pdecQuantity / ldecFactor1 * ldecFactor2;

        EXIT(ldecResult);
    end;
}

