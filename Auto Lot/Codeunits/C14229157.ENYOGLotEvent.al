/// <summary>
/// Codeunit EN LT YOGLot Event ELA (ID 14229157).
/// </summary>
codeunit 14229157 "EN LT YOGLot Event ELA"
{
    EventSubscriberInstance = StaticAutomatic;
    [EventSubscriber(ObjectType::Table, 37, 'OnValidateLocationCodeOnBeforeSetShipmentDate', '', true, true)]
    local procedure OnValidateLocationCode(SalesLine: Record "Sales Line")
    begin
        AutoLotNo(false);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnCopyFromItemOnAfterCheck', '', true, true)]
    local procedure OnCopyFromItem(Item: Record Item)
    begin
        AutoLotNo(false);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeVerifyReservedQty', '', true, true)]
    local procedure VerifyReservedQty(SalesLine: Record "Sales Line")
    begin
        UpdateLotTracking(false, 0);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnValidateQtyToShipAfterInitQty', '', true, true)]
    local procedure OnValidateQtyToShip(SalesLine: Record "Sales Line")
    begin
        UpdateLotTracking(false, 0);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeVerifyReservedQty', '', true, true)]
    local procedure OnBeforeVerifyReserved(SalesLine: Record "Sales Line")
    begin
        UpdateLotTracking(true, 0);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnValidateQtyToReturnAfterInitQty', '', true, true)]
    local procedure OnValidateQtyToReturn(SalesLine: Record "Sales Line")
    begin
        UpdateLotTracking(false, 0);
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeOpenItemTrackingLines', '', true, true)]
    local procedure OnBeforeOpenItemTracking(PurchaseLine: Record "Purchase Line")
    begin
        PurchaseLine.GetLotNo();
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterAssignItemValues', '', true, true)]
    local procedure OnCopyItem(var PurchLine: Record "Purchase Line")
    begin
        PurchLine.AutoLotNo(false);
    end;
/// <summary>
/// AutoLotNo.
/// </summary>
/// <param name="Posting">Boolean.</param>
    procedure AutoLotNo(Posting: Boolean)
    var
        SalesLine: Record "Sales Line";
        xSalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        Rec: Record "Sales Line";
        xRec: Record "Sales Line";
    begin

        IF NOT (SalesLine."Document Type" IN [SalesLine."Document Type"::"Return Order", SalesLine."Document Type"::"Credit Memo"]) THEN
            EXIT;
        IF (SalesLine.Type <> SalesLine.Type::Item) OR (SalesLine."No." = '') THEN
            EXIT;

        IF Posting AND (SalesLine."Return Qty. to Receive" = 0) THEN
            EXIT;


        SalesLine := Rec;
        xSalesLine := xRec;
        IF Posting THEN BEGIN
            SalesLine."Shipment Date" := SalesHeader."Posting Date";

            xSalesLine := SalesLine;
        END ELSE BEGIN
            SalesLine."Shipment Date" := 0D;
            xSalesLine."Shipment Date" := 0D;
        END;
    end;

    local procedure UpdateLotTracking(ForceUpdate: Boolean; ApplyFromEntryNo: Integer)
    var
        Item: Record Item;
        QtyBase: Decimal;
        QtyToHandle: Decimal;
        QtyToHandleAlt: Decimal;
        QtyToInvoice: Decimal;
        CurrFieldNo: Integer;
        UseWhseLineQty: Boolean;
        WhseLineQtyBase: Decimal;
        WhseLineQtyToInvBase: Decimal;
        SalesLine: Record "Sales Line";
        Location: Record Location;
        xRec: Record "Sales Line";

    begin
        IF ((CurrFieldNo = 0) AND (NOT ForceUpdate)) OR (SalesLine.Type <> SalesLine.Type::Item) THEN // P8000071A
            EXIT;

        IF SalesLine."Line No." = 0 THEN
            EXIT;

        IF UseWhseLineQty THEN BEGIN
            QtyBase := SalesLine."Quantity (Base)";
            QtyToHandle := WhseLineQtyBase;

            QtyToInvoice := WhseLineQtyToInvBase;
        END ELSE BEGIN

            GetLocation(SalesLine."Location Code");
            CASE SalesLine."Document Type" OF
                SalesLine."Document Type"::Order, SalesLine."Document Type"::Invoice:
                    IF Location.LocationType = 1 THEN BEGIN
                        QtyToHandle := SalesLine."Qty. to Ship (Base)";

                        QtyToInvoice := SalesLine."Qty. to Invoice (Base)";

                    END ELSE BEGIN

                        QtyToHandle := SalesLine."Qty. to Ship (Base)";

                        QtyToInvoice := SalesLine."Qty. to Invoice (Base)";


                    END;
                SalesLine."Document Type"::"Credit Memo", SalesLine."Document Type"::"Return Order":
                    IF Location.LocationType = 1 THEN BEGIN
                        QtyToHandle := SalesLine."Return Qty. to Receive (Base)";

                        QtyToInvoice := SalesLine."Qty. to Invoice (Base)";

                    END ELSE BEGIN

                        QtyToHandle := SalesLine."Return Qty. to Receive (Base)";

                        QtyToInvoice := SalesLine."Qty. to Invoice (Base)";


                    END;
            END;
            QtyBase := SalesLine."Quantity (Base)";
        END;

        IF (xRec."Document Type" = 0) AND (xRec."Document No." = '') AND (xRec."Line No." = 0) THEN // P8000181A
            xRec."Lot No. ELA" := SalesLine."Lot No. ELA";                                                              // P8000181A
                                                                                                                /////EasyLotTracking.ReplaceTracking(xRec."Lot No.","Lot No.",
                                                                                                                /////////// QtyBase,QtyToHandle,QtyToInvoice); // P8000629A, P8004505
    end;
/// <summary>
/// GetLocation.
/// </summary>
/// <param name="LocationCode">Code[20].</param>
    procedure GetLocation(LocationCode: Code[20])
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

