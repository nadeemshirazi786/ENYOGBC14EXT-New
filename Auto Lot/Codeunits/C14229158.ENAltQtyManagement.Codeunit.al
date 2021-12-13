/// <summary>
/// Codeunit Alt. Qty. Management ELA (ID 14229158).
/// </summary>
codeunit 14229158 "Alt. Qty. Management ELA"
{
    trigger OnRun()
    begin
    end;

    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        TrackItem: Boolean;
        TempAltQtyInvLineNo: Integer;
        TempExcessAltQtyLineNo: Integer;
        ReportingComplete: Boolean;
        SavedPerBaseAmount: array[100] of Decimal;
        SavedPerBaseAmountCount: Integer;
        Text001: Label 'Alternate Quantity detail has already been specified.';
        Text002: Label '%1 differs from the expected value of %2 by more than the %3 of %4 percent.\\%1 is expected to be between %5 and %6.\\Is %7 the correct quantity?';
        Text003: Label '%1 differs from the expected value of %2 by more than the %3 of %4 percent.\\Is %5 the correct quantity?';
        Text004: Label 'Please enter the correct %1.';
        Text005: Label 'You must specify %1 for %2 %3 %4.';
        Text006: Label '%1 must match the detail quantity of %2.';
        Text007: Label '<Precision,%1><Standard format,0>';
        Text008: Label '%1s exist for an associated %2 (Order %3).\\These lines must be deleted, the information is already specified on the %4.';
        SourceAltQtyTransNo: Integer;
        P800Globals: Codeunit "Process 800 System Globals ELA";
        Text009: Label 'Alternate quantity must be entered on the associated warehouse documents.';
        Text010: Label 'Alternate quantity must be entered on the Invt. Put-Away.';
        Text011: Label 'Alternate quantity must be entered on the Invt. Pick.';
        Text012: Label '%1 and %2 cannot have the same %3 %4.';
        Text013: Label '%1 %2 is assigned a Fixed Production Bin for %3 %4. %5 must be blank.';
        Text014: Label 'Alternate quantity must be entered for %1 %2.';
        IsActualAppliedAltQty: Boolean;
/// <summary>
/// InitAlternateQtyELA.
/// </summary>
/// <param name="ItemNo">Code[20].</param>
/// <param name="AltQtyTransactionNo">Integer.</param>
/// <param name="QtyBase">Decimal.</param>
/// <param name="QtyAlt">VAR Decimal.</param>
    procedure InitAlternateQtyELA(ItemNo: Code[20]; AltQtyTransactionNo: Integer; QtyBase: Decimal; var QtyAlt: Decimal)
    begin
        // InitAlternateQty
        GetItemELA(ItemNo);
        if Item."Catch Alternate Qtys. ELA" then
            QtyAlt := CalcAltQtyLinesQtyAlt1ELA(AltQtyTransactionNo)
        else
            QtyAlt := CalcAltQtyELA(ItemNo, QtyBase);
    end;
/// <summary>
/// CalcAltQtyLinesQtyAlt1ELA.
/// </summary>
/// <param name="AltQtyTransactionNo">Integer.</param>
/// <returns>Return value of type Decimal.</returns>
    procedure CalcAltQtyLinesQtyAlt1ELA(AltQtyTransactionNo: Integer): Decimal
    begin
        // CalcAltQtyLinesQtyAlt1
        if (AltQtyTransactionNo = 0) then
            exit(0);
        //AltQtyLine.SETRANGE("Alt. Qty. Transaction No.", AltQtyTransactionNo);
        //AltQtyLine.CALCSUMS("Quantity (Alt.)");
        //EXIT(AltQtyLine."Quantity (Alt.)");
    end;
/// <summary>
/// GetLocationELA.
/// </summary>
/// <param name="LocationCode">Code[20].</param>
/// <param name="Location">VAR Record Location.</param>
    procedure GetLocationELA(LocationCode: Code[20]; var Location: Record Location)
    var
        WhseSetup: Record "Warehouse Setup";
    begin
        // P8000282A
        Clear(Location);
        with Location do
            if not Get(LocationCode) then
                if WhseSetup.Get then begin
                    "Require Receive" := WhseSetup."Require Receive";
                    "Require Put-away" := WhseSetup."Require Put-away";
                    "Require Shipment" := WhseSetup."Require Shipment";
                    "Require Pick" := WhseSetup."Require Pick";
                end;
    end;

    local procedure GetItemELA(ItemNo: Code[20])
    begin
        // GetItem
        if (Item."No." <> ItemNo) then
            Item.Get(ItemNo);
        TrackItem := ItemTrackingCode.Get(Item."Item Tracking Code");
    end;

    local procedure CalcAltQtyELA(ItemNo: Code[20]; BaseQty: Decimal): Decimal
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        // CalcAltQty
        GetItemELA(ItemNo);
        if not Item.TrackAlternateUnits() then
            exit(0);
        ItemUnitOfMeasure.Get(ItemNo, Item."Alternate Unit of Measure ELA");
        ItemUnitOfMeasure.TestField("Qty. per Unit of Measure");
        exit(Round(BaseQty / ItemUnitOfMeasure."Qty. per Unit of Measure", 0.00001)); // PR3.61.01
    end;
/// <summary>
/// InitAlternateQtyToHandleELA.
/// </summary>
/// <param name="ItemNo">Code[20].</param>
/// <param name="AltQtyTransactionNo">Integer.</param>
/// <param name="BaseQty">Decimal.</param>
/// <param name="BaseQtyToHandle">Decimal.</param>
/// <param name="BaseQtyHandled">Decimal.</param>
/// <param name="AltQty">Decimal.</param>
/// <param name="AltQtyHandled">Decimal.</param>
/// <param name="AltQtyToHandle">VAR Decimal.</param>
    procedure InitAlternateQtyToHandleELA(ItemNo: Code[20]; AltQtyTransactionNo: Integer; BaseQty: Decimal; BaseQtyToHandle: Decimal; BaseQtyHandled: Decimal; AltQty: Decimal; AltQtyHandled: Decimal; var AltQtyToHandle: Decimal)
    begin
        
        GetItemELA(ItemNo);
        if Item."Catch Alternate Qtys. ELA" then
            AltQtyToHandle := CalcAltQtyLinesQtyAlt1ELA(AltQtyTransactionNo)
        else
            AltQtyToHandle :=
              CalcAltQtyToHandleELA(ItemNo, BaseQty, BaseQtyToHandle, BaseQtyHandled, AltQty, AltQtyHandled);
    end;
/// <summary>
/// CalcAltQtyToHandleELA.
/// </summary>
/// <param name="ItemNo">Code[20].</param>
/// <param name="BaseQty">Decimal.</param>
/// <param name="BaseQtyToHandle">Decimal.</param>
/// <param name="BaseQtyHandled">Decimal.</param>
/// <param name="AltQty">Decimal.</param>
/// <param name="AltQtyHandled">Decimal.</param>
/// <returns>Return value of type Decimal.</returns>
    local procedure CalcAltQtyToHandleELA(ItemNo: Code[20]; BaseQty: Decimal; BaseQtyToHandle: Decimal; BaseQtyHandled: Decimal; AltQty: Decimal; AltQtyHandled: Decimal): Decimal
    begin
        
        GetItemELA(ItemNo);
        if not Item.TrackAlternateUnits() then
            exit(0);
        if (BaseQtyToHandle = 0) then
            exit(0);
        //IF ((BaseQtyToHandle + BaseQtyHandled) = BaseQty) THEN // P8001393
        //  EXIT(AltQty - AltQtyHandled);                        // P8001393
        exit(CalcAltQtyELA(ItemNo, BaseQtyToHandle + BaseQtyHandled) - AltQtyHandled);
    end;
/// <summary>
/// SetTrackingLineAltQtyToInvoiceELA.
/// </summary>
/// <param name="TrackingLine">VAR Record "Tracking Specification".</param>
    procedure SetTrackingLineAltQtyToInvoiceELA(var TrackingLine: Record "Tracking Specification")
    var
        QtyNotInvoiced: Decimal;
    begin
        // SetTrackingLineAltQtyToInvoice
        with TrackingLine do begin
            if ("Qty. to Invoice (Base)" <= "Qty. to Handle (Base)") and ("Qty. to Handle (Base)" <> 0) then begin
                "Qty. to Invoice (Alt.) ELA" := "Qty. to Handle (Alt.) ELA" * "Qty. to Invoice (Base)" / "Qty. to Handle (Base)";
                "Qty. to Invoice (Alt.) ELA" := Round("Qty. to Invoice (Alt.) ELA", 0.00001);
            end else begin
                "Qty. to Invoice (Alt.) ELA" := "Qty. to Handle (Alt.) ELA";
                QtyNotInvoiced := "Quantity Handled (Base)" - "Quantity Invoiced (Base)";
                if QtyNotInvoiced <> 0 then begin
                    "Qty. to Invoice (Alt.) ELA" += ("Quantity Handled (Alt.) ELA" - "Quantity Invoiced (Alt.) ELA") *
                      ("Qty. to Invoice (Base)" - "Qty. to Handle (Base)") / QtyNotInvoiced;
                    "Qty. to Invoice (Alt.) ELA" := Round("Qty. to Invoice (Alt.) ELA", 0.00001);
                end;
            end;
        end;
    end;
/// <summary>
/// TestTrackingAltQtyInfoELA.
/// </summary>
/// <param name="TrackingLine">VAR Record "Tracking Specification".</param>
/// <param name="CatchAltQtysCheck">Boolean.</param>
    procedure TestTrackingAltQtyInfoELA(var TrackingLine: Record "Tracking Specification"; CatchAltQtysCheck: Boolean)
    begin
        // TestTrackingAltQtyInfo
        with TrackingLine do begin
            TestField("Item No.");
            GetItemELA("Item No.");
            Item.TestField("Alternate Unit of Measure ELA");
            //TESTFIELD("Quantity (Base)"); // PR3.61
            if CatchAltQtysCheck then
                Item.TestField("Catch Alternate Qtys. ELA", true);
        end;
    end;
/// <summary>
/// GetSourceAltQtyTransNoELA.
/// </summary>
/// <param name="TableNo">Integer.</param>
/// <param name="DocType">Integer.</param>
/// <param name="DocNo">Code[20].</param>
/// <param name="TempName">Code[10].</param>
/// <param name="BatchName">Code[10].</param>
/// <param name="SourceLineNo">Integer.</param>
/// <param name="Assign">Boolean.</param>
/// <returns>Return variable AltQtyTransNo of type Integer.</returns>
    procedure GetSourceAltQtyTransNoELA(TableNo: Integer; DocType: Integer; DocNo: Code[20]; TempName: Code[10]; BatchName: Code[10]; SourceLineNo: Integer; Assign: Boolean) AltQtyTransNo: Integer
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        ItemJnlLine: Record "Item Journal Line";
        TransferLine: Record "Transfer Line";
    begin
        // GetSourceAltQtyTransNo
        case TableNo of
            DATABASE::"Sales Line":
                begin
                    if not SalesLine.Get(DocType, DocNo, SourceLineNo) then
                        exit(0);
                    // P8000361A
                    GetItemELA(SalesLine."No.");
                    if not Item."Catch Alternate Qtys. ELA" then
                        exit(0);
                    // P8000361A
                    /*IF AssignNewTransactionNo(SalesLine."Alt. Qty. Transaction No.") THEN BEGIN
                      SalesLine.MODIFY;
                      COMMIT;
                    END;*/
                    //AltQtyTransNo := SalesLine."Alt. Qty. Transaction No.";
                end;

            DATABASE::"Purchase Line":
                begin
                    if not PurchLine.Get(DocType, DocNo, SourceLineNo) then
                        exit(0);
                    // P8000361A
                    GetItemELA(PurchLine."No.");
                    if not Item."Catch Alternate Qtys. ELA" then
                        exit(0);
                    // P8000361A
                    /*IF AssignNewTransactionNo(PurchLine."Alt. Qty. Transaction No.") THEN BEGIN
                      PurchLine.MODIFY;
                      COMMIT;
                    END;*/
                    //AltQtyTransNo := PurchLine."Alt. Qty. Transaction No.";
                end;

            DATABASE::"Item Journal Line":
                begin
                    if not ItemJnlLine.Get(TempName, BatchName, SourceLineNo) then
                        exit(0);
                    // P8000361A
                    GetItemELA(ItemJnlLine."Item No.");
                    if not Item."Catch Alternate Qtys. ELA" then
                        exit(0);
                    // P8000361A
                    /*IF AssignNewTransactionNo(ItemJnlLine."Alt. Qty. Transaction No.") THEN BEGIN
                      ItemJnlLine.MODIFY;
                      COMMIT;
                    END;
                    AltQtyTransNo := ItemJnlLine."Alt. Qty. Transaction No.";*/
                end;

            // PR3.61.01 Begin
            DATABASE::"Transfer Line":
                begin
                    if not TransferLine.Get(DocNo, SourceLineNo) then
                        exit(0);
                    // P8000361A
                    GetItemELA(TransferLine."Item No.");
                    if not Item."Catch Alternate Qtys. ELA" then
                        exit(0);
                    // P8000361A
                    case DocType of
                        0:
                            begin
                                /*IF AssignNewTransactionNo(TransferLine."Alt. Qty. Trans. No. (Ship)") THEN BEGIN
                                  TransferLine.MODIFY;
                                  COMMIT;
                                END;
                                AltQtyTransNo := TransferLine."Alt. Qty. Trans. No. (Ship)";*/
                            end;
                        1:
                            begin
                                /*IF AssignNewTransactionNo(TransferLine."Alt. Qty. Trans. No. (Receive)") THEN BEGIN
                                  TransferLine.MODIFY;
                                  COMMIT;
                                END;
                                AltQtyTransNo := TransferLine."Alt. Qty. Trans. No. (Receive)";*/
                            end;
                    end;
                end;
        // PR3.61.01 End
        end;

    end;
/// <summary>
/// CheckSummaryTolerance2ELA.
/// </summary>
/// <param name="AltQtyTransactionNo">Integer.</param>
/// <param name="ItemNo">Code[20].</param>
/// <param name="SerialNo">Code[50].</param>
/// <param name="LotNo">Code[50].</param>
/// <param name="SourceFieldName">Text[250].</param>
/// <param name="BaseQty">Decimal.</param>
/// <param name="AlternateQty">Decimal.</param>
    procedure CheckSummaryTolerance2ELA(AltQtyTransactionNo: Integer; ItemNo: Code[20]; SerialNo: Code[50]; LotNo: Code[50]; SourceFieldName: Text[250]; BaseQty: Decimal; AlternateQty: Decimal)
    begin
        /*// CheckSummaryTolerance2
        IF (AltQtyTransactionNo <> 0) THEN BEGIN
          AltQtyLine.SETCURRENTKEY("Alt. Qty. Transaction No.","Serial No.","Lot No.");
          AltQtyLine.SETRANGE("Alt. Qty. Transaction No.", AltQtyTransactionNo);
          AltQtyLine.SETRANGE("Serial No.",SerialNo);
          AltQtyLine.SETRANGE("Lot No.",LotNo);
          IF (AltQtyLine.COUNT > 1) THEN
            EXIT;
        END;
        CheckTolerance(ItemNo, SourceFieldName, BaseQty, AlternateQty);
        */

    end;
/// <summary>
/// SetTrackingLineAltQtyELA.
/// </summary>
/// <param name="TrackingLine">VAR Record "Tracking Specification".</param>
    procedure SetTrackingLineAltQtyELA(var TrackingLine: Record "Tracking Specification")
    var
        AltQtyTransNo: Integer;
    begin
        // SetTrackingLineAltQty
        with TrackingLine do begin
            GetItemELA("Item No.");
            if not Item.TrackAlternateUnits then
                "Quantity (Alt.) ELA" := 0
            else
                if Item."Catch Alternate Qtys. ELA" then begin // PR3.61
                                                               //AltQtyTransNo := GetSourceAltQtyTransNo("Source Type",DocumentType,DocumentNo,TemplateName,
                                                               //BatchName,"Source Ref. No.",FALSE);
                    if AltQtyTransNo <> 0 then begin
                        if "Qty. to Handle (Base)" = CalcAltQtyLinesQtyBase2ELA(AltQtyTransNo, "Serial No.", "Lot No.") then
                            "Quantity (Alt.) ELA" := "Quantity Handled (Alt.) ELA" + "Qty. to Handle (Alt.) ELA" +
                              CalcAltQtyELA("Item No.", "Quantity (Base)" - "Qty. to Handle (Base)" - "Quantity Handled (Base)")
                        else
                            "Quantity (Alt.) ELA" := "Quantity Handled (Alt.) ELA" +
                              CalcAltQtyELA("Item No.", "Quantity (Base)" - "Quantity Handled (Base)");
                        SetTrackingLineAltQtyToInvoiceELA(TrackingLine);
                    end;
                    // PR3.61 Begin
                end else begin
                    
                    // "Qty. to Handle (Alt.)" := CalcAltQty("Item No.","Qty. to Handle (Base)");
                    // "Quantity (Alt.)" := "Quantity Handled (Alt.)" +
                    //   CalcAltQty("Item No.","Quantity (Base)" - "Quantity Handled (Base)");
                    if ("Quantity Handled (Base)" = "Quantity (Base)") then
                        "Quantity (Alt.) ELA" := "Quantity Handled (Alt.) ELA"
                    else
                        "Quantity (Alt.) ELA" := CalcAltQtyELA("Item No.", "Quantity (Base)");
                    "Qty. to Handle (Alt.) ELA" :=
                      CalcAltQtyToHandleELA("Item No.", "Quantity (Base)", "Qty. to Handle (Base)",
                                         "Quantity Handled (Base)", "Quantity (Alt.) ELA", "Quantity Handled (Alt.) ELA");
                    
                    SetTrackingLineAltQtyToInvoiceELA(TrackingLine);
                    // PR3.61 End
                end;
        end;
    end;
/// <summary>
/// CalcAltQtyLinesQtyBase2ELA.
/// </summary>
/// <param name="AltQtyTransactionNo">Integer.</param>
/// <param name="SerialNo">Code[50].</param>
/// <param name="LotNo">Code[50].</param>
/// <returns>Return value of type Decimal.</returns>
    procedure CalcAltQtyLinesQtyBase2ELA(AltQtyTransactionNo: Integer; SerialNo: Code[50]; LotNo: Code[50]): Decimal
    begin
        // CalcAltQtyLinesQtyBase2
        /*IF (AltQtyTransactionNo = 0) THEN
          EXIT(0);
        AltQtyLine.SETCURRENTKEY("Alt. Qty. Transaction No.","Serial No.","Lot No.");
        AltQtyLine.SETRANGE("Alt. Qty. Transaction No.", AltQtyTransactionNo);
        AltQtyLine.SETRANGE("Serial No.",SerialNo);
        AltQtyLine.SETRANGE("Lot No.",LotNo);
        AltQtyLine.CALCSUMS("Quantity (Base)");
        EXIT(AltQtyLine."Quantity (Base)");
        */

    end;
/// <summary>
/// ValidateTrackingAltQtyLineELA.
/// </summary>
/// <param name="TrackingLine">VAR Record "Tracking Specification".</param>
    procedure ValidateTrackingAltQtyLineELA(var TrackingLine: Record "Tracking Specification")
    begin
        // ValidateTrackingAltQtyLine
        TrackingLine.TestAltQtyEntryELA; // P8000282A
        StartTrackingAltQtyLineELA(TrackingLine);
        /*AltQtyLine.SETRANGE("Alt. Qty. Transaction No.",SourceAltQtyTransNo);
        AltQtyLine.SETRANGE("Serial No.",TrackingLine."Serial No.");
        AltQtyLine.SETRANGE("Lot No.",TrackingLine."Lot No.");
        CASE AltQtyLine.COUNT OF
          0 :
            CreateTrackingAltQtyLine(TrackingLine);
          1 :
            BEGIN
              AltQtyLine.FIND('-');
              UpdateTrackingAltQtyLine(TrackingLine, AltQtyLine);
            END;
          ELSE
            BEGIN
              MESSAGE(Text001);
              ShowTrackingAltQtyLines(TrackingLine);
            END;
        END;
        */

    end;
/// <summary>
/// StartTrackingAltQtyLineELA.
/// </summary>
/// <param name="TrackingLine">VAR Record "Tracking Specification".</param>
    local procedure StartTrackingAltQtyLineELA(var TrackingLine: Record "Tracking Specification")
    begin
        // StartTrackingAltQtyLine
        TestTrackingAltQtyInfoELA(TrackingLine, true);
        with TrackingLine do begin
            GetItemELA("Item No.");
            SourceAltQtyTransNo := GetSourceAltQtyTransNoELA(
            "Source Type", DocumentTypeELA, DocumentNoELA, TemplateNameELA, BatchNameELA, "Source Ref. No.", true);
        end;
    end;
/// <summary>
/// ShowTrackingAltQtyLinesELA.
/// </summary>
/// <param name="TrackingLine">VAR Record "Tracking Specification".</param>
    procedure ShowTrackingAltQtyLinesELA(var TrackingLine: Record "Tracking Specification")
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        // ShowTrackingAltQtyLines
        Commit;
        TrackingLine.TestAltQtyEntryELA; // P8000282A
        StartTrackingAltQtyLineELA(TrackingLine);
        /*WITH TrackingLine DO BEGIN
          AltQtyForm.SetSource("Source Type",DocumentType,
                               DocumentNo,TemplateName,BatchName,"Source Ref. No.");
          AltQtyForm.SetQty("Qty. to Handle (Base)", FIELDCAPTION("Qty. to Handle (Base)"));
          AltQtyForm.SetMaxQty("Quantity (Base)" - "Quantity Handled (Base)");
          Item.GET("Item No.");
          IF Item."Item Tracking Code" <> '' THEN BEGIN
            ItemTrackingCode.GET(Item."Item Tracking Code");
            IF ItemTrackingCode."SN Specific Tracking" THEN
              TESTFIELD("Serial No.");
            IF ItemTrackingCode."Lot Specific Tracking" THEN BEGIN // P8000566A
              TESTFIELD("Lot No.");
              IF IsReclass THEN                                    // P8000566A
                TESTFIELD("New Lot No.");                          // P8000566A
            END;                                                   // P8000566A
            AltQtyForm.SetTracking(ItemTrackingCode."SN Specific Tracking",ItemTrackingCode."Lot Specific Tracking");
          END;
          AltQtyLine.FILTERGROUP(4);
          AltQtyLine.SETRANGE("Alt. Qty. Transaction No.",SourceAltQtyTransNo);
          AltQtyLine.SETRANGE("Serial No.","Serial No.");
          AltQtyLine.SETRANGE("Lot No.","Lot No.");
          AltQtyLine.FILTERGROUP(0);
          AltQtyForm.SETTABLEVIEW(AltQtyLine);
          AltQtyForm.SetLotAndSerial("Lot No.","Serial No.");
          AltQtyForm.SetNewLot("New Lot No."); // P8000566A
          AltQtyForm.RUNMODAL;
        END;*/
        UpdateTrackingLineELA(TrackingLine);

    end;
/// <summary>
/// UpdateTrackingLineELA.
/// </summary>
/// <param name="TrackingLine">VAR Record "Tracking Specification".</param>
    local procedure UpdateTrackingLineELA(var TrackingLine: Record "Tracking Specification")
    begin
        // UpdatetrackingLine
        with TrackingLine do begin
            Validate("Qty. to Handle (Alt.) ELA", CalcAltQtyLinesQtyAlt2ELA(SourceAltQtyTransNo, "Serial No.", "Lot No."));
            //IF AltQtyLinesExist(SourceAltQtyTransNo) THEN
            Validate("Qty. to Handle (Base)", CalcAltQtyLinesQtyBase2ELA(SourceAltQtyTransNo, "Serial No.", "Lot No."));
            if "Source Type" = DATABASE::"Item Journal Line" then
                Validate("Quantity (Base)", "Qty. to Handle (Base)");
            Modify;
        end;
    end;
/// <summary>
/// CalcAltQtyLinesQtyAlt2ELA.
/// </summary>
/// <param name="AltQtyTransactionNo">Integer.</param>
/// <param name="SerialNo">Code[50].</param>
/// <param name="LotNo">Code[50].</param>
/// <returns>Return value of type Decimal.</returns>
    procedure CalcAltQtyLinesQtyAlt2ELA(AltQtyTransactionNo: Integer; SerialNo: Code[50]; LotNo: Code[50]): Decimal
    begin
        // CalcAltQtyLinesQtyAlt2
        if (AltQtyTransactionNo = 0) then
            exit(0);
        /*AltQtyLine.SETCURRENTKEY("Alt. Qty. Transaction No.","Serial No.","Lot No.");
        AltQtyLine.SETRANGE("Alt. Qty. Transaction No.", AltQtyTransactionNo);
        AltQtyLine.SETRANGE("Serial No.",SerialNo);
        AltQtyLine.SETRANGE("Lot No.",LotNo);
        AltQtyLine.CALCSUMS("Quantity (Alt.)");*/
        //EXIT(AltQtyLine."Quantity (Alt.)");

    end;
/// <summary>
/// TestPurchAltQtyInfoELA.
/// </summary>
/// <param name="PurchLine">VAR Record "Purchase Line".</param>
/// <param name="CatchAltQtysCheck">Boolean.</param>
    procedure TestPurchAltQtyInfoELA(var PurchLine: Record "Purchase Line"; CatchAltQtysCheck: Boolean)
    begin
        // TestPurchAltQtyInfo
        PurchLine.TestField(Type, PurchLine.Type::Item);
        PurchLine.TestField("No.");
        GetItemELA(PurchLine."No.");
        Item.TestField("Alternate Unit of Measure ELA");
        if GetPurchShipReceiveQtyELA(PurchLine, PurchLine.FieldNo("Qty. to Receive (Alt.) ELA")) <> 0 then // PR3.61.01
            PurchLine.TestField("Outstanding Quantity");
        if CatchAltQtysCheck then
            Item.TestField("Catch Alternate Qtys. ELA", true);

    end;

    local procedure GetPurchShipReceiveQtyELA(var PurchLine: Record "Purchase Line"; FldNo: Integer): Decimal
    begin
        // GetPurchShipReceiveQty
        with PurchLine do begin
            if ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]) then
                case FldNo of
                    FieldNo("Qty. to Receive"):
                        exit("Return Qty. to Ship");
                    FieldNo("Qty. to Receive (Base)"):
                        exit("Return Qty. to Ship (Base)");
                    FieldNo("Qty. to Receive (Alt.) ELA"):
                        exit("Return Qty. to Ship (Alt.) ELA");
                    FieldNo("Quantity Received"):
                        exit("Return Qty. Shipped");
                    FieldNo("Qty. Received (Base)"):
                        exit("Return Qty. Shipped (Base)");
                    FieldNo("Qty. Received (Alt.) ELA"):
                        exit("Return Qty. Shipped (Alt.) ELA");
                end;
            case FldNo of
                FieldNo("Qty. to Receive"):
                    exit("Qty. to Receive");
                FieldNo("Qty. to Receive (Base)"):
                    exit("Qty. to Receive (Base)");
                FieldNo("Qty. to Receive (Alt.) ELA"):
                    exit("Qty. to Receive (Alt.) ELA");
                FieldNo("Quantity Received"):
                    exit("Quantity Received");
                FieldNo("Qty. Received (Base)"):
                    exit("Qty. Received (Base)");
                FieldNo("Qty. Received (Alt.) ELA"):
                    exit("Qty. Received (Alt.) ELA");
            end;
        end;
    end;
