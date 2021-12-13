codeunit 14229419 "Table Events ELA"
{
    // ENRE1.00 2021-09-08 AJ
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterAssignItemValues', '', false, false)]
    local procedure OnAfterAssignItemValues(VAR SalesLine: Record "Sales Line"; Item: Record Item)

    begin
        SalesLine.CopyItemNoToRefItemNo;
    end;

    var
        myInt: Integer;
}