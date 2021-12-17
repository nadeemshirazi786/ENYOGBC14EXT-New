pageextension 14229638 "Phys. Inventory Journal ELA" extends "Phys. Inventory Journal"
{
    actions
    {
        addafter(CalculateCountingPeriod)
        {
            action("Calc. Inventory by Loc./Bin/Lot/Serial No.")
            {
                ApplicationArea = All;
                Caption = 'Calc. Inventory by Loc./Bin/Lot/Serial No.';
                trigger OnAction()
                var
                    lrptCalcInvByBinLotSerial: Report "Calc. Inv Loc/Bin/Lot/Ser. ELA";
                begin
                    CLEAR(lrptCalcInvByBinLotSerial);
                    lrptCalcInvByBinLotSerial.SetWhseJnlLine(Rec);
                    lrptCalcInvByBinLotSerial.RUNMODAL;
                    CLEAR(lrptCalcInvByBinLotSerial);
                    CurrPage.UPDATE;
                end;
            }
            action("Calc. Inventory by Loc./Lot/Serial No.")
            {
                ApplicationArea = All;
                Caption = 'Calc. Inventory by Loc./Lot/Serial No.';
                trigger OnAction()
                var
                    lrptCalcInvByLotSerial: Report "Calc. Inv. Loc./Lot/Serial ELA";
                begin
                    CLEAR(lrptCalcInvByLotSerial);
                    lrptCalcInvByLotSerial.SetWhseJnlLine(Rec);
                    lrptCalcInvByLotSerial.RUNMODAL;
                    CLEAR(lrptCalcInvByLotSerial);
                    CurrPage.UPDATE;
                end;
            }
        }
    }

}