codeunit 14229420 "Transfer Custom Fields ELA"
{
    // ENRE1.00 2021-09-08 AJ
    trigger OnRun()
    begin

    end;

    procedure CVLedgEntryTODVLedgEntryBuf(VAR CVLedgEntryBuf: Record "CV Ledger Entry Buffer"; VAR DCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer")
    begin


        //<ENRE1.00>
        DCVLedgEntryBuf."Rebate Code ELA" := CVLedgEntryBuf."Rebate Code ELA";
        DCVLedgEntryBuf."Rebate Source Type ELA" := CVLedgEntryBuf."Rebate Source Type ELA";
        DCVLedgEntryBuf."Rebate Source No. ELA" := CVLedgEntryBuf."Rebate Source No. ELA";
        DCVLedgEntryBuf."Rebate Source Line No. ELA" := CVLedgEntryBuf."Rebate Source Line No. ELA";
        DCVLedgEntryBuf."Rebate Document No. ELA" := CVLedgEntryBuf."Rebate Document No. ELA";
        DCVLedgEntryBuf."Posted Rebate Entry No. ELA" := CVLedgEntryBuf."Posted Rebate Entry No. ELA";
        DCVLedgEntryBuf."Rebate Accrual Vendor No. ELA" := CVLedgEntryBuf."Rebate Accrual Vendor No. ELA";
        DCVLedgEntryBuf."Rebate Vendor No. ELA" := CVLedgEntryBuf."Rebate Vendor No. ELA";
        DCVLedgEntryBuf."Rebate Item No. ELA" := CVLedgEntryBuf."Rebate Item No. ELA";
        DCVLedgEntryBuf."Rebate Category Code ELA" := CVLedgEntryBuf."Rebate Category Code ELA";
        DCVLedgEntryBuf."Vendor Rebate Group ELA" := CVLedgEntryBuf."Vendor Rebate Group ELA";
        DCVLedgEntryBuf."Item Rebate Group ELA" := CVLedgEntryBuf."Item Rebate Group ELA";
        //<ENRE1.00>
    end;

    procedure GenJnlLineTOCVLedgEntryBuf(VAR GenJnlLine: Record "Gen. Journal Line"; VAR CVLedgEntryBuf: Record "CV Ledger Entry Buffer")
    begin


        //<ENRE1.00>
        CVLedgEntryBuf."Rebate Code ELA" := GenJnlLine."Rebate Code ELA";
        CVLedgEntryBuf."Rebate Source Type ELA" := GenJnlLine."Rebate Source Type ELA";
        CVLedgEntryBuf."Rebate Source No. ELA" := GenJnlLine."Rebate Source No. ELA";
        CVLedgEntryBuf."Rebate Source Line No. ELA" := GenJnlLine."Rebate Source Line No. ELA";
        CVLedgEntryBuf."Rebate Document No. ELA" := GenJnlLine."Rebate Document No. ELA";
        CVLedgEntryBuf."Posted Rebate Entry No. ELA" := GenJnlLine."Posted Rebate Entry No. ELA";

        CVLedgEntryBuf."Rbt Accrual Customer No. ELA" := GenJnlLine."Rebate Accrual Customer No.";
        CVLedgEntryBuf."Rebate Customer No. ELA" := GenJnlLine."Rebate Customer No. ELA";
        CVLedgEntryBuf."Rebate Item No. ELA" := GenJnlLine."Rebate Item No. ELA";
        CVLedgEntryBuf."Rebate Category Code ELA" := GenJnlLine."Rebate Category Code ELA";
        CVLedgEntryBuf."Customer Rebate Group ELA" := GenJnlLine."Customer Rebate Group ELA";
        CVLedgEntryBuf."Item Rebate Group ELA" := GenJnlLine."Item Rebate Group ELA";
    end;

    var
        myInt: Integer;
}