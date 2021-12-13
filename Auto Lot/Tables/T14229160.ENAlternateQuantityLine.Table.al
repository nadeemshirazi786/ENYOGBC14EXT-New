table 14229160 "EN Alternate Quantity Line ELA"
{
    Caption = 'Alternate Quantity Line';
    fields
    {
        field(1; "Alt. Qty. Transaction No."; Integer)
        {
            Caption = 'Alt. Qty. Transaction No.';
            Editable = false;
        }
        field(2; "Table No."; Integer)
        {
            BlankZero = true;
            Caption = 'Table No.';
            Editable = false;
        }
        field(3; "Document Type"; Option)
        {
            Caption = 'Document Type';
            Editable = false;
            OptionMembers = " ","Order",Invoice,"Credit Memo",,"Return Order";
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(5; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            Editable = false;
        }
        field(6; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            Editable = false;
        }
        field(7; "Source Line No."; Integer)
        {
            Caption = 'Source Line No.';
            Editable = false;
        }
        field(8; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(9; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Description = 'PR3.61';

            trigger OnValidate()
            begin
                if "Container ID" <> '' then
                    Error(Text007);

                if ("Lot No." = '') then
                    exit;

                TestTrackingOn;
                if not CheckLotPreferences("Lot No.", true) then
                    Error(Text008, "Lot No.");

                if not SourceTrackingLine.Positive then begin
                    SetTrackingEntryFilters(ItemTrackingEntry);
                    SetLotSerialEntryFilters(ItemTrackingEntry, "Lot No.", '');
                    if not ItemTrackingEntry.Find('-') then
                        Error(Text001, FieldCaption("Lot No."), "Lot No.");
                end;


                if "Table No." = DATABASE::"Item Journal Line" then begin
                    GetSource;
                    if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer then
                        "New Lot No." := "Lot No.";
                end;

            end;
        }
        field(10; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            Description = 'PR3.61';

            trigger OnValidate()
            begin
                if "Container ID" <> '' then
                    Error(Text007);

                if ("Serial No." = '') then
                    exit;

                TestTrackingOn;

                if not SourceTrackingLine.Positive then begin
                    SetTrackingEntryFilters(ItemTrackingEntry);
                    SetLotSerialEntryFilters(ItemTrackingEntry, "Lot No.", "Serial No.");
                    if not ItemTrackingEntry.Find('-') then
                        Error(Text001, FieldCaption("Serial No."), "Serial No.");
                end;

                Validate("Quantity (Base)", 1);
            end;
        }
        field(11; "New Lot No."; Code[50])
        {
            Caption = 'New Lot No.';

            trigger OnValidate()
            var
                AltQtyLine: Record "EN Alternate Quantity Line ELA";
            begin

                if "New Lot No." <> '' then begin
                    TestTrackingOn;
                    if "Table No." <> DATABASE::"Item Journal Line" then
                        Error(Text010, FieldCaption("New Lot No."))
                    else begin
                        GetSource;
                        if ItemJnlLine."Entry Type" <> ItemJnlLine."Entry Type"::Transfer then
                            Error(Text010, FieldCaption("New Lot No."))
                    end;

                    AltQtyLine.SetCurrentKey("Alt. Qty. Transaction No.", "Serial No.", "Lot No.");
                    AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Transaction No.");
                    AltQtyLine.SetRange("Serial No.", "Serial No.");
                    AltQtyLine.SetRange("Lot No.", "Lot No.");
                    AltQtyLine.SetFilter("New Lot No.", '<>%1', "New Lot No.");
                    if not AltQtyLine.IsEmpty then
                        Error(Text011, TableCaption, FieldCaption("Lot No."), "Lot No.");
                end;
            end;
        }
        field(12; "Quantity (Base)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';

            trigger OnValidate()
            begin
                if "Container ID" <> '' then
                    Error(Text007);

                GetSource;
                Quantity := "Quantity (Base)" / BaseQtyPerEntryUOM;
                if (CurrFieldNo = FieldNo("Quantity (Base)")) then
                    ValidateQuantity;

                InitInvoicedQty;
            end;
        }
        field(13; "Quantity (Alt.)"; Decimal)
        {
            AutoFormatExpression = AutoFormatQtyAlt;
            AutoFormatType = 37002000;
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,2,0,%1,%2,%3,%4,%5,%6', "Table No.", "Document Type", "Document No.", "Journal Template Name", "Journal Batch Name", "Source Line No.");
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';

            trigger OnValidate()
            begin

            end;
        }
        field(14; "Invoiced Qty. (Base)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Invoiced Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(15; "Invoiced Qty. (Alt.)"; Decimal)
        {
            BlankZero = true;
            CaptionClass = StrSubstNo('37002080,2,6,%1,%2,%3,%4,%5,%6', "Table No.", "Document Type", "Document No.", "Journal Template Name", "Journal Batch Name", "Source Line No.");
            Caption = 'Invoiced Qty. (Alt.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(18; Quantity; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';

            trigger OnValidate()
            begin
                if "Container ID" <> '' then
                    Error(Text007);
                GetSource;

                "Quantity (Base)" := Quantity * BaseQtyPerEntryUOM;
                if (CurrFieldNo = FieldNo(Quantity)) then begin
                    TestSourceStatus;
                    ValidateQuantity;
                end;

                InitInvoicedQty;
            end;
        }
        field(37002562; "Container ID"; Code[20])
        {
            Caption = 'Container ID';

        }
        field(37002563; "Container Line No."; Integer)
        {
            Caption = 'Container Line No.';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Alt. Qty. Transaction No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = "Quantity (Base)", "Quantity (Alt.)";
        }
        key(Key2; "Table No.", "Document Type", "Document No.", "Journal Template Name", "Journal Batch Name", "Source Line No.", "Line No.")
        {
            SumIndexFields = "Quantity (Base)", "Quantity (Alt.)";
        }
        key(Key3; "Table No.", "Document Type", "Document No.", "Source Line No.", "Line No.")
        {
            SumIndexFields = "Quantity (Base)", "Quantity (Alt.)";
        }
        key(Key4; "Alt. Qty. Transaction No.", "Serial No.", "Lot No.")
        {
            SumIndexFields = "Quantity (Base)", "Quantity (Alt.)";
        }
        key(Key5; "Container ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if "Container ID" <> '' then
            Error(Text007);

        TestSourceStatus;
    end;

    var
        ItemJnlLine: Record "Item Journal Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchaseHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        //RepackOrder: Record "EN Repack Order";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        PhysInvtRecordLine: Record "Phys. Invt. Record Line";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingEntry: Record "Item Ledger Entry";
        SourceTrackingLine: Record "Reservation Entry";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        SourceRead: Boolean;
        TrackingSourceBuilt: Boolean;
        TrackingOn: Boolean;
        Text001: Label 'Unable to find %1 %2.';
        Text002: Label '%1 %2 is assigned to other entries.';
        Text003: Label 'Do you want to assign a new %1?';
        Text004: Label '%1 or %2 must be Yes in %3 %4.';
        Text005: Label 'Assign is not allowed for negative entries.';
        BaseQtyPerEntryUOM: Decimal;
        Text006: Label 'All %1s have been entered for %2 %3.';
        Text007: Label 'This line is associated with a container.';
        Text008: Label 'Lot %1 fails to meet established lot preferences.';
        Text009: Label 'Tracking is specified on %1.';
        Text010: Label '%1 is allowed only for reclassification.';
        Text011: Label '%1 already exists with %2 %3.';
        StatusCheckSuspended: Boolean;

    [Scope('Internal')]
    procedure ClearSource()
    begin

        Clear(SourceRead);
        Clear(TrackingSourceBuilt);
        Clear(SourceTrackingLine);
    end;

    local procedure TestSourceExists()
    begin
        if ("Source Line No." = 0) then
            Error(Text006, TableCaption, "Document Type", "Document No.");
    end;

    procedure ValidateQuantity()
    begin
        if ("Serial No." <> '') then
            TestField("Quantity (Base)", 1)
        else
            if ("Table No." <> DATABASE::"Item Journal Line") then
                TestField(Quantity)
            else
                if (Quantity = 0) then begin
                    ItemJnlLine.Get("Journal Template Name", "Journal Batch Name", "Source Line No.");
                    if (Abs(ItemJnlLine.Quantity) > 0) then
                        TestField(Quantity);
                end;
    end;


    procedure GetMaxDecimalPlaces(var NumDecimalPlaces: Integer): Boolean
    var
        UnitOfMeasure: Record "Unit of Measure";
        ColonPos: Integer;
    begin

    end;

    [Scope('Internal')]
    procedure SetUpNewLine(LastRec: Record "EN Alternate Quantity Line ELA"; TableNo: Integer; DocumentType: Integer; DocumentNo: Code[20]; TemplateName: Code[10]; BatchName: Code[10]; LineNo: Integer; QtyBase: Decimal)
    var
        AltQtyLine: Record "EN Alternate Quantity Line ELA";
        AvailQtyBase: Decimal;
    begin
        "Table No." := TableNo;
        "Document Type" := DocumentType;
        "Document No." := DocumentNo;
        "Journal Template Name" := TemplateName;
        "Journal Batch Name" := BatchName;
        "Source Line No." := LineNo;

        GetSource;

        AltQtyLine.SetRange("Alt. Qty. Transaction No.", "Alt. Qty. Transaction No.");
        AltQtyLine.CalcSums("Quantity (Base)");
        if (AltQtyLine."Quantity (Base)" < QtyBase) then begin
            if ("Serial No." <> '') then
                "Quantity (Base)" := 1
            else
                if DefaultToDetail() then
                    "Quantity (Base)" := BaseQtyPerEntryUOM
                else
                    "Quantity (Base)" := QtyBase - AltQtyLine."Quantity (Base)";
            Validate("Quantity (Base)");
        end;
    end;

    local procedure DefaultToDetail(): Boolean
    var
        InvtSetup: Record "Inventory Setup";
    begin

    end;


    procedure InitInvoicedQty()
    begin
        if ("Table No." = DATABASE::"Item Journal Line") then begin
            ItemJnlLine.Get("Journal Template Name", "Journal Batch Name", "Source Line No.");
            if (ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Output) then begin
                "Invoiced Qty. (Base)" := 0;
                "Invoiced Qty. (Alt.)" := 0;
            end else begin
                "Invoiced Qty. (Base)" := "Quantity (Base)";
                "Invoiced Qty. (Alt.)" := "Quantity (Alt.)";
            end;
        end;
    end;

    local procedure GetSource()
    var
        UOMMgmt: Codeunit "Unit of Measure Management";
        PickNo: Integer;
        RecordingNo: Integer;
    begin
        TestSourceExists;

        if SourceRead then
            exit;
        SourceRead := true;

        case "Table No." of
            DATABASE::"Item Journal Line":
                begin
                    ItemJnlLine.Get("Journal Template Name", "Journal Batch Name", "Source Line No.");
                    Item.Get(ItemJnlLine."Item No.");
                    BaseQtyPerEntryUOM :=
                      UOMMgmt.GetQtyPerUnitOfMeasure(Item, ItemJnlLine."Unit of Measure Code");
                end;
            DATABASE::"Sales Line":
                begin
                    SalesHeader.Get("Document Type", "Document No.");
                    SalesLine.Get("Document Type", "Document No.", "Source Line No.");
                    Item.Get(SalesLine."No.");
                    BaseQtyPerEntryUOM :=
                      UOMMgmt.GetQtyPerUnitOfMeasure(Item, SalesLine."Unit of Measure Code");
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchaseHeader.Get("Document Type", "Document No.");
                    PurchLine.Get("Document Type", "Document No.", "Source Line No.");
                    Item.Get(PurchLine."No.");
                    BaseQtyPerEntryUOM :=
                      UOMMgmt.GetQtyPerUnitOfMeasure(Item, PurchLine."Unit of Measure Code");
                end;

            DATABASE::"Transfer Line":
                begin
                    TransLine.Get("Document No.", "Source Line No.");
                    Item.Get(TransLine."Item No.");
                    BaseQtyPerEntryUOM :=
                      UOMMgmt.GetQtyPerUnitOfMeasure(Item, TransLine."Unit of Measure Code");
                end;
            DATABASE::"Warehouse Activity Line":
                begin
                    WarehouseActivityLine.Get("Document Type", "Document No.", "Source Line No.");
                    Item.Get(WarehouseActivityLine."Item No.");
                    BaseQtyPerEntryUOM :=
                      UOMMgmt.GetQtyPerUnitOfMeasure(Item, WarehouseActivityLine."Unit of Measure Code");
                end;
            DATABASE::"Phys. Invt. Record Line":
                begin
                    Evaluate(RecordingNo, "Journal Template Name");
                    PhysInvtRecordLine.Get("Document No.", RecordingNo, "Source Line No.");
                    Item.Get(PhysInvtRecordLine."Item No.");
                    BaseQtyPerEntryUOM :=
                      UOMMgmt.GetQtyPerUnitOfMeasure(Item, PhysInvtRecordLine."Unit of Measure Code");
                end;
        end;

        TrackingOn := false;
        if (Item."Item Tracking Code" <> '') then
            if ItemTrackingCode.Get(Item."Item Tracking Code") then
                if ItemTrackingCode."Lot Specific Tracking" or ItemTrackingCode."SN Specific Tracking" then
                    TrackingOn := true;

    end;

    local procedure BuildTrackingSource()
    begin
        TestSourceExists;

        if TrackingSourceBuilt then
            exit;
        TrackingSourceBuilt := true;

        GetSource;

        if not TrackingOn then
            exit;

        SourceTrackingLine.Init;
        SourceTrackingLine."Entry No." := 0;
        SourceTrackingLine."Item No." := Item."No.";
        SourceTrackingLine."Source Type" := "Table No.";
        SourceTrackingLine."Creation Date" := Today;
        SourceTrackingLine."Created By" := UserId;

        case "Table No." of
            DATABASE::"Item Journal Line":
                begin
                    SourceTrackingLine."Source ID" := "Journal Template Name";
                    SourceTrackingLine."Source Batch Name" := "Journal Batch Name";
                    SourceTrackingLine."Source Subtype" := ItemJnlLine."Entry Type";
                    SourceTrackingLine."Source Prod. Order Line" := ItemJnlLine."Order Line No."; // P8001132
                    SourceTrackingLine."Source Ref. No." := "Source Line No.";

                    SourceTrackingLine."Location Code" := ItemJnlLine."Location Code";
                    SourceTrackingLine."Variant Code" := ItemJnlLine."Variant Code";
                    SourceTrackingLine."Qty. per Unit of Measure" := ItemJnlLine."Qty. per Unit of Measure";


                    if (ItemJnlLine."Output Quantity" <> 0) then
                        SourceTrackingLine.Positive := (ItemJnlLine."Output Quantity (Base)" > 0)
                    else
                        if (ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer) then
                            SourceTrackingLine.Positive := false
                        else
                            if (ItemJnlLine."Quantity (Base)" <> 0) then
                                SourceTrackingLine.Positive := (ItemJnlLine.Signed(ItemJnlLine."Quantity (Base)") > 0)
                            else
                                if ItemJnlLine."Phys. Inventory" then
                                    SourceTrackingLine.Positive := false
                                else
                                    SourceTrackingLine.Positive := (ItemJnlLine.Signed(1) > 0);
                    if SourceTrackingLine.Positive then
                        SourceTrackingLine."Expected Receipt Date" := ItemJnlLine."Posting Date"
                    else
                        SourceTrackingLine."Shipment Date" := ItemJnlLine."Posting Date";

                    SourceTrackingLine.Validate("Quantity (Base)", ItemJnlLine."Quantity (Base)");
                end;
            DATABASE::"Sales Line":
                begin
                    SourceTrackingLine."Source Subtype" := "Document Type";
                    SourceTrackingLine."Source ID" := "Document No.";
                    SourceTrackingLine."Source Ref. No." := "Source Line No.";

                    SourceTrackingLine."Location Code" := SalesLine."Location Code";
                    SourceTrackingLine."Variant Code" := SalesLine."Variant Code";
                    SourceTrackingLine."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";

                    SourceTrackingLine.Positive := (SalesLine.SignedXX(SalesLine."Quantity (Base)") > 0);
                    if SourceTrackingLine.Positive then
                        SourceTrackingLine."Expected Receipt Date" := SalesLine."Planned Shipment Date"
                    else
                        SourceTrackingLine."Shipment Date" := SalesLine."Planned Shipment Date";

                    SourceTrackingLine.Validate("Quantity (Base)", SalesLine."Quantity (Base)");
                end;
            DATABASE::"Purchase Line":
                begin
                    SourceTrackingLine."Source Subtype" := "Document Type";
                    SourceTrackingLine."Source ID" := "Document No.";
                    SourceTrackingLine."Source Ref. No." := "Source Line No.";

                    SourceTrackingLine."Location Code" := PurchLine."Location Code";
                    SourceTrackingLine."Variant Code" := PurchLine."Variant Code";
                    SourceTrackingLine."Qty. per Unit of Measure" := PurchLine."Qty. per Unit of Measure";

                    SourceTrackingLine.Positive := (PurchLine.Signed(PurchLine."Quantity (Base)") > 0);
                    if SourceTrackingLine.Positive then
                        SourceTrackingLine."Expected Receipt Date" := PurchLine."Expected Receipt Date"
                    else
                        SourceTrackingLine."Shipment Date" := PurchLine."Expected Receipt Date";

                    SourceTrackingLine.Validate("Quantity (Base)", PurchLine."Quantity (Base)");
                end;
            DATABASE::"Transfer Line":
                begin
                    SourceTrackingLine."Source Subtype" := "Document Type";
                    SourceTrackingLine."Source ID" := "Document No.";
                    SourceTrackingLine."Source Ref. No." := "Source Line No.";

                    SourceTrackingLine."Variant Code" := TransLine."Variant Code";
                    SourceTrackingLine."Qty. per Unit of Measure" := TransLine."Qty. per Unit of Measure";

                    if "Document Type" = 0 then begin
                        SourceTrackingLine."Location Code" := TransLine."Transfer-from Code";
                        SourceTrackingLine.Positive := false;
                        SourceTrackingLine."Shipment Date" := TransLine."Shipment Date";
                        SourceTrackingLine.Validate("Quantity (Base)", TransLine."Quantity (Base)");
                    end else begin
                        SourceTrackingLine."Location Code" := TransLine."Transfer-to Code";
                        SourceTrackingLine.Positive := true;
                        SourceTrackingLine."Shipment Date" := TransLine."Receipt Date";
                        SourceTrackingLine.Validate("Quantity (Base)", TransLine."Quantity (Base)");
                    end;
                end;

        end;

        if ItemTrackingMgt.IsOrderNetworkEntity(
          SourceTrackingLine."Source Type",
          SourceTrackingLine."Source Subtype")
        then
            SourceTrackingLine."Reservation Status" := SourceTrackingLine."Reservation Status"::Surplus
        else
            SourceTrackingLine."Reservation Status" := SourceTrackingLine."Reservation Status"::Prospect;
    end;

    local procedure SetTrackingLineFilters(var ResEntry: Record "Reservation Entry")
    begin
        ResEntry.Reset;
        ResEntry.SetCurrentKey("Item No.", "Variant Code", "Location Code");

        ResEntry.SetRange("Item No.", SourceTrackingLine."Item No.");
        ResEntry.SetRange("Variant Code", SourceTrackingLine."Variant Code");
        ResEntry.SetRange("Location Code", SourceTrackingLine."Location Code");

    end;

    local procedure SetTrackingEntryFilters(var ItemLedgerEntry2: Record "Item Ledger Entry")
    begin
        ItemLedgerEntry2.Reset;
        ItemLedgerEntry2.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date", // P8000267B
          "Expiration Date", "Lot No.", "Serial No.");
        ItemLedgerEntry2.SetRange("Item No.", SourceTrackingLine."Item No.");
        ItemLedgerEntry2.SetRange("Variant Code", SourceTrackingLine."Variant Code");
        ItemLedgerEntry2.SetRange(Positive, not SourceTrackingLine.Positive);
        ItemLedgerEntry2.SetRange("Location Code", SourceTrackingLine."Location Code");
        ItemLedgerEntry2.SetRange(Open, true);
    end;

    local procedure SetLotSerialLineFilters(var ResEntry: Record "Reservation Entry"; LotNo: Code[50]; SerialNo: Code[50])
    begin
        if (LotNo <> '') then
            ResEntry.SetRange("Lot No.", LotNo);
        if (SerialNo <> '') then
            ResEntry.SetRange("Serial No.", SerialNo);
    end;

    local procedure SetLotSerialEntryFilters(var ItemLedgerEntry2: Record "Item Ledger Entry"; LotNo: Code[50]; SerialNo: Code[50])
    begin
        if (LotNo <> '') then
            ItemLedgerEntry2.SetRange("Lot No.", LotNo);
        if (SerialNo <> '') then
            ItemLedgerEntry2.SetRange("Serial No.", SerialNo);
    end;

    local procedure TestTrackingOn()
    begin

    end;


    procedure CheckLotPreferences(LotNo: Code[50]; ShowWarning: Boolean): Boolean
    var
        SalesLine: Record "Sales Line";
        ItemJnlLine: Record "Item Journal Line";
    begin

    end;


    procedure AutoFormatQtyAlt(): Text[10]
    var
        NumDecPlaces: Integer;
    begin
    end;

    local procedure TestSourceStatus()
    begin
        if not StatusCheckSuspended then begin
            GetSource;
            case "Table No." of
                DATABASE::"Sales Line":
                    SalesHeader.TestField(Status, SalesHeader.Status::Open);
                DATABASE::"Purchase Line":
                    PurchaseHeader.TestField(Status, PurchaseHeader.Status::Open);
            end;
        end;
    end;

    [Scope('Internal')]
    procedure SuspendStatusCheck(SuspendCheck: Boolean) WasSuspended: Boolean
    begin
        WasSuspended := StatusCheckSuspended;
        StatusCheckSuspended := SuspendCheck;
    end;
}

