codeunit 14228831 "User-Def Events ELA"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, 5763, 'OnInitSourceDocumentHeaderOnBeforeSalesHeaderModify', '', true, true)]
    local procedure OnInitSourceDocumentHeader(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var SalesHeader: Record "Sales Header"; var ModifyHeader: Boolean)
    begin
        IF (WarehouseShipmentHeader."Seal No. ELA" <> '') AND
           (WarehouseShipmentHeader."Seal No. ELA" <> SalesHeader."Seal No. ELA")
        THEN BEGIN
            SalesHeader."Seal No. ELA" := WarehouseShipmentHeader."Seal No. ELA";
            SalesHeader.Modify(true);
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5771, 'OnBeforeCreateWhseRequest', '', true, true)]
    local procedure OnBeforeCreateWhseRequest(var SalesHeader: Record "Sales Header"; var WhseRqst: Record "Warehouse Request")
    begin
        WhseRqst."Seal No. ELA" := SalesHeader."Seal No. ELA";
    end;

    [EventSubscriber(ObjectType::Report, 5753, 'OnAfterCreateShptHeader', '', true, true)]
    local procedure AfterCreateShptHeader(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; WarehouseRequest: Record "Warehouse Request")
    begin
        WarehouseShipmentHeader."Seal No. ELA" := WarehouseRequest."Seal No. ELA";
        WarehouseShipmentHeader."Pallet Code ELA" := WarehouseRequest."Pallet Code ELA";
    end;

    [EventSubscriber(ObjectType::Codeunit, 7380, 'OnBeforeCreatePhysInvtItemJnl', '', true, true)]
    local procedure BeforeCalcInvtQtyOnHand(var IsHandled: Boolean; var TempPhysInvtItemSelection: Record "Phys. Invt. Item Selection"; var ItemJournalLine: Record "Item Journal Line")
    var
        loptCalcInvBy: Option "Location","Loc./Bin/Lot/Serial No.","Loc./Lot/Serial No.";
        lrptCalcInvByBinLotSerial: Report "Calc. Inv Loc/Bin/Lot/Ser. ELA";
        lrecBinContent: Record "Bin Content";
        lrptCalcInvByLotSerial: Report "Calc. Inv. Loc./Lot/Serial ELA";
        CalcQtyOnHand: Report "Calculate Inventory";
        Item: Record Item;
        PhysInvtCountRep: Report "Calc. Phys. Invt. Count. ELA";
        ItemJnlBatch: Record "Item Journal Batch";
        PhysInvtList: Report "Phys. Inventory List";
        Window: Dialog;
        PostingDate: Date;
        DocNo: Code[20];
        PrintDoc: Boolean;
        PrintDocPerItem: Boolean;
        ZeroQty: Boolean;
        PrintQtyCalculated: Boolean;
        SortingMethod: Option "","Item","Bin";
        Text000: TextConst ENU = 'Processing items    #1##########';
    begin
        ItemJnlBatch.GET(
          ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
        PhysInvtCountRep.SetItemJnlLine(ItemJnlBatch);
        PhysInvtCountRep.RUNMODAL;

        IF PhysInvtCountRep.GetRequest(
             PostingDate, DocNo, SortingMethod, PrintDoc, PrintDocPerItem, ZeroQty, PrintQtyCalculated)
        THEN BEGIN
            PhysInvtCountRep.jfGetRequestRprtOption(loptCalcInvBy);

            Window.OPEN(Text000, TempPhysInvtItemSelection."Item No.");
            REPEAT
                Window.UPDATE;
                CASE loptCalcInvBy OF
                    loptCalcInvBy::Location:
                        BEGIN // this is the base Nav default
                            CalcQtyOnHand.SetSkipDim(TRUE);
                            CalcQtyOnHand.InitializeRequest(PostingDate, DocNo, ZeroQty, false);
                            CalcQtyOnHand.SetItemJnlLine(ItemJournalLine);
                            CalcQtyOnHand.InitializePhysInvtCount(
                              TempPhysInvtItemSelection."Phys Invt Counting Period Code",
                              TempPhysInvtItemSelection."Phys Invt Counting Period Type");
                            CalcQtyOnHand.USEREQUESTPAGE(FALSE);
                            CalcQtyOnHand.SetHideValidationDialog(TRUE);
                            Item.SETRANGE("No.", TempPhysInvtItemSelection."Item No.");
                            IF TempPhysInvtItemSelection."Phys Invt Counting Period Type" =
                               TempPhysInvtItemSelection."Phys Invt Counting Period Type"::SKU
                            THEN BEGIN
                                Item.SETRANGE("Variant Filter", TempPhysInvtItemSelection."Variant Code");
                                Item.SETRANGE("Location Filter", TempPhysInvtItemSelection."Location Code");
                            END;
                            CalcQtyOnHand.SETTABLEVIEW(Item);
                            CalcQtyOnHand.RUNMODAL;
                            CLEAR(CalcQtyOnHand);
                        END;
                    loptCalcInvBy::"Loc./Bin/Lot/Serial No.":
                        BEGIN

                            lrptCalcInvByBinLotSerial.InitializeRequest(PostingDate, DocNo, ZeroQty);
                            lrptCalcInvByBinLotSerial.SetWhseJnlLine(ItemJournalLine);
                            lrptCalcInvByBinLotSerial.InitializePhysInvtCount(
                              TempPhysInvtItemSelection."Phys Invt Counting Period Code",
                              TempPhysInvtItemSelection."Phys Invt Counting Period Type");
                            lrptCalcInvByBinLotSerial.USEREQUESTPAGE(FALSE);
                            lrptCalcInvByBinLotSerial.SetHideValidationDialog(TRUE);

                            lrecBinContent.SETRANGE("Item No.", TempPhysInvtItemSelection."Item No.");
                            IF TempPhysInvtItemSelection."Phys Invt Counting Period Type" =
                               TempPhysInvtItemSelection."Phys Invt Counting Period Type"::SKU
                            THEN BEGIN
                                lrecBinContent.SETRANGE("Variant Code", TempPhysInvtItemSelection."Variant Code");
                                lrecBinContent.SETRANGE("Location Code", TempPhysInvtItemSelection."Location Code");
                            END;

                            lrptCalcInvByBinLotSerial.SETTABLEVIEW(lrecBinContent);
                            lrptCalcInvByBinLotSerial.RUNMODAL;
                            CLEAR(lrptCalcInvByBinLotSerial);

                        END;
                    loptCalcInvBy::"Loc./Lot/Serial No.":
                        BEGIN

                            lrptCalcInvByLotSerial.InitializeRequest(PostingDate, DocNo, ZeroQty);
                            lrptCalcInvByLotSerial.SetWhseJnlLine(ItemJournalLine);
                            lrptCalcInvByLotSerial.InitializePhysInvtCount(
                              TempPhysInvtItemSelection."Phys Invt Counting Period Code",
                              TempPhysInvtItemSelection."Phys Invt Counting Period Type");
                            lrptCalcInvByLotSerial.USEREQUESTPAGE(FALSE);
                            lrptCalcInvByLotSerial.SetHideValidationDialog(TRUE);
                            Item.SETRANGE("No.", TempPhysInvtItemSelection."Item No.");
                            IF TempPhysInvtItemSelection."Phys Invt Counting Period Type" =
                               TempPhysInvtItemSelection."Phys Invt Counting Period Type"::SKU
                            THEN BEGIN
                                Item.SETRANGE("Variant Filter", TempPhysInvtItemSelection."Variant Code");
                                Item.SETRANGE("Location Filter", TempPhysInvtItemSelection."Location Code");
                            END;
                            lrptCalcInvByLotSerial.SETTABLEVIEW(Item);
                            lrptCalcInvByLotSerial.RUNMODAL;
                            CLEAR(lrptCalcInvByLotSerial);

                        END;
                END;
            UNTIL TempPhysInvtItemSelection.NEXT = 0;
            Window.CLOSE;

            IF PrintDoc THEN BEGIN
                IF NOT PrintDocPerItem THEN BEGIN
                    ItemJnlBatch.SETRECFILTER;
                    ItemJournalLine.SETRANGE(
                      "Journal Template Name", ItemJournalLine."Journal Template Name");
                    ItemJournalLine.SETRANGE(
                      "Journal Batch Name", ItemJournalLine."Journal Batch Name");
                    PhysInvtList.USEREQUESTPAGE(FALSE);
                    PhysInvtList.Initialize(PrintQtyCalculated);
                    PhysInvtList.SETTABLEVIEW(ItemJnlBatch);
                    PhysInvtList.SETTABLEVIEW(ItemJournalLine);
                    PhysInvtList.RUN;
                END ELSE BEGIN
                    TempPhysInvtItemSelection.FIND('-');
                    REPEAT
                        ItemJnlBatch.SETRECFILTER;
                        PhysInvtList.SETTABLEVIEW(ItemJnlBatch);
                        ItemJournalLine.SETRANGE(
                          "Journal Template Name", ItemJournalLine."Journal Template Name");
                        ItemJournalLine.SETRANGE(
                          "Journal Batch Name", ItemJournalLine."Journal Batch Name");
                        ItemJournalLine.SETRANGE("Item No.", TempPhysInvtItemSelection."Item No.");
                        PhysInvtList.USEREQUESTPAGE(FALSE);
                        PhysInvtList.Initialize(PrintQtyCalculated);
                        PhysInvtList.SETTABLEVIEW(ItemJournalLine);
                        PhysInvtList.RUN;
                        TempPhysInvtItemSelection.SETRANGE("Item No.",
                          TempPhysInvtItemSelection."Item No.");
                        TempPhysInvtItemSelection.FIND('+');
                        TempPhysInvtItemSelection.SETRANGE("Item No.");
                    UNTIL TempPhysInvtItemSelection.NEXT = 0;
                END;
                CLEAR(PhysInvtList);
            END;
        END;
        IsHandled := true;
    end;
}