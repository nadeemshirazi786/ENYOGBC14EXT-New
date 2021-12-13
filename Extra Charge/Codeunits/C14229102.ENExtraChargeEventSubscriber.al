codeunit 14229102 "EN Event Subscriber(ExtraChrg)"
{
    [EventSubscriber(ObjectType::Codeunit, 22, 'OnBeforeInsertValueEntry', '', true, true)]
    procedure OnBeforeInsertValueEntry(VAR ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line"; VAR ItemLedgerEntry: Record "Item Ledger Entry"; VAR ValueEntryNo: Integer; VAR InventoryPostingToGL: Codeunit "Inventory Posting To G/L"; CalledFromAdjustment: Boolean)
    var
        ExtraChargeBuffer: Record "EN Extra Charge Posting Buffer";
        ExtraChargeQty: Decimal;
    begin
        ExtraChargeMgmt.AdjustItemJnlLine(ItemJournalLine, ExtraChargeBuffer, ExtraChargeQty);

        ExtraChargeMgmt.SetExtraChargeBuffer(ExtraChargeBuffer, ExtraChargeQty, ItemJournalLine."Purchase Order No. ELA");
        IF ExtraChargeBuffer.FINDFIRST THEN
            ExtraChargeMgmt.MoveToValueEntry(ValueEntry, ItemLedgerEntry, ItemJournalLine);
    end;

    //[EventSubscriber(ObjectType::Codeunit, 22, 'OnBeforeInsertCapValueEntrySetRunOnlyCheck', '', true, true)]
    procedure OnBeforeInsertCapValueEntrySetRunOnlyCheck(ValueEntry: Record "Value Entry"; SetCalledFromItemPosting: Boolean; SetCheckOnly: Boolean; SetCalledFromTestReport: Boolean)
    var
        ENGlobalBuffer: Record "EN Global Buffer";
    begin
        IF ENGlobalBuffer.GET(ValueEntry."Entry No.", '') THEN begin
            ENGlobalBuffer."Boolean Value 1" := SetCalledFromItemPosting;
            ENGlobalBuffer."Boolean Value 2" := SetCheckOnly;
            ENGlobalBuffer."Boolean Value 3" := SetCalledFromTestReport;
            ENGlobalBuffer.Modify;
        end else begin
            ENGlobalBuffer.INIT;
            ENGlobalBuffer."Key 1" := ValueEntry."Entry No.";
            ENGlobalBuffer."Boolean Value 1" := SetCalledFromItemPosting;
            ENGlobalBuffer."Boolean Value 2" := SetCheckOnly;
            ENGlobalBuffer."Boolean Value 3" := SetCalledFromTestReport;
            ENGlobalBuffer.INSERT;
        end;
    end;

    //[EventSubscriber(ObjectType::Codeunit, 22, 'OnBeforePostInvtToGLSetRunOnlyCheck', '', true, true)]
    procedure OnBeforePostInvtToGLSetRunOnlyCheck(ValueEntry: Record "Value Entry"; SetCalledFromItemPosting: Boolean; SetCheckOnly: Boolean; SetCalledFromTestReport: Boolean)
    var
        ENGlobalBuffer: Record "EN Global Buffer";
    begin
        IF ENGlobalBuffer.GET(ValueEntry."Entry No.", '') THEN begin
            ENGlobalBuffer."Boolean Value 1" := SetCalledFromItemPosting;
            ENGlobalBuffer."Boolean Value 2" := SetCheckOnly;
            ENGlobalBuffer."Boolean Value 3" := SetCalledFromTestReport;
            ENGlobalBuffer.Modify;
        end else begin
            ENGlobalBuffer.INIT;
            ENGlobalBuffer."Key 1" := ValueEntry."Entry No.";
            ENGlobalBuffer."Boolean Value 1" := SetCalledFromItemPosting;
            ENGlobalBuffer."Boolean Value 2" := SetCheckOnly;
            ENGlobalBuffer."Boolean Value 3" := SetCalledFromTestReport;
            ENGlobalBuffer.INSERT;
        end;
    end;

    //[EventSubscriber(ObjectType::Codeunit, 22, 'OnBeforePostInvtToGLSetRunOnlyCheck2', '', true, true)]
    procedure OnBeforePostInvtToGLSetRunOnlyCheck2(ValueEntry: Record "Value Entry"; SetCalledFromItemPosting: Boolean; SetCheckOnly: Boolean; SetCalledFromTestReport: Boolean)
    var
        ENGlobalBuffer: Record "EN Global Buffer";
    begin
        IF ENGlobalBuffer.GET(ValueEntry."Entry No.", '') THEN begin
            ENGlobalBuffer."Boolean Value 1" := SetCalledFromItemPosting;
            ENGlobalBuffer."Boolean Value 2" := SetCheckOnly;
            ENGlobalBuffer."Boolean Value 3" := SetCalledFromTestReport;
            ENGlobalBuffer.Modify;
        end else begin
            ENGlobalBuffer.INIT;
            ENGlobalBuffer."Key 1" := ValueEntry."Entry No.";
            ENGlobalBuffer."Boolean Value 1" := SetCalledFromItemPosting;
            ENGlobalBuffer."Boolean Value 2" := SetCheckOnly;
            ENGlobalBuffer."Boolean Value 3" := SetCalledFromTestReport;
            ENGlobalBuffer.INSERT;
        end;
    end;

    //[EventSubscriber(ObjectType::Codeunit, 22, 'OnBeforePostInvtToGLSetRunOnlyCheck3', '', true, true)]
    procedure OnBeforePostInvtToGLSetRunOnlyCheck3(ValueEntry: Record "Value Entry"; SetCalledFromItemPosting: Boolean; SetCheckOnly: Boolean; SetCalledFromTestReport: Boolean)
    var
        ENGlobalBuffer: Record "EN Global Buffer";
    begin
        IF ENGlobalBuffer.GET(ValueEntry."Entry No.", '') THEN begin
            ENGlobalBuffer."Boolean Value 1" := SetCalledFromItemPosting;
            ENGlobalBuffer."Boolean Value 2" := SetCheckOnly;
            ENGlobalBuffer."Boolean Value 3" := SetCalledFromTestReport;
            ENGlobalBuffer.Modify;
        end else begin
            ENGlobalBuffer.INIT;
            ENGlobalBuffer."Key 1" := ValueEntry."Entry No.";
            ENGlobalBuffer."Boolean Value 1" := SetCalledFromItemPosting;
            ENGlobalBuffer."Boolean Value 2" := SetCheckOnly;
            ENGlobalBuffer."Boolean Value 3" := SetCalledFromTestReport;
            ENGlobalBuffer.INSERT;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 22, 'OnBeforeInsertCorrValueEntry', '', true, true)]
    procedure OnBeforeInsertCorrValueEntry(OldValueEntry: Record "Value Entry"; NewValueEntry: Record "Value Entry"; Sign: Integer)
    var
        QtyToShip: Decimal;
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        Clear(QtyToShip);
        ItemLedgEntry.GET(NewValueEntry."Item Ledger Entry No.");
        IF ItemLedgEntry."Invoiced Quantity" = 0 THEN begin
            If (Sign = -1) and (NewValueEntry."Invoiced Quantity" = 0) then
                QtyToShip := NewValueEntry."Item Ledger Entry Quantity";
        end else
            QtyToShip := NewValueEntry."Item Ledger Entry Quantity";

        ExtraChargeMgmt.CopyEntryExtraCharge(OldValueEntry."Entry No.", NewValueEntry."Entry No.", Sign, NewValueEntry."Expected Cost", QtyToShip);
    end;



    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostLines', '', true, true)]
    procedure AfterOnBeforePostLines(VAR SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
        ExtraChargeMgmt.ClearDropShipPostingBuffer;
    end;


    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostAssocItemJnlLine', '', true, true)]
    procedure OnBeforePostAssocItemJnlLineEC(ItemJournalLine: Record "Item Journal Line"; PurchaseLine: Record "Purchase Line"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean)
    var
        ExtraChargeBuffer: Record "EN Extra Charge Posting Buffer";
        ExtraChargeQty: Decimal;
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
    begin

        ExtraChargeMgmt.StartDropShipPosting(PurchaseHeader, PurchaseLine, SalesHeader, SalesLine);
        ExtraChargeMgmt.AdjustItemJnlLine(ItemJournalLine, ExtraChargeBuffer, ExtraChargeQty);
        ExtraChargeMgmt.SetExtraChargeBuffer(ExtraChargeBuffer, ExtraChargeQty, SalesHeader."No.");
    end;



    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePurchRcptHeaderInsert', '', true, true)]
    procedure OnBeforePurchRcptHeaderInsertSalesEC(PurchRcptHeader: Record "Purch. Rcpt. Header"; PurchaseHeader: Record "Purchase Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean)
    var
        ExtraCharge: Record "EN Extra Charge";
    begin
        ExtraChargeMgmt.MoveToDocumentHeader(DATABASE::"Purchase Header",
      PurchaseHeader."Document Type", PurchaseHeader."No.",
      PurchaseHeader."Posting Date", DATABASE::"Purch. Rcpt. Header", PurchRcptHeader."No.");
    end;



    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostDropOrderShipment', '', true, true)]
    procedure OnBeforePostDropOrderShipmentEC()
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchOrderLine: Record "Purchase Line";
    begin
        ExtraChargeMgmt.DropShipMoveToDocumentLine(PurchRcptLine."Document No.", PurchRcptLine."Line No.", PurchOrderLine."Sales Order Line No.");

        //ExtraChargeMgmt.DropShipUpdateVendorBuffer(PurchOrderHeader);
        //ExtraChargeMgmt.CreateVendorInvoices(ExtraCharge);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterInsertDropOrderPurchRcptHeader', '', true, true)]
    procedure OnAfterInsertDropOrderPurchRcptHeaderEC(PurchRcptHeader: Record "Purch. Rcpt. Header")
    var
        ExtraCharge: Record "EN Extra Charge";
        PurchOrderHeader: Record "Purchase Header";
    begin
        ExtraChargeMgmt.DropShipUpdateVendorBuffer(PurchOrderHeader);
        ExtraChargeMgmt.CreateVendorInvoices(ExtraCharge);
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnPostPurchLineOnAfterSetEverythingInvoiced', '', true, true)]
    procedure OnPostPurchLineOnAfterInvoiceEC(PurchaseLine: Record "Purchase Line"; var EverythingInvoiced: Boolean)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        //<<ENEC1.00
        IF (PurchaseLine.Type = PurchaseLine.Type::Item) THEN
            ExtraChargeMgmt.StartPurchasePosting(PurchaseHeader, PurchaseLine, Currency);
        //>>ENEC1.00    
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforePurchInvLineInsert', '', true, true)]
    procedure OnBeforePurchInvLineInsertEC(PurchInvLine: Record "Purch. Inv. Line"; PurchInvHeader: Record "Purch. Inv. Header"; PurchaseLine: Record "Purchase Line"; CommitIsSupressed: Boolean)
    begin
        //<<ENEC1.00
        IF (PurchInvLine.Type = PurchInvLine.Type::Item) THEN
            ExtraChargeMgmt.MoveToDocumentLine(DATABASE::"Purch. Inv. Line", PurchInvLine."Document No.", PurchInvLine."Line No.");

        IF (PurchInvLine.Type = PurchInvLine.Type::"G/L Account") THEN
            ExtraChargeFunction.UpdateExtraChargeSummary(PurchaseLine, PurchInvLine);
        //>>ENEC1.00    
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforeItemJnlPostLine', '', true, true)]
    procedure OnBeforeItemJnlPostLineEC(VAR ItemJournalLine: Record "Item Journal Line"; PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; CommitIsSupressed: Boolean; VAR IsHandled: Boolean)
    var
        ExtraChargeBuffer: Record "EN Extra Charge Posting Buffer";
        ExtraChargeQty: Decimal;
    begin
        ItemJournalLine."Purchase Order No. ELA" := PurchaseHeader."No.";
        ExtraChargeMgmt.AdjustItemJnlLine(ItemJournalLine, ExtraChargeBuffer, ExtraChargeQty);
        ExtraChargeMgmt.SetExtraChargeBuffer(ExtraChargeBuffer, ExtraChargeQty, ItemJournalLine."Document No.");  ///TMS 04/09/18    

    end;


    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterDeleteAfterPosting', '', true, true)]
    procedure AfterOnAfterDeleteAfterPosting(PurchHeader: Record "Purchase Header"; PurchInvHeader: Record "Purch. Inv. Header"; PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; CommitIsSupressed: Boolean)
    var
        ECPostingBuffer: Record "EN Extra Charge Posting Buffer";
    begin
        //<<ENEC1.00
        DocExtraCharge.RESET;
        DocExtraCharge.SETFILTER("Table ID", '%1|%2', DATABASE::"Purchase Header", DATABASE::"Purchase Line");
        DocExtraCharge.SETRANGE("Document Type", PurchHeader."Document Type");
        DocExtraCharge.SETRANGE("Document No.", PurchHeader."No.");
        DocExtraCharge.DELETEALL;
        //>>ENEC1.00 
    end;


    [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforePurchInvHeaderInsert', '', true, true)]

    procedure OnBeforePurchInvHeaderInsertEC(PurchInvHeader: Record "Purch. Inv. Header"; PurchHeader: Record "Purchase Header"; CommitIsSupressed: Boolean)
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        //<<ENEC1.00
        ExtraChargeMgmt.MoveToDocumentHeader(DATABASE::"Purchase Header",
            PurchHeader."Document Type", PurchHeader."No.", PurchHeader."Posting Date",
            DATABASE::"Purch. Inv. Header", PurchInvHeader."No.");
        //>>ENEC1.00
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforePurchRcptHeaderInsert', '', true, true)]
    procedure OnBeforePurchRcptHeaderInsertPurchEC(PurchRcptHeader: Record "Purch. Rcpt. Header"; PurchaseHeader: Record "Purchase Header"; CommitIsSupressed: Boolean)

    begin
        //<<ENEC1.00
        ExtraChargeMgmt.MoveToDocumentHeader(DATABASE::"Purchase Header",
            PurchaseHeader."Document Type", PurchaseHeader."No.", PurchaseHeader."Posting Date",
            DATABASE::"Purch. Rcpt. Header", PurchRcptHeader."No.");
        //>>ENEC1.00    
    end;



    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPurchRcptLineInsert', '', true, true)]
    procedure OnAfterPurchRcptLineInsertEC(PurchaseLine: Record "Purchase Line"; PurchRcptLine: Record "Purch. Rcpt. Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean; PurchInvHeader: Record "Purch. Inv. Header"; VAR TempTrackingSpecification: Record "Tracking Specification" TEMPORARY)

    begin
        //<<ENEC1.00
        IF (PurchRcptLine.Type = PurchRcptLine.Type::Item) THEN
            ExtraChargeMgmt.MoveToDocumentLine(
                DATABASE::"Purch. Rcpt. Line", PurchRcptLine."Document No.", PurchRcptLine."Line No.");
        //>>ENEC1.00    
    end;



    [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforeReturnShptHeaderInsert', '', true, true)]
    procedure OnBeforeReturnShptHeaderInsertEC(ReturnShptHeader: Record "Return Shipment Header"; PurchHeader: Record "Purchase Header"; CommitIsSupressed: Boolean)
    begin
        //<<ENEC1.00
        ExtraChargeMgmt.MoveToDocumentHeader(DATABASE::"Purchase Header",
            PurchHeader."Document Type", PurchHeader."No.", PurchHeader."Posting Date",
            DATABASE::"Return Shipment Header", ReturnShptHeader."No.");
        //>>ENEC1.00    
    end;


    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterReturnShptLineInsert', '', true, true)]
    procedure OnAfterReturnShptLineInsertEC(ReturnShptLine: Record "Return Shipment Line"; ReturnShptHeader: Record "Return Shipment Header"; PurchLine: Record "Purchase Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean; VAR TempWhseShptHeader: Record "Warehouse Shipment Header" temporary; PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")

    begin
        //<<ENEC1.00
        IF (ReturnShptLine.Type = ReturnShptLine.Type::Item) THEN
            ExtraChargeMgmt.MoveToDocumentLine(
                DATABASE::"Return Shipment Line", ReturnShptLine."Document No.", ReturnShptLine."Line No.");
        //>>ENEC1.00    
    end;



    [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforePurchCrMemoHeaderInsert', '', true, true)]
    procedure OnBeforePurchCrMemoHeaderInsert(PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; PurchHeader: Record "Purchase Header"; CommitIsSupressed: Boolean)

    begin

        ExtraChargeMgmt.MoveToDocumentHeader(DATABASE::"Purchase Header",
            PurchHeader."Document Type", PurchHeader."No.", PurchHeader."Posting Date",
            DATABASE::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr."No.");

    end;

    [EventSubscriber(ObjectType::Codeunit, 5802, 'OnBeforeBufferInvtPosting', '', true, true)]
    procedure OnBeforeBufferInvtPosting(VAR ValueEntry: Record "Value Entry"; VAR Result: Boolean; VAR IsHandled: Boolean)

    var

        ENGlobalBuffer: Record "EN Global Buffer";
        EntryExtraCharge: Record "EN Value Entry Extra Charge";
        RecordBuffer: Record "Record Buffer";
    begin
        IF ENGlobalBuffer.GET(ValueEntry."Entry No.", '') THEN begin

            ENInventoryPostingToGL.SetRunOnlyCheck(ENGlobalBuffer."Boolean Value 1", ENGlobalBuffer."Boolean Value 2", ENGlobalBuffer."Boolean Value 3");
            IF ENInventoryPostingToGL.BufferInvtPosting(ValueEntry) THEN
                ENInventoryPostingToGL.PostInvtPostBufPerEntry(ValueEntry);
            IsHandled := True;
            ENGlobalBuffer.DELETE;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5813, 'OnAfterNewPurchRcptLineInsert', '', true, true)]
    procedure OnAfterNewPurchRcptLineInsert(VAR NewPurchRcptLine: Record "Purch. Rcpt. Line"; OldPurchRcptLine: Record "Purch. Rcpt. Line")
    begin

        ExtraChargeMgmt.CopyDocExtraCharge(Database::"Purch. Rcpt. Line", OldPurchRcptLine."Document No.", OldPurchRcptLine."Line No.",
        Database::"Purch. Rcpt. Line", NewPurchRcptLine."Document No.", NewPurchRcptLine."Line No.", -1);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5813, 'OnAfterPurchRcptLineModify', '', true, true)]
    procedure OnAfterPurchRcptLineModify(VAR PurchRcptLine: Record "Purch. Rcpt. Line")
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    begin

        //PurchRcptHeader.Get(PurchRcptLine."Document No.");
        //ExtraChargeMgmt.CalculateDocExtraCharge(Database::"Purch. Rcpt. Header", Database::"Purch. Rcpt. Line", PurchRcptLine."Document No.", PurchRcptHeader."Posting Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, 5813, 'OnAfterCode', '', true, true)]
    procedure OnAfterCode(VAR PurchRcptLine: Record "Purch. Rcpt. Line")
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    begin

        PurchRcptHeader.Get(PurchRcptLine."Document No.");
        ExtraChargeMgmt.CalculateDocExtraCharge(Database::"Purch. Rcpt. Header", Database::"Purch. Rcpt. Line", PurchRcptLine."Document No.", PurchRcptHeader."Posting Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, 5814, 'OnAfterNewReturnShptLineInsert', '', true, true)]
    procedure OnAfterNewReturnShptLineInsert(NewReturnShipmentLine: Record "Return Shipment Line"; OldReturnShipmentLine: Record "Return Shipment Line")
    begin

        ExtraChargeMgmt.CopyDocExtraCharge(Database::"Return Shipment Line", OldReturnShipmentLine."Document No.", OldReturnShipmentLine."Line No.",
        Database::"Return Shipment Line", NewReturnShipmentLine."Document No.", NewReturnShipmentLine."Line No.", -1);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6620, 'OnCopyPurchDocWithoutHeader', '', true, true)]
    procedure OnCopyPurchDocWithoutHeader(ToPurchaseHeader: Record "Purchase Header")
    var
        FromPurchHeader: Record "Purchase Header";
        ExtraChargeFN: Codeunit "EN Extra Charge Functions";
    begin
        ToPurchaseHeader.TransferFields(FromPurchHeader, false);
        ExtraChargeFN.CopyFromPurchECToHeader(ToPurchaseHeader, FromPurchHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6620, 'OnCopyPurchDocOnBeforeCopyPurchDocRcptLine', '', true, true)]
    procedure OnCopyPurchDocOnBeforeCopyPurchDocRcptLine(ToPurchaseHeader: Record "Purchase Header"; var FromPurchRcptHeader: Record "Purch. Rcpt. Header")
    var
        TableID: Integer;
        DocNo: Code[20];
        ExtraChargeFN: Codeunit "EN Extra Charge Functions";
    begin
        TableID := Database::"Purch. Rcpt. Header";
        DocNo := FromPurchRcptHeader."No.";
        ExtraChargeFN.CopyFromPstdPurchECToHeader(ToPurchaseHeader, TableID, DocNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6620, 'OnCopyPurchDocOnBeforeCopyPurchDocInvLine', '', true, true)]
    procedure OnCopyPurchDocOnBeforeCopyPurchDocInvLine(ToPurchaseHeader: Record "Purchase Header"; var FromPurchInvHeader: Record "Purch. Inv. Header")
    var
        TableID: Integer;
        DocNo: Code[20];
        ExtraChargeFN: Codeunit "EN Extra Charge Functions";
    begin
        TableID := Database::"Purch. Inv. Header";
        DocNo := FromPurchInvHeader."No.";
        ExtraChargeFN.CopyFromPstdPurchECToHeader(ToPurchaseHeader, TableID, DocNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6620, 'OnCopyPurchDocOnBeforeCopyPurchDocReturnShptLine', '', true, true)]
    procedure OnCopyPurchDocOnBeforeCopyPurchDocReturnShptLine(ToPurchaseHeader: Record "Purchase Header"; var FromReturnShipmentHeader: Record "Return Shipment Header")
    var
        TableID: Integer;
        DocNo: Code[20];
        ExtraChargeFN: Codeunit "EN Extra Charge Functions";
    begin
        TableID := Database::"Return Shipment Header";
        DocNo := FromReturnShipmentHeader."No.";
        ExtraChargeFN.CopyFromPstdPurchECToHeader(ToPurchaseHeader, TableID, DocNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6620, 'OnCopyPurchDocOnBeforeCopyPurchDocCrMemoLine', '', true, true)]
    procedure OnCopyPurchDocOnBeforeCopyPurchDocCrMemoLine(ToPurchaseHeader: Record "Purchase Header"; var FromPurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    var
        TableID: Integer;
        DocNo: Code[20];
        ExtraChargeFN: Codeunit "EN Extra Charge Functions";
    begin
        TableID := Database::"Purch. Cr. Memo Hdr.";
        DocNo := FromPurchCrMemoHdr."No.";
        ExtraChargeFN.CopyFromPstdPurchECToHeader(ToPurchaseHeader, TableID, DocNo);
    end;

    var
        ExtraCharge: Boolean;
        ExtraChargeFunction: Codeunit "EN Extra Charge Functions";
        ExtraChargeMgmt: Codeunit "EN Extra Charge Management";

        Currency: Record Currency;

        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        DocExtraCharge: Record "EN Document Extra Charge";
        CalledFromItemPosting: Boolean;
        RunOnlyCheck: Boolean;
        CalledFromTestReport: Boolean;
        ENInventoryPostingToGL: Codeunit "EN Inventory Posting To G/L";
        ECToPost: Record "EN Extra Charge Posting Buffer" temporary;

        AdditionalPostingCode: Code[20];
        InvtSetup: Record "Inventory Setup";

}