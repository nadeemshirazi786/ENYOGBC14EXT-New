codeunit 14228831 "User-Def Events ELA"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, 5763, 'OnInitSourceDocumentHeaderOnBeforeSalesHeaderModify', '', true, true)]
    local procedure OnInitSourceDocumentHeader(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var SalesHeader: Record "Sales Header"; var ModifyHeader: Boolean)
    begin
        IF (WarehouseShipmentHeader."Seal No. ELA" <> '') AND
           (WarehouseShipmentHeader."Seal No. ELA" <> SalesHeader."Seal No. ELA")
        THEN BEGIN
            SalesHeader."Seal No. ELA" := WarehouseShipmentHeader."Seal No. ELA";
            SalesHeader.Modify(true);
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5771, 'OnBeforeCreateWhseRequest', '', true, true)]
    local procedure OnBeforeCreateWhseRequest(var SalesHeader: Record "Sales Header"; var WhseRqst: Record "Warehouse Request")
    begin
        WhseRqst."Seal No. ELA" := SalesHeader."Seal No. ELA";
    end;

    [EventSubscriber(ObjectType::Report, 5753, 'OnAfterCreateShptHeader', '', true, true)]
    local procedure AfterCreateShptHeader(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; WarehouseRequest: Record "Warehouse Request")
    begin
        WarehouseShipmentHeader."Seal No. ELA" := WarehouseRequest."Seal No. ELA";
        WarehouseShipmentHeader."Pallet Code ELA" := WarehouseRequest."Pallet Code ELA";
    end;
}