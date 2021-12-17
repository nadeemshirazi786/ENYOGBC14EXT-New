report 23019507 "Calc. Inv Loc/Bin/Lot/Ser. ELA"
{
    Caption = 'Calc. Inv. Loc./Bin/Lot/Serial';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Bin Content"; "Bin Content")
        {
            DataItemTableView = SORTING("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
            RequestFilterFields = "Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code", "Lot No. Filter", "Serial No. Filter";

            trigger OnAfterGetRecord()
            begin
                grecItem.GET("Item No.");

                IF SkipCycleSKU("Location Code", "Item No.", "Variant Code") THEN
                    CurrReport.SKIP;

                IF NOT HideValidationDialog THEN
                    Window.UPDATE;
                CALCFIELDS(Quantity);
                IF (Quantity <> 0) OR ZeroQty THEN
                    InsertItemJnlLine;

            end;

            trigger OnPostDataItem()
            begin
                IF NOT HideValidationDialog THEN
                    Window.CLOSE;
            end;

            trigger OnPreDataItem()
            var
                ItemJnlTemplate: Record "Item Journal Template";
                lrecFloorSetup: Record "Floor Setup ELA";
            begin

                IF PostingDate = 0D THEN
                    ERROR(Text001, ItemJnlLine.FIELDCAPTION("Posting Date"));

                ItemJnlTemplate.GET(ItemJnlLine."Journal Template Name");
                ItemJnlBatch.GET(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");

                IF (
                  (gcodDocName <> '')
                ) THEN BEGIN
                    NextDocNo := gcodDocName;


                    IF (
                      (ItemJnlBatch."Posting No. Series" = '')
                    ) THEN BEGIN
                        lrecFloorSetup.GET;
                        lrecFloorSetup.TESTFIELD("Phys. Inv. Posting No. Series");
                        ItemJnlBatch."Posting No. Series" := lrecFloorSetup."Phys. Inv. Posting No. Series";
                    END;

                END;

                IF NextDocNo = '' THEN BEGIN
                    IF ItemJnlBatch."No. Series" <> '' THEN BEGIN
                        ItemJnlLine.SETRANGE("Journal Template Name", ItemJnlLine."Journal Template Name");
                        ItemJnlLine.SETRANGE("Journal Batch Name", ItemJnlLine."Journal Batch Name");
                        ItemJnlLine.SETRANGE("Location Code", ItemJnlLine."Location Code");
                        IF NOT ItemJnlLine.FIND('-') THEN
                            NextDocNo :=
                              NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", PostingDate, FALSE);
                        ItemJnlLine.INIT;
                    END;
                    IF NextDocNo = '' THEN
                        ERROR(Text001, ItemJnlLine.FIELDCAPTION("Document No."));
                END;

                NextLineNo := 0;

                IF NOT HideValidationDialog THEN
                    Window.OPEN(Text003 + '\' + Text002, "Item No.", "Bin Content"."Bin Code");
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
            IF PostingDate = 0D THEN
                PostingDate := WORKDATE;
            ValidateRegisteringDate;

            gblnDefaultQtyPhysInv := FALSE;
        end;
    }

    labels
    {
    }

    var
        Text001: Label 'Please enter the %1.';
        Text002: Label 'Processing Bins    #2##########';
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlLine: Record "Item Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        Location: Record Location;
        Bin: Record Bin;
        grecItem: Record Item;
        grecItemTrackingCode: Record "Item Tracking Code";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Window: Dialog;
        PostingDate: Date;
        CycleSourceType: Option " ",Item,SKU;
        PhysInvtCountCode: Code[10];
        NextDocNo: Code[20];
        NextLineNo: Integer;
        ZeroQty: Boolean;
        HideValidationDialog: Boolean;
        Text003: Label 'Processing Item    #1##########';
        gblnDefaultQtyPhysInv: Boolean;
        gcodDocName: Code[20];

    [Scope('Internal')]
    procedure SetWhseJnlLine(var NewItemJnlLine: Record "Item Journal Line")
    begin
        ItemJnlLine := NewItemJnlLine;
    end;

    local procedure ValidateRegisteringDate()
    begin
        IF (
          (gcodDocName <> '')
        ) THEN BEGIN
            EXIT;
        END;

        ItemJnlBatch.GET(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");
        IF ItemJnlBatch."No. Series" = '' THEN
            NextDocNo := ''
        ELSE BEGIN
            NextDocNo :=
              NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", PostingDate, FALSE);
            CLEAR(NoSeriesMgt);
        END;
    end;

    [Scope('Internal')]
    procedure InsertItemJnlLine()
    var
        WhseEntry: Record "Warehouse Entry";
        WhseEntry2: Record "Warehouse Entry";
        lrecTEMPWhseEntry: Record "Warehouse Entry" temporary;
        lintEntryNo: Integer;
        lcduItemTrackingMgt: Codeunit "Item Tracking Management";
        lblnEntriesExist: Boolean;
    begin
        WITH ItemJnlLine DO BEGIN
            IF NextLineNo = 0 THEN BEGIN
                LOCKTABLE;
                SETRANGE("Journal Template Name", "Journal Template Name");
                SETRANGE("Journal Batch Name", "Journal Batch Name");

                IF FIND('+') THEN
                    NextLineNo := "Line No.";

                SourceCodeSetup.GET;
            END;
            NextLineNo := NextLineNo + 10000;

            GetLocation("Bin Content"."Location Code");

            WhseEntry.SETCURRENTKEY(
              "Item No.", "Bin Code", "Location Code", "Variant Code",
              "Unit of Measure Code", "Lot No.", "Serial No.", "Entry Type");
            WhseEntry.SETRANGE("Item No.", "Bin Content"."Item No.");
            WhseEntry.SETRANGE("Bin Code", "Bin Content"."Bin Code");
            WhseEntry.SETRANGE("Location Code", "Bin Content"."Location Code");
            WhseEntry.SETRANGE("Variant Code", "Bin Content"."Variant Code");
            WhseEntry.SETRANGE("Unit of Measure Code", "Bin Content"."Unit of Measure Code");


            WhseEntry.SETFILTER("Lot No.", "Bin Content".GETFILTER("Lot No. Filter"));
            WhseEntry.SETFILTER("Serial No.", "Bin Content".GETFILTER("Serial No. Filter"));

            //WhseEntry.SETFILTER("Container No.","Bin Content".GETFILTER("Container No. Filter"));

            IF WhseEntry.FIND('-') THEN BEGIN
                lrecTEMPWhseEntry.DELETEALL;
                lintEntryNo := 0;

                REPEAT
                    lrecTEMPWhseEntry.SETRANGE("Location Code", WhseEntry."Location Code");
                    lrecTEMPWhseEntry.SETRANGE("Lot No.", WhseEntry."Lot No.");
                    lrecTEMPWhseEntry.SETRANGE("Serial No.", WhseEntry."Serial No.");
                    lrecTEMPWhseEntry.SETRANGE("Bin Code", WhseEntry."Bin Code");
                    //lrecTEMPWhseEntry.SETRANGE("Container No.",WhseEntry."Container No.");

                    IF NOT lrecTEMPWhseEntry.FINDFIRST THEN BEGIN
                        lintEntryNo += 1;
                        lrecTEMPWhseEntry.INIT;
                        lrecTEMPWhseEntry."Entry No." := lintEntryNo;
                        lrecTEMPWhseEntry."Bin Code" := WhseEntry."Bin Code";
                        lrecTEMPWhseEntry."Location Code" := WhseEntry."Location Code";
                        lrecTEMPWhseEntry."Lot No." := WhseEntry."Lot No.";
                        lrecTEMPWhseEntry."Serial No." := WhseEntry."Serial No.";
                        //lrecTEMPWhseEntry."Container No." := WhseEntry."Container No.";
                        lrecTEMPWhseEntry.INSERT;

                        WhseEntry2.SETCURRENTKEY(
                          "Item No.", "Bin Code", "Location Code", "Variant Code",
                          "Unit of Measure Code", "Lot No.", "Serial No.", "Entry Type");
                        WhseEntry2.SETRANGE("Item No.", WhseEntry."Item No.");
                        WhseEntry2.SETRANGE("Bin Code", WhseEntry."Bin Code");
                        WhseEntry2.SETRANGE("Location Code", WhseEntry."Location Code");
                        WhseEntry2.SETRANGE("Variant Code", WhseEntry."Variant Code");
                        WhseEntry2.SETRANGE("Unit of Measure Code", WhseEntry."Unit of Measure Code");
                        WhseEntry2.SETRANGE("Lot No.", WhseEntry."Lot No.");
                        WhseEntry2.SETRANGE("Serial No.", WhseEntry."Serial No.");
                        //WhseEntry2.SETRANGE("Container No.",WhseEntry."Container No.");
                        WhseEntry2.CALCSUMS(Quantity);

                        IF (WhseEntry2.Quantity <> 0) OR ZeroQty THEN BEGIN
                            NextLineNo := NextLineNo + 10000;
                            INIT;
                            "Line No." := NextLineNo;
                            VALIDATE("Posting Date", PostingDate);
                            VALIDATE("Document No.", NextDocNo);
                            "Posting No. Series" := ItemJnlBatch."Posting No. Series";
                            VALIDATE("Item No.", "Bin Content"."Item No.");
                            VALIDATE("Variant Code", "Bin Content"."Variant Code");
                            VALIDATE("Location Code", "Bin Content"."Location Code");
                            VALIDATE("Bin Code", "Bin Content"."Bin Code");
                            VALIDATE("Source Code", SourceCodeSetup."Whse. Phys. Invt. Journal");
                            VALIDATE("Unit of Measure Code", "Bin Content"."Unit of Measure Code");
                            "Serial No." := WhseEntry."Serial No.";
                            "Lot No." := WhseEntry."Lot No.";
                            //"Container No." := WhseEntry."Container No.";
                            "Phys. Inventory" := TRUE;
                            VALIDATE("Qty. (Calculated)", WhseEntry2.Quantity);
                            "Phys. Inventory" := FALSE;
                            VALIDATE("Unit of Measure Code", "Bin Content"."Unit of Measure Code");
                            "Phys. Inventory" := TRUE;

                            IF gblnDefaultQtyPhysInv THEN BEGIN
                                "Qty. (Phys. Inventory)" := WhseEntry2.Quantity;
                            END;
                            VALIDATE("Qty. (Phys. Inventory)");

                            IF Location."Use ADCS" THEN
                                VALIDATE("Qty. (Phys. Inventory)", 0);

                            "Phys Invt Counting Period Code" := PhysInvtCountCode;
                            "Phys Invt Counting Period Type" := CycleSourceType;


                            "Reason Code" := ItemJnlBatch."Reason Code";

                            "Item Expiration Date" := lcduItemTrackingMgt.ExistingExpirationDate("Item No.", "Variant Code", "Lot No.",
                                                                                                 "Serial No.", FALSE, lblnEntriesExist);

                            //"Production Date" := lcduItemTrackingMgt.jfExistingProdDate("Item No.","Variant Code","Lot No.",
                            //                                                          "Serial No.",FALSE,lblnEntriesExist);

                            //"QA Release Date" := lcduItemTrackingMgt.jfExistingQADate("Item No.","Variant Code","Lot No.",
                            //                                                        "Serial No.",FALSE,lblnEntriesExist);

                            INSERT(TRUE);
                        END;
                    END;
                UNTIL WhseEntry.NEXT = 0;
            END;
        END;

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
        IF CycleSourceType = CycleSourceType::Item THEN
            IF SKU.READPERMISSION THEN
                IF SKU.GET(LocationCode, ItemNo, VariantCode) THEN
                    EXIT(TRUE);
        EXIT(FALSE);
    end;

    [Scope('Internal')]
    procedure GetLocation(LocationCode: Code[10])
    begin
        IF Location.Code <> LocationCode THEN BEGIN
            Location.GET(LocationCode);
            IF (
              (Location."Directed Put-away and Pick")
            ) THEN BEGIN
                Location.TESTFIELD("Adjustment Bin Code");
                Bin.GET(Location.Code, Location."Adjustment Bin Code");
            END;
        END;

    end;

    [Scope('Internal')]
    procedure jfSetDocumentName(pcodDocName: Code[20])
    begin
        gcodDocName := pcodDocName;
    end;

    [Scope('Internal')]
    procedure SetDefaultQtyPhysInv(pDefaultQtyPhysInv: Boolean)
    begin
        gblnDefaultQtyPhysInv := pDefaultQtyPhysInv;
    end;
}

