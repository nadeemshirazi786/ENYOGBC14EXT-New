report 14229403 "Cancel Rebate ELA"
{
    //ENRE1.00 2021-09-08 AJ
    // 
    // ENRE1.00
    //    - fix code re: comments
    // 
    // ENRE1.00
    //    - changed logic to check for posting date availability
    // 
    // ENRE1.00
    //    - handle blocked rebates
    // 
    // ENRE1.00
    Caption = 'Cancelled Rebate';
    ApplicationArea = All;
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Rebate Header"; "Rebate Header ELA")
        {
            DataItemTableView = SORTING(Code);
            RequestFilterFields = "Code";

            trigger OnAfterGetRecord()
            begin
                if GuiAllowed then
                    gdlgWindow.Update(1, Code);

                //<ENRE1.00>
                TestField(Blocked, false);
                //</ENRE1.00>

                //<ENRE1.00>
                if "Rebate Type" = "Rebate Type"::Commodity then begin
                    Error(gText009, "Rebate Type", Code);
                end;
                //</ENRE1.00>

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

                    if not Confirm(gText002, false, "Rebate Header".Code) then
                        Error(gText001);
                end;

                //-- Verify that the selecte dPOstin gDate can be posted to
                if gdtePostingDate = 0D then
                    Error(gText003);


                //<ENRE1.00>
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
                //</ENRE1.00>


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
        gText009: Label 'Rebate Type is %1. You cannot cancel Rebate %2.';


    procedure MoveRebateToCancelled()
    var
        lrecRebate: Record "Rebate Header ELA";
        lrecRebateDetail: Record "Rebate Line ELA";
        lrecRebateComment: Record "Rebate Comment Line ELA";
        lrecCancelRebate: Record "Cancelled Rebate Header ELA";
        lrecCancelRebateDetail: Record "Cancelled Rebate Line ELA";
        lrecCancelRebateComment: Record "Cancel Rbt Comment Line ELA";
    begin
        //-- Rebate Header
        lrecRebate.Get("Rebate Header".Code);
        lrecCancelRebate.Init;
        lrecCancelRebate.TransferFields(lrecRebate);
        lrecCancelRebate.Insert(true);
        lrecRebate.Delete;

        //-- Rebate Details
        lrecRebateDetail.SetRange("Rebate Code", "Rebate Header".Code);
        lrecRebateDetail.SetRange("Line No.");

        if lrecRebateDetail.FindSet(true) then begin
            repeat
                lrecCancelRebateDetail.Init;
                lrecCancelRebateDetail.TransferFields(lrecRebateDetail);
                lrecCancelRebateDetail.Insert(true);
            until lrecRebateDetail.Next = 0;

            lrecRebateDetail.DeleteAll;
        end;

        //-- Rebate Comments
        lrecRebateComment.SetRange("Rebate Code", "Rebate Header".Code);
        lrecRebateComment.SetRange("Line No.");

        if lrecRebateComment.FindSet(true) then begin
            repeat
                lrecCancelRebateComment.Init;
                lrecCancelRebateComment.TransferFields(lrecRebateComment);
                lrecCancelRebateComment.Insert(true);
            until lrecRebateComment.Next = 0;

            lrecRebateComment.DeleteAll;
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
        lrecRebateEntry.SetRange("Rebate Code", "Rebate Header".Code);

        //-- Loop throughand delete as it is less of a performance hit than the DELETEALL is
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
        lrecRebate: Record "Rebate Header ELA";
        lrecRebateLedgEntry: Record "Rebate Ledger Entry ELA";
        lrecRebateLedgEntryINS: Record "Rebate Ledger Entry ELA";
        lcodCurrSourceNo: Code[20];
        lintCurrSourceLineNo: Integer;
        lintEntryNo: Integer;
        lintCounter: Integer;
        lintCount: Integer;
        lcodCurrItemNo: Code[20];
    begin
        lrecRebate.Get("Rebate Header".Code);

        lrecRebateLedgEntry.SetCurrentKey("Functional Area", "Source Type", "Source No.", "Source Line No.", "Rebate Type", "Rebate Code");

        lrecRebateLedgEntry.SetRange("Functional Area");
        lrecRebateLedgEntry.SetRange("Source Type");
        lrecRebateLedgEntry.SetRange("Source No.");
        lrecRebateLedgEntry.SetRange("Source Line No.");
        lrecRebateLedgEntry.SetRange("Rebate Type");
        lrecRebateLedgEntry.SetRange("Rebate Code", lrecRebate.Code);

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

                    //-- Determine what the total posted amount for the rebate is for this source doc line and create an entry to reverse it
                    lrecRebate.SetRange("Functional Area Filter", lrecRebateLedgEntry."Functional Area");
                    lrecRebate.SetRange("Source Type Filter", lrecRebateLedgEntry."Source Type");
                    lrecRebate.SetRange("Source No. Filter", lrecRebateLedgEntry."Source No.");
                    lrecRebate.SetRange("Source Line No. Filter", lrecRebateLedgEntry."Source Line No.");

                    lrecRebate.CalcFields("Rebate Ledger Amount (LCY)", "Rebate Ledger Amount (RBT)", "Rebate Ledger Amount (DOC)");

                    if lrecRebate."Rebate Ledger Amount (LCY)" <> 0 then begin
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

                        lrecRebateLedgEntryINS."Amount (LCY)" := -lrecRebateLedgEntry."Amount (LCY)";
                        lrecRebateLedgEntryINS."Amount (RBT)" := -lrecRebateLedgEntry."Amount (RBT)";
                        lrecRebateLedgEntryINS."Amount (DOC)" := -lrecRebateLedgEntry."Amount (DOC)";

                        lrecRebateLedgEntryINS.UpdateRebateRates;

                        lrecRebateLedgEntryINS.Insert(true);

                        lintEntryNo += 1;
                    end;
                end;
            until lrecRebateLedgEntry.Next = 0;
        end;
    end;


    procedure PostReversal()
    var
        lrptPostRebate: Report "Post Rebates ELA";
    begin
        lrptPostRebate.SetRebateLedgerFilters('', "Rebate Header", '');
        lrptPostRebate.SetPostOption(0);  //-- need to post right away always

        lrptPostRebate.UseRequestPage(false);
        lrptPostRebate.Run;
    end;
}

