codeunit 14229412 "Rebate Jnl.-Post Batch ELA"
{


    // ENRE1.00 2021-09-08 AJ
    Permissions = TableData "Rebate Batch ELA" = imd;
    TableNo = "Rebate Journal Line ELA";

    trigger OnRun()
    begin
        RebateJnlLine.Copy(Rec);
        Code;
        Rec := RebateJnlLine;
    end;

    var
        RebateJnlLine: Record "Rebate Journal Line ELA";
        RebateJnlBatch: Record "Rebate Batch ELA";
        RebateLedgEntry: Record "Rebate Ledger Entry ELA";
        RebateJnlLine2: Record "Rebate Journal Line ELA";
        RebateJnlLine3: Record "Rebate Journal Line ELA";
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemReg: Record "Item Register";
        AccountingPeriod: Record "Accounting Period";
        NoSeries: Record "No. Series" temporary;
        RebateJnlCheckLine: Codeunit "Rebate Jnl.-Check Line ELA";
        RebateJnlPostLine: Codeunit "Rebate Jnl.-Post Line ELA";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesMgt2: array[10] of Codeunit NoSeriesManagement;
        Window: Dialog;
        RebateRegNo: Integer;
        StartLineNo: Integer;
        Day: Integer;
        Week: Integer;
        Month: Integer;
        MonthText: Text[30];
        NoOfRecords: Integer;
        LineCount: Integer;
        LastDocNo: Code[20];
        LastDocNo2: Code[20];
        LastPostedDocNo: Code[20];
        NoOfPostingNoSeries: Integer;
        PostingNoSeriesNo: Integer;
        RebateReg: Record "Rebate Register ELA";
        AXText001: Label 'cannot exceed %1 characters';
        AXText002: Label 'A maximum of %1 posting number series can be used in each journal.';

    local procedure "Code"()
    var
        lrptCreateAndPostRebate: Report "Post Rebates ELA";
        lrecRebateLedgerEntry: Record "Rebate Ledger Entry ELA";
    begin

        RebateJnlLine.SetRange(RebateJnlLine."Rebate Batch Name", RebateJnlLine."Rebate Batch Name");

        if RebateJnlLine.RecordLevelLocking then
            RebateJnlLine.LockTable;

        RebateJnlBatch.Get(RebateJnlLine."Rebate Batch Name");
        if StrLen(IncStr(RebateJnlBatch.Name)) > MaxStrLen(RebateJnlBatch.Name) then
            RebateJnlBatch.FieldError(
              Name,
              StrSubstNo(
                AXText001,
                MaxStrLen(RebateJnlBatch.Name)));


        if not RebateJnlLine.Find('=><') then begin
            RebateJnlLine."Line No." := 0;
            Commit;
            exit;
        end;

        Window.Open(
            'Journal Batch Name    #1##########\\' +
            'Checking lines        #2######\' +
            'Posting lines         #3###### @4@@@@@@@@@@@@@');

        Window.Update(1, RebateJnlLine."Rebate Batch Name");

        // Check Lines
        LineCount := 0;
        StartLineNo := RebateJnlLine."Line No.";
        repeat
            LineCount := LineCount + 1;
            Window.Update(2, LineCount);
            RebateJnlCheckLine.Run(RebateJnlLine);
            if RebateJnlLine.Next = 0 then
                RebateJnlLine.Find('-');
        until RebateJnlLine."Line No." = StartLineNo;
        NoOfRecords := LineCount;

        // Find next register no.
        RebateLedgEntry.LockTable;
        if RebateJnlLine.RecordLevelLocking then
            if RebateLedgEntry.Find('+') then;
        RebateReg.LockTable;
        if RebateReg.Find('+') then
            RebateRegNo := RebateReg."No." + 1
        else
            RebateRegNo := 1;

        // Post lines
        LineCount := 0;
        LastDocNo := '';
        LastDocNo2 := '';
        LastPostedDocNo := '';
        RebateJnlLine.Find('-');
        repeat
            LineCount := LineCount + 1;
            Window.Update(3, LineCount);
            Window.Update(4, Round(LineCount / NoOfRecords * 10000, 1));
            if not RebateJnlLine.EmptyLine and
               (RebateJnlBatch."No. Series" <> '') and
               (RebateJnlLine."Document No." <> LastDocNo2)
            then
                RebateJnlLine.TestField(RebateJnlLine."Document No.", NoSeriesMgt.GetNextNo(RebateJnlBatch."No. Series", RebateJnlLine."Posting Date", false));
            LastDocNo2 := RebateJnlLine."Document No.";
            if RebateJnlLine."Posting No. Series" = '' then
                RebateJnlLine."Posting No. Series" := RebateJnlBatch."No. Series"
            else
                if not RebateJnlLine.EmptyLine then
                    if RebateJnlLine."Document No." = LastDocNo then
                        RebateJnlLine."Document No." := LastPostedDocNo
                    else begin
                        if not NoSeries.Get(RebateJnlLine."Posting No. Series") then begin
                            NoOfPostingNoSeries := NoOfPostingNoSeries + 1;
                            if NoOfPostingNoSeries > ArrayLen(NoSeriesMgt2) then
                                Error(AXText002, ArrayLen(NoSeriesMgt2));
                            NoSeries.Code := RebateJnlLine."Posting No. Series";
                            NoSeries.Description := Format(NoOfPostingNoSeries);
                            NoSeries.Insert;
                        end;
                        LastDocNo := RebateJnlLine."Document No.";
                        Evaluate(PostingNoSeriesNo, NoSeries.Description);
                        RebateJnlLine."Document No." := NoSeriesMgt2[PostingNoSeriesNo].GetNextNo(RebateJnlLine."Posting No. Series", RebateJnlLine."Posting Date", false);
                        LastPostedDocNo := RebateJnlLine."Document No.";
                    end;
            RebateJnlPostLine.Run(RebateJnlLine);
        until RebateJnlLine.Next = 0;

        //Copy register no. and current journal batch name to rebate journal
        if not RebateReg.Find('+') or (RebateReg."No." <> RebateRegNo) then
            RebateRegNo := 0;

        RebateJnlLine.Init;
        RebateJnlLine."Line No." := RebateRegNo;

        // Update/delete lines
        if RebateRegNo <> 0 then begin
            //-- Post Rebate Entries to Customer Ledger Entry
            Clear(lrptCreateAndPostRebate);
            Clear(lrecRebateLedgerEntry);

            lrecRebateLedgerEntry.SetRange("Entry No.", RebateReg."From Entry No.", RebateReg."To Entry No.");

            lrptCreateAndPostRebate.SetEntryFilter(lrecRebateLedgerEntry);

            lrptCreateAndPostRebate.UseRequestPage(false);
            lrptCreateAndPostRebate.RunModal;

            if not RebateJnlLine.RecordLevelLocking then
                RebateJnlLine.LockTable(true, true);
            RebateJnlLine2.CopyFilters(RebateJnlLine);
            RebateJnlLine2.SetFilter("Rebate Code", '<>%1', '');
            if RebateJnlLine2.Find('+') then; // Remember the last line
            RebateJnlLine.DeleteAll;

            RebateJnlLine3.SetRange("Rebate Batch Name", RebateJnlLine."Rebate Batch Name");
            if not RebateJnlLine3.Find('+') then
                if IncStr(RebateJnlLine."Rebate Batch Name") <> '' then begin
                    RebateJnlBatch.Delete;
                    RebateJnlBatch.Name := IncStr(RebateJnlLine."Rebate Batch Name");
                    if RebateJnlBatch.Insert then;
                    RebateJnlLine."Rebate Batch Name" := RebateJnlBatch.Name;
                end;

            RebateJnlLine3.SetRange("Rebate Batch Name", RebateJnlLine."Rebate Batch Name");

            if (RebateJnlBatch."No. Series" <> '') and not RebateJnlLine3.Find('+') then begin
                RebateJnlLine3.Init;
                RebateJnlLine3."Rebate Batch Name" := RebateJnlLine."Rebate Batch Name";
                RebateJnlLine3."Line No." := 10000;
                RebateJnlLine3.Insert;
                RebateJnlLine3.SetUpNewLine(RebateJnlLine2);
                RebateJnlLine3.Modify;
            end;
        end;
        if RebateJnlBatch."No. Series" <> '' then
            NoSeriesMgt.SaveNoSeries;
        if NoSeries.Find('-') then
            repeat
                Evaluate(PostingNoSeriesNo, NoSeries.Description);
                NoSeriesMgt2[PostingNoSeriesNo].SaveNoSeries;
            until NoSeries.Next = 0;
        Commit;

    end;
}

