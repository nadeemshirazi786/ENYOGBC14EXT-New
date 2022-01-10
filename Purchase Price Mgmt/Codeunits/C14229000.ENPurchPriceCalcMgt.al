codeunit 14229000 "EN Purch. Price Calc. Mgt."
{

    trigger OnRun()
    begin
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
        Vend: Record Vendor;
        ResCost: Record "Resource Cost";
        Currency: Record Currency;
        TempPurchPrice: Record "Purchase Price" temporary;
        TempPurchLineDisc: Record "Purchase Line Discount" temporary;
        LineDiscPerCent: Decimal;
        Qty: Decimal;
        QtyPerUOM: Decimal;
        VATPerCent: Decimal;
        PricesInclVAT: Boolean;
        VATBusPostingGr: Code[20];
        PricesInCurrency: Boolean;
        PriceInSKU: Boolean;
        CurrencyFactor: Decimal;
        ExchRateDate: Date;
        FoundPurchPrice: Boolean;
        DateCaption: Text[30];
        Text000: Label '%1 is less than %2 in the %3.';
        Text001: Label 'The %1 in the %2 must be same as in the %3.';
        gcodVendNo: code[20];
        gcodOrderAddCode: code[20];
        gcodPriceGrp: code[10];
        gcodPurchPriceUOM: code[10];
        gcodPurchLineLocCode: code[20];
        gdecPurchPriceUOMQtyPer: Integer;
        gdecPurchPriceUOMQtyPerBaseUOM: Integer;
        grecPurchSetup: Record "Purchases & Payables Setup";
        gblnPriceFromItem: Boolean;
        gblnPriceFromSKU: Boolean;
        grecItemUOM: Record "Item Unit of Measure";

    procedure FindPurchLinePrice(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; CalledByFieldNo: Integer)
    begin
        WITH PurchLine DO BEGIN
            SetCurrency(
              PurchHeader."Currency Code", PurchHeader."Currency Factor", PurchHeaderExchDate(PurchHeader));
            SetVAT(PurchHeader."Prices Including VAT", "VAT %", "VAT Bus. Posting Group");
            SetUoM(ABS(Quantity), "Qty. per Unit of Measure");
            SetLineDisc("Line Discount %");

            TESTFIELD("Qty. per Unit of Measure");
            IF PricesInCurrency THEN
                PurchHeader.TESTFIELD("Currency Factor");

            CASE Type OF
                Type::Item:
                    BEGIN
                        Item.GET("No.");
                        Vend.GET("Pay-to Vendor No.");
                        PriceInSKU := SKU.GET("Location Code", "No.", "Variant Code");
                        PurchLinePriceExists(PurchHeader, PurchLine, FALSE);

                        grecPurchSetup.GET;
                        CASE grecPurchSetup."Purchase Pricing Model ELA" OF
                            grecPurchSetup."Purchase Pricing Model ELA"::"Best Price":
                                BEGIN
                                    CalcBestDirectUnitCost(TempPurchPrice);
                                END;
                            grecPurchSetup."Purchase Pricing Model ELA"::"Specific Price":
                                BEGIN
                                    CalcSpecificUnitCost(TempPurchPrice, PurchHeader, PurchLine);
                                END;
                        END;

                        //CalcBestDirectUnitCost(TempPurchPrice);

                        IF (FoundPurchPrice OR
                            NOT ((CalledByFieldNo = FIELDNO(Quantity)) OR
                                 ((CalledByFieldNo = FIELDNO("Variant Code")) AND NOT PriceInSKU))) AND
                           ("Prepmt. Amt. Inv." = 0)
                        THEN begin
                            //"Direct Unit Cost" := TempPurchPrice."Direct Unit Cost";
                            isSetYogDirectUnitCost(PurchLine, TempPurchPrice);

                            IF TempPurchPrice."Direct Unit Cost" <> 0 THEN BEGIN
                                IF gblnPriceFromItem THEN BEGIN
                                    "Purchase Price Source ELA" := 'Item';
                                END ELSE BEGIN
                                    IF gblnPriceFromSKU THEN BEGIN
                                        "Purchase Price Source ELA" := 'SKU';
                                    END ELSE BEGIN
                                        "Purchase Price Source ELA" := FORMAT(TempPurchPrice."Purchase Type ELA");
                                    END;
                                END;
                            END ELSE BEGIN
                                "Purchase Price Source ELA" := '';
                            END;
                        END;
                    end;
            END;
        END;
        OnAfterFindPurchLinePrice(PurchLine, PurchHeader, TempPurchPrice, CalledByFieldNo);
    END;


    procedure FindItemJnlLinePrice(var ItemJnlLine: Record "Item Journal Line"; CalledByFieldNo: Integer)
    begin
        WITH ItemJnlLine DO BEGIN
            TESTFIELD("Qty. per Unit of Measure");
            SetCurrency('', 0, 0D);
            SetVAT(FALSE, 0, '');
            SetUoM(ABS(Quantity), "Qty. per Unit of Measure");

            Item.GET("Item No.");
            PriceInSKU := SKU.GET("Location Code", "Item No.", "Variant Code");

            FindPurchPrice(
              TempPurchPrice, '', "Item No.", "Variant Code",
              "Unit of Measure Code", '', "Posting Date", FALSE, '');

            OnFindItemJnlLinePriceOnBeforeCalcBestDirectUnitCost(ItemJnlLine, TempPurchPrice);
            CalcBestDirectUnitCost(TempPurchPrice);

            IF FoundPurchPrice OR
               NOT ((CalledByFieldNo = FIELDNO(Quantity)) OR
                    ((CalledByFieldNo = FIELDNO("Variant Code")) AND NOT PriceInSKU))
            THEN
                "Unit Amount" := TempPurchPrice."Direct Unit Cost";
        END;
    end;

    procedure FindReqLinePrice(var ReqLine: Record "Requisition Line"; CalledByFieldNo: Integer)
    var
        VendorNo: Code[20];
        IsHandled: Boolean;
    begin
        WITH ReqLine DO
            IF Type = Type::Item THEN BEGIN
                IF NOT Vend.GET("Vendor No.") THEN
                    Vend.INIT
                ELSE
                    IF Vend."Pay-to Vendor No." <> '' THEN
                        IF NOT Vend.GET(Vend."Pay-to Vendor No.") THEN
                            Vend.INIT;
                IF Vend."No." <> '' THEN
                    VendorNo := Vend."No."
                ELSE
                    VendorNo := "Vendor No.";

                SetCurrency("Currency Code", "Currency Factor", "Order Date");
                SetVAT(Vend."Prices Including VAT", 0, '');
                SetUoM(ABS(Quantity), "Qty. per Unit of Measure");

                TESTFIELD("Qty. per Unit of Measure");
                IF PricesInCurrency THEN
                    TESTFIELD("Currency Factor");

                Item.GET("No.");
                PriceInSKU := SKU.GET("Location Code", "No.", "Variant Code");

                IsHandled := FALSE;
                OnBeforeFindReqLinePrice(TempPurchPrice, ReqLine, IsHandled);
                IF NOT IsHandled THEN
                    FindPurchPrice(
                      TempPurchPrice, VendorNo, "No.", "Variant Code",
                      "Unit of Measure Code", "Currency Code", "Order Date", FALSE, Vend."Vendor Price Group ELA");
                CalcBestDirectUnitCost(TempPurchPrice);

                IF FoundPurchPrice OR
                   NOT ((CalledByFieldNo = FIELDNO(Quantity)) OR
                        ((CalledByFieldNo = FIELDNO("Variant Code")) AND NOT PriceInSKU))
                THEN
                    "Direct Unit Cost" := TempPurchPrice."Direct Unit Cost";
            END;

        OnAfterFindReqLinePrice(ReqLine, TempPurchPrice, CalledByFieldNo);
    end;

    procedure FindPurchLineLineDisc(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    begin
        WITH PurchLine DO BEGIN
            SetCurrency(PurchHeader."Currency Code", 0, 0D);
            SetUoM(ABS(Quantity), "Qty. per Unit of Measure");

            TESTFIELD("Qty. per Unit of Measure");

            IF Type = Type::Item THEN BEGIN
                PurchLineLineDiscExists(PurchHeader, PurchLine, FALSE);
                CalcBestLineDisc(TempPurchLineDisc);

                "Line Discount %" := TempPurchLineDisc."Line Discount %";
            END;

            OnAfterFindPurchLineLineDisc(PurchLine, PurchHeader, TempPurchLineDisc);
        END;
    end;

    procedure FindStdItemJnlLinePrice(var StdItemJnlLine: Record "Standard Item Journal Line"; CalledByFieldNo: Integer)
    begin
        WITH StdItemJnlLine DO BEGIN
            TESTFIELD("Qty. per Unit of Measure");
            SetCurrency('', 0, 0D);
            SetVAT(FALSE, 0, '');
            SetUoM(ABS(Quantity), "Qty. per Unit of Measure");

            Item.GET("Item No.");
            PriceInSKU := SKU.GET("Location Code", "Item No.", "Variant Code");

            FindPurchPrice(
              TempPurchPrice, '', "Item No.", "Variant Code",
              "Unit of Measure Code", '', WORKDATE, FALSE, '');
            CalcBestDirectUnitCost(TempPurchPrice);

            IF FoundPurchPrice OR
               NOT ((CalledByFieldNo = FIELDNO(Quantity)) OR
                    ((CalledByFieldNo = FIELDNO("Variant Code")) AND NOT PriceInSKU))
            THEN
                "Unit Amount" := TempPurchPrice."Direct Unit Cost";
        END;
    end;

    procedure FindReqLineDisc(var ReqLine: Record "Requisition Line")
    var
        IsHandled: Boolean;
    begin
        WITH ReqLine DO BEGIN
            SetCurrency("Currency Code", 0, 0D);
            SetUoM(ABS(Quantity), "Qty. per Unit of Measure");

            TESTFIELD("Qty. per Unit of Measure");

            IF Type = Type::Item THEN BEGIN
                IsHandled := FALSE;
                OnBeforeFindReqLineDisc(ReqLine, TempPurchLineDisc, IsHandled);
                IF NOT IsHandled THEN
                    FindPurchLineDisc(
                      TempPurchLineDisc, "Vendor No.", "No.", "Variant Code",
                      "Unit of Measure Code", "Currency Code", "Order Date", FALSE,
                      "Qty. per Unit of Measure", ABS(Quantity));
                OnAfterFindReqLineDisc(ReqLine);
                CalcBestLineDisc(TempPurchLineDisc);

                "Line Discount %" := TempPurchLineDisc."Line Discount %";
            END;
        END;
    end;

    local procedure CalcBestDirectUnitCost(var PurchPrice: Record "Purchase Price")
    var
        BestPurchPrice: Record "Purchase Price";
        IsHandled: Boolean;
        BestPurchPriceFound: Boolean;
    begin

        WITH PurchPrice DO BEGIN
            FoundPurchPrice := FIND('-');
            IF FoundPurchPrice THEN
                REPEAT
                    IF IsInMinQty("Unit of Measure Code", "Minimum Quantity") THEN BEGIN
                        ConvertPriceToVAT(
                          Vend."Prices Including VAT", Item."VAT Prod. Posting Group",
                          Vend."VAT Bus. Posting Group", "Direct Unit Cost");
                        ConvertPriceToUoM("Unit of Measure Code", "Direct Unit Cost");
                        ConvertPriceLCYToFCY("Currency Code", "Direct Unit Cost");

                        //-- If the direct unit cost is the same use the entry as we want to use the most applicable in this scenario
                        CASE TRUE OF
                            ((BestPurchPrice."Currency Code" = '') AND ("Currency Code" <> '')) OR
                          ((BestPurchPrice."Variant Code" = '') AND ("Variant Code" <> '')):
                                BestPurchPrice := PurchPrice;
                            ((BestPurchPrice."Currency Code" = '') OR ("Currency Code" <> '')) AND
                          ((BestPurchPrice."Variant Code" = '') OR ("Variant Code" <> '')):
                                IF (BestPurchPrice."Direct Unit Cost" = 0) OR
                                   (CalcLineAmount(BestPurchPrice) >= CalcLineAmount(PurchPrice))
                                THEN
                                    BestPurchPrice := PurchPrice;
                        END;
                    END;
                UNTIL NEXT = 0;
        END;

        IF (gcodPurchPriceUOM <> '') AND (gdecPurchPriceUOMQtyPer <> 0) AND (gdecPurchPriceUOMQtyPerBaseUOM <> 0) THEN BEGIN
            IF gdecPurchPriceUOMQtyPer < 1 THEN
                BestPurchPrice."Direct Unit Cost" :=
                  ROUND(BestPurchPrice."Direct Unit Cost" * QtyPerUOM *
                        gdecPurchPriceUOMQtyPerBaseUOM, Currency."Unit-Amount Rounding Precision")
            ELSE
                BestPurchPrice."Direct Unit Cost" :=
                  ROUND(BestPurchPrice."Direct Unit Cost" * QtyPerUOM / gdecPurchPriceUOMQtyPer, Currency."Unit-Amount Rounding Precision");
        END;
        gblnPriceFromSKU := FALSE;
        gblnPriceFromItem := FALSE;

        // No price found in agreement
        IF BestPurchPrice."Direct Unit Cost" = 0 THEN BEGIN
            PriceInSKU := PriceInSKU AND (SKU."Last Direct Cost" <> 0);

            IF PriceInSKU THEN BEGIN
                BestPurchPrice."Direct Unit Cost" := SKU."Last Direct Cost";
                gblnPriceFromSKU := TRUE;
            END ELSE BEGIN
                BestPurchPrice."Direct Unit Cost" := Item."Last Direct Cost";
                gblnPriceFromItem := TRUE;
            END;

            ConvertPriceToVAT(FALSE, Item."VAT Prod. Posting Group", '', BestPurchPrice."Direct Unit Cost");
            ConvertPriceToUoM('', BestPurchPrice."Direct Unit Cost");
            ConvertPriceLCYToFCY('', BestPurchPrice."Direct Unit Cost");
        END;

        PurchPrice := BestPurchPrice;

    end;

    local procedure CalcBestLineDisc(var PurchLineDisc: Record "Purchase Line Discount")
    var
        BestPurchLineDisc: Record "Purchase Line Discount";
    begin
        WITH PurchLineDisc DO
            IF FIND('-') THEN
                REPEAT
                    IF IsInMinQty("Unit of Measure Code", "Minimum Quantity") THEN
                        CASE TRUE OF
                            ((BestPurchLineDisc."Currency Code" = '') AND ("Currency Code" <> '')) OR
                          ((BestPurchLineDisc."Variant Code" = '') AND ("Variant Code" <> '')):
                                BestPurchLineDisc := PurchLineDisc;
                            ((BestPurchLineDisc."Currency Code" = '') OR ("Currency Code" <> '')) AND
                          ((BestPurchLineDisc."Variant Code" = '') OR ("Variant Code" <> '')):
                                IF BestPurchLineDisc."Line Discount %" < "Line Discount %" THEN
                                    BestPurchLineDisc := PurchLineDisc;
                        END;
                UNTIL NEXT = 0;

        PurchLineDisc := BestPurchLineDisc;
    end;

    local procedure FindPurchPrice(var ToPurchPrice: Record "Purchase Price"; VendorNo: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date; ShowAll: Boolean; pcodVendPriceGrCode: Code[10])
    var
        FromPurchPrice: Record "Purchase Price";
    begin
        OnBeforeFindPurchPrice(
          ToPurchPrice, FromPurchPrice, VendorNo, ItemNo, VariantCode, UOM, CurrencyCode, StartingDate, ShowAll, Qty, QtyPerUOM);

        gcodVendNo := VendorNo;
        gcodPriceGrp := pcodVendPriceGrCode;
        WITH FromPurchPrice DO BEGIN
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Vendor No.", VendorNo);
            SETRANGE("Location Code ELA", gcodPurchLineLocCode);
            SETFILTER("Ending Date", '%1|>=%2', 0D, StartingDate);
            SETFILTER("Variant Code", '%1|%2', VariantCode, '');
            IF NOT ShowAll THEN BEGIN
                SETRANGE("Starting Date", 0D, StartingDate);
                SETFILTER("Currency Code", '%1|%2', CurrencyCode, '');
                SETFILTER("Unit of Measure Code", '%1|%2', UOM, '');

                IF gcodPurchPriceUOM <> '' THEN
                    SETFILTER("Unit of Measure Code", '%1|%2', gcodPurchPriceUOM, '');
            END;


            //-- If no entries exist here for the specific Location Code, look for entries with blank Location Code
            IF FromPurchPrice.ISEMPTY THEN
                SETFILTER("Location Code ELA", '%1', '');
            //</JF4062MG>

            ToPurchPrice.RESET;
            ToPurchPrice.DELETEALL;

            //<JF8569SHR>

            SETRANGE("Purchase Type ELA", "Purchase Type ELA"::"All Vendors");
            SETRANGE("Vendor No.");

            CopyPurchPriceToPurchPrice(FromPurchPrice, ToPurchPrice);

            IF VendorNo <> '' THEN BEGIN
                SETRANGE("Purchase Type ELA", "Purchase Type ELA"::Vendor);
                SETRANGE("Vendor No.", VendorNo);
                SETRANGE("Order Address Code ELA", '');

                CopyPurchPriceToPurchPrice(FromPurchPrice, ToPurchPrice);
            END;

            IF gcodOrderAddCode <> '' THEN BEGIN
                SETRANGE("Order Address Code ELA", gcodOrderAddCode);

                CopyPurchPriceToPurchPrice(FromPurchPrice, ToPurchPrice);
            END;

            IF gcodPriceGrp <> '' THEN BEGIN
                SETRANGE("Purchase Type ELA", "Purchase Type ELA"::"Vendor Price Group");
                SETRANGE("Vendor No.", gcodPriceGrp);
                SETRANGE("Order Address Code ELA");

                CopyPurchPriceToPurchPrice(FromPurchPrice, ToPurchPrice);
            END;

            RankPurchPriceLines(ToPurchPrice);
        END;

        OnAfterFindPurchPrice(
          ToPurchPrice, FromPurchPrice, VendorNo, ItemNo, VariantCode, UOM, CurrencyCode, StartingDate, ShowAll, Qty, QtyPerUOM);
    end;

    local procedure FindPurchLineDisc(var ToPurchLineDisc: Record "Purchase Line Discount"; VendorNo: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date; ShowAll: Boolean; QuantityPerUoM: Decimal; Quantity: Decimal)
    var
        FromPurchLineDisc: Record "Purchase Line Discount";
    begin
        WITH FromPurchLineDisc DO BEGIN
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Vendor No.", VendorNo);
            SETFILTER("Ending Date", '%1|>=%2', 0D, StartingDate);
            SETFILTER("Variant Code", '%1|%2', VariantCode, '');
            IF NOT ShowAll THEN BEGIN
                SETRANGE("Starting Date", 0D, StartingDate);
                SETFILTER("Currency Code", '%1|%2', CurrencyCode, '');
                SETFILTER("Unit of Measure Code", '%1|%2', UOM, '');
            END;

            ToPurchLineDisc.RESET;
            ToPurchLineDisc.DELETEALL;

            IF FIND('-') THEN
                REPEAT
                    ToPurchLineDisc := FromPurchLineDisc;
                    ToPurchLineDisc.INSERT;
                UNTIL NEXT = 0;
        END;

        OnAfterFindPurchLineDisc(ToPurchLineDisc, FromPurchLineDisc, ItemNo, QuantityPerUoM, Quantity, ShowAll);
    end;

    local procedure SetCurrency(CurrencyCode2: Code[10]; CurrencyFactor2: Decimal; ExchRateDate2: Date)
    begin
        PricesInCurrency := CurrencyCode2 <> '';
        IF PricesInCurrency THEN BEGIN
            Currency.GET(CurrencyCode2);
            Currency.TESTFIELD("Unit-Amount Rounding Precision");
            CurrencyFactor := CurrencyFactor2;
            ExchRateDate := ExchRateDate2;
        END ELSE
            GLSetup.GET;
    end;

    local procedure SetVAT(PriceInclVAT2: Boolean; VATPerCent2: Decimal; VATBusPostingGr2: Code[20])
    begin
        PricesInclVAT := PriceInclVAT2;
        VATPerCent := VATPerCent2;
        VATBusPostingGr := VATBusPostingGr2;
    end;

    local procedure SetUoM(Qty2: Decimal; QtyPerUoM2: Decimal)
    begin
        Qty := Qty2;
        QtyPerUOM := QtyPerUoM2;
    end;

    local procedure SetLineDisc(LineDiscPerCent2: Decimal)
    begin
        LineDiscPerCent := LineDiscPerCent2;
    end;

    local procedure IsInMinQty(UnitofMeasureCode: Code[10]; MinQty: Decimal): Boolean
    begin
        IF UnitofMeasureCode = '' THEN
            EXIT(MinQty <= QtyPerUOM * Qty);
        EXIT(MinQty <= Qty);
    end;

    local procedure ConvertPriceToVAT(FromPriceInclVAT: Boolean; FromVATProdPostingGr: Code[20]; FromVATBusPostingGr: Code[20]; var UnitPrice: Decimal)
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        IF FromPriceInclVAT THEN BEGIN
            IF NOT VATPostingSetup.GET(FromVATBusPostingGr, FromVATProdPostingGr) THEN
                VATPostingSetup.INIT;
            OnBeforeConvertPriceToVAT(VATPostingSetup);

            IF PricesInclVAT THEN BEGIN
                IF VATBusPostingGr <> FromVATBusPostingGr THEN
                    UnitPrice := UnitPrice * (100 + VATPerCent) / (100 + VATPostingSetup."VAT %");
            END ELSE
                UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
        END ELSE
            IF PricesInclVAT THEN
                UnitPrice := UnitPrice * (1 + VATPerCent / 100);
    end;

    local procedure ConvertPriceToUoM(UnitOfMeasureCode: Code[10]; var UnitPrice: Decimal)
    begin
        IF UnitOfMeasureCode = '' THEN
            UnitPrice := UnitPrice * QtyPerUOM;
    end;

    local procedure ConvertPriceLCYToFCY(CurrencyCode: Code[10]; var UnitPrice: Decimal)
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        IF PricesInCurrency THEN BEGIN
            IF CurrencyCode = '' THEN
                UnitPrice :=
                  CurrExchRate.ExchangeAmtLCYToFCY(ExchRateDate, Currency.Code, UnitPrice, CurrencyFactor);
            UnitPrice := ROUND(UnitPrice, Currency."Unit-Amount Rounding Precision");
        END ELSE
            UnitPrice := ROUND(UnitPrice, GLSetup."Unit-Amount Rounding Precision");
    end;

    local procedure CalcLineAmount(PurchPrice: Record "Purchase Price"): Decimal
    begin
        WITH PurchPrice DO
            EXIT("Direct Unit Cost" * (1 - LineDiscPerCent / 100));
    end;

    local procedure PurchLinePriceExists(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; ShowAll: Boolean): Boolean
    var
        IsHandled: Boolean;
    begin


        gcodOrderAddCode := PurchHeader."Order Address Code";
        gcodPurchPriceUOM := '';
        gdecPurchPriceUOMQtyPer := 1;

        IF (PurchLine.Type = PurchLine.Type::Item) AND (PurchLine."Purch Price Unit of Meas. ELA" <> '') THEN BEGIN
            gcodPurchPriceUOM := PurchLine."Purch Price Unit of Meas. ELA";
            grecItemUOM.GET(PurchLine."No.", PurchLine."Purch Price Unit of Meas. ELA");
            gdecPurchPriceUOMQtyPer := grecItemUOM."Qty. per Unit of Measure";
            gdecPurchPriceUOMQtyPerBaseUOM := grecItemUOM."Qty. per Base UOM ELA";
        END;
        gcodPurchLineLocCode := PurchLine."Location Code";

        WITH PurchLine DO
            IF (Type = Type::Item) AND Item.GET("No.") THEN BEGIN
                grecPurchSetup.GET;
                CASE grecPurchSetup."Purchase Price Source ELA" OF
                    grecPurchSetup."Purchase Price Source ELA"::"Pay-To Vendor":
                        BEGIN
                            FindPurchPrice(
                              TempPurchPrice, "Pay-to Vendor No.", "No.", "Variant Code", "Unit of Measure Code",
                              PurchHeader."Currency Code", PurchHeaderLineStartDate(PurchHeader, DateCaption,
                              PurchLine, PurchHeader."Pay-to Vendor No."), ShowAll, "Vendor Price Group ELA");
                        END;
                    grecPurchSetup."Purchase Price Source ELA"::"Buy-From Vendor":
                        BEGIN
                            FindPurchPrice(
                              TempPurchPrice, "Buy-from Vendor No.", "No.", "Variant Code", "Unit of Measure Code",
                              PurchHeader."Currency Code", PurchHeaderLineStartDate(PurchHeader, DateCaption,
                              PurchLine, PurchHeader."Buy-from Vendor No."), ShowAll, "Vendor Price Group ELA");
                        END;
                END;
                EXIT(TempPurchPrice.FIND('-'));
            END;
        EXIT(FALSE);

    end;

    local procedure PurchLineLineDiscExists(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; ShowAll: Boolean): Boolean
    var
        IsHandled: Boolean;
    begin
        WITH PurchLine DO
            IF (Type = Type::Item) AND Item.GET("No.") THEN BEGIN
                IsHandled := FALSE;
                OnBeforePurchLineLineDiscExists(PurchLine, PurchHeader, TempPurchLineDisc, ShowAll, IsHandled);
                IF NOT IsHandled THEN
                    FindPurchLineDisc(
                      TempPurchLineDisc, "Pay-to Vendor No.", "No.", "Variant Code", "Unit of Measure Code",
                      PurchHeader."Currency Code", PurchHeaderStartDate(PurchHeader, DateCaption), ShowAll,
                      "Qty. per Unit of Measure", Quantity);
                OnAfterPurchLineLineDiscExists(PurchLine);
                EXIT(TempPurchLineDisc.FIND('-'));
            END;
        EXIT(FALSE);
    end;

    local procedure PurchHeaderExchDate(var PurchHeader: Record "Purchase Header"): Date
    begin
        WITH PurchHeader DO BEGIN
            IF "Posting Date" <> 0D THEN
                EXIT("Posting Date");
            EXIT(WORKDATE);
        END;
    end;

    local procedure PurchHeaderStartDate(var PurchHeader: Record "Purchase Header"; var DateCaption: Text[30]): Date
    begin
        WITH PurchHeader DO
            IF "Document Type" IN ["Document Type"::Invoice, "Document Type"::"Credit Memo"] THEN BEGIN
                DateCaption := FIELDCAPTION("Posting Date");
                EXIT("Posting Date")
            END ELSE BEGIN
                DateCaption := FIELDCAPTION("Order Date");
                EXIT("Order Date");
            END;
    end;

    procedure FindJobPlanningLinePrice(var JobPlanningLine: Record "Job Planning Line"; CalledByFieldNo: Integer)
    var
        JTHeader: Record Job;
    begin
        WITH JobPlanningLine DO BEGIN
            SetCurrency("Currency Code", "Currency Factor", "Planning Date");
            SetVAT(FALSE, 0, '');
            SetUoM(ABS(Quantity), "Qty. per Unit of Measure");

            TESTFIELD("Qty. per Unit of Measure");

            CASE Type OF
                Type::Item:
                    BEGIN
                        Item.GET("No.");
                        PriceInSKU := SKU.GET('', "No.", "Variant Code");
                        JTHeader.GET("Job No.");

                        FindPurchPrice(
                          TempPurchPrice, '', "No.", "Variant Code", "Unit of Measure Code", '', "Planning Date", FALSE, '');
                        PricesInCurrency := FALSE;
                        GLSetup.GET;
                        CalcBestDirectUnitCost(TempPurchPrice);
                        SetCurrency("Currency Code", "Currency Factor", "Planning Date");

                        IF FoundPurchPrice OR
                           NOT ((CalledByFieldNo = FIELDNO(Quantity)) OR
                                ((CalledByFieldNo = FIELDNO("Variant Code")) AND NOT PriceInSKU))
                        THEN
                            "Direct Unit Cost (LCY)" := TempPurchPrice."Direct Unit Cost";
                    END;
                Type::Resource:
                    BEGIN
                        ResCost.INIT;
                        ResCost.Code := "No.";
                        ResCost."Work Type Code" := "Work Type Code";
                        CODEUNIT.RUN(CODEUNIT::"Resource-Find Cost", ResCost);
                        OnAfterJobPlanningLineFindResCost(JobPlanningLine, CalledByFieldNo, ResCost);
                        ConvertPriceLCYToFCY("Currency Code", ResCost."Unit Cost");
                        "Direct Unit Cost (LCY)" := ROUND(ResCost."Direct Unit Cost" * "Qty. per Unit of Measure",
                            Currency."Unit-Amount Rounding Precision");
                        VALIDATE("Unit Cost (LCY)", ROUND(ResCost."Unit Cost" * "Qty. per Unit of Measure",
                            Currency."Unit-Amount Rounding Precision"));
                    END;
            END;
            VALIDATE("Direct Unit Cost (LCY)");
        END;
    end;

    procedure FindJobJnlLinePrice(var JobJnlLine: Record "Job Journal Line"; CalledByFieldNo: Integer)
    var
        Job: Record Job;
        IsHandled: Boolean;
    begin
        WITH JobJnlLine DO BEGIN
            SetCurrency("Currency Code", "Currency Factor", "Posting Date");
            SetVAT(FALSE, 0, '');
            SetUoM(ABS(Quantity), "Qty. per Unit of Measure");

            TESTFIELD("Qty. per Unit of Measure");

            CASE Type OF
                Type::Item:
                    BEGIN
                        Item.GET("No.");
                        PriceInSKU := SKU.GET('', "No.", "Variant Code");
                        Job.GET("Job No.");

                        FindPurchPrice(
                          TempPurchPrice, '', "No.", "Variant Code", "Unit of Measure Code", "Country/Region Code", "Posting Date", FALSE, '');
                        PricesInCurrency := FALSE;
                        GLSetup.GET;

                        OnFindJobJnlLinePriceOnBeforeCalcBestDirectUnitCost(JobJnlLine, TempPurchPrice);
                        CalcBestDirectUnitCost(TempPurchPrice);
                        SetCurrency("Currency Code", "Currency Factor", "Posting Date");

                        IF FoundPurchPrice OR
                           NOT ((CalledByFieldNo = FIELDNO(Quantity)) OR
                                ((CalledByFieldNo = FIELDNO("Variant Code")) AND NOT PriceInSKU))
                        THEN
                            "Direct Unit Cost (LCY)" := TempPurchPrice."Direct Unit Cost";
                        OnAfterFindJobJnlLinePriceItem(JobJnlLine);
                    END;
                Type::Resource:
                    BEGIN
                        ResCost.INIT;
                        ResCost.Code := "No.";
                        ResCost."Work Type Code" := "Work Type Code";
                        CODEUNIT.RUN(CODEUNIT::"Resource-Find Cost", ResCost);
                        OnAfterJobJnlLineFindResCost(JobJnlLine, CalledByFieldNo, ResCost);
                        ConvertPriceLCYToFCY("Currency Code", ResCost."Unit Cost");
                        "Direct Unit Cost (LCY)" :=
                          ROUND(ResCost."Direct Unit Cost" * "Qty. per Unit of Measure", Currency."Unit-Amount Rounding Precision");
                        VALIDATE("Unit Cost (LCY)",
                          ROUND(ResCost."Unit Cost" * "Qty. per Unit of Measure", Currency."Unit-Amount Rounding Precision"));
                        OnAfterFindJobJnlLinePriceResource(JobJnlLine);
                    END;
            END;
            OnAfterFindJobJnlLinePrice(JobJnlLine, IsHandled);
            IF NOT IsHandled THEN
                VALIDATE("Direct Unit Cost (LCY)");
        END;
    end;

    procedure NoOfPurchLinePrice(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; ShowAll: Boolean): Integer
    begin
        IF PurchLinePriceExists(PurchHeader, PurchLine, ShowAll) THEN
            EXIT(TempPurchPrice.COUNT);
    end;

    procedure NoOfPurchLineLineDisc(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; ShowAll: Boolean): Integer
    begin
        IF PurchLineLineDiscExists(PurchHeader, PurchLine, ShowAll) THEN
            EXIT(TempPurchLineDisc.COUNT);
    end;

    procedure GetPurchLinePrice(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    begin
        PurchLinePriceExists(PurchHeader, PurchLine, TRUE);

        WITH PurchLine DO
            IF PAGE.RUNMODAL(PAGE::"Get Purchase Price", TempPurchPrice) = ACTION::LookupOK THEN BEGIN
                SetVAT(PurchHeader."Prices Including VAT", "VAT %", "VAT Bus. Posting Group");
                SetUoM(ABS(Quantity), "Qty. per Unit of Measure");
                SetCurrency(PurchHeader."Currency Code", PurchHeader."Currency Factor", PurchHeaderExchDate(PurchHeader));
                OnGetPurchLinePriceOnAfterLookup(PurchHeader, PurchLine, TempPurchPrice);

                IF NOT IsInMinQty(TempPurchPrice."Unit of Measure Code", TempPurchPrice."Minimum Quantity") THEN
                    ERROR(
                      Text000,
                      FIELDCAPTION(Quantity),
                      TempPurchPrice.FIELDCAPTION("Minimum Quantity"),
                      TempPurchPrice.TABLECAPTION);
                IF NOT (TempPurchPrice."Currency Code" IN ["Currency Code", '']) THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION("Currency Code"),
                      TABLECAPTION,
                      TempPurchPrice.TABLECAPTION);
                IF NOT (TempPurchPrice."Unit of Measure Code" IN ["Unit of Measure Code", '']) THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION("Unit of Measure Code"),
                      TABLECAPTION,
                      TempPurchPrice.TABLECAPTION);
                IF TempPurchPrice."Starting Date" > PurchHeaderStartDate(PurchHeader, DateCaption) THEN
                    ERROR(
                      Text000,
                      DateCaption,
                      TempPurchPrice.FIELDCAPTION("Starting Date"),
                      TempPurchPrice.TABLECAPTION);

                ConvertPriceToVAT(
                  PurchHeader."Prices Including VAT", Item."VAT Prod. Posting Group",
                  "VAT Bus. Posting Group", TempPurchPrice."Direct Unit Cost");
                ConvertPriceToUoM(TempPurchPrice."Unit of Measure Code", TempPurchPrice."Direct Unit Cost");
                ConvertPriceLCYToFCY(TempPurchPrice."Currency Code", TempPurchPrice."Direct Unit Cost");

                VALIDATE("Direct Unit Cost", TempPurchPrice."Direct Unit Cost");
            END;

        OnAfterGetPurchLinePrice(PurchHeader, PurchLine, TempPurchPrice);
    end;

    procedure GetPurchLineLineDisc(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    begin
        PurchLineLineDiscExists(PurchHeader, PurchLine, TRUE);

        WITH PurchLine DO
            IF PAGE.RUNMODAL(PAGE::"Get Purchase Line Disc.", TempPurchLineDisc) = ACTION::LookupOK THEN BEGIN
                SetCurrency(PurchHeader."Currency Code", 0, 0D);
                SetUoM(ABS(Quantity), "Qty. per Unit of Measure");
                OnGetPurchLineLineDiscOnAfterLookup(PurchHeader, PurchLine, TempPurchLineDisc);

                IF NOT IsInMinQty(TempPurchLineDisc."Unit of Measure Code", TempPurchLineDisc."Minimum Quantity") THEN
                    ERROR(
                      Text000, FIELDCAPTION(Quantity),
                      TempPurchLineDisc.FIELDCAPTION("Minimum Quantity"),
                      TempPurchLineDisc.TABLECAPTION);
                IF NOT (TempPurchLineDisc."Currency Code" IN ["Currency Code", '']) THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION("Currency Code"),
                      TABLECAPTION,
                      TempPurchLineDisc.TABLECAPTION);
                IF NOT (TempPurchLineDisc."Unit of Measure Code" IN ["Unit of Measure Code", '']) THEN
                    ERROR(
                      Text001,
                      FIELDCAPTION("Unit of Measure Code"),
                      TABLECAPTION,
                      TempPurchLineDisc.TABLECAPTION);
                IF TempPurchLineDisc."Starting Date" > PurchHeaderStartDate(PurchHeader, DateCaption) THEN
                    ERROR(
                      Text000,
                      DateCaption,
                      TempPurchLineDisc.FIELDCAPTION("Starting Date"),
                      TempPurchLineDisc.TABLECAPTION);

                VALIDATE("Line Discount %", TempPurchLineDisc."Line Discount %");
            END;
    end;

    procedure CalcSpecificUnitCost(VAR PurchPrice: Record "Purchase Price"; precPurchHeader: Record "Purchase Header"; precPurchLine: Record "Purchase Line")
    var
        BestPurchPrice: Record "Purchase Price";
        lblnFoundSpecific: Boolean;
    begin

        WITH PurchPrice DO BEGIN
            FoundPurchPrice := FINDSET;

            IF FoundPurchPrice THEN BEGIN
                //-- Look for Order Address pricing first
                PurchPrice.SETRANGE("Purchase Type ELA", PurchPrice."Purchase Type ELA"::Vendor);
                PurchPrice.SETRANGE("Vendor No.", gcodVendNo);
                PurchPrice.SETRANGE("Order Address Code ELA", gcodOrderAddCode);
                lblnFoundSpecific := FindSpecificUnitCost(PurchPrice, BestPurchPrice,
                                                       '', FALSE);

                //-- otherwise look for Vendor pricing
                IF NOT lblnFoundSpecific THEN BEGIN
                    PurchPrice.SETRANGE("Order Address Code ELA");
                    lblnFoundSpecific := FindSpecificUnitCost(PurchPrice, BestPurchPrice,
                                                                   '', FALSE);
                END;

                //-- otherwise look for Vendor Price Group
                IF NOT lblnFoundSpecific THEN BEGIN
                    PurchPrice.SETRANGE("Purchase Type ELA", PurchPrice."Purchase Type ELA"::"Vendor Price Group");
                    PurchPrice.SETRANGE("Vendor No.", gcodPriceGrp);
                    lblnFoundSpecific := FindSpecificUnitCost(PurchPrice, BestPurchPrice,
                                                                   gcodPriceGrp, TRUE);
                END;

                //-- otherwise look for pricing applying to All Vendors
                IF NOT lblnFoundSpecific THEN BEGIN
                    PurchPrice.SETRANGE("Purchase Type ELA", PurchPrice."Purchase Type ELA"::"All Vendors");
                    PurchPrice.SETRANGE("Vendor No.");
                    lblnFoundSpecific := FindSpecificUnitCost(PurchPrice, BestPurchPrice,
                                                                   '', FALSE);
                END;

            END; // IF FoundPurchPrice THEN BEGIN

        END; // WITH PurchPrice DO BEGIN


        IF (gcodPurchPriceUOM <> '') AND (gdecPurchPriceUOMQtyPer <> 0) AND (gdecPurchPriceUOMQtyPerBaseUOM <> 0) THEN BEGIN
            IF gdecPurchPriceUOMQtyPer < 1 THEN BEGIN
                BestPurchPrice."Direct Unit Cost" :=
                  ROUND(BestPurchPrice."Direct Unit Cost" * QtyPerUOM * gdecPurchPriceUOMQtyPerBaseUOM,
                        Currency."Unit-Amount Rounding Precision");
            END ELSE BEGIN
                BestPurchPrice."Direct Unit Cost" :=
                  ROUND(BestPurchPrice."Direct Unit Cost" * QtyPerUOM / gdecPurchPriceUOMQtyPer, Currency."Unit-Amount Rounding Precision");
            END;
        END;


        // No price found in agreement
        IF BestPurchPrice."Direct Unit Cost" = 0 THEN BEGIN
            ConvertPriceToVAT(
              Item."Price Includes VAT", Item."VAT Prod. Posting Group",
              Item."VAT Bus. Posting Gr. (Price)", Item."Last Direct Cost");
            ConvertPriceToUoM('', Item."Last Direct Cost");
            ConvertPriceLCYToFCY('', Item."Last Direct Cost");

            CLEAR(BestPurchPrice);
            BestPurchPrice."Direct Unit Cost" := Item."Last Direct Cost";
        END;


        PurchPrice := BestPurchPrice;


    end;

    procedure FindSpecificUnitCost(VAR PurchPrice: Record "Purchase Price"; VAR BestPurchPrice: Record "Purchase Price"; pcodTypeCode: Code[20]; pblnRequireTypeCode: Boolean) pblnResult: Boolean
    begin

        IF pblnRequireTypeCode AND (pcodTypeCode = '') THEN BEGIN
            EXIT(FALSE);
        END;

        WITH PurchPrice DO BEGIN
            IF NOT FINDSET THEN BEGIN
                EXIT(FALSE);
            END ELSE BEGIN
                REPEAT

                    IF IsInMinQty("Unit of Measure Code", "Minimum Quantity") THEN BEGIN
                        ConvertPriceToUoM("Unit of Measure Code", "Direct Unit Cost");
                        ConvertPriceLCYToFCY("Currency Code", "Direct Unit Cost");


                        //-- If the unit price is the same use the entry as we want to use the most applicable in this scenario
                        CASE TRUE OF
                            ((BestPurchPrice."Currency Code" = '') AND ("Currency Code" <> '')) OR
                          ((BestPurchPrice."Variant Code" = '') AND ("Variant Code" <> '')):
                                BestPurchPrice := PurchPrice;
                            ((BestPurchPrice."Currency Code" = '') OR ("Currency Code" <> '')) AND
                          ((BestPurchPrice."Variant Code" = '') OR ("Variant Code" <> '')):
                                IF (BestPurchPrice."Direct Unit Cost" = 0) OR
                                   (CalcLineAmount(BestPurchPrice) >= CalcLineAmount(PurchPrice)) OR //-- use >= not >
                                   (PurchPrice."Starting Date" >= BestPurchPrice."Starting Date")
                                THEN
                                    BestPurchPrice := PurchPrice;
                        END;
                    END;
                UNTIL NEXT = 0;
            END;
        END;

        EXIT(TRUE);
    end;

    Procedure isSetYogDirectUnitCost(VAR precPurchLine: Record "Purchase Line"; VAR precPurchPriceTEMP: Record "Purchase Price")
    begin


        precPurchPriceTEMP.isCalcYogAmounts(precPurchLine."Unit of Measure Code");
        precPurchLine."Upcharge Amount ELA" := precPurchPriceTEMP."Upcharge Amount ELA";
        precPurchLine."Billback Amount ELA" := 0 - precPurchPriceTEMP."Billback Amount ELA";
        precPurchLine."Discount 1 Amount ELA" := 0 - precPurchPriceTEMP."Discount 1 Amount ELA";
        precPurchLine."List Cost ELA" := precPurchPriceTEMP."List Cost ELA";
        precPurchLine."Direct Unit Cost" := precPurchPriceTEMP."List Cost ELA" + precPurchPriceTEMP."Upcharge Amount ELA" - precPurchPriceTEMP."Discount 1 Amount ELA" - precPurchPriceTEMP."Billback Amount ELA";
        precPurchLine."Overhead Rate" := Item."Overhead Rate";
        precPurchLine."Unit Cost (LCY)" := precPurchLine."Direct Unit Cost" + precPurchLine."Overhead Rate";
        precPurchLine."Freight Amount ELA" := precPurchPriceTEMP."Freight Amount ELA";

    end;

    procedure CopyPurchPriceToPurchPrice(VAR FromPurchPrice: Record "Purchase Price"; VAR ToPurchPrice: Record "Purchase Price")
    begin

        WITH ToPurchPrice DO BEGIN
            IF FromPurchPrice.FINDSET THEN
                REPEAT
                    IF FromPurchPrice."Direct Unit Cost" <> 0 THEN BEGIN
                        ToPurchPrice := FromPurchPrice;
                        INSERT;
                    END;
                UNTIL FromPurchPrice.NEXT = 0;
        END;
    end;

    procedure RankPurchPriceLines(VAR precPurchPrice: Record "Purchase Price" TEMPORARY)
    begin

        precPurchPrice.RESET;
        IF NOT precPurchPrice.FINDSET THEN
            EXIT;

        REPEAT
            CASE precPurchPrice."Purchase Type ELA" OF
                precPurchPrice."Purchase Type ELA"::Vendor:
                    BEGIN
                        precPurchPrice."Specific Pricing Rank ELA" += 12;
                        IF precPurchPrice."Order Address Code ELA" <> '' THEN
                            precPurchPrice."Specific Pricing Rank ELA" += 2;
                    END;
                precPurchPrice."Purchase Type ELA"::"Vendor Price Group":
                    BEGIN
                        precPurchPrice."Specific Pricing Rank ELA" += 8;
                    END;
                precPurchPrice."Purchase Type ELA"::"All Vendors":
                    BEGIN
                        precPurchPrice."Specific Pricing Rank ELA" += 2;
                    END;
            END;
            IF precPurchPrice."Variant Code" <> '' THEN
                precPurchPrice."Specific Pricing Rank ELA" += 2;

            IF precPurchPrice."Unit of Measure Code" <> '' THEN
                precPurchPrice."Specific Pricing Rank ELA" += 2;

            precPurchPrice.MODIFY;
        UNTIL precPurchPrice.NEXT = 0;
    end;

    procedure PurchHeaderLineStartDate(PurchHeader: Record "Purchase Header"; VAR DateCaption: Text[30]; precPurchLine: Record "Purchase Line"; pcodVendorNo: Code[20]): Date
    var
        lrecVendor: Record Vendor;
    begin

        WITH PurchHeader DO
            IF "Document Type" IN ["Document Type"::Invoice, "Document Type"::"Credit Memo"] THEN BEGIN
                DateCaption := FIELDCAPTION("Posting Date");
                EXIT("Posting Date")
            END ELSE BEGIN
                IF pcodVendorNo <> '' THEN BEGIN
                    lrecVendor.GET(pcodVendorNo);
                    WITH precPurchLine DO BEGIN
                        CASE lrecVendor."Purch. Price/Sur. Dt Cntrl ELA" OF
                            lrecVendor."Purch. Price/Sur. Dt Cntrl ELA"::"Order Date":
                                BEGIN
                                    //-- Order Date should be used from the header as we want it to be the date the order was entered not the date the
                                    //-- might calculate at the line level because of lead times, etc.
                                    DateCaption := PurchHeader.FIELDCAPTION("Order Date");
                                    EXIT(PurchHeader."Order Date");

                                END;
                            lrecVendor."Purch. Price/Sur. Dt Cntrl ELA"::"Expected Receipt Date":
                                BEGIN
                                    DateCaption := FIELDCAPTION("Expected Receipt Date");
                                    EXIT("Expected Receipt Date");
                                END;
                        END;
                    END;
                END ELSE BEGIN
                    DateCaption := FIELDCAPTION("Order Date");
                    EXIT("Order Date");
                END;

            END;

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindJobJnlLinePrice(var JobJournalLine: Record "Job Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindJobJnlLinePriceItem(var JobJournalLine: Record "Job Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindJobJnlLinePriceResource(var JobJournalLine: Record "Job Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindPurchPrice(var ToPurchPrice: Record "Purchase Price"; FromPurchasePrice: Record "Purchase Price"; VendorNo: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date; ShowAll: Boolean; Qty: Decimal; QtyPerUOM: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindPurchLinePrice(var PurchaseLine: Record "Purchase Line"; var PurchaseHeader: Record "Purchase Header"; var PurchasePrice: Record "Purchase Price"; CalledByFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindPurchLineDisc(var ToPurchaseLineDiscount: Record "Purchase Line Discount"; var FromPurchaseLineDiscount: Record "Purchase Line Discount"; ItemNo: Code[20]; QuantityPerUoM: Decimal; Quantity: Decimal; ShowAll: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindPurchLineLineDisc(var PurchaseLine: Record "Purchase Line"; var PurchaseHeader: Record "Purchase Header"; var TempPurchLineDisc: Record "Purchase Line Discount" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindReqLinePrice(var ReqLine: Record "Requisition Line"; var TempPurchasePrice: Record "Purchase Price" temporary; CalledByFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindReqLineDisc(var ReqLine: Record "Requisition Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetPurchLinePrice(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; var TempPurchasePrice: Record "Purchase Price" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterJobJnlLineFindResCost(var JobJournalLine: Record "Job Journal Line"; CalledByFieldNo: Integer; var ResourceCost: Record "Resource Cost")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterJobPlanningLineFindResCost(var JobPlanningLine: Record "Job Planning Line"; CalledByFieldNo: Integer; var ResourceCost: Record "Resource Cost")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPurchLineLineDiscExists(var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPurchLinePriceExists(var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConvertPriceToVAT(var VATPostingSetup: Record "VAT Posting Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindPurchPrice(var ToPurchPrice: Record "Purchase Price"; var FromPurchasePrice: Record "Purchase Price"; var VendorNo: Code[20]; var ItemNo: Code[20]; var VariantCode: Code[10]; var UOM: Code[10]; var CurrencyCode: Code[10]; var StartingDate: Date; var ShowAll: Boolean; var Qty: Decimal; var QtyPerUOM: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindReqLinePrice(var TempPurchasePrice: Record "Purchase Price" temporary; var ReqLine: Record "Requisition Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindReqLineDisc(var ReqLine: Record "Requisition Line"; var TempPurchaseLineDiscount: Record "Purchase Line Discount" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePurchLinePriceExists(var PurchaseLine: Record "Purchase Line"; var PurchaseHeader: Record "Purchase Header"; var TempPurchasePrice: Record "Purchase Price" temporary; ShowAll: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePurchLineLineDiscExists(var PurchaseLine: Record "Purchase Line"; var PurchaseHeader: Record "Purchase Header"; var TempPurchLineDisc: Record "Purchase Line Discount" temporary; ShowAll: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcBestDirectUnitCostOnAfterSetUnitCost(var PurchasePrice: Record "Purchase Price")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcBestDirectUnitCostOnBeforeNoPriceFound(var PurchasePrice: Record "Purchase Price"; Item: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetPurchLinePriceOnAfterLookup(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; var TempPurchasePrice: Record "Purchase Price" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetPurchLineLineDiscOnAfterLookup(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; var TempPurchaseLineDiscount: Record "Purchase Line Discount" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindItemJnlLinePriceOnBeforeCalcBestDirectUnitCost(var ItemJournalLine: Record "Item Journal Line"; var TempPurchasePrice: Record "Purchase Price" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindJobJnlLinePriceOnBeforeCalcBestDirectUnitCost(var JobJournalLine: Record "Job Journal Line"; var TempPurchasePrice: Record "Purchase Price" temporary)
    begin
    end;
}