/// <summary>
/// CheckSummaryTolerance1ELA.
/// </summary>
/// <param name="AltQtyTransactionNo">Integer.</param>
/// <param name="ItemNo">Code[20].</param>
/// <param name="SourceFieldName">Text[250].</param>
/// <param name="BaseQty">Decimal.</param>
/// <param name="AlternateQty">Decimal.</param>
    procedure CheckSummaryTolerance1ELA(AltQtyTransactionNo: Integer; ItemNo: Code[20]; SourceFieldName: Text[250]; BaseQty: Decimal; AlternateQty: Decimal)
    begin
        // CheckSummaryTolerance1
        if (AltQtyTransactionNo <> 0) then begin
            //  AltQtyLine.SETRANGE("Alt. Qty. Transaction No.", AltQtyTransactionNo);
            //IF (AltQtyLine.COUNT > 1) THEN
            //EXIT;
        end;
        CheckToleranceELA(ItemNo, SourceFieldName, BaseQty, AlternateQty);
    end;
/// <summary>
/// CheckToleranceELA.
/// </summary>
/// <param name="ItemNo">Code[20].</param>
/// <param name="AltFieldName">Text[250].</param>
/// <param name="BaseQty">Decimal.</param>
/// <param name="AlternateQty">Decimal.</param>
    procedure CheckToleranceELA(ItemNo: Code[20]; AltFieldName: Text[250]; BaseQty: Decimal; AlternateQty: Decimal)
    var
        ExpectedAltQty: Decimal;
        ToleranceAltQty: Decimal;
        ErrorMsg: Text[250];
    begin
        // CheckTolerance
        // P8000310A
        if CheckTolerance1ELA(ItemNo, BaseQty, AlternateQty, ExpectedAltQty, ToleranceAltQty) then
            exit;

        //GetItem(ItemNo);
        //IF (Item."Alternate Qty. Tolerance %" = 0) THEN
        //  EXIT;
        //ExpectedAltQty := CalcAltQty(ItemNo, BaseQty);
        //ToleranceAltQty := ABS(ExpectedAltQty) * Item."Alternate Qty. Tolerance %" / 100;
        //IF (ABS(AlternateQty - ExpectedAltQty) > ToleranceAltQty) THEN BEGIN
        // P8000310A
        ExpectedAltQty := Round(ExpectedAltQty, 0.00001);
        ToleranceAltQty := Round(ToleranceAltQty, 0.00001);
        /*IF (ExpectedAltQty <> 0) THEN
          ErrorMsg :=
            STRSUBSTNO(
              Text002, AltFieldName, ExpectedAltQty,
              Item.FIELDCAPTION("Alternate Qty. Tolerance %"), Item."Alternate Qty. Tolerance %",
              ExpectedAltQty - ToleranceAltQty, ExpectedAltQty + ToleranceAltQty, AlternateQty)
        ELSE
          ErrorMsg :=
            STRSUBSTNO(
              Text003, AltFieldName, ExpectedAltQty,
              Item.FIELDCAPTION("Alternate Qty. Tolerance %"),
              Item."Alternate Qty. Tolerance %", AlternateQty);
        IF NOT CONFIRM(ErrorMsg, FALSE) THEN
          ERROR(Text004, AltFieldName);
        //END;
        */

    end;
