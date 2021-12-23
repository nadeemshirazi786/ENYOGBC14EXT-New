codeunit 51005 "User-Defined Fields Mgmt. ELA"
{
    procedure jfInsertItemRecord(pcodNo: Code[20])
    var
        grecBottleDepositSetup: Record "Bottle Deposit Setup";
        Item: Record Item;
    begin
        IF pcodNo = '' THEN
            EXIT;

        grecItemCustomFields.INIT;
        grecBottleDepositSetup.Init();

        grecItemCustomFields."Item No." := pcodNo;
        grecBottleDepositSetup."Item No." := pcodNo;
        If Item.Get(pcodNo) then
            grecBottleDepositSetup."Item Name" := Item.Description;

        If grecBottleDepositSetup.Insert() then;
        IF grecItemCustomFields.INSERT THEN;
    end;

    procedure jfCalcSalesBottleDeposit(VAR precSalesHeader: Record "Sales Header"; var gcodBottleDepositAcct: Code[20]; var gdecBottleDepositAmt: Decimal)
    var
        grecState: Record "State ELA";
        lrecShipToAddress: Record "Ship-to Address";
        grecLocation: Record Location;
        lrecSalesLine: Record "Sales Line";
        ldecValue: Decimal;
        recBottleState: Record "Bottle Deposit Setup";
    begin
        CLEAR(gcodBottleDepositAcct);
        CLEAR(gdecBottleDepositAmt);
        IF precSalesHeader."Shipment Method Code" <> 'PICKUP' THEN BEGIN
            IF (precSalesHeader."Document Type" = precSalesHeader."Document Type"::"Credit Memo") OR (precSalesHeader."Document Type" = precSalesHeader."Document Type"::"Return Order") THEN BEGIN
                IF (precSalesHeader."Ship-to Code" <> '') THEN BEGIN
                    lrecSalesLine.Reset();
                    lrecSalesLine.SetRange("Document No.", precSalesHeader."No.");
                    lrecSalesLine.SetRange("Document Type", precSalesHeader."Document Type");
                    lrecSalesLine.SetRange(type, lrecSalesLine.Type::Item);
                    lrecSalesLine.SetRange("Bottle Deposit", true);
                    if lrecSalesLine.FindFirst() then begin
                        if grecState.Get(precSalesHeader."Sell-to County") then begin
                            gcodBottleDepositAcct := grecState."Bottle Deposit Account";
                        end else
                            gcodBottleDepositAcct := '';

                    end;
                END ELSE BEGIN
                    gcodBottleDepositAcct := '';
                END;
            END ELSE begin
                lrecSalesLine.Reset();
                lrecSalesLine.SetRange("Document No.", precSalesHeader."No.");
                lrecSalesLine.SetRange("Document Type", precSalesHeader."Document Type");
                lrecSalesLine.SetRange(Type, lrecSalesLine.Type::Item);
                lrecSalesLine.SetRange("Bottle Deposit", true);
                if lrecSalesLine.FindFirst() then begin
                    if grecState.Get(precSalesHeader."Sell-to County") then begin
                        gcodBottleDepositAcct := grecState."Bottle Deposit Account";
                    end else
                        gcodBottleDepositAcct := '';
                end;
            end;
        END ELSE BEGIN
            IF grecLocation.GET(precSalesHeader."Location Code") THEN BEGIN
                lrecSalesLine.Reset();
                lrecSalesLine.SetRange("Document No.", precSalesHeader."No.");
                lrecSalesLine.SetRange("Document Type", precSalesHeader."Document Type");
                lrecSalesLine.SetRange(Type, lrecSalesLine.Type::Item);
                lrecSalesLine.SetRange("Bottle Deposit", true);
                if lrecSalesLine.FindFirst() then begin
                    if grecState.Get(grecLocation.County) then begin
                        gcodBottleDepositAcct := grecState."Bottle Deposit Account";
                    end else
                        gcodBottleDepositAcct := '';
                end;

            END;
        END;

        lrecSalesLine.Reset();
        lrecSalesLine.SETRANGE("Document Type", precSalesHeader."Document Type");
        lrecSalesLine.SETRANGE("Document No.", precSalesHeader."No.");
        lrecSalesLine.SETRANGE(Type, lrecSalesLine.Type::Item);
        IF lrecSalesLine.FINDSET THEN BEGIN
            REPEAT
                IF lrecSalesLine."Bottle Deposit" THEN BEGIN
                    IF EVALUATE(ldecValue, lrecSalesLine.GetBottleAmount(lrecSalesLine)) THEN
                        gdecBottleDepositAmt += (lrecSalesLine."Outstanding Quantity" * ldecValue);
                END;
            UNTIL lrecSalesLine.NEXT = 0;
        END;
    end;

    procedure jfCalcPurchBottleDeposit(VAR precPurchHeader: Record "Purchase Header"; var lcodBottleDepositAcct: Code[20]; var ldecBottleDepositAmt: Decimal)
    var
        grecState: Record "State ELA";
        grecLocation: Record Location;
        lrecPurchLine: Record "Purchase Line";
        ldecValue: Decimal;
        recBottleState: Record "Bottle Deposit Setup";
    begin
        CLEAR(lcodBottleDepositAcct);
        CLEAR(ldecBottleDepositAmt);
        IF precPurchHeader."Shipment Method Code" <> 'PICKUP' THEN BEGIN
            lrecPurchLine.Reset();
            lrecPurchLine.SetRange("Document No.", precPurchHeader."No.");
            lrecPurchLine.SetRange("Document Type", precPurchHeader."Document Type");
            lrecPurchLine.SetRange(Type, lrecPurchLine.Type::Item);
            lrecPurchLine.SetRange("Bottle Deposit", true);
            if lrecPurchLine.FindFirst() then begin
                if grecState.Get(precPurchHeader."Buy-from County") then begin
                    lcodBottleDepositAcct := grecState."Bottle Deposit Account";
                end else
                    lcodBottleDepositAcct := '';

            end;
        END ELSE BEGIN
            IF grecLocation.GET(precPurchHeader."Location Code") THEN BEGIN
                lrecPurchLine.Reset();
                lrecPurchLine.SetRange("Document No.", precPurchHeader."No.");
                lrecPurchLine.SetRange("Document Type", precPurchHeader."Document Type");
                lrecPurchLine.SetRange(Type, lrecPurchLine.Type::Item);
                lrecPurchLine.SetRange("Bottle Deposit", true);
                if lrecPurchLine.FindFirst() then begin
                    if grecState.Get(grecLocation.County) then begin
                        lcodBottleDepositAcct := grecState."Bottle Deposit Account";
                    end else
                        lcodBottleDepositAcct := '';
                end;
            end;
        END;
        lrecPurchLine.Reset();
        lrecPurchLine.SETRANGE("Document Type", precPurchHeader."Document Type");
        lrecPurchLine.SETRANGE("Document No.", precPurchHeader."No.");
        lrecPurchLine.SETRANGE(Type, lrecPurchLine.Type::Item);
        IF lrecPurchLine.FINDSET THEN BEGIN
            REPEAT
                IF lrecPurchLine."Bottle Deposit" THEN BEGIN
                    IF EVALUATE(ldecValue, lrecPurchLine.GetBottleAmount(lrecPurchLine)) THEN
                        ldecBottleDepositAmt += (lrecPurchLine.Quantity * ldecValue);
                END;
            UNTIL lrecPurchLine.NEXT = 0;
        END;
    end;

    var
        grecItemCustomFields: Record "User-Defined Fields - Item ELA";

}

