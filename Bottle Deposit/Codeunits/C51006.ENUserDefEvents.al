codeunit 51006 "User Def. Custom Events ELA"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterAssignFieldsForNo', '', true, true)]
    local procedure OnAfterAssignFieldsNo(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    var
        State: Record "State ELA";
        InventSetup: Record "Inventory Setup";
        recBottleDeposit: Record Item;
        recBottleState: Record "Bottle Deposit Setup";
        grecState: Record "State ELA";
        lrecLocation: Record Location;
    begin
        InventSetup.Get();
        IF InventSetup."Copy to Sales Documents" then begin
            IF recBottleDeposit.Get(SalesLine."No.") then begin
                IF recBottleDeposit."Bottle Deposit - Sales" then begin
                    recBottleState.Reset();
                    recBottleState.SetRange("Item No.", SalesLine."No.");
                    recBottleState.SetFilter("Bottle Deposit State", '=%1', SalesHeader."Sell-to County");
                    if recBottleState.FindFirst() then begin
                        if recBottleState.Get(SalesLine."No.", SalesHeader."Sell-to County") then
                            SalesLine.Validate("Bottle Deposit", true);
                    end else begin
                        if grecState.Get(SalesHeader."Sell-to County") then begin
                            SalesLine.Validate("Bottle Deposit", true);
                        end else begin
                            IF lrecLocation.GET(SalesHeader."Location Code") THEN begin
                                IF grecState.Get(lrecLocation.County) then
                                    SalesLine.Validate("Bottle Deposit", true);
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 414, 'OnBeforeCalcInvDiscount', '', true, true)]
    local procedure BeforeCalcSalesInvDiscount(SalesHeader: Record "Sales Header")
    var
        grecSalesHeader: Record "Sales Header";
        lcduReleaseSalesDoc: Codeunit "Release Sales Document";
        BottleDepositAmt: Decimal;
        BottleDepositAcct: Code[20];
        UDFieldMgmt: Codeunit "User-Defined Fields Mgmt. ELA";
        grecSalesLine: Record "Sales Line";
        gintLineNo: Integer;
        grecSalesLine2: Record "Sales Line";
        grecSalesLine3: Record "Sales Line";
        grecState: Record "State ELA";
        lrecLocation: Record Location;
    begin
        Clear(BottleDepositAcct);
        Clear(BottleDepositAmt);
        IF SalesHeader."Document Type" IN [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice] then begin
            IF SalesHeader."Shipment Method Code" <> 'PICKUP' then begin
                IF not grecState.Get(SalesHeader."Sell-to County") then
                    exit;
                UDFieldMgmt.jfCalcSalesBottleDeposit(SalesHeader, BottleDepositAcct, BottleDepositAmt);

                grecSalesLine.Reset();
                grecSalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
                grecSalesLine.SETRANGE("Document No.", SalesHeader."No.");
                grecSalesLine.SetRange("Bottle Deposit", true);
                IF grecSalesLine.FINDLAST THEN BEGIN

                    grecSalesLine2.RESET;
                    grecSalesLine2.SetRange("Document No.", grecSalesLine."Document No.");
                    grecSalesLine2.SetRange("No.", BottleDepositAcct);
                    if grecSalesLine2.FindFirst() then begin
                        grecSalesLine2.VALIDATE("Unit Price", ROUND((BottleDepositAmt), 0.01));
                        grecSalesLine2.MODIFY(true);
                    end else begin
                        grecSalesLine3.Reset();
                        grecSalesLine3.SetRange("Document No.", grecSalesLine."Document No.");
                        grecSalesLine3.SetRange("Document Type", grecSalesLine."Document Type");
                        IF grecSalesLine3.FindLast() then
                            gintLineNo := grecSalesLine3."Line No." + 10000;
                        grecSalesLine.RESET;
                        grecSalesLine.INIT;
                        grecSalesLine.VALIDATE("Document Type", SalesHeader."Document Type");
                        grecSalesLine.VALIDATE("Document No.", SalesHeader."No.");
                        grecSalesLine.VALIDATE("Line No.", gintLineNo);
                        grecSalesLine.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                        grecSalesLine.INSERT(true);

                        grecSalesLine.Validate("Location Code", grecSalesHeader."Location Code");
                        grecSalesLine.VALIDATE(Type, grecSalesLine.Type::"G/L Account");
                        grecSalesLine.VALIDATE("No.", BottleDepositAcct);
                        grecSalesLine.VALIDATE(Quantity, 1);
                        //grecSalesLine.Validate("Qty. to Ship", 0);
                        grecSalesLine.VALIDATE("Unit Price", ROUND((BottleDepositAmt), 0.01));
                        grecSalesLine.MODIFY(true);
                    end;
                end;
            end else begin
                If lrecLocation.Get(SalesHeader."Location Code") then begin
                    UDFieldMgmt.jfCalcSalesBottleDeposit(SalesHeader, BottleDepositAcct, BottleDepositAmt);

                    grecSalesLine.Reset();
                    grecSalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
                    grecSalesLine.SETRANGE("Document No.", SalesHeader."No.");
                    grecSalesLine.SetRange("Bottle Deposit", true);
                    IF grecSalesLine.FINDLAST THEN BEGIN

                        grecSalesLine2.RESET;
                        grecSalesLine2.SetRange("Document No.", grecSalesLine."Document No.");
                        grecSalesLine2.SetRange("No.", BottleDepositAcct);
                        if grecSalesLine2.FindFirst() then begin
                            grecSalesLine2.VALIDATE("Unit Price", ROUND((BottleDepositAmt), 0.01));
                            grecSalesLine2.MODIFY(true);
                        end else begin
                            grecSalesLine3.Reset();
                            grecSalesLine3.SetRange("Document No.", grecSalesLine."Document No.");
                            grecSalesLine3.SetRange("Document Type", grecSalesLine."Document Type");
                            IF grecSalesLine3.FindLast() then
                                gintLineNo := grecSalesLine3."Line No." + 10000;
                            grecSalesLine.RESET;
                            grecSalesLine.INIT;
                            grecSalesLine.VALIDATE("Document Type", SalesHeader."Document Type");
                            grecSalesLine.VALIDATE("Document No.", SalesHeader."No.");
                            grecSalesLine.VALIDATE("Line No.", gintLineNo);
                            grecSalesLine.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                            grecSalesLine.INSERT(true);

                            grecSalesLine.Validate("Location Code", grecSalesHeader."Location Code");
                            grecSalesLine.VALIDATE(Type, grecSalesLine.Type::"G/L Account");
                            grecSalesLine.VALIDATE("No.", BottleDepositAcct);
                            grecSalesLine.VALIDATE(Quantity, 1);
                            //grecSalesLine.Validate("Qty. to Ship", 0);
                            grecSalesLine.VALIDATE("Unit Price", ROUND((BottleDepositAmt), 0.01));
                            grecSalesLine.MODIFY(true);
                        end;
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforeInsertPostedHeaders', '', true, true)]
    local procedure OnBeforeInsertPostedHeaders(SalesHeader: Record "Sales Header")
    var
        grecSalesHeader: Record "Sales Header";
        lcduReleaseSalesDoc: Codeunit "Release Sales Document";
        BottleDepositAmt: Decimal;
        BottleDepositAcct: Code[20];
        UDFieldMgmt: Codeunit "User-Defined Fields Mgmt. ELA";
        grecSalesLine: Record "Sales Line";
        gintLineNo: Integer;
        grecSalesLine2: Record "Sales Line";
        grecSalesLine3: Record "Sales Line";
        grecState: Record "State ELA";
        lrecLocation: Record Location;
    begin
        Clear(BottleDepositAcct);
        Clear(BottleDepositAmt);
        IF SalesHeader."Document Type" IN [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice] then begin
            IF SalesHeader."Shipment Method Code" <> 'PICKUP' then begin
                IF not grecState.Get(SalesHeader."Sell-to County") then
                    exit;
                UDFieldMgmt.jfCalcSalesBottleDeposit(SalesHeader, BottleDepositAcct, BottleDepositAmt);

                grecSalesHeader.RESET;
                IF grecSalesHeader.GET(SalesHeader."Document Type", SalesHeader."No.") THEN BEGIN
                    IF grecSalesHeader.Status <> grecSalesHeader.Status::Open THEN BEGIN
                        CLEAR(lcduReleaseSalesDoc);
                        lcduReleaseSalesDoc.Reopen(grecSalesHeader);
                    END;
                    grecSalesLine.Reset();
                    grecSalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
                    grecSalesLine.SETRANGE("Document No.", SalesHeader."No.");
                    grecSalesLine.SetRange("Bottle Deposit", true);
                    IF grecSalesLine.FINDLAST THEN BEGIN

                        grecSalesLine2.RESET;
                        grecSalesLine2.SetRange("Document No.", grecSalesLine."Document No.");
                        grecSalesLine2.SetRange("No.", BottleDepositAcct);
                        if grecSalesLine2.FindFirst() then begin
                            grecSalesLine2.VALIDATE("Unit Price", ROUND((BottleDepositAmt), 0.01));
                            //grecSalesLine2.MODIFY;
                        end else begin
                            grecSalesLine3.Reset();
                            grecSalesLine3.SetRange("Document No.", grecSalesLine."Document No.");
                            grecSalesLine3.SetRange("Document Type", grecSalesLine."Document Type");
                            IF grecSalesLine3.FindLast() then
                                gintLineNo := grecSalesLine3."Line No." + 10000;
                            grecSalesLine.RESET;
                            grecSalesLine.INIT;
                            grecSalesLine.VALIDATE("Document Type", SalesHeader."Document Type");
                            grecSalesLine.VALIDATE("Document No.", SalesHeader."No.");
                            grecSalesLine.VALIDATE("Line No.", gintLineNo);
                            grecSalesLine.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                            grecSalesLine.INSERT(true);

                            grecSalesLine.Validate("Location Code", grecSalesHeader."Location Code");
                            grecSalesLine.VALIDATE(Type, grecSalesLine.Type::"G/L Account");
                            grecSalesLine.VALIDATE("No.", BottleDepositAcct);
                            grecSalesLine.VALIDATE(Quantity, 1);
                            //grecSalesLine.Validate("Qty. to Ship", 0);
                            grecSalesLine.VALIDATE("Unit Price", ROUND((BottleDepositAmt), 0.01));
                            grecSalesLine.MODIFY(true);
                        end;
                    END;
                end;
            end else begin
                If lrecLocation.Get(SalesHeader."Location Code") then begin
                    UDFieldMgmt.jfCalcSalesBottleDeposit(SalesHeader, BottleDepositAcct, BottleDepositAmt);

                    grecSalesLine.Reset();
                    grecSalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
                    grecSalesLine.SETRANGE("Document No.", SalesHeader."No.");
                    grecSalesLine.SetRange("Bottle Deposit", true);
                    IF grecSalesLine.FINDLAST THEN BEGIN

                        grecSalesLine2.RESET;
                        grecSalesLine2.SetRange("Document No.", grecSalesLine."Document No.");
                        grecSalesLine2.SetRange("No.", BottleDepositAcct);
                        if grecSalesLine2.FindFirst() then begin
                            grecSalesLine2.VALIDATE("Unit Price", ROUND((BottleDepositAmt), 0.01));
                            grecSalesLine2.MODIFY(true);
                        end else begin
                            grecSalesLine3.Reset();
                            grecSalesLine3.SetRange("Document No.", grecSalesLine."Document No.");
                            grecSalesLine3.SetRange("Document Type", grecSalesLine."Document Type");
                            IF grecSalesLine3.FindLast() then
                                gintLineNo := grecSalesLine3."Line No." + 10000;
                            grecSalesLine.RESET;
                            grecSalesLine.INIT;
                            grecSalesLine.VALIDATE("Document Type", SalesHeader."Document Type");
                            grecSalesLine.VALIDATE("Document No.", SalesHeader."No.");
                            grecSalesLine.VALIDATE("Line No.", gintLineNo);
                            grecSalesLine.VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
                            grecSalesLine.INSERT(true);

                            grecSalesLine.Validate("Location Code", grecSalesHeader."Location Code");
                            grecSalesLine.VALIDATE(Type, grecSalesLine.Type::"G/L Account");
                            grecSalesLine.VALIDATE("No.", BottleDepositAcct);
                            grecSalesLine.VALIDATE(Quantity, 1);
                            //grecSalesLine.Validate("Qty. to Ship", 0);
                            grecSalesLine.VALIDATE("Unit Price", ROUND((BottleDepositAmt), 0.01));
                            grecSalesLine.MODIFY(true);
                        end;
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterAssignFieldsForNo', '', true, true)]
    local procedure AfterAssignFieldsForNo(var PurchLine: Record "Purchase Line"; PurchHeader: Record "Purchase Header")
    var
        UserDefItem: Record "User-Defined Fields - Item ELA";
        InventSetup: Record "Inventory Setup";
        recBottleDeposit: Record Item;
        recBottleState: Record "Bottle Deposit Setup";
        grecState: Record "State ELA";
        lrecLocation: Record Location;
    begin
        InventSetup.Get();
        IF InventSetup."Copy to Purchase Documents" then begin
            IF recBottleDeposit.Get(PurchLine."No.") then begin
                IF recBottleDeposit."Bottle Deposit - Purchase" then begin
                    recBottleState.Reset();
                    recBottleState.SetRange("Item No.", PurchLine."No.");
                    recBottleState.SetFilter("Bottle Deposit State", '=%1', PurchHeader."Buy-from County");
                    if recBottleState.FindFirst() then begin
                        if recBottleState.Get(PurchLine."No.", PurchHeader."Buy-from County") then
                            PurchLine.Validate("Bottle Deposit", true);
                    end else begin
                        if grecState.Get(PurchHeader."Buy-from County") then begin
                            PurchLine.Validate("Bottle Deposit", true);
                        end else begin
                            IF lrecLocation.GET(PurchHeader."Location Code") THEN begin
                                IF grecState.Get(lrecLocation.County) then
                                    PurchLine.Validate("Bottle Deposit", true);
                            end;
                        end;
                    end;
                end;
            end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, 415, 'OnBeforeCalcInvDiscount', '', true, true)]
    procedure BeforeCalcPurchInvDiscount(var PurchaseHeader: Record "Purchase Header")
    var
        grecPurchHeader: Record "Purchase Header";
        BottleDepositAmt: Decimal;
        BottleDepositAcct: Code[20];
        UDFieldMgmt: Codeunit "User-Defined Fields Mgmt. ELA";
        grecPurchLine: Record "Purchase Line";
        grecPurchLine2: Record "Purchase Line";
        grecPurchLine3: Record "Purchase Line";
        gintLineNo: Integer;
        grecState: Record "State ELA";
        lrecLocation: Record Location;
    begin
        Clear(BottleDepositAcct);
        Clear(BottleDepositAmt);

        IF PurchaseHeader."Document Type" IN [PurchaseHeader."Document Type"::Order, PurchaseHeader."Document Type"::Invoice] then begin
            IF PurchaseHeader."Shipment Method Code" <> 'PICKUP' then begin
                IF not grecState.Get(PurchaseHeader."Buy-from County") then
                    exit;
                UDFieldMgmt.jfCalcPurchBottleDeposit(PurchaseHeader, BottleDepositAcct, BottleDepositAmt);

                grecPurchLine.Reset();
                grecPurchLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
                grecPurchLine.SETRANGE("Document No.", PurchaseHeader."No.");
                grecPurchLine.SetRange("Bottle Deposit", true);
                IF grecPurchLine.FINDLAST THEN BEGIN

                    grecPurchLine2.RESET;
                    grecPurchLine2.SetRange("Document No.", grecPurchLine."Document No.");
                    grecPurchLine2.SetRange("No.", BottleDepositAcct);
                    if grecPurchLine2.FindFirst() then begin
                        grecPurchLine2.VALIDATE("Direct Unit Cost", ROUND((BottleDepositAmt), 0.01));
                        grecPurchLine2.MODIFY(true);
                    end else begin
                        grecPurchLine3.Reset();
                        grecPurchLine3.SetRange("Document No.", grecPurchLine."Document No.");
                        grecPurchLine3.SetRange("Document Type", grecPurchLine."Document Type");
                        IF grecPurchLine3.FindLast() then
                            gintLineNo := grecPurchLine3."Line No." + 10000;
                        grecPurchLine.Reset();
                        grecPurchLine.INIT;
                        grecPurchLine.VALIDATE("Document Type", PurchaseHeader."Document Type");
                        grecPurchLine.VALIDATE("Document No.", PurchaseHeader."No.");
                        grecPurchLine.VALIDATE("Line No.", gintLineNo);
                        grecPurchLine.VALIDATE("Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.");
                        grecPurchLine.INSERT(true);

                        grecPurchLine.Validate("Location Code", grecPurchHeader."Location Code");
                        grecPurchLine.VALIDATE(Type, grecPurchLine.Type::"G/L Account");
                        grecPurchLine.VALIDATE("No.", BottleDepositAcct);
                        grecPurchLine.VALIDATE(Quantity, 1);
                        grecPurchLine.VALIDATE("Direct Unit Cost", ROUND((BottleDepositAmt), 0.01));
                        grecPurchLine.Validate("Qty. to Receive", 0);
                        grecPurchLine.MODIFY(true);
                    end;
                end;
            end else begin
                If lrecLocation.Get(PurchaseHeader."Location Code") then begin
                    UDFieldMgmt.jfCalcPurchBottleDeposit(PurchaseHeader, BottleDepositAcct, BottleDepositAmt);
                    grecPurchLine.Reset();
                    grecPurchLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
                    grecPurchLine.SETRANGE("Document No.", PurchaseHeader."No.");
                    grecPurchLine.SetRange("Bottle Deposit", true);
                    IF grecPurchLine.FINDLAST THEN BEGIN
                        grecPurchLine2.RESET;
                        grecPurchLine2.SetRange("Document No.", grecPurchLine."Document No.");
                        grecPurchLine2.SetRange("No.", BottleDepositAcct);
                        if grecPurchLine2.FindFirst() then begin
                            grecPurchLine2.VALIDATE("Direct Unit Cost", ROUND((BottleDepositAmt), 0.01));
                            grecPurchLine2.MODIFY(true);
                        end else begin
                            grecPurchLine3.Reset();
                            grecPurchLine3.SetRange("Document No.", grecPurchLine."Document No.");
                            grecPurchLine3.SetRange("Document Type", grecPurchLine."Document Type");
                            IF grecPurchLine3.FindLast() then
                                gintLineNo := grecPurchLine3."Line No." + 10000;
                            grecPurchLine.Reset();
                            grecPurchLine.INIT;
                            grecPurchLine.VALIDATE("Document Type", PurchaseHeader."Document Type");
                            grecPurchLine.VALIDATE("Document No.", PurchaseHeader."No.");
                            grecPurchLine.VALIDATE("Line No.", gintLineNo);
                            grecPurchLine.VALIDATE("Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.");
                            grecPurchLine.INSERT(true);

                            grecPurchLine.Validate("Location Code", grecPurchHeader."Location Code");
                            grecPurchLine.VALIDATE(Type, grecPurchLine.Type::"G/L Account");
                            grecPurchLine.VALIDATE("No.", BottleDepositAcct);
                            grecPurchLine.VALIDATE(Quantity, 1);
                            grecPurchLine.VALIDATE("Direct Unit Cost", ROUND((BottleDepositAmt), 0.01));
                            grecPurchLine.Validate("Qty. to Receive", 0);
                            grecPurchLine.MODIFY(true);
                        end;
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforeInsertPostedHeaders', '', true, true)]
    procedure OnBeforeInsertPostedPurchHeaders(var PurchaseHeader: Record "Purchase Header")
    var
        grecPurchHeader: Record "Purchase Header";
        BottleDepositAmt: Decimal;
        BottleDepositAcct: Code[20];
        UDFieldMgmt: Codeunit "User-Defined Fields Mgmt. ELA";
        grecPurchLine: Record "Purchase Line";
        gintLineNo: Integer;
        lcduReleasePurchDoc: Codeunit "Release Purchase Document";
        grecPurchLine2: Record "Purchase Line";
        grecPurchLine3: Record "Purchase Line";
        grecState: Record "State ELA";
        lrecLocation: Record Location;
    begin
        Clear(BottleDepositAcct);
        Clear(BottleDepositAmt);
        IF PurchaseHeader."Document Type" IN [PurchaseHeader."Document Type"::Order, PurchaseHeader."Document Type"::Invoice] then begin
            IF PurchaseHeader."Shipment Method Code" <> 'PICKUP' then begin
                IF not grecState.Get(PurchaseHeader."Buy-from County") then
                    exit;
                UDFieldMgmt.jfCalcPurchBottleDeposit(PurchaseHeader, BottleDepositAcct, BottleDepositAmt);

                grecPurchHeader.RESET;
                IF grecPurchHeader.GET(PurchaseHeader."Document Type", PurchaseHeader."No.") THEN BEGIN
                    IF grecPurchHeader.Status <> grecPurchHeader.Status::Open THEN BEGIN
                        CLEAR(lcduReleasePurchDoc);
                        lcduReleasePurchDoc.Reopen(grecPurchHeader);
                    END;
                    grecPurchLine.Reset();
                    grecPurchLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
                    grecPurchLine.SETRANGE("Document No.", PurchaseHeader."No.");
                    grecPurchLine.SetRange("Bottle Deposit", true);
                    IF grecPurchLine.FINDLAST THEN BEGIN

                        grecPurchLine2.RESET;
                        grecPurchLine2.SetRange("Document No.", grecPurchLine."Document No.");
                        grecPurchLine2.SetRange("No.", BottleDepositAcct);
                        if grecPurchLine2.FindFirst() then begin
                            grecPurchLine2.VALIDATE("Unit Cost", ROUND((BottleDepositAmt), 0.01));
                            grecPurchLine2.MODIFY(true);
                        end else begin
                            grecPurchLine3.Reset();
                            grecPurchLine3.SetRange("Document No.", grecPurchLine."Document No.");
                            grecPurchLine3.SetRange("Document Type", grecPurchLine."Document Type");
                            IF grecPurchLine3.FindLast() then
                                gintLineNo := grecPurchLine3."Line No." + 10000;
                            grecPurchLine.RESET;
                            grecPurchLine.INIT;
                            grecPurchLine.VALIDATE("Document Type", PurchaseHeader."Document Type");
                            grecPurchLine.VALIDATE("Document No.", PurchaseHeader."No.");
                            grecPurchLine.VALIDATE("Line No.", gintLineNo);
                            grecPurchLine.VALIDATE("Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.");
                            grecPurchLine.INSERT(true);

                            grecPurchLine.Validate("Location Code", grecPurchHeader."Location Code");
                            grecPurchLine.VALIDATE(Type, grecPurchLine.Type::"G/L Account");
                            grecPurchLine.VALIDATE("No.", BottleDepositAcct);
                            grecPurchLine.VALIDATE(Quantity, 1);
                            grecPurchLine.Validate("Qty. to Receive", 0);
                            grecPurchLine.VALIDATE("Unit Cost", ROUND((BottleDepositAmt), 0.01));
                            grecPurchLine.MODIFY(true);
                        end;
                    END;
                end;
            end else begin
                If lrecLocation.Get(PurchaseHeader."Location Code") then begin
                    UDFieldMgmt.jfCalcPurchBottleDeposit(PurchaseHeader, BottleDepositAcct, BottleDepositAmt);
                    grecPurchLine.Reset();
                    grecPurchLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
                    grecPurchLine.SETRANGE("Document No.", PurchaseHeader."No.");
                    grecPurchLine.SetRange("Bottle Deposit", true);
                    IF grecPurchLine.FINDLAST THEN BEGIN
                        grecPurchLine2.RESET;
                        grecPurchLine2.SetRange("Document No.", grecPurchLine."Document No.");
                        grecPurchLine2.SetRange("No.", BottleDepositAcct);
                        if grecPurchLine2.FindFirst() then begin
                            grecPurchLine2.VALIDATE("Direct Unit Cost", ROUND((BottleDepositAmt), 0.01));
                            grecPurchLine2.MODIFY(true);
                        end else begin
                            grecPurchLine3.Reset();
                            grecPurchLine3.SetRange("Document No.", grecPurchLine."Document No.");
                            grecPurchLine3.SetRange("Document Type", grecPurchLine."Document Type");
                            IF grecPurchLine3.FindLast() then
                                gintLineNo := grecPurchLine3."Line No." + 10000;
                            grecPurchLine.Reset();
                            grecPurchLine.INIT;
                            grecPurchLine.VALIDATE("Document Type", PurchaseHeader."Document Type");
                            grecPurchLine.VALIDATE("Document No.", PurchaseHeader."No.");
                            grecPurchLine.VALIDATE("Line No.", gintLineNo);
                            grecPurchLine.VALIDATE("Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.");
                            grecPurchLine.INSERT(true);

                            grecPurchLine.Validate("Location Code", grecPurchHeader."Location Code");
                            grecPurchLine.VALIDATE(Type, grecPurchLine.Type::"G/L Account");
                            grecPurchLine.VALIDATE("No.", BottleDepositAcct);
                            grecPurchLine.VALIDATE(Quantity, 1);
                            grecPurchLine.VALIDATE("Direct Unit Cost", ROUND((BottleDepositAmt), 0.01));
                            grecPurchLine.Validate("Qty. to Receive", 0);
                            grecPurchLine.MODIFY(true);
                        end;
                    end;
                end;
            end;
        end;
    end;

    var
        gcduUserDefFieldMgmt: Codeunit "User-Defined Fields Mgmt. ELA";
}