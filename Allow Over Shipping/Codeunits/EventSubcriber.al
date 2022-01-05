codeunit 50050 "Event Subscriber"
{
    [EventSubscriber(ObjectType::Table, 7317, 'OnBeforeValidateQtyToReceive', '', true, true)]
    local procedure ValidateQtyToReceive(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var IsHandled: Boolean)
    begin
        WarehouseReceiptLine.JfOverReceive();
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnValidateQtyToReceiveOnAfterCheck', '', true, true)]
    local procedure QtyToReceiveOnAfterCheck(CallingFieldNo: Integer; var PurchaseLine: Record "Purchase Line")
    begin
        PurchaseLine.JfOverReceive();
    end;

    [EventSubscriber(ObjectType::Codeunit, 5750, 'OnPurchLine2ReceiptLineOnAfterInitNewLine', '', true, true)]
    local procedure PurchLine2ReceiptLineOnAfterInitNewLine(PurchaseLine: Record "Purchase Line"; var WhseReceiptLine: Record "Warehouse Receipt Line"; WhseReceiptHeader: Record "Warehouse Receipt Header")
    var
        grecItem: Record Item;
    begin
        grecItem.GET(WhseReceiptLine."Item No.");
        WhseReceiptLine."Receiving UOM ELA" := grecItem."Receiving Unit of Measure ELA";
    end;

    [EventSubscriber(ObjectType::Codeunit, 5777, 'OnBeforeVerifyFieldNotChanged', '', true, true)]
    local procedure VerifyFieldNotChanged(FieldNumber: Integer; NewRecRef: RecordRef; OldRecRef: RecordRef; var IsHandled: Boolean)
    var
        MyFieldRef: FieldRef;
        AllowOverReceiving: Boolean;
    begin
        MyFieldRef := NewRecRef.Field(51011);
        AllowOverReceiving := MyFieldRef.Value;
        if AllowOverReceiving then
            IsHandled := true;
    end;

}