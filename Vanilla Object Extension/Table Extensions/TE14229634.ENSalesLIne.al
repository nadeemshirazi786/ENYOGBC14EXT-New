tableextension 14229634 "EN Sales Line ELA" extends "Sales Line"
{
    fields
    {

        field(14229150; "Lot No. ELA"; Code[20])
        {
            Caption = 'Lot No.';
            DataClassification = ToBeClassified;
        }
        field(14228880; "To be Authorized ELA"; Boolean)
        {
            Caption = 'To be Authorized';
            DataClassification = ToBeClassified;
        }
        field(14228881; "Authorized Unit Price ELA"; Decimal)
        {
            Caption = 'Authorized Unit Price';
            DataClassification = ToBeClassified;
        }
        field(14228882; "Authrzed Price below Cost ELA"; Code[20])
        {
            Caption = 'Authorized Price below Cost';
            DataClassification = ToBeClassified;
        }
        field(14228883; "Pricing Method ELA"; Enum "EN Pricing Method")
        {
            Caption = 'Pricing Method';
            DataClassification = ToBeClassified;

        }

        field(14228884; "Requested Order Qty. ELA"; Decimal)
        {
            Caption = 'Requested Order Qty.';
            DataClassification = ToBeClassified;
            trigger OnValidate();
            begin
                IF Rec."Requested Order Qty. ELA" <> xRec."Requested Order Qty. ELA" THEN BEGIN
                    VALIDATE(Quantity, "Requested Order Qty. ELA");
                END;
            end;

        }
        field(14228900; "Supply Chain Group Code ELA"; Code[10])
        {
            Caption = 'Supply Chain Group Code';
            DataClassification = ToBeClassified;
        }
        field(14228901; "Country/Reg of Origin Code ELA"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            DataClassification = ToBeClassified;
        }
        field(14228902; "Label Item As ELA"; Code[20])
        {
            Caption = 'Label Item As';
            DataClassification = ToBeClassified;
            TableRelation = Item;
        }
        field(14228903; "Price After Sale ELA"; Boolean)
        {
            Caption = 'Price After Sale';
            DataClassification = ToBeClassified;
        }
        field(51000; "Breaking Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(51001; "Green Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(51002; "No Gas Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(51003; "Color Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(51008; "Backorder Tolerance %"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(51009; "Green Tracking No."; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(51010; "Breaking Tracking No."; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(51011; "Order Template Location"; Code[10])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Sales Header"."Order Template Location ELA" WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No.")));
            Editable = false;
        }
        field(51012; "Standing Order Status"; Enum SHeaderOrderStatus)
        {
            DataClassification = ToBeClassified;
        }
        field(51013; "No Gas Tracking No."; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(51014; "Color Tracking No."; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(51015; "Purchase Rebate Amount"; Decimal)
        {
            TableRelation = "Sales Line".Amount;
            DataClassification = ToBeClassified;
        }
        field(51016; "Bottle Deposit"; Boolean)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                Validate("Unit Price");
            end;
        }

        field(14228850; "Sales Price UOM ELA"; Code[20])
        {
            Caption = 'Sales Price Unit of Measure';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
            trigger OnValidate()
            begin
                IF "Sales Price UOM ELA" <> '' THEN
                    TESTFIELD(Type, Type::Item);

                IF Type = Type::Item THEN
                    UpdateUnitPrice(FIELDNO("Sales Price UOM ELA"));

                IF (Type = Type::Item) AND ("Sales Price UOM ELA" <> xRec."Sales Price UOM ELA") AND
                ("Lock Pricing ELA") AND ("Unit Price" <> 0)
                THEN BEGIN
                    MESSAGE(Text000, FIELDNAME("Sales Price UOM ELA"));
                END;

            end;
        }
        field(14228851; "Ref. Item No. ELA"; Code[20])
        {

            Caption = 'Ref. Item No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = Item;

            trigger OnValidate()
            var
                lrecItem: Record Item;
                lrecItemChargeAssignment: Record "Item Charge Assignment (Sales)";
            begin

                if Type = Type::Item then begin
                    TestField("Ref. Item No. ELA", "No.");
                end;

                if "Ref. Item No. ELA" <> '' then begin
                    lrecItem.Get("Ref. Item No. ELA");


                    if Type = Type::"Charge (Item)" then begin
                        // Document Type,Document No.,Document Line No.,Line No.
                        lrecItemChargeAssignment.SetRange("Document Type", "Document Type");
                        lrecItemChargeAssignment.SetRange("Document No.", "Document No.");
                        lrecItemChargeAssignment.SetRange("Document Line No.", "Line No.");
                        lrecItemChargeAssignment.SetFilter("Item No.", '<>%1', "Ref. Item No. ELA");
                        if lrecItemChargeAssignment.FindFirst then begin
                            lrecItemChargeAssignment.TestField("Item No.", "Ref. Item No. ELA");
                        end;
                    end;


                    //"Comm. Prod. Group" := lrecItem."Comm. Prod. Group";   tr
                    "Tax Group Code" := lrecItem."Tax Group Code";
                    Description := lrecItem.Description;
                    "Description 2" := lrecItem."Description 2";

                    if Type <> Type::Item then begin
                        CreateDim(
                          DimMgt.TypeToTableID3(Type::Item), "Ref. Item No. ELA",
                          DATABASE::Job, "Job No.",
                          DATABASE::"Responsibility Center", "Responsibility Center");
                    end;

                    UpdateUnitPrice(FieldNo("Ref. Item No. ELA"));
                end;

            end;

        }

        field(14228853; "Sell Item at Cost ELA"; Boolean)
        {
            Caption = 'Sell Item at Cost';

        }

        field(14228854; "Lock Pricing ELA"; Boolean)
        {
            Caption = 'Lock Pricing';

        }
        field(14228855; "Price Calc. GUID ELA"; Guid)
        {
            Caption = 'Price Calc. GUID';

        }
        field(14228856; "Unit Price (S.Price UOM) ELA"; Decimal)
        {

            Caption = 'Unit Price (Sales Price UOM)';
        }
        field(14228857; "Unit Price (Base UOM) ELA"; Decimal)
        {
            Caption = 'Unit Price (Base UOM)';

        }
        field(14228858; "Sales Price Source ELA"; Text[30])
        {
            Caption = 'Sales Price Source';
            Editable = false;
        }
        field(14228859; "Unit Price Prot Level ELA"; Enum "EN Unit Price Protection Level")
        {
            Caption = 'Unit Price Protection Level';
        }
        field(14228860; "Sales App Price ELA"; Boolean)
        {
            Caption = 'Sales App Price';
        }
        field(14228861; "Price Change Reason Code ELA"; Text[30])
        {
            Caption = 'Price Change Reason Code';
        }
        field(14228862; "Shelf No. ELA"; Code[10])
        {
            Caption = 'Shelf No.';
            Editable = false;

        }
        field(14228863; "Size Code ELA"; Code[20])
        {
            Caption = 'Size Code';
            TableRelation = "EN Unit of Measure Size".Code;

        }

        field(14228865; "EDI Line No. ELA"; Integer)
        {
            Caption = 'EDI Line No.';
        }
        field(14228866; "Pallet Code ELA"; code[10])
        {
            Caption = 'Pallet Code';
            //TableRelation = "EN Container Type";
        }
        field(14228867; "Include IC in Unit Price ELA"; Boolean)
        {
            Caption = 'Include IC in Unit Price';
            trigger OnValidate()
            begin
                TESTFIELD(Type, Type::"Charge (Item)");
                TESTFIELD("Attached to Line No.");
            end;

        }
        field(14228868; "Item Charge Type ELA"; Enum "EN Item Charge Type")
        {
            Caption = 'Item Charge Type';
            Editable = false;

        }
        field(14229400; "Line Net Weight ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Caption = 'Line Net Weight';
        }
        field(14228869; "Original Order Qty. ELA"; Decimal)
        {
            Caption = 'Original Order Qty.';
            Editable = false;
            DecimalPlaces = 0 : 5;

        }
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                lrecItemContainerType: Record "Item Container Type ELA";
            begin
                IF SalesHeader."Delivery Zone Code ELA" <> '' THEN BEGIN
                    // IF lrecItemContainerType.GET("No.", SalesHeader."Delivery Zone Code ELA") THEN BEGIN
                    //     "Item Container Type" := lrecItemContainerType."Container Type";
                    // END;
                END;
                "Sales Price UOM ELA" := GetSalesPriceUOM;
                Case Type OF
                    Type::Item:
                        Begin
                            cbOrderRuleItemCheck;
                            cbOrderRuleQtyDefault;
                        end;
                End;
            end;
        }
        modify("Unit of Measure Code")
        {
            trigger OnAfterValidate()
            begin

                Case Type OF
                    Type::Item:
                        Begin
                            IF (xRec."Unit of Measure Code" <> "Unit of Measure Code") AND (Quantity <> 0) THEN BEGIN
                                cbOrderRuleItemCheck;
                            end;
                        end;
                End;
            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                UpdateUnitPriceBaseUOM;
                cbOrderRuleRoundOrderMult;

                IF (Type = Type::Item) AND
                   ("Line No." <> 0)
                THEN BEGIN
                    CusttItemSurchargeMgt.ProcessSalesLineSurcharges(Rec);
                END;

                IF ("Original Order Qty. ELA" = 0) OR
                   ((CurrFieldNo = FIELDNO(Quantity)))
                THEN BEGIN
                    IF NOT (("Quantity Shipped" > 0) AND (Quantity < "Original Order Qty. ELA")) THEN
                        "Original Order Qty. ELA" := Quantity;
                END;

            end;
        }
        modify("Unit Price")
        {
            trigger OnAfterValidate()
            begin
                TestPriceProtection;

                IF "Sell Item at Cost ELA" THEN BEGIN
                    TESTFIELD("Unit Price", "Unit Cost");

                    VALIDATE("Line Discount %", 0);

                    IF (Type = Type::Item) AND
                       ("Line No." <> 0)
                    THEN BEGIN
                        CusttItemSurchargeMgt.ProcessSalesLineSurcharges(Rec);
                    END;
                END ELSE BEGIN

                    VALIDATE("Line Discount %");
                END;
                "Unit Price (S.Price UOM) ELA" := gSalesPriceMgt.CalcSalesPriceUOMPrice(Rec);
                UpdateUnitPriceBaseUOM;

                IF CurrFieldNo = FIELDNO("Unit Price") THEN BEGIN
                    ENSalesSetup.GET;
                    IF ENSalesSetup."Lock UnitPrice on ManEdit ELA" THEN BEGIN
                        "Lock Pricing ELA" := TRUE;
                    END;
                    "Sales Price Source ELA" := 'Manual';
                END;

                IF "Unit Price" <> xRec."Unit Price" THEN
                    IF xRec."Unit Price" <> 0 THEN BEGIN
                        IF Item.GET("No.") THEN
                            IF ItemCategory.GET(Item."Item Category Code") THEN BEGIN
                                IF (NOT "Lock Pricing ELA") AND
                                   (NOT "Sales App Price ELA") AND
                                   (ItemCategory."Req. Reason For Price Change")
                                THEN
                                    IF "Price Change Reason Code ELA" = '' THEN
                                        ERROR('Error In Price Change');
                            END;
                    END;

            end;
        }
        modify("Unit Cost (LCY)")
        {
            trigger OnAfterValidate()
            begin
                IF "Sell Item at Cost ELA" THEN BEGIN
                    VALIDATE("Unit Price", "Unit Cost");
                END;
            end;
        }
        modify("Line Discount %")
        {
            trigger OnAfterValidate()
            begin

                IF "Line Discount %" <> 0 THEN
                    TESTFIELD("Sell Item at Cost ELA", FALSE);

                IF (Type = Type::Item) AND
                   ("Line No." <> 0)
                THEN BEGIN
                    CusttItemSurchargeMgt.ProcessSalesLineSurcharges(Rec);
                end;
            end;

        }
        modify("Line Discount Amount")
        {
            trigger OnAfterValidate()
            begin

                IF "Line Discount Amount" <> 0 THEN
                    TESTFIELD("Sell Item at Cost ELA", FALSE);
                IF (Type = Type::Item) AND
                   ("Line No." <> 0)
                THEN BEGIN
                    CusttItemSurchargeMgt.ProcessSalesLineSurcharges(Rec);
                end;
            end;
        }


    }
    procedure WarehouseLineQuantityELA(QtyBase: Decimal; QtyAlt: Decimal; QtyToInvBase: Decimal)
    begin
        UseWhseLineQty := TRUE;
        WhseLineQtyBase := QtyBase;
        WhseLineQtyToInvBase := QtyToInvBase; // P80077569
    end;

    procedure GetLocationELA(LocationCode: Code[20])
    begin
        IF LocationCode = '' THEN
            CLEAR(Location)
        ELSE
            IF Location.Code <> LocationCode THEN
                Location.GET(LocationCode);
    end;

    procedure SuspendPriceCalcELA(pblnSuspendPriceCalc: Boolean)

    begin
        gblnSuspendPriceCalc := pblnSuspendPriceCalc;
    end;

    procedure doTrackingExistsELA(pdecQty: Decimal; VAR pblnItemTracking: Boolean): Decimal
    var
        lrecReservEntry: Record "Reservation Entry";
        lrecTrackingSpecification: Record "Tracking Specification";
        ldecPctInReserv: Decimal;
        lrecitem: Record Item;
    begin
        pblnItemTracking := FALSE;

        IF NOT (Type = Type::Item) THEN
            EXIT(0);

        IF NOT lrecitem.GET("No.") THEN
            EXIT(0);

        IF lrecitem."Item Tracking Code" = '' THEN
            EXIT(0);

        pblnItemTracking := TRUE;

        IF pdecQty = 0 THEN
            EXIT(0);

        lrecReservEntry.SETCURRENTKEY(
        "Source ID", "Source Ref. No.", "Source Type", "Source Subtype", "Source Batch Name", "Source Prod. Order Line",
        "Reservation Status", "Shipment Date", "Expected Receipt Date");

        lrecReservEntry.SETRANGE("Source ID", "Document No.");
        lrecReservEntry.SETRANGE("Source Ref. No.", "Line No.");
        lrecReservEntry.SETRANGE("Source Type", DATABASE::"Sales Line");

        IF lrecReservEntry.FIND('-') THEN BEGIN
            REPEAT
                IF (lrecReservEntry."Lot No." <> '') OR (lrecReservEntry."Serial No." <> '') THEN BEGIN
                    IF "Document Type" IN ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]
                    THEN
                        ldecPctInReserv += lrecReservEntry."Quantity (Base)";
                    IF "Document Type" IN
                        ["Document Type"::Quote,
                        "Document Type"::Order,
                        "Document Type"::Invoice,
                        "Document Type"::"Blanket Order"]
                    THEN
                        ldecPctInReserv += -lrecReservEntry."Quantity (Base)";
                END;
            UNTIL lrecReservEntry.NEXT = 0;
        END;

        lrecTrackingSpecification.SETCURRENTKEY(
        "Source ID", "Source Type", "Source Subtype",
        "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.");

        lrecTrackingSpecification.SETRANGE("Source ID", "Document No.");
        lrecTrackingSpecification.SETRANGE("Source Type", DATABASE::"Sales Line");
        lrecTrackingSpecification.SETRANGE("Source Subtype", "Document Type");
        lrecTrackingSpecification.SETRANGE("Source Batch Name", '');
        lrecTrackingSpecification.SETRANGE("Source Prod. Order Line", 0);
        lrecTrackingSpecification.SETRANGE("Source Ref. No.", "Line No.");

        IF lrecTrackingSpecification.FIND('-') THEN BEGIN
            REPEAT
                IF (lrecTrackingSpecification."Lot No." <> '') OR (lrecTrackingSpecification."Serial No." <> '') THEN BEGIN
                    IF "Document Type" IN ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]
                    THEN
                        ldecPctInReserv += lrecTrackingSpecification."Quantity (Base)";
                    IF "Document Type" IN
                        ["Document Type"::Quote,
                        "Document Type"::Order,
                        "Document Type"::Invoice,
                        "Document Type"::"Blanket Order"]
                    THEN
                        ldecPctInReserv += -lrecTrackingSpecification."Quantity (Base)";
                END;
            UNTIL lrecTrackingSpecification.NEXT = 0;
        END;

        IF pdecQty <> 0 THEN
            ldecPctInReserv := ldecPctInReserv / pdecQty * 100;

        EXIT(ldecPctInReserv);

    end;

    procedure LookupNoFieldELA(VAR mytext: Text[1024]): Boolean
    var
        StdText: Record "Standard Text";
        Acct: Record "G/L Account";
        Item: Record Item;
        Res: Record Resource;
        FA: Record "Fixed Asset";
        ItemCharge: Record "Item Charge";
        StdTextList: Page "Standard Text Codes";
        AcctList: Page "G/L Account List";
        ItemList: Page "Item List";
        ResList: Page "Resource List";
        FAList: Page "Fixed Asset List";
        ItemChargeList: Page "Item Charges";
    begin
        case Rec.Type OF
            Rec.Type::" ":
                begin
                    StdTextList.SetTableView(StdText);
                    IF StdText.Get("No.") then
                        StdTextList.SetRecord(StdText);
                    StdTextList.LookupMode := true;
                    IF StdTextList.RunModal <> Action::LookupOK then
                        exit(false);
                    StdTextList.GetRecord(StdText);
                    mytext := StdText.Code;
                end;
            Rec.Type::"G/L Account":
                begin
                    AcctList.SetTableView(Acct);
                    if Acct.Get("No.") then
                        AcctList.SetRecord(Acct);
                    AcctList.LookupMode := true;
                    if AcctList.RunModal <> Action::LookupOK then
                        exit(false);
                    AcctList.GetRecord(Acct);
                    mytext := Acct."No.";
                end;
            Rec.Type::Item:
                begin
                    Item.SetRange("Item Type ELA", Item."Item Type ELA"::"Finished Good");
                    ItemList.SetTableView(Item);
                    if item.Get("No.") then
                        ItemList.SetRecord(Item);
                    ItemList.LookupMode := true;
                    if ItemList.RunModal <> Action::LookupOK then
                        exit(false);
                    ItemList.GetRecord(Item);
                    mytext := Item."No.";
                end;
            Rec.Type::Resource:
                begin
                    ResList.SetTableView(Res);
                    if Res.Get("No.") then
                        ResList.SetRecord(Res);
                    ResList.LookupMode := true;
                    if ResList.RunModal <> Action::LookupOK then
                        exit(false);
                    ResList.GetRecord(Res);
                    mytext := Res."No.";
                end;
            Rec.Type::"Fixed Asset":
                begin
                    FAList.SetTableView(FA);
                    IF FA.Get("No.") then
                        FAList.SetRecord(FA);
                    FAList.LookupMode := true;
                    IF FAList.RunModal <> Action::LookupOK then
                        exit(false);
                    FAList.GetRecord(FA);
                    mytext := FA."No.";
                end;
            Rec.Type::"Charge (Item)":
                begin
                    ItemChargeList.SetTableView(ItemCharge);
                    if ItemCharge.Get("No.") then
                        ItemChargeList.SetRecord(ItemCharge);
                    ItemChargeList.LookupMode := true;
                    IF ItemChargeList.RunModal <> Action::LookupOK then
                        exit(false);
                    ItemChargeList.GetRecord(ItemCharge);
                    mytext := ItemCharge."No.";
                end;

        end;
        exit(false);
    end;

    procedure WarehouseLineQuantity(QtyBase: Decimal; QtyAlt: Decimal; QtyToInvBase: Decimal)
    begin
        UseWhseLineQty := TRUE;
        WhseLineQtyBase := QtyBase;
        WhseLineQtyToInvBase := QtyToInvBase;
    end;

    procedure GetLotNo()
    begin

    end;

    procedure AutoLotNo(Posting: Boolean)
    begin
        IF NOT ("Document Type" IN ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) THEN
            EXIT;
        IF (Type <> Type::Item) OR ("No." = '') THEN
            EXIT;

        IF Posting AND ("Return Qty. to Receive" = 0) THEN
            EXIT;

        GetSalesHeader;
        SalesLine := Rec;
        xSalesLine := xRec;
        IF Posting THEN BEGIN
            SalesLine."Shipment Date" := SalesHeader."Posting Date";
            xSalesLine := SalesLine;
        END ELSE BEGIN
            SalesLine."Shipment Date" := 0D;
            xSalesLine."Shipment Date" := 0D;
        END;
    end;

    procedure UpdateLotTracking(ForceUpdate: Boolean; ApplyFromEntryNo: Integer)
    begin
        IF ((CurrFieldNo = 0) AND (NOT ForceUpdate)) OR (Type <> Type::Item) THEN
            EXIT;

        IF "Line No." = 0 THEN
            EXIT;

        IF UseWhseLineQty THEN BEGIN
            QtyBase := "Quantity (Base)";
            QtyToHandle := WhseLineQtyBase;

            QtyToInvoice := WhseLineQtyToInvBase;
        END ELSE BEGIN
            GetLocation("Location Code");
            CASE "Document Type" OF
                "Document Type"::Order, "Document Type"::Invoice:
                    IF Location.LocationType = 1 THEN BEGIN
                        QtyToHandle := "Qty. to Ship (Base)";

                        QtyToInvoice := "Qty. to Invoice (Base)";

                    END ELSE BEGIN

                        QtyToHandle := "Qty. to Ship (Base)";

                        QtyToInvoice := "Qty. to Invoice (Base)";


                    END;
                "Document Type"::"Credit Memo", "Document Type"::"Return Order":
                    IF Location.LocationType = 1 THEN BEGIN
                        QtyToHandle := "Return Qty. to Receive (Base)";

                        QtyToInvoice := "Qty. to Invoice (Base)";

                    END ELSE BEGIN

                        QtyToHandle := "Return Qty. to Receive (Base)";

                        QtyToInvoice := "Qty. to Invoice (Base)";


                    END;
            END;
            QtyBase := "Quantity (Base)";
        END;

        IF (xRec."Document Type" = 0) AND (xRec."Document No." = '') AND (xRec."Line No." = 0) THEN // P8000181A
            xRec."Lot No. ELA" := "Lot No. ELA";                                                              // P8000181A
                                                                                                              /////EasyLotTracking.ReplaceTracking(xRec."Lot No.","Lot No.",
                                                                                                              /////////// QtyBase,QtyToHandle,QtyToInvoice); // P8000629A, P8004505
    end;

    procedure GetLocation(LocationCode: Code[20])
    begin
        IF LocationCode = '' THEN
            CLEAR(Location)
        ELSE
            IF Location.Code <> LocationCode THEN
                Location.GET(LocationCode);
    end;

    procedure jfSuspendPriceCalc(pblnSuspendPriceCalc: Boolean)
    var
        myInt: Integer;
    begin
        gblnSuspendPriceCalc := pblnSuspendPriceCalc;
    end;

    procedure jfCalculateNetUnitPrice(var pdecNetUnitAmount: Decimal; var pdecNetTotalAmount: Decimal; var pdecRebateUnitAmt: Decimal; var pdecNetUnitAmountBaseUOM: Decimal; pblnDeductLineDiscount: Boolean)
    var
        lintRebateFactor: Integer;
    begin
        pdecNetUnitAmount := 0;
        pdecNetTotalAmount := 0;
        pdecRebateUnitAmt := 0;
        pdecNetUnitAmountBaseUOM := 0;
        lintRebateFactor := 1;

    end;

    procedure jfCalcDeliveredPrice(var pdecDeliveredPrice: Decimal)

    begin
    end;

    procedure jfCalcPurchRebateUnitRate(var pdecPurchRebateUnitAmt: Decimal)
    begin
        IF Quantity <> 0 THEN BEGIN
            CALCFIELDS("Purchase Rebate Amount");
            pdecPurchRebateUnitAmt := ROUND("Purchase Rebate Amount" / Quantity, 0.00001);
        END ELSE BEGIN
            pdecPurchRebateUnitAmt := 0;
        END;
    end;

    procedure jfmgResetItemChargeLine()
    begin

    end;

    procedure jfShowItemProperties()
    begin
    end;

    procedure jfGetUDCalculation(pcodUDCalcCode: Code[20]) rtxtUDCalcVal: Text[30]

    begin
    end;

    procedure GetBottleAmount(recSalesLine: Record "Sales Line") ptxtResult: Text[250]
    var
        recHeader: Record "Sales Header";
        recState: Record "State ELA";
        ldecDecimalVariable: Decimal;
        UDCalc: Codeunit "UD Calculations ELA";
        recBottleState: Record "Bottle Deposit Setup";
    begin
        IF NOT recSalesLine."Bottle Deposit" then
            exit;
        IF (recSalesLine."No." = '') AND (recSalesLine.Type <> recSalesLine.Type::Item) then
            exit;
        IF recHeader.GET(recSalesLine."Document Type", recSalesLine."Document No.") then begin
            recBottleState.Reset();
            recBottleState.SetRange("Item No.", recSalesLine."No.");
            recBottleState.SetFilter("Bottle Deposit State", '<>%1', '');
            if recBottleState.FindFirst() then begin
                IF recBottleState.Get(recSalesLine."No.", recHeader."Sell-to County") then begin
                    ldecDecimalVariable := UDCalc.jfUOMConvert(
                                          recSalesLine."No.",
                                          recSalesLine."Unit of Measure Code",
                                          'EA',
                                          recBottleState."Bottle Deposit Amount");
                    ptxtResult := FORMAT(ROUND(ldecDecimalVariable, 0.01, '>'));
                end else
                    ptxtResult := Format(0);

            end else begin
                if recState.Get(recHeader."Sell-to County") then begin
                    ldecDecimalVariable := UDCalc.jfUOMConvert(
                                          recSalesLine."No.",
                                          recSalesLine."Unit of Measure Code",
                                          'EA',
                                          recState."Bottle Deposit ELA");
                    ptxtResult := FORMAT(ROUND(ldecDecimalVariable, 0.01, '>'));
                end ELSE
                    ptxtResult := FORMAT(0);

            end;

        end;
    end;

    procedure CalcUnitCostExt(ItemLedgEntry: Record "Item Ledger Entry"): Decimal
    begin
        EXIT(CalcUnitCostExt(ItemLedgEntry));
    end;
    /// <summary>
    /// UpdateUnitPriceBaseUOM.
    /// </summary>
    procedure UpdateUnitPriceBaseUOM()
    var
        lrecItem: Record Item;
        lrecItemUOM: Record "Item Unit of Measure";
    begin

        GetSalesHeaderExt;
        IF "Lock Pricing ELA" AND (CurrFieldNo <> FIELDNO("Unit Price")) AND (CurrFieldNo <> 0) AND (NOT gblnSkipLockPricing) THEN
            EXIT;
        IF Type <> Type::Item THEN
            EXIT;

        lrecItem.GET("No.");
        IF lrecItem."Base Unit of Measure" = "Unit of Measure Code" THEN BEGIN
            "Unit Price (Base UOM) ELA" := "Unit Price";
        END ELSE BEGIN
            lrecItemUOM.GET("No.", "Unit of Measure Code");
            "Unit Price (Base UOM) ELA" := ROUND("Unit Price" * lrecItemUOM."Qty. per Base UOM ELA", Currency."Amount Rounding Precision");
        END;

    end;
    /// <summary>
    /// GetSalesPriceUOM.
    /// </summary>
    /// <returns>Return value of type Code[10].</returns>
    procedure GetSalesPriceUOM(): Code[10]
    var
        lrecCustomer: Record Customer;
        lrecItem: Record Item;
        lrecItemCustomer: Record "EN Item Customer";
    begin

        IF Type <> Type::Item THEN
            EXIT('');

        //-- Sales Price UOM hierarchy --> Item Customer, Customer, Item
        // 1. Item Customer trumps everything

        lrecItemCustomer.SETRANGE("Customer No.", "Sell-to Customer No.");
        lrecItemCustomer.SETRANGE("Item No.", "No.");
        lrecItemCustomer.SETRANGE("Variant Code", "Variant Code");

        IF lrecItemCustomer.FINDFIRST THEN
            IF lrecItemCustomer."Sales Price Unit of Measure" <> '' THEN
                EXIT(lrecItemCustomer."Sales Price Unit of Measure");

        // 2. Customer trumps Item

        IF (
        ("Sell-to Customer No." <> '')
        AND (lrecCustomer.GET("Sell-to Customer No."))
        AND (lrecCustomer."Sales Price UOM ELA" <> '')
        ) THEN BEGIN
            EXIT(lrecCustomer."Sales Price UOM ELA");
        END;

        // 3. otherwise use Item

        IF (
        ("No." <> '')
        AND (lrecItem.GET("No."))
        AND (lrecItem."Sales Price UOM ELA" <> '')
        ) THEN BEGIN
            EXIT(lrecItem."Sales Price UOM ELA");
        END;

        // 4. got nuthin'

        EXIT('');

        //</JF00135MG>
    end;
    /// <summary>
    /// GetSalesHeaderExt.
    /// </summary>
    procedure GetSalesHeaderExt()
    begin
        TESTFIELD("Document No.");
        IF ("Document Type" <> SalesHeader."Document Type") OR ("Document No." <> SalesHeader."No.") THEN BEGIN
            SalesHeader.GET("Document Type", "Document No.");
            IF SalesHeader."Currency Code" = '' THEN
                Currency.InitRoundingPrecision
            ELSE BEGIN
                SalesHeader.TESTFIELD("Currency Factor");
                Currency.GET(SalesHeader."Currency Code");
                Currency.TESTFIELD("Amount Rounding Precision");
            END;
        END;
    end;

    procedure CopyItemNoToRefItemNo()
    begin
        "Ref. Item No. ELA" := "No.";
    end;
    /// <summary>
    /// CalcBestDiscPct.
    /// </summary>
    /// <param name="pSalesLine">Record "Sales Line".</param>
    procedure CalcBestDiscPct(pSalesLine: Record "Sales Line")
    var
        ldecBestDiscPct: Decimal;
    begin

        IF (pSalesLine."Unit Price" > 0) THEN BEGIN
            ldecBestDiscPct := 100 * pSalesLine."Line Discount Amount" / pSalesLine."Unit Price";
            IF ldecBestDiscPct > 100 THEN BEGIN
                ldecBestDiscPct := 100;
            END;
            IF ldecBestDiscPct > "Line Discount %" THEN BEGIN
                "Line Discount %" := ldecBestDiscPct;
            END;
        END;
    end;

    procedure TestPriceProtection()
    var
        ldecCostToUse: Decimal;
        ltxc001: Label 'The Pricing is protected such that the Sales Cost must be covered.  The Unit Price has been set to the Sales Cost to reflect the minimimum allowable price.';
    begin

        IF CurrFieldNo <> FIELDNO("Unit Price") THEN
            EXIT;

        CASE "Unit Price Prot Level ELA" OF
            "Unit Price Prot Level ELA"::None:
                BEGIN
                END;

            "Unit Price Prot Level ELA"::Absolute:
                BEGIN
                    FIELDERROR("Unit Price Prot Level ELA");
                END;

            "Unit Price Prot Level ELA"::"Cost Plus":
                BEGIN
                    //ldecCostToUse := "Alternate Sales Cost (LCY)";
                    IF ldecCostToUse = 0 THEN
                        ldecCostToUse := "Unit Cost (LCY)";
                    IF "Unit Price" < ldecCostToUse THEN BEGIN
                        MESSAGE(ltxc001);
                        "Unit Price" := ldecCostToUse;
                    END;
                END;
        END;
    end;

    /// <summary>
    /// FromICInboxCreate.
    /// </summary>
    /// <param name="pFromICInboxCreate">Boolean.</param>
    procedure FromICInboxCreate(pFromICInboxCreate: Boolean)
    begin
        gFromICInboxCreate := pFromICInboxCreate;
    end;

    procedure SkipLockPricing(pblnSkipLockPricing: Boolean)
    begin
        gblnSkipLockPricing := pblnSkipLockPricing;
    end;

    procedure TestItemDocumentBlock()
    begin
        If Type = Type::Item then begin
            GetItem;
            IF GetSKU THEN BEGIN
                SKU.TESTFIELD("Block From Sales Doc ELA", FALSE);
            END ELSE BEGIN
                Item.TESTFIELD("Block From Sales Doc ELA", FALSE);
            END;
        end;
    end;

    procedure GetItem()
    begin

        TESTFIELD("No.");
        IF "No." <> Item."No." THEN
            Item.GET("No.");
    end;

    procedure GetSKU(): Boolean
    begin

        IF (SKU."Location Code" = "Location Code") AND
           (SKU."Item No." = "No.") AND
           (SKU."Variant Code" = "Variant Code")
        THEN
            EXIT(TRUE);
        IF SKU.GET("Location Code", "No.", "Variant Code") THEN
            EXIT(TRUE);

        EXIT(FALSE);
    end;

    procedure GetSalesUOM(): Code[10]
    var

        lrecCustomer: Record Customer;
        lrecItem: Record Item;
        lrecItemCustomer: Record "EN Item Customer";
    begin

        //-- Try and find the default Sales UOM for the customer - copied from Sales Price UOM logic
        IF Type <> Type::Item THEN
            EXIT('');
        //-- Sales UOM hierarchy --> Item Customer, Customer, Item
        // 1. Item Customer trumps everything
        lrecItemCustomer.SETRANGE("Customer No.", "Sell-to Customer No.");
        lrecItemCustomer.SETRANGE("Item No.", "No.");
        lrecItemCustomer.SETRANGE("Variant Code", "Variant Code");
        IF lrecItemCustomer.FINDFIRST THEN
            IF lrecItemCustomer."Sales Unit of Measure" <> '' THEN
                EXIT(lrecItemCustomer."Sales Unit of Measure");

        // 2. Customer trumps Item
        IF (
          ("Sell-to Customer No." <> '')
          AND (lrecCustomer.GET("Sell-to Customer No."))
          AND (lrecCustomer."Sales Unit of Measure ELA" <> '')
        ) THEN BEGIN
            EXIT(lrecCustomer."Sales Unit of Measure ELA");
        END;

        // 3. otherwise use Item
        IF (
          ("No." <> '')
          AND (lrecItem.GET("No."))
          AND (lrecItem."Sales Unit of Measure" <> '')
        ) THEN BEGIN
            EXIT(lrecItem."Sales Unit of Measure");
        END;

        // 4. got nuthin'

        EXIT('');
    end;

    /// <summary>
    /// CheckItemAlreadyonLine.
    /// </summary>
    /// <param name="pSoHeaderNo">Code[20].</param>
    procedure CheckItemAlreadyonLine(pSoHeaderNo: Code[20])
    var
        lSalesLine: Record "Sales Line";
        lText001: Label 'Item is already on another line.';
    begin

        IF (Type = Type::Item) AND ("No." <> xRec."No.") AND (CurrFieldNo <> 0) THEN BEGIN
            CLEAR(lSalesLine);
            lSalesLine.SETCURRENTKEY("Document Type", "Document No.", Type, "No.");
            lSalesLine.SETRANGE("Document Type", lSalesLine."Document Type"::Quote);
            lSalesLine.SETRANGE("Document No.", pSoHeaderNo);
            lSalesLine.SETRANGE(Type, lSalesLine.Type::Item);
            lSalesLine.SETRANGE("No.", "No.");
            IF lSalesLine.COUNT >= 1 THEN BEGIN
                MESSAGE(lText001);
            END;
        END;
    end;

    /// <summary>
    /// CheckItemChgInherit.
    /// </summary>
    /// <param name="pcodItemChgCode">Code[20].</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure CheckItemChgInherit(pcodItemChgCode: Code[20]): Boolean
    var
        lItemChg: Record "Item Charge";
    begin

        IF lItemChg.GET(pcodItemChgCode) THEN
            EXIT(lItemChg."Inherit Dim From Assgnt ELA");
    end;

    /// <summary>
    /// CalcDeliveredPrice.
    /// </summary>
    /// <param name="VAR pdecDeliveredPrice">Decimal.</param>
    procedure CalcDeliveredPrice(VAR pdecDeliveredPrice: Decimal)
    var
        lcduSalesSurcharge: Codeunit "EN Delivery Charge Mgt";
    begin

        pdecDeliveredPrice :=
          lcduSalesSurcharge.CalcDeliveredPrice(DATABASE::"Sales Line", "Document Type", "Document No.", "Line No.", "Unit Price");
    end;

    procedure CalcDeliveredPrice2(var pdecDeliveredPrice: Decimal) //added
    var
        RebateFunctions: Codeunit "Rebate Sales Functions ELA";
    begin

        pdecDeliveredPrice :=
          RebateFunctions.CalcDeliveredPrice(DATABASE::"Sales Line", "Document Type", "Document No.", "Line No.", "Unit Price");

    end;

    /// <summary>
    /// OrderRuleItemCheck.
    /// </summary>
    procedure cbOrderRuleItemCheck()
    var
        lOrderRules: Codeunit "EN Order Rule Functions";
    begin

        IF gFromICInboxCreate THEN
            EXIT;
        IF ("Document Type" = "Document Type"::Order) OR
           ("Document Type" = "Document Type"::Invoice) OR
           ("Document Type" = "Document Type"::Quote)
        THEN BEGIN
            lOrderRules.cbSalesLineItemOK(Rec);
        END;

    end;

    /// <summary>
    /// cbOrderRuleQtyDefault.
    /// </summary>
    procedure cbOrderRuleQtyDefault()
    var
        lOrderRules: Codeunit "EN Order Rule Functions";
        ldecMin: Decimal;
    begin

        IF ("Document Type" = "Document Type"::Order) OR
           ("Document Type" = "Document Type"::Invoice)
        THEN BEGIN
            ldecMin := lOrderRules.cbSalesLineDefaultMinQty(Rec);
            IF ldecMin <> 0 THEN BEGIN
                VALIDATE(Quantity, ldecMin);
            END;
        END;
    end;

    procedure cbOrderRuleRoundOrderMult()
    var
        lOrderRules: Codeunit "EN Order Rule Functions";
    begin

        IF ("Document Type" = "Document Type"::Order) OR
           ("Document Type" = "Document Type"::Invoice)
        THEN BEGIN
            Quantity := lOrderRules.cbSalesLineOrderMultiple(Rec);
        END;
    end;

    procedure yogIsCashAndCarry(precSalesLine: Record "Sales Line") pblnResult: Boolean
    var
        lrecSalesHeader: Record "Sales Header";
    begin

        IF (precSalesLine."Document Type" <> precSalesLine."Document Type"::Order) THEN
            EXIT(FALSE);
        IF (NOT lrecSalesHeader.GET(precSalesLine."Document Type", precSalesLine."Document No.")) THEN
            EXIT(FALSE);

        EXIT(lrecSalesHeader."Cash & Carry ELA");
    end;

    procedure FreightAmount(pcodItemChargeCode: code[20]) ptxtResult: Text[250]
    var
        lrecSalesLine: Record "Sales Line";
        lrecSalesHdr: Record "Sales Header";
        lrecState: Record "State ELA";
        lrecShipToAddress: Record "Ship-to Address";
        lrecLocation: Record Location;
        lrecItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        lrecPostItemChargeAssgntSales: Record "Posted Item Chg Asgn Sales ELA";
        lcodState: Code[20];
        ldecDecimalVariable: Decimal;
        lblnItemChargeAttached: Boolean;
        ldecItemChargeAttachedLineCost: Decimal;
        lrecSalesLine1: Record "Sales Line";

    begin
        IF Type <> Type::Item THEN
            EXIT;
        IF pcodItemChargeCode = 'S-FREIGHT' then begin
            CLEAR(lblnItemChargeAttached);
            CLEAR(ldecItemChargeAttachedLineCost);
            lrecSalesLine.RESET;
            lrecSalesLine.SETRANGE("Document Type", "Document Type");
            lrecSalesLine.SETRANGE("Document No.", "Document No.");
            lrecSalesLine.SETRANGE("Attached to Line No.", "Line No.");
            lrecSalesLine.SETRANGE(Type, lrecSalesLine.Type::"Charge (Item)");
            lrecSalesLine.SETRANGE("No.", pcodItemChargeCode);
            IF lrecSalesLine.FINDSET THEN
                REPEAT
                    ldecItemChargeAttachedLineCost += lrecSalesLine."Unit Price";
                    lblnItemChargeAttached := TRUE;
                UNTIL lrecSalesLine.NEXT = 0;

            lrecItemChargeAssgntSales.RESET;
            lrecItemChargeAssgntSales.SETCURRENTKEY("Applies-to Doc. Type", "Applies-to Doc. No.", "Applies-to Doc. Line No.");
            lrecItemChargeAssgntSales.SETRANGE("Applies-to Doc. Type", "Document Type");
            lrecItemChargeAssgntSales.SETRANGE("Applies-to Doc. No.", "Document No.");
            lrecItemChargeAssgntSales.SETRANGE("Applies-to Doc. Line No.", "Line No.");
            lrecItemChargeAssgntSales.SETRANGE("Item Charge No.", pcodItemChargeCode);
            IF lrecItemChargeAssgntSales.FINDSET THEN BEGIN
                REPEAT
                    IF lblnItemChargeAttached THEN BEGIN
                        IF NOT ((lrecItemChargeAssgntSales."Document Type" = "Document Type") AND
                          (lrecItemChargeAssgntSales."Document No." = "Document No.")) THEN BEGIN
                            ldecDecimalVariable += lrecItemChargeAssgntSales."Amount to Assign";
                        END;
                    END ELSE
                        ldecDecimalVariable += lrecItemChargeAssgntSales."Amount to Assign";
                UNTIL lrecItemChargeAssgntSales.NEXT = 0;
                IF Rec."Quantity (Base)" <> 0 THEN
                    ldecDecimalVariable := ldecDecimalVariable / "Quantity (Base)"
                ELSE
                    ldecDecimalVariable := 0;
            END;
            ldecDecimalVariable += ldecItemChargeAttachedLineCost;
            ptxtResult := FORMAT(ROUND(ldecDecimalVariable, 0.00001, '>'));
        END;
    END;


    var
        gblnSuspendPriceCalc: Boolean;
        myInt: Integer;
        SalesLine: Record "Sales Line";
        xSalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        UseWhseLineQty: Boolean;
        WhseLineQtyBase: Decimal;
        WhseLineQtyToInvBase: Decimal;
        QtyBase: Decimal;
        QtyToHandle: Decimal;
        QtyToInvoice: Decimal;
        Location: Record Location;
        Currency: Record Currency;
        Text000: Label 'You changed the %1 when Lock Pricing is set. \Confirm pricing is correct.';
        gFromICInboxCreate: Boolean;
        gSalesPriceMgt: Codeunit "EN Sales Price Calc. Mgt.";
        gblnSkipLockPricing: Boolean;
        ENSalesSetup: Record "Sales & Receivables Setup";
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
        ItemCategory: Record "Item Category";
        CusttItemSurchargeMgt: Codeunit "EN Delivery Charge Mgt";
        DimMgt: Codeunit DimensionManagement;

    trigger OnInsert()
    begin
        If Type = Type::Item THEN begin

            IF "Line No." <> 0 THEN BEGIN
                CusttItemSurchargeMgt.ProcessSalesLineSurcharges(Rec);

                SalesHeader.GET("Document Type", "Document No.");
                "Lock Pricing ELA" := SalesHeader."Lock Pricing ELA";
            END;
        end;
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}
