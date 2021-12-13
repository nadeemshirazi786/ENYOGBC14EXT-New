page 51012 "Purchase Worksheet"
{
    AutoSplitKey = true;
    ApplicationArea = all;
    UsageCategory = Documents;
    PageType = Card;
    RefreshOnActivate = true;
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(OrderDate; OrderDate)
                {
                    Caption = 'Order Date';

                    trigger OnValidate()
                    begin
                        SetOrderDate;
                    end;
                }
                field(LocCode; LocCode)
                {
                    Caption = 'Location Code';
                }
                field(gcodFreightChargeCode; gcodFreightChargeCode)
                {
                    Caption = 'Freight Charge Code';
                    Visible = false;
                }


            }
            part(Matrix; "Purchase Worksheet Matrix")
            {
            }
        }
    }


    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Add Item...")
                {
                    Caption = 'Add Item...';
                    Image = NewItem;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        Item: Record Item;
                        ItemLookup: Page "Item List";
                        lrecItemVariant: Record "Item Variant";
                        lFrmItemVariant: Page "Item Variants";
                        lcodItemVarCode: Code[20];
                        lrecPurchaseWorksheetHeader: Record "Purchase Worksheet Header";
                    begin
                        ItemLookup.SetTableView(Item);
                        ItemLookup.LookupMode(true);
                        if ItemLookup.RunModal = ACTION::LookupOK then begin
                            ItemLookup.GetRecord(Item);
                            ItemList.SetRange("Item No.", Item."No.");
                            Clear(lcodItemVarCode);
                            lrecItemVariant.Reset;
                            lrecItemVariant.SetRange("Item No.", Item."No.");
                            if lrecItemVariant.Count > 0 then begin
                                lFrmItemVariant.SetTableView(lrecItemVariant);
                                lFrmItemVariant.Editable := false;
                                lFrmItemVariant.LookupMode(true);
                                if lFrmItemVariant.RunModal = ACTION::LookupOK then begin
                                    lFrmItemVariant.GetRecord(lrecItemVariant);
                                    ItemList.SetRange("Variant Code", lrecItemVariant.Code);
                                    lcodItemVarCode := lrecItemVariant.Code;
                                end;
                            end;
                            if not ItemList.Find('-') then begin
                                ItemList.SetRange("Item No.");
                                ItemList.SetRange("Variant Code");

                                if ItemList.Find('+') then;
                                ItemList."Entry No." += 1;
                                ItemList."Item No." := Item."No.";
                                ItemList."Variant Code" := lcodItemVarCode;

                                ItemList.Insert;
                            end;
                            CurrPage.Matrix.PAGE.GetRecord(lrecPurchaseWorksheetHeader);
                            if not PWLine.Get(lrecPurchaseWorksheetHeader."Order Date", lrecPurchaseWorksheetHeader."Order No.",
                                              ItemList."Item No.", ItemList."Variant Code") then begin
                                PWLine.Init;
                                PWLine."Order Date" := lrecPurchaseWorksheetHeader."Order Date";
                                PWLine."Order No." := lrecPurchaseWorksheetHeader."Order No.";
                                PWLine."Item No." := ItemList."Item No.";
                                PWLine."Variant Code" := ItemList."Variant Code";
                                PWLine.Insert;
                            end;
                        end;
                        jfSetColumns(MatrixSetWanted::Initial);
                    end;
                }
                action("Create Purchase Orders")
                {
                    Caption = 'Create Purchase Orders';
                    Image = CreateDocuments;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        if OrderDate = 0D then
                            Error('Order date must be specified.');
                        if not Confirm('Create orders for %1?', false, OrderDate) then
                            exit;

                        CreateOrders();
                        SetOrderDate;
                    end;
                }

            }
            group(Home)
            {
                action("Add Additional Freight")
                {
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        AdditionalFreight: Record "Additional Freight";
                        AddFreight: Page "Additional Freight";
                        PWLine: Record "purchase worksheet line";
                    begin
                        AdditionalFreight.Reset();
                        CurrPage.Matrix.Page.GetRecord(PWLine);
                        AdditionalFreight.SetRange("Order Date", PWLine."Order Date");
                        AdditionalFreight.SetRange("Order No.", PWLine."Order No.");
                        AddFreight.SetTableView(AdditionalFreight);
                        AddFreight.RunModal();
                        CurrPage.Matrix.Page.Update(false);
                    end;
                }
            }

            action(Print)
            {
                Caption = 'Print';
                Image = Print;

                trigger OnAction()
                var
                    PWHead: Record "Purchase Worksheet Header";
                begin

                    PWHead.SetRange("Order Date", OrderDate);
                    REPORT.RunModal(REPORT::"Purchase Worksheet", true, false, PWHead);
                end;
            }
            action("Previous Column")
            {
                Caption = 'Previous Column';
                Image = PreviousRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Previous';

                trigger OnAction()
                var
                    Step: Option First,Previous,Same,Next,PreviousColumn,NextColumn;
                begin
                    jfSetColumns(Step::PreviousColumn);
                end;
            }
            action("Next Column")
            {
                Caption = 'Next Column';
                Image = NextRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Next';

                trigger OnAction()
                var
                    Step: Option First,Previous,Same,Next,PreviousColumn,NextColumn;
                begin
                    jfSetColumns(Step::NextColumn);
                end;
            }
        }

    }

    trigger OnInit()
    begin

        PurchSetup.Get();
        LocCode := PurchSetup."Purchase Worksheet Location";
        gcodFreightChargeCode := 'FREIGHT';

        OrderDate := WorkDate;
    end;

    trigger OnOpenPage()
    begin

        SetOrderDate;
        CurrPage.Update();
    end;



    var
        PWLine: Record "Purchase Worksheet Line";
        ItemList: Record "Purchase Worksheet Items";
        OrderDate: Date;
        LocCode: Code[10];
        gcodFreightChargeCode: Code[20];
        "------------": Integer;
        MatrixRecord: Record "Purchase Worksheet Items";
        MatrixRecords: array[32] of Record "Purchase Worksheet Items";
        MatrixRecordRef: RecordRef;
        MatrixSetWanted: Option Initial,Previous,Same,Next;
        MatrixColumnCaptions: array[32] of Text[1024];
        MatrixCaptionRange: Text[1024];
        MatrixPKFirstRecInCurrSet: Text[1024];
        MatrixCurrSetLength: Integer;
        PurchSetup: Record "Purchases & Payables Setup";

    procedure SetOrderDate()
    begin
        GetItems;
    end;


    procedure GetItems()
    var
        lintI: Integer;
    begin
        ItemList.Reset;
        jfSetColumns(MatrixSetWanted::Initial);

    end;


    procedure CreateOrders()
    var
        PWHead: Record "Purchase Worksheet Header";
        PWLine: Record "Purchase Worksheet Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Text001: Label 'Shipping Agent Code is required on line for vendor %1.';
        lrecShippingAgent: Record "Shipping Agent";
        Text002: Label 'Shipping Agent %1 has no Vendor No. set.';
        lcduOrderShAllocateFreight: Codeunit BananaWrkshtCustomFunctions;
        lcodPurchaseInvoiceNo: Code[20];
        lrecPurchaseInvoice: Record "Purchase Header";
        lrecFreightPurchaseOrder: Record "Purchase Header";
        lcduPurchPost: Codeunit "Purch.-Post";
        lcduCustomRecordExtMgt: Codeunit BananaWrkshtCustomFunctions;
        lrecCustomRecordExt: Record "Custom Record Extension";
        AdditionalFreight: Record "Additional Freight";
        DocExtraCharge: Record "EN Document Extra Charge";
        ExtraChrgMgt: Codeunit "EN Extra Charge Management";
        ExtraCharge: Record "EN Extra Charge";
        UserSetup: Record "User Setup";
        Text50000: TextConst ENU = 'You do not have permission to use this function.';
        PDocExtraChrge: Page "EN Document Hdr. Extra Charges";
    begin
        PWHead.SetRange("Order Date", OrderDate);

        PWHead.SetFilter(PWHead."Vendor No.", '<>%1', '');

        if PWHead.Find('-') then
            repeat
                PWHead.TestField("Vendor No.");
                PWHead.TestField("Expected Receipt Date");
                if PWHead."Freight Cost" <> 0 then begin
                    if (PWHead."Shipping Agent Code" = '') then
                        Error(Text001, PWHead."Vendor No.");
                    lrecShippingAgent.Get(PWHead."Shipping Agent Code");
                    if lrecShippingAgent."Vendor No." = '' then
                        Error(Text002, PWHead."Shipping Agent Code");
                end;
                PWLine.SetRange("Order Date", PWHead."Order Date");
                PWLine.SetRange("Order No.", PWHead."Order No.");
                if PWLine.Find('-') then begin
                    Clear(PurchaseHeader);
                    PurchaseHeader.Init;
                    PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::Order);
                    PurchaseHeader.Insert(true);
                    PurchaseHeader.Validate("Buy-from Vendor No.", PWHead."Vendor No.");
                    PurchaseHeader.Validate("Shipping Agent Code", PWHead."Shipping Agent Code");
                    PurchaseHeader.Validate("Order Date", PWHead."Order Date");
                    PurchaseHeader.Validate("Posting Date", PWHead."Expected Receipt Date");
                    PurchaseHeader.Validate("Expected Receipt Date", PWHead."Expected Receipt Date");
                    PurchaseHeader.Validate("Location Code", LocCode);
                    PurchaseHeader.Validate("Vendor Order No.", PWHead."Customer PO");
                    PurchaseHeader."Lock Pricing" := true;
                    PurchaseHeader."Exp. Delivery Appointment Date" := PWHead."Expected Pickup Date";

                    PurchaseHeader.Modify(true);

                    PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                    PurchaseLine."Document No." := PurchaseHeader."No.";
                    repeat
                        PurchaseLine.Init;
                        PurchaseLine."Line No." += 10000;
                        PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
                        PurchaseLine.Validate("No.", PWLine."Item No.");
                        PurchaseLine.Validate("Variant Code", PWLine."Variant Code");
                        PurchaseLine.Validate(Quantity, PWLine.Quantity);
                        PurchaseLine."Lock Pricing ELA" := true;

                        if PWLine."Unit Price" <> 0 then
                            PurchaseLine.Validate("List Cost", PWLine."Unit Price");
                        PurchaseLine.Insert;

                        lcduCustomRecordExtMgt.isPurchLineExtGet(PurchaseLine, lrecCustomRecordExt, true);
                        PWLine.Delete(true);

                    until PWLine.Next = 0;

                    if PWHead."Freight Cost" <> 0 then begin
                        AdditionalFreight.Reset();
                        AdditionalFreight.SetRange("Order Date", PWHead."Order Date");
                        AdditionalFreight.SetRange("Order No.", PWHead."Order No.");
                        IF AdditionalFreight.Findset() then begin
                            repeat
                                lcodPurchaseInvoiceNo :=
    lcduOrderShAllocateFreight.CreatECEntry(PurchaseHeader, AdditionalFreight);

                                lrecFreightPurchaseOrder.Get(lrecFreightPurchaseOrder."Document Type"::Order, lcodPurchaseInvoiceNo);
                                lrecFreightPurchaseOrder."Your Reference" := PurchaseHeader."No.";
                                lrecFreightPurchaseOrder.Modify;
                                AdditionalFreight.Delete(true);
                            until AdditionalFreight.Next() = 0;
                            DocExtraCharge.Reset();
                            DocExtraCharge.SetRange("Document No.", PurchaseHeader."No.");
                            DocExtraCharge.SetRange("Document Type", PurchaseHeader."Document Type");
                            IF DocExtraCharge.FindSet() then begin
                                IF NOT EVALUATE(PurchaseHeader."Document Type", DocExtraCharge.GETFILTER("Document Type")) THEN
                                    EXIT;
                                IF NOT EVALUATE(PurchaseHeader."No.", DocExtraCharge.GETFILTER("Document No.")) THEN
                                    EXIT;
                                IF NOT PurchaseHeader.FIND('=') THEN
                                    EXIT;
                                PurchaseHeader.TESTFIELD(Status, PurchaseHeader.Status::Open);

                                ExtraChrgMgt.AllocateChargesToLines(DocExtraCharge."Table ID", PurchaseHeader."Document Type", // P8000928
                                  PurchaseHeader."No.", PurchaseHeader."Currency Code", ExtraCharge);                              // P8000928
                                UserSetup.GET(USERID);
                                IF UserSetup."Allow EC Button Use ELA" = FALSE
                                  THEN
                                    ERROR(Text50000);
                                PDocExtraChrge.SetTableView(DocExtraCharge);
                                PDocExtraChrge.CreateExtraChargeSummary;
                                PDocExtraChrge.CreateVendInv;

                            end;

                        end;


                    end;
                end;
                PWHead.Delete(true);

            until PWHead.Next = 0;

    end;


    procedure jfCalcUnitCost(): Decimal
    var
        lrecPurchaseWorksheetHeader: Record "Purchase Worksheet Header";
        lrecPHeaderTMP: Record "Purchase Header" temporary;
        lrecPLineTMP: Record "Purchase Line" temporary;
        PurchPriceCalcMgt: Codeunit "Purch. Price Calc. Mgt.";
    begin
        CurrPage.Matrix.PAGE.GetRecord(lrecPurchaseWorksheetHeader);

        lrecPHeaderTMP."Document Type" := lrecPHeaderTMP."Document Type"::Order;
        lrecPHeaderTMP."No." := '999999';
        lrecPHeaderTMP."Buy-from Vendor No." := lrecPurchaseWorksheetHeader."Vendor No.";
        lrecPHeaderTMP."Pay-to Vendor No." := lrecPurchaseWorksheetHeader."Vendor No.";

        lrecPLineTMP."Document Type" := lrecPLineTMP."Document Type"::Order;
        lrecPLineTMP."Document No." := lrecPHeaderTMP."No.";
        lrecPLineTMP."Line No." := 1;
        lrecPLineTMP.Type := lrecPLineTMP.Type::Item;
        lrecPLineTMP."No." := ItemList."Item No.";
        lrecPLineTMP."Variant Code" := ItemList."Variant Code";
        lrecPLineTMP."Pay-to Vendor No." := lrecPurchaseWorksheetHeader."Vendor No.";
        lrecPLineTMP."Buy-from Vendor No." := lrecPurchaseWorksheetHeader."Vendor No.";
        lrecPLineTMP."Country/Reg of Origin Code ELA" := lrecPLineTMP.jfGetPurchPriceUOM;


        PurchPriceCalcMgt.FindPurchLinePrice(lrecPHeaderTMP, lrecPLineTMP, 0);
        exit(lrecPLineTMP."Direct Unit Cost");
    end;


    procedure jfSetColumns(SetWanted: Option Initial,Previous,Same,Next)
    var
        i: Integer;
        MatrixMgt: Codeunit "Matrix Management";
        CaptionFieldNo: Integer;
        CurrentMatrixRecordOrdinal: Integer;
        BananaWrkshtNewFunctions: Codeunit BananaWrkshtNewFunctions;
    begin
        Clear(MatrixColumnCaptions);
        Clear(MatrixRecords);
        CurrentMatrixRecordOrdinal := 1;

        for i := 1 to ArrayLen(MatrixRecords) do begin
        end;

        MatrixRecordRef.GetTable(MatrixRecord);
        MatrixRecordRef.SetTable(MatrixRecord);

        CaptionFieldNo := 0;


        BananaWrkshtNewFunctions.jfSetMultiFieldColumnCaption(MatrixRecord.FieldNo("Item No."), MatrixRecord.FieldNo("Variant Code"), 0);

        BananaWrkshtNewFunctions.GenerateMatrixData(MatrixRecordRef, SetWanted, ArrayLen(MatrixRecords), CaptionFieldNo, MatrixPKFirstRecInCurrSet,
          MatrixColumnCaptions, MatrixCaptionRange, MatrixCurrSetLength);

        if MatrixCurrSetLength > 0 then begin
            MatrixRecord.SetPosition(MatrixPKFirstRecInCurrSet);
            MatrixRecord.Find;
            repeat
                MatrixRecords[CurrentMatrixRecordOrdinal].Copy(MatrixRecord);
                CurrentMatrixRecordOrdinal := CurrentMatrixRecordOrdinal + 1;
            until (CurrentMatrixRecordOrdinal > MatrixCurrSetLength) or (MatrixRecord.Next <> 1);
        end;
        jfSetMatrix;
    end;

    procedure jfSetMatrix()
    begin
        CurrPage.Matrix.PAGE.Load(
                                  MatrixColumnCaptions,
                                  MatrixRecords,
                                  LocCode,
                                  OrderDate
                                  );
    end;
}

