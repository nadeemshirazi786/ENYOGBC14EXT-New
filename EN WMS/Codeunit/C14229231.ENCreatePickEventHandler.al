codeunit 14229231 "Create Pick Event ELA"
{
    var
        Location: Record Location;
        NewWhseActivLine: Record "Warehouse Activity Line" temporary;

    [EventSubscriber(ObjectType::Codeunit, 7312, 'OnAfterCreateWhseDocument', '', true, true)]
    LOCAL procedure OnAfterCreateWhseDocument(VAR FirstWhseDocNo: Code[20]; VAR LastWhseDocNo: Code[20])
    var
        WhseActLine: Record "Warehouse Activity Line";
        QtyToBreak: Integer;
        WhseActLine2: Record "Warehouse Activity Line";
    begin
        WhseActLine.Reset();
        WhseActLine.SetRange("No.", FirstWhseDocNo, LastWhseDocNo);
        IF WhseActLine.FindSet() then
            repeat
                IF WhseActLine."Activity Type" = WhseActLine."Activity Type"::Pick then begin
                    IF WhseActLine."Action Type" = WhseActLine."Action Type"::Take then begin
                        SplitPickLines(WhseActLine);
                    end;
                end;
                WhseActLine.Delete();
            UNTIL WhseActLine.NEXT = 0;
        NewWhseActivLine.Reset();
        IF NewWhseActivLine.FindSet() then begin
            repeat
                WhseActLine2.INIT;
                WhseActLine2 := NewWhseActivLine;
                WhseActLine2.INSERT;
            until NewWhseActivLine.NEXT = 0;

        end;
    end;

    [EventSubscriber(ObjectType::Report, 7318, 'OnAfterCalculateQuantityToPick', '', true, true)]
    local procedure OnAfterCalculateQuantityToPick(VAR WarehouseShipmentLine: Record "Warehouse Shipment Line"; VAR QtyToPick: Decimal; VAR QtyToPickBase: Decimal)
    var
        Text14229220: Label 'Overshipping is not allowed';
    begin

        IF WarehouseShipmentLine."Qty. To Handle ELA" < 0 THEN BEGIN
            QtyToPickBase := 0;
            QtyToPick := 0;
        END;

        IF WarehouseShipmentLine."Qty. To Handle ELA" + WarehouseShipmentLine."Qty. Picked" + WarehouseShipmentLine."Pick Qty."
          > WarehouseShipmentLine.Quantity THEN
            ERROR(Text14229220);

        QtyToPickBase := WarehouseShipmentLine."Qty. To Handle (Base) ELA";
        QtyToPick := WarehouseShipmentLine."Qty. To Handle ELA";
    end;

    [EventSubscriber(ObjectType::Codeunit, 7307, 'OnAfterWhseShptLineModify', '', true, true)]
    procedure OnAfterWhseShptLineModify(VAR WarehouseShipmentLine: Record "Warehouse Shipment Line")
    var
        ShipmentDshBrd: Codeunit "Shipment Mgmt. ELA";
    begin

        //<<EN1.03
        IF WarehouseShipmentLine.Status = WarehouseShipmentLine.Status::"Completely Picked" THEN
            ShipmentDshBrd.UpdateProcessedLine(WarehouseShipmentLine."No.", WarehouseShipmentLine."Line No.", TRUE);

        ShipmentDshBrd.UpdateProcessedQty(WarehouseShipmentLine."No.", WarehouseShipmentLine."Line No.", WarehouseShipmentLine."Qty. Picked");

    end;

    [EventSubscriber(ObjectType::Codeunit, 7307, 'OnUpdateWhseShptLineOnBeforeWhseShptLineModify', '', true, true)]
    procedure OnUpdateWhseShptLineOnBeforeWhseShptLineModify(VAR WarehouseShipmentLine: Record "Warehouse Shipment Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
        If WarehouseShipmentLine.Status = WarehouseShipmentLine.Status::"Completely Picked" then
            WarehouseShipmentLine."Release to QC ELA" := True;
    end;

    local procedure SplitPickLines(WhseActivLine: Record "Warehouse Activity Line")
    var
        PalletSize: Integer;
        QtyToBreak: Integer;
        QtyToHandle: Integer;

        ContMgmt: Codeunit "Container Mgmt. ELA";
        WhseDocType: enum "Whse. Doc. Type ELA";
        GenerateAutoContainer: Boolean;
        ContainerNo: Code[20];
        TempWhseActivLine: Record "Warehouse Activity Line" temporary;
        ItemUOM: Record "Item Unit of Measure";
        WHShipLine: Record "Warehouse Shipment Line";
        ParentLineNo: Integer;
        WhseActPlaceLine: record "Warehouse Activity Line";
    begin

        ItemUOM.RESET;
        ItemUOM.SetFilter("Item No.", WhseActivLine."Item No.");
        ItemUOM.SetFilter("Is Bulk ELA", '%1', true);
        IF ItemUOM.FindFirst() then
            PalletSize := ItemUOM."Qty. per Unit of Measure";

        if PalletSize = 0 then
            PalletSize := 1;
        QtyToBreak := WhseActivLine."Qty. to Handle";

        WhseActPlaceLine.RESET;
        WhseActPlaceLine.SetRange("Activity Type", WhseActivLine."Activity Type");
        WhseActPlaceLine.SetRange("No.", WhseActivLine."No.");
        WhseActPlaceLine.SetRange("Source Document", WhseActivLine."Source Document");
        WhseActPlaceLine.SetRange("Source Line No.", WhseActivLine."Source Line No.");
        WhseActPlaceLine.SetRange("Action Type", WhseActivLine."Action Type"::Place);
        If WhseActPlaceLine.FINDFIRST THEN;
        repeat
            if QtyToBreak > PalletSize then begin
                QtyToBreak := QtyToBreak - PalletSize;
                QtyToHandle := PalletSize;
                GenerateAutoContainer := true;
            end else begin
                GenerateAutoContainer := false;
                QtyToHandle := QtyToBreak;
                QtyToBreak := 0;
            end;
            WHShipLine.RESET;
            WHShipLine.SetRange("Source No.", WhseActivLine."Source No.");
            WHShipLine.SetRange("Source Line No.", WhseActivLine."Source Line No.");
            WHShipLine.SetRange("Source Type", WhseActivLine."Source Type");
            WHShipLine.SetRange("Source Subtype", WhseActivLine."Source Subtype");
            IF WHShipLine.FindFirst() then begin
                WhseActivLine."Assigned App. Role ELA" := WHShipLine."Assigned App. Role ELA";
                WhseActivLine."Assigned App. User ELA" := WHShipLine."Assigned To ELA";
                WhseActivLine.Modify();
            END;
            ParentLineNo := CreateTempWhseLine(WhseActivLine, QtyToHandle, 2, 0); //TakeLine

            CreateTempWhseLine(WhseActPlaceLine, QtyToHandle, 1, ParentLineNo);    //PlaceLine

            if (QtyToBreak <= 0) then
                exit;
        until false;

    end;

    local procedure CreateTempWhseLine(WhseActivLine: Record "Warehouse Activity Line"; QtyToHandle: Decimal; ActionType: Option "",Place,Take; ParentLineNo: Integer): Integer
    var
        WMSMgt: Codeunit "WMS Management";

    begin
        NewWhseActivLine.INIT;
        NewWhseActivLine."Activity Type" := WhseActivLine."Activity Type";
        NewWhseActivLine."No." := WhseActivLine."No.";
        NewWhseActivLine."Line No." := GetLineNo(WhseActivLine."Action Type", WhseActivLine."No.", WhseActivLine."Line No.");
        NewWhseActivLine."Source Type" := WhseActivLine."Source Type";
        NewWhseActivLine."Source Subtype" := WhseActivLine."Source Subtype";
        NewWhseActivLine."Source No." := WhseActivLine."Source No.";
        NewWhseActivLine."Source Line No." := WhseActivLine."Source Line No.";
        NewWhseActivLine."Source Subline No." := WhseActivLine."Source Subline No.";
        NewWhseActivLine."Source Document" := WhseActivLine."Source Document";
        NewWhseActivLine."Location Code" := WhseActivLine."Location Code";
        NewWhseActivLine."Shelf No." := WhseActivLine."Shelf No.";
        NewWhseActivLine."Sorting Sequence No." := WhseActivLine."Sorting Sequence No.";
        NewWhseActivLine."Item No." := WhseActivLine."Item No.";
        NewWhseActivLine."Variant Code" := WhseActivLine."Variant Code";
        NewWhseActivLine."Unit of Measure Code" := WhseActivLine."Unit of Measure Code";
        NewWhseActivLine."Qty. per Unit of Measure" := WhseActivLine."Qty. per Unit of Measure";
        NewWhseActivLine."Description" := WhseActivLine."Description";
        NewWhseActivLine."Description 2" := WhseActivLine."Description 2";
        NewWhseActivLine.Quantity := QtyToHandle;
        NewWhseActivLine."Qty. (Base)" := QtyToHandle;
        NewWhseActivLine."Qty. Outstanding" := NewWhseActivLine.Quantity;
        NewWhseActivLine."Qty. Outstanding (Base)" := NewWhseActivLine."Qty. (Base)";
        NewWhseActivLine."Qty. to Handle" := NewWhseActivLine.Quantity;
        NewWhseActivLine."Qty. to Handle (Base)" := NewWhseActivLine."Qty. (Base)";
        NewWhseActivLine."Qty. Handled" := 0;
        NewWhseActivLine."Qty. Handled (Base)" := 0;
        GetLocation(WhseActivLine."Location Code");
        IF Location."Directed Put-away and Pick" THEN BEGIN
            WMSMgt.CalcCubageAndWeight(
              NewWhseActivLine."Item No.", NewWhseActivLine."Unit of Measure Code",
              NewWhseActivLine."Qty. to Handle", NewWhseActivLine.Cubage, NewWhseActivLine.Weight);
        END;
        NewWhseActivLine."Shipping Advice" := WhseActivLine."Shipping Advice";
        NewWhseActivLine."Due Date" := WhseActivLine."Due Date";
        NewWhseActivLine."Destination Type" := WhseActivLine."Destination Type";
        NewWhseActivLine."Destination No." := WhseActivLine."Destination No.";
        NewWhseActivLine."Shipping Agent Code" := WhseActivLine."Shipping Agent Code";
        NewWhseActivLine."Shipping Agent Service Code" := WhseActivLine."Shipping Agent Service Code";
        NewWhseActivLine."Shipment Method Code" := WhseActivLine."Shipment Method Code";
        NewWhseActivLine."Starting Date" := WhseActivLine."Starting Date";
        NewWhseActivLine."Assemble to Order" := WhseActivLine."Assemble to Order";
        NewWhseActivLine."ATO Component" := WhseActivLine."ATO Component";
        NewWhseActivLine."Serial No." := WhseActivLine."Serial No.";
        NewWhseActivLine."Lot No." := WhseActivLine."Lot No.";
        NewWhseActivLine."Warranty Date" := WhseActivLine."Warranty Date";
        NewWhseActivLine."Expiration Date" := WhseActivLine."Expiration Date";
        NewWhseActivLine."Serial No. Blocked" := WhseActivLine."Serial No. Blocked";
        NewWhseActivLine."Lot No. Blocked" := WhseActivLine."Lot No. Blocked";
        NewWhseActivLine."Action Type" := WhseActivLine."Action Type";
        NewWhseActivLine."Bin Code" := WhseActivLine."Bin Code";
        NewWhseActivLine."Zone Code" := WhseActivLine."Zone Code";
        NewWhseActivLine."Whse. Document Type" := WhseActivLine."Whse. Document Type";
        NewWhseActivLine."Whse. Document No." := WhseActivLine."Whse. Document No.";
        NewWhseActivLine."Whse. Document Line No." := WhseActivLine."Whse. Document Line No.";
        NewWhseActivLine."Bin Ranking" := WhseActivLine."Bin Ranking";

        NewWhseActivLine."Special Equipment Code" := WhseActivLine."Special Equipment Code";
        NewWhseActivLine."Bin Type Code" := WhseActivLine."Bin Type Code";
        NewWhseActivLine."Breakbulk No." := WhseActivLine."Breakbulk No.";
        NewWhseActivLine."Original Breakbulk" := WhseActivLine."Original Breakbulk";
        NewWhseActivLine.Breakbulk := WhseActivLine.Breakbulk;
        NewWhseActivLine."Cross-Dock Information" := WhseActivLine."Cross-Dock Information";
        NewWhseActivLine.Dedicated := WhseActivLine.Dedicated;
        NewWhseActivLine."Assigned App. Role ELA" := WhseActivLine."Assigned App. Role ELA";
        NewWhseActivLine."Assigned App. User ELA" := WhseActivLine."Assigned App. User ELA";
        NewWhseActivLine."Original Qty. ELA" := WhseActivLine."Original Qty. ELA";
        NewWhseActivLine."Released To Pick ELA" := WhseActivLine."Released To Pick ELA";
        NewWhseActivLine."Released At ELA" := WhseActivLine."Released At ELA";
        NewWhseActivLine."Prioritized ELA" := WhseActivLine."Prioritized ELA";
        NewWhseActivLine."Trip No. ELA" := WhseActivLine."Trip No. ELA";
        NewWhseActivLine."Ship Action ELA" := WhseActivLine."Ship Action ELA";
        NewWhseActivLine."Received By ELA" := WhseActivLine."Received By ELA";
        NewWhseActivLine."Received Date ELA" := WhseActivLine."Received Date ELA";
        NewWhseActivLine."Received Time ELA" := WhseActivLine."Received Time ELA";
        NewWhseActivLine."Container No. ELA" := WhseActivLine."Container No. ELA";
        NewWhseActivLine."Licnese Plate No. ELA" := WhseActivLine."Licnese Plate No. ELA";
        NewWhseActivLine."Container Line No. ELA" := WhseActivLine."Container Line No. ELA";
        If ParentLineNo = 0 then
            NewWhseActivLine."Parent Line No. ELA" := NewWhseActivLine."Line No."
        else
            NewWhseActivLine."Parent Line No. ELA" := ParentLineNo;
        /*NewWhseActivLine.Copy(TempWhseActivLine);
        NewWhseActivLine."Line No." := GetLastLineNo(WhseActivLine."Action Type", WhseActivLine."No.", WhseActivLine."Line No.");

        NewWhseActivLine.Quantity := QtyToHandle;
        NewWhseActivLine."Qty. (Base)" := QtyToHandle;
        NewWhseActivLine."Qty. Outstanding" := NewWhseActivLine.Quantity;
        NewWhseActivLine."Qty. Outstanding (Base)" := NewWhseActivLine."Qty. (Base)";
        NewWhseActivLine."Qty. to Handle" := NewWhseActivLine.Quantity;
        NewWhseActivLine."Qty. to Handle (Base)" := NewWhseActivLine."Qty. (Base)";
        NewWhseActivLine."Qty. Handled" := 0;
        NewWhseActivLine."Qty. Handled (Base)" := 0;
        GetLocation(WhseActivLine."Location Code");
        IF Location."Directed Put-away and Pick" THEN BEGIN
            WMSMgt.CalcCubageAndWeight(
              NewWhseActivLine."Item No.", NewWhseActivLine."Unit of Measure Code",
              NewWhseActivLine."Qty. to Handle", NewWhseActivLine.Cubage, NewWhseActivLine.Weight);
        END;
        /* ContainerNo := '';
           if GenerateAutoContainer then begin
               if NewWhseActivLine."Action Type" = NewWhseActivLine."Action Type"::Take then begin
                   ContainerNo := ContMgmt.CreateNewContainer('', NewWhseActivLine."Location Code", false);
                   ContMgmt.AddContentToContainer(ContainerNo, NewWhseActivLine."Item No.", NewWhseActivLine."Unit of Measure Code",
                    NewWhseActivLine.Quantity, '', NewWhseActivLine."Source No.", NewWhseActivLine."Line No.",
                   WhseDocType, NewWhseActivLine."Whse. Document No.", 2, NewWhseActivLine."No.", 0);
               end else
                   if NewWhseActivLine."Action Type" = NewWhseActivLine."Action Type"::Place then begin
                       TempWhseActivLine.Copy(NewWhseActivLine);
                       ContainerNo := GetTakeLineContainerNo(NewWhseActivLine."No.", NewWhseActivLine."Line No.");
                       NewWhseActivLine.Copy(TempWhseActivLine);
                   end;

           end;
         NewWhseActivLine.Validate("Container No.", ContainerNo);*/

        NewWhseActivLine.Insert();
        exit(NewWhseActivLine."Line No.");
    end;

    local procedure GetLineNo(ActionType: Option ,Take,Place; "Document No.": Code[20]; SourceLineNo: Integer) LineNo: Integer

    begin

        NewWhseActivLine.Reset();
        NewWhseActivLine.SetCurrentKey("Activity Type", "No.", "Line No.");
        //NewWhseActivLine.SetRange("Action Type", ActionType);
        NewWhseActivLine.SetRange("No.", "Document No.");
        If NewWhseActivLine.FindLast() then begin
            exit(NewWhseActivLine."Line No." + 10000);
        end else
            exit(SourceLineNo);
    end;

    local procedure GetLocation(LocationCode: Code[20])
    begin
        IF LocationCode = '' THEN
            CLEAR(Location)
        ELSE
            IF LocationCode <> Location.Code THEN
                Location.GET(LocationCode);
    end;


}