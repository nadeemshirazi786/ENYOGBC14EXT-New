codeunit 14228801 "EN Event Sub ELA"
{
    trigger OnRun()
    begin
        
    end;
    [EventSubscriber(ObjectType::Codeunit, 414, 'OnBeforeCheckCustomerCreated', '', true, true)]
    local procedure OnBeforeCheckCustomer(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.ibCheckExtDocNo();
    end;
    [EventSubscriber(ObjectType::Table, 36, 'OnAfterCheckSellToCust', '', true, true)]
    local procedure AfterCheckSellToCust(var SalesHeader: Record "Sales Header";Customer: Record Customer)
    begin
        SalesHeader."Communication Group Code ELA" := Customer."Communication Group Code ELA";
    end;
    var
        myInt: Integer;
}