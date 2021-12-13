codeunit 14229120 "Repack-Post"
{


    Permissions =;
    TableNo = "EN Repack Order";

    trigger OnRun()
    begin
        RepackOrder := Rec;

        RepackOrder.TestField(RepackOrder."Item No.");
        RepackOrder.TestField(RepackOrder."Posting Date");
        if GenJnlCheckLine.DateNotAllowed(RepackOrder."Posting Date") then
            RepackOrder.FieldError(RepackOrder."Posting Date", Text001);

        if not (RepackOrder.Transfer or RepackOrder.Produce) then
            Error(
              Text002,
              RepackOrder.FieldCaption(RepackOrder.Transfer), RepackOrder.FieldCaption(RepackOrder.Produce));

        CheckDim;

        if Transfer then begin
            RepackLine.Reset;
            RepackLine.SetRange("Order No.", RepackOrder."No.");
            RepackLine.SetFilter("Quantity to Transfer", '<>0');
            Transfer := not RepackLine.IsEmpty;
        end;

        if Produce then begin
            RepackLine.Reset;
            RepackLine.SetRange("Order No.", RepackOrder."No.");
            RepackLine.SetFilter("Quantity to Consume", '<>0');
            Produce := (RepackOrder."Quantity to Produce" <> 0) and (not RepackLine.IsEmpty);
        end;

        if not (RepackOrder.Transfer or RepackOrder.Produce) then
            Error(Text007);

        if RepackOrder.Produce then
            if not CheckConsumptionEqualsTransfer(RepackOrder) then
                exit;

        if RepackOrder.Transfer and RepackOrder.Produce then
            Window.Open(
              Text008 + '\\' +
              Text009 + '\' +
              Text010 + '\' +
              Text011)
        else
            if RepackOrder.Transfer then
                Window.Open(
                  Text008 + '\\' +
                  Text009)
            else
                Window.Open(
                  Text008 + '\\' +
                  Text010 + '\' +
                  Text011);
        Window.Update(1, StrSubstNo('%1 %2', TableCaption, RepackOrder."No."));



        SourceCodeSetup.Get;
        SrcCode := SourceCodeSetup."Repack Order ELA";

        if Transfer then begin
            LineCount := 0;
            RepackLine.Reset;
            RepackLine.SetRange("Order No.", RepackOrder."No.");
            RepackLine.SetRange(Type, RepackLine.Type::Item);
            RepackLine.SetFilter("Quantity to Transfer", '<>0');
            if RepackLine.FindSet(true, false) then
                repeat
                    LineCount += 1;
                    Window.Update(2, LineCount);
                    PostTransfer(RepackLine);
                    RepackLine.Modify;
                until RepackLine.Next = 0;
        end;

        if RepackOrder.Produce then begin
            LineCount := 0;
            TotalCost := 0;

            RepackLine.Reset;
            RepackLine.SetRange("Order No.", RepackOrder."No.");
            RepackLine.SetFilter("Quantity to Consume", '<>0');
            if RepackLine.FindSet(true, false) then
                repeat
                    CreateTempConsumptionLine(RepackLine, TotalCost);
                    RepackLine.Modify;
                until RepackLine.Next = 0;

            Window.Update(3, RepackOrder."Item No.");
            PostOutput(RepackOrder, TotalCost);

            PostTempJnlLines;

            RepackOrder.Status := RepackOrder.Status::Finished;
            RepackOrder.Modify;
        end;

        if RepackOrder.Status = RepackOrder.Status::Finished then begin
            RepackOrder."Quantity to Produce" := 0;
            RepackOrder."Quantity to Produce (Base)" := 0;

            RepackOrder.Modify;
        end;

        RepackLine.Reset;
        RepackLine.SetRange("Order No.", RepackOrder."No.");
        if RepackLine.FindSet then
            repeat
                RepackLine.UpdateQtyToTransfer;
                RepackLine.UpdateQtyToConsume;
                RepackLine.Status := RepackOrder.Status;
                RepackLine.Modify;
            until RepackLine.Next = 0;


        UpdateAnalysisView.UpdateAll(0, true);
        UpdateItemAnalysisView.UpdateAll(0, true);
        Rec := RepackOrder;
    end;

    var
        RepackOrder: Record "EN Repack Order";
        RepackLine: Record "EN Repack Order Line";
        Location: Record Location;
        SourceCodeSetup: Record "Source Code Setup";
        TempItemJnlLine: Record "Item Journal Line" temporary;
        TempResJnlLine: Record "Res. Journal Line" temporary;
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        DimMgt: Codeunit DimensionManagement;
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        ResJnlPostLine: Codeunit "Res. Jnl.-Post Line";
        WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
        UpdateAnalysisView: Codeunit "Update Analysis View";
        UpdateItemAnalysisView: Codeunit "Update Item Analysis View";
        Window: Dialog;
        SrcCode: Code[10];
        PostingDate: Date;
        LineCount: Integer;
        TotalCost: Decimal;
        Text001: Label 'is not within your range of allowed posting dates';
        Text002: Label 'Please enter "Yes" in %1 and/or %2.';
        Text003: Label 'The combination of dimensions used in %1 %2 is blocked. %3.';
        Text004: Label 'The combination of dimensions used in %1 %2, line no. %3 is blocked. %4.';
        Text005: Label 'The dimensions used in %1 %2 are invalid. %3.';
        Text006: Label 'The dimensions used in %1 %2, line no. %3 are invalid. %4.';
        Text007: Label 'There is nothing to post.';
        Text008: Label '#1#################################';
        Text009: Label 'Posting Transfers          #2######';
        Text010: Label 'Posting Output             #3######';
        Text011: Label 'Posting Consumption        #4######';
        Text012: Label '%1 %2, %3 %4, Item %5 %6 will exceed %7.  Continue posting?';

    local procedure CheckDim()
    var
        RepackLine2: Record "EN Repack Order Line";
    begin

        if (RepackOrder.Produce and (RepackOrder."Quantity to Produce" <> 0)) then begin
            RepackLine2."Line No." := 0;
            CheckDimComb(RepackLine2);
            CheckDimValuePosting(RepackLine2);
        end;

        RepackLine2.SetRange("Order No.", RepackOrder."No.");
        if RepackLine2.FindSet then
            repeat
                if (RepackOrder.Transfer and (RepackLine2."Quantity to Transfer" <> 0)) or
                   (RepackOrder.Produce and (RepackLine2."Quantity to Consume" <> 0))
                then begin
                    CheckDimComb(RepackLine2);
                    CheckDimValuePosting(RepackLine2);
                end
            until RepackLine2.Next = 0;
    end;

    local procedure CheckDimComb(RepackLine: Record "EN Repack Order Line")
    begin

        if RepackLine."Line No." = 0 then
            if not DimMgt.CheckDimIDComb(RepackOrder."Dimension Set ID") then
                Error(
                  Text003,
                  RepackOrder.TableCaption, RepackOrder."No.", DimMgt.GetDimCombErr);

        if RepackLine."Line No." <> 0 then
            if not DimMgt.CheckDimIDComb(RepackLine."Dimension Set ID") then
                Error(
                  Text004,
                  RepackOrder.TableCaption, RepackOrder."No.", RepackLine."Line No.", DimMgt.GetDimCombErr);
    end;

    local procedure CheckDimValuePosting(var RepackLine2: Record "EN Repack Order Line")
    var
        TableIDArr: array[10] of Integer;
        NumberArr: array[10] of Code[20];
    begin
        if RepackLine2."Line No." = 0 then begin
            TableIDArr[1] := DATABASE::Item;
            NumberArr[1] := RepackOrder."Item No.";
            if not DimMgt.CheckDimValuePosting(TableIDArr, NumberArr, RepackOrder."Dimension Set ID") then
                Error(
                  Text005,
                  RepackOrder.TableCaption, RepackOrder."No.", DimMgt.GetDimValuePostingErr);
        end else begin
            TableIDArr[1] := RepackLine2.TypeToTable;
            NumberArr[1] := RepackLine2."No.";
            if not DimMgt.CheckDimValuePosting(TableIDArr, NumberArr, RepackLine2."Dimension Set ID") then
                Error(
                  Text006,
                  RepackOrder.TableCaption, RepackOrder."No.", RepackLine2."Line No.", DimMgt.GetDimValuePostingErr);
        end;
    end;


    procedure CheckConsumptionEqualsTransfer(RepackOrder: Record "EN Repack Order"): Boolean
    var
        RepackLine: Record "EN Repack Order Line";
    begin
        RepackLine.SetRange("Order No.", RepackOrder."No.");
        RepackLine.SetRange(Type, RepackLine.Type::Item);
        RepackLine.SetFilter("Source Location", '<>%1', RepackOrder."Repack Location");
        if RepackLine.Find('-') then
            repeat
                if (RepackLine."Quantity Transferred" + RepackLine."Quantity to Transfer") > RepackLine."Quantity to Consume" then
                    if not Confirm(Text012, false,
                      RepackOrder.TableCaption, RepackOrder."No.",
                      RepackLine.FieldCaption("Line No."), RepackLine."Line No.", RepackLine."No.",
                      RepackLine.FieldCaption("Quantity Transferred"), RepackLine.FieldCaption("Quantity Consumed"))
                    then
                        exit(false);
            until RepackLine.Next = 0;

        exit(true);
    end;


    procedure PostTransfer(var RepackLine: Record "EN Repack Order Line")
    var
        Item: Record Item;
        ItemJnlLine: Record "Item Journal Line";
        TempHandlingSpecification: Record "Tracking Specification" temporary;
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin

        // Item.Get(RepackLine."No.");
        // if (Item."Item Tracking Code" <> '') and (RepackLine."Lot No." = '') then
        //     RepackLine.FieldError(RepackLine."Lot No.");

        ItemJnlLine.Init;
        ItemJnlLine.Validate("Posting Date", RepackOrder."Posting Date");
        ItemJnlLine.Validate("Document No.", RepackOrder."No.");
        ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::Transfer);
        ItemJnlLine.Validate("Item No.", RepackLine."No.");
        ItemJnlLine.Description := RepackLine.Description;
        ItemJnlLine.Validate("Variant Code", RepackLine."Variant Code");
        ItemJnlLine."Shortcut Dimension 1 Code" := RepackLine."Shortcut Dimension 1 Code";
        ItemJnlLine."Shortcut Dimension 2 Code" := RepackLine."Shortcut Dimension 2 Code";
        ItemJnlLine."Dimension Set ID" := RepackLine."Dimension Set ID";
        ItemJnlLine.Validate("Location Code", RepackLine."Source Location");
        ItemJnlLine.Validate("Bin Code", RepackLine."Bin Code");
        ItemJnlLine.Validate("New Location Code", RepackOrder."Repack Location");
        ItemJnlLine.Validate("Unit of Measure Code", RepackLine."Unit of Measure Code");
        ItemJnlLine.Validate(Quantity, RepackLine."Quantity to Transfer");

        ItemJnlLine."Source Code" := SrcCode;

        ItemJnlLine."Order Type Ext ELA" := ItemJnlLine."Order Type Ext ELA"::Repack;
        ItemJnlLine."Order No." := RepackLine."Order No.";
        ItemJnlLine."Order Line No." := RepackLine."Line No.";


        if RepackLine."Lot No." <> '' then begin
            CreateReservEntry.CreateReservEntryFor(
              DATABASE::"Item Journal Line", ItemJnlLine."Entry Type", '', '', 0, 0,
              ItemJnlLine."Qty. per Unit of Measure", ItemJnlLine.Quantity, ItemJnlLine."Quantity (Base)", '', RepackLine."Lot No.");
            CreateReservEntry.SetNewSerialLotNo('', RepackLine."Lot No.");
            CreateReservEntry.CreateEntry(ItemJnlLine."Item No.", ItemJnlLine."Variant Code",
              ItemJnlLine."Location Code", ItemJnlLine.Description, 0D, ItemJnlLine."Posting Date", 0, 3);
        end;

        ItemJnlPostLine.RunWithCheck(ItemJnlLine);

        ItemJnlPostLine.CollectTrackingSpecification(TempHandlingSpecification);
        PostWhseJnlLine(
          ItemJnlLine, RepackLine."Quantity to Transfer", RepackLine."Quantity to Transfer (Base)", TempHandlingSpecification);


        RepackLine."Quantity Transferred" += RepackLine."Quantity to Transfer";
        RepackLine."Quantity Transferred (Base)" += RepackLine."Quantity to Transfer (Base)";

    end;


    procedure CreateTempConsumptionLine(var RepackLine: Record "EN Repack Order Line"; var TotalCost: Decimal)
    begin
        case RepackLine.Type of
            RepackLine.Type::Item:
                begin
                    TempItemJnlLine.Init;
                    TempItemJnlLine."Line No." := RepackLine."Line No.";
                    TempItemJnlLine.Validate("Posting Date", RepackOrder."Posting Date");
                    TempItemJnlLine."Document No." := RepackOrder."No.";
                    TempItemJnlLine."Entry Type" := TempItemJnlLine."Entry Type"::"Negative Adjmt.";
                    TempItemJnlLine.Validate("Item No.", RepackLine."No.");
                    TempItemJnlLine.Validate("Variant Code", RepackLine."Variant Code");
                    TempItemJnlLine.Description := RepackLine.Description;
                    TempItemJnlLine."Shortcut Dimension 1 Code" := RepackLine."Shortcut Dimension 1 Code";
                    TempItemJnlLine."Shortcut Dimension 2 Code" := RepackLine."Shortcut Dimension 2 Code";
                    TempItemJnlLine."Dimension Set ID" := RepackLine."Dimension Set ID";
                    TempItemJnlLine."Source Code" := SrcCode;

                    TempItemJnlLine."Order Type Ext ELA" := TempItemJnlLine."Order Type Ext ELA"::Repack;
                    TempItemJnlLine."Order No." := RepackLine."Order No.";
                    TempItemJnlLine."Order Line No." := RepackLine."Line No.";

                    TempItemJnlLine.Validate("Location Code", RepackOrder."Repack Location");
                    if RepackOrder."Repack Location" = RepackLine."Source Location" then
                        TempItemJnlLine.Validate("Bin Code", RepackLine."Bin Code");
                    TempItemJnlLine.Validate("Unit of Measure Code", RepackLine."Unit of Measure Code");
                    TempItemJnlLine.Validate(Quantity, RepackLine."Quantity to Consume");


                    TempItemJnlLine.Insert;

                    TotalCost += TempItemJnlLine."Unit Cost" * TempItemJnlLine.GetCostingQtyELA(TempItemJnlLine.FieldNo(Quantity));
                end;

            RepackLine.Type::Resource:
                begin
                    TempResJnlLine.Init;
                    TempResJnlLine."Line No." := RepackLine."Line No.";
                    TempResJnlLine.Validate("Posting Date", RepackOrder."Posting Date");
                    TempResJnlLine."Document No." := RepackOrder."No.";
                    TempResJnlLine."Entry Type" := TempResJnlLine."Entry Type"::Usage;
                    TempResJnlLine.Validate("Resource No.", RepackLine."No.");
                    TempResJnlLine.Description := RepackLine.Description;
                    TempResJnlLine."Shortcut Dimension 1 Code" := RepackLine."Shortcut Dimension 1 Code";
                    TempResJnlLine."Shortcut Dimension 2 Code" := RepackLine."Shortcut Dimension 2 Code";
                    TempResJnlLine."Dimension Set ID" := RepackLine."Dimension Set ID";
                    TempResJnlLine."Source Code" := SrcCode;

                    TempResJnlLine."Order Type Ext ELA" := TempResJnlLine."Order Type Ext ELA"::Repack;
                    TempResJnlLine."Order No." := RepackLine."Order No.";
                    TempResJnlLine."Order Line No." := RepackLine."Line No.";

                    TempResJnlLine.Validate("Unit of Measure Code", RepackLine."Unit of Measure Code");
                    TempResJnlLine.Validate(Quantity, RepackLine."Quantity to Consume");
                    TempResJnlLine.Insert;

                    TotalCost += TempResJnlLine."Total Cost";
                end;
        end;

        RepackLine."Quantity Consumed" := RepackLine."Quantity to Consume";
        RepackLine."Quantity Consumed (Base)" := RepackLine."Quantity to Consume (Base)";

    end;


    procedure PostOutput(var RepackOrder: Record "EN Repack Order"; TotalCost: Decimal)
    var
        ItemJnlLine: Record "Item Journal Line";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        LotInfo: Record "Lot No. Information";
        TempHandlingSpecification: Record "Tracking Specification" temporary;
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin

        Item.Get(RepackOrder."Item No.");

        ItemJnlLine.Init;
        ItemJnlLine.Validate("Posting Date", RepackOrder."Posting Date");
        ItemJnlLine.Validate("Document No.", RepackOrder."No.");
        ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.");
        ItemJnlLine.Validate("Item No.", RepackOrder."Item No.");
        ItemJnlLine.Description := RepackOrder.Description;
        ItemJnlLine.Validate("Variant Code", RepackOrder."Variant Code");
        ItemJnlLine."Shortcut Dimension 1 Code" := RepackOrder."Shortcut Dimension 1 Code";
        ItemJnlLine."Shortcut Dimension 2 Code" := RepackOrder."Shortcut Dimension 2 Code";
        ItemJnlLine."Dimension Set ID" := RepackOrder."Dimension Set ID";
        ItemJnlLine.Validate("Location Code", RepackOrder."Destination Location");
        ItemJnlLine.Validate("Bin Code", RepackOrder."Bin Code");
        ItemJnlLine.Validate("Unit of Measure Code", RepackOrder."Unit of Measure Code");
        ItemJnlLine.Validate(Quantity, RepackOrder."Quantity to Produce");

        ItemJnlLine.Validate(Amount, TotalCost);
        ItemJnlLine."Source Code" := SrcCode;

        ItemJnlLine."Order Type Ext ELA" := ItemJnlLine."Order Type Ext ELA"::Repack;
        ItemJnlLine."Order No." := RepackOrder."No.";

        /*
        IF "Lot No." <> '' THEN BEGIN
          ItemJnlLine.Farm := Farm;
          ItemJnlLine.Brand := Brand;
          ItemJnlLine."Country/Region of Origin Code" :="Country/Region of Origin Code";
          //ItemJnlLine.Repack := TRUE;

          CreateReservEntry.CreateReservEntryFor(
            DATABASE::"Item Journal Line",ItemJnlLine."Entry Type",'','',0,0,
            ItemJnlLine."Qty. per Unit of Measure",ItemJnlLine.Quantity,ItemJnlLine."Quantity (Base)",'',"Lot No."); 
           
          CreateReservEntry.CreateEntry(ItemJnlLine."Item No.",ItemJnlLine."Variant Code",
            ItemJnlLine."Location Code",ItemJnlLine.Description,ItemJnlLine."Posting Date",0D,0,3);

          IF NOT LotInfo.GET("Item No.","Variant Code","Lot No.") THEN BEGIN
            LotInfo."Item No." := "Item No.";
            LotInfo."Variant Code" := "Variant Code";
            LotInfo."Lot No." := "Lot No.";
            LotInfo.Description := Item.Description;
            LotInfo."Item Category Code" := Item."Item Category Code";
            LotInfo."Created From Repack" := TRUE;
            LotInfo.INSERT;
          END;
        END;
        *///TBR
        ItemJnlPostLine.RunWithCheck(ItemJnlLine);

        ItemJnlPostLine.CollectTrackingSpecification(TempHandlingSpecification);
        PostWhseJnlLine(
          ItemJnlLine, RepackOrder."Quantity to Produce", RepackOrder."Quantity to Produce (Base)", TempHandlingSpecification);


        RepackOrder."Quantity Produced" += RepackOrder."Quantity to Produce";
        RepackOrder."Quantity Produced (Base)" += RepackOrder."Quantity to Produce (Base)";


    end;




    procedure PostTempJnlLines()
    var
        ItemJnlLine: Record "Item Journal Line";
        ResReg: Record "Resource Register";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        if TempItemJnlLine.FindSet then
            repeat
                LineCount += 1;
                Window.Update(4, LineCount);

                RepackLine.Get(RepackOrder."No.", TempItemJnlLine."Line No.");
                /*IF RepackLine."Lot No." <> '' THEN BEGIN
                  CreateReservEntry.CreateReservEntryFor(
                    DATABASE::"Item Journal Line",TempItemJnlLine."Entry Type",'','',0,TempItemJnlLine."Line No.",
                    TempItemJnlLine."Qty. per Unit of Measure",TempItemJnlLine.Quantity,TempItemJnlLine."Quantity (Base)",'',RepackLine."Lot No."); 
                  
                  CreateReservEntry.CreateEntry(TempItemJnlLine."Item No.",TempItemJnlLine."Variant Code",
                    TempItemJnlLine."Location Code",TempItemJnlLine.Description,0D,TempItemJnlLine."Posting Date",0,3);
                END;
                *///TBR
                ItemJnlPostLine.RunWithCheck(TempItemJnlLine);
            until TempItemJnlLine.Next = 0;

        if TempResJnlLine.FindSet then
            repeat
                LineCount += 1;
                Window.Update(4, LineCount);

                RepackLine.Get(RepackOrder."No.", TempResJnlLine."Line No.");

                ResJnlPostLine.RunWithCheck(TempResJnlLine);

            until TempResJnlLine.Next = 0;

    end;

    local procedure PostWhseJnlLine(ItemJnlLine: Record "Item Journal Line"; OriginalQuantity: Decimal; OriginalQuantityBase: Decimal; var TempHandlingSpecification: Record "Tracking Specification" temporary)
    var
        WhseJnlLine: Record "Warehouse Journal Line";
        TempWhseJnlLine2: Record "Warehouse Journal Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WMSMgmt: Codeunit "WMS Management";
        TemplateType: Integer;
    begin


        ItemJnlLine.Quantity := OriginalQuantity;
        ItemJnlLine."Quantity (Base)" := OriginalQuantityBase;

        if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer then
            TemplateType := 1
        else
            TemplateType := 0;
        if Location.Get(ItemJnlLine."Location Code") then
            if Location."Bin Mandatory" then
                if WMSMgmt.CreateWhseJnlLine(ItemJnlLine, TemplateType, WhseJnlLine, false) then begin
                    XferWhseRoundingAdjmts;
                    ItemTrackingMgt.SplitWhseJnlLine(WhseJnlLine, TempWhseJnlLine2, TempHandlingSpecification, false);
                    if TempWhseJnlLine2.FindSet then
                        repeat
                            WMSMgmt.CheckWhseJnlLine(TempWhseJnlLine2, 1, 0, false);
                            WhseJnlPostLine.Run(TempWhseJnlLine2);
                            PostWhseAltQtyAdjmt(TempWhseJnlLine2);
                        until TempWhseJnlLine2.Next = 0;
                    PostWhseRoundingAdjmts;
                end;

        if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer then begin
            if Location.Get(ItemJnlLine."New Location Code") then
                if Location."Bin Mandatory" then
                    if WMSMgmt.CreateWhseJnlLine(ItemJnlLine, 0, WhseJnlLine, true) then begin
                        ItemTrackingMgt.SplitWhseJnlLine(WhseJnlLine, TempWhseJnlLine2, TempHandlingSpecification, true);
                        if TempWhseJnlLine2.FindSet then
                            repeat
                                WMSMgmt.CheckWhseJnlLine(TempWhseJnlLine2, 1, 0, true);
                                WhseJnlPostLine.Run(TempWhseJnlLine2);
                            until TempWhseJnlLine2.Next = 0;
                    end;
        end;
    end;


    local procedure PostWhseAltQtyAdjmt(var TempWhseJnlLine2: Record "Warehouse Journal Line" temporary)
    var
        TempWhseJnlLine: Record "Warehouse Journal Line";
        Item: Record Item;
        ItemLedgEntry: Record "Item Ledger Entry";
        WhseEntry: Record "Warehouse Entry";
    begin

        if not Location."Directed Put-away and Pick" then
            exit;

        TempWhseJnlLine := TempWhseJnlLine2;

        Item.Get(TempWhseJnlLine."Item No.");


        ItemLedgEntry.SetCurrentKey(
          "Item No.", "Variant Code", "Location Code", "Lot No.", "Serial No.", "Posting Date");
        ItemLedgEntry.SetRange("Item No.", TempWhseJnlLine."Item No.");
        ItemLedgEntry.SetRange("Variant Code", TempWhseJnlLine."Variant Code");
        ItemLedgEntry.SetRange("Location Code", TempWhseJnlLine."Location Code");
        ItemLedgEntry.SetRange("Lot No.", TempWhseJnlLine."Lot No.");
        ItemLedgEntry.SetRange("Serial No.", TempWhseJnlLine."Serial No.");
        ItemLedgEntry.CalcSums(Quantity);
        if (ItemLedgEntry.Quantity <> 0) then
            exit;


        WhseEntry.SetCurrentKey(
          "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code",
          "Lot No.", "Serial No.", "Entry Type");
        WhseEntry.SetRange("Item No.", TempWhseJnlLine."Item No.");
        WhseEntry.SetRange("Bin Code", Location."Adjustment Bin Code");
        WhseEntry.SetRange("Location Code", TempWhseJnlLine."Location Code");
        WhseEntry.SetRange("Variant Code", TempWhseJnlLine."Variant Code");
        WhseEntry.SetRange("Lot No.", TempWhseJnlLine."Lot No.");
        WhseEntry.SetRange("Serial No.", TempWhseJnlLine."Serial No.");
        WhseEntry.CalcSums("Qty. (Base)");
        if (WhseEntry."Qty. (Base)" <> 0) then
            exit;


        TempWhseJnlLine.Quantity := 0;
        TempWhseJnlLine."Qty. (Base)" := 0;
        TempWhseJnlLine."Qty. (Absolute)" := 0;
        TempWhseJnlLine."Qty. (Absolute, Base)" := 0;

        TempWhseJnlLine."Entry Type" := TempWhseJnlLine."Entry Type"::"Positive Adjmt.";
        if (TempWhseJnlLine."Entry Type" <> TempWhseJnlLine2."Entry Type") then begin
            TempWhseJnlLine."To Zone Code" := TempWhseJnlLine2."From Zone Code";
            TempWhseJnlLine."To Bin Code" := TempWhseJnlLine2."From Bin Code";
            TempWhseJnlLine."From Zone Code" := TempWhseJnlLine2."To Zone Code";
            TempWhseJnlLine."From Bin Code" := TempWhseJnlLine2."To Bin Code";
        end;

        WhseJnlPostLine.Run(TempWhseJnlLine);
    end;



    local procedure XferWhseRoundingAdjmts()
    var
        TempWhseAdjmtLine: Record "Warehouse Journal Line" temporary;
    begin

        /*IF ItemJnlPostLine.GetWhseRoundingAdjmts(TempWhseAdjmtLine) THEN BEGIN
          ItemJnlPostLine.ClearWhseRoundingAdjmts;
          RoundingAdjmtMgmt.SetWhseAdjmts(TempWhseAdjmtLine);
          WhseJnlPostLine.SetWhseRoundingAdjmts(TempWhseAdjmtLine);
        END;
        *///TBR

    end;

    local procedure PostWhseRoundingAdjmts()
    var
        WhseJnlLine: Record "Warehouse Journal Line";
    begin

        /*IF RoundingAdjmtMgmt.WhseAdjmtsToPost() THEN BEGIN
          WhseJnlPostLine.ClearWhseRoundingAdjmts;
          REPEAT
            RoundingAdjmtMgmt.BuildWhseAdjmtJnlLine(WhseJnlLine);
            WhseJnlPostLine.RUN(WhseJnlLine);
          UNTIL (NOT RoundingAdjmtMgmt.WhseAdjmtsToPost());
        END;*///TBR

    end;
}

