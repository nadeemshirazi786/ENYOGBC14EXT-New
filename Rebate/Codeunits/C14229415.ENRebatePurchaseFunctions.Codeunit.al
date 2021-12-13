codeunit 14229415 "Rebate Purchase Functions ELA"
{
    // ENRE1.00 2021-08-26 AJ


    trigger OnRun()
    begin
    end;


    procedure rdCalculateRebates(var PurchaseHeader: Record "Purchase Header")
    var
        lPurchasesPayablesSetup: Record "Purchases & Payables Setup";
        lRecordRef: RecordRef;
        lPurchaseRebateManagement: Codeunit "Purchase Rebate Management ELA";
    begin
        //<ENRE1.00>
        lPurchasesPayablesSetup.Get;

        if lPurchasesPayablesSetup."Calculate Rbt on Release ELA" then begin
            lRecordRef.GetTable(PurchaseHeader);
            lRecordRef.SetView(PurchaseHeader.GetView);
            lPurchaseRebateManagement.CalcPurchDocRebate(lRecordRef, false, true);
        end;
        //</ENRE1.00>
    end;
}

