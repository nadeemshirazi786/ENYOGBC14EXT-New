codeunit 14228880 "EN Custom Functions"
{

    trigger OnRun()
    begin
    end;

    var
        grecTempUDCalcValues: Record "Buffer ELA" temporary;
        gcduUDCalculations: Codeunit "EN Custom Functions";
        grecSalesHeader: Record "Sales Header";
        grecSalesLine: Record "Sales Line";
        gdecRemQty: Decimal;
        gdecBinContentQty: Decimal;
        gdecReserveQty: Decimal;
        gdecQtyGone: Decimal;
        gdecQtyAvailable: Decimal;
        grecWhseSetup: Record "Warehouse Setup";
        gcodSalesLocation: Code[250];

        grecWhseActHdrTMP: Record "Warehouse Activity Header" temporary;
        grecWhseActLineTMP: Record "Warehouse Activity Line" temporary;
        WMSMgmt: Codeunit "WMS Management";

        OrderSignature: Record "EN Sales Order Signature";
        SignatureSetup: Record "EN Signature Capture Setup";
        Topaz: Boolean;
        CLine: Text[100];
        Return: Integer;
        Param: Text[100];
        ImportedFile: Text[50];
        UserSetup: Record "User Setup";
        grecItem: Record Item;
        grecCurrency: Record Currency;

        grrfRecordRefMaster: RecordRef;
        grecPurchLine: Record "Purchase Line";



    procedure CalcUOMToText(var precItemUOM: Record "Item Unit of Measure"): Text[250]
    var
        lrecItem: Record Item;
        lrecItemUOM: Record "Item Unit of Measure";
        lText000: Label 'This is the Base Unit of Measure.';
        lText001: Label 'There are %1 %2 in a %3.';
        lText002: Label 'There are approximately %1 %2 in a %3.';
        lText003: Label 'Please select a Base Unit of Measure on the Item card.';
    begin

        WITH precItemUOM DO BEGIN
            IF lrecItem.GET("Item No.") THEN BEGIN
                IF lrecItem."Base Unit of Measure" = '' THEN BEGIN
                    EXIT(lText003);
                END;

                IF Code = lrecItem."Base Unit of Measure" THEN BEGIN
                    EXIT(lText000);
                END ELSE BEGIN
                    //-- Get Base UOM
                    IF lrecItemUOM.GET("Item No.", lrecItem."Base Unit of Measure") THEN BEGIN
                        IF precItemUOM."Allow Variable Qty. Per ELA" THEN BEGIN
                            IF "Qty. per Unit of Measure" >= 1 THEN BEGIN
                                EXIT(STRSUBSTNO(lText002, "Qty. per Unit of Measure", lrecItemUOM.Code, Code));
                            END ELSE BEGIN
                                EXIT(STRSUBSTNO(lText002, "Qty. per Unit of Measure", Code, lrecItemUOM.Code));
                            END;
                        END ELSE BEGIN
                            IF "Qty. per Unit of Measure" >= 1 THEN BEGIN
                                EXIT(STRSUBSTNO(lText001, "Qty. per Unit of Measure", lrecItemUOM.Code, Code));
                            END ELSE BEGIN
                                EXIT(STRSUBSTNO(lText001, "Qty. per Unit of Measure", Code, lrecItemUOM.Code));
                            END;
                        END;
                    END;
                END;
            END;
        END;

        EXIT('');

    end;

    procedure CheckAllowVariableUOM(pcodItem: Code[20]; pcodUOM: Code[10]; pblnShowError: Boolean): Boolean
    var
        lrecItemUOM: Record "Item Unit of Measure";
    begin
        if not lrecItemUOM.Get(pcodItem, pcodUOM) then
            exit(false);

        if pblnShowError and not lrecItemUOM."Allow Variable Qty. Per ELA" then begin

            lrecItemUOM.FieldError("Allow Variable Qty. Per ELA");
        end;

        exit(lrecItemUOM."Allow Variable Qty. Per ELA");
    end;


    procedure CreateQuickItemJnl(Rec: Record "Sales Header")
    var
        lrecSalesLine: Record "Sales Line";
        ldecLineQuantity: Decimal;
    begin
        grecSalesHeader.Get(Rec."Document Type", Rec."No.");
        grecSalesLine.Reset;
        grecSalesLine.SetRange("Document Type", grecSalesHeader."Document Type");
        grecSalesLine.SetRange("Document No.", grecSalesHeader."No.");
        grecSalesLine.SetRange(Type, grecSalesLine.Type::Item);
        if grecSalesLine.FindSet then
            repeat
                grecSalesLine.TestField("No.");
                grecSalesLine.TestField("Location Code");
                grecSalesLine.TestField("Bin Code");
            until grecSalesLine.Next = 0;


        isInitBreakBulkVars;


        if grecSalesLine.FindSet then
            repeat
                Clear(gdecRemQty);
                Clear(gdecBinContentQty);

                gdecBinContentQty := Round(GetBinContentQty(grecSalesLine), 0.00001);

                gdecReserveQty := GetReservedQty(grecSalesLine);

                ldecLineQuantity := grecSalesLine.Quantity;
                lrecSalesLine.SetRange("Document Type", grecSalesHeader."Document Type");
                lrecSalesLine.SetRange("Document No.", grecSalesHeader."No.");
                lrecSalesLine.SetRange(Type, grecSalesLine.Type::Item);
                lrecSalesLine.SetRange("No.", grecSalesLine."No.");
                lrecSalesLine.SetRange("Variant Code", grecSalesLine."Variant Code");
                lrecSalesLine.SetRange("Location Code", grecSalesLine."Location Code");
                lrecSalesLine.SetRange("Bin Code", grecSalesLine."Bin Code");
                lrecSalesLine.SetRange("Unit of Measure Code", grecSalesLine."Unit of Measure Code");
                if lrecSalesLine.Count > 1 then begin
                    ldecLineQuantity := 0;
                    if lrecSalesLine.FindSet then
                        repeat
                            ldecLineQuantity := ldecLineQuantity + lrecSalesLine.Quantity;
                        until lrecSalesLine.Next = 0;
                end;




                gdecQtyGone := gdecBinContentQty + gdecReserveQty;
                gdecRemQty := ldecLineQuantity - gdecQtyGone;

                if gdecRemQty > 0 then
                    isTryBreakBulk(grecSalesLine, gdecRemQty);

                if gdecRemQty > 0 then begin
                    PostItemJnlLine(grecSalesLine, gdecRemQty - gdecQtyAvailable);
                end;

            until grecSalesLine.Next = 0;

        isPostBreakBulk;
    end;


    procedure isInitBreakBulkVars()
    begin

        grecWhseActHdrTMP.DeleteAll;
        grecWhseActLineTMP.DeleteAll;
        grecWhseSetup.Get;
    end;


    procedure GetBinContentQty(lrecSalesLine: Record "Sales Line"): Decimal
    var
        lrecBinContent: Record "Bin Content";
    begin

        lrecBinContent.Reset;
        lrecBinContent.SetRange("Item No.", lrecSalesLine."No.");
        lrecBinContent.SetRange("Variant Code", lrecSalesLine."Variant Code");
        lrecBinContent.SetRange("Location Code", lrecSalesLine."Location Code");
        lrecBinContent.SetRange("Bin Code", lrecSalesLine."Bin Code");
        lrecBinContent.SetRange("Unit of Measure Code", lrecSalesLine."Unit of Measure Code");
        if lrecBinContent.FindFirst then begin
            lrecBinContent.CalcFields(Quantity, "Quantity (Base)");
            exit(lrecBinContent.Quantity);
        end;
    end;


    procedure GetReservedQty(lrecSalesLine: Record "Sales Line"): Decimal
    var
        lrecReservationEntry: Record "Reservation Entry";
        UOMManagement: Codeunit "Unit of Measure Management";
        UOMQTY: Decimal;
        lrecLocation: Record Location;
        lrecBinContent: Record "Bin Content";
    begin

        UOMQTY := 0;
        lrecReservationEntry.Reset;
        lrecReservationEntry.SetRange("Source Type", DATABASE::"Sales Line");
        lrecReservationEntry.SetFilter("Source ID", '<>%1', lrecSalesLine."Document No.");
        lrecReservationEntry.SetFilter("Source Subtype", '1');
        lrecReservationEntry.SetRange("Item No.", lrecSalesLine."No.");
        lrecReservationEntry.SetRange("Variant Code", lrecSalesLine."Variant Code");
        lrecReservationEntry.SetRange("Location Code", lrecSalesLine."Location Code");

        lrecReservationEntry.SetRange(Description, '');
        lrecReservationEntry.SetRange("Qty. per Unit of Measure", lrecSalesLine."Qty. per Unit of Measure");
        if lrecReservationEntry.FindFirst then begin
            lrecReservationEntry.CalcSums(Quantity);

            UOMQTY := lrecReservationEntry.Quantity
        end;

        exit(UOMQTY);
    end;


    procedure isTryBreakBulk(precSalesLine: Record "Sales Line"; var pdecQtyShortVAR: Decimal)
    var
        lrecItemUOM: Record "Item Unit of Measure";
        ldecBinContentQtyOtherUOM: Decimal;
        lcodRequiredUOM: Code[20];
        ldecBulkBrokenQtyPer: Decimal;
        ldecBulkQtyToBreak: Decimal;
        ldecBrokenQty: Decimal;
        lrecItem: Record Item;
        ldecBulkBuildQtyPer: Decimal;
        ldecQtyToBuild: Decimal;
        ldecBuildQty: Decimal;
    begin
        lrecItemUOM.Get(precSalesLine."No.", precSalesLine."Unit of Measure Code");
        //lrecItemUOM.SetFilter(lrecItemUOM."Qty. per Base UOM", '>%1', lrecItemUOM."Qty. per Base UOM"); //Review
        lrecItemUOM.SetFilter("Item No.", precSalesLine."No.");
        if lrecItemUOM.FindSet then begin

            lrecItem.Get(precSalesLine."No.");

            lcodRequiredUOM := precSalesLine."Unit of Measure Code";
            repeat
                GetBinLots(precSalesLine, lrecItemUOM.Code);
            /*if grecLotNosByBinBufferTMP.FindFirst then
                repeat  // For each lot of that UOM found
                    ldecBinContentQtyOtherUOM := grecLotNosByBinBufferTMP."Qty. (Base)";

                    // How many to 'break' ?
                    ldecBulkBuildQtyPer := isUOMConvert(precSalesLine."No.", lcodRequiredUOM, lrecItemUOM.Code, 1);       //ex. 24 (Ea per CS)
                    ldecBuildQty := pdecQtyShortVAR * ldecBulkBuildQtyPer;    //ex. 72 EA are needed (3 CS * 24 EA per CS)
                    if ldecBuildQty > ldecBinContentQtyOtherUOM then    //ex. BinContent is 50
                        ldecBuildQty := Round(ldecBinContentQtyOtherUOM, ldecBulkBuildQtyPer, '<');  //round down to multiple equal to ldecBulkBuildQtyPer, therefore ldecBuildQty = 48
                    ldecQtyToBuild := ldecBuildQty / ldecBulkBuildQtyPer;   //set the quantity we are building of the Sales line UOM, ex. 48 / 24 = 2

                    // Build it/them ...
                    isCreateWhseActivityRecs(
                      precSalesLine,
                      lrecItemUOM.Code,                     // 'bulk' UOM
                      ldecBuildQty,                   // 'bulk' qty to build from
                                                      //<DP20171116>
                                                      //lrecItemUOM."Qty. per Base UOM",
                      lrecItemUOM."Qty. per Unit of Measure",
                      //</DP20171116>
                      precSalesLine."Unit of Measure Code", // build-to UOM
                      ldecQtyToBuild,                        // build qty
                      isUOMConvert(precSalesLine."No.", lcodRequiredUOM, lrecItem."Base Unit of Measure", 1),
                      grecLotNosByBinBufferTMP."Lot No."
                    );

                    pdecQtyShortVAR -= ldecQtyToBuild;
                    if pdecQtyShortVAR < 0 then
                        pdecQtyShortVAR := 0;
                until (grecLotNosByBinBufferTMP.Next = 0) or (pdecQtyShortVAR = 0);TBR*/
            until (lrecItemUOM.Next = 0) or (pdecQtyShortVAR = 0);
        end;

        if pdecQtyShortVAR = 0 then     //if there is no more shortage to deal with when we are done, otherwise move on to larger UOMs
            exit;


        // Find UOMs that are 'larger' than sales line UOM
        lrecItemUOM.Get(precSalesLine."No.", precSalesLine."Unit of Measure Code");
        //lrecItemUOM.SetFilter(lrecItemUOM."Qty. per Base UOM", '<%1', lrecItemUOM."Qty. per Base UOM"); //Review
        lrecItemUOM.SetFilter("Item No.", precSalesLine."No.");
        if not lrecItemUOM.FindSet then
            exit;

        lrecItem.Get(precSalesLine."No.");

        lcodRequiredUOM := precSalesLine."Unit of Measure Code";
        repeat  // For each item UOM ...
            GetBinLots(precSalesLine, lrecItemUOM.Code); // Loads grecLotNosByBinBufferTMP recs for inv with this UOM
                                                         // Note: "Qty. (Base)" will contain qty in passed UOM, *not* base UOM
                                                         /*if grecLotNosByBinBufferTMP.FindFirst then
                                                             repeat  // For each lot of that UOM found
                                                                 ldecBinContentQtyOtherUOM := grecLotNosByBinBufferTMP."Qty. (Base)";

                                                                 // How many to 'break' ?
                                                                 ldecBulkBrokenQtyPer := isUOMConvert(precSalesLine."No.", lrecItemUOM.Code, lcodRequiredUOM, 1);
                                                                 ldecBulkQtyToBreak := Round(pdecQtyShortVAR / ldecBulkBrokenQtyPer, 1.0, '>');
                                                                 if ldecBulkQtyToBreak > ldecBinContentQtyOtherUOM then
                                                                     ldecBulkQtyToBreak := ldecBinContentQtyOtherUOM;
                                                                 ldecBrokenQty := ldecBulkQtyToBreak * ldecBulkBrokenQtyPer;

                                                                 // Break it/them ...
                                                                 isCreateWhseActivityRecs(
                                                                   precSalesLine,
                                                                   lrecItemUOM.Code,                     // 'bulk' UOM
                                                                   ldecBulkQtyToBreak,                   // 'bulk' qty to break

                                                                   //lrecItemUOM."Qty. per Base UOM",
                                                                   lrecItemUOM."Qty. per Unit of Measure",

                                                                   precSalesLine."Unit of Measure Code", // break-to UOM
                                                                   ldecBrokenQty,                        // broken qty
                                                                   isUOMConvert(precSalesLine."No.", lcodRequiredUOM, lrecItem."Base Unit of Measure", 1),
                                                                   grecLotNosByBinBufferTMP."Lot No."
                                                                 );

                                                                 pdecQtyShortVAR -= ldecBrokenQty;
                                                                 if pdecQtyShortVAR < 0 then
                                                                     pdecQtyShortVAR := 0;
                                                             until (grecLotNosByBinBufferTMP.Next = 0) or (pdecQtyShortVAR = 0);TBR*/
        until (lrecItemUOM.Next = 0) or (pdecQtyShortVAR = 0);
    end;

    local procedure PostItemJnlLine(var precSalesLine: Record "Sales Line"; pdecQty: Decimal): Integer
    var
        lrecTempWhseJnlLine: Record "Warehouse Journal Line" temporary;
        lrecTempWhseJnlLine2: Record "Warehouse Journal Line" temporary;
        lrecTempWhseTrkSpecification: Record "Tracking Specification" temporary;
        lcduPostWhseJnlLine: Boolean;
        CheckApplFromItemEntry: Boolean;
        lrecItemJnlLine: Record "Item Journal Line";
        DimMgt: Codeunit DimensionManagement;
        lrecGLSetup: Record "General Ledger Setup";
        lcduItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        lrecLocation: Record Location;
        lcduItemTrackingMgt: Codeunit "Item Tracking Management";
        lblnPostWhseJnlLine: Boolean;
        lrecTempHandlingSpecification: Record "Tracking Specification" temporary;
        lrecTempTrackingSpecification: Record "Tracking Specification" temporary;
        lcduWhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
        lrecItem: Record Item;
        lrecSourceCodeSetUp: Record "Source Code Setup";
        lrecItemJnlBatch: Record "Item Journal Batch";
        lrecItemTrackingCode: Record "Item Tracking Code";
        lrecItemLedgerEntry: Record "Item Ledger Entry";
    begin
        lrecItem.Get(precSalesLine."No.");
        lrecItemJnlLine.Init;
        lrecItemJnlLine."Posting Date" := grecSalesHeader."Posting Date";
        lrecItemJnlLine."Document Date" := grecSalesHeader."Document Date";
        lrecItemJnlLine.Validate("Entry Type", lrecItemJnlLine."Entry Type"::"Positive Adjmt.");
        lrecItemJnlLine.Validate("Item No.", precSalesLine."No.");
        lrecItemJnlLine.Description := precSalesLine.Description;
        lrecItemJnlLine."Document No." := grecSalesLine."Document No.";
        lrecItemJnlLine."Shortcut Dimension 1 Code" := precSalesLine."Shortcut Dimension 1 Code";
        lrecItemJnlLine."Shortcut Dimension 2 Code" := precSalesLine."Shortcut Dimension 2 Code";
        lrecSourceCodeSetUp.Get;
        lrecSourceCodeSetUp.TestField("Item Journal");
        lrecItemJnlLine."Source Code" := lrecSourceCodeSetUp."Item Journal";
        lrecItemJnlBatch.Reset;
        lrecItemJnlBatch.SetRange("Journal Template Name", 'ITEM');
        lrecItemJnlBatch.SetRange(Name, 'CCADJ');
        lrecItemJnlBatch.FindFirst;
        lrecItemJnlLine."Journal Template Name" := lrecItemJnlBatch."Journal Template Name";
        lrecItemJnlLine."Journal Batch Name" := lrecItemJnlBatch.Name;
        lrecItemJnlLine."Reason Code" := lrecItemJnlBatch."Reason Code";

        lrecItemJnlLine.Validate("Location Code", precSalesLine."Location Code");
        lrecItemJnlLine.Validate("Variant Code", precSalesLine."Variant Code");
        lrecItemJnlLine.Validate("Bin Code", precSalesLine."Bin Code");


        lrecItemJnlLine.Validate("Unit of Measure Code", precSalesLine."Unit of Measure Code");

        lrecItemJnlLine."Cross-Reference No." := precSalesLine."Cross-Reference No.";
        lrecItemJnlLine.Validate(Quantity, pdecQty);

        if (lrecItemJnlLine."Location Code" <> '') and
            (lrecItemJnlLine.Quantity <> 0) and
            not lrecItemJnlLine.Subcontracting
        then begin
            if lrecLocation.Get(lrecItemJnlLine."Location Code") then begin
                if (lrecLocation."Directed Put-away and Pick") or (lrecLocation."Bin Mandatory")
                then begin
                    CreateWhseJnlLine(lrecItemJnlLine, lrecTempWhseJnlLine);
                    lblnPostWhseJnlLine := true;
                end;
            end;
        end;


        //jfAssignItemTracking(lrecItemJnlLine,pdecQty);
        //ibAssignTracking(lrecItemJnlLine,pdecQty); TBR

        lcduItemJnlPostLine.RunWithCheck(lrecItemJnlLine);

        //Collect Item Tracking Specifications...
        if lcduItemJnlPostLine.CollectTrackingSpecification(lrecTempHandlingSpecification) then
            if lrecTempHandlingSpecification.FindSet then
                repeat
                    lrecTempTrackingSpecification := lrecTempHandlingSpecification;
                    lrecTempTrackingSpecification."Source Type" := DATABASE::"Item Journal Line";
                    lrecTempTrackingSpecification."Source Subtype" := lrecItemJnlLine."Entry Type";
                    lrecTempTrackingSpecification."Source ID" := lrecItemJnlLine."Document No.";
                    lrecTempTrackingSpecification."Source Batch Name" := '';
                    lrecTempTrackingSpecification."Source Prod. Order Line" := 0;
                    lrecTempTrackingSpecification."Source Ref. No." := lrecItemJnlLine."Line No.";
                    if lrecTempTrackingSpecification.Insert then;
                    //IF QtyToBeInvoiced <> 0 THEN BEGIN
                    //TempTrackingSpecificationInv := TempTrackingSpecification;
                    //IF TempTrackingSpecificationInv.INSERT THEN;
                    //END;
                    if lblnPostWhseJnlLine then begin
                        lrecTempWhseTrkSpecification := lrecTempTrackingSpecification;
                        if lrecTempWhseTrkSpecification.Insert then;
                    end;
                until lrecTempHandlingSpecification.Next = 0;

        //Posting Warehouse Journal....
        if lblnPostWhseJnlLine then begin
            lcduItemTrackingMgt.SplitWhseJnlLine(lrecTempWhseJnlLine, lrecTempWhseJnlLine2, lrecTempWhseTrkSpecification, false);
            if lrecTempWhseJnlLine2.FindSet then
                repeat
                    lcduWhseJnlPostLine.Run(lrecTempWhseJnlLine2);
                until lrecTempWhseJnlLine2.Next = 0;
            lrecTempWhseTrkSpecification.DeleteAll;
        end;

    end;


    procedure isPostBreakBulk()
    var
        lcduWhseActRegister: Codeunit "Whse.-Activity-Register";
        lrecWhseActivityLine: Record "Warehouse Activity Line";
    begin

        if not grecWhseActHdrTMP.FindFirst then
            exit;


        // Register the 'pick' to break larger UOMs to needed UOMs
        lcduWhseActRegister.ShowHideDialog(true);
        //lcduWhseActRegister.jfSetTempActivityRecs(grecWhseActHdrTMP, grecWhseActLineTMP);TBR
        lcduWhseActRegister.Run(grecWhseActLineTMP);
    end;


    procedure GetBinLots(precSalesLine: Record "Sales Line"; pcodUOM: Code[20])
    var
        LotNosByBinCode: Query "Lot Numbers by Bin";
    begin
        /*
        lqueWhseEntrySummLotLast.SETRANGE(Item_No,precSalesLine."No.");
        lqueWhseEntrySummLotLast.SETRANGE(Variant_Code,precSalesLine."Variant Code");
        lqueWhseEntrySummLotLast.SETRANGE(Location_Code,precSalesLine."Location Code");
        lqueWhseEntrySummLotLast.SETRANGE(Bin_Code,precSalesLine."Bin Code");
        lqueWhseEntrySummLotLast.SETRANGE(Unit_of_Measure_Code,pcodUOM);
        lqueWhseEntrySummLotLast.OPEN;
        
        WITH grecLotNosByBinBufferTMP DO BEGIN
          DELETEALL;
          WHILE lqueWhseEntrySummLotLast.READ DO BEGIN
            IF lqueWhseEntrySummLotLast.Sum_Quantity <> 0 THEN BEGIN
              INIT;
              "Item No." := lqueWhseEntrySummLotLast.Item_No;
              "Variant Code" := lqueWhseEntrySummLotLast.Variant_Code;
              "Zone Code" := lqueWhseEntrySummLotLast.Zone_Code;
              "Bin Code" := lqueWhseEntrySummLotLast.Bin_Code;
              "Location Code" := lqueWhseEntrySummLotLast.Location_Code;
              "Lot No." := lqueWhseEntrySummLotLast.Lot_No;
              //"Qty. (Base)" := lqueWhseEntrySummLotLast.Sum_Qty_Base;
              "Qty. (Base)" := lqueWhseEntrySummLotLast.Sum_Quantity;  // !!! Note - returning qty in actual UOM, not base
              INSERT;
            END;
          END;
        END;
        
        *///TBR

    end;


    procedure isUOMConvert(pcodItemNo: Code[20]; pcodFromUOM: Code[10]; pcodToUOM: Code[10]; pdecQty: Decimal): Decimal
    var
        lrecFromUOM: Record "Item Unit of Measure";
        lrecToUOM: Record "Item Unit of Measure";
    begin

        if pcodFromUOM = pcodToUOM then
            exit(pdecQty);
        if pdecQty = 0 then
            exit(0);
        if not lrecFromUOM.Get(pcodItemNo, pcodFromUOM) then
            exit(0);
        if not lrecToUOM.Get(pcodItemNo, pcodToUOM) then
            exit(0);

        pdecQty := Round(pdecQty * lrecFromUOM."Qty. per Unit of Measure" / lrecToUOM."Qty. per Unit of Measure", 0.00001);

        exit(pdecQty);
    end;


    procedure isCreateWhseActivityRecs(precSalesLine: Record "Sales Line"; pcodTakeUOM: Code[20]; pdecTakeQty: Decimal; pdecTakeQtyPerUOM: Decimal; pcodPlaceUOM: Code[20]; pdecPlaceQty: Decimal; pdecPlaceQtyPerUOM: Decimal; pcodLotNo: Code[20])
    var
        lintLineNo: Integer;
    begin


        // Header

        if not grecWhseActHdrTMP.FindFirst then begin
            grecWhseActHdrTMP.Init;
            grecWhseActHdrTMP."Location Code" := precSalesLine."Location Code";
            grecWhseActHdrTMP."Registering No. Series" := grecWhseSetup."Whse. Pick Nos.";
            grecWhseActHdrTMP.Insert;
        end;


        // 'Take' Line  Activity Type,No.,Line No.

        lintLineNo := 0;
        if grecWhseActLineTMP.FindLast then
            lintLineNo := grecWhseActLineTMP."Line No.";

        grecWhseActLineTMP.Init;
        lintLineNo += 1000;
        grecWhseActLineTMP."Activity Type" := grecWhseActLineTMP."Activity Type"::Movement;
        grecWhseActLineTMP."Location Code" := precSalesLine."Location Code";
        grecWhseActLineTMP."Item No." := precSalesLine."No.";
        grecWhseActLineTMP."Bin Code" := precSalesLine."Bin Code";
        grecWhseActLineTMP."Breakbulk No." := 1;
        grecWhseActLineTMP."Source Type" := 37;
        grecWhseActLineTMP."Source Subtype" := 1;
        grecWhseActLineTMP."Source No." := precSalesLine."Document No.";
        grecWhseActLineTMP."Source Line No." := precSalesLine."Line No.";
        grecWhseActLineTMP."Source Document" := grecWhseActLineTMP."Source Document"::"Sales Order";
        grecWhseActLineTMP.Description := precSalesLine.Description;
        grecWhseActLineTMP."Lot No." := pcodLotNo;
        //
        grecWhseActLineTMP."Line No." := lintLineNo;
        grecWhseActLineTMP."Action Type" := grecWhseActLineTMP."Action Type"::Take;
        grecWhseActLineTMP."Unit of Measure Code" := pcodTakeUOM;
        grecWhseActLineTMP."Qty. per Unit of Measure" := pdecTakeQtyPerUOM;
        grecWhseActLineTMP.Validate(Quantity, pdecTakeQty);

        grecWhseActLineTMP.Insert;

        // 'Place' Line
        grecWhseActLineTMP."Line No." += 1;
        grecWhseActLineTMP."Action Type" := grecWhseActLineTMP."Action Type"::Place;
        grecWhseActLineTMP."Unit of Measure Code" := pcodPlaceUOM;
        grecWhseActLineTMP."Qty. per Unit of Measure" := pdecPlaceQtyPerUOM;
        grecWhseActLineTMP.Validate(Quantity, pdecPlaceQty);

        grecWhseActLineTMP.Insert;

    end;

    local procedure CreateWhseJnlLine(precItemJnlLine: Record "Item Journal Line"; var TempWhseJnlLine: Record "Warehouse Journal Line" temporary)
    var
        WhseMgt: Codeunit "Whse. Management";
        lrecLocation: Record Location;
    begin

        lrecLocation.Get(precItemJnlLine."Location Code");
        WMSMgmt.CheckAdjmtBin(lrecLocation, precItemJnlLine.Quantity, true);
        WMSMgmt.CreateWhseJnlLine(precItemJnlLine, 0, TempWhseJnlLine, false);
        TempWhseJnlLine."Source Type" := DATABASE::"Item Journal Line";
        TempWhseJnlLine."Source Subtype" := precItemJnlLine."Entry Type";
        WhseMgt.GetSourceDocument(
          TempWhseJnlLine."Source Type", TempWhseJnlLine."Source Subtype");
        TempWhseJnlLine."Source No." := precItemJnlLine."Document No.";
        TempWhseJnlLine."Source Line No." := precItemJnlLine."Line No.";
        TempWhseJnlLine."Source Code" := precItemJnlLine."Source Code";
        TempWhseJnlLine."Reference Document" := TempWhseJnlLine."Reference Document"::"Item Journal";
        TempWhseJnlLine."Reference No." := precItemJnlLine."Document No.";
        TempWhseJnlLine."Journal Template Name" := precItemJnlLine."Document No.";
    end;


    procedure ibAssignTracking(var precItemJnlLine: Record "Item Journal Line"; pdecQty: Decimal)
    var
        lcduItemJnlLineReserve: Codeunit "Item Jnl. Line-Reserve";
        lrecTrackingSpecification: Record "Tracking Specification" temporary;
        lrecItem: Record Item;
        lrecItemTrackingCode: Record "Item Tracking Code";
        lpagItemTrackingPage: Page "Item Tracking Lines";
        lrecLocation: Record Location;
        lcodCountryRegion: Code[20];
        lcodCounty: Code[20];
        lrecItemLedgerEntry: Record "Item Ledger Entry";
        lrecTrackingSpecification2: Record "Tracking Specification";
    begin

        /*
        lrecItem.GET(precItemJnlLine."Item No.");
        IF lrecItem."Item Tracking Code" <> '' THEN BEGIN
          lpagItemTrackingPage.SetBlockCommit(TRUE);
          lrecItemTrackingCode.GET(lrecItem."Item Tracking Code");
          lcduItemJnlLineReserve.InitTrackingSpecification(precItemJnlLine,lrecTrackingSpecification);
          lpagItemTrackingPage.SetSource(lrecTrackingSpecification,precItemJnlLine."Posting Date");
          lpagItemTrackingPage.SETRECORD(lrecTrackingSpecification);
          IF lrecItemTrackingCode."Lot Pos. Adjmt. Inb. Tracking" THEN BEGIN
            lpagItemTrackingPage.ibAssignLotNo;
            //<IB55459EP>
            lpagItemTrackingPage.GETRECORD(lrecTrackingSpecification2);
            //</IB55459EP>
            lpagItemTrackingPage.TempItemTrackingDef(lrecTrackingSpecification);
        
            //<IB55459EP>
            IF lrecItem."Item Tracking Code" <> '' THEN BEGIN
              IF lrecItemTrackingCode.GET(lrecItem."Item Tracking Code") THEN BEGIN
                IF lrecItemTrackingCode."Enable COO Tracking" = TRUE THEN BEGIN
                  IF NOT ibDoesTrackingCOOExist(lrecTrackingSpecification2) THEN BEGIN
        
                    lrecItemLedgerEntry.SETCURRENTKEY("Item No.","Posting Date");
                    lrecItemLedgerEntry.SETRANGE("Variant Code",lrecTrackingSpecification2."Variant Code");
                    //<DP20160121>
                    //lrecItemLedgerEntry.SETRANGE("Location Code",lrecTrackingSpecification2."Location Code");
                    lrecItemLedgerEntry.SETRANGE("Item No.",lrecTrackingSpecification2."Item No.");
                    lrecItemLedgerEntry.SETRANGE("Serial No.",lrecTrackingSpecification2."Serial No.");
                    //lrecItemLedgerEntry.SETRANGE("Lot No.",lrecTrackingSpecification2."Lot No.");
                    lrecItemLedgerEntry.ASCENDING(FALSE);
        
                    IF lrecItemLedgerEntry.FINDFIRST THEN BEGIN
                      lrecItemLedgerCOO.SETRANGE("Item No.",lrecItemLedgerEntry."Item No.");
                      lrecItemLedgerCOO.SETRANGE("Variant Code",lrecItemLedgerEntry."Variant Code");
                      lrecItemLedgerCOO.SETRANGE("Serial No.",lrecItemLedgerEntry."Serial No.");
                      //<DP20160121>
                      //lrecItemLedgerCOO.SETRANGE("Lot No.",lrecItemLedgerEntry."Lot No.");
                      IF lrecItemLedgerCOO.FINDFIRST THEN BEGIN
                        lcodCountryRegion := lrecItemLedgerCOO."Country/Region Code";
                        lcodCounty := lrecItemLedgerCOO."County Code";
                      END;
                    END;
        
                    IF lcodCountryRegion = '' THEN BEGIN
                      IF lrecLocation.GET(precItemJnlLine."Location Code") THEN BEGIN
                        lcodCountryRegion := lrecLocation."Country/Region Code";
                        lcodCounty := lrecLocation.County;
                      END;
                    END;
        
                    IF lcodCountryRegion <> '' THEN BEGIN
                      lrecItemTrackingCOO.INIT;
                      lrecItemTrackingCOO."Source Type" := lrecTrackingSpecification2."Source Type";
                      lrecItemTrackingCOO."Source Subtype" :=lrecTrackingSpecification2."Source Subtype";
                      lrecItemTrackingCOO."Source No." := lrecTrackingSpecification2."Source ID";
                      lrecItemTrackingCOO."Source Batch Name" :=lrecTrackingSpecification2."Source Batch Name";
                      lrecItemTrackingCOO."Source Line No." := lrecTrackingSpecification2."Source Ref. No.";
                      lrecItemTrackingCOO."Source Prod. Order Line" := lrecTrackingSpecification2."Source Prod. Order Line";
                      lrecItemTrackingCOO."Item No." := lrecTrackingSpecification2."Item No."; //
                      lrecItemTrackingCOO."Variant Code" :=lrecTrackingSpecification2."Variant Code";//
                      lrecItemTrackingCOO."Serial No." :=lrecTrackingSpecification2."Serial No.";   //
                      lrecItemTrackingCOO."Lot No." := lrecTrackingSpecification2."Lot No.";  //
                      lrecItemTrackingCOO."Country/Region Code" := lcodCountryRegion;
                      lrecItemTrackingCOO."County Code" := lcodCounty;
                      IF lrecItemTrackingCOO.INSERT THEN;
                    END ELSE BEGIN
                      ERROR(COONotFound, lrecTrackingSpecification2."Item No.");
                    END;
        
                  END;
                END;
              END;
            END;
            //</IB55459EP>
          END;
        END;
        
        *///TBR

    end;


    procedure ibDoesTrackingCOOExist(pRecTrackingSpecification: Record "Tracking Specification"): Boolean
    begin

        /*WITH pRecTrackingSpecification DO BEGIN
        
          IF NOT gcduCOOLMgmt.jfIsItemCOOTracked("Item No.") THEN
            EXIT(TRUE);
        
          lrecTEMPTrackingCOO.SETRANGE("Item No.", "Item No.");
          lrecTEMPTrackingCOO.SETRANGE("Serial No.","Serial No.");
          lrecTEMPTrackingCOO.SETRANGE("Lot No.","Lot No.");
        
          IF lrecTEMPTrackingCOO.COUNT > 0 THEN BEGIN
            EXIT(TRUE);
          END;
        
          lrecInventoryCOO.SETRANGE("Item No.","Item No.");
          lrecInventoryCOO.SETRANGE("Variant Code","Variant Code");
          lrecInventoryCOO.SETRANGE("Serial No.","Serial No.");
          lrecInventoryCOO.SETRANGE("Lot No.","Lot No.");
          IF lrecInventoryCOO.COUNT > 0 THEN BEGIN
            EXIT(TRUE);
          END;
        
          EXIT(FALSE);
        
        END;
        
        *///TBR

    end;



    procedure T36SignOrder(var precSalesHeaderVAR: Record "Sales Header")
    begin

        PWCaptureOrderSignature(precSalesHeaderVAR."No.");
    end;


    procedure PWCaptureOrderSignature("Order No.": Code[20])
    begin

        if (
          (OrderSignature.Get("Order No."))
          and (OrderSignature.Signature.HasValue)
        ) then begin
            if not Confirm('Signature exist for order %1 Replace (Y/N)', false, "Order No.") then
                exit
            else begin
                OrderSignature.Delete;
                Commit;
            end;

        end;

        OrderSignature.SetRange("Order No.", "Order No.");

        PAGE.RunModal(55000, OrderSignature);

        exit;


        if OrderSignature.Get("Order No.") then
            if not Confirm('Signature exist for order %1 Replace (Y/N)') then
                exit
            else
                OrderSignature.Delete;

        SignatureSetup.Get;

        Message('Note: Function PWCaptureOrderSignature is incomplete.');
        /*
                if not PWPenWareActive then
                    Error('Signature Capture not Active');

                if Topaz and not Exists(SignatureSetup."TopazCap Directory" + '\TopazCap.exe') then
                    Error('TopazCap software not found, please setup TopazCap or unplug the Topaz pad.');

                if not Topaz then
                    if Exists(SignatureSetup."Penware Output Directory" + '\SIG.PCX') then
                        if not Erase(SignatureSetup."Penware Output Directory" + '\SIG.PCX') then
                            Error('Problem removing temp signature file %1', SignatureSetup."Penware Output Directory" + '\SIG.PCX');

                if Exists(SignatureSetup."2Bitmap Output Directory" + '\SIG.BMP') then
                    if Erase(SignatureSetup."2Bitmap Output Directory" + '\SIG.BMP') then
                        Error('Problem removing temp signature file %1', SignatureSetup."2Bitmap Output Directory" + '\SIG.BMP');


                if Topaz then begin
                    CLine := SignatureSetup."TopazCap Directory" + '\TOPAZCAP.EXE';
                    Param := SignatureSetup."2Bitmap Output Directory" + '\SIG.BMP';
                    Return := Shell(CLine, Param);


                end else begin
                    CLine := SignatureSetup."Penware Program Directory" + '\GETSIGW.EXE';
                    Param := SignatureSetup."Penware Output Directory" + '\SIG.PCX';
                    Return := Shell(CLine, Param);

                    CLine := '';
                    //CLine := SignatureSetup."2Bitmap Program Directory" + '\2bitmap s="' + SignatureSetup."Penware Output Directory"
                    //          + '\SIG.PCX" d="' + SignatureSetup."2Bitmap Output Directory"  + '" -nodlg';
                    CLine := SignatureSetup."2Bitmap Program Directory" + '\2bitmap.EXE';
                    Param := 's="' + SignatureSetup."Penware Output Directory"
                               + '\SIG.PCX" d="' + SignatureSetup."2Bitmap Output Directory" + '" -nodlg"';

                    Return := Shell(CLine, Param);

                    if Exists(SignatureSetup."Penware Output Directory" + '\SIG.PCX') then
                        if Erase(SignatureSetup."Penware Output Directory" + '\SIG.PCX') then;
                end;

                if Exists(SignatureSetup."2Bitmap Output Directory" + '\SIG.BMP') then begin
                    OrderSignature.Init;
                    OrderSignature."Order No." := "Order No.";
                    ImportedFile := '';
                    ImportedFile := OrderSignature.Signature.Import(SignatureSetup."2Bitmap Output Directory" + '\SIG.BMP');
                    if ImportedFile = SignatureSetup."2Bitmap Output Directory" + '\SIG.BMP' then begin
                        OrderSignature.Insert;
                        if Exists(ImportedFile) then
                            if Erase(ImportedFile) then;
                    end;
                end
                else
                    Error('Signature Capture Failed');
                    TBR*/
    end;

    /*
    procedure PWPenWareActive(): Boolean
    begin

        SignatureSetup.Get;
        if SignatureSetup."Use Signature Capture" then begin
            UserSetup.Get(UserId);
            if UserSetup."Use Signature" then
                exit(true)
            else
                exit(false);
        end else begin
            exit(false);
        end;
    end;

    TBR*/


    procedure T36OKtoPost(var precSalesHeaderVAR: Record "Sales Header"; PromptForApproval: Boolean): Boolean
    var
        PaymentMethod: Record "Payment Method";
        Outstanding: array[2] of Decimal;
        Limit: Decimal;
    begin
        //<<EN1.00


        if not PaymentMethod.Get(precSalesHeaderVAR."Payment Method Code") then
            PaymentMethod."Cash ELA" := true;
        precSalesHeaderVAR.CalcFields("Amount Including VAT");
        if (precSalesHeaderVAR."Authorized Amount ELA" < precSalesHeaderVAR."Amount Including VAT") then begin
            T36CalcCredit(precSalesHeaderVAR, Outstanding, Limit);
            if (Outstanding[2] > 0) or
              (PaymentMethod."Cash ELA" and (Outstanding[1] > Limit)) or
              ((not PaymentMethod."Cash ELA") and ((Outstanding[1] + precSalesHeaderVAR."Amount Including VAT" -
                precSalesHeaderVAR."Cash Applied (Current) ELA") > Limit))
            then begin
                if PromptForApproval then begin
                    //Added condition check against return for T36AuthorizeOrder, Changed existing EXIT into condition to test Authorize Amount.
                    if T36AuthorizeOrder(precSalesHeaderVAR, Outstanding, Limit) = true then begin
                        if precSalesHeaderVAR."Authorized Amount ELA" >= precSalesHeaderVAR."Amount Including VAT" then begin

                            exit(true)
                        end else begin
                            Error('Order is authorized for %1.', precSalesHeaderVAR."Authorized Amount ELA");
                        end;
                    end else begin
                        exit(false);
                    end;

                end else
                    exit(false);
            end else
                exit(true);
        end else
            exit(true);

    end;

    procedure T36CalcCredit(VAR precSalesHeaderVAR: Record "Sales Header"; VAR Outstanding: ARRAY[2] OF Decimal; VAR Limit: Decimal)
    var
        Customer: Record Customer;
        CustLedger: Record "Cust. Ledger Entry";
        SalesSetup: Record "Sales & Receivables Setup";
        DueDate: Date;
    begin

        Customer.GET(precSalesHeaderVAR."Bill-to Customer No.");
        DueDate := TODAY - Customer."Credit Grace Period (Days) ELA";

        //Limit := Customer."High Credit Limit (LCY)";
        Limit := Customer."Credit Limit (LCY)";

        CustLedger.SETCURRENTKEY("Customer No.", Open, Positive, "Due Date");
        CustLedger.SETRANGE("Customer No.", Customer."No.");
        CustLedger.SETRANGE(Open, TRUE);
        //CustLedger.SETRANGE(Positive,TRUE); <IB55742EP> - Commented out.
        //CustLedger.SETFILTER("Remaining Amount",'>%1',SalesSetup."C&C Minimum Overdue Invoice"); <IB55742EP> - Commented out.
        IF CustLedger.FIND('-') THEN
            REPEAT
                CustLedger.CALCFIELDS("Remaining Amount");
                IF (precSalesHeaderVAR."No." <> '') AND (precSalesHeaderVAR."No." = CustLedger."Applies-to ID") THEN
                    CustLedger."Remaining Amount" -= CustLedger."Amount to Apply";

                Outstanding[1] += CustLedger."Remaining Amount";

                IF CustLedger."Due Date" < DueDate THEN BEGIN
                    IF (CustLedger."Remaining Amount" < 0) OR (CustLedger."Remaining Amount" >= SalesSetup."C&C Min Overdue Invoice ELA") THEN
                        Outstanding[2] += CustLedger."Remaining Amount";
                END;

            UNTIL CustLedger.NEXT = 0;
    end;

    procedure T36AuthorizeOrder(var precSalesHeaderVAR: Record "Sales Header"; Outstanding: array[2] of Decimal; Limit: Decimal): Boolean
    var
        ApproveOrder: Page "EN Approve Order";
        User: Code[20];
        Authorized: Decimal;
        lboolReturn: Boolean;

    begin

        lboolReturn := false;

        //<<EN1.00
        precSalesHeaderVAR.CalcFields("Amount Including VAT");
        if precSalesHeaderVAR."Authorized Amount ELA" <> 0 then
            Authorized := precSalesHeaderVAR."Authorized Amount ELA"
        else
            Authorized := precSalesHeaderVAR."Amount Including VAT";
        ApproveOrder.SetVariables(Outstanding, Limit, precSalesHeaderVAR."Amount Including VAT", Authorized, precSalesHeaderVAR."Cash Applied (Current) ELA");
        Commit;
        if ApproveOrder.RunModal = ACTION::OK then begin
            ApproveOrder.GetVariables(User, Authorized);
            if User <> '' then begin
                precSalesHeaderVAR."Authorized User ELA" := User;
                precSalesHeaderVAR."Authorized Amount ELA" := Authorized;

                lboolReturn := true;
            end;
        end;

        exit(lboolReturn);
    end;




    procedure UpdateTrackingStatus(ldecPct: Decimal; lblnItemTracking: Boolean): Code[10]
    begin

        if lblnItemTracking then begin
            case true of
                ldecPct = 100:
                    begin
                        exit('FILLED');
                    end;

                ldecPct > 0:
                    begin
                        exit('PARTIAL');
                    end;

                ldecPct = 0:
                    begin
                        exit('OPEN');
                    end;

            end;
        end else begin
            exit('');
        end;
    end;

    procedure T37PriceCheck(VAR precSalesLineVAR: Record "Sales Line"): Boolean
    var
        Price: Decimal;
    begin

        IF precSalesLineVAR.Type <> precSalesLineVAR.Type::Item THEN EXIT(TRUE);
        Price := precSalesLineVAR."Unit Price";

        //IF (precSalesLineVAR."Pricing Method" = precSalesLineVAR."Pricing Method"::Sale) OR (precSalesLineVAR."Pricing Method" = precSalesLineVAR."Pricing Method"::"Volume Discount") THEN
        //  EXIT(TRUE);
        IF precSalesLineVAR."Pricing Method ELA" = precSalesLineVAR."Pricing Method ELA"::"Volume Discount" THEN
            EXIT(TRUE);
        IF (precSalesLineVAR."Authorized Unit Price ELA" >= 0) AND (precSalesLineVAR."Authorized Unit Price ELA" <= Price) THEN EXIT(TRUE);
        T37GetItem(precSalesLineVAR);
        IF Price < T37MinimumItemUnitPrice(precSalesLineVAR) THEN
            EXIT(FALSE);
        EXIT(Price >= T37EstAveItemCostPerUOM(precSalesLineVAR));

    end;

    procedure T37GetItem(VAR precSalesLineVAR: Record "Sales Line")
    begin

        precSalesLineVAR.TESTFIELD(precSalesLineVAR."No.");
        IF precSalesLineVAR."No." <> grecItem."No." THEN
            grecItem.GET(precSalesLineVAR."No.");

    end;

    procedure T37MinimumItemUnitPrice(VAR precSalesLineVAR: Record "Sales Line"): Decimal
    begin

        T37GetItem(precSalesLineVAR);
        EXIT((grecItem."Unit Price" * precSalesLineVAR."Qty. per Unit of Measure") - (grecItem."Minimum Price Delta ELA" * precSalesLineVAR."Qty. per Unit of Measure"));

    end;

    procedure T37EstAveItemCostPerUOM(VAR precSalesLineVAR: Record "Sales Line"): Decimal
    begin

        T37GetItem(precSalesLineVAR);
        EXIT(grecItem."Estimated Average Cost ELA" * precSalesLineVAR."Qty. per Unit of Measure");

    end;

    procedure T37AuthorizePrice(VAR precSalesLineVAR: Record "Sales Line")
    var
        PriceAuthorization: Page "EN Price Authorization";
        MinPrice: Decimal;
        AuthUser: Code[20];
        PriceOK: Boolean;
    begin

        IF T37PriceCheck(precSalesLineVAR) THEN BEGIN
            precSalesLineVAR."To be Authorized ELA" := FALSE;
            precSalesLineVAR.MODIFY;
            EXIT;
        END;
        T37GetItem(precSalesLineVAR);

        PriceOK := FALSE;//lrecItemAuth.GET(grecItem."Item Type Code",USERID);TBR
        IF NOT PriceOK THEN BEGIN
            PriceAuthorization.SetVariables(precSalesLineVAR."Unit Price",//-T37BottleDeposit(precSalesLineVAR),TBR
            T37MinimumItemUnitPrice(precSalesLineVAR), T37EstAveItemCostPerUOM(precSalesLineVAR)); // MNJR20  YG0270A
            PriceAuthorization.RUNMODAL;

            AuthUser := PriceAuthorization.GetValidUser;
            IF AuthUser = '' THEN
                ERROR('Price not authorized.');
            /*ELSE
            IF NOT lrecItemAuth.GET(grecItem."Item Type Code", AuthUser) THEN
                ERROR('User ''%1'' not authorized for item.', AuthUser);*///TBR
        END;
        precSalesLineVAR."Authorized Unit Price ELA" := precSalesLineVAR."Unit Price";// - T37BottleDeposit(precSalesLineVAR);TBR
        precSalesLineVAR."To be Authorized ELA" := FALSE;
        precSalesLineVAR.MODIFY;
        IF PriceOK THEN
            precSalesLineVAR."Authrzed Price below Cost ELA" := USERID //lrecItemAuth."User ID"TBR
        ELSE
            precSalesLineVAR."Authrzed Price below Cost ELA" := AuthUser;

    end;

    procedure GetSalesLocationFilter(): Code[250]

    begin
        EXIT(GetSalesLocationFilter2(USERID));
    end;

    procedure GetSalesLocationFilter2(UserCode: Code[50]): Code[250]
    var
        myInt: Integer;
    begin
        IF (UserSetup.GET(UserCode)) AND (UserCode <> '') THEN BEGIN
            IF UserSetup."Sales Location Filter ELA" <> '' THEN BEGIN
                gcodSalesLocation := UserSetup."Sales Location Filter ELA" + '|' + '''' + '''';
            END;
        END;
        EXIT(gcodSalesLocation);
    end;

    procedure SetStyle(ldecPct: Decimal; lblnItemTracking: Boolean) "Text": Text
    begin
        IF lblnItemTracking THEN BEGIN
            CASE TRUE OF
                ldecPct = 100:
                    BEGIN
                        EXIT('Favorable');
                    END;

                ldecPct > 0:
                    BEGIN
                        EXIT('Ambiguous');
                    END;

                ldecPct = 0:
                    BEGIN
                        EXIT('Unfavorable');
                    END;

            END;
        END ELSE BEGIN
            EXIT('Standard');
        END;
    end;
}

