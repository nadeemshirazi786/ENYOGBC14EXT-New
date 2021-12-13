/// <summary>
/// Codeunit Process 800 Item Tracking ELA (ID 14229151).
/// </summary>
codeunit 14229151 "Process 800 Item Tracking ELA"
{
    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'MULTIPLE';
        ProcessFns: Codeunit "Process 800 Functions ELA";
        Text002: Label 'may not be edited';
        SplitItemJnlLine: Record "Item Journal Line";
        SplitResEntry: Record "Reservation Entry";
        SplitAltQtyLine: Record "EN Alternate Quantity Line ELA";
        P800Globals: Codeunit "Process 800 System Globals ELA";
        AltQtySplit: Integer;
        Text004: Label 'Only a single alternate quantity line may be entered.';
        Text005: Label '%1 %2, %3 %4 has already been posted.';
        Text006: Label 'Lot %1 fails to meet established lot preferences.';
        Text007: Label 'No document number is available to use for lot number.';
        Text008: Label 'No date is available to use for lot number.';
        Text009: Label '%1 %2, %3 %4 has not been posted.';
        Text010: Label 'may not be changed from %1';
        Text011: Label 'may not be changed to %1';

    /// <summary>
    /// LotStatus.
    /// </summary>
    /// <param name="TrackingSpec">Record "Tracking Specification".</param>
    /// <param name="Operation">Code[10].</param>
    /// <param name="AllowLooseLotControl">Boolean.</param>
    /// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure LotStatus(TrackingSpec: Record "Tracking Specification"; Operation: Code[10]; AllowLooseLotControl: Boolean): Boolean
    var
        ItemJnlLine: Record "Item Journal Line";
        LotNoInfo: Record "Lot No. Information";
    begin
        if (not TrackingSpec.Positive) and

          ((TrackingSpec."Source Type" <> DATABASE::"Item Journal Line") or (TrackingSpec."Source Subtype" <> ItemJnlLine."Entry Type"::Transfer))
        then
            exit(false);

        case Operation of
            'DELETE':
                begin
                    if LotNoInfo.Get(TrackingSpec."Item No.", TrackingSpec."Variant Code", TrackingSpec."Lot No.") then
                        exit(not LotNoInfo."Posted ELA");
                    exit(true);
                end;

            'CREATE':
                begin
                    if TrackingSpec."Source Type" = DATABASE::"Item Journal Line" then begin
                        case TrackingSpec."Source Subtype" of
                            ItemJnlLine."Entry Type"::"Positive Adjmt.":
                                begin
                                    if TrackingSpec."Phys. Inventory ELA" or AllowLooseLotControl then
                                        exit(not LotNoInfo.Get(TrackingSpec."Item No.", TrackingSpec."Variant Code", TrackingSpec."Lot No."))
                                    else
                                        exit(false);
                                end;
                            ItemJnlLine."Entry Type"::Consumption:

                                if AllowLooseLotControl then
                                    exit(not LotNoInfo.Get(TrackingSpec."Item No.", TrackingSpec."Variant Code", TrackingSpec."Lot No."))
                                else
                                    exit(false);

                            ItemJnlLine."Entry Type"::Transfer:
                                if AllowLooseLotControl then
                                    exit(not LotNoInfo.Get(TrackingSpec."Item No.", TrackingSpec."Variant Code", TrackingSpec."New Lot No."))
                                else
                                    exit(TrackingSpec."Lot No." <> TrackingSpec."New Lot No.");

                            else
                                exit(not LotNoInfo.Get(TrackingSpec."Item No.", TrackingSpec."Variant Code", TrackingSpec."Lot No."))
                        end;
                    end;
                    exit(not LotNoInfo.Get(TrackingSpec."Item No.", TrackingSpec."Variant Code", TrackingSpec."Lot No."));
                end;
        end;
    end;

    /// <summary>
    /// CreateLotNoInfo.
    /// </summary>
    /// <param name="TrackingSpec">VAR Record "Tracking Specification".</param>
    /// <param name="LotNoInfo">VAR Record "Lot No. Information".</param>
    [Scope('Internal')]
    procedure CreateLotNoInfo(var TrackingSpec: Record "Tracking Specification"; var LotNoInfo: Record "Lot No. Information")
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        ItemJnlLine: Record "Item Journal Line";
        LotNoInfo2: Record "Lot No. Information";
    begin
        if TrackingSpec."Lot No." = '' then
            exit;

        Item.Get(TrackingSpec."Item No.");


        if TrackingSpec."Source Subtype" = ItemJnlLine."Entry Type"::Transfer then begin
            LotNoInfo.Get(TrackingSpec."Item No.", TrackingSpec."Variant Code", TrackingSpec."Lot No.");
            if LotNoInfo2.Get(TrackingSpec."Item No.", TrackingSpec."Variant Code", TrackingSpec."New Lot No.") then
                exit;
            LotNoInfo2 := LotNoInfo;
            LotNoInfo2."Lot No." := TrackingSpec."New Lot No.";
            LotNoInfo2."Lot Status Code ELA" := TrackingSpec."New Lot Status Code ELA";
            LotNoInfo2.Insert;
            TrackingSpec."New Expiration Date" := LotNoInfo."Expiration Date ELA";
            CopyLotData(LotNoInfo, LotNoInfo2);
        end else begin

            LotNoInfo.Init;
            LotNoInfo."Item No." := TrackingSpec."Item No.";
            LotNoInfo."Variant Code" := TrackingSpec."Variant Code";
            LotNoInfo."Lot No." := TrackingSpec."Lot No.";
            LotNoInfo.Description := Item.Description;
            LotNoInfo."Item Category Code ELA" := Item."Item Category Code";
            if TrackingSpec."Source Type" = DATABASE::"Sales Line" then begin
                SalesHeader.Get(TrackingSpec."Source Subtype", TrackingSpec."Source ID");
                LotNoInfo."Source Type ELA" := LotNoInfo."Source Type ELA"::Customer;
                LotNoInfo."Source No. ELA" := SalesHeader."Sell-to Customer No.";
            end else
                if TrackingSpec."Source Type" = DATABASE::"Purchase Line" then begin
                    PurchaseHeader.Get(TrackingSpec."Source Subtype", TrackingSpec."Source ID");
                    LotNoInfo."Source Type ELA" := LotNoInfo."Source Type ELA"::Vendor;
                    LotNoInfo."Source No. ELA" := PurchaseHeader."Buy-from Vendor No.";
                end;
            LotNoInfo.Insert;
        end;
    end;

    /// <summary>
    /// PostLotData.
    /// </summary>
    /// <param name="ItemJnlLine">Record "Item Journal Line".</param>
    /// <param name="EntryType">Integer.</param>
    /// <param name="LotNoInfo">VAR Record "Lot No. Information".</param>
    /// <param name="AllowLooseLotControl">Boolean.</param>
    /// <param name="ExpDate">Date.</param>
    /// <param name="RelDate">Date.</param>
    [Scope('Internal')]
    procedure PostLotData(ItemJnlLine: Record "Item Journal Line"; EntryType: Integer; var LotNoInfo: Record "Lot No. Information"; AllowLooseLotControl: Boolean; ExpDate: Date; RelDate: Date)
    var
        Item: Record Item;
        InvSetup: Record "Inventory Setup";
    begin
        if ItemJnlLine.Correction then
            exit;
        ItemJnlLine."Entry Type" := EntryType;
        if not ItemJnlIsPositive(ItemJnlLine) then
            exit;

        if LotNoInfo."Posted ELA" then begin
            if AllowLooseLotControl or
              ItemJnlLine."Phys. Inventory" or
              ((ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Consumption) and (ItemJnlLine.Quantity < 0)) or // PR3.70.03
              ((LotNoInfo."Document No. ELA" = ItemJnlLine."Document No.") and
               (LotNoInfo."Source Type ELA" = ItemJnlLine."Source Type") and
               (LotNoInfo."Source No. ELA" = ItemJnlLine."Source No."))
            then
                exit;
            Error(Text005,
              LotNoInfo.FieldCaption("Item No."), LotNoInfo."Item No.",
              LotNoInfo.FieldCaption("Lot No."), LotNoInfo."Lot No.");

        end else
            if not AllowLooseLotControl then begin
                if ((ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::"Positive Adjmt.") and // P8000496A
                    (not ItemJnlLine."Phys. Inventory")) or
                  ((ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Consumption) and (ItemJnlLine.Quantity < 0))
                then
                    Error(Text009,
                      LotNoInfo.FieldCaption("Item No."), LotNoInfo."Item No.",
                      LotNoInfo.FieldCaption("Lot No."), LotNoInfo."Lot No.");

            end;


        Item.Get(ItemJnlLine."Item No.");
        LotNoInfo."Document No. ELA" := ItemJnlLine."Document No.";
        LotNoInfo."Document Date ELA" := ItemJnlLine."Document Date";
        LotNoInfo."Source Type ELA" := ItemJnlLine."Source Type";
        LotNoInfo."Source No. ELA" := ItemJnlLine."Source No.";

        if LotNoInfo."Country/Regn of Orign Code ELA" = '' then
            LotNoInfo."Country/Regn of Orign Code ELA" := ItemJnlLine."Country/Regn of Orign Code ELA"; // P8000624A

        LotNoInfo."Expiration Date ELA" := ExpDate;
        LotNoInfo."Release Date ELA" := RelDate;

        LotNoInfo."Posted ELA" := true;

    end;
    /// <summary>
    /// UndoPostLotData.
    /// </summary>
    /// <param name="ItemJnlLine">Record "Item Journal Line".</param>
    [Scope('Internal')]
    procedure UndoPostLotData(ItemJnlLine: Record "Item Journal Line")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        LotInfo: Record "Lot No. Information";
        xLotInfo: Record "Lot No. Information";
        PurchReceiptLine: Record "Purch. Rcpt. Line";
        Item: Record Item;
        EntryNo: Integer;
        DatesSet: Boolean;
    begin

    end;
    /// <summary>
    /// ItemJnlIsPositive.
    /// </summary>
    /// <param name="ItemJnlLine">Record "Item Journal Line".</param>
    /// <returns>Return variable positive of type Boolean.</returns>
    local procedure ItemJnlIsPositive(ItemJnlLine: Record "Item Journal Line") positive: Boolean
    begin

        positive := ((ItemJnlLine."Entry Type" in [ItemJnlLine."Entry Type"::Purchase, ItemJnlLine."Entry Type"::"Positive Adjmt.",
                                      ItemJnlLine."Entry Type"::Output]) and
                     (ItemJnlLine.Quantity > 0)) or
                    ((ItemJnlLine."Entry Type" in [ItemJnlLine."Entry Type"::Sale, ItemJnlLine."Entry Type"::"Negative Adjmt.",
                                       ItemJnlLine."Entry Type"::Transfer, ItemJnlLine."Entry Type"::Consumption]) and
                     (ItemJnlLine.Quantity < 0));
    end;
    /// <summary>
    /// GetLotDates.
    /// </summary>
    /// <param name="ItemNo">Code[20].</param>
    /// <param name="VariantCode">Code[10].</param>
    /// <param name="LotNo">Code[50].</param>
    /// <param name="DocDate">Date.</param>
    /// <param name="ItemTrackingCode">Record "Item Tracking Code".</param>
    /// <param name="ExpDate">VAR Date.</param>
    /// <param name="RelDate">VAR Date.</param>
    [Scope('Internal')]
    procedure GetLotDates(ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; DocDate: Date; ItemTrackingCode: Record "Item Tracking Code"; var ExpDate: Date; var RelDate: Date)
    var
        Item: Record Item;
        LotNoInfo: Record "Lot No. Information";
    begin
    end;
    /// <summary>
    /// CheckLotUsable.
    /// </summary>
    /// <param name="ItemTrackingCode">Record "Item Tracking Code".</param>
    /// <param name="ItemLedgerEntry">Record "Item Ledger Entry".</param>
    [Scope('Internal')]
    procedure CheckLotUsable(ItemTrackingCode: Record "Item Tracking Code"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        Text001: Label ' is before the posting date.';
        LotNoInfo: Record "Lot No. Information";
    begin

        if not LotNoInfo.Get(ItemLedgerEntry."Item No.", ItemLedgerEntry."Variant Code", ItemLedgerEntry."Lot No.") then
            exit;

        if ItemTrackingCode."Strict Expiration Posting" and (LotNoInfo."Expiration Date ELA" <> 0D) and                         // P8001083
          (ItemLedgerEntry."Entry Type" in [ItemLedgerEntry."Entry Type"::Sale, ItemLedgerEntry."Entry Type"::Consumption,  // P8001083, P8001132
            ItemLedgerEntry."Entry Type"::"Assembly Consumption"])                                                          // P8001132
        then                                                                                                                // P8001083
            if ItemLedgerEntry."Posting Date" > LotNoInfo."Expiration Date ELA" then
                LotNoInfo.FieldError("Expiration Date ELA", Text001);

    end;
    /// <summary>
    /// LotControlled.
    /// </summary>
    /// <param name="ItemNo">Code[20].</param>
    /// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure LotControlled(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if not Item.Get(ItemNo) then
            exit(false);
        if Item."Item Tracking Code" <> '' then begin
            ItemTrackingCode.Get(Item."Item Tracking Code");
            exit(ItemTrackingCode."Lot Specific Tracking");
        end;
    end;
    /// <summary>
    /// UpdateItemJnlPhysQty.
    /// </summary>
    /// <param name="ResEntry">Record "Reservation Entry".</param>
    [Scope('Internal')]
    procedure UpdateItemJnlPhysQty(ResEntry: Record "Reservation Entry")
    var
        ItemJnlLine: Record "Item Journal Line";
        ResEntry2: Record "Reservation Entry";
    begin
        ResEntry2.SetCurrentKey("Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.", "Serial No.");
        ResEntry2.SetRange("Source Type", ResEntry."Source Type");
        ResEntry2.SetRange("Source ID", ResEntry."Source ID");
        ResEntry2.SetRange("Source Batch Name", ResEntry."Source Batch Name");
        ResEntry2.SetRange("Source Ref. No.", ResEntry."Source Ref. No.");
        ResEntry2.SetFilter("Entry No.", '<>%1', ResEntry."Entry No.");
        ItemJnlLine.Get(ResEntry."Source ID", ResEntry."Source Batch Name", ResEntry."Source Ref. No.");
        ItemJnlLine.Modify;
    end;
    /// <summary>
    /// TransferResEntryToItemJnlLine.
    /// </summary>
    /// <param name="ResEntry">Record "Reservation Entry".</param>
    /// <param name="ItemJnlLine">VAR Record "Item Journal Line".</param>

    [Scope('Internal')]
    procedure TransferResEntryToItemJnlLine(ResEntry: Record "Reservation Entry"; var ItemJnlLine: Record "Item Journal Line")
    begin
        ItemJnlLine.Quantity := ResEntry.Quantity;
        ItemJnlLine."Lot No." := ResEntry."Lot No.";
        ItemJnlLine."Serial No." := ResEntry."Serial No.";
    end;
    /// <summary>
    /// TrackLinesExistForItemJnlLine.
    /// </summary>
    /// <param name="ItemJnlLine">Record "Item Journal Line".</param>
    /// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure TrackLinesExistForItemJnlLine(ItemJnlLine: Record "Item Journal Line"): Boolean
    var
        ResEntry: Record "Reservation Entry";
    begin
        ResEntry.SetCurrentKey("Source Type", "Source ID", "Source Batch Name", "Source Ref. No.");
        ResEntry.SetRange("Source Type", DATABASE::"Item Journal Line");
        ResEntry.SetRange("Source ID", ItemJnlLine."Journal Template Name");
        ResEntry.SetRange("Source Batch Name", ItemJnlLine."Journal Batch Name");
        ResEntry.SetRange("Source Ref. No.", ItemJnlLine."Line No.");
        exit(ResEntry.Find('-'));
    end;

    /// <summary>
    /// GetLotNoForProdOrderLine.
    /// </summary>
    /// <param name="ProdOrderLine">Record "Prod. Order Line".</param>
    /// <returns>Return variable LotNo of type Code[50].</returns>
    [Scope('Internal')]
    procedure GetLotNoForProdOrderLine(ProdOrderLine: Record "Prod. Order Line") LotNo: Code[50]
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ResEntry: Record "Reservation Entry";
    begin
        ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line");
        ResEntry.SetRange("Source Type", DATABASE::"Prod. Order Line");
        ResEntry.SetRange("Source Subtype", ProdOrderLine.Status);
        ResEntry.SetRange("Source ID", ProdOrderLine."Prod. Order No.");
        ResEntry.SetRange("Source Prod. Order Line", ProdOrderLine."Line No.");
        if ResEntry.Find('-') then begin
            LotNo := ResEntry."Lot No.";
            ResEntry.SetFilter("Lot No.", '<>%1', LotNo);
        end;
        if ResEntry.Next <> 0 then
            exit(Text001);

        ItemLedgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type");
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
        ItemLedgerEntry.SetRange("Order No.", ProdOrderLine."Prod. Order No.");
        ItemLedgerEntry.SetRange("Order Line No.", ProdOrderLine."Line No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Output);
        if LotNo <> '' then
            ItemLedgerEntry.SetFilter("Lot No.", '<>%1&<>%2', LotNo, '');
        if ItemLedgerEntry.Find('-') then begin
            if LotNo <> '' then
                exit(Text001);
            LotNo := ItemLedgerEntry."Lot No.";
            ItemLedgerEntry.SetFilter("Lot No.", '<>%1&<>%2', LotNo, '');
            if ItemLedgerEntry.Next <> 0 then
                exit(Text001);
        end;
    end;
    /// <summary>
    /// GetLotNoForProdOrderComp.
    /// </summary>
    /// <param name="ProdOrderComp">Record "Prod. Order Component".</param>
    /// <returns>Return variable LotNo of type Code[50].</returns>

    [Scope('Internal')]
    procedure GetLotNoForProdOrderComp(ProdOrderComp: Record "Prod. Order Component") LotNo: Code[50]
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ResEntry: Record "Reservation Entry";
    begin
        ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line");
        ResEntry.SetRange("Source Type", DATABASE::"Prod. Order Component");
        ResEntry.SetRange("Source Subtype", ProdOrderComp.Status);
        ResEntry.SetRange("Source ID", ProdOrderComp."Prod. Order No.");
        ResEntry.SetRange("Source Prod. Order Line", ProdOrderComp."Prod. Order Line No.");
        ResEntry.SetRange("Source Ref. No.", ProdOrderComp."Line No.");
        if ResEntry.Find('-') then
            LotNo := ResEntry."Lot No.";
        if ResEntry.Next <> 0 then
            exit(Text001);


        ItemLedgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type");
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
        ItemLedgerEntry.SetRange("Order No.", ProdOrderComp."Prod. Order No.");
        ItemLedgerEntry.SetRange("Order Line No.", ProdOrderComp."Prod. Order Line No.");
        ItemLedgerEntry.SetRange("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Output);
        if LotNo <> '' then
            ItemLedgerEntry.SetFilter("Lot No.", '<>%1&<>%2', LotNo, '');
        if ItemLedgerEntry.Find('-') then begin
            if LotNo <> '' then
                exit(Text001);
            LotNo := ItemLedgerEntry."Lot No.";
            if ItemLedgerEntry.Next <> 0 then
                exit(Text001);
        end;
    end;
    /// <summary>
    /// ItemJnlValidateLot.
    /// </summary>
    /// <param name="xRec">Record "Item Journal Line".</param>
    /// <param name="Rec">VAR Record "Item Journal Line".</param>
    [Scope('Internal')]
    procedure ItemJnlValidateLot(xRec: Record "Item Journal Line"; var Rec: Record "Item Journal Line")
    var
        Item: Record Item;
        ItemTracking: Record "Item Tracking Code";
        LotInfo: Record "Lot No. Information";
    begin
        if Rec."Phys. Inventory" then begin
            if xRec."Lot No." <> '' then
                Rec.FieldError("Lot No.", Text002);

            if Rec."Lot No." = '' then
                exit;

            Rec.TestField("Phys. Inventory", true);

            Item.Get(Rec."Item No.");
            Item.TestField("Item Tracking Code");
            ItemTracking.Get(Item."Item Tracking Code");
            ItemTracking.TestField("Lot Specific Tracking", true);

            if Rec."Line No." <> 0 then
                ItemJnlInsertPhysical(Rec);
        end else begin
            if xRec."Lot No." = P800Globals.MultipleLotCode then
                Rec.FieldError("Lot No.", Text002);
            if Rec."Lot No." <> '' then
                if Rec."Entry Type" = Rec."Entry Type"::Transfer then begin
                    Rec."New Lot No." := Rec."Lot No.";

                    if LotInfo.Get(Rec."Item No.", Rec."Variant Code", Rec."Lot No.") then
                        Rec."New Lot Status Code ELA" := LotInfo."Lot Status Code ELA"
                    else
                        Rec."New Lot Status Code ELA" := '';
                end;

            if Rec."Line No." <> 0 then begin
                Rec.Modify;
                Rec.UpdateLotTracking(false);
            end;
        end;

    end;
    /// <summary>
    /// ItemJnlValidateNewLot.
    /// </summary>
    /// <param name="xRec">Record "Item Journal Line".</param>
    /// <param name="Rec">VAR Record "Item Journal Line".</param>
    [Scope('Internal')]
    procedure ItemJnlValidateNewLot(xRec: Record "Item Journal Line"; var Rec: Record "Item Journal Line")
    var
        Item: Record Item;
        ItemTracking: Record "Item Tracking Code";
        LotInfo: Record "Lot No. Information";
    begin
        if xRec."New Lot No." = P800Globals.MultipleLotCode then
            Rec.FieldError("New Lot No.", Text002);
        if LotInfo.Get(Rec."Item No.", Rec."Variant Code", Rec."New Lot No.") then
            Rec."New Lot Status Code ELA" := LotInfo."Lot Status Code ELA"
        else begin
            LotInfo.Get(Rec."Item No.", Rec."Variant Code", Rec."Lot No.");
            Rec."New Lot Status Code ELA" := LotInfo."Lot Status Code ELA"
        end;
        if Rec."Line No." <> 0 then begin
            Rec.Modify;
            Rec.UpdateLotTracking(false);
        end;
    end;


    /// <summary>
    /// ItemJnlValidateNewLotStatus.
    /// </summary>
    /// <param name="xRec">Record "Item Journal Line".</param>
    /// <param name="Rec">VAR Record "Item Journal Line".</param>
    procedure ItemJnlValidateNewLotStatus(xRec: Record "Item Journal Line"; var Rec: Record "Item Journal Line")
    var
        InvSetup: Record "Inventory Setup";
    begin

        if xRec."New Lot No." = P800Globals.MultipleLotCode then
            Rec.FieldError("New Lot No.", Text002);
        InvSetup.Get;
        if InvSetup."Quarantine Lot Status ELA" = '' then
            exit;
        if xRec."New Lot Status Code ELA" = InvSetup."Quarantine Lot Status ELA" then
            Rec.FieldError("New Lot Status Code ELA", StrSubstNo(Text010, InvSetup."Quarantine Lot Status ELA"));
        if Rec."New Lot Status Code ELA" = InvSetup."Quarantine Lot Status ELA" then
            Rec.FieldError("New Lot Status Code ELA", StrSubstNo(Text011, InvSetup."Quarantine Lot Status ELA"));
        if Rec."Line No." <> 0 then begin
            Rec.Modify;
            Rec.UpdateLotTracking(false);
        end;
    end;

    /// <summary>
    /// ItemJnlValidateSerial.
    /// </summary>
    /// <param name="xRec">Record "Item Journal Line".</param>
    /// <param name="Rec">VAR Record "Item Journal Line".</param>
    procedure ItemJnlValidateSerial(xRec: Record "Item Journal Line"; var Rec: Record "Item Journal Line")
    var
        Item: Record Item;
        ItemTracking: Record "Item Tracking Code";
    begin
        if xRec."Serial No." <> '' then
            Rec.FieldError("Serial No.", Text002);

        if Rec."Serial No." = '' then
            exit;

        Rec.TestField("Phys. Inventory", true);

        Item.Get(Rec."Item No.");
        Item.TestField("Item Tracking Code");
        ItemTracking.Get(Item."Item Tracking Code");
        ItemTracking.TestField("SN Specific Tracking", true);

        if Rec."Line No." <> 0 then
            ItemJnlInsertPhysical(Rec);

    end;
    /// <summary>
    /// ItemJnlInsertPhysical.
    /// </summary>
    /// <param name="rec">VAR Record "Item Journal Line".</param>
    procedure ItemJnlInsertPhysical(var rec: Record "Item Journal Line")
    var
        ResEntry: Record "Reservation Entry";
    begin
        ItemJnlDeletePhysical(rec);
        if (rec."Line No." <> 0) and
          ((rec."Lot No." <> '') or (rec."Serial No." <> '')) and
          ((rec.Quantity <> 0))
        then begin
            ResEntry.Init;
            ResEntry."Entry No." := 0;
            ResEntry."Item No." := rec."Item No.";
            ResEntry."Reservation Status" := ResEntry."Reservation Status"::Prospect;
            ResEntry."Variant Code" := rec."Variant Code";
            ResEntry."Location Code" := rec."Location Code";
            ResEntry."Created By" := UserId;
            ResEntry."Creation Date" := Today;
            ResEntry."Source Type" := DATABASE::"Item Journal Line";
            ResEntry."Source ID" := rec."Journal Template Name";
            ResEntry."Source Batch Name" := rec."Journal Batch Name";
            ResEntry."Source Subtype" := rec."Entry Type";
            ResEntry."Source Ref. No." := rec."Line No.";
            ResEntry."Lot No." := rec."Lot No.";
            ResEntry."Serial No." := rec."Serial No.";
            ResEntry.Insert(true);
        end;
    end;

    /// <summary>
    /// ItemJnlModifyPhysical.
    /// </summary>
    /// <param name="rec">VAR Record "Item Journal Line".</param>
    procedure ItemJnlModifyPhysical(var rec: Record "Item Journal Line")
    var
        ResEntry: Record "Reservation Entry";
        xResEntry: Record "Reservation Entry";
    begin
        if (rec.Quantity = 0) then
            ItemJnlDeletePhysical(rec)
        else
            if (rec."Line No." <> 0) and ((rec."Lot No." <> '') or (rec."Serial No." <> '')) then begin
                ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
                  "Source Prod. Order Line", "Source Ref. No.");
                ResEntry.SetRange("Source Type", DATABASE::"Item Journal Line");
                ResEntry.SetRange("Source ID", rec."Journal Template Name");
                ResEntry.SetRange("Source Batch Name", rec."Journal Batch Name");
                ResEntry.SetRange("Source Ref. No.", rec."Line No.");
                if ResEntry.Find('-') then begin
                    xResEntry := ResEntry;
                end;
                if ResEntry.Positive then begin
                    ResEntry."Expected Receipt Date" := rec."Posting Date";
                    ResEntry."Shipment Date" := 0D;
                end else begin
                    ResEntry."Expected Receipt Date" := 0D;
                    ResEntry."Shipment Date" := rec."Posting Date";
                end;
                if xResEntry.Positive <> ResEntry.Positive then begin
                    xResEntry.Delete;
                    ResEntry.Insert;
                end else
                    ResEntry.Modify;
            end else
                ItemJnlInsertPhysical(rec);
    end;

    /// <summary>
    /// ItemJnlDeletePhysical.
    /// </summary>
    /// <param name="rec">VAR Record "Item Journal Line".</param>
    procedure ItemJnlDeletePhysical(var rec: Record "Item Journal Line")
    var
        ResEntry: Record "Reservation Entry";
    begin
        if (rec."Line No." <> 0) and ((rec."Lot No." <> '') or (rec."Serial No." <> '')) then begin
            ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
              "Source Prod. Order Line", "Source Ref. No.");
            ResEntry.SetRange("Source Type", DATABASE::"Item Journal Line");
            ResEntry.SetRange("Source ID", rec."Journal Template Name");
            ResEntry.SetRange("Source Batch Name", rec."Journal Batch Name");
            ResEntry.SetRange("Source Ref. No.", rec."Line No.");
            ResEntry.DeleteAll;
        end;

    end;
    /// <summary>
    /// ItemJnlLineSplitPhysical.
    /// </summary>
    /// <param name="ItemJnlLine">VAR Record "Item Journal Line".</param>
    /// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure ItemJnlLineSplitPhysical(var ItemJnlLine: Record "Item Journal Line"): Boolean
    var
        ResEntry: Record "Reservation Entry";
        AltQtyLine: Record "EN Alternate Quantity Line ELA";
    begin
        case AltQtySplit of
            0:
                begin
                    SplitItemJnlLine := ItemJnlLine;
                    if AltQtyLine.Count <> 1 then
                        Error(Text004);
                    AltQtyLine.Find('-');
                    SplitAltQtyLine := AltQtyLine;
                    ItemJnlLine.Validate("Qty. (Phys. Inventory)", ItemJnlLine."Qty. (Calculated)");
                    ItemJnlModifyPhysical(ItemJnlLine);
                    AltQtyLine.Validate(Quantity, ItemJnlLine."Qty. (Calculated)");
                    AltQtyLine.Modify;
                    AltQtySplit := 1;
                    AltQtySplit := 2;
                end;
            1:
                begin
                    ItemJnlLine := SplitItemJnlLine;
                    AltQtyLine := SplitAltQtyLine;
                    ItemJnlModifyPhysical(ItemJnlLine);
                    AltQtyLine.Insert;
                    AltQtySplit := 2;
                end;
            2:
                begin
                    ItemJnlLine := SplitItemJnlLine;
                    AltQtySplit := 0;
                end;
        end;
        exit(AltQtySplit <> 0);

    end;
    /// <summary>
    /// GetDocumentLineLotInfo.
    /// </summary>
    /// <param name="SourceType">Integer.</param>
    /// <param name="SourceSubType">Integer.</param>
    /// <param name="SourceID">Code[20].</param>
    /// <param name="SourceRefNo">Integer.</param>
    /// <param name="Handled">Boolean.</param>
    /// <param name="LotInfo">VAR Record "Lot No. Information".</param>
    [Scope('Internal')]
    procedure GetDocumentLineLotInfo(SourceType: Integer; SourceSubType: Integer; SourceID: Code[20]; SourceRefNo: Integer; Handled: Boolean; var LotInfo: Record "Lot No. Information")
    var
        TrackingSpec: Record "Tracking Specification";
        ResEntry: Record "Reservation Entry";
    begin
        LotInfo.Init;
        if Handled then begin
            TrackingSpec.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Batch Name",
              "Source Prod. Order Line", "Source Ref. No.");
            TrackingSpec.SetRange("Source Type", SourceType);
            TrackingSpec.SetRange("Source Subtype", SourceSubType);
            TrackingSpec.SetRange("Source ID", SourceID);
            TrackingSpec.SetRange("Source Ref. No.", SourceRefNo);
            if TrackingSpec.Find('-') then begin
                LotInfo."Item No." := TrackingSpec."Item No.";
                LotInfo."Variant Code" := TrackingSpec."Variant Code";
                LotInfo."Lot No." := TrackingSpec."Lot No.";
            end;
        end else begin
            ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
              "Source Prod. Order Line", "Source Ref. No.");
            ResEntry.SetRange("Source Type", SourceType);
            ResEntry.SetRange("Source Subtype", SourceSubType);
            ResEntry.SetRange("Source ID", SourceID);
            ResEntry.SetRange("Source Ref. No.", SourceRefNo);
            if ResEntry.Find('-') then begin
                LotInfo."Item No." := ResEntry."Item No.";
                LotInfo."Variant Code" := ResEntry."Variant Code";
                LotInfo."Lot No." := ResEntry."Lot No.";
            end;
        end;

        if LotInfo.Find('=') then;
    end;

    /// <summary>
    /// OKToAssignLotNo.
    /// </summary>
    /// <param name="SourceRec">Variant.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure OKToAssignLotNo(SourceRec: Variant): Boolean
    var
        LotNoData: Record "EN Lot No. Data ELA";
    begin
        LotNoData.InitializeFromSourceRecord(SourceRec, false);
        exit(LotNoData.OKToAssign);
    end;
    /// <summary>
    /// AssignLotNo.
    /// </summary>
    /// <param name="SourceRec">Variant.</param>
    /// <returns>Return value of type Code[50].</returns>
    procedure AssignLotNo(SourceRec: Variant): Code[50]
    var
        LotNoData: Record "EN Lot No. Data ELA";
    begin
        LotNoData.InitializeFromSourceRecord(SourceRec, false);
        exit(LotNoData.AssignLotNo);
    end;

    /// <summary>
    /// AutoAssignLotNo.
    /// </summary>
    /// <param name="SourceRec">Variant.</param>
    /// <param name="xSourceRec">Variant.</param>
    /// <param name="LotNo">VAR Code[50].</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure AutoAssignLotNo(SourceRec: Variant; xSourceRec: Variant; var LotNo: Code[50]): Boolean
    var
        LotNoData: Record "EN Lot No. Data ELA";
        xLotNoData: Record "EN Lot No. Data ELA";
    begin
        LotNoData.InitializeFromSourceRecord(SourceRec, true);

        if not LotNoData."Inbound Assignment" then
            exit(false);

        if LotNo = '' then begin
            if LotNoData.OKToAssign then begin
                LotNo := LotNoData.AssignLotNo;
                exit(true);
            end else
                exit(false);
        end else begin
            xLotNoData.InitializeFromSourceRecord(xSourceRec, true);
            if LotNoData.LotDataChanged(xLotNoData) then begin
                if LotNoData.OKToAssign then begin
                    LotNo := LotNoData.AssignLotNo;
                end else
                    LotNo := '';
                exit(true);
            end else
                if not LotNoData.OKToAssign then begin
                    LotNo := '';
                    exit(true);
                end else
                    exit(false);
        end;
    end;

    /// <summary>
    /// GetUniqueSegmentNo.
    /// </summary>
    /// <param name="Root">Code[20].</param>
    /// <returns>Return value of type Integer.</returns>
    procedure GetUniqueSegmentNo(Root: Code[20]): Integer
    var
        AutoLotNo: Record "EN Automatic Lot No. ELA";
    begin
        if not AutoLotNo.Get(Root) then begin
            AutoLotNo.Root := Root;
            AutoLotNo.Suffix := 1;
            AutoLotNo.Insert;
        end else begin
            AutoLotNo.Suffix += 1;
            AutoLotNo.Modify;
        end;

        exit(AutoLotNo.Suffix);
    end;
    /// <summary>
    /// CalcFreshDate.
    /// </summary>
    /// <param name="LotNoInfo">VAR Record "Lot No. Information".</param>
    /// <returns>Return value of type Date.</returns>
    [Scope('Internal')]
    procedure CalcFreshDate(var LotNoInfo: Record "Lot No. Information"): Date
    var
        Item: Record Item;
    begin

    end;
    /// <summary>
    /// GetLotFreshDate.
    /// </summary>
    /// <param name="ReservEntry">Record "Reservation Entry".</param>
    /// <returns>Return value of type Date.</returns>
    [Scope('Internal')]
    procedure GetLotFreshDate(ReservEntry: Record "Reservation Entry"): Date
    var
        LotNoInfo: Record "Lot No. Information";
    begin

    end;
    /// <summary>
    /// VerifyReservLotIsFresh.
    /// </summary>
    /// <param name="TrackingSpecification">Record "Tracking Specification".</param>
    /// <param name="ReservEntry">Record "Reservation Entry".</param>
    /// <returns>Return value of type Boolean.</returns>
    [Scope('Internal')]
    procedure VerifyReservLotIsFresh(TrackingSpecification: Record "Tracking Specification"; ReservEntry: Record "Reservation Entry"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        if TrackingSpecification."Source Type" = DATABASE::"Sales Line" then begin
            SalesLine.Get(TrackingSpecification."Source Subtype", TrackingSpecification."Source ID", TrackingSpecification."Source Ref. No.");
            if (SalesLine.Type <> SalesLine.Type::Item) or
               (SalesLine."No." = '')
            then
                exit(true);
            if not VerifySalesLotIsFresh(SalesLine, ReservEntry."Lot No.", SalesLine."Shipment Date") then
                exit(false);
        end;
        exit(true);
    end;


    /// <summary>
    /// VerifySalesLotIsFresh.
    /// </summary>
    /// <param name="SalesLine">Record "Sales Line".</param>
    /// <param name="LotNo">Code[50].</param>
    /// <param name="PostingDate">Date.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure VerifySalesLotIsFresh(SalesLine: Record "Sales Line"; LotNo: Code[50]; PostingDate: Date): Boolean
    begin

    end;

    /// <summary>
    /// LotIsFresh.
    /// </summary>
    /// <param name="ItemNo">Code[20].</param>
    /// <param name="VariantCode">Code[10].</param>
    /// <param name="LotNo">Code[50].</param>
    /// <param name="FreshnessPreference">Integer.</param>
    /// <param name="PostingDate">Date.</param>
    /// <param name="ShipmentDate">Date.</param>
    /// <param name="DeliveryDate">Date.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure LotIsFresh(ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; FreshnessPreference: Integer; PostingDate: Date; ShipmentDate: Date; DeliveryDate: Date): Boolean
    var
        Item: Record Item;
        LotNoInfo: Record "Lot No. Information";
    begin

    end;
    /// <summary>
    /// GetLotFreshnessPreference.
    /// </summary>
    /// <param name="Item">Record Item.</param>
    /// <param name="CustNo">Code[20].</param>
    /// <returns>Return value of type Integer.</returns>
    [Scope('Internal')]
    procedure GetLotFreshnessPreference(Item: Record Item; CustNo: Code[20]): Integer
    begin

    end;

    /// <summary>
    /// SetDefaultCOO.
    /// </summary>
    /// <param name="PurchHeader">Record "Purchase Header".</param>
    /// <param name="PurchLine">VAR Record "Purchase Line".</param>
    /// <param name="TrackingCode">Code[10].</param>
    [Scope('Internal')]
    procedure SetDefaultCOO(PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; TrackingCode: Code[10])
    var
        ItemTracking: Record "Item Tracking Code";
        OrderAddress: Record "Order Address";
    begin
        if TrackingCode = '' then
            exit;
        ItemTracking.Get(TrackingCode);
        if not ItemTracking."Lot Specific Tracking" then
            exit;
        if PurchHeader."Order Address Code" <> '' then begin
            OrderAddress.Get(PurchHeader."Buy-from Vendor No.", PurchHeader."Order Address Code");
            PurchLine."Country/Reg of Origin Code ELA" := OrderAddress."Country/Region Code";
        end;
        if PurchLine."Country/Reg of Origin Code ELA" = '' then
            PurchLine."Country/Reg of Origin Code ELA" := PurchHeader."Buy-from Country/Region Code";
    end;

    /// <summary>
    /// CopyLotData.
    /// </summary>
    /// <param name="LotInfo">Record "Lot No. Information".</param>
    /// <param name="NewLotInfo">Record "Lot No. Information".</param>
    procedure CopyLotData(LotInfo: Record "Lot No. Information"; NewLotInfo: Record "Lot No. Information")
    var
        LotSpec: Record "EN Lot Specification ELA";
        LotSpec2: Record "EN Lot Specification ELA";
    begin
    end;
    /// <summary>
    /// SetLotFieldsFromTracking.
    /// </summary>
    /// <param name="TrackingSpec">VAR Record "Tracking Specification".</param>
    /// <param name="LotNoInfo">VAR Record "Lot No. Information".</param>

    [Scope('Internal')]
    procedure SetLotFieldsFromTracking(var TrackingSpec: Record "Tracking Specification"; var LotNoInfo: Record "Lot No. Information")
    var
        ModifyRec: Boolean;
    begin
        if (LotNoInfo."Supplier Lot No. ELA" = '') and (TrackingSpec."Supplier Lot No. ELA" <> '') then begin
            LotNoInfo."Supplier Lot No. ELA" := TrackingSpec."Supplier Lot No. ELA";
            ModifyRec := true;
        end;
        if (LotNoInfo."Creation Date ELA" = 0D) and (TrackingSpec."Lot Creation Date ELA" <> 0D) then begin
            LotNoInfo."Creation Date ELA" := TrackingSpec."Lot Creation Date ELA";
            ModifyRec := true;
        end;
        if (LotNoInfo."Country/Regn of Orign Code ELA" = '') and (TrackingSpec."Country/Regn of Orign Code ELA" <> '') then begin
            LotNoInfo."Country/Regn of Orign Code ELA" := TrackingSpec."Country/Regn of Orign Code ELA";
            ModifyRec := true;
        end;
        if ModifyRec then
            LotNoInfo.Modify;
    end;


}

