codeunit 14229411 "Rebate Jnl.-Post ELA"
{

    // ENRE1.00 2021-09-08 AJ
    TableNo = "Rebate Journal Line ELA";

    trigger OnRun()
    begin
        RebateJnlLine.Copy(Rec);
        Code;
        Rec.Copy(RebateJnlLine);
    end;

    var
        RebateJnlLine: Record "Rebate Journal Line ELA";
        RebateJnlPostBatch: Codeunit "Rebate Jnl.-Post Batch ELA";
        TempJnlBatchName: Code[10];
        AXText001: Label 'Do you want to post the journal lines?';
        AXText002: Label 'There is nothing to post.';
        AXText003: Label 'The journal lines were successfully posted. ';
        AXText004: Label 'You are now in the %1 journal.';

    local procedure "Code"()
    begin


        if not Confirm(AXText001) then
            exit;

        TempJnlBatchName := RebateJnlLine."Rebate Batch Name";
        RebateJnlPostBatch.Run(RebateJnlLine);

        if RebateJnlLine."Line No." = 0 then
            Message(AXText002)
        else
            if TempJnlBatchName = RebateJnlLine."Rebate Batch Name" then
                Message(AXText003)
            else
                Message(AXText003 + AXText004, RebateJnlLine."Rebate Batch Name");

        if not RebateJnlLine.Find('=><') or (TempJnlBatchName <> RebateJnlLine."Rebate Batch Name") then begin
            RebateJnlLine.Reset;
            RebateJnlLine.FilterGroup(2);
            RebateJnlLine.SetRange("Rebate Batch Name", RebateJnlLine."Rebate Batch Name");
            RebateJnlLine.FilterGroup(0);
            RebateJnlLine."Line No." := 1;
        end;

    end;
}

