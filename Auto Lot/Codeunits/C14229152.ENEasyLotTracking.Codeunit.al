/// <summary>
/// Codeunit Easy Lot Tracking ELA (ID 14229152).
/// </summary>
codeunit 14229152 "Easy Lot Tracking ELA"
{

    trigger OnRun()
    begin
    end;

    var
        Item: Record Item;
        GlobalTrackingSpec: Record "Tracking Specification";
        HandledField: Text[80];
        QtyHandled: Decimal;
        SourceOutstandingQtyBase: Decimal;
        TrackingDate: Date;
        TrackingFormRunMode: Integer;
        Text001: Label '%1 must be zero.';
        LookupAllowed: Code[10];
        Text002: Label 'Do you want to assign a %1?';
        AssignmentAllowed: Code[10];
        SecondSourceRowID: Text[100];
        Text003: Label '&Lookup %1,&Assign %1';
        NewLotNo: Code[50];
        xNewLotNo: Code[50];
        NewLotStatusCode: Code[10];
        xNewLotStatusCode: Code[10];
        GlobalApplyFromEntryNo: Integer;
        SupplierLotNo: Code[50];
        xSupplierLotNo: Code[50];
        LotCreationDate: Date;
        xLotCreationDate: Date;
        CountryOfOrigin: Code[10];
        xCountryOfOrigin: Code[10];
        LotNoData: Record "EN Lot No. Data ELA";
        P800Globals: Codeunit "Process 800 System Globals ELA";
    /// <summary>
    /// TestSalesLine.
    /// </summary>
    /// <param name="SalesLine">Record "Sales Line".</param>
    [Scope('Internal')]
    procedure TestSalesLine(SalesLine: Record "Sales Line")
    begin
        SalesLine.TestField(SalesLine.Type, SalesLine.Type::Item);
        SalesLine.TestField("No.");
        Item.Get(SalesLine."No.");
        Item.TestField("Item Tracking Code");
    end;

    /// <summary>
    /// SetSalesLine.
    /// </summary>
    /// <param name="SalesLine">Record "Sales Line".</param>
    [Scope('Internal')]
    procedure SetSalesLine(SalesLine: Record "Sales Line")
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        Clear(GlobalTrackingSpec);
        GlobalTrackingSpec.InitFromSalesLine(SalesLine);
        TrackingDate := SalesLine."Shipment Date";
        LotNoData.InitializeFromSourceRecord(SalesLine, false);
        TrackingFormRunMode := 2;
        if SalesLine."Drop Shipment" and (SalesLine."Purchase Order No." <> '') then begin
            TrackingFormRunMode := 3;
            SecondSourceRowID := ItemTrackingMgt.ComposeRowID(DATABASE::"Purchase Line", 1,
              SalesLine."Purchase Order No.", '', 0, SalesLine."Purch. Order Line No.");
        end;
        case SalesLine."Document Type" of
            SalesLine."Document Type"::Order, SalesLine."Document Type"::Invoice:
                begin
                    HandledField := SalesLine.FieldCaption("Quantity Shipped");
                    QtyHandled := SalesLine."Qty. Shipped (Base)";
                    LookupAllowed := 'ALWAYS';
                    AssignmentAllowed := 'NEVER';
                end;
            SalesLine."Document Type"::"Return Order", SalesLine."Document Type"::"Credit Memo":
                begin
                    HandledField := SalesLine.FieldCaption("Return Qty. Received");
                    QtyHandled := SalesLine."Return Qty. Received (Base)";
                    LookupAllowed := '';
                    AssignmentAllowed := 'ALWAYS';
                end;
        end;
        SourceOutstandingQtyBase := SalesLine."Outstanding Qty. (Base)";
    end;

    /// <summary>
    /// TestPurchaseLine.
    /// </summary>
    /// <param name="PurchaseLine">Record "Purchase Line".</param>
    procedure TestPurchaseLine(PurchaseLine: Record "Purchase Line")
    begin

        PurchaseLine.TestField(Type, PurchaseLine.Type::Item);
        PurchaseLine.TestField("No.");
        Item.Get(PurchaseLine."No.");
    end;

    /// <summary>
    /// SetPurchaseLine.
    /// </summary>
    /// <param name="PurchaseLine">Record "Purchase Line".</param>

    procedure SetPurchaseLine(PurchaseLine: Record "Purchase Line")
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        Clear(GlobalTrackingSpec);
        GlobalTrackingSpec.InitFromPurchLine(PurchaseLine);
        TrackingDate := PurchaseLine."Expected Receipt Date";
        LotNoData.InitializeFromSourceRecord(PurchaseLine, false);
        TrackingFormRunMode := 2;
        if PurchaseLine."Drop Shipment" and (PurchaseLine."Sales Order No." <> '') then begin
            TrackingFormRunMode := 3;
            SecondSourceRowID := ItemTrackingMgt.ComposeRowID(DATABASE::"Sales Line", 1,
             PurchaseLine."Sales Order No.", '', 0, PurchaseLine."Sales Order Line No.");
        end;

        case PurchaseLine."Document Type" of
            PurchaseLine."Document Type"::Order, PurchaseLine."Document Type"::Invoice:
                begin
                    HandledField := PurchaseLine.FieldCaption("Quantity Received");
                    QtyHandled := PurchaseLine."Qty. Received (Base)";
                    LookupAllowed := '';
                    AssignmentAllowed := 'ALWAYS';
                end;
            PurchaseLine."Document Type"::"Return Order", PurchaseLine."Document Type"::"Credit Memo":
                begin
                    HandledField := PurchaseLine.FieldCaption("Return Qty. Shipped");
                    QtyHandled := PurchaseLine."Return Qty. Shipped (Base)";
                    LookupAllowed := 'ALWAYS';
                    AssignmentAllowed := 'NEVER';
                end;
        end;
        SourceOutstandingQtyBase := PurchaseLine."Outstanding Qty. (Base)";
    end;


    /// <summary>
    /// TestItemJnlLine.
    /// </summary>
    /// <param name="ItemJnlLine">Record "Item Journal Line".</param>
    procedure TestItemJnlLine(ItemJnlLine: Record "Item Journal Line")
    begin
        ItemJnlLine.TestField("Item No.");
        Item.Get(ItemJnlLine."Item No.");
        Item.TestField("Item Tracking Code");
    end;
    /// <summary>
    /// SetItemJnlLine.
    /// </summary>
    /// <param name="ItemJnlLine">Record "Item Journal Line".</param>
    /// <param name="FldNo">Integer.</param>
    procedure SetItemJnlLine(ItemJnlLine: Record "Item Journal Line"; FldNo: Integer)
    begin
        Clear(GlobalTrackingSpec);
        GlobalTrackingSpec.InitFromItemJnlLine(ItemJnlLine);
        TrackingDate := ItemJnlLine."Posting Date";
        LotNoData.InitializeFromSourceRecord(ItemJnlLine, false);
        if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer then
            TrackingFormRunMode := 1;

        case ItemJnlLine."Entry Type" of
            ItemJnlLine."Entry Type"::Sale, ItemJnlLine."Entry Type"::"Negative Adjmt.", ItemJnlLine."Entry Type"::Consumption:
                if ItemJnlLine.Quantity >= 0 then begin
                    LookupAllowed := 'ALWAYS';
                    AssignmentAllowed := 'NEVER';
                end else begin
                    LookupAllowed := '';
                    AssignmentAllowed := 'ALWAYS';
                end;
            ItemJnlLine."Entry Type"::"Positive Adjmt.":
                if ItemJnlLine.Quantity >= 0 then begin
                    LookupAllowed := 'ALWAYS';
                    AssignmentAllowed := '';
                end else begin
                    LookupAllowed := 'ALWAYS';
                    AssignmentAllowed := 'NEVER';
                end;

            ItemJnlLine."Entry Type"::Transfer:
                case FldNo of
                    ItemJnlLine.FieldNo("Lot No."):
                        begin
                            LookupAllowed := 'ALWAYS';
                            AssignmentAllowed := 'NEVER';
                        end;
                    ItemJnlLine.FieldNo("New Lot No."):
                        begin
                            LookupAllowed := '';
                            AssignmentAllowed := 'ALWAYS';
                        end;
                end;

            else
                if ItemJnlLine.Quantity >= 0 then begin
                    LookupAllowed := '';
                    AssignmentAllowed := 'ALWAYS';
                end else begin
                    LookupAllowed := 'ALWAYS';
                    AssignmentAllowed := 'NEVER';
                end;
        end;

        SourceOutstandingQtyBase := ItemJnlLine."Quantity (Base)";
    end;
    /// <summary>
    /// SetNewLotNo.
    /// </summary>
    /// <param name="xLotNo">Code[20].</param>
    /// <param name="LotNo">Code[50].</param>
    procedure SetNewLotNo(xLotNo: Code[20]; LotNo: Code[50])
    begin

        xNewLotNo := xLotNo;
        NewLotNo := LotNo;
    end;
    /// <summary>
    /// SetNewLotStatus.
    /// </summary>
    /// <param name="xLotStatus">Code[10].</param>
    /// <param name="LotStatus">Code[10].</param>
    procedure SetNewLotStatus(xLotStatus: Code[10]; LotStatus: Code[10])
    begin

        xNewLotStatusCode := xLotStatus;
        NewLotStatusCode := LotStatus;
    end;
    /// <summary>
    /// TestTransferLine.
    /// </summary>
    /// <param name="TransLine">Record "Transfer Line".</param>
    [Scope('Internal')]
    procedure TestTransferLine(TransLine: Record "Transfer Line")
    begin
        TransLine.TestField("Item No.");
        Item.Get(TransLine."Item No.");
        Item.TestField("Item Tracking Code");
    end;


    /// <summary>
    /// SetTransferLine.
    /// </summary>
    /// <param name="TransLine">Record "Transfer Line".</param>
    /// <param name="Direction">Option Outbound,Inbound.</param>
    procedure SetTransferLine(TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound)
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        TrackingDate := TransLine."Shipment Date";
        Clear(GlobalTrackingSpec);
        GlobalTrackingSpec.InitFromTransLine(TransLine, TrackingDate, Direction);

        TrackingFormRunMode := 3;
        SecondSourceRowID := ItemTrackingMgt.ComposeRowID(DATABASE::"Transfer Line", 1,
          TransLine."Document No.", '', 0, TransLine."Line No.");

        HandledField := TransLine.FieldCaption("Quantity Shipped");
        QtyHandled := TransLine."Qty. Shipped (Base)";
        LookupAllowed := 'ALWAYS';
        AssignmentAllowed := 'NEVER';
        SourceOutstandingQtyBase := TransLine."Quantity (Base)";
    end;

    /// <summary>
    /// TestProdOrderLine.
    /// </summary>
    /// <param name="ProdOrderLine">Record "Prod. Order Line".</param>
    [Scope('Internal')]
    procedure TestProdOrderLine(ProdOrderLine: Record "Prod. Order Line")
    begin
        ProdOrderLine.TestField("Item No.");
        Item.Get(ProdOrderLine."Item No.");
        Item.TestField("Item Tracking Code");
    end;

    /// <summary>
    /// SetProdOrderLine.
    /// </summary>
    /// <param name="ProdOrderLine">Record "Prod. Order Line".</param>
    procedure SetProdOrderLine(ProdOrderLine: Record "Prod. Order Line")
    begin
        Clear(GlobalTrackingSpec);
        GlobalTrackingSpec.InitFromProdOrderLine(ProdOrderLine);
        TrackingDate := ProdOrderLine."Due Date";
        LotNoData.InitializeFromSourceRecord(ProdOrderLine, false);
        LookupAllowed := '';
        AssignmentAllowed := 'ALWAYS';
        SourceOutstandingQtyBase := ProdOrderLine."Remaining Qty. (Base)";
    end;

    /// <summary>
    /// TestProdOrderComp.
    /// </summary>
    /// <param name="ProdOrderComp">Record "Prod. Order Component".</param>
    [Scope('Internal')]
    procedure TestProdOrderComp(ProdOrderComp: Record "Prod. Order Component")
    begin
        ProdOrderComp.TestField("Item No.");
        Item.Get(ProdOrderComp."Item No.");
        Item.TestField("Item Tracking Code");
    end;

    /// <summary>
    /// SetProdOrderComp.
    /// </summary>
    /// <param name="ProdOrderComp">Record "Prod. Order Component".</param>
    [Scope('Internal')]
    procedure SetProdOrderComp(ProdOrderComp: Record "Prod. Order Component")
    begin
        Clear(GlobalTrackingSpec);
        GlobalTrackingSpec.InitFromProdOrderComp(ProdOrderComp);
        TrackingDate := ProdOrderComp."Due Date";
        LookupAllowed := 'ALWAYS';
        AssignmentAllowed := 'NEVER';
        SourceOutstandingQtyBase := ProdOrderComp."Remaining Qty. (Base)";
    end;

    /// <summary>
    /// GetLotNo.
    /// </summary>
    /// <returns>Return variable LotNo of type Code[50].</returns>

    procedure GetLotNo() LotNo: Code[50]
    var
        ResEntry: Record "Reservation Entry";
        TrackingSpec: Record "Tracking Specification";
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedgerEntry: Record "Item Ledger Entry";
        NewLotNo: Code[50];
    begin
        ResEntry.SetCurrentKey(                                                                    // P8000448B
          "Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.", "Serial No."); // P8000448B
        ResEntry.SetRange("Source Type", GlobalTrackingSpec."Source Type");
        ResEntry.SetRange("Source Subtype", GlobalTrackingSpec."Source Subtype");
        ResEntry.SetRange("Source ID", GlobalTrackingSpec."Source ID");
        ResEntry.SetRange("Source Batch Name", GlobalTrackingSpec."Source Batch Name");
        ResEntry.SetRange("Source Prod. Order Line", GlobalTrackingSpec."Source Prod. Order Line");
        ResEntry.SetRange("Source Ref. No.", GlobalTrackingSpec."Source Ref. No.");
        ResEntry.SetFilter("Lot No.", '<>%1&<>%2', '', LotNo);
        if ResEntry.Find('-') then begin
            LotNo := ResEntry."Lot No.";
            SupplierLotNo := ResEntry."Supplier Lot No. ELA";
            LotCreationDate := ResEntry."Lot Creation Date ELA";
            CountryOfOrigin := ResEntry."Country/Regn of Orign Code ELA";
            ResEntry.SetFilter("Lot No.", '<>%1&<>%2', '', LotNo);
            if ResEntry.Find('-') then;
            exit(P800Globals.MultipleLotCode);

            if (GlobalTrackingSpec."Source Type" = DATABASE::"Item Journal Line") and
              (GlobalTrackingSpec."Source Subtype" = 4)
            then begin
                ResEntry.SetRange("Lot No.");
                ResEntry.SetFilter("New Lot No.", '<>%1&<>%2', '', NewLotNo);
                if ResEntry.Find('-') then begin
                    NewLotNo := ResEntry."New Lot No.";
                    ResEntry.SetFilter("New Lot No.", '<>%1&<>%2', '', NewLotNo);
                    if ResEntry.Find('-') then;
                    exit(P800Globals.MultipleLotCode);
                end;
            end;

        end;

        if GlobalTrackingSpec."Source Type" in [DATABASE::"Sales Line", DATABASE::"Purchase Line"] then begin
            TrackingSpec.SetCurrentKey("Source ID", "Source Type", "Source Subtype",
              "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.");

            TrackingSpec.SetRange("Source Type", GlobalTrackingSpec."Source Type");
            TrackingSpec.SetRange("Source Subtype", GlobalTrackingSpec."Source Subtype");
            TrackingSpec.SetRange("Source ID", GlobalTrackingSpec."Source ID");
            TrackingSpec.SetRange("Source Batch Name", GlobalTrackingSpec."Source Batch Name");
            TrackingSpec.SetRange("Source Prod. Order Line", GlobalTrackingSpec."Source Prod. Order Line");
            TrackingSpec.SetRange("Source Ref. No.", GlobalTrackingSpec."Source Ref. No.");
            TrackingSpec.SetFilter("Lot No.", '<>%1&<>%2', '', LotNo);
            if TrackingSpec.Find('-') then
                if LotNo = '' then begin
                    LotNo := TrackingSpec."Lot No.";
                    SupplierLotNo := TrackingSpec."Supplier Lot No. ELA";
                    LotCreationDate := TrackingSpec."Lot Creation Date ELA";
                    CountryOfOrigin := TrackingSpec."Country/Regn of Orign Code ELA";
                    TrackingSpec.SetFilter("Lot No.", '<>%1&<>%2', '', LotNo);
                    if TrackingSpec.Find('-') then;
                    exit(P800Globals.MultipleLotCode);
                end else
                    exit(P800Globals.MultipleLotCode);
        end;


        if GlobalTrackingSpec."Source Type" = DATABASE::"Transfer Line" then begin
            ItemEntryRelation.SetCurrentKey("Order No.", "Order Line No.");
            ItemEntryRelation.SetRange("Source Type", DATABASE::"Transfer Shipment Line");
            ItemEntryRelation.SetRange("Order No.", GlobalTrackingSpec."Source ID");
            ItemEntryRelation.SetRange("Order Line No.", GlobalTrackingSpec."Source Ref. No.");
            if ItemEntryRelation.Find('-') then
                repeat
                    ItemLedgerEntry.Get(ItemEntryRelation."Item Entry No.");
                    if LotNo = '' then
                        LotNo := ItemLedgerEntry."Lot No."
                    else
                        if LotNo <> ItemLedgerEntry."Lot No." then;
                    exit(P800Globals.MultipleLotCode);
                until ItemEntryRelation.Next = 0;
        end;
    end;
    /// <summary>
    /// GetNewLotNo.
    /// </summary>
    /// <param name="NewLotStatus">VAR Code[10].</param>
    /// <returns>Return variable NewLotNo of type Code[50].</returns>
    [Scope('Internal')]
    procedure GetNewLotNo(var NewLotStatus: Code[10]) NewLotNo: Code[50]
    var
        ResEntry: Record "Reservation Entry";
        LotNo: Code[50];
    begin

        ResEntry.SetCurrentKey(                                                                    // P8000448B
          "Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.", "Serial No."); // P8000448B
        ResEntry.SetRange("Source Type", GlobalTrackingSpec."Source Type");
        ResEntry.SetRange("Source Subtype", GlobalTrackingSpec."Source Subtype");
        ResEntry.SetRange("Source ID", GlobalTrackingSpec."Source ID");
        ResEntry.SetRange("Source Batch Name", GlobalTrackingSpec."Source Batch Name");
        ResEntry.SetRange("Source Prod. Order Line", GlobalTrackingSpec."Source Prod. Order Line");
        ResEntry.SetRange("Source Ref. No.", GlobalTrackingSpec."Source Ref. No.");
        ResEntry.SetFilter("New Lot No.", '<>%1&<>%2', '', NewLotNo);
        if ResEntry.Find('-') then begin
            NewLotNo := ResEntry."New Lot No.";
            NewLotStatus := ResEntry."New Lot Status Code ELA";
            ResEntry.SetFilter("New Lot No.", '<>%1&<>%2', '', NewLotNo);
            if ResEntry.Find('-') then begin
                NewLotStatus := P800Globals.MultipleLotCode;
                exit(P800Globals.MultipleLotCode);
            end;
            if (GlobalTrackingSpec."Source Type" = DATABASE::"Item Journal Line") and
              (GlobalTrackingSpec."Source Subtype" = 4)
            then begin
                ResEntry.SetRange("New Lot No.");
                ResEntry.SetFilter("Lot No.", '<>%1&<>%2', '', LotNo);
                if ResEntry.Find('-') then begin
                    LotNo := ResEntry."Lot No.";
                    ResEntry.SetFilter("Lot No.", '<>%1&<>%2', '', LotNo);
                    if ResEntry.Find('-') then begin
                        NewLotStatus := P800Globals.MultipleLotCode;
                        exit(P800Globals.MultipleLotCode);
                    end;
                end;
            end;
        end;
    end;

    /// <summary>
    /// ReplaceTracking.
    /// </summary>
    /// <param name="xLotNo">Code[50].</param>
    /// <param name="LotNo">Code[50].</param>
    /// <param name="AltQtyTransNo">Integer.</param>
    /// <param name="Qty">Decimal.</param>
    /// <param name="QtyToHandle">Decimal.</param>
    /// <param name="QtyToHandleAlt">Decimal.</param>
    /// <param name="QtyToInvoice">Decimal.</param>
    procedure ReplaceTracking(xLotNo: Code[50]; LotNo: Code[50]; AltQtyTransNo: Integer; Qty: Decimal; QtyToHandle: Decimal; QtyToHandleAlt: Decimal; QtyToInvoice: Decimal)
    begin

        ProcessTracking(xLotNo, LotNo, AltQtyTransNo, Qty, QtyToHandle, QtyToHandleAlt, QtyToInvoice, 'REPLACE');
    end;
    /// <summary>
    /// UpdateTracking.
    /// </summary>
    /// <param name="xLotNo">Code[50].</param>
    /// <param name="LotNo">Code[50].</param>
    /// <param name="AltQtyTransNo">Integer.</param>
    /// <param name="Qty">Decimal.</param>
    /// <param name="QtyToHandle">Decimal.</param>
    /// <param name="QtyToHandleAlt">Decimal.</param>
    /// <param name="QtyToInvoice">Decimal.</param>
    [Scope('Internal')]
    procedure UpdateTracking(xLotNo: Code[50]; LotNo: Code[50]; AltQtyTransNo: Integer; Qty: Decimal; QtyToHandle: Decimal; QtyToHandleAlt: Decimal; QtyToInvoice: Decimal)
    begin

        ProcessTracking(xLotNo, LotNo, AltQtyTransNo, Qty, QtyToHandle, QtyToHandleAlt, QtyToInvoice, 'UPDATE');
    end;

    /// <summary>
    /// ProcessTracking.
    /// </summary>
    /// <param name="xLotNo">Code[50].</param>
    /// <param name="LotNo">Code[50].</param>
    /// <param name="AltQtyTransNo">Integer.</param>
    /// <param name="Qty">Decimal.</param>
    /// <param name="QtyToHandle">Decimal.</param>
    /// <param name="QtyToHandleAlt">Decimal.</param>
    /// <param name="QtyToInvoice">Decimal.</param>
    /// <param name="Mode">Code[10].</param>
    procedure ProcessTracking(xLotNo: Code[50]; LotNo: Code[50]; AltQtyTransNo: Integer; Qty: Decimal; QtyToHandle: Decimal; QtyToHandleAlt: Decimal; QtyToInvoice: Decimal; Mode: Code[10])
    var
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        ItemTrackingForm: Page "EN LT ItemTrackLineISV EXT ELA";
        ApplyFromEntryNo: Integer;
    begin

        ApplyFromEntryNo := GlobalApplyFromEntryNo;
        GlobalApplyFromEntryNo := 0;

        if (LotNo = '') and (xLotNo = '') and (NewLotNo = '') and (xNewLotNo = '') and
          (SupplierLotNo = '') and (xSupplierLotNo = '') and
          (LotCreationDate = 0D) and (xLotCreationDate = 0D) and
          (CountryOfOrigin = '') and (xCountryOfOrigin = '') and
          (NewLotStatusCode = '') and (xNewLotStatusCode = '')
        then
            exit;

        if (xLotNo <> '') and (LotNo <> xLotNo) and (QtyHandled <> 0) then
            Error(Text001, HandledField);

        TempTrackingSpecification.Init;
        TempTrackingSpecification."Lot No." := LotNo;
        TempTrackingSpecification."New Lot No." := NewLotNo;
        TempTrackingSpecification."New Lot Status Code ELA" := NewLotStatusCode;
        TempTrackingSpecification."Supplier Lot No. ELA" := SupplierLotNo;
        TempTrackingSpecification."Lot Creation Date ELA" := LotCreationDate;
        TempTrackingSpecification."Country/Regn of Orign Code ELA" := CountryOfOrigin;
        TempTrackingSpecification.Validate("Quantity (Base)", Qty);
        TempTrackingSpecification."Qty. to Handle (Base)" := QtyToHandle;
        TempTrackingSpecification."Qty. to Invoice (Base)" := QtyToInvoice;
        if GlobalTrackingSpec."Source Type" = DATABASE::"Item Journal Line" then;
        TempTrackingSpecification."Quantity (Alt.) ELA" := QtyToHandleAlt;
        TempTrackingSpecification."Qty. to Handle (Alt.) ELA" := QtyToHandleAlt;
        TempTrackingSpecification."Appl.-from Item Entry" := ApplyFromEntryNo;
        TempTrackingSpecification.InitExpirationDate;
        TempTrackingSpecification.Insert;

        ItemTrackingForm.SetFormRunMode(TrackingFormRunMode);

        if TrackingFormRunMode = 3 then
            ItemTrackingForm.SetSecondSourceRowID(SecondSourceRowID);

        ItemTrackingForm.SetBlockCommit(true);
        ItemTrackingForm.SetSourceSpec(GlobalTrackingSpec, TrackingDate);
        ItemTrackingForm.RegisterP800Tracking(TempTrackingSpecification, Mode);
        if TrackingFormRunMode = 3 then
            UpdateLinkedLine(SecondSourceRowID);

        if AltQtyTransNo <> 0 then begin
        end;

    end;

    /// <summary>
    /// UpdateLinkedLine.
    /// </summary>
    /// <param name="RowID">Text[100].</param>
    procedure UpdateLinkedLine(RowID: Text[100])
    var
        ResEntry: Record "Reservation Entry";
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
    begin
        ResEntry.SetPointer(RowID);
        case ResEntry."Source Type" of
            DATABASE::"Sales Line":
                begin
                    SalesLine.Get(ResEntry."Source Subtype", ResEntry."Source ID", ResEntry."Source Ref. No.");
                    SalesLine.GetLotNo;
                    SalesLine.Modify;
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchLine.Get(ResEntry."Source Subtype", ResEntry."Source ID", ResEntry."Source Ref. No.");
                    PurchLine.GetLotNo;
                    PurchLine.Modify;
                end;
        end;
    end;
    /// <summary>
    /// AssistEdit.
    /// </summary>
    /// <param name="LotNo">VAR Code[50].</param>
    /// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure AssistEdit(var LotNo: Code[50]): Boolean
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        LotNoInfo: Record "Lot No. Information";
        ResEntry: Record "Reservation Entry";
        P800Functions: Codeunit "Process 800 Functions ELA";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemTrackingDCMgt: Codeunit "Item Tracking Data Collection";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        CurrentSignFactor: Integer;
        MaxQty: Decimal;
        Lookup: Boolean;
        Assign: Boolean;
        DefaultAction: Integer;
    begin
        if not P800Functions.TrackingInstalled then
            exit;
        if LotNo = P800Globals.MultipleLotCode then
            exit(false);

        if LotNo <> '' then begin
            LotNoInfo.SetRange("Item No.", GlobalTrackingSpec."Item No.");
            LotNoInfo.SetRange("Variant Code", GlobalTrackingSpec."Variant Code");
            LotNoInfo.SetRange("Lot No.", LotNo);
            PAGE.RunModal(PAGE::"Lot No. Information Card", LotNoInfo);
            exit(false);
        end;

        Item.Get(GlobalTrackingSpec."Item No.");
        ItemTrackingCode.Get(Item."Item Tracking Code");


        if LookupAllowed = 'ALWAYS' then begin
            Lookup := true;
            DefaultAction := 1;
        end;
        if (LookupAllowed = '') and ItemTrackingCode."Allow Loose Lot Control ELA" then
            Lookup := true;
        if AssignmentAllowed = 'ALWAYS' then begin
            Assign := true;
            DefaultAction := 2;
        end;
        if (AssignmentAllowed = '') and ItemTrackingCode."Allow Loose Lot Control ELA" then
            Assign := true;
        if Assign and Lookup then begin
            case StrMenu(StrSubstNo(Text003, GlobalTrackingSpec.FieldCaption("Lot No.")), DefaultAction) of
                0:
                    exit(false);
                1:
                    Assign := false;
                2:
                    Lookup := false;
            end;
        end else
            if Assign then
                if not Confirm(Text002, false, GlobalTrackingSpec.FieldCaption("Lot No.")) then
                    exit(false);


        if Lookup then begin
            ResEntry."Source Type" := GlobalTrackingSpec."Source Type";
            ResEntry."Source Subtype" := GlobalTrackingSpec."Source Subtype";
            CurrentSignFactor := CreateReservEntry.SignFactor(ResEntry);
            MaxQty := SourceOutstandingQtyBase;
            ItemTrackingDCMgt.AssistEditTrackingNo(GlobalTrackingSpec, true, CurrentSignFactor, 1, MaxQty); // P8000466A
            LotNo := GlobalTrackingSpec."Lot No.";
            exit(LotNo <> '');
        end;
        if Assign then begin
            LotNo := LotNoData.AssignLotNo;
            exit(true);
        end;
    end;

    local procedure SkipWhseTrackingUpdate(): Boolean
    var
        Location: Record Location;
    begin
        if IsWhseShptSource(GlobalTrackingSpec) then BEGIN
            if Location.Get(GlobalTrackingSpec."Location Code") then
                exit(Location."Require Shipment" and Location."Require Pick");
        end;
        exit(false);

    end;

    local procedure IsWhseShptSource(var SourceSpecification2: Record "Tracking Specification"): Boolean
    begin
        case SourceSpecification2."Source Type" of
            DATABASE::"Sales Line":
                exit(SourceSpecification2."Source Subtype" = 1);
            DATABASE::"Purchase Line":
                exit(SourceSpecification2."Source Subtype" = 5);
            DATABASE::"Transfer Line":
                exit(SourceSpecification2."Source Subtype" = 0);
        end;
        exit(false);

    end;
    /// <summary>
    /// SetApplyFromEntryNo.
    /// </summary>
    /// <param name="EntryNo">Integer.</param>
    [Scope('Internal')]
    procedure SetApplyFromEntryNo(EntryNo: Integer)
    begin

        GlobalApplyFromEntryNo := EntryNo;
    end;

    /// <summary>
    /// SetSupplierLotNo.
    /// </summary>
    /// <param name="xNewSupplierLotNo">Code[50].</param>
    /// <param name="NewSupplierLotNo">Code[50].</param>
    procedure SetSupplierLotNo(xNewSupplierLotNo: Code[50]; NewSupplierLotNo: Code[50])
    begin

        xSupplierLotNo := xNewSupplierLotNo;
        SupplierLotNo := NewSupplierLotNo;
    end;
    /// <summary>
    /// GetSupplierLotNo.
    /// </summary>
    /// <param name="LotNo">Code[50].</param>
    /// <returns>Return value of type Code[50].</returns>

    procedure GetSupplierLotNo(LotNo: Code[50]): Code[50]
    begin
        if (LotNo <> '') then
            if (LotNo = P800Globals.MultipleLotCode) then
                exit('');
        exit(SupplierLotNo);
    end;

    /// <summary>
    /// SetLotCreationDate.
    /// </summary>
    /// <param name="xNewLotCreationDate">Date.</param>
    /// <param name="NewLotCreationDate">Date.</param>
    procedure SetLotCreationDate(xNewLotCreationDate: Date; NewLotCreationDate: Date)
    begin
        xLotCreationDate := xNewLotCreationDate;
        LotCreationDate := NewLotCreationDate;
    end;

    /// <summary>
    /// GetLotCreationDate.
    /// </summary>
    /// <param name="LotNo">Code[50].</param>
    /// <returns>Return value of type Date.</returns>
    procedure GetLotCreationDate(LotNo: Code[50]): Date
    begin
        if (LotNo <> '') then
            if (LotNo = P800Globals.MultipleLotCode) then
                exit(0D);
        exit(LotCreationDate);
    end;
    /// <summary>
    /// SetCountryOfOrigin.
    /// </summary>
    /// <param name="xNewCountryOfOrigin">Code[10].</param>
    /// <param name="NewCountryOfOrigin">Code[10].</param>
    procedure SetCountryOfOrigin(xNewCountryOfOrigin: Code[10]; NewCountryOfOrigin: Code[10])
    begin
        xCountryOfOrigin := xNewCountryOfOrigin;
        CountryOfOrigin := NewCountryOfOrigin;
    end;

    /// <summary>
    /// GetCountryOfOrigin.
    /// </summary>
    /// <param name="LotNo">Code[50].</param>
    /// <returns>Return value of type Code[10].</returns>
    procedure GetCountryOfOrigin(LotNo: Code[50]): Code[10]
    begin
        if (LotNo <> '') then
            if (LotNo = P800Globals.MultipleLotCode) then
                exit('');
        exit(CountryOfOrigin);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5750, 'OnAfterCreateShptLineFromSalesLine', '', true, false)]
    local procedure WhseCreateSourceDocument_OnAfterCreateShptLineFromSalesLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; WarehouseShipmentHeader: Record "Warehouse Shipment Header"; SalesLine: Record "Sales Line")
    begin

        WarehouseShipmentLine.SetLotQuantity(WarehouseShipmentLine.GetLotNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5763, 'OnAfterPostUpdateWhseShptLine', '', true, false)]
    local procedure WhsePostShipment_OnAfterPostUpdateWhseShptLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    begin
        WarehouseShipmentLine.SetLotQuantity(WarehouseShipmentLine.GetLotNo);
    end;
}

