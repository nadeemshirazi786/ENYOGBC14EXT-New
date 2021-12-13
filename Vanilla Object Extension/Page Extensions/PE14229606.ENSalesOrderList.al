pageextension 14229606 "EN Sales Order List" extends "Sales Order List"
{

    procedure GetSelectionFilter(VAR SalesHeader: Record "Sales Header")

    begin
        CurrPage.SETSELECTIONFILTER(SalesHeader); //ENSP1.00
    end;

}