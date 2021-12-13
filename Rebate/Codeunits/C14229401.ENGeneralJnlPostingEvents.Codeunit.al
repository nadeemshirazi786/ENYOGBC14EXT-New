codeunit 14229401 "Gen. Jnl. Posting Events ELA"
{
    // ENRE1.00 2021-08-25 AJ 


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 17, 'OnAfterCopyGLEntryFromGenJnlLine', '', false, false)]
    local procedure rdOnAfterCopyGLEntryFromGenJnlLine(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        //<ENRE1.00>
        GLEntry."Rebate Code ELA" := GenJournalLine."Rebate Code ELA";
        GLEntry."Rebate Source Type ELA" := GenJournalLine."Rebate Source Type ELA";
        GLEntry."Rebate Source No. ELA" := GenJournalLine."Rebate Source No. ELA";
        GLEntry."Rebate Source Line No. ELA" := GenJournalLine."Rebate Source Line No. ELA";
        GLEntry."Rebate Document No. ELA" := GenJournalLine."Rebate Document No. ELA";
        GLEntry."Posted Rebate Entry No. ELA" := GenJournalLine."Posted Rebate Entry No. ELA";
        //<ENRE1.00/>

        //<ENRE1.00>
        GLEntry."Rbt Accrual Customer No. ELA" := GenJournalLine."Rebate Accrual Customer No.";
        GLEntry."Rebate Customer No. ELA" := GenJournalLine."Rebate Customer No. ELA";
        GLEntry."Rebate Item No. ELA" := GenJournalLine."Rebate Item No. ELA";
        GLEntry."Rebate Category Code ELA" := GenJournalLine."Rebate Category Code ELA";
        GLEntry."Customer Rebate Group ELA" := GenJournalLine."Customer Rebate Group ELA";
        GLEntry."Item Rebate Group ELA" := GenJournalLine."Item Rebate Group ELA";
        //</ENRE1.00>

        //<ENRE1.00>
        GLEntry."Rebate Accrual Vendor No. ELA" := GenJournalLine."Rebate Accrual Vendor No. ELA";
        GLEntry."Rebate Vendor No. ELA" := GenJournalLine."Rebate Vendor No. ELA";
        GLEntry."Vendor Rebate Group ELA" := GenJournalLine."Vendor Rebate Group ELA";
        //</ENRE1.00>


    end;

    [EventSubscriber(ObjectType::Table, 21, 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure rdOnAfterCopyCustLedgerEntryFromGenJnlLine(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        //<ENRE1.00>
        CustLedgerEntry."Rebate Code ELA" := GenJournalLine."Rebate Code ELA";
        CustLedgerEntry."Rebate Source Type ELA" := GenJournalLine."Rebate Source Type ELA";
        CustLedgerEntry."Rebate Source No. ELA" := GenJournalLine."Rebate Source No. ELA";
        CustLedgerEntry."Rebate Source Line No. ELA" := GenJournalLine."Rebate Source Line No. ELA";
        CustLedgerEntry."Rebate Document No. ELA" := GenJournalLine."Rebate Document No. ELA";
        CustLedgerEntry."Posted Rebate Entry No. ELA" := GenJournalLine."Posted Rebate Entry No. ELA";
        //</ENRE1.00>

        //<ENRE1.00>
        CustLedgerEntry."Rbt Accrual Customer No. ELA" := GenJournalLine."Rebate Accrual Customer No.";
        CustLedgerEntry."Rebate Customer No. ELA" := GenJournalLine."Rebate Customer No. ELA";
        CustLedgerEntry."Rebate Item No. ELA" := GenJournalLine."Rebate Item No. ELA";
        CustLedgerEntry."Rebate Category Code ELA" := GenJournalLine."Rebate Category Code ELA";
        CustLedgerEntry."Customer Rebate Group ELA" := GenJournalLine."Customer Rebate Group ELA";
        CustLedgerEntry."Item Rebate Group ELA" := GenJournalLine."Item Rebate Group ELA";
        //</ENRE1.00>

        //<ENRE1.00>
        CustLedgerEntry."Inv For Bill of Lading No. ELA" := GenJournalLine."Inv For Bill of Lading No ELA";
        CustLedgerEntry."Invoice For Shipment No. ELA" := GenJournalLine."Invoice For Shipment No. ELA";
        //</ENRE1.00>

        //<ENRE1.00>
        CustLedgerEntry."Comment ELA" := GenJournalLine.Comment;
        //</ENRE1.00>

        //<ENRE1.00>
        CustLedgerEntry."Job No. ELA" := GenJournalLine."Job No.";
        CustLedgerEntry."Job Task No. ELA" := GenJournalLine."Job Task No.";
        //</ENRE1.00>
    end;

    [EventSubscriber(ObjectType::Table, 25, 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure rdOnAfterCopyVendLedgerEntryFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        //<ENRE1.00>
        VendorLedgerEntry."Comment ELA" := GenJournalLine.Comment;
        //</ENRE1.00>

        //<ENRE1.00>
        VendorLedgerEntry."Rebate Code ELA" := GenJournalLine."Rebate Code ELA";
        VendorLedgerEntry."Rebate Source Type ELA" := GenJournalLine."Rebate Source Type ELA";
        VendorLedgerEntry."Rebate Source No. ELA" := GenJournalLine."Rebate Source No. ELA";
        VendorLedgerEntry."Rebate Source Line No. ELA" := GenJournalLine."Rebate Source Line No. ELA";
        VendorLedgerEntry."Rebate Document No. ELA" := GenJournalLine."Rebate Document No. ELA";
        VendorLedgerEntry."Posted Rebate Entry No. ELA" := GenJournalLine."Posted Rebate Entry No. ELA";
        VendorLedgerEntry."Rebate Accrual Vendor No. ELA" := GenJournalLine."Rebate Accrual Vendor No. ELA";
        VendorLedgerEntry."Rebate Vendor No. ELA" := GenJournalLine."Rebate Vendor No. ELA";
        VendorLedgerEntry."Rebate Item No. ELA" := GenJournalLine."Rebate Item No. ELA";
        VendorLedgerEntry."Rebate Category Code ELA" := GenJournalLine."Rebate Category Code ELA";
        VendorLedgerEntry."Vendor Rebate Group ELA" := GenJournalLine."Vendor Rebate Group ELA";
        VendorLedgerEntry."Item Rebate Group ELA" := GenJournalLine."Item Rebate Group ELA";
        //</ENRE1.00>
    end;

    [EventSubscriber(ObjectType::Table, 382, 'OnAfterCopyFromVendLedgerEntry', '', false, false)]
    local procedure rdOnAfterCopyFromVendLedgerEntry(var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer"; VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        //<ENRE1.00>
        CVLedgerEntryBuffer."Rebate Code ELA" := VendorLedgerEntry."Rebate Code ELA";
        CVLedgerEntryBuffer."Rebate Source Type ELA" := VendorLedgerEntry."Rebate Source Type ELA";
        CVLedgerEntryBuffer."Rebate Source No. ELA" := VendorLedgerEntry."Rebate Source No. ELA";
        CVLedgerEntryBuffer."Rebate Source Line No. ELA" := VendorLedgerEntry."Rebate Source Line No. ELA";
        CVLedgerEntryBuffer."Rebate Document No. ELA" := VendorLedgerEntry."Rebate Document No. ELA";
        CVLedgerEntryBuffer."Posted Rebate Entry No. ELA" := VendorLedgerEntry."Posted Rebate Entry No. ELA";
        CVLedgerEntryBuffer."Rebate Accrual Vendor No. ELA" := VendorLedgerEntry."Rebate Accrual Vendor No. ELA";
        CVLedgerEntryBuffer."Rebate Vendor No. ELA" := VendorLedgerEntry."Rebate Vendor No. ELA";
        CVLedgerEntryBuffer."Rebate Item No. ELA" := VendorLedgerEntry."Rebate Item No. ELA";
        CVLedgerEntryBuffer."Rebate Category Code ELA" := VendorLedgerEntry."Rebate Category Code ELA";
        CVLedgerEntryBuffer."Vendor Rebate Group ELA" := VendorLedgerEntry."Vendor Rebate Group ELA";
        CVLedgerEntryBuffer."Item Rebate Group ELA" := VendorLedgerEntry."Item Rebate Group ELA";
        //</ENRE1.00>
    end;

    [EventSubscriber(ObjectType::Table, 25, 'OnAfterCopyVendLedgerEntryFromCVLedgEntryBuffer', '', false, false)]
    local procedure rdOnAfterCopyVendLedgerEntryFromCVLedgEntryBuffer(var VendorLedgerEntry: Record "Vendor Ledger Entry"; CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer")
    begin
        //<ENRE1.00>
        VendorLedgerEntry."Rebate Code ELA" := CVLedgerEntryBuffer."Rebate Code ELA";
        VendorLedgerEntry."Rebate Source Type ELA" := CVLedgerEntryBuffer."Rebate Source Type ELA";
        VendorLedgerEntry."Rebate Source No. ELA" := CVLedgerEntryBuffer."Rebate Source No. ELA";
        VendorLedgerEntry."Rebate Source Line No. ELA" := CVLedgerEntryBuffer."Rebate Source Line No. ELA";
        VendorLedgerEntry."Rebate Document No. ELA" := CVLedgerEntryBuffer."Rebate Document No. ELA";
        VendorLedgerEntry."Posted Rebate Entry No. ELA" := CVLedgerEntryBuffer."Posted Rebate Entry No. ELA";
        VendorLedgerEntry."Rebate Accrual Vendor No. ELA" := CVLedgerEntryBuffer."Rebate Accrual Vendor No. ELA";
        VendorLedgerEntry."Rebate Vendor No. ELA" := CVLedgerEntryBuffer."Rebate Vendor No. ELA";
        VendorLedgerEntry."Rebate Item No. ELA" := CVLedgerEntryBuffer."Rebate Item No. ELA";
        VendorLedgerEntry."Rebate Category Code ELA" := CVLedgerEntryBuffer."Rebate Category Code ELA";
        VendorLedgerEntry."Vendor Rebate Group ELA" := CVLedgerEntryBuffer."Vendor Rebate Group ELA";
        VendorLedgerEntry."Item Rebate Group ELA" := CVLedgerEntryBuffer."Item Rebate Group ELA";
        //</ENRE1.00>
    end;

    [EventSubscriber(ObjectType::Table, 382, 'OnAfterCopyFromCustLedgerEntry', '', false, false)]
    local procedure rdOnAfterCopyFromCustLedgerEntry(var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer"; CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        //<ENRE1.00>
        CVLedgerEntryBuffer."Rebate Code ELA" := CustLedgerEntry."Rebate Code ELA";
        CVLedgerEntryBuffer."Rebate Source Type ELA" := CustLedgerEntry."Rebate Source Type ELA";
        CVLedgerEntryBuffer."Rebate Source No. ELA" := CustLedgerEntry."Rebate Source No. ELA";
        CVLedgerEntryBuffer."Rebate Source Line No. ELA" := CustLedgerEntry."Rebate Source Line No. ELA";
        CVLedgerEntryBuffer."Rebate Document No. ELA" := CustLedgerEntry."Rebate Document No. ELA";
        CVLedgerEntryBuffer."Posted Rebate Entry No. ELA" := CustLedgerEntry."Posted Rebate Entry No. ELA";
        //<ENRE1.00/>

        //<ENRE1.00>
        CVLedgerEntryBuffer."Rbt Accrual Customer No. ELA" := CustLedgerEntry."Rbt Accrual Customer No. ELA";
        CVLedgerEntryBuffer."Rebate Customer No. ELA" := CustLedgerEntry."Rebate Customer No. ELA";
        CVLedgerEntryBuffer."Rebate Item No. ELA" := CustLedgerEntry."Rebate Item No. ELA";
        CVLedgerEntryBuffer."Rebate Category Code ELA" := CustLedgerEntry."Rebate Category Code ELA";
        CVLedgerEntryBuffer."Customer Rebate Group ELA" := CustLedgerEntry."Customer Rebate Group ELA";
        CVLedgerEntryBuffer."Item Rebate Group ELA" := CustLedgerEntry."Item Rebate Group ELA";
        //</ENRE1.00>
    end;

    [EventSubscriber(ObjectType::Table, 21, 'OnAfterCopyCustLedgerEntryFromCVLedgEntryBuffer', '', false, false)]
    local procedure rdOnAfterCopyCustLedgerEntryFromCVLedgEntryBuffer(var CustLedgerEntry: Record "Cust. Ledger Entry"; CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer")
    begin
        //<ENRE1.00>
        CustLedgerEntry."Rebate Code ELA" := CVLedgerEntryBuffer."Rebate Code ELA";
        CustLedgerEntry."Rebate Source Type ELA" := CVLedgerEntryBuffer."Rebate Source Type ELA";
        CustLedgerEntry."Rebate Source No. ELA" := CVLedgerEntryBuffer."Rebate Source No. ELA";
        CustLedgerEntry."Rebate Source Line No. ELA" := CVLedgerEntryBuffer."Rebate Source Line No. ELA";
        CustLedgerEntry."Rebate Document No. ELA" := CVLedgerEntryBuffer."Rebate Document No. ELA";
        CustLedgerEntry."Posted Rebate Entry No. ELA" := CVLedgerEntryBuffer."Posted Rebate Entry No. ELA";
        //<ENRE1.00/>

        //<ENRE1.00>
        CustLedgerEntry."Rbt Accrual Customer No. ELA" := CVLedgerEntryBuffer."Rbt Accrual Customer No. ELA";
        CustLedgerEntry."Rebate Customer No. ELA" := CVLedgerEntryBuffer."Rebate Customer No. ELA";
        CustLedgerEntry."Rebate Item No. ELA" := CVLedgerEntryBuffer."Rebate Item No. ELA";
        CustLedgerEntry."Rebate Category Code ELA" := CVLedgerEntryBuffer."Rebate Category Code ELA";
        CustLedgerEntry."Customer Rebate Group ELA" := CVLedgerEntryBuffer."Customer Rebate Group ELA";
        CustLedgerEntry."Item Rebate Group ELA" := CVLedgerEntryBuffer."Item Rebate Group ELA";
        //</ENRE1.00>
    end;

    [EventSubscriber(ObjectType::Codeunit, 22, 'OnAfterInitItemLedgEntry', '', false, false)]
    local procedure rdOnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    var
        lItem: Record Item;
    begin
    end;

    [EventSubscriber(ObjectType::Table, 203, 'OnAfterCopyFromResJnlLine', '', false, false)]
    local procedure rdOnAfterCopyFromResJnlLine(var ResLedgerEntry: Record "Res. Ledger Entry"; ResJournalLine: Record "Res. Journal Line")
    begin
        //<ENRE1.00>
        //Transfer Quality Measure Code to Ledger
        //ResLedgerEntry."Quality Measure Code" := ResJournalLine."Quality Measure Code";
        //</ENRE1.00>
    end;
}

