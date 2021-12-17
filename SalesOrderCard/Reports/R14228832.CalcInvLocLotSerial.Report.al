report 23019511 "Calc. Inv. Loc./Lot/Serial ELA"
{
    Caption = 'Calc. Inv. Loc./Lot/Serial';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "Location Filter", "Lot No. Filter", "Serial No. Filter";

            trigger OnAfterGetRecord()
            var
                lrecItemTrackingCode: Record "Item Tracking Code";
            begin
                if SkipCycleSKU(GetFilter("Location Filter"), "No.", GetFilter("Variant Filter")) then
                    CurrReport.Skip;

                if Item."Item Tracking Code" = '' then begin
                    CurrReport.Skip;
                end else begin
                    lrecItemTrackingCode.Get(Item."Item Tracking Code");
                    if (not lrecItemTrackingCode."SN Specific Tracking") and (not lrecItemTrackingCode."Lot Specific Tracking") then begin
                        CurrReport.Skip;
                    end;
                end;

                if not HideValidationDialog then
                    Window.Update;

                CalcFields(Inventory);
                if (Inventory <> 0) or ZeroQty then
                    InsertItemJnlLine;
            end;

            trigger OnPostDataItem()
            begin
                if not HideValidationDialog then
                    Window.Close;
            end;

            trigger OnPreDataItem()
            var
                ItemJnlTemplate: Record "Item Journal Template";
                ItemJnlBatch: Record "Item Journal Batch";
            begin
                if PostingDate = 0D then
                    Error(Text001, ItemJnlLine.FieldCaption("Posting Date"));

                ItemJnlTemplate.Get(ItemJnlLine."Journal Template Name");
                ItemJnlBatch.Get(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");

                if NextDocNo = '' then begin
                    if ItemJnlBatch."No. Series" <> '' then begin
                        ItemJnlLine.SetRange("Journal Template Name", ItemJnlLine."Journal Template Name");
                        ItemJnlLine.SetRange("Journal Batch Name", ItemJnlLine."Journal Batch Name");
                        ItemJnlLine.SetRange("Location Code", ItemJnlLine."Location Code");
                        if not ItemJnlLine.Find('-') then
                            NextDocNo :=
                              NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", PostingDate, false);
                        ItemJnlLine.Init;
                    end;
                    if NextDocNo = '' then
                        Error(Text001, ItemJnlLine.FieldCaption("Document No."));
                end;

                NextLineNo := 0;

                if not HideValidationDialog then
                    Window.Open(Text002, Item."No.");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PostingDate; PostingDate)
                    {
                        Caption = 'Posting Date';

                        trigger OnValidate()
                        begin
                            ValidateRegisteringDate;
                        end;
                    }
                    field(NextDocNo; NextDocNo)
                    {
                        Caption = 'Document No.';
                    }
                    field(ZeroQty; ZeroQty)
                    {
                        Caption = 'Items Not on Inventory';
                    }
                    field(gblnGetWhseQty; gblnGetWhseQty)
                    {
                        Caption = 'Get Qty. in Warehouse as Calc. Qty.';
                        MultiLine = true;
                    }
                    field(gblnDefaultQtyPhysInv; gblnDefaultQtyPhysInv)
                    {
                        Caption = 'Default Qty. (Phys. Inventory)';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if PostingDate = 0D then
                PostingDate := WorkDate;
            ValidateRegisteringDate;
            gblnDefaultQtyPhysInv := false;
        end;
    }

    labels
    {
    }

    var
        Text001: Label 'Please enter the %1.';
        Text002: Label 'Processing bins    #1##########';
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlLine: Record "Item Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        Location: Record Location;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Window: Dialog;
        PostingDate: Date;
        CycleSourceType: Option " ",Item,SKU;
        PhysInvtCountCode: Code[10];
        NextDocNo: Code[20];
        NextLineNo: Integer;
        ZeroQty: Boolean;
        HideValidationDialog: Boolean;
        gblnGetWhseQty: Boolean;
        gblnDefaultQtyPhysInv: Boolean;

    [Scope('Internal')]
    procedure SetWhseJnlLine(var NewWhseJnlLine: Record "Item Journal Line")
    begin
        ItemJnlLine := NewWhseJnlLine;
    end;

    local procedure ValidateRegisteringDate()
    begin
        ItemJnlBatch.Get(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");
        if ItemJnlBatch."No. Series" = '' then
            NextDocNo := ''
        else begin
            NextDocNo :=
              NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", PostingDate, false);
            Clear(NoSeriesMgt);
        end;
    end;

    [Scope('Internal')]
    procedure InsertItemJnlLine()
    var
        lrecILE: Record "Item Ledger Entry";
        lrecILE2: Record "Item Ledger Entry";
        lrecTEMPILE: Record "Item Ledger Entry" temporary;
        lrecBinContent: Record "Bin Content";
        ldecQtyInWhse: Decimal;
        lcodCurrLocation: Code[20];
        lcodCurrLotNo: Code[20];
        lcodCurrSerialNo: Code[20];
        lintEntryNo: Integer;
        lblnEntriesExist: Boolean;
        lcduItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        with ItemJnlLine do begin
            if NextLineNo = 0 then begin
                LockTable;
                SetRange("Journal Template Name", "Journal Template Name");
                SetRange("Journal Batch Name", "Journal Batch Name");
                if Find('+') then
                    NextLineNo := "Line No.";

                SourceCodeSetup.Get;
            end;

            NextLineNo := NextLineNo + 10000;


            GetLocation;

            lrecILE.SetCurrentKey(
              "Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date",
              "Expiration Date", "Lot No.", "Serial No.");
            lrecILE.SetRange("Item No.", Item."No.");
            lrecILE.SetFilter("Location Code", Item.GetFilter("Location Filter"));
            lrecILE.SetFilter("Variant Code", Item.GetFilter("Variant Filter"));


            lrecILE.SetFilter("Lot No.", Item.GetFilter("Lot No. Filter"));

            lrecILE.SetFilter("Serial No.", Item.GetFilter("Serial No. Filter"));


            if lrecILE.FindSet then begin
                lrecTEMPILE.DeleteAll;
                lintEntryNo := 0;

                repeat
                    lrecTEMPILE.SetRange("Location Code", lrecILE."Location Code");
                    lrecTEMPILE.SetRange("Lot No.", lrecILE."Lot No.");
                    lrecTEMPILE.SetRange("Serial No.", lrecILE."Serial No.");

                    if not lrecTEMPILE.FindFirst then begin
                        lintEntryNo += 1;
                        lrecTEMPILE.Init;
                        lrecTEMPILE."Entry No." := lintEntryNo;
                        lrecTEMPILE."Location Code" := lrecILE."Location Code";
                        lrecTEMPILE."Lot No." := lrecILE."Lot No.";
                        lrecTEMPILE."Serial No." := lrecILE."Serial No.";
                        lrecTEMPILE.Insert;

                        lrecILE2.SetCurrentKey(
                          "Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date",
                          "Expiration Date", "Lot No.", "Serial No.");
                        lrecILE2.SetRange("Item No.", lrecILE."Item No.");
                        lrecILE2.SetRange("Variant Code", lrecILE."Variant Code");
                        lrecILE2.SetRange("Location Code", lrecILE."Location Code");
                        lrecILE2.SetRange("Lot No.", lrecILE."Lot No.");
                        lrecILE2.SetRange("Serial No.", lrecILE."Serial No.");
                        lrecILE2.CalcSums("Remaining Quantity");

                        if (lrecILE2."Remaining Quantity" <> 0) or ZeroQty then begin
                            NextLineNo := NextLineNo + 10000;
                            Init;
                            "Line No." := NextLineNo;
                            Validate("Posting Date", PostingDate);
                            Validate("Entry Type", "Entry Type"::"Positive Adjmt.");
                            Validate("Document No.", NextDocNo);
                            Validate("Item No.", Item."No.");
                            Validate("Variant Code", lrecILE."Variant Code");
                            Validate("Location Code", lrecILE."Location Code");
                            Validate("Source Code", SourceCodeSetup."Whse. Phys. Invt. Journal");

                            Validate("Unit of Measure Code", Item."Base Unit of Measure");

                            "Serial No." := lrecILE."Serial No.";

                            //IF lcduCatchWeightMgmt.jfIsCatchWeightItem(lrecILE."Item No.",FALSE) THEN
                            //"Phys. Inv. Catch Weight" := lcduCatchWeightMgmt.jfGetCatchWeight(lrecILE."Item No.",lrecILE."Variant Code",lrecILE."Serial No.",TRUE);
                            "Lot No." := lrecILE."Lot No.";
                            "Phys. Inventory" := true;

                            "Reason Code" := ItemJnlBatch."Reason Code";

                            "Qty. (Phys. Inventory)" := lrecILE2."Remaining Quantity";
                            Validate("Qty. (Calculated)", lrecILE2."Remaining Quantity");

                            if gblnDefaultQtyPhysInv then begin
                                "Qty. (Phys. Inventory)" := lrecILE2."Remaining Quantity";
                            end;

                            "Entry Type" := ItemJnlLine."Entry Type"::"Positive Adjmt.";
                            "Phys Invt Counting Period Code" := PhysInvtCountCode;
                            "Phys Invt Counting Period Type" := CycleSourceType;

                            ldecQtyInWhse := 0;
                            if gblnGetWhseQty then begin
                                lrecBinContent.SetCurrentKey("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
                                lrecBinContent.SetRange("Item No.", Item."No.");
                                lrecBinContent.SetRange("Variant Code", lrecILE."Variant Code");
                                lrecBinContent.SetRange("Location Code", lrecILE."Location Code");
                                lrecBinContent.SetFilter("Bin Code", '<>%1', Location."Adjustment Bin Code");
                                lrecBinContent.SetRange("Lot No. Filter", lrecILE."Lot No.");
                                lrecBinContent.SetRange("Serial No. Filter", lrecILE."Serial No.");
                                if lrecBinContent.Find('-') then
                                    repeat
                                        lrecBinContent.CalcFields(Quantity);
                                        ldecQtyInWhse += lrecBinContent.Quantity * lrecBinContent."Qty. per Unit of Measure";
                                    until lrecBinContent.Next = 0;

                                Validate("Qty. (Phys. Inventory)", ldecQtyInWhse);
                            end;

                            "Item Expiration Date" := lcduItemTrackingMgt.ExistingExpirationDate("Item No.", "Variant Code", "Lot No.",
                                                                                                 "Serial No.", false, lblnEntriesExist);

                            //"Production Date ELA" := lcduItemTrackingMgt.jfExistingProdDate("Item No.","Variant Code","Lot No.",
                            //EN1.00                                                        "Serial No.",FALSE,lblnEntriesExist);

                            //"QA Release Date" := lcduItemTrackingMgt.jfExistingQADate("Item No.","Variant Code","Lot No.",
                            //                                                        "Serial No.",FALSE,lblnEntriesExist);


                            Insert(true);
                        end;
                    end;
                until lrecILE.Next = 0;
            end;
        end;

    end;

    [Scope('Internal')]
    procedure InitializeRequest(NewPostingDate: Date; WhseDocNo: Code[20]; ItemsNotOnInvt: Boolean)
    begin
        PostingDate := NewPostingDate;
        NextDocNo := WhseDocNo;
        ZeroQty := ItemsNotOnInvt;
    end;

    [Scope('Internal')]
    procedure InitializePhysInvtCount(PhysInvtCountCode2: Code[10]; CycleSourceType2: Option " ",Item,SKU)
    begin
        PhysInvtCountCode := PhysInvtCountCode2;
        CycleSourceType := CycleSourceType2;
    end;

    [Scope('Internal')]
    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure SkipCycleSKU(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]): Boolean
    var
        SKU: Record "Stockkeeping Unit";
    begin
        if CycleSourceType = CycleSourceType::Item then
            if SKU.ReadPermission then
                if SKU.Get(LocationCode, ItemNo, VariantCode) then
                    exit(true);
        exit(false);
    end;

    [Scope('Internal')]
    procedure GetLocation()
    begin
        if Location.Code <> Item.GetFilter("Location Filter") then begin
            Location.Get(Item.GetFilter("Location Filter"));
        end;
    end;
}