/// <summary>
/// CheckTolerance1ELA.
/// </summary>
/// <param name="ItemNo">Code[20].</param>
/// <param name="BaseQty">Decimal.</param>
/// <param name="AlternateQty">Decimal.</param>
/// <param name="ExpectedAltQty">VAR Decimal.</param>
/// <param name="ToleranceAltQty">VAR Decimal.</param>
/// <returns>Return value of type Boolean.</returns>
    procedure CheckTolerance1ELA(ItemNo: Code[20]; BaseQty: Decimal; AlternateQty: Decimal; var ExpectedAltQty: Decimal; var ToleranceAltQty: Decimal): Boolean
    begin
        // P8000310A
        GetItemELA(ItemNo);
        //IF (Item."Alternate Qty. Tolerance %" = 0) THEN
        //EXIT(TRUE);
        ExpectedAltQty := CalcAltQtyELA(ItemNo, BaseQty);
        //ToleranceAltQty := ABS(ExpectedAltQty) * Item."Alternate Qty. Tolerance %" / 100;
        exit(Abs(AlternateQty - ExpectedAltQty) <= ToleranceAltQty);
    end;
/// <summary>
/// SetPurchLineAltQtyELA.
/// </summary>
/// <param name="PurchLine">VAR Record "Purchase Line".</param>
    procedure SetPurchLineAltQtyELA(var PurchLine: Record "Purchase Line")
    var
        OldQtyAlt: Decimal;
        CheckSuspended: Boolean;
        IsNotOrderLine: Boolean;
    begin
        // SetPurchLineAltQty
        //with PurchLine do
        if (PurchLine.Type <> PurchLine.Type::Item) or (PurchLine."No." = '') then
            PurchLine."Quantity (Alt.) ELA" := 0
        else begin
            GetItemELA(PurchLine."No.");
            IsNotOrderLine := (PurchLine."Receipt No." <> '') or (PurchLine."Return Shipment No." <> '');
            if not Item.TrackAlternateUnits() then
                PurchLine."Quantity (Alt.) ELA" := 0
            else begin
                OldQtyAlt := PurchLine."Quantity (Alt.) ELA";
                
                if not Item."Catch Alternate Qtys. ELA" then begin
                    
                    //"Quantity (Alt.)" := CalcAltQty("No.", "Quantity (Base)")
                    PurchLine."Quantity (Alt.) ELA" := CalcAltQtyELA(PurchLine."No.", PurchLine.Quantity * PurchLine."Qty. per Unit of Measure")
                    
                end else begin
                    
                    //IF (GetPurchShipReceiveQty(PurchLine, FIELDNO("Qty. to Receive (Base)")) =
                    //  ROUND(CalcAltQtyLinesQtyBase1("Alt. Qty. Transaction No."),0.00001)) // P8000392A
                    //THEN
                    PurchLine."Quantity (Alt.) ELA" :=
                      GetPurchShipReceiveQtyELA(PurchLine, PurchLine.FieldNo("Qty. Received (Alt.) ELA")) +
                      GetPurchShipReceiveQtyELA(PurchLine, PurchLine.FieldNo("Qty. to Receive (Alt.) ELA")) +
                      CalcAltQtyELA(PurchLine."No.",
                        (PurchLine."Outstanding Quantity" - GetPurchShipReceiveQtyELA(PurchLine, PurchLine.FieldNo("Qty. to Receive"))) *  // PR3.60.03
                        PurchLine."Qty. per Unit of Measure")                                                                 // PR3.60.03
                                                                                                                              //ELSE
                end;
                
                if not IsNotOrderLine then
                    PurchLine."Quantity (Alt.) ELA" :=
                      GetPurchShipReceiveQtyELA(PurchLine, PurchLine.FieldNo("Qty. Received (Alt.) ELA")) +
                      CalcAltQtyELA(PurchLine."No.", PurchLine."Outstanding Quantity" * PurchLine."Qty. per Unit of Measure") // PR3.60.03
                else
                    PurchLine."Quantity (Alt.) ELA" :=
                      GetPurchShipReceiveQtyELA(PurchLine, PurchLine.FieldNo("Qty. Received (Alt.) ELA"));
                
                
                if (PurchLine."Quantity (Alt.) ELA" <> OldQtyAlt) then begin
                    PurchLine.Validate("Quantity (Alt.) ELA");
                    //IF Item.CostInAlternateUnits() THEN BEGIN // P8000554A
                    //UpdateAmounts;                    // P8000344A
                    //CheckSuspended := PurchLine.SuspendStatusCheck(TRUE); // P8000344A, P8006787
                    PurchLine.Validate("Line Discount %");        // P8000344A
                    PurchLine.SuspendStatusCheck(CheckSuspended); // P8000638, P8006787
                                                                  //END;                                      // P8000554A
                                                                  //"Alt. Qty. Update Required" := TRUE; // P8000282A
                end;
                

                SetPurchLineAltQtyToInvoiceELA(PurchLine);
            end;
        end;

        //SetPurchLineWeights(PurchLine);
    end;

    local procedure SetPurchLineAltQtyToInvoiceELA(var PurchLine: Record "Purchase Line")
    var
        PostedQtyToInvBase: Decimal;
    begin
        // SetPurchLineAltQtyToInvoice
        /*WITH PurchLine DO
          // P8000282A
          IF ("Qty. to Invoice" =
                (GetPurchShipReceiveQty(PurchLine, FIELDNO("Quantity Received")) +
                 GetPurchShipReceiveQty(PurchLine, FIELDNO("Qty. to Receive"))))
          THEN
            "Qty. to Invoice (Alt.)" :=
              GetPurchShipReceiveQty(PurchLine, FIELDNO("Qty. Received (Alt.)")) +
              GetPurchShipReceiveQty(PurchLine, FIELDNO("Qty. to Receive (Alt.)"))
          // P8000282A
          ELSE IF NOT Item."Catch Alternate Qtys." THEN
            
            // "Qty. to Invoice (Alt.)" := CalcAltQty("No.", "Qty. to Invoice" * "Qty. per Unit of Measure") // PR3.60.03
            {IF ("Qty. to Invoice" = GetPurchShipReceiveQty(PurchLine, FIELDNO("Qty. to Receive"))) THEN
              "Qty. to Invoice (Alt.)" := GetPurchShipReceiveQty(PurchLine, FIELDNO("Qty. to Receive (Alt.)"))
            ELSE IF NOT TrackItem THEN
              "Qty. to Invoice (Alt.)" :=
                CalcAltQtyToHandle("No.", "Quantity (Base)", "Qty. to Invoice (Base)",
                                   "Qty. Invoiced (Base)", "Quantity (Alt.)", "Qty. Invoiced (Alt.)")
            ELSE
              "Qty. to Invoice (Alt.)" :=
                ABS(AltQtyTracking.GetAltQtyToInvoice(
                  DATABASE::"Purchase Line", "Document No.", "Document Type", '', 0, "Line No."))}
            
          ELSE IF NOT TrackItem THEN BEGIN
            CalcAltQtyToInvoice(
              "No.", "Alt. Qty. Transaction No.", "Qty. to Invoice" * "Qty. per Unit of Measure",         // PR3.60.03
              GetPurchShipReceiveQty(PurchLine, FIELDNO("Qty. to Receive")) * "Qty. per Unit of Measure", // PR3.60.03
              "Qty. to Invoice (Alt.)", PostedQtyToInvBase);
            IF (PostedQtyToInvBase <> 0) THEN
              IF ("Document Type" IN ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]) THEN
                "Qty. to Invoice (Alt.)" := "Qty. to Invoice (Alt.)" +
                  CalcReturnShptQtyAlt(PurchLine, PostedQtyToInvBase)
              ELSE
                "Qty. to Invoice (Alt.)" := "Qty. to Invoice (Alt.)" +
                  CalcReceiptQtyAlt(PurchLine, PostedQtyToInvBase);
          END ELSE BEGIN
            "Qty. to Invoice (Alt.)" :=
              ABS(AltQtyTracking.GetAltQtyToInvoice(DATABASE::"Purchase Line","Document No.","Document Type",'',0,"Line No."));
          END;
          */

    end;
}

