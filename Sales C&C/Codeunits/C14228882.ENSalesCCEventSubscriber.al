codeunit 14228882 "EN Sales CC Event Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterSalesInvHeaderInsert', '', true, true)]
    procedure OnAfterSalesInvHeaderInsert(VAR SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean)
    begin
        SalesInvHeader."Source Type ELA" := SalesHeader."Source Type ELA";
        SalesInvHeader."Source Subtype ELA" := SalesHeader."Source Subtype ELA";
        SalesInvHeader."Source ID ELA" := SalesHeader."Source ID ELA";
        SalesInvHeader."Authorized Amount ELA" := SalesHeader."Authorized Amount ELA";
        SalesInvHeader."Authorized User ELA" := SalesHeader."Authorized User ELA";
        SalesInvHeader."Cash & Carry ELA" := SalesHeader."Cash & Carry ELA";
        SalesInvHeader."Cash Applied (Current) ELA" := SalesHeader."Cash Applied (Current) ELA";
        SalesInvHeader."Cash Applied (Other) ELA" := SalesHeader."Cash Applied (Other) ELA";
        SalesInvHeader."Cash Tendered ELA" := SalesHeader."Cash Tendered ELA";
        SalesInvHeader."Cash vs Amount Incld Tax ELA" := SalesHeader."Cash vs Amount Incld Tax ELA";
        SalesInvHeader."Stop Arrival Time ELA" := SalesHeader."Stop Arrival Time ELA";
        SalesInvHeader."Non-Commissionable ELA" := SalesHeader."Non-Commissionable ELA";
        SalesInvHeader."Approved By ELA" := SalesHeader."Approved By ELA";
        SalesInvHeader."Approval Status ELA" := SalesHeader."Approval Status ELA";
        SalesInvHeader."Order Template Location ELA" := SalesHeader."Order Template Location ELA";
        SalesInvHeader."Entered Amount to Apply ELA" := SalesHeader."Entered Amount to Apply ELA";
        SalesInvHeader."Change Due ELA" := SalesHeader."Change Due ELA";
        SalesInvHeader."Entered Amount to Apply ELA" := SalesHeader."Entered Amount to Apply ELA";
        SalesInvHeader.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterSalesInvLineInsert', '', true, true)]
    procedure OnAfterSalesInvLineInsertUpdate(VAR SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSuppressed: Boolean; VAR SalesHeader: Record "Sales Header"; VAR TempItemChargeAssgntSales: Record "Item Charge Assignment (Sales)")
    begin
        SalesInvLine."Authrzed Price below Cost ELA" := SalesLine."Authrzed Price below Cost ELA";
        SalesInvLine."Authorized Unit Price ELA" := SalesLine."Authorized Unit Price ELA";
        SalesInvLine."To be Authorized ELA" := SalesLine."To be Authorized ELA";
        SalesInvLine."Requested Order Qty. ELA" := SalesLine."Requested Order Qty. ELA";
        SalesInvLine.Modify();
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterCopyFromItem', '', true, true)]
    local procedure OnAfterCopyItem(var SalesLine: Record "Sales Line"; Item: Record Item)
    begin
        SalesLine.Validate("Size Code ELA", Item."Size Code ELA");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterCopyShipToCustomerAddressFieldsFromShipToAddr', '', true, true)]
    local procedure OrderTemplateLocation(var SalesHeader: Record "Sales Header")
    begin
        //SalesHeader.Validate("Order Template Location ELA", SalesHeader."Ship-to Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, 7302, 'OnInitWhseJnlLineCopyFromItemJnlLine', '', true, true)]
    local procedure OnInitWhseJnlLineFromItemJnlLine(var WarehouseJournalLine: Record "Warehouse Journal Line"; ItemJournalLine: Record "Item Journal Line")
    var
        Location: Record Location;

    begin
        IF Location.GET(ItemJournalLine."Location Code") THEN;
        IF Location."Directed Put-away and Pick" THEN BEGIN
            WarehouseJournalLine.Quantity := ROUND(ItemJournalLine."Quantity (Base)" / ItemJournalLine."Qty. per Unit of Measure", 0.00001);
            WarehouseJournalLine."Unit of Measure Code" := ItemJournalLine."Unit of Measure Code";
            WarehouseJournalLine."Qty. per Unit of Measure" := ItemJournalLine."Qty. per Unit of Measure";
        END ELSE BEGIN
            IF UseBaseUOM(ItemJournalLine."Item No.", ItemJournalLine."Variant Code", ItemJournalLine."Location Code") THEN BEGIN
                WarehouseJournalLine.Quantity := ItemJournalLine."Quantity (Base)";
                WarehouseJournalLine."Unit of Measure Code" := GetBaseUOM(ItemJournalLine."Item No.");
                WarehouseJournalLine."Qty. per Unit of Measure" := 1;
            END ELSE BEGIN
                WarehouseJournalLine.Quantity := ItemJournalLine.Quantity;
                WarehouseJournalLine."Unit of Measure Code" := ItemJournalLine."Unit of Measure Code";
                WarehouseJournalLine."Qty. per Unit of Measure" := ItemJournalLine."Qty. per Unit of Measure";
            END;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 7301, 'OnInitWhseEntryCopyFromWhseJnlLine', '', true, true)]
    local procedure OnInitWhseEntryCopyFromWhseJnlLine(VAR WarehouseEntry: Record "Warehouse Entry"; WarehouseJournalLine: Record "Warehouse Journal Line"; OnMovement: Boolean; Sign: Integer)
    var
        Location: Record Location;

    begin
        IF Location.GET(WarehouseJournalLine."Location Code") THEN;
        IF Location."Directed Put-away and Pick" THEN BEGIN
            WarehouseEntry.Quantity := WarehouseJournalLine."Qty. (Absolute)" * Sign;
            WarehouseEntry."Unit of Measure Code" := WarehouseJournalLine."Unit of Measure Code";
            WarehouseEntry."Qty. per Unit of Measure" := WarehouseJournalLine."Qty. per Unit of Measure";
        END ELSE BEGIN

            IF UseBaseUOM(WarehouseJournalLine."Item No.", WarehouseJournalLine."Variant Code", WarehouseJournalLine."Location Code") THEN BEGIN
                WarehouseEntry.Quantity := WarehouseJournalLine."Qty. (Absolute, Base)" * Sign;
                WarehouseEntry."Unit of Measure Code" := GetBaseUOM(WarehouseJournalLine."Item No.");
                WarehouseEntry."Qty. per Unit of Measure" := 1;
            END ELSE BEGIN
                WarehouseEntry.Quantity := WarehouseJournalLine."Qty. (Absolute)" * Sign;
                WarehouseEntry."Unit of Measure Code" := WarehouseJournalLine."Unit of Measure Code";
                WarehouseEntry."Qty. per Unit of Measure" := WarehouseJournalLine."Qty. per Unit of Measure";
            END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5760, 'OnBeforeInsertTempWhseJnlLine', '', true, true)]
    local procedure OnBeforeInsertTempWhseJnlLine(VAR TempWarehouseJournalLine: Record "Warehouse Journal Line" temporary; PostedWhseReceiptLine: Record "Posted Whse. Receipt Line")
    var
        Location: Record Location;

    begin
        IF Location.GET(PostedWhseReceiptLine."Location Code") THEN;

        IF Location."Directed Put-away and Pick" THEN BEGIN
            TempWarehouseJournalLine."Qty. (Absolute)" := PostedWhseReceiptLine.Quantity;
            TempWarehouseJournalLine."Unit of Measure Code" := PostedWhseReceiptLine."Unit of Measure Code";
            TempWarehouseJournalLine."Qty. per Unit of Measure" := PostedWhseReceiptLine."Qty. per Unit of Measure";
        END ELSE BEGIN
            IF UseBaseUOM(PostedWhseReceiptLine."Item No.", PostedWhseReceiptLine."Variant Code", PostedWhseReceiptLine."Location Code") THEN BEGIN
                TempWarehouseJournalLine."Qty. (Absolute)" := PostedWhseReceiptLine."Qty. (Base)";
                TempWarehouseJournalLine."Unit of Measure Code" := GetBaseUOM(PostedWhseReceiptLine."Item No.");
                TempWarehouseJournalLine."Qty. per Unit of Measure" := 1;
            END ELSE BEGIN
                TempWarehouseJournalLine."Qty. (Absolute)" := PostedWhseReceiptLine.Quantity;
                TempWarehouseJournalLine."Unit of Measure Code" := PostedWhseReceiptLine."Unit of Measure Code";
                TempWarehouseJournalLine."Qty. per Unit of Measure" := PostedWhseReceiptLine."Qty. per Unit of Measure";
            END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 7307, 'OnBeforeWhseJnlRegisterLine', '', true, true)]
    procedure OnBeforeWhseJnlRegisterLine(VAR WarehouseJournalLine: Record "Warehouse Journal Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        Location: Record Location;

    begin
        IF Location.GET(WarehouseActivityLine."Location Code") THEN;

        IF Location."Directed Put-away and Pick" THEN BEGIN
            WarehouseJournalLine.Quantity := WarehouseActivityLine."Qty. to Handle";
            WarehouseJournalLine."Unit of Measure Code" := WarehouseActivityLine."Unit of Measure Code";
            WarehouseJournalLine."Qty. per Unit of Measure" := WarehouseActivityLine."Qty. per Unit of Measure";
        END ELSE BEGIN
            IF UseBaseUOM(WarehouseActivityLine."Item No.", WarehouseActivityLine."Variant Code", WarehouseActivityLine."Location Code") THEN BEGIN
                WarehouseJournalLine.Quantity := WarehouseActivityLine."Qty. to Handle (Base)";
                WarehouseJournalLine."Unit of Measure Code" := GetBaseUOM(WarehouseActivityLine."Item No.");
                WarehouseJournalLine."Qty. per Unit of Measure" := 1;
            END ELSE BEGIN
                WarehouseJournalLine.Quantity := WarehouseActivityLine."Qty. to Handle";
                WarehouseJournalLine."Unit of Measure Code" := WarehouseActivityLine."Unit of Measure Code";
                WarehouseJournalLine."Qty. per Unit of Measure" := WarehouseActivityLine."Qty. per Unit of Measure";
            END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 414, 'OnBeforeSalesLineFind', '', true, true)]
    local procedure OnBeforeSalesLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        lrecCustomer: Record Customer;
        ltxtText000: TextConst ENU = 'A %1 is required for %2 %3 on Sales %4 No. %5';
    begin

        IF NOT (SalesHeader."Document Type" IN [SalesHeader."Document Type"::Quote,
                                                    SalesHeader."Document Type"::Order,
                                                    SalesHeader."Document Type"::Invoice]) THEN
            EXIT;

        IF SalesHeader."Ship-to Code" <> '' THEN
            EXIT;

        IF SalesHeader."Sell-to Customer No." <> '' THEN BEGIN
            IF lrecCustomer.GET(SalesHeader."Sell-to Customer No.") THEN BEGIN
                IF lrecCustomer."Req. Ship-To on Sale Doc ELA" THEN BEGIN
                    IF SalesHeader."Ship-to Code" = '' THEN
                        ERROR(ltxtText000, SalesHeader.FIELDCAPTION("Ship-to Code"), SalesHeader.FIELDCAPTION("Sell-to Customer No."),
                              SalesHeader."Sell-to Customer No.", SalesHeader."Document Type", SalesHeader."No.");
                END;
            END;
        END;
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterUpdateWithWarehouseShip', '', true, true)]
    procedure OnAfterUpdateWithWarehouseShip(SalesHeader: Record "Sales Header"; VAR SalesLine: Record "Sales Line")
    var
        Location: Record Location;
    begin
        IF SalesLine.Type = SalesLine.Type::Item THEN
            CASE TRUE OF
                (SalesLine."Document Type" IN [SalesLine."Document Type"::Quote, SalesLine."Document Type"::Order]) AND (SalesLine.Quantity >= 0):
                    IF Location.RequireShipment(SalesLine."Location Code")
                        AND NOT SalesLine.yogIsCashAndCarry(SalesLine)
                    THEN
                        SalesLine.VALIDATE(SalesLine."Qty. to Ship", 0)
                    ELSE
                        SalesLine.VALIDATE(SalesLine."Qty. to Ship", SalesLine."Outstanding Quantity");
                (SalesLine."Document Type" IN [SalesLine."Document Type"::Quote, SalesLine."Document Type"::Order]) AND (SalesLine.Quantity < 0):
                    IF Location.RequireReceive(SalesLine."Location Code") THEN
                        SalesLine.VALIDATE(SalesLine."Qty. to Ship", 0)
                    ELSE
                        SalesLine.VALIDATE(SalesLine."Qty. to Ship", SalesLine."Outstanding Quantity");
                (SalesLine."Document Type" = SalesLine."Document Type"::"Return Order") AND (SalesLine.Quantity >= 0):
                    IF Location.RequireReceive(SalesLine."Location Code") THEN
                        SalesLine.VALIDATE(SalesLine."Return Qty. to Receive", 0)
                    ELSE
                        SalesLine.VALIDATE(SalesLine."Return Qty. to Receive", SalesLine."Outstanding Quantity");
                (SalesLine."Document Type" = SalesLine."Document Type"::"Return Order") AND (SalesLine.Quantity < 0):
                    IF Location.RequireShipment(SalesLine."Location Code") THEN
                        SalesLine.VALIDATE(SalesLine."Return Qty. to Receive", 0)
                    ELSE
                        SalesLine.VALIDATE(SalesLine."Return Qty. to Receive", SalesLine."Outstanding Quantity");
            END;
        SalesLine.SetDefaultQuantity;
    end;

    // [EventSubscriber(ObjectType::Table, 37, 'OnCheckWarehouseOnBeforeShowDialog', '', true, true)]
    // procedure OnCheckWarehouseOnBeforeShowDialog(SalesLine: Record "Sales Line"; Location: Record Location; VAR ShowDialog: Option " ",Message,Error; VAR DialogText: Text[50])
    // begin
    //     if SalesLine.yogIsCashAndCarry(SalesLine) then
    //         ShowDialog := ShowDialog::" ";

    // end;

    local procedure UseBaseUOM(pcodItemNo: Code[20]; pcodVariantCode: Code[10]; pcodLocation: Code[10]): Boolean
    var
        lrecSKU: Record "Stockkeeping Unit";
        Location: Record Location;
    begin
        GetLocation(pcodLocation);
        IF lrecSKU.GET(pcodLocation, pcodItemNo, pcodVariantCode) THEN BEGIN
            EXIT(NOT lrecSKU."Allow Multi-UOM Bin Contnt ELA");
        END ELSE BEGIN
            IF Location.Get(pcodLocation) then
                EXIT(NOT Location."Allow Multi-UOM Bin Contnt ELA");
        END;
    end;

    local procedure GetBaseUOM(ItemNo: Code[20]): Code[10]
    var
        Item: Record Item;
    begin
        GetItem(ItemNo);
        IF Item.Get(ItemNo) then
            EXIT(Item."Base Unit of Measure");
    end;

    LOCAL procedure GetItem(ItemNo: Code[20])
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        IF ItemNo = Item."No." THEN
            EXIT;

        Item.GET(ItemNo);
        IF Item."Item Tracking Code" <> '' THEN
            ItemTrackingCode.GET(Item."Item Tracking Code")
        ELSE
            CLEAR(ItemTrackingCode);
    end;

    LOCAL procedure GetLocation(LocationCode: Code[10])
    var
        Location: Record Location;
    begin
        IF LocationCode = '' THEN
            CLEAR(Location)
        ELSE
            IF Location.Code <> LocationCode THEN
                Location.GET(LocationCode);
    end;
}