/// <summary>
/// Codeunit EN Sales Events (ID 14228850).
/// </summary>
/// TEST Merge
codeunit 14228856 "EN Purchase Events"
{


    [EventSubscriber(ObjectType::Report, 5753, 'OnAfterCreateRcptHeader', '', true, true)]
    procedure OnAfterCreateRcptHeader(VAR WarehouseReceiptHeader: Record "Warehouse Receipt Header"; WarehouseRequest: Record "Warehouse Request"; PurchaseLine: Record "Purchase Line")
    var
        lPurchHeader: Record "Purchase Header";
    begin
        IF lPurchHeader.GET(PurchaseLine."Document Type", PurchaseLine."Document No.") then begin
            WarehouseReceiptHeader."Name ELA" := lPurchHeader."Buy-from Vendor Name";
            WarehouseReceiptHeader."Address ELA" := lPurchHeader."Buy-from Address";
            WarehouseReceiptHeader."Address 2 ELA" := lPurchHeader."Buy-from Address 2";
            WarehouseReceiptHeader."City ELA" := lPurchHeader."Buy-from City";
            WarehouseReceiptHeader."County ELA" := lPurchHeader."Buy-from County";
            WarehouseReceiptHeader."Post Code ELA" := lPurchHeader."Buy-from Post Code";
            WarehouseReceiptHeader."Country/Region Code ELA" := lPurchHeader."Buy-from Country/Region Code";
            WarehouseReceiptHeader."Contact ELA" := lPurchHeader."Buy-from Contact";
            WarehouseReceiptHeader.Modify()
        end;


    end;
}