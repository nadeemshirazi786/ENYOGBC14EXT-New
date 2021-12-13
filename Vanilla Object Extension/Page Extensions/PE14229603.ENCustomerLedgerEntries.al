pageextension 14229603 "EN Customer Ledger Entries" extends "Customer Ledger Entries"
{
    procedure GetSelectionFilter(VAR CustLedgEntry: Record "Cust. Ledger Entry")

    begin
        CurrPage.SETSELECTIONFILTER(CustLedgEntry); //ENSP1.00
    end;
}