report 14229402 "Cancel Purchase Rebate ELA"
{

    // ENRE1.00 2021-08-26 AJ
    //    - New Report
    // 
    // 
    //    - add support for Purchase Rebate Customers / Cancelled Purch. Rebate Custs.
    //   - cancelling rebates now adjusts out Posted Sales Profit Modifier entries
    //     - fix: in the rebate ledger, cancelling rebates was not accounting for adjustments (after the first entry)
    Caption = 'Cancel Purchase Rebate';
    ApplicationArea = All;
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Purchase Rebate Header"; "Purchase Rebate Header ELA")
        {
            DataItemTableView = SORTING(Code);
            RequestFilterFields = "Code";

            trigger OnAfterGetRecord()
            begin
                if GuiAllowed then
                    gdlgWindow.Update(1, Code);
                TestField(Blocked, false);
                DeleteOpenRebateEntries;
                ReverseRebateLedgerEntries;
                PostReversal;
                MoveRebateToCancelled;
            end;

            trigger OnPostDataItem()
            begin
                if GuiAllowed then
                    gdlgWindow.Close;
            end;

            trigger OnPreDataItem()
            var
                ldteFirstAvailDate: Date;
            begin
                if Count > 1 then begin
                    if not Confirm(gText000, false) then
                        Error(gText001);
                end else begin
                    FindSet;
                    if not Confirm(gText002, false, "Purchase Rebate Header".Code) then
                        Error(gText001);
                end;
                if gdtePostingDate = 0D then
                    Error(gText003);
                if UserId <> '' then
                    if grecUserSetup.Get(UserId) then begin
                        gdteAllowPostingFrom := grecUserSetup."Allow Posting From";
                        gdteAllowPostingTo := grecUserSetup."Allow Posting To";
                    end;
                if (gdteAllowPostingFrom = 0D) and (gdteAllowPostingTo = 0D) then begin
                    grecGLSetup.Get;
                    gdteAllowPostingFrom := grecGLSetup."Allow Posting From";
                    gdteAllowPostingTo := grecGLSetup."Allow Posting To";
                end;
                if gdteAllowPostingTo = 0D then
                    gdteAllowPostingTo := 99991231D;
                if (gdteAllowPostingFrom > gdtePostingDate) or (gdteAllowPostingTo < gdtePostingDate) then begin
                    Error(gText004, gdtePostingDate, gdteAllowPostingFrom, gdteAllowPostingTo);
                end;
                if GuiAllowed then
                    gdlgWindow.Open(gText005 +
                                    gText006 +
                                    gText007 +
                                    gText008);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(gdtePostingDate; gdtePostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            gdtePostingDate := WorkDate;
        end;
    }

    labels
    {
    }

    var
        gText000: Label 'You are cancelling multiple rebates. Are you sure?';
        gText001: Label 'Process cancelled.';
        gText002: Label 'Are you sure you want to cancel rebate %1?';
        grecGLSetup: Record "General Ledger Setup";
        gdtePostingDate: Date;
        gcodReasonCode: Code[10];
        gText003: Label 'You must specify a Posting Date.';
        gText004: Label 'You cannot post to %1. The dates you can post to is %2 to %3.';
        gText005: Label 'Processing...\\';
        gText006: Label 'Rebate                          #1########\';
        gText007: Label 'Deleting Open Rebate Entries    @2@@@@@@@@\';
        gText008: Label 'Reversing Posted Rebate Entries @3@@@@@@@@';
        gdlgWindow: Dialog;
        gdteAllowPostingFrom: Date;
        gdteAllowPostingTo: Date;
        grecUserSetup: Record "User Setup";


    procedure MoveRebateToCancelled()
    var
        lrecPurchRebate: Record "Purchase Rebate Header ELA";
        lrecPurchRebateDetail: Record "Purchase Rebate Line ELA";
        lrecPurchRebateComment: Record "Purchase Rbt Comment Line ELA";
        lrecCancelRebate: Record "Cancel Purch. Rbt Header ELA";
        lrecCancelRebateDetail: Record "Cancel Purch. Rbt Line ELA";
        lrecCancelRebateComment: Record "Cancel Purch Rbt Comm Line ELA";
        lrecFromPurchRebateCust: Record "Purchase Rebate Customer ELA";
        lrecCancelledPurchRebateCust: Record "Cancelled Purch. Rbt Cust. ELA";
    begin
        lrecPurchRebate.Get("Purchase Rebate Header".Code);
        lrecCancelRebate.Init;
        lrecCancelRebate.TransferFields(lrecPurchRebate);
        lrecCancelRebate.Insert(true);

        //<ENRE1.00>
        if (
          (lrecPurchRebate."Rebate Type" = lrecPurchRebate."Rebate Type"::"Sales-Based")
        ) then begin
            lrecFromPurchRebateCust.Reset;
            lrecFromPurchRebateCust.SetRange("Purchase Rebate Code", lrecPurchRebate.Code);
            if (
              (not lrecFromPurchRebateCust.IsEmpty)
            ) then begin

                lrecFromPurchRebateCust.FindSet(true);
                repeat

                    lrecCancelledPurchRebateCust.Init;
                    lrecCancelledPurchRebateCust.TransferFields(lrecFromPurchRebateCust);
                    lrecCancelledPurchRebateCust.Insert(true);

                until lrecFromPurchRebateCust.Next = 0;
                lrecFromPurchRebateCust.DeleteAll;
            end;
        end;
        //</ENRE1.00>

        lrecPurchRebate.Delete;
        lrecPurchRebateDetail.SetRange("Purchase Rebate Code", "Purchase Rebate Header".Code);
        lrecPurchRebateDetail.SetRange("Line No.");
        if lrecPurchRebateDetail.FindSet(true) then begin
            repeat
                lrecCancelRebateDetail.Init;
                lrecCancelRebateDetail.TransferFields(lrecPurchRebateDetail);
                lrecCancelRebateDetail.Insert(true);
            until lrecPurchRebateDetail.Next = 0;
            lrecPurchRebateDetail.DeleteAll;
        end;
        lrecPurchRebateComment.SetRange("Purchase Rebate Code", "Purchase Rebate Header".Code);
        lrecPurchRebateComment.SetRange("Line No.");
        if lrecPurchRebateComment.FindSet(true) then begin
            repeat
                lrecCancelRebateComment.Init;
                lrecCancelRebateComment.TransferFields(lrecPurchRebateComment);
                lrecCancelRebateComment.Insert(true);
            until lrecPurchRebateComment.Next = 0;
            lrecPurchRebateComment.DeleteAll;
        end;
    end;


    procedure DeleteOpenRebateEntries()
    var
        lrecRebateEntry: Record "Rebate Entry ELA";
        lrecRebateEntry2: Record "Rebate Entry ELA";
        lintCounter: Integer;
        lintCount: Integer;
    begin
        lrecRebateEntry.SetCurrentKey("Rebate Code");
        lrecRebateEntry.SetRange("Rebate Code", "Purchase Rebate Header".Code);
        if lrecRebateEntry.Find('-') then begin
            lintCount := lrecRebateEntry.Count;
            lintCounter := 0;
            repeat
                lintCounter += 1;
                if GuiAllowed then
                    gdlgWindow.Update(2, Round(lintCounter / lintCount) * 10000);
                lrecRebateEntry2.Get(lrecRebateEntry."Entry No.");
                lrecRebateEntry2.Delete(true);
            until lrecRebateEntry.Next = 0;
        end;
    end;


    procedure ReverseRebateLedgerEntries()
    var
        lrecPurchRebate: Record "Purchase Rebate Header ELA";
        lrecRebateLedgEntry: Record "Rebate Ledger Entry ELA";
        lrecRebateLedgEntryINS: Record "Rebate Ledger Entry ELA";
        lcodCurrSourceNo: Code[20];
        lintCurrSourceLineNo: Integer;
        lintEntryNo: Integer;
        lintCounter: Integer;
        lintCount: Integer;
        lcodCurrItemNo: Code[20];
        lrecPostedSalesProfitModifierSummary: Record "Post. Sales Prof. Modifier ELA";
        lrecPostedSalesProfitModifierToInsert: Record "Post. Sales Prof. Modifier ELA";
        lrecPostedSalesProfitModifier: Record "Post. Sales Prof. Modifier ELA";
        lintPostedSalesProfitModifierEntryNo: Integer;
    begin
        lrecPurchRebate.Get("Purchase Rebate Header".Code);
        lrecRebateLedgEntry.SetCurrentKey("Functional Area", "Source Type", "Source No.", "Source Line No.", "Rebate Type", "Rebate Code");
        lrecRebateLedgEntry.SetRange("Functional Area");
        lrecRebateLedgEntry.SetRange("Source Type");
        lrecRebateLedgEntry.SetRange("Source No.");
        lrecRebateLedgEntry.SetRange("Source Line No.");
        lrecRebateLedgEntry.SetRange("Rebate Type");
        lrecRebateLedgEntry.SetRange("Rebate Code", lrecPurchRebate.Code);
        if lrecRebateLedgEntry.FindSet(true) then begin
            lcodCurrSourceNo := '';
            lintCurrSourceLineNo := 0;
            lcodCurrItemNo := '';
            lrecRebateLedgEntryINS.Reset;
            lrecRebateLedgEntryINS.LockTable;
            if lrecRebateLedgEntryINS.FindLast then
                lintEntryNo := lrecRebateLedgEntryINS."Entry No." + 1
            else
                lintEntryNo := 1;
            lrecPostedSalesProfitModifier.Reset;
            if (
              (lrecPostedSalesProfitModifier.FindLast)
            ) then begin
                lintPostedSalesProfitModifierEntryNo := lrecPostedSalesProfitModifier."Entry No.";
            end else begin
                lintPostedSalesProfitModifierEntryNo := 0;
            end;
            lintCount := lrecRebateLedgEntry.Count;
            lintCounter := 0;
            repeat
                lintCounter += 1;
                if GuiAllowed then
                    gdlgWindow.Update(3, Round(lintCounter / lintCount) * 10000);

                if (lcodCurrSourceNo <> lrecRebateLedgEntry."Source No.") or
                   (lintCurrSourceLineNo <> lrecRebateLedgEntry."Source Line No.") or
                   (lcodCurrItemNo <> lrecRebateLedgEntry."Item No.") then begin
                    lcodCurrSourceNo := lrecRebateLedgEntry."Source No.";
                    lintCurrSourceLineNo := lrecRebateLedgEntry."Source Line No.";
                    lcodCurrItemNo := lrecRebateLedgEntry."Item No.";
                    lrecPurchRebate.SetRange("Functional Area Filter", lrecRebateLedgEntry."Functional Area");
                    lrecPurchRebate.SetRange("Source Type Filter", lrecRebateLedgEntry."Source Type");
                    lrecPurchRebate.SetRange("Source No. Filter", lrecRebateLedgEntry."Source No.");
                    lrecPurchRebate.SetRange("Source Line No. Filter", lrecRebateLedgEntry."Source Line No.");
                    lrecPurchRebate.CalcFields("Rebate Ledger Amount (LCY)", "Rebate Ledger Amount (RBT)", "Rebate Ledger Amount (DOC)");
                    if lrecPurchRebate."Rebate Ledger Amount (LCY)" <> 0 then begin
                        lrecRebateLedgEntryINS.Init;
                        lrecRebateLedgEntryINS."Entry No." := lintEntryNo;
                        lrecRebateLedgEntryINS.TransferFields(lrecRebateLedgEntry, false);
                        lrecRebateLedgEntryINS."Posted To G/L" := false;
                        lrecRebateLedgEntryINS.Adjustment := false;
                        lrecRebateLedgEntryINS."Rebate Document No." := '';
                        lrecRebateLedgEntryINS."Date Created" := 0D;
                        lrecRebateLedgEntryINS."Paid to Customer" := false;
                        lrecRebateLedgEntryINS."Rebate Batch Name" := '';
                        lrecRebateLedgEntryINS."Posting Date" := gdtePostingDate;
                        lrecRebateLedgEntryINS."Reason Code" := gcodReasonCode;
                        lrecRebateLedgEntryINS."Rebate Cancellation Entry" := true;
                        //<ENRE1.00>
                        // this was causing only "this" entry to be reversed, and ignoring later adjustment amounts
                        // - deleted offending code
                        lrecRebateLedgEntryINS."Amount (LCY)" := -lrecPurchRebate."Rebate Ledger Amount (LCY)";
                        lrecRebateLedgEntryINS."Amount (RBT)" := -lrecPurchRebate."Rebate Ledger Amount (RBT)";
                        lrecRebateLedgEntryINS."Amount (DOC)" := -lrecPurchRebate."Rebate Ledger Amount (DOC)";
                        //</ENRE1.00>
                        lrecRebateLedgEntryINS.UpdateRebateRates;
                        lrecRebateLedgEntryINS.Insert(true);
                        lintEntryNo += 1;

                        //<ENRE1.00>
                        lrecPostedSalesProfitModifierSummary.SetRange("Document Type", lrecPostedSalesProfitModifierSummary."Document Type"::Invoice);

                        lrecPostedSalesProfitModifierSummary.SetRange("Document No.", lrecRebateLedgEntry."Source No.");
                        lrecPostedSalesProfitModifierSummary.SetRange("Document Line No.", lrecRebateLedgEntry."Source Line No.");

                        lrecPostedSalesProfitModifierSummary.SetRange("Source Type", lrecPostedSalesProfitModifierSummary."Source Type"::"Purchase Rebate");
                        lrecPostedSalesProfitModifierSummary.SetRange("Source No.", lrecRebateLedgEntry."Rebate Code");

                        lrecPostedSalesProfitModifierSummary.CalcSums("Amount (LCY)", Amount);

                        if lrecPostedSalesProfitModifierSummary."Amount (LCY)" <> 0 then begin

                            lrecPostedSalesProfitModifierToInsert.Init;

                            lrecPostedSalesProfitModifier.Copy(lrecPostedSalesProfitModifierSummary);
                            lrecPostedSalesProfitModifier.FindLast;

                            lrecPostedSalesProfitModifierToInsert.TransferFields(lrecPostedSalesProfitModifier);
                            lintPostedSalesProfitModifierEntryNo := lintPostedSalesProfitModifierEntryNo + 1;
                            lrecPostedSalesProfitModifierToInsert."Entry No." := lintPostedSalesProfitModifierEntryNo;

                            lrecPostedSalesProfitModifierToInsert.Validate("Amount (LCY)", -lrecPostedSalesProfitModifierSummary."Amount (LCY)");
                            lrecPostedSalesProfitModifierToInsert.Validate(Amount, -lrecPostedSalesProfitModifierSummary.Amount);

                            lrecPostedSalesProfitModifierToInsert.Insert;

                        end;
                        //</ENRE1.00>

                    end;
                end;
            until lrecRebateLedgEntry.Next = 0;
        end;
    end;


    procedure PostReversal()
    var
        lrptPostRebate: Report "Post Purchase Rebates ELA";
    begin
        lrptPostRebate.SetRebateLedgerFilters('', "Purchase Rebate Header", '');
        lrptPostRebate.SetPostOption(0);
        lrptPostRebate.UseRequestPage(false);
        lrptPostRebate.Run;
    end;
}

