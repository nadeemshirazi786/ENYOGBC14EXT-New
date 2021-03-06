pageextension 14229638 "Phys. Inventory Journal ELA" extends "Phys. Inventory Journal"
{
layout
    {
        addafter("Item No.")
        {
            field("Journal Template Name"; "Journal Template Name")
            {
                ApplicationArea = All;
            }
            field("Journal Batch Name"; "Journal Batch Name")
            {
                ApplicationArea = All;
            }
            field("Line No."; "Line No.")
            {
                ApplicationArea = All;
            }
            field("Lot No."; "Lot No.")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter(CalculateCountingPeriod)
        {
            // action("Calculate Inventory Counting Period")
            // {
            //     ApplicationArea = All;

            //     trigger OnAction()
            //     var
            //         PhysInvtCountMgt: Codeunit "Phys. Invt. Count.-Management";
            //     begin
            //         PhysInvtCountMgt.InitFromItemJnl(Rec);
            //         PhysInvtCountMgt.RUN;
            //         CLEAR(PhysInvtCountMgt);
            //     end;
            // }
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
        // modify(CalculateCountingPeriod)
        // {
        //     ApplicationArea = All;

        // }
    }

}