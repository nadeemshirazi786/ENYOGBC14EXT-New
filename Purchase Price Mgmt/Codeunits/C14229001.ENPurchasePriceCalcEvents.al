codeunit 14229001 "EN Purchase Price Calc Events"
{
    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeUpdateDirectUnitCost', '', true, true)]
    procedure OnBeforeUpdateDirectUnitCost(VAR PurchLine: Record "Purchase Line"; xPurchLine: Record "Purchase Line"; CalledByFieldNo: Integer; CurrFieldNo: Integer; VAR Handled: Boolean)
    var
        PurchPriceCalcMgt: Codeunit "EN Purch. Price Calc. Mgt.";
        PurchHeader: Record "Purchase Header";
        Currency: Record Currency;
        ItemVend: Record "Item Vendor";
        Item: Record Item;
    begin
        Handled := true;
        IF (CurrFieldNo <> 0) AND (PurchLine."Prod. Order No." <> '') THEN
            PurchLine.UpdateAmounts;

        IF ((CalledByFieldNo <> CurrFieldNo) AND (CurrFieldNo <> 0)) OR
           (PurchLine."Prod. Order No." <> '')
        THEN
            EXIT;

        IF PurchLine."Lock Pricing ELA" THEN BEGIN
            PurchLine.UpdateAmounts;
            EXIT;
        END;
        //IF gblnSuspendPriceCalc THEN
        //    EXIT;

        IF PurchLine.Type = PurchLine.Type::Item THEN BEGIN

            PurchLine.TESTFIELD("Document No.");
            IF (PurchLine."Document Type" <> PurchHeader."Document Type") OR (PurchLine."Document No." <> PurchHeader."No.") THEN BEGIN
                PurchHeader.GET(PurchLine."Document Type", PurchLine."Document No.");
                IF PurchHeader."Currency Code" = '' THEN
                    Currency.InitRoundingPrecision
                ELSE BEGIN
                    PurchHeader.TESTFIELD("Currency Factor");
                    Currency.GET(PurchHeader."Currency Code");
                    Currency.TESTFIELD("Amount Rounding Precision");
                END;
            END;

            PurchPriceCalcMgt.FindPurchLinePrice(PurchHeader, PurchLine, CalledByFieldNo);
            PurchPriceCalcMgt.FindPurchLineLineDisc(PurchHeader, PurchLine);
            PurchLine.VALIDATE("Direct Unit Cost");

            IF CalledByFieldNo IN [PurchLine.FIELDNO("No."), PurchLine.FIELDNO("Variant Code"), PurchLine.FIELDNO("Location Code")] THEN begin
                PurchLine.TESTFIELD("No.");
                IF Item."No." <> PurchLine."No." THEN
                    Item.GET(PurchLine."No.");

                ItemVend.INIT;
                ItemVend."Vendor No." := PurchLine."Buy-from Vendor No.";
                ItemVend."Variant Code" := PurchLine."Variant Code";
                Item.FindItemVend(ItemVend, PurchLine."Location Code");



                PurchLine.VALIDATE("Vendor Item No.", ItemVend."Vendor Item No.");
            end;

        END;
    end;
}
