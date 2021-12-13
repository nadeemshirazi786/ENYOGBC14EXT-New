report 14229410 "Post Scheduled Rbt Entries ELA"
{

    // 
    // ENRE1.00
    //   
    //     should work the same as the Accrue Customer Rebates form "Post Entries to Customer" function
    //     filters on records marked as "Rebate Ledger Entry"::"Schedule For Processing"

    //ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            dataitem("Rebate Ledger Entry"; "Rebate Ledger Entry ELA")
            {
                DataItemLink = "Post-to Customer No." = FIELD("No.");
                DataItemTableView = SORTING("Functional Area", "Post-to Customer No.", "Rebate Code", "Posting Date", "Posted To G/L", "G/L Posting Only", "Posted To Customer") WHERE("Posted To G/L" = CONST(true), "Posted To Customer" = CONST(false), "G/L Posting Only" = CONST(true), "Schedule For Processing" = CONST(true));
                MaxIteration = 1;

                trigger OnAfterGetRecord()
                var
                    lcduRebateMgmt: Codeunit "Rebate Management ELA";
                    lrecRebateLedgerEntry: Record "Rebate Ledger Entry ELA";
                begin

                    lrecRebateLedgerEntry.CopyFilters("Rebate Ledger Entry");

                    lcduRebateMgmt.SkipDialogMode(true);
                    lcduRebateMgmt.AccrueRebateToCustomer(lrecRebateLedgerEntry, "Post-to Customer No.");

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

