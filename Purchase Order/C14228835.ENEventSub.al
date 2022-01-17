codeunit 14228835 "Event Subsciber"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, 5760, 'OnInitSourceDocumentHeaderOnBeforePurchHeaderModify', '', true, true)]
    local procedure OnInitSourceDocument(var PurchaseHeader: Record "Purchase Header"; var ModifyHeader: Boolean; var WarehouseReceiptHeader: Record "Warehouse Receipt Header")
    begin

        IF WarehouseReceiptHeader."Shipping Agent Code ELA" <> '' THEN BEGIN
            IF WarehouseReceiptHeader."Shipping Agent Code ELA" <> PurchaseHeader."Shipping Agent Code" THEN BEGIN
                PurchaseHeader.VALIDATE("Shipping Agent Code", WarehouseReceiptHeader."Shipping Agent Code ELA");
                ModifyHeader := TRUE;
            END;
        END;
        IF WarehouseReceiptHeader."Exp. Delivery Appointment Date" <> 0D THEN BEGIN
            IF WarehouseReceiptHeader."Exp. Delivery Appointment Date" <> PurchaseHeader."Exp. Delivery Appointment Date" THEN BEGIN
                PurchaseHeader.VALIDATE("Exp. Delivery Appointment Date", WarehouseReceiptHeader."Exp. Delivery Appointment Date");
                ModifyHeader := TRUE;
            END;
        END;

        IF WarehouseReceiptHeader."Exp. Delivery Appointment Time" <> 0T THEN BEGIN
            IF WarehouseReceiptHeader."Exp. Delivery Appointment Time" <> PurchaseHeader."Exp. Delivery Appointment Time" THEN BEGIN
                PurchaseHeader.VALIDATE("Exp. Delivery Appointment Time", WarehouseReceiptHeader."Exp. Delivery Appointment Time");
                ModifyHeader := TRUE;
            END;
        END;

        IF WarehouseReceiptHeader."Act. Delivery Appointment Date" <> 0D THEN BEGIN
            IF WarehouseReceiptHeader."Act. Delivery Appointment Date" <> PurchaseHeader."Act. Delivery Appointment Date" THEN BEGIN
                PurchaseHeader.VALIDATE("Act. Delivery Appointment Date", WarehouseReceiptHeader."Act. Delivery Appointment Date");
                ModifyHeader := TRUE;
            END;
        END;

        IF WarehouseReceiptHeader."Act. Delivery Appointment Time" <> 0T THEN BEGIN
            IF WarehouseReceiptHeader."Act. Delivery Appointment Time" <> PurchaseHeader."Act. Delivery Appointment Time" THEN BEGIN
                PurchaseHeader.VALIDATE("Act. Delivery Appointment Time", WarehouseReceiptHeader."Act. Delivery Appointment Time");
                ModifyHeader := TRUE;
            END;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5772, 'OnBeforeCreateWhseRequest', '', true, true)]
    local procedure CreateWhseRequest(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; var WhseRqst: Record "Warehouse Request"; WhseType: Option)
    begin
        WhseRqst."Exp. Delivery Appointment Date" := PurchHeader."Exp. Delivery Appointment Date";
        WhseRqst."Exp. Delivery Appointment Time" := PurchHeader."Exp. Delivery Appointment Time";
        WhseRqst."Act. Delivery Appointment Date" := PurchHeader."Act. Delivery Appointment Date";
        WhseRqst."Act. Delivery Appointment Time" := PurchHeader."Act. Delivery Appointment Time";
        WhseRqst."Shipping Agent Code" := PurchHeader."Shipping Agent Code";
    end;

    [EventSubscriber(ObjectType::Report, 5753, 'OnBeforeWhseReceiptHeaderInsert', '', true, true)]
    local procedure WhseReceiptHeaderInsert(var WarehouseReceiptHeader: Record "Warehouse Receipt Header"; WarehouseRequest: Record "Warehouse Request")
    begin

        WarehouseReceiptHeader."Shipping Agent Code ELA" := WarehouseRequest."Shipping Agent Code";
        WarehouseReceiptHeader."Exp. Delivery Appointment Date" := WarehouseRequest."Exp. Delivery Appointment Date";
        WarehouseReceiptHeader."Exp. Delivery Appointment Time" := WarehouseRequest."Exp. Delivery Appointment Time";
        WarehouseReceiptHeader."Act. Delivery Appointment Date" := WarehouseRequest."Act. Delivery Appointment Date";
        WarehouseReceiptHeader."Act. Delivery Appointment Time" := WarehouseRequest."Act. Delivery Appointment Time";
    end;
}