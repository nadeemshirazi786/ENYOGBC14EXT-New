report 14229411 "Post Sch Purch Rbt Entries ELA"
{
    //ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - New Report
    // 
    // ENRE1.00
    //    - changed Rebate Ledger Entry dataitemtableview and dataitemlink

    //ApplicationArea = All;
    Caption = 'Post Scheduled Purchase Rebate Entries';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            dataitem("Rebate Ledger Entry"; "Rebate Ledger Entry ELA")
            {
                DataItemLink = "Post-to Vendor No." = FIELD("No.");
                DataItemTableView = SORTING("Functional Area", "Post-to Vendor No.", "Rebate Code", "Posting Date", "Posted To G/L", "G/L Posting Only", "Posted To Vendor", "Paid-by Vendor") WHERE("Posted To G/L" = CONST(true), "Posted To Vendor" = CONST(false), "G/L Posting Only" = CONST(true), "Schedule For Processing" = CONST(true));
                MaxIteration = 1;

                trigger OnAfterGetRecord()
                var
                    lcduPurchRebateMgmt: Codeunit "Purchase Rebate Management ELA";
                    lrecRebateLedgerEntry: Record "Rebate Ledger Entry ELA";
                begin
                    lrecRebateLedgerEntry.CopyFilters("Rebate Ledger Entry");
                    lcduPurchRebateMgmt.SkipDialogMode(true);
                    lcduPurchRebateMgmt.AccrueRebateFromVendor(lrecRebateLedgerEntry, "Post-to Vendor No.");
                    Commit;
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }
}

