codeunit 50050 "Event Subscriber"
{
    [EventSubscriber(ObjectType::Table, 7317, 'OnBeforeValidateQtyToReceive', '', true, true)]
    local procedure ValidateQtyToReceive(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var IsHandled: Boolean)
    var
        WhseRcptLine: Record "Warehouse Receipt Line";
    begin
        //  WhseRcptLine.JfOverReceive();
    end;
}