/// <summary>
/// Codeunit EN Sales Price Calc. Mgt. (ID 14228852).
/// </summary>

codeunit 14228852 "EN Sales Price Calc. Mgt."
{

    trigger OnRun()
    begin
    end;

    var
        ENSalesSetup: Record "Sales & Receivables Setup";
        gSalesHeader: Record "Sales Header";
        gCustomer: Record "Customer";
        grecTmpSalesPriceCalcLine: Record "EN Sales Price" temporary;
        grecTempSalesListPrice: Record "Sales Price" Temporary;
        enumPriceEvaluationRank: Enum "EN Price Evaluation Rank";
        gblnUseOppositeModel: Boolean;
        gblnUseRefItemNo: Boolean;
        gblnSalesPriceCalcFound: Boolean;
        gPriceRuleBestPrice: Boolean;
        gPriceRuleSepecificPrice: Boolean;
        gblnPriceFromItem: Boolean;
        gblnDiscAmtMode: Boolean;
        gTempSalesListPrice: Record "Sales Price" temporary;
        gcodCustNo: code[20];
        gcodShipto: code[10];
        gcodPriceGrp: Code[10];
        gcodCampaign: Code[20];
        gcodPriceRuleCode: Code[10];
        gcodCustBuyingGrp: code[10];
        gcodPriceListGroup: Code[10];
        gcodLocation: Code[10];
        gcodCustUOM: code[10];
        gdecCustUOMQtyPer: Decimal;
        gdecPriceGroupPrice: Decimal;
        gdecCustUOMQtyPerBaseUOM: Decimal;
        gintSalesType: Integer;
        grecItemUOM: Record "Item Unit of Measure";
        GLSetup: Record "General Ledger Setup";
        Item: Record Item;
        ResPrice: Record "Resource Price";
        Res: Record Resource;
        Currency: Record Currency;
        Text000: Label '%1 is less than %2 in the %3.';
        Text010: Label 'Prices including VAT cannot be calculated when %1 is %2.';
        TempSalesPrice: Record "Sales Price" temporary;
        TempSalesLineDisc: Record "Sales Line Discount" temporary;
        LineDiscPerCent: Decimal;
        Qty: Decimal;
        AllowLineDisc: Boolean;
        AllowInvDisc: Boolean;
        VATPerCent: Decimal;
        PricesInclVAT: Boolean;
        VATCalcType: Option "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        VATBusPostingGr: Code[20];
        QtyPerUOM: Decimal;
        PricesInCurrency: Boolean;
        CurrencyFactor: Decimal;
        ExchRateDate: Date;
        Text018: Label '%1 %2 is greater than %3 and was adjusted to %4.';
        FoundSalesPrice: Boolean;
        Text001: Label 'The %1 in the %2 must be same as in the %3.';
        TempTableErr: Label 'The table passed as a parameter must be temporary.';
        HideResUnitPriceMessage: Boolean;
        DateCaption: Text[30];


    /// <summary>
    /// FindSalesLinePrice.
    /// </summary>
    /// <param name="SalesHeader">Record "Sales Header".</param>
    /// <param name="SalesLine">VAR Record "Sales Line".</param>
    /// <param name="CalledByFieldNo">Integer.</param>
    procedure FindSalesLinePrice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer)
    var
        IsHandled: Boolean;
    begin
        ENSalesSetup.GET;
        IsHandled := false;
        if IsHandled then
            exit;

        SetCurrency(
          SalesHeader."Currency Code", SalesHeader."Currency Factor", SalesHeaderExchDate(SalesHeader));
        SetVAT(SalesHeader."Prices Including VAT", SalesLine."VAT %", SalesLine."VAT Calculation Type", SalesLine."VAT Bus. Posting Group");
        SetUoM(Abs(SalesLine.Quantity), SalesLine."Qty. per Unit of Measure");
        SetLineDisc(SalesLine."Line Discount %", SalesLine."Allow Line Disc.", SalesLine."Allow Invoice Disc.");

        SalesLine.TestField(SalesLine."Qty. per Unit of Measure");
        if PricesInCurrency then
            SalesHeader.TestField("Currency Factor");

        gblnUseRefItemNo := FALSE;
        gSalesHeader := SalesHeader;
        GetSetupAndPriceRank(SalesHeader."Sell-to Customer No.", SalesHeader."Bill-to Customer No.");

        case SalesLine.Type of
            SalesLine.Type::Item:
                begin
                    Item.Get(SalesLine."No.");
                    SalesLinePriceExists(SalesHeader, SalesLine, false);

                    CASE ENSalesSetup."Sales Pricing Model ELA" OF
                        ENSalesSetup."Sales Pricing Model ELA"::"Best Price":
                            BEGIN

                                IF gblnUseOppositeModel THEN BEGIN
                                    CalcSpecificUnitPrice(TempSalesPrice, SalesHeader, SalesLine);
                                    Item.GET(SalesLine."No.");
                                    CalcSpecificUnitPrice(grecTempSalesListPrice, SalesHeader, SalesLine);
                                END ELSE BEGIN
                                    CalcBestUnitPrice(TempSalesPrice);
                                    Item.GET(SalesLine."No.");
                                    CalcBestUnitPrice(grecTempSalesListPrice);
                                END;

                            END;
                        ENSalesSetup."Sales Pricing Model ELA"::"Specific Price":
                            BEGIN
                                IF gblnUseOppositeModel THEN BEGIN
                                    CalcBestUnitPrice(TempSalesPrice);
                                    Item.GET(SalesLine."No.");
                                    CalcBestUnitPrice(grecTempSalesListPrice);
                                END ELSE BEGIN
                                    CalcSpecificUnitPrice(TempSalesPrice, SalesHeader, SalesLine);
                                    Item.GET(SalesLine."No.");
                                    CalcSpecificUnitPrice(grecTempSalesListPrice, SalesHeader, SalesLine);
                                    IF (SalesLine."Unit Price" <> TempSalesPrice."Unit Price") THEN
                                        FoundSalesPrice := TRUE;
                                END;

                            END;
                    END;
                    /// Was before the calc price calls above - moved here to accomodate new rules in sales price calculations to allow price
                    /// calcs to be done on sales prices
                    RunSalesPriceCalcCheck(SalesHeader, SalesLine);
                    //Apply price calc to sales price IF APPLICABLE
                    IF grecTmpSalesPriceCalcLine."Calculation Cost Base" =
                       grecTmpSalesPriceCalcLine."Calculation Cost Base"::"Sales Price"
                    THEN BEGIN
                        CASE grecTmpSalesPriceCalcLine."Calculation Type" OF
                            grecTmpSalesPriceCalcLine."Calculation Type"::"Markup (%)":
                                BEGIN
                                    TempSalesPrice."Unit Price" := TempSalesPrice."Unit Price" * (1 + (grecTmpSalesPriceCalcLine.Value / 100));
                                END;
                            grecTmpSalesPriceCalcLine."Calculation Type"::Value:
                                BEGIN

                                    //ConvertPriceToUoM(SalesLine."Unit of Measure Code", grecTmpSalesPriceCalcLine.Value); //RIPA

                                    TempSalesPrice."Unit Price" := TempSalesPrice."Unit Price" + grecTmpSalesPriceCalcLine.Value;
                                END;
                            grecTmpSalesPriceCalcLine."Calculation Type"::"Margin (%)":
                                BEGIN
                                    TempSalesPrice."Unit Price" :=
                                      TempSalesPrice."Unit Price" * 100 /
                                      (100 - grecTmpSalesPriceCalcLine.Value);
                                END;
                        END;
                    END;

                    IF grecTmpSalesPriceCalcLine."Calculation Cost Base" =
                       grecTmpSalesPriceCalcLine."Calculation Cost Base"::"Price List"
                    THEN BEGIN
                        //Get List Price
                        //Apply calculation to it
                        CASE grecTmpSalesPriceCalcLine."Calculation Type" OF
                            grecTmpSalesPriceCalcLine."Calculation Type"::"Markup (%)":
                                BEGIN
                                    grecTempSalesListPrice."Unit Price" :=
                                    grecTempSalesListPrice."Unit Price" * (1 + (grecTmpSalesPriceCalcLine.Value / 100));
                                END;
                            grecTmpSalesPriceCalcLine."Calculation Type"::Value:
                                BEGIN

                                    //ConvertPriceToUoM(SalesLine."Unit of Measure Code", grecTmpSalesPriceCalcLine.Value); //RIPA

                                    grecTempSalesListPrice."Unit Price" :=
                                      grecTempSalesListPrice."Unit Price" + grecTmpSalesPriceCalcLine.Value;
                                END;
                            grecTmpSalesPriceCalcLine."Calculation Type"::"Margin (%)":
                                BEGIN
                                    grecTempSalesListPrice."Unit Price" :=
                                      grecTempSalesListPrice."Unit Price" * 100 /
                                      (100 - grecTmpSalesPriceCalcLine.Value);
                                END;
                        END;
                        TempSalesPrice := grecTempSalesListPrice;
                        TempSalesPrice.MODIFY;
                    END;
                    //Now run the pricing algorithm again to see if there's a better price than the calc. price on prev. price algorithm
                    //<BG19974AS>
                    IF NOT grecTmpSalesPriceCalcLine.ISEMPTY THEN BEGIN
                        //gdecCustUOMQtyPerBaseUOM := 1; //RIPA
                        //QtyPerUOM := 1; //RIPA

                        CASE ENSalesSetup."Sales Pricing Model ELA" OF
                            ENSalesSetup."Sales Pricing Model ELA"::"Best Price":
                                BEGIN
                                    IF gblnUseOppositeModel THEN BEGIN
                                        CalcSpecificUnitPrice(TempSalesPrice, SalesHeader, SalesLine);
                                    END ELSE BEGIN
                                        CalcBestUnitPrice(TempSalesPrice);
                                    END;
                                END;
                            ENSalesSetup."Sales Pricing Model ELA"::"Specific Price":
                                BEGIN
                                    IF gblnUseOppositeModel THEN BEGIN
                                        CalcBestUnitPrice(TempSalesPrice);
                                    END ELSE BEGIN
                                        CalcSpecificUnitPrice(TempSalesPrice, SalesHeader, SalesLine);
                                    END;
                                END;
                        END;

                    END;

                    IF FoundSalesPrice OR gblnSalesPriceCalcFound OR

                       NOT ((CalledByFieldNo = SalesLine.FIELDNO(SalesLine.Quantity)) OR
                            (CalledByFieldNo = SalesLine.FIELDNO(SalesLine."Variant Code")))
                    THEN BEGIN
                        SalesLine."Allow Line Disc." := TempSalesPrice."Allow Line Disc.";
                        SalesLine."Allow Invoice Disc." := TempSalesPrice."Allow Invoice Disc.";
                        SalesLine."Unit Price" := TempSalesPrice."Unit Price";


                        IF TempSalesPrice."Unit Price" <> 0 THEN BEGIN

                            IF gblnPriceFromItem THEN BEGIN
                                SalesLine."Sales Price Source ELA" := 'Item';
                            END ELSE BEGIN
                                SalesLine."Sales Price Source ELA" := FORMAT(TempSalesPrice."Sales Type ELA");
                            END;

                        END ELSE BEGIN
                            SalesLine."Sales Price Source ELA" := '';
                        END;

                        SalesLine."Unit Price Prot Level ELA" := grecTmpSalesPriceCalcLine."Unit Price Protection Level";

                        IF gblnSalesPriceCalcFound THEN BEGIN
                            SalesLine."Price Calc. GUID ELA" := grecTmpSalesPriceCalcLine.GUID;
                            IF grecTmpSalesPriceCalcLine."Sales Type" = grecTmpSalesPriceCalcLine."Sales Type"::"Customer Price Group" THEN BEGIN
                                SalesLine."Customer Price Group" := grecTmpSalesPriceCalcLine."Sales Code";
                            END;
                        END;
                    end;

                    IF NOT SalesLine."Allow Line Disc." THEN BEGIN
                        SalesLine."Line Discount %" := 0;
                        SalesLine."Line Discount Amount" := 0;
                    END;
                end;
            SalesLine.Type::Resource:
                begin

                    IF SalesLine."Ref. Item No. ELA" = '' THEN BEGIN
                        SetResPrice(SalesLine."No.", SalesLine."Work Type Code", SalesLine."Currency Code");
                        CODEUNIT.Run(CODEUNIT::"Resource-Find Price", ResPrice);

                        ConvertPriceToVAT(FALSE, '', '', ResPrice."Unit Price");
                        ConvertPriceLCYToFCY(ResPrice."Currency Code", ResPrice."Unit Price");
                        SalesLine."Unit Price" := ResPrice."Unit Price" * SalesLine."Qty. per Unit of Measure";
                    END ELSE BEGIN
                        gblnUseRefItemNo := TRUE;

                        Item.GET(SalesLine."Ref. Item No. ELA");
                        SalesLinePriceExists(SalesHeader, SalesLine, FALSE);
                        RunSalesPriceCalcCheck(SalesHeader, SalesLine);

                        CASE ENSalesSetup."Sales Pricing Model ELA" OF
                            ENSalesSetup."Sales Pricing Model ELA"::"Best Price":
                                BEGIN
                                    IF gblnUseOppositeModel THEN BEGIN
                                        CalcSpecificUnitPrice(TempSalesPrice, SalesHeader, SalesLine);
                                    END ELSE BEGIN
                                        CalcBestUnitPrice(TempSalesPrice);
                                    END;
                                END;
                            ENSalesSetup."Sales Pricing Model ELA"::"Specific Price":
                                BEGIN
                                    IF gblnUseOppositeModel THEN BEGIN
                                        CalcBestUnitPrice(TempSalesPrice);
                                    END ELSE BEGIN
                                        CalcSpecificUnitPrice(TempSalesPrice, SalesHeader, SalesLine);
                                    END;
                                END;
                        END;

                        IF FoundSalesPrice OR
                           NOT ((CalledByFieldNo = SalesLine.FIELDNO(SalesLine.Quantity)) OR
                                (CalledByFieldNo = SalesLine.FIELDNO(SalesLine."Variant Code")))
                        THEN BEGIN
                            SalesLine."Allow Line Disc." := TempSalesPrice."Allow Line Disc.";
                            SalesLine."Allow Invoice Disc." := TempSalesPrice."Allow Invoice Disc.";
                            SalesLine."Unit Price" := TempSalesPrice."Unit Price";
                            IF TempSalesPrice."Unit Price" <> 0 THEN BEGIN
                                SalesLine."Sales Price Source ELA" := FORMAT(TempSalesPrice."Sales Type ELA");
                            END ELSE BEGIN
                                SalesLine."Sales Price Source ELA" := '';
                            END;
                        END;
                        IF NOT SalesLine."Allow Line Disc." THEN BEGIN
                            SalesLine."Line Discount %" := 0;
                            SalesLine."Line Discount Amount" := 0;
                        END;
                    END;

                end;

            SalesLine.Type::"G/L Account":
                BEGIN
                    IF SalesLine."Ref. Item No. ELA" <> '' THEN BEGIN
                        gblnUseRefItemNo := TRUE;
                        Item.GET(SalesLine."Ref. Item No. ELA");
                        SalesLinePriceExists(SalesHeader, SalesLine, FALSE);
                        RunSalesPriceCalcCheck(SalesHeader, SalesLine);
                        CASE ENSalesSetup."Sales Pricing Model ELA" OF
                            ENSalesSetup."Sales Pricing Model ELA"::"Best Price":
                                BEGIN

                                    IF gblnUseOppositeModel THEN BEGIN
                                        CalcSpecificUnitPrice(TempSalesPrice, SalesHeader, SalesLine);
                                    END ELSE BEGIN
                                        CalcBestUnitPrice(TempSalesPrice);
                                    END;

                                END;
                            ENSalesSetup."Sales Pricing Model ELA"::"Specific Price":
                                BEGIN

                                    IF gblnUseOppositeModel THEN BEGIN
                                        CalcBestUnitPrice(TempSalesPrice);
                                    END ELSE BEGIN
                                        CalcSpecificUnitPrice(TempSalesPrice, SalesHeader, SalesLine);
                                    END;

                                END;
                        END;


                        IF FoundSalesPrice OR
                           NOT ((CalledByFieldNo = SalesLine.FIELDNO(SalesLine.Quantity)) OR
                                (CalledByFieldNo = SalesLine.FIELDNO(SalesLine."Variant Code")))
                        THEN BEGIN
                            SalesLine."Allow Line Disc." := TempSalesPrice."Allow Line Disc.";
                            SalesLine."Allow Invoice Disc." := TempSalesPrice."Allow Invoice Disc.";
                            SalesLine."Unit Price" := TempSalesPrice."Unit Price";

                            IF TempSalesPrice."Unit Price" <> 0 THEN BEGIN
                                SalesLine."Sales Price Source ELA" := FORMAT(TempSalesPrice."Sales Type ELA");
                            END ELSE BEGIN
                                SalesLine."Sales Price Source ELA" := '';
                            END;

                        END;
                        IF NOT SalesLine."Allow Line Disc." THEN BEGIN
                            SalesLine."Line Discount %" := 0;
                            SalesLine."Line Discount Amount" := 0;
                        END;
                    END;
                END;
        END;
        // clear global variable now that we're done with it
        CLEAR(gSalesHeader);
    end;

    /// <summary>
    /// FindItemJnlLinePrice.
    /// </summary>
    /// <param name="ItemJnlLine">VAR Record "Item Journal Line".</param>
    /// <param name="CalledByFieldNo">Integer.</param>
    procedure FindItemJnlLinePrice(var ItemJnlLine: Record "Item Journal Line"; CalledByFieldNo: Integer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;

        if IsHandled then
            exit;


        SetCurrency('', 0, 0D);
        SetVAT(false, 0, 0, '');
        SetUoM(Abs(ItemJnlLine.Quantity), ItemJnlLine."Qty. per Unit of Measure");
        ItemJnlLine.TestField(ItemJnlLine."Qty. per Unit of Measure");
        Item.Get(ItemJnlLine."Item No.");

        FindSalesPrice(
          TempSalesPrice, '', '', '', '', ItemJnlLine."Item No.", ItemJnlLine."Variant Code",
          ItemJnlLine."Unit of Measure Code", '', ItemJnlLine."Posting Date", false);
        CalcBestUnitPrice(TempSalesPrice);
        if FoundSalesPrice or
           not ((CalledByFieldNo = ItemJnlLine.FieldNo(ItemJnlLine.Quantity)) or
                (CalledByFieldNo = ItemJnlLine.FieldNo(ItemJnlLine."Variant Code")))
        then
            ItemJnlLine.Validate("Unit Amount", TempSalesPrice."Unit Price");


    end;


    /// <summary>
    /// FindSalesLineLineDisc.
    /// </summary>
    /// <param name="SalesHeader">Record "Sales Header".</param>
    /// <param name="SalesLine">VAR Record "Sales Line".</param>
    procedure FindSalesLineLineDisc(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;

        if IsHandled then
            exit;


        SetCurrency(SalesHeader."Currency Code", 0, 0D);
        SetUoM(Abs(SalesLine.Quantity), SalesLine."Qty. per Unit of Measure");

        SalesLine.TestField("Qty. per Unit of Measure");
        gblnUseRefItemNo := FALSE;
        IsHandled := false;

        if not IsHandled then
            if SalesLine.Type = SalesLine.Type::Item then begin
                SalesLineLineDiscExists(SalesHeader, SalesLine, false);

                IF NOT gblnDiscAmtMode THEN BEGIN
                    CalcBestLineDisc(TempSalesLineDisc);
                    SalesLine."Line Discount %" := TempSalesLineDisc."Line Discount %";
                END ELSE BEGIN
                    SetCurrency(
                      SalesHeader."Currency Code", SalesHeader."Currency Factor", SalesHeaderExchDate(SalesHeader));
                    CalcBestLineDiscAmt(TempSalesLineDisc);
                    SalesLine."Line Discount Amount" := TempSalesLineDisc."Line Discount %";
                END;
            END ELSE BEGIN
                IF SalesLine."Ref. Item No. ELA" <> '' THEN BEGIN
                    gblnUseRefItemNo := TRUE;
                    SalesLineLineDiscExists(SalesHeader, SalesLine, FALSE);
                    IF NOT gblnDiscAmtMode THEN BEGIN
                        CalcBestLineDisc(TempSalesLineDisc);
                        SalesLine."Line Discount %" := TempSalesLineDisc."Line Discount %";
                    END ELSE BEGIN
                        SetCurrency(
                          SalesHeader."Currency Code", SalesHeader."Currency Factor", SalesHeaderExchDate(SalesHeader));
                        CalcBestLineDiscAmt(TempSalesLineDisc);
                        SalesLine."Line Discount Amount" := TempSalesLineDisc."Line Discount %";
                    END;

                END;
            END;



    end;


    /// <summary>
    /// FindStdItemJnlLinePrice.
    /// </summary>
    /// <param name="StdItemJnlLine">VAR Record "Standard Item Journal Line".</param>
    /// <param name="CalledByFieldNo">Integer.</param>
    procedure FindStdItemJnlLinePrice(var StdItemJnlLine: Record "Standard Item Journal Line"; CalledByFieldNo: Integer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := true;

        if IsHandled then
            exit;


        SetCurrency('', 0, 0D);
        SetVAT(false, 0, 0, '');
        SetUoM(Abs(StdItemJnlLine.Quantity), StdItemJnlLine."Qty. per Unit of Measure");
        StdItemJnlLine.TestField(StdItemJnlLine."Qty. per Unit of Measure");
        Item.Get(StdItemJnlLine."Item No.");

        FindSalesPrice(
          TempSalesPrice, '', '', '', '', StdItemJnlLine."Item No.", StdItemJnlLine."Variant Code",
          StdItemJnlLine."Unit of Measure Code", '', WorkDate, false);
        CalcBestUnitPrice(TempSalesPrice);
        if FoundSalesPrice or
           not ((CalledByFieldNo = StdItemJnlLine.FieldNo(Quantity)) or
                (CalledByFieldNo = StdItemJnlLine.FieldNo("Variant Code")))
        then
            StdItemJnlLine.Validate("Unit Amount", TempSalesPrice."Unit Price");


    end;

    /// <summary>
    /// FindAnalysisReportPrice.
    /// </summary>
    /// <param name="ItemNo">Code[20].</param>
    /// <param name="Date">Date.</param>
    /// <returns>Return value of type Decimal.</returns>
    procedure FindAnalysisReportPrice(ItemNo: Code[20]; Date: Date): Decimal
    var
        UnitPrice: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;

        if IsHandled then
            exit(UnitPrice);

        SetCurrency('', 0, 0D);
        SetVAT(false, 0, 0, '');
        SetUoM(0, 1);
        Item.Get(ItemNo);

        FindSalesPrice(TempSalesPrice, '', '', '', '', ItemNo, '', '', '', Date, false);
        CalcBestUnitPrice(TempSalesPrice);
        if FoundSalesPrice then
            exit(TempSalesPrice."Unit Price");
        exit(Item."Unit Price");
    end;

    /// <summary>
    /// CalcBestUnitPrice.
    /// </summary>
    /// <param name="SalesPrice">VAR Record "Sales Price".</param>
    procedure CalcBestUnitPrice(var SalesPrice: Record "Sales Price")
    var
        BestSalesPrice: Record "Sales Price";
        BestSalesPriceFound: Boolean;
        IsHandled: Boolean;
    begin

        if IsHandled then
            exit;


        FoundSalesPrice := SalesPrice.FindSet;
        if FoundSalesPrice then
            repeat
                if IsInMinQty(SalesPrice."Unit of Measure Code", SalesPrice."Minimum Quantity") then begin
                    ConvertPriceToVAT(
                      SalesPrice."Price Includes VAT", Item."VAT Prod. Posting Group",
                      SalesPrice."VAT Bus. Posting Gr. (Price)", SalesPrice."Unit Price");
                    ConvertPriceToUoM(SalesPrice."Unit of Measure Code", SalesPrice."Unit Price");

                    ConvertPriceToVAT(
                      SalesPrice."Price Includes VAT", Item."VAT Prod. Posting Group",
                      SalesPrice."VAT Bus. Posting Gr. (Price)", SalesPrice."Delivered Unit Price ELA");
                    ConvertPriceToUoM(SalesPrice."Unit of Measure Code", SalesPrice."Delivered Unit Price ELA");

                    ConvertPriceLCYToFCY(SalesPrice."Currency Code", SalesPrice."Unit Price");

                    case true of
                        ((BestSalesPrice."Currency Code" = '') and (SalesPrice."Currency Code" <> '')) or
                        ((BestSalesPrice."Variant Code" = '') and (SalesPrice."Variant Code" <> '')):
                            begin
                                BestSalesPrice := SalesPrice;
                                BestSalesPriceFound := true;
                            end;
                        ((BestSalesPrice."Currency Code" = '') or (SalesPrice."Currency Code" <> '')) and
                      ((BestSalesPrice."Variant Code" = '') or (SalesPrice."Variant Code" <> '')):
                            if (BestSalesPrice."Unit Price" = 0) or
                               (CalcLineAmount(BestSalesPrice) > CalcLineAmount(SalesPrice))
                            then begin
                                BestSalesPrice := SalesPrice;
                                BestSalesPriceFound := true;
                            end;
                    end;
                end;
            until SalesPrice.Next = 0;



        IF gdecPriceGroupPrice <> 0 THEN BEGIN
            IF gdecPriceGroupPrice < BestSalesPrice."Unit Price" THEN BEGIN
                BestSalesPrice."Unit Price" := gdecPriceGroupPrice;
                evaluate(BestSalesPrice."Sales Type ELA", Format(gintSalesType));
            END;
        END;
        IF (gcodCustUOM <> '') AND (gdecCustUOMQtyPer <> 0) AND (gdecCustUOMQtyPerBaseUOM <> 0) THEN BEGIN
            IF gdecCustUOMQtyPer < 1 THEN BEGIN
                BestSalesPrice."Unit Price" :=
                  ROUND(BestSalesPrice."Unit Price" * QtyPerUOM * gdecCustUOMQtyPerBaseUOM, Currency."Unit-Amount Rounding Precision");
                BestSalesPrice."Delivered Unit Price ELA" :=
                  ROUND(BestSalesPrice."Delivered Unit Price ELA" * QtyPerUOM *
                        gdecCustUOMQtyPerBaseUOM, Currency."Unit-Amount Rounding Precision");
            END ELSE BEGIN
                BestSalesPrice."Unit Price" :=
                  ROUND(BestSalesPrice."Unit Price" * QtyPerUOM / gdecCustUOMQtyPer, Currency."Unit-Amount Rounding Precision");
                BestSalesPrice."Delivered Unit Price ELA" :=
                  ROUND(BestSalesPrice."Delivered Unit Price ELA" * QtyPerUOM / gdecCustUOMQtyPer, Currency."Unit-Amount Rounding Precision");
            END;
        END;
        gblnPriceFromItem := FALSE;


        // No price found in agreement
        if not BestSalesPriceFound then begin
            ConvertPriceToVAT(
              Item."Price Includes VAT", Item."VAT Prod. Posting Group",
              Item."VAT Bus. Posting Gr. (Price)", Item."Unit Price");
            ConvertPriceToUoM('', Item."Unit Price");
            ConvertPriceLCYToFCY('', Item."Unit Price");

            Clear(BestSalesPrice);

            IF gdecPriceGroupPrice <> 0 THEN BEGIN
                BestSalesPrice."Unit Price" := gdecPriceGroupPrice;
                evaluate(BestSalesPrice."Sales Type ELA", Format(gintSalesType));
                IF (gcodCustUOM <> '') AND (gdecCustUOMQtyPer <> 0) AND (gdecCustUOMQtyPerBaseUOM <> 0) THEN BEGIN
                    IF gdecCustUOMQtyPer < 1 THEN BEGIN
                        BestSalesPrice."Unit Price" :=
                          ROUND(BestSalesPrice."Unit Price" * QtyPerUOM * gdecCustUOMQtyPerBaseUOM, Currency."Unit-Amount Rounding Precision");
                        BestSalesPrice."Delivered Unit Price ELA" :=
                          ROUND(BestSalesPrice."Delivered Unit Price ELA" * QtyPerUOM *
                            gdecCustUOMQtyPerBaseUOM, Currency."Unit-Amount Rounding Precision");
                    END ELSE BEGIN
                        BestSalesPrice."Unit Price" :=
                          ROUND(BestSalesPrice."Unit Price" * QtyPerUOM / gdecCustUOMQtyPer, Currency."Unit-Amount Rounding Precision");
                        BestSalesPrice."Delivered Unit Price ELA" :=
                          ROUND(BestSalesPrice."Delivered Unit Price ELA" * QtyPerUOM / gdecCustUOMQtyPer, Currency."Unit-Amount Rounding Precision");
                    END;
                END;
            END ELSE BEGIN
                BestSalesPrice."Unit Price" := Item."Unit Price";
                BestSalesPrice."Allow Line Disc." := AllowLineDisc;
                BestSalesPrice."Allow Invoice Disc." := AllowInvDisc;

                gblnPriceFromItem := TRUE;
            END;

        end;

        SalesPrice := BestSalesPrice;
    end;

    /// <summary>
    /// CalcBestLineDisc.
    /// </summary>
    /// <param name="SalesLineDisc">VAR Record "Sales Line Discount".</param>
    procedure CalcBestLineDisc(var SalesLineDisc: Record "Sales Line Discount")
    var
        BestSalesLineDisc: Record "Sales Line Discount";
        IsHandled: Boolean;
    begin
        IsHandled := false;

        if IsHandled then
            exit;

        SalesLineDisc.SETRANGE("Line Discount Type ELA", SalesLineDisc."Line Discount Type ELA"::Percent);
        if SalesLineDisc.FindSet then
            repeat
                if IsInMinQty(SalesLineDisc."Unit of Measure Code", SalesLineDisc."Minimum Quantity") then
                    case true of
                        ((BestSalesLineDisc."Currency Code" = '') and (SalesLineDisc."Currency Code" <> '')) or
                      ((BestSalesLineDisc."Variant Code" = '') and (SalesLineDisc."Variant Code" <> '')):
                            BestSalesLineDisc := SalesLineDisc;
                        ((BestSalesLineDisc."Currency Code" = '') or (SalesLineDisc."Currency Code" <> '')) and
                      ((BestSalesLineDisc."Variant Code" = '') or (SalesLineDisc."Variant Code" <> '')):
                            if BestSalesLineDisc."Line Discount %" < SalesLineDisc."Line Discount %" then
                                BestSalesLineDisc := SalesLineDisc;
                    end;
            until SalesLineDisc.Next = 0;


        SalesLineDisc := BestSalesLineDisc;
    end;

    /// <summary>
    /// FindSalesPrice.
    /// </summary>
    /// <param name="ToSalesPrice">VAR Record "Sales Price".</param>
    /// <param name="CustNo">Code[20].</param>
    /// <param name="ContNo">Code[20].</param>
    /// <param name="CustPriceGrCode">Code[10].</param>
    /// <param name="CampaignNo">Code[20].</param>
    /// <param name="ItemNo">Code[20].</param>
    /// <param name="VariantCode">Code[10].</param>
    /// <param name="UOM">Code[10].</param>
    /// <param name="CurrencyCode">Code[10].</param>
    /// <param name="StartingDate">Date.</param>
    /// <param name="ShowAll">Boolean.</param>
    procedure FindSalesPrice(var ToSalesPrice: Record "Sales Price"; CustNo: Code[20]; ContNo: Code[20]; CustPriceGrCode: Code[10]; CampaignNo: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date; ShowAll: Boolean)
    var
        FromSalesPrice: Record "Sales Price";
        TempTargetCampaignGr: Record "Campaign Target Group" temporary;
    begin
        if not ToSalesPrice.IsTemporary then
            Error(TempTableErr);

        ToSalesPrice.Reset();
        ToSalesPrice.DeleteAll();


        ENSalesSetup.GET;
        gcodCustNo := CustNo;
        gcodPriceGrp := CustPriceGrCode;
        gcodCampaign := CampaignNo;
        gcodPriceListGroup := '';
        gcodCustBuyingGrp := '';
        IF gcodCustNo <> '' THEN BEGIN
            GetCust(gcodCustNo);
            gcodCustBuyingGrp := gCustomer."Customer Buying Group ELA";
            gcodPriceListGroup := gCustomer."Price List Group Code ELA";
        END;
        // if this is from a Sales Line, grecSalesHeader will be valid; use its Price List Group Code
        // (always over-ride the Customer version if grecSalesHeader exists)
        IF gSalesHeader.FIND THEN BEGIN
            gcodPriceListGroup := gSalesHeader."Price List Group Code ELA";
        END;

        IF gcodPriceListGroup = '' THEN
            gcodPriceListGroup := ENSalesSetup."Global Price List Group ELA";
        FromSalesPrice.SetRange("Item No.", ItemNo);
        FromSalesPrice.SetFilter("Variant Code", '%1|%2', VariantCode, '');
        FromSalesPrice.SetFilter("Ending Date", '%1|>=%2', 0D, StartingDate);
        if not ShowAll then begin
            FromSalesPrice.SetFilter("Currency Code", '%1|%2', CurrencyCode, '');
            if UOM <> '' then
                FromSalesPrice.SetFilter("Unit of Measure Code", '%1|%2', UOM, '');

            IF gcodCustUOM <> '' THEN
                FromSalesPrice.SETFILTER("Unit of Measure Code", '%1|%2', gcodCustUOM, '');

            FromSalesPrice.SetRange("Starting Date", 0D, StartingDate);
        end;

        FromSalesPrice.SetRange("Sales Type ELA", FromSalesPrice."Sales Type ELA"::"All Customers");
        FromSalesPrice.SetRange("Sales Code");
        CopySalesPriceToSalesPrice(FromSalesPrice, ToSalesPrice);

        if CustNo <> '' then begin
            FromSalesPrice.SetRange("Sales Type ELA", FromSalesPrice."Sales Type ELA"::Customer);
            FromSalesPrice.SetRange("Sales Code", CustNo);

            FromSalesPrice.SETRANGE("Ship-To Code ELA", '');
            CopySalesPriceToSalesPrice(FromSalesPrice, ToSalesPrice);
        end;

        IF gcodShipto <> '' THEN BEGIN
            FromSalesPrice.SETRANGE("Ship-To Code ELA", gcodShipto);
            CopySalesPriceToSalesPrice(FromSalesPrice, ToSalesPrice);
        END;

        FromSalesPrice.SETRANGE("Ship-To Code ELA");

        if CustPriceGrCode <> '' then begin
            FromSalesPrice.SetRange("Sales Type ELA", FromSalesPrice."Sales Type ELA"::"Customer Price Group");
            FromSalesPrice.SetRange("Sales Code", CustPriceGrCode);
            CopySalesPriceToSalesPrice(FromSalesPrice, ToSalesPrice);
            FromSalesPrice.SETRANGE("Ship-To Code ELA");
        end;

        if not ((CustNo = '') and (ContNo = '') and (CampaignNo = '')) then begin
            FromSalesPrice.SetRange(FromSalesPrice."Sales Type ELA", FromSalesPrice."Sales Type ELA"::Campaign);
            if ActivatedCampaignExists(TempTargetCampaignGr, CustNo, ContNo, CampaignNo) then
                repeat
                    FromSalesPrice.SetRange("Sales Code", TempTargetCampaignGr."Campaign No.");
                    CopySalesPriceToSalesPrice(FromSalesPrice, ToSalesPrice);
                until TempTargetCampaignGr.Next = 0;
        end;

        IF gcodPriceListGroup <> '' THEN BEGIN
            FromSalesPrice.SETRANGE("Sales Type ELA", FromSalesPrice."Sales Type ELA"::"Price List Group");
            FromSalesPrice.SETRANGE("Sales Code", gcodPriceListGroup);
            CopySalesPriceToSalesPrice(FromSalesPrice, ToSalesPrice);
            CopySalesPriceToPriceList(FromSalesPrice, grecTempSalesListPrice);
        END;

        RankSalesPriceLines(ToSalesPrice, gCustomer."Price Rule Code ELA");

    end;

    /// <summary>
    /// FindSalesLineDisc.
    /// </summary>
    /// <param name="ToSalesLineDisc">VAR Record "Sales Line Discount".</param>
    /// <param name="CustNo">Code[20].</param>
    /// <param name="ContNo">Code[20].</param>
    /// <param name="CustDiscGrCode">Code[20].</param>
    /// <param name="CampaignNo">Code[20].</param>
    /// <param name="ItemNo">Code[20].</param>
    /// <param name="ItemDiscGrCode">Code[20].</param>
    /// <param name="VariantCode">Code[10].</param>
    /// <param name="UOM">Code[10].</param>
    /// <param name="CurrencyCode">Code[10].</param>
    /// <param name="StartingDate">Date.</param>
    /// <param name="ShowAll">Boolean.</param>
    procedure FindSalesLineDisc(var ToSalesLineDisc: Record "Sales Line Discount"; CustNo: Code[20]; ContNo: Code[20]; CustDiscGrCode: Code[20]; CampaignNo: Code[20]; ItemNo: Code[20]; ItemDiscGrCode: Code[20]; VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date; ShowAll: Boolean)
    var
        FromSalesLineDisc: Record "Sales Line Discount";
        TempCampaignTargetGr: Record "Campaign Target Group" temporary;
        InclCampaigns: Boolean;
    begin
        FromSalesLineDisc.SetFilter("Ending Date", '%1|>=%2', 0D, StartingDate);
        FromSalesLineDisc.SetFilter("Variant Code", '%1|%2', VariantCode, '');

        if not ShowAll then begin
            FromSalesLineDisc.SetRange("Starting Date", 0D, StartingDate);
            FromSalesLineDisc.SetFilter("Currency Code", '%1|%2', CurrencyCode, '');
            if UOM <> '' then
                FromSalesLineDisc.SetFilter("Unit of Measure Code", '%1|%2', UOM, '');
        end;

        ToSalesLineDisc.Reset();
        ToSalesLineDisc.DeleteAll();
        for FromSalesLineDisc."Sales Type" := FromSalesLineDisc."Sales Type"::Customer to FromSalesLineDisc."Sales Type"::Campaign do
            if (FromSalesLineDisc."Sales Type" = FromSalesLineDisc."Sales Type"::"All Customers") or
               ((FromSalesLineDisc."Sales Type" = FromSalesLineDisc."Sales Type"::Customer) and (CustNo <> '')) or
               ((FromSalesLineDisc."Sales Type" = FromSalesLineDisc."Sales Type"::"Customer Disc. Group") and (CustDiscGrCode <> '')) or
               ((FromSalesLineDisc."Sales Type" = FromSalesLineDisc."Sales Type"::Campaign) and
                not ((CustNo = '') and (ContNo = '') and (CampaignNo = '')))
            then begin
                InclCampaigns := false;

                FromSalesLineDisc.SetRange("Sales Type", FromSalesLineDisc."Sales Type");
                case FromSalesLineDisc."Sales Type" of
                    FromSalesLineDisc."Sales Type"::"All Customers":
                        FromSalesLineDisc.SetRange("Sales Code");
                    FromSalesLineDisc."Sales Type"::Customer:
                        FromSalesLineDisc.SetRange("Sales Code", CustNo);
                    FromSalesLineDisc."Sales Type"::"Customer Disc. Group":
                        FromSalesLineDisc.SetRange("Sales Code", CustDiscGrCode);
                    FromSalesLineDisc."Sales Type"::Campaign:
                        begin
                            InclCampaigns := ActivatedCampaignExists(TempCampaignTargetGr, CustNo, ContNo, CampaignNo);
                            FromSalesLineDisc.SetRange("Sales Code", TempCampaignTargetGr."Campaign No.");
                        end;
                end;

                repeat
                    FromSalesLineDisc.SetRange(Type, FromSalesLineDisc.Type::Item);
                    FromSalesLineDisc.SetRange(Code, ItemNo);
                    CopySalesDiscToSalesDisc(FromSalesLineDisc, ToSalesLineDisc);

                    if ItemDiscGrCode <> '' then begin
                        FromSalesLineDisc.SetRange(Type, FromSalesLineDisc.Type::"Item Disc. Group");
                        FromSalesLineDisc.SetRange(Code, ItemDiscGrCode);
                        CopySalesDiscToSalesDisc(FromSalesLineDisc, ToSalesLineDisc);
                    end;

                    if InclCampaigns then begin
                        InclCampaigns := TempCampaignTargetGr.Next <> 0;
                        FromSalesLineDisc.SetRange("Sales Code", TempCampaignTargetGr."Campaign No.");
                    end;
                until not InclCampaigns;
            end;

    end;

    /// <summary>
    /// CopySalesPrice.
    /// </summary>
    /// <param name="SalesPrice">VAR Record "Sales Price".</param>
    procedure CopySalesPrice(var SalesPrice: Record "Sales Price")
    begin
        SalesPrice.DeleteAll();
        CopySalesPriceToSalesPrice(TempSalesPrice, SalesPrice);
    end;

    local procedure CopySalesPriceToSalesPrice(var FromSalesPrice: Record "Sales Price"; var ToSalesPrice: Record "Sales Price")
    begin

        if FromSalesPrice.FindSet then
            repeat
                ToSalesPrice := FromSalesPrice;

                ToSalesPrice."Price Rule ELA" := gblnUseOppositeModel;
                ToSalesPrice."Price Rule Code ELA" := gcodPriceRuleCode;
                ToSalesPrice.Insert;
            until FromSalesPrice.Next = 0;
    end;

    local procedure CopySalesDiscToSalesDisc(var FromSalesLineDisc: Record "Sales Line Discount"; var ToSalesLineDisc: Record "Sales Line Discount")
    begin

        if FromSalesLineDisc.FindSet then
            repeat
                ToSalesLineDisc := FromSalesLineDisc;
                ToSalesLineDisc.Insert;
            until FromSalesLineDisc.Next = 0;
    end;

    /// <summary>
    /// SetItem.
    /// </summary>
    /// <param name="ItemNo">Code[20].</param>
    procedure SetItem(ItemNo: Code[20])
    begin
        Item.Get(ItemNo);
    end;

    /// <summary>
    /// SetResPrice.
    /// </summary>
    /// <param name="Code2">Code[20].</param>
    /// <param name="WorkTypeCode">Code[10].</param>
    /// <param name="CurrencyCode">Code[10].</param>
    procedure SetResPrice(Code2: Code[20]; WorkTypeCode: Code[10]; CurrencyCode: Code[10])
    begin

        ResPrice.Init;
        ResPrice.Code := Code2;
        ResPrice."Work Type Code" := WorkTypeCode;
        ResPrice."Currency Code" := CurrencyCode;

    end;

    /// <summary>
    /// SetCurrency.
    /// </summary>
    /// <param name="CurrencyCode2">Code[10].</param>
    /// <param name="CurrencyFactor2">Decimal.</param>
    /// <param name="ExchRateDate2">Date.</param>
    procedure SetCurrency(CurrencyCode2: Code[10]; CurrencyFactor2: Decimal; ExchRateDate2: Date)
    begin
        PricesInCurrency := CurrencyCode2 <> '';
        if PricesInCurrency then begin
            Currency.Get(CurrencyCode2);
            Currency.TestField("Unit-Amount Rounding Precision");
            CurrencyFactor := CurrencyFactor2;
            ExchRateDate := ExchRateDate2;
        end else
            GLSetup.Get();
    end;

    /// <summary>
    /// SetVAT.
    /// </summary>
    /// <param name="PriceInclVAT2">Boolean.</param>
    /// <param name="VATPerCent2">Decimal.</param>
    /// <param name="VATCalcType2">Option.</param>
    /// <param name="VATBusPostingGr2">Code[20].</param>
    procedure SetVAT(PriceInclVAT2: Boolean; VATPerCent2: Decimal; VATCalcType2: Option; VATBusPostingGr2: Code[20])
    begin
        PricesInclVAT := PriceInclVAT2;
        VATPerCent := VATPerCent2;
        VATCalcType := VATCalcType2;
        VATBusPostingGr := VATBusPostingGr2;
    end;

    /// <summary>
    /// SetUoM.
    /// </summary>
    /// <param name="Qty2">Decimal.</param>
    /// <param name="QtyPerUoM2">Decimal.</param>
    procedure SetUoM(Qty2: Decimal; QtyPerUoM2: Decimal)
    begin
        Qty := Qty2;
        QtyPerUOM := QtyPerUoM2;
    end;

    /// <summary>
    /// SetLineDisc.
    /// </summary>
    /// <param name="LineDiscPerCent2">Decimal.</param>
    /// <param name="AllowLineDisc2">Boolean.</param>
    /// <param name="AllowInvDisc2">Boolean.</param>
    procedure SetLineDisc(LineDiscPerCent2: Decimal; AllowLineDisc2: Boolean; AllowInvDisc2: Boolean)
    begin
        LineDiscPerCent := LineDiscPerCent2;
        AllowLineDisc := AllowLineDisc2;
        AllowInvDisc := AllowInvDisc2;
    end;

    local procedure IsInMinQty(UnitofMeasureCode: Code[10]; MinQty: Decimal): Boolean
    begin
        if UnitofMeasureCode = '' then
            exit(MinQty <= QtyPerUOM * Qty);
        exit(MinQty <= Qty);
    end;

    /// <summary>
    /// ConvertPriceToVAT.
    /// </summary>
    /// <param name="FromPricesInclVAT">Boolean.</param>
    /// <param name="FromVATProdPostingGr">Code[20].</param>
    /// <param name="FromVATBusPostingGr">Code[20].</param>
    /// <param name="UnitPrice">VAR Decimal.</param>
    procedure ConvertPriceToVAT(FromPricesInclVAT: Boolean; FromVATProdPostingGr: Code[20]; FromVATBusPostingGr: Code[20]; var UnitPrice: Decimal)
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if FromPricesInclVAT then begin
            VATPostingSetup.Get(FromVATBusPostingGr, FromVATProdPostingGr);


            case VATPostingSetup."VAT Calculation Type" of
                VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
                    VATPostingSetup."VAT %" := 0;
                VATPostingSetup."VAT Calculation Type"::"Sales Tax":
                    Error(
                      Text010,
                      VATPostingSetup.FieldCaption("VAT Calculation Type"),
                      VATPostingSetup."VAT Calculation Type");
            end;

            case VATCalcType of
                VATCalcType::"Normal VAT",
                VATCalcType::"Full VAT",
                VATCalcType::"Sales Tax":
                    begin
                        if PricesInclVAT then begin
                            if VATBusPostingGr <> FromVATBusPostingGr then
                                UnitPrice := UnitPrice * (100 + VATPerCent) / (100 + VATPostingSetup."VAT %");
                        end else
                            UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
                    end;
                VATCalcType::"Reverse Charge VAT":
                    UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
            end;
        end else
            if PricesInclVAT then
                UnitPrice := UnitPrice * (1 + VATPerCent / 100);
    end;

    local procedure ConvertPriceToUoM(UnitOfMeasureCode: Code[10]; var UnitPrice: Decimal)
    begin
        if UnitOfMeasureCode = '' then
            UnitPrice := UnitPrice * QtyPerUOM;
    end;

    /// <summary>
    /// ConvertPriceLCYToFCY.
    /// </summary>
    /// <param name="CurrencyCode">Code[10].</param>
    /// <param name="UnitPrice">VAR Decimal.</param>
    procedure ConvertPriceLCYToFCY(CurrencyCode: Code[10]; var UnitPrice: Decimal)
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if PricesInCurrency then begin
            if CurrencyCode = '' then
                UnitPrice :=
                  CurrExchRate.ExchangeAmtLCYToFCY(ExchRateDate, Currency.Code, UnitPrice, CurrencyFactor);
            UnitPrice := Round(UnitPrice, Currency."Unit-Amount Rounding Precision");
        end else
            UnitPrice := Round(UnitPrice, GLSetup."Unit-Amount Rounding Precision");
    end;

    local procedure CalcLineAmount(SalesPrice: Record "Sales Price") LineAmount: Decimal
    begin

        if SalesPrice."Allow Line Disc." then
            LineAmount := SalesPrice."Unit Price" * (1 - LineDiscPerCent / 100)
        else
            LineAmount := SalesPrice."Unit Price";

    end;

    /// <summary>
    /// GetSalesLinePrice.
    /// </summary>
    /// <param name="SalesHeader">Record "Sales Header".</param>
    /// <param name="SalesLine">VAR Record "Sales Line".</param>
    procedure GetSalesLinePrice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        IsHandled: Boolean;
        lENSalesSetup: Record "Sales & Receivables Setup";
        lCustomer: Record Customer;

    begin
        IsHandled := false;

        if IsHandled then
            exit;
        lENSalesSetup.GET;

        GetSetupAndPriceRank(SalesHeader."Sell-to Customer No.", SalesHeader."Bill-to Customer No.");

        SalesLinePriceExists(SalesHeader, SalesLine, true);

        IF lENSalesSetup."Sales Pricing Model ELA" = lENSalesSetup."Sales Pricing Model ELA"::"Specific Price" THEN BEGIN
            IF NOT gblnUseOppositeModel THEN BEGIN
                TempSalesPrice.SETCURRENTKEY("Specific Pricing Rank ELA");
                TempSalesPrice.ASCENDING(FALSE);
            END;
        END;


        if PAGE.RunModal(PAGE::"Get Sales Price", TempSalesPrice) = ACTION::LookupOK then begin
            SetVAT(
              SalesHeader."Prices Including VAT", SalesLine."VAT %", SalesLine."VAT Calculation Type", SalesLine."VAT Bus. Posting Group");
            SetUoM(Abs(SalesLine.Quantity), SalesLine."Qty. per Unit of Measure");
            SetCurrency(
              SalesHeader."Currency Code", SalesHeader."Currency Factor", SalesHeaderExchDate(SalesHeader));

            if not IsInMinQty(TempSalesPrice."Unit of Measure Code", TempSalesPrice."Minimum Quantity") then
                Error(
                  Text000,
                  SalesLine.FieldCaption(Quantity),
                  TempSalesPrice.FieldCaption("Minimum Quantity"),
                  TempSalesPrice.TableCaption);
            if not (TempSalesPrice."Currency Code" in [SalesLine."Currency Code", '']) then
                Error(
                  Text001,
                  SalesLine.FieldCaption("Currency Code"),
                  SalesLine.TableCaption,
                  TempSalesPrice.TableCaption);
            if not (TempSalesPrice."Unit of Measure Code" in [SalesLine."Unit of Measure Code", '']) then
                Error(
                  Text001,
                  SalesLine.FieldCaption("Unit of Measure Code"),
                  SalesLine.TableCaption,
                  TempSalesPrice.TableCaption);


            CASE lENSalesSetup."Sales Price/Disc Source ELA" OF
                lENSalesSetup."Sales Price/Disc Source ELA"::"Bill-To Customer":
                    BEGIN
                        IF TempSalesPrice."Starting Date"
                            > SalesHeaderLineStartDate(SalesHeader, DateCaption, SalesLine, SalesHeader."Bill-to Customer No.") THEN
                            ERROR(
                              Text000,
                              DateCaption,
                              TempSalesPrice.FIELDCAPTION("Starting Date"),
                              TempSalesPrice.TABLECAPTION);
                    END;
                lENSalesSetup."Sales Price/Disc Source ELA"::"Sell-To Customer":
                    BEGIN
                        IF TempSalesPrice."Starting Date"
                            > SalesHeaderLineStartDate(SalesHeader, DateCaption, SalesLine, SalesHeader."Sell-to Customer No.") THEN
                            ERROR(
                              Text000,
                              DateCaption,
                              TempSalesPrice.FIELDCAPTION("Starting Date"),
                              TempSalesPrice.TABLECAPTION);
                    END;
            END;
            if TempSalesPrice."Starting Date" > SalesHeaderStartDate(SalesHeader, DateCaption) then
                Error(
                  Text000,
                  DateCaption,
                  TempSalesPrice.FieldCaption("Starting Date"),
                  TempSalesPrice.TableCaption);

            ConvertPriceToVAT(
              TempSalesPrice."Price Includes VAT", Item."VAT Prod. Posting Group",
              TempSalesPrice."VAT Bus. Posting Gr. (Price)", TempSalesPrice."Unit Price");
            ConvertPriceToUoM(TempSalesPrice."Unit of Measure Code", TempSalesPrice."Unit Price");
            ConvertPriceLCYToFCY(TempSalesPrice."Currency Code", TempSalesPrice."Unit Price");

            SalesLine."Allow Invoice Disc." := TempSalesPrice."Allow Invoice Disc.";
            SalesLine."Allow Line Disc." := TempSalesPrice."Allow Line Disc.";
            if not SalesLine."Allow Line Disc." then
                SalesLine."Line Discount %" := 0;

            SalesLine.Validate("Unit Price", TempSalesPrice."Unit Price");
        end;


    end;

    /// <summary>
    /// GetSalesLineLineDisc.
    /// </summary>
    /// <param name="SalesHeader">Record "Sales Header".</param>
    /// <param name="SalesLine">VAR Record "Sales Line".</param>
    procedure GetSalesLineLineDisc(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        IsHandled: Boolean;
        ldecLineDiscountPct: decimal;
        lENSalesSetup: record "Sales & Receivables Setup";
    begin
        IsHandled := false;

        if IsHandled then
            exit;
        lENSalesSetup.GET;
        GetSetupAndPriceRank(SalesHeader."Sell-to Customer No.", SalesHeader."Bill-to Customer No.");
        SalesLineLineDiscExists(SalesHeader, SalesLine, true);


        if PAGE.RunModal(PAGE::"Get Sales Line Disc.", TempSalesLineDisc) = ACTION::LookupOK then begin
            SetCurrency(SalesHeader."Currency Code", 0, 0D);
            SetUoM(Abs(SalesLine.Quantity), SalesLine."Qty. per Unit of Measure");

            if not IsInMinQty(TempSalesLineDisc."Unit of Measure Code", TempSalesLineDisc."Minimum Quantity")
            then
                Error(
                  Text000, SalesLine.FieldCaption(Quantity),
                  TempSalesLineDisc.FieldCaption("Minimum Quantity"),
                  TempSalesLineDisc.TableCaption);
            if not (TempSalesLineDisc."Currency Code" in [SalesLine."Currency Code", '']) then
                Error(
                  Text001,
                  SalesLine.FieldCaption("Currency Code"),
                  SalesLine.TableCaption,
                  TempSalesLineDisc.TableCaption);
            if not (TempSalesLineDisc."Unit of Measure Code" in [SalesLine."Unit of Measure Code", '']) then
                Error(
                  Text001,
                  SalesLine.FieldCaption("Unit of Measure Code"),
                  SalesLine.TableCaption,
                  TempSalesLineDisc.TableCaption);


            CASE lENSalesSetup."Sales Price/Disc Source ELA" OF
                lENSalesSetup."Sales Price/Disc Source ELA"::"Bill-To Customer":
                    BEGIN
                        IF TempSalesLineDisc."Starting Date" > SalesHeaderLineStartDate(SalesHeader, DateCaption,
                                                                      SalesLine, SalesHeader."Bill-to Customer No.") THEN
                            ERROR(
                              Text000,
                              DateCaption,
                              TempSalesLineDisc.FIELDCAPTION("Starting Date"),
                              TempSalesLineDisc.TABLECAPTION);
                    END;
                lENSalesSetup."Sales Price/Disc Source ELA"::"Sell-To Customer":
                    BEGIN
                        IF TempSalesLineDisc."Starting Date" > SalesHeaderLineStartDate(SalesHeader, DateCaption,
                                                                      SalesLine, SalesHeader."Sell-to Customer No.") THEN
                            ERROR(
                              Text000,
                              DateCaption,
                              TempSalesLineDisc.FIELDCAPTION("Starting Date"),
                              TempSalesLineDisc.TABLECAPTION);
                    END;

            end;


            SalesLine.TestField("Allow Line Disc.");

            IF (TempSalesLineDisc."Line Discount Type ELA" = TempSalesLineDisc."Line Discount Type ELA"::Amount) THEN BEGIN
                SetCurrency(
                  SalesHeader."Currency Code", SalesHeader."Currency Factor", SalesHeaderExchDate(SalesHeader));

                ConvertPriceLCYToFCY(TempSalesLineDisc."Currency Code", TempSalesLineDisc."Line Discount %");

                IF SalesLine."Unit Price" = 0 THEN BEGIN
                    ldecLineDiscountPct := 0;
                END ELSE BEGIN
                    // translate Amount type to Percent type
                    ldecLineDiscountPct := 100 * TempSalesLineDisc."Line Discount %" / SalesLine."Unit Price";
                END;

                IF ldecLineDiscountPct < 0 THEN BEGIN
                    ldecLineDiscountPct := 0;
                END ELSE
                    IF ldecLineDiscountPct > 100 THEN BEGIN
                        ldecLineDiscountPct := 100;
                    END;

                TempSalesLineDisc."Line Discount %" := ldecLineDiscountPct;
            END;
            SalesLine.Validate("Line Discount %", TempSalesLineDisc."Line Discount %");
        end;


    end;

    /// <summary>
    /// SalesLinePriceExists.
    /// </summary>
    /// <param name="SalesHeader">VAR Record "Sales Header".</param>
    /// <param name="SalesLine">VAR Record "Sales Line".</param>
    /// <param name="ShowAll">Boolean.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure SalesLinePriceExists(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ShowAll: Boolean): Boolean
    var
        IsHandled: Boolean;
        lENSalesSetup: record "Sales & Receivables Setup";
    begin
        lENSalesSetup.GET;
        gcodShipto := SalesHeader."Ship-to Code";

        gcodCustUOM := '';
        gdecCustUOMQtyPer := 1;

        IF NOT gblnUseRefItemNo THEN BEGIN
            IF (SalesLine.Type = SalesLine.Type::Item) AND (SalesLine."Sales Price UOM ELA" <> '') THEN BEGIN
                gcodCustUOM := SalesLine."Sales Price UOM ELA";
                grecItemUOM.GET(SalesLine."No.", SalesLine."Sales Price UOM ELA");
                gdecCustUOMQtyPer := grecItemUOM."Qty. per Unit of Measure";
                gdecCustUOMQtyPerBaseUOM := grecItemUOM."Qty. per Base UOM ELA";
            END;
        END ELSE BEGIN
            IF (SalesLine."Sales Price UOM ELA" <> '') THEN BEGIN
                gcodCustUOM := SalesLine."Sales Price UOM ELA";
                grecItemUOM.GET(SalesLine."Ref. Item No. ELA", SalesLine."Sales Price UOM ELA");
                gdecCustUOMQtyPer := grecItemUOM."Qty. per Unit of Measure";
                gdecCustUOMQtyPerBaseUOM := grecItemUOM."Qty. per Base UOM ELA";
            END;
        END;

        IF NOT gblnUseRefItemNo THEN BEGIN

            IF (SalesLine.Type = SalesLine.Type::Item) AND Item.GET(SalesLine."No.") THEN BEGIN
                CASE lENSalesSetup."Sales Price/Disc Source ELA" OF
                    lENSalesSetup."Sales Price/Disc Source ELA"::"Bill-To Customer":
                        BEGIN
                            FindSalesPrice(
                              TempSalesPrice, SalesHeader."Bill-to Customer No.", SalesHeader."Bill-to Contact No.",
                              SalesLine."Customer Price Group", '', SalesLine."No.", SalesLine."Variant Code", SalesLine."Unit of Measure Code",
                              SalesHeader."Currency Code",
                              SalesHeaderLineStartDate(SalesHeader, DateCaption, SalesLine, SalesHeader."Bill-to Customer No."), ShowAll);
                        END;
                    lENSalesSetup."Sales Price/Disc Source ELA"::"Sell-To Customer":
                        BEGIN
                            FindSalesPrice(
                              TempSalesPrice, SalesHeader."Sell-to Customer No.", SalesHeader."Sell-to Contact No.",
                              SalesLine."Customer Price Group", '', SalesLine."No.", SalesLine."Variant Code", SalesLine."Unit of Measure Code",
                              SalesHeader."Currency Code",
                              SalesHeaderLineStartDate(SalesHeader, DateCaption, SalesLine, SalesHeader."Sell-to Customer No."), ShowAll);
                        END;
                END;

                EXIT(TempSalesPrice.FINDFIRST);
            END;
        END ELSE BEGIN

            IF Item.GET(SalesLine."Ref. Item No. ELA") THEN BEGIN

                CASE lENSalesSetup."Sales Price/Disc Source ELA" OF
                    lENSalesSetup."Sales Price/Disc Source ELA"::"Bill-To Customer":
                        BEGIN
                            FindSalesPrice(
                              TempSalesPrice, SalesHeader."Bill-to Customer No.", SalesHeader."Bill-to Contact No.",
                              SalesLine."Customer Price Group", '', SalesLine."Ref. Item No. ELA", SalesLine."Variant Code", SalesLine."Unit of Measure Code",
                              SalesHeader."Currency Code",
                              SalesHeaderLineStartDate(SalesHeader, DateCaption, SalesLine, SalesHeader."Bill-to Customer No."), ShowAll);
                        END;
                    lENSalesSetup."Sales Price/Disc Source ELA"::"Sell-To Customer":
                        BEGIN
                            FindSalesPrice(
                              TempSalesPrice, SalesHeader."Sell-to Customer No.", SalesHeader."Sell-to Contact No.",
                              SalesLine."Customer Price Group", '', SalesLine."Ref. Item No. ELA", SalesLine."Variant Code", SalesLine."Unit of Measure Code",
                              SalesHeader."Currency Code",
                              SalesHeaderLineStartDate(SalesHeader, DateCaption, SalesLine, SalesHeader."Sell-to Customer No."), ShowAll);
                        END;
                END;

                EXIT(TempSalesPrice.FINDFIRST);
            END;
        END;

        EXIT(FALSE);

    end;

    /// <summary>
    /// SalesLineLineDiscExists.
    /// </summary>
    /// <param name="SalesHeader">VAR Record "Sales Header".</param>
    /// <param name="SalesLine">VAR Record "Sales Line".</param>
    /// <param name="ShowAll">Boolean.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure SalesLineLineDiscExists(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ShowAll: Boolean): Boolean
    var
        IsHandled: Boolean;
        lENSalesSetup: record "Sales & Receivables Setup";
    begin
        lENSalesSetup.Get;


        IF NOT gblnUseRefItemNo THEN BEGIN
            IF (SalesLine.Type = SalesLine.Type::Item) AND Item.GET(SalesLine."No.") THEN BEGIN
                CASE lENSalesSetup."Sales Price/Disc Source ELA" OF
                    lENSalesSetup."Sales Price/Disc Source ELA"::"Bill-To Customer":
                        BEGIN
                            FindSalesLineDisc(
                              TempSalesLineDisc, SalesLine."Bill-to Customer No.", SalesHeader."Bill-to Contact No.",
                              SalesLine."Customer Disc. Group", '', SalesLine."No.", Item."Item Disc. Group", SalesLine."Variant Code", SalesLine."Unit of Measure Code",
                              SalesHeader."Currency Code",
                              SalesHeaderLineStartDate(SalesHeader, DateCaption, SalesLine, SalesLine."Bill-to Customer No."), ShowAll);
                        END;
                    lENSalesSetup."Sales Price/Disc Source ELA"::"Sell-To Customer":
                        BEGIN
                            FindSalesLineDisc(
                              TempSalesLineDisc, SalesLine."Sell-to Customer No.", SalesHeader."Sell-to Contact No.",
                              SalesLine."Customer Disc. Group", '', SalesLine."No.", Item."Item Disc. Group", SalesLine."Variant Code", SalesLine."Unit of Measure Code",
                              SalesHeader."Currency Code",
                              SalesHeaderLineStartDate(SalesHeader, DateCaption, SalesLine, SalesLine."Sell-to Customer No."), ShowAll);
                        END;
                END;
                EXIT(TempSalesLineDisc.FINDFIRST);
            END;
        END ELSE BEGIN
            IF Item.GET(SalesLine."Ref. Item No. ELA") THEN BEGIN
                CASE lENSalesSetup."Sales Price/Disc Source ELA" OF
                    lENSalesSetup."Sales Price/Disc Source ELA"::"Bill-To Customer":
                        BEGIN
                            FindSalesLineDisc(
                              TempSalesLineDisc, SalesLine."Bill-to Customer No.", SalesHeader."Bill-to Contact No.",
                              SalesLine."Customer Disc. Group", '', SalesLine."Ref. Item No. ELA", Item."Item Disc. Group", SalesLine."Variant Code", SalesLine."Unit of Measure Code",
                              SalesHeader."Currency Code",
                              SalesHeaderLineStartDate(SalesHeader, DateCaption, SalesLine, SalesLine."Bill-to Customer No."), ShowAll);
                        END;
                    lENSalesSetup."Sales Price/Disc Source ELA"::"Sell-To Customer":
                        BEGIN
                            FindSalesLineDisc(
                              TempSalesLineDisc, SalesLine."Sell-to Customer No.", SalesHeader."Sell-to Contact No.",
                              SalesLine."Customer Disc. Group", '', SalesLine."Ref. Item No. ELA", Item."Item Disc. Group", SalesLine."Variant Code", SalesLine."Unit of Measure Code",
                              SalesHeader."Currency Code",
                              SalesHeaderLineStartDate(SalesHeader, DateCaption, SalesLine, SalesLine."Sell-to Customer No."), ShowAll);
                        END;
                END;

                EXIT(TempSalesLineDisc.FINDFIRST);
            END;
        END;


        EXIT(FALSE);
    end;


    local procedure GetCustNoForSalesHeader(SalesHeader: Record "Sales Header"): Code[20]
    var
        CustNo: Code[20];
    begin
        CustNo := SalesHeader."Bill-to Customer No.";

        exit(CustNo);
    end;


    /// <summary>
    /// ActivatedCampaignExists.
    /// </summary>
    /// <param name="ToCampaignTargetGr">VAR Record "Campaign Target Group".</param>
    /// <param name="CustNo">Code[20].</param>
    /// <param name="ContNo">Code[20].</param>
    /// <param name="CampaignNo">Code[20].</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure ActivatedCampaignExists(var ToCampaignTargetGr: Record "Campaign Target Group"; CustNo: Code[20]; ContNo: Code[20]; CampaignNo: Code[20]): Boolean
    var
        FromCampaignTargetGr: Record "Campaign Target Group";
        Cont: Record Contact;
        IsHandled: Boolean;
    begin
        if not ToCampaignTargetGr.IsTemporary then
            Error(TempTableErr);

        IsHandled := false;

        IF IsHandled then
            exit;


        ToCampaignTargetGr.Reset();
        ToCampaignTargetGr.DeleteAll();

        if CampaignNo <> '' then begin
            ToCampaignTargetGr."Campaign No." := CampaignNo;
            ToCampaignTargetGr.Insert();
        end else begin
            FromCampaignTargetGr.SetRange(Type, FromCampaignTargetGr.Type::Customer);
            FromCampaignTargetGr.SetRange("No.", CustNo);
            if FromCampaignTargetGr.FindSet then
                repeat
                    ToCampaignTargetGr := FromCampaignTargetGr;
                    ToCampaignTargetGr.Insert();
                until FromCampaignTargetGr.Next = 0
            else
                if Cont.Get(ContNo) then begin
                    FromCampaignTargetGr.SetRange(Type, FromCampaignTargetGr.Type::Contact);
                    FromCampaignTargetGr.SetRange("No.", Cont."Company No.");
                    if FromCampaignTargetGr.FindSet then
                        repeat
                            ToCampaignTargetGr := FromCampaignTargetGr;
                            ToCampaignTargetGr.Insert();
                        until FromCampaignTargetGr.Next = 0;
                end;
        end;
        exit(ToCampaignTargetGr.FindFirst);

    end;

    local procedure SalesHeaderExchDate(SalesHeader: Record "Sales Header"): Date
    begin

        if SalesHeader."Posting Date" <> 0D then
            exit(SalesHeader."Posting Date");
        exit(WorkDate);

    end;

    local procedure SalesHeaderStartDate(var SalesHeader: Record "Sales Header"; var DateCaption: Text[30]): Date
    begin

        if SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo"] then begin
            DateCaption := SalesHeader.FieldCaption("Posting Date");
            exit(SalesHeader."Posting Date")
        end else begin
            DateCaption := SalesHeader.FieldCaption("Order Date");
            exit(SalesHeader."Order Date");
        end;
    end;

    /// <summary>
    /// NoOfSalesLinePrice.
    /// </summary>
    /// <param name="SalesHeader">VAR Record "Sales Header".</param>
    /// <param name="SalesLine">VAR Record "Sales Line".</param>
    /// <param name="ShowAll">Boolean.</param>
    /// <returns>Return value of type Integer.</returns>
    procedure NoOfSalesLinePrice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ShowAll: Boolean): Integer
    begin
        GetSetupAndPriceRank(SalesHeader."Sell-to Customer No.", SalesHeader."Bill-to Customer No.");
        if SalesLinePriceExists(SalesHeader, SalesLine, ShowAll) then
            exit(TempSalesPrice.Count);
    end;

    /// <summary>
    /// NoOfSalesLineLineDisc.
    /// </summary>
    /// <param name="SalesHeader">VAR Record "Sales Header".</param>
    /// <param name="SalesLine">VAR Record "Sales Line".</param>
    /// <param name="ShowAll">Boolean.</param>
    /// <returns>Return value of type Integer.</returns>
    procedure NoOfSalesLineLineDisc(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ShowAll: Boolean): Integer
    begin
        GetSetupAndPriceRank(SalesHeader."Sell-to Customer No.", SalesHeader."Bill-to Customer No.");
        if SalesLineLineDiscExists(SalesHeader, SalesLine, ShowAll) then
            exit(TempSalesLineDisc.Count);
    end;

    /// <summary>
    /// GetCustomer.
    /// </summary>
    /// <param name="CustomerNo">Code[20].</param>
    procedure GetCustomer(CustomerNo: Code[20])

    begin
        IF gCustomer."No." <> CustomerNo THEN
            IF NOT gCustomer.GET(CustomerNo) THEN
                CLEAR(gCustomer);
    end;

    /// <summary>
    /// GetSetupAndPriceRank.
    /// </summary>
    /// <param name="SellToCustomerNo">Code[20].</param>
    /// <param name="BillToCustomerNo">Code[20].</param>
    procedure GetSetupAndPriceRank(SellToCustomerNo: Code[20]; BillToCustomerNo: Code[20])
    var

        PriceRule: Record "EN Price Rule";
    begin
        ENSalesSetup.GET;
        CLEAR(gPriceRuleSepecificPrice);
        CLEAR(gPriceRuleBestPrice);
        CLEAR(gcodPriceRuleCode);
        CASE ENSalesSetup."Sales Price/Disc Source ELA" OF
            ENSalesSetup."Sales Price/Disc Source ELA"::"Bill-To Customer":
                BEGIN
                    GetCustomer(BillToCustomerNo);
                END;
            ENSalesSetup."Sales Price/Disc Source ELA"::"Sell-To Customer":
                BEGIN
                    GetCustomer(SellToCustomerNo);
                END;
        END;

        //Reset the global variable "Best/Specific" model based on price rule if available
        IF PriceRule.GET(gCustomer."Price Rule Code ELA") THEN BEGIN
            CASE PriceRule."Price Evaluation Rank" OF
                PriceRule."Price Evaluation Rank"::"Sales Price Setup":
                    BEGIN
                        //Do Nothing
                    END;
                PriceRule."Price Evaluation Rank"::"Best Price":
                    BEGIN
                        IF ENSalesSetup."Sales Pricing Model ELA" <> ENSalesSetup."Sales Pricing Model ELA"::"Best Price" THEN BEGIN
                            gblnUseOppositeModel := TRUE;
                            gcodPriceRuleCode := gCustomer."Price Rule Code ELA";

                        END;
                    END;
                PriceRule."Price Evaluation Rank"::"Hierarchy Price":
                    BEGIN
                        IF ENSalesSetup."Sales Pricing Model ELA" <> ENSalesSetup."Sales Pricing Model ELA"::"Specific Price" THEN BEGIN
                            gblnUseOppositeModel := TRUE;
                            gcodPriceRuleCode := gCustomer."Price Rule Code ELA";

                        END;
                    END;
            END;
        END;

        //IF PriceRule.GET(gCustomer."Price Rule Code") THEN BEGIN
        //    CASE PriceRule."Price Evaluation Rank" of
        //        PriceRule."Price Evaluation Rank"::"Hierarchy Price":
        //            begin
        //                gPriceRuleSepecificPrice := TRUE;
        //                gcodPriceRuleCode := gCustomer."Price Rule Code";
        //            end;
        //        PriceRule."Price Evaluation Rank"::"Best Price":
        //            begin
        //                gPriceRuleBestPrice := TRUE;
        //                gcodPriceRuleCode := gCustomer."Price Rule Code";
        //            end;
        //        PriceRule."Price Evaluation Rank"::"Sales Price Setup":
        //            begin
        //                If ENSalesSetup."Sales Price Model" = ENSalesSetup.ENSalesSetup::"Best Price" then
        //                    gPriceRuleBestPrice := TRUE;
        //                If ENSalesSetup."Sales Price Model" = ENSalesSetup."Sales Price Model"::"Specific Price" then
        //                    gPriceRuleSepecificPrice := TRUE;
        //            end;
        //    END
        //END Else begin
        //    If ENSalesSetup."Sales Price Model" = ENSalesSetup."Sales Price Model"::"Best Price" then
        //        gPriceRuleBestPrice := TRUE;
        //    If ENSalesSetup."Sales Price Model" = ENSalesSetup."Sales Price Model"::"Specific Price" then
        //        gPriceRuleSepecificPrice := TRUE;
        //end;
    END;


    /// <summary>
    /// RunSalesPriceCalcCheck.
    /// </summary>
    /// <param name="precSalesHeader">Record "Sales Header".</param>
    /// <param name="precSalesLine">VAR Record "Sales Line".</param>
    procedure RunSalesPriceCalcCheck(precSalesHeader: Record "Sales Header"; var precSalesLine: Record "Sales Line")
    var
        lENSalesSetup: Record "Sales & Receivables Setup";
    begin
        lENSalesSetup.Get; ////
        gblnSalesPriceCalcFound := SalesPriceCalcLineExists(precSalesHeader, precSalesLine, FALSE);

        CASE lENSalesSetup."Sales Price/Disc Source ELA" OF
            lENSalesSetup."Sales Price/Disc Source ELA"::"Bill-To Customer":
                BEGIN
                    GetCust(precSalesHeader."Bill-to Customer No.");
                END;
            lENSalesSetup."Sales Price/Disc Source ELA"::"Sell-To Customer":
                BEGIN
                    GetCust(precSalesHeader."Sell-to Customer No.");
                END;
        END;

        RankSalesPriceCalcLines(grecTmpSalesPriceCalcLine, gCustomer."Price Rule Code ELA");

        CalcBestPriceCalcLine(grecTmpSalesPriceCalcLine);
    end;
    /// <summary>
    /// CalcBestPriceCalcLine.
    /// </summary>
    /// <param name="VAR precSalesPriceGroupLine">Record "EN Price List Line" TEMPORARY.</param>
    procedure CalcBestPriceCalcLine(VAR precSalesPriceGroupLine: Record "EN Sales Price" TEMPORARY)
    var
        lrecBestPriceGroupLine: record "EN Sales Price" temporary;
        ldecCurrentPrice: Decimal;
        ldecHighestPrice: Decimal;
        lintSalesType: Integer;
        lrecTopRankPriceCalcLine: record "EN Sales Price" temporary;
        lrecSalesSetup: Record "Sales & Receivables Setup";
    begin

        lrecSalesSetup.GET;

        /// Base for this function is Standard 5.0 function "CalcBestLineDisc" in CU 7000

        precSalesPriceGroupLine.SETCURRENTKEY("Price Calc. Ranking");
        precSalesPriceGroupLine.ASCENDING(FALSE);
        IF precSalesPriceGroupLine.FINDFIRST THEN BEGIN  //findset not used because of the reverse sort


            lrecBestPriceGroupLine := precSalesPriceGroupLine;
            REPEAT
                ldecCurrentPrice := ExecutePriceCalcCalcultion(precSalesPriceGroupLine, Item);

                IF IsInMinQty(precSalesPriceGroupLine."Unit of Measure Code", precSalesPriceGroupLine."Minimum Quantity") THEN
                    CASE TRUE OF
                        ((lrecBestPriceGroupLine."Variant Code" = '') AND (precSalesPriceGroupLine."Variant Code" <> '')):
                            lrecBestPriceGroupLine := precSalesPriceGroupLine;
                        ((lrecBestPriceGroupLine."Variant Code" = '') OR (precSalesPriceGroupLine."Variant Code" <> '')):
                            BEGIN

                                IF lrecTopRankPriceCalcLine.Code = '' THEN BEGIN
                                    lrecTopRankPriceCalcLine := precSalesPriceGroupLine;
                                END;

                                IF (ldecCurrentPrice < ldecHighestPrice) OR (ldecHighestPrice = 0) THEN BEGIN
                                    lrecBestPriceGroupLine := precSalesPriceGroupLine;
                                    ldecHighestPrice := ldecCurrentPrice;

                                    Evaluate(lintSalesType, Format(precSalesPriceGroupLine."Sales Type", 0, 9));

                                END;
                            END;
                    END;
            UNTIL precSalesPriceGroupLine.NEXT = 0;
        END;

        IF gPriceRuleBestPrice THEN BEGIN
            precSalesPriceGroupLine := lrecBestPriceGroupLine;
        END;
        IF gPriceRuleSepecificPrice THEN begin
            precSalesPriceGroupLine := lrecTopRankPriceCalcLine
        END;


        IF lrecSalesSetup."Sales Pricing Model ELA" = lrecSalesSetup."Sales Pricing Model ELA"::"Specific Price" THEN BEGIN
            IF gblnUseOppositeModel THEN BEGIN
                precSalesPriceGroupLine := lrecBestPriceGroupLine;
            END ELSE BEGIN
                precSalesPriceGroupLine := lrecTopRankPriceCalcLine
            END;
        END ELSE BEGIN
            IF gblnUseOppositeModel THEN BEGIN
                precSalesPriceGroupLine := lrecTopRankPriceCalcLine
            END ELSE BEGIN
                precSalesPriceGroupLine := lrecBestPriceGroupLine;
            END;
        END;

        gdecPriceGroupPrice := precSalesPriceGroupLine."Calculated Price";

        gintSalesType := lintSalesType;

    end;
    /// <summary>
    /// ExecutePriceCalcCalcultion.
    /// </summary>
    /// <param name="VAR precTmpSalesPriceGroupLine">Record "EN Price List Line" TEMPORARY.</param>
    /// <param name="precItem">Record Item.</param>
    /// <returns>Return value of type Decimal.</returns>
    procedure ExecutePriceCalcCalcultion(VAR precTmpSalesPriceGroupLine: Record "EN Sales Price" TEMPORARY; precItem: Record Item): Decimal
    var
        ldecPrice: Decimal;
        lfrfItemMarkupField: FieldRef;
        lrrfItem: RecordRef;
        ldecBaseValue: Decimal;
        lrecSalesSetup: Record "Sales & Receivables Setup";
        lrecItemUOM: Record "Item Unit of Measure";

    begin

        lrecSalesSetup.GET;
        IF precTmpSalesPriceGroupLine.Value <> 0 THEN BEGIN
            lrrfItem.OPEN(DATABASE::Item);
            lrrfItem.GETTABLE(precItem);
            CASE precTmpSalesPriceGroupLine."Calculation Cost Base" OF
                precTmpSalesPriceGroupLine."Calculation Cost Base"::"Unit Cost":
                    lfrfItemMarkupField := lrrfItem.FIELD(Item.FIELDNO("Unit Cost"));
                precTmpSalesPriceGroupLine."Calculation Cost Base"::"Unit Price":
                    lfrfItemMarkupField := lrrfItem.FIELD(Item.FIELDNO("Unit Price"));
                precTmpSalesPriceGroupLine."Calculation Cost Base"::"Sales Price":
                    BEGIN
                        lfrfItemMarkupField := lrrfItem.FIELD(Item.FIELDNO("Unit Price"));
                        lfrfItemMarkupField.VALUE := TempSalesPrice."Unit Price";
                    END;
                precTmpSalesPriceGroupLine."Calculation Cost Base"::"Price List":
                    BEGIN
                        lfrfItemMarkupField := lrrfItem.FIELD(Item.FIELDNO("Unit Price"));
                        lfrfItemMarkupField.VALUE := grecTempSalesListPrice."Unit Price";
                    END;
                precTmpSalesPriceGroupLine."Calculation Cost Base"::"Alternate Cost":
                    BEGIN

                    END;
                precTmpSalesPriceGroupLine."Calculation Cost Base"::"Alt. Cost (Base)":
                    BEGIN

                    END;
                precTmpSalesPriceGroupLine."Calculation Cost Base"::Fixed:
                    BEGIN
                        lfrfItemMarkupField := lrrfItem.FIELD(Item.FIELDNO("Unit Price"));
                        lfrfItemMarkupField.VALUE := precTmpSalesPriceGroupLine.Value;
                    END;
            END;

            CASE precTmpSalesPriceGroupLine."Calculation Cost Base" OF
                precTmpSalesPriceGroupLine."Calculation Cost Base"::"Sales Price",

                precTmpSalesPriceGroupLine."Calculation Cost Base"::Fixed,

                precTmpSalesPriceGroupLine."Calculation Cost Base"::"Price List":
                    ldecBaseValue := lfrfItemMarkupField.VALUE;
                ELSE BEGIN

                        IF lrecItemUOM.GET(precItem."No.", precTmpSalesPriceGroupLine."Unit of Measure Code") THEN BEGIN
                            ldecBaseValue := lfrfItemMarkupField.VALUE;
                            ldecBaseValue *= lrecItemUOM."Qty. per Unit of Measure";
                        END ELSE
                            ldecBaseValue := lfrfItemMarkupField.VALUE;

                    END;
            END;


            IF precTmpSalesPriceGroupLine."Calculation Cost Base" = precTmpSalesPriceGroupLine."Calculation Cost Base"::Fixed
            THEN BEGIN
                ldecPrice := ldecBaseValue;
            END ELSE BEGIN
                CASE precTmpSalesPriceGroupLine."Calculation Type" OF
                    precTmpSalesPriceGroupLine."Calculation Type"::"Markup (%)":
                        ldecPrice := ldecBaseValue * (1 + (precTmpSalesPriceGroupLine.Value / 100));
                    precTmpSalesPriceGroupLine."Calculation Type"::Value:
                        ldecPrice := ldecBaseValue + precTmpSalesPriceGroupLine.Value;
                    precTmpSalesPriceGroupLine."Calculation Type"::"Margin (%)":
                        BEGIN
                            ldecPrice := ldecBaseValue * 100 /
                                        (100 - precTmpSalesPriceGroupLine.Value);
                        END;
                END;
            END;

            //Round the amount
            RoundAmt(ldecPrice, precTmpSalesPriceGroupLine."Rounding Method", precTmpSalesPriceGroupLine."Rounding Precision");


            IF gSalesHeader."No." <> '' THEN BEGIN  //this is to fix problem with price calc. form doing a modify in the wrong trigger
                precTmpSalesPriceGroupLine."Calculated Price" := ldecPrice;
                precTmpSalesPriceGroupLine."Calculation Base Price" := ldecBaseValue;
                precTmpSalesPriceGroupLine.MODIFY;
            END;

        END;

        EXIT(ldecPrice);
    end;
    /// <summary>
    /// RoundAmt.
    /// </summary>
    /// <param name="VAR pdecAmt">Decimal.</param>
    /// <param name="pcodRoundMethod">Code[10].</param>
    /// <param name="pdecRoundPrecision">Decimal.</param>
    procedure RoundAmt(VAR pdecAmt: Decimal; pcodRoundMethod: Code[10]; pdecRoundPrecision: Decimal)
    var
        lrecRoundingMethod: Record "Rounding Method";
        lintSign: Integer;
    begin

        //Round the amount
        IF pcodRoundMethod <> '' THEN BEGIN

            IF pdecAmt >= 0 THEN
                lintSign := 1
            ELSE
                lintSign := -1;

            lrecRoundingMethod.SETRANGE(Code, pcodRoundMethod);
            lrecRoundingMethod.Code := pcodRoundMethod;
            lrecRoundingMethod."Minimum Amount" := ABS(pdecAmt);
            IF lrecRoundingMethod.FIND('=<') THEN BEGIN
                pdecAmt := pdecAmt + lintSign * lrecRoundingMethod."Amount Added Before";
                IF lrecRoundingMethod.Precision > 0 THEN BEGIN
                    pdecAmt := lintSign * ROUND(ABS(pdecAmt), lrecRoundingMethod.Precision, COPYSTR('=><', lrecRoundingMethod.Type + 1, 1));
                END;
                pdecAmt := pdecAmt + lintSign * lrecRoundingMethod."Amount Added After";
            END;

        END ELSE BEGIN
            IF pdecRoundPrecision <> 0 THEN
                pdecAmt := ROUND(pdecAmt, pdecRoundPrecision);
        END;
    end;
    /// <summary>
    /// RankSalesPriceCalcLines.
    /// </summary>
    /// <param name="VAR precSalesPriceCalcTMP">Record "EN Price List Line" TEMPORARY.</param>
    /// <param name="pcodPriceHierarchy">Code[10].</param>
    procedure RankSalesPriceCalcLines(VAR precSalesPriceCalcTMP: Record "EN Sales Price" TEMPORARY; pcodPriceHierarchy: Code[10])
    var
        lrecPricingHierarchy: Record "EN Price Rule";
        lrecCustPriceGr: Record "Customer Price Group";
        lrecCampaign: Record "Campaign";

    begin

        precSalesPriceCalcTMP.RESET;
        IF NOT precSalesPriceCalcTMP.FINDSET THEN
            EXIT;

        IF NOT lrecPricingHierarchy.GET(pcodPriceHierarchy) THEN
            IF NOT lrecPricingHierarchy.GET THEN
                EXIT;

        REPEAT
            CASE precSalesPriceCalcTMP."Sales Type" OF
                precSalesPriceCalcTMP."Sales Type"::Customer:
                    BEGIN
                        precSalesPriceCalcTMP."Price Calc. Ranking" += lrecPricingHierarchy."Customer Rank";
                    END;
                precSalesPriceCalcTMP."Sales Type"::"Customer Buying Group":
                    BEGIN
                        precSalesPriceCalcTMP."Price Calc. Ranking" += lrecPricingHierarchy."Buying Group Rank";
                    END;
                precSalesPriceCalcTMP."Sales Type"::"Customer Price Group":
                    BEGIN
                        IF lrecCustPriceGr.GET(precSalesPriceCalcTMP."Sales Code") THEN BEGIN

                            precSalesPriceCalcTMP."Price Calc. Ranking" += lrecPricingHierarchy."Customer Price Group Rank";

                        END;
                    END;
                precSalesPriceCalcTMP."Sales Type"::"Price List Group":
                    BEGIN
                        precSalesPriceCalcTMP."Price Calc. Ranking" += lrecPricingHierarchy."List Price Group Rank";
                    END;
                precSalesPriceCalcTMP."Sales Type"::Campaign:
                    BEGIN
                        precSalesPriceCalcTMP."Price Calc. Ranking" += lrecPricingHierarchy."Campaign Rank";

                    END;
                precSalesPriceCalcTMP."Sales Type"::"All Customers":
                    BEGIN
                        precSalesPriceCalcTMP."Price Calc. Ranking" += lrecPricingHierarchy."All Customer Rank";
                    END;
            END;

            IF precSalesPriceCalcTMP."Contract Price" THEN
                precSalesPriceCalcTMP."Price Calc. Ranking" += lrecPricingHierarchy."Contract Price Modifier Rank";

            IF precSalesPriceCalcTMP."Variant Code" <> '' THEN
                precSalesPriceCalcTMP."Price Calc. Ranking" += lrecPricingHierarchy."Variant Modifier Rank";

            IF precSalesPriceCalcTMP."Unit of Measure Code" <> '' THEN
                precSalesPriceCalcTMP."Price Calc. Ranking" += lrecPricingHierarchy."Unit of Measure Modifier Rank";

            IF precSalesPriceCalcTMP."Ending Date" <> 0D THEN
                precSalesPriceCalcTMP."Price Calc. Ranking" += lrecPricingHierarchy."End Date Modifier Rank";

            precSalesPriceCalcTMP.MODIFY;
        UNTIL precSalesPriceCalcTMP.NEXT = 0;

    end;
    /// <summary>
    /// SalesPriceCalcLineExists.
    /// </summary>
    /// <param name="precSalesHeader">Record "Sales Header".</param>
    /// <param name="VAR precSalesLine">Record "Sales Line".</param>
    /// <param name="pblnShowAll">Boolean.</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure SalesPriceCalcLineExists(precSalesHeader: Record "Sales Header"; VAR precSalesLine: Record "Sales Line"; pblnShowAll: Boolean): Boolean
    var
        lcodCustNoToUse: Code[20];
        lcodCustContToUse: Code[20];
        lENSalesSetup: Record "Sales & Receivables Setup";
    begin


        lENSalesSetup.GET;
        //// Base for this function is Standard 5.0 function "SalesLineDiscExists" in CU 7000

        CASE lENSalesSetup."Sales Price/Disc Source ELA" OF
            lENSalesSetup."Sales Price/Disc Source ELA"::"Bill-To Customer":
                BEGIN
                    lcodCustNoToUse := precSalesHeader."Bill-to Customer No.";
                    lcodCustContToUse := precSalesHeader."Bill-to Contact No.";
                END;
            lENSalesSetup."Sales Price/Disc Source ELA"::"Sell-To Customer":
                BEGIN
                    lcodCustNoToUse := precSalesHeader."Sell-to Customer No.";
                    lcodCustContToUse := precSalesHeader."Sell-to Contact No.";
                END;
        END;

        //<JF00135MG>
        gcodCustUOM := '';
        gdecCustUOMQtyPer := 1;

        IF NOT gblnUseRefItemNo THEN BEGIN
            IF (precSalesLine.Type = precSalesLine.Type::Item) AND (precSalesLine."Sales Price UOM ELA" <> '') THEN BEGIN
                gcodCustUOM := precSalesLine."Sales Price UOM ELA";
                grecItemUOM.GET(precSalesLine."No.", precSalesLine."Sales Price UOM ELA");
                gdecCustUOMQtyPer := grecItemUOM."Qty. per Unit of Measure";
                gdecCustUOMQtyPerBaseUOM := grecItemUOM."Qty. per Base UOM ELA";
            END;
        END ELSE BEGIN
            IF (precSalesLine."Sales Price UOM ELA" <> '') THEN BEGIN
                gcodCustUOM := precSalesLine."Sales Price UOM ELA";
                grecItemUOM.GET(precSalesLine."Ref. Item No. ELA", precSalesLine."Sales Price UOM ELA");
                gdecCustUOMQtyPer := grecItemUOM."Qty. per Unit of Measure";
                gdecCustUOMQtyPerBaseUOM := grecItemUOM."Qty. per Base UOM ELA";
            END;
        END;
        //<JF00135MG>


        IF gblnUseRefItemNo THEN BEGIN
            IF precSalesLine."Ref. Item No. ELA" <> '' THEN BEGIN
                IF Item.GET(precSalesLine."Ref. Item No. ELA") THEN BEGIN
                    //<JF00116SHR>
                    FindSalesPriceCalcLine(
                    grecTmpSalesPriceCalcLine, lcodCustNoToUse, lcodCustContToUse,
                    precSalesHeader."Customer Price Group", precSalesHeader."Campaign No.", precSalesLine."Ref. Item No. ELA",
                    Item."Item Price Group Code ELA", precSalesLine."Variant Code", precSalesLine."Unit of Measure Code",
                    precSalesHeader."Currency Code",
                    SalesHeaderLineStartDate(precSalesHeader, DateCaption, precSalesLine, lcodCustNoToUse), pblnShowAll);

                    //</JF00116SHR>
                    EXIT(grecTmpSalesPriceCalcLine.FINDFIRST);
                END;
            END;
        END ELSE BEGIN
            IF (precSalesLine.Type = precSalesLine.Type::Item) AND Item.GET(precSalesLine."No.") THEN BEGIN
                CLEAR(gcodLocation);
                gcodLocation := precSalesLine."Location Code";
                FindSalesPriceCalcLine(
                    grecTmpSalesPriceCalcLine, lcodCustNoToUse, lcodCustContToUse,
                    precSalesHeader."Customer Price Group", precSalesHeader."Campaign No.", precSalesLine."No.",
                    Item."Item Price Group Code ELA", precSalesLine."Variant Code", precSalesLine."Unit of Measure Code",
                    precSalesHeader."Currency Code",
                    SalesHeaderLineStartDate(precSalesHeader, DateCaption, precSalesLine, lcodCustNoToUse), pblnShowAll);

                //</JF00116SHR>
                EXIT(grecTmpSalesPriceCalcLine.FINDFIRST);
            END;
        END;
        EXIT(FALSE);

    end;
    /// <summary>
    /// FindSalesPriceCalcLine.
    /// </summary>
    /// <param name="VAR precToSalesPriceGroupLine">TEMPORARY Record "EN Price List Line".</param>
    /// <param name="CustNo">Code[20].</param>
    /// <param name="ContNo">Code[20].</param>
    /// <param name="precCustPriceGrCode">Code[10].</param>
    /// <param name="CampaignNo">Code[20].</param>
    /// <param name="ItemNo">Code[20].</param>
    /// <param name="precItemPriceGrCode">Code[10].</param>
    /// <param name="VariantCode">Code[10].</param>
    /// <param name="UOM">Code[10].</param>
    /// <param name="CurrencyCode">Code[10].</param>
    /// <param name="StartingDate">Date.</param>
    /// <param name="ShowAll">Boolean.</param>
    procedure FindSalesPriceCalcLine(VAR precToSalesPriceGroupLine: Record "EN Sales Price" temporary; CustNo: Code[20]; ContNo: Code[20]; precCustPriceGrCode: Code[10]; CampaignNo: Code[20]; ItemNo: Code[20]; precItemPriceGrCode: Code[10];
    VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date; ShowAll: Boolean)
    var
        lrecFromSalesPriceGroupLine: Record "EN Sales Price";
        lrecTempCampaignTargetGr: Record "Campaign Target Group" temporary;
        lrecPriceRule: Record "EN Price Rule";
        lblnInclCampaigns: Boolean;

    //lrecPriceRuleDetail:Record	"Price Rule Addnl. Details";	
    begin
        //// Base for this function is Standard 5.0 function "FindSalesLineDisc" in CU 7000

        lrecFromSalesPriceGroupLine.SETFILTER("Ending Date", '%1|>=%2', 0D, StartingDate);
        lrecFromSalesPriceGroupLine.SETFILTER("Variant Code", '%1|%2', VariantCode, '');
        lrecFromSalesPriceGroupLine.SETFILTER("Ship-From Location", '%1|%2', gcodLocation, '');
        IF NOT ShowAll THEN BEGIN
            lrecFromSalesPriceGroupLine.SETRANGE("Starting Date", 0D, StartingDate);
            //SETFILTER("Currency Code",'%1|%2',CurrencyCode,'');
            IF UOM <> '' THEN
                lrecFromSalesPriceGroupLine.SETFILTER("Unit of Measure Code", '%1|%2', UOM, '');


            IF gcodCustUOM <> '' THEN
                lrecFromSalesPriceGroupLine.SETFILTER("Unit of Measure Code", '%1|%2', gcodCustUOM, '');

        END;

        precToSalesPriceGroupLine.RESET;
        precToSalesPriceGroupLine.DELETEALL;

        FOR lrecFromSalesPriceGroupLine."Sales Type" := lrecFromSalesPriceGroupLine."Sales Type"::Customer TO lrecFromSalesPriceGroupLine."Sales Type"::"Price List Group" DO
            IF (lrecFromSalesPriceGroupLine."Sales Type" = lrecFromSalesPriceGroupLine."Sales Type"::"All Customers") OR
            ((lrecFromSalesPriceGroupLine."Sales Type" = lrecFromSalesPriceGroupLine."Sales Type"::Customer) AND (CustNo <> '')) OR
            ((lrecFromSalesPriceGroupLine."Sales Type" = lrecFromSalesPriceGroupLine."Sales Type"::"Customer Price Group") AND (precCustPriceGrCode <> '')) OR
            ((lrecFromSalesPriceGroupLine."Sales Type" = lrecFromSalesPriceGroupLine."Sales Type"::Campaign) AND
                NOT ((CustNo = '') AND (ContNo = '') AND (CampaignNo = ''))) OR
            ((lrecFromSalesPriceGroupLine."Sales Type" = lrecFromSalesPriceGroupLine."Sales Type"::"Customer Buying Group") AND (gcodCustBuyingGrp <> '')) OR
            ((lrecFromSalesPriceGroupLine."Sales Type" = lrecFromSalesPriceGroupLine."Sales Type"::"Price List Group") AND (gcodPriceListGroup <> ''))
            THEN BEGIN

                lblnInclCampaigns := FALSE;

                lrecFromSalesPriceGroupLine.SETRANGE("Sales Type", lrecFromSalesPriceGroupLine."Sales Type");
                CASE lrecFromSalesPriceGroupLine."Sales Type" OF
                    lrecFromSalesPriceGroupLine."Sales Type"::"All Customers":
                        lrecFromSalesPriceGroupLine.SETRANGE("Sales Code");
                    lrecFromSalesPriceGroupLine."Sales Type"::Customer:
                        lrecFromSalesPriceGroupLine.SETRANGE("Sales Code", CustNo);
                    lrecFromSalesPriceGroupLine."Sales Type"::"Customer Price Group":
                        lrecFromSalesPriceGroupLine.SETRANGE("Sales Code", precCustPriceGrCode);
                    lrecFromSalesPriceGroupLine."Sales Type"::Campaign:
                        BEGIN
                            lblnInclCampaigns := ActivatedCampaignExists(lrecTempCampaignTargetGr, CustNo, ContNo, CampaignNo);
                            lrecFromSalesPriceGroupLine.SETRANGE("Sales Code", lrecTempCampaignTargetGr."Campaign No.");
                        END;
                    lrecFromSalesPriceGroupLine."Sales Type"::"Customer Buying Group":
                        lrecFromSalesPriceGroupLine.SETRANGE("Sales Code", gcodCustBuyingGrp);
                    lrecFromSalesPriceGroupLine."Sales Type"::"Price List Group":
                        lrecFromSalesPriceGroupLine.SETRANGE("Sales Code", gcodPriceListGroup);
                END;

                REPEAT
                    lrecFromSalesPriceGroupLine.SETRANGE(Type, lrecFromSalesPriceGroupLine.Type::Item);
                    lrecFromSalesPriceGroupLine.SETRANGE(Code, ItemNo);
                    CopySPCalcToSPCalc(lrecFromSalesPriceGroupLine, precToSalesPriceGroupLine);

                    IF precItemPriceGrCode <> '' THEN BEGIN
                        lrecFromSalesPriceGroupLine.SETRANGE(Type, lrecFromSalesPriceGroupLine.Type::"Item Price Group");
                        lrecFromSalesPriceGroupLine.SETRANGE(Code, precItemPriceGrCode);
                        CopySPCalcToSPCalc(lrecFromSalesPriceGroupLine, precToSalesPriceGroupLine);
                    END;

                    IF lblnInclCampaigns THEN BEGIN
                        lblnInclCampaigns := lrecTempCampaignTargetGr.NEXT <> 0;
                        lrecFromSalesPriceGroupLine.SETRANGE("Sales Code", lrecTempCampaignTargetGr."Campaign No.");
                    END;
                UNTIL NOT lblnInclCampaigns;

            END;

        GetCust(CustNo);
        /*
        IF lrecPriceRule.GET(grecCust."Price Rule Code") THEN BEGIN
            lrecPriceRuleDetail.SETRANGE("Price Rule Code", lrecPriceRule.Code);
            IF lrecPriceRuleDetail.FINDSET THEN
                REPEAT
                    SETRANGE("Sales Type", "Sales Type"::"Customer Price Group");
                    SETRANGE("Sales Code", lrecPriceRuleDetail."Cust. Price Group Code");
                    SETRANGE(Type, Type::Item);
                    SETRANGE(Code, ItemNo);
                    jfCopySPCalcToSPCalc(lrecFromSalesPriceGroupLine, precToSalesPriceGroupLine);

                    IF precItemPriceGrCode <> '' THEN BEGIN
                        SETRANGE(Type, Type::"Item Price Group");
                        SETRANGE(Code, precItemPriceGrCode);
                        jfCopySPCalcToSPCalc(lrecFromSalesPriceGroupLine, precToSalesPriceGroupLine);
                    END;

                UNTIL lrecPriceRuleDetail.NEXT = 0;
        
        END;
        */
    end;
    /// <summary>
    /// SalesHeaderLineStartDate.
    /// </summary>
    /// <param name="SalesHeader">Record "Sales Header".</param>
    /// <param name="VAR DateCaption">Text[30].</param>
    /// <param name="precSalesLine">Record "Sales Line".</param>
    /// <param name="pcodCustomerNo">Code[20].</param>
    /// <returns>Return value of type Date.</returns>
    procedure SalesHeaderLineStartDate(SalesHeader: Record "Sales Header"; VAR DateCaption: Text[30]; precSalesLine: Record "Sales Line"; pcodCustomerNo: Code[20]): Date
    begin


        IF SalesHeader."Document Type" IN [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo"] THEN BEGIN
            DateCaption := SalesHeader.FIELDCAPTION(SalesHeader."Posting Date");
            EXIT(SalesHeader."Posting Date")
        END ELSE BEGIN

            IF pcodCustomerNo <> '' THEN BEGIN

                GetCust(pcodCustomerNo);

                CASE gCustomer."Sales Price/Sur Date Cntrl ELA" OF
                    gCustomer."Sales Price/Sur Date Cntrl ELA"::"Order Date":
                        BEGIN
                            DateCaption := SalesHeader.FIELDCAPTION("Order Date");
                            EXIT(SalesHeader."Order Date");
                        END;
                    gCustomer."Sales Price/Sur Date Cntrl ELA"::"Shipment Date":
                        BEGIN
                            DateCaption := precSalesLine.FIELDCAPTION(precSalesLine."Shipment Date");
                            EXIT(precSalesLine."Shipment Date");
                        END;
                    gCustomer."Sales Price/Sur Date Cntrl ELA"::"Req. Delivery Date":
                        BEGIN
                            IF precSalesLine."Requested Delivery Date" <> 0D THEN BEGIN
                                DateCaption := precSalesLine.FIELDCAPTION(precSalesLine."Requested Delivery Date");
                                EXIT(precSalesLine."Requested Delivery Date");
                            END ELSE BEGIN
                                DateCaption := precSalesLine.FIELDCAPTION(precSalesLine."Planned Delivery Date");
                                EXIT(precSalesLine."Planned Delivery Date");
                            END;
                        END;
                END;
            END ELSE BEGIN
                DateCaption := SalesHeader.FIELDCAPTION("Order Date");
                EXIT(SalesHeader."Order Date");
            END;
        end;
    end;
    /// <summary>
    /// CopySPCalcToSPCalc.
    /// </summary>
    /// <param name="VAR precFromSalesPriceGroupLine">Record "EN Price List Line".</param>
    /// <param name="VAR precToSalesPriceGroupLineTMP">TEMPORARY Record "EN Price List Line".</param>
    procedure CopySPCalcToSPCalc(VAR precFromSalesPriceGroupLine: Record "EN Sales Price"; VAR precToSalesPriceGroupLineTMP: Record "EN Sales Price" temporary)
    var
        lblnInclude: Boolean;
    begin


        IF precFromSalesPriceGroupLine.FINDSET THEN
            REPEAT

                //Don't insert those records that are not in the starting order date, ending order date range
                //additional clause...
                lblnInclude := TRUE;
                IF precFromSalesPriceGroupLine."Starting Order Date" <> 0D THEN
                    IF gSalesHeader."Order Date" < precFromSalesPriceGroupLine."Starting Order Date" THEN
                        lblnInclude := FALSE;
                IF precFromSalesPriceGroupLine."Ending Order Date" <> 0D THEN
                    IF gSalesHeader."Order Date" > precFromSalesPriceGroupLine."Ending Order Date" THEN
                        lblnInclude := FALSE;

                IF precFromSalesPriceGroupLine.Value <> 0 THEN BEGIN
                    precToSalesPriceGroupLineTMP := precFromSalesPriceGroupLine;
                    precToSalesPriceGroupLineTMP."Price Rule" := gblnUseOppositeModel;
                    precToSalesPriceGroupLineTMP."Price Rule Code" := gcodPriceRuleCode;

                    IF lblnInclude THEN
                        IF precToSalesPriceGroupLineTMP.INSERT THEN;

                END;
            UNTIL precFromSalesPriceGroupLine.NEXT = 0;

    end;
    /// <summary>
    /// GetCust.
    /// </summary>
    /// <param name="pcodCustNo">Code[20].</param>
    procedure GetCust(pcodCustNo: Code[20])
    begin
        IF gCustomer."No." <> pcodCustNo then
            IF not gCustomer.GET(pcodCustNo) then
                clear(gCustomer);
    end;

    LOCAL procedure CalcSpecificUnitPrice(VAR SalesPrice: Record "Sales Price"; precSalesHeader: Record "Sales Header"; precSalesLine: Record "Sales Line")
    var
        BestSalesPrice: Record "Sales Price";
        lblnFoundSpecific: Boolean;
        lEnumSalesType: Enum "EN Sales Type";
    begin
        FoundSalesPrice := SalesPrice.FINDSET;

        IF FoundSalesPrice THEN BEGIN

            //-- Look for Ship-To pricing first
            SalesPrice.SETRANGE("Sales Type ELA", SalesPrice."Sales Type ELA"::Customer);
            SalesPrice.SETRANGE("Sales Code", gcodCustNo);
            SalesPrice.SETRANGE("Ship-To Code ELA", gcodShipto);
            lblnFoundSpecific := lFindSpecificUnitPrice(SalesPrice, BestSalesPrice,
                                                   '', FALSE);

            //-- otherwise look for Customer pricing
            IF NOT lblnFoundSpecific THEN BEGIN
                SalesPrice.SETRANGE(SalesPrice."Ship-To Code ELA");
                lblnFoundSpecific := lFindSpecificUnitPrice(SalesPrice, BestSalesPrice,
                                                               '', FALSE);
            END;

            //-- otherwise look for Customer Buying Group
            IF NOT lblnFoundSpecific THEN BEGIN
                SalesPrice.SETRANGE("Sales Type ELA", SalesPrice."Sales Type ELA"::"Customer Buying Group");
                SalesPrice.SETRANGE("Sales Code", gcodCustBuyingGrp);
                lblnFoundSpecific := lFindSpecificUnitPrice(SalesPrice, BestSalesPrice,
                                                               gcodCustBuyingGrp, TRUE);
            END;

            //-- otherwise look for Customer Price Group
            IF NOT lblnFoundSpecific THEN BEGIN
                SalesPrice.SETRANGE("Sales Type ELA", SalesPrice."Sales Type ELA"::"Customer Price Group");
                SalesPrice.SETRANGE("Sales Code", gcodPriceGrp);
                lblnFoundSpecific := lFindSpecificUnitPrice(SalesPrice, BestSalesPrice,
                                                               gcodPriceGrp, TRUE);
            END;


            //-- otherwise look for Price List Group
            IF NOT lblnFoundSpecific THEN BEGIN
                SalesPrice.SETRANGE("Sales Type ELA", SalesPrice."Sales Type ELA"::"Price List Group");
                SalesPrice.SETRANGE("Sales Code", gcodPriceListGroup);
                lblnFoundSpecific := lFindSpecificUnitPrice(SalesPrice, BestSalesPrice,
                                                               gcodPriceListGroup, TRUE);
            END;


            //-- otherwise look for Campaign Pricing
            IF NOT lblnFoundSpecific THEN BEGIN
                IF gcodCampaign <> '' THEN BEGIN
                    SalesPrice.SETRANGE("Sales Type ELA", SalesPrice."Sales Type ELA"::Campaign);
                    SalesPrice.SETRANGE("Sales Code", gcodCampaign);
                    lblnFoundSpecific := lFindSpecificUnitPrice(SalesPrice, BestSalesPrice,
                                                                   '', FALSE);
                END;
            END;

            //-- otherwise look for pricing applying to All Customers
            IF NOT lblnFoundSpecific THEN BEGIN
                SalesPrice.SETRANGE("Sales Type ELA", SalesPrice."Sales Type ELA"::"All Customers");
                SalesPrice.SETRANGE("Sales Code");
                lblnFoundSpecific := lFindSpecificUnitPrice(SalesPrice, BestSalesPrice,
                                                               '', FALSE);
            END;

        END; // IF FoundSalesPrice THEN BEGIN

        IF gdecPriceGroupPrice <> 0 THEN BEGIN
            BestSalesPrice."Unit Price" := gdecPriceGroupPrice;
            evaluate(BestSalesPrice."Sales Type ELA", format(gintSalesType));

        END;
        IF (gcodCustUOM <> '') AND (gdecCustUOMQtyPer <> 0) AND (gdecCustUOMQtyPerBaseUOM <> 0) THEN BEGIN
            IF gdecCustUOMQtyPer < 1 THEN BEGIN
                BestSalesPrice."Unit Price" :=
                  ROUND(BestSalesPrice."Unit Price" * QtyPerUOM * gdecCustUOMQtyPerBaseUOM, Currency."Unit-Amount Rounding Precision");
                BestSalesPrice."Delivered Unit Price ELA" :=
                  ROUND(BestSalesPrice."Delivered Unit Price ELA" * QtyPerUOM *
                     gdecCustUOMQtyPerBaseUOM, Currency."Unit-Amount Rounding Precision");
            END ELSE BEGIN
                BestSalesPrice."Unit Price" :=
                  ROUND(BestSalesPrice."Unit Price" * QtyPerUOM / gdecCustUOMQtyPer, Currency."Unit-Amount Rounding Precision");
                BestSalesPrice."Delivered Unit Price ELA" :=
                  ROUND(BestSalesPrice."Delivered Unit Price ELA" * QtyPerUOM / gdecCustUOMQtyPer, Currency."Unit-Amount Rounding Precision");
            END;
        END;

        // No price found in agreement
        IF BestSalesPrice."Unit Price" = 0 THEN BEGIN
            ConvertPriceToVAT(
              Item."Price Includes VAT", Item."VAT Prod. Posting Group",
              Item."VAT Bus. Posting Gr. (Price)", Item."Unit Price");
            ConvertPriceToUoM('', Item."Unit Price");
            ConvertPriceLCYToFCY('', Item."Unit Price");

            CLEAR(BestSalesPrice);
            BestSalesPrice."Unit Price" := Item."Unit Price";
            BestSalesPrice."Allow Line Disc." := AllowLineDisc;
            BestSalesPrice."Allow Invoice Disc." := AllowInvDisc;
        END;

        SalesPrice := BestSalesPrice;

    end;

    LOCAL Procedure lFindSpecificUnitPrice(VAR SalesPrice: Record "Sales Price"; VAR BestSalesPrice: Record "Sales Price"; pcodTypeCode: Code[20]; pblnRequireTypeCode: Boolean) pblnResult: Boolean
    begin

        IF pblnRequireTypeCode AND (pcodTypeCode = '') THEN BEGIN
            EXIT(FALSE);
        END;


        IF NOT SalesPrice.FINDSET THEN BEGIN
            EXIT(FALSE);
        END ELSE BEGIN
            REPEAT
                IF IsInMinQty(SalesPrice."Unit of Measure Code", SalesPrice."Minimum Quantity") THEN BEGIN
                    ConvertPriceToVAT(
                    SalesPrice."Price Includes VAT", Item."VAT Prod. Posting Group",
                    SalesPrice."VAT Bus. Posting Gr. (Price)", SalesPrice."Unit Price");
                    ConvertPriceToUoM(SalesPrice."Unit of Measure Code", SalesPrice."Unit Price");
                    ConvertPriceLCYToFCY(SalesPrice."Currency Code", SalesPrice."Unit Price");

                    ConvertPriceToVAT(
                    SalesPrice."Price Includes VAT", Item."VAT Prod. Posting Group",
                    SalesPrice."VAT Bus. Posting Gr. (Price)", SalesPrice."Delivered Unit Price ELA");
                    ConvertPriceToUoM(SalesPrice."Unit of Measure Code", SalesPrice."Delivered Unit Price ELA");

                    //<JF3590MG>

                    //-- If the unit price is the same use the entry as we want to use the most applicable in this scenario
                    CASE TRUE OF
                        ((BestSalesPrice."Currency Code" = '') AND (SalesPrice."Currency Code" <> '')) OR
                    ((BestSalesPrice."Variant Code" = '') AND (SalesPrice."Variant Code" <> '')):
                            BestSalesPrice := SalesPrice;
                        ((BestSalesPrice."Currency Code" = '') OR (SalesPrice."Currency Code" <> '')) AND
                    ((BestSalesPrice."Variant Code" = '') OR (SalesPrice."Variant Code" <> '')):
                            IF (BestSalesPrice."Unit Price" = 0) OR
                            (CalcLineAmount(BestSalesPrice) >= CalcLineAmount(SalesPrice)) OR //-- use >= not >
                            (SalesPrice."Starting Date" >= BestSalesPrice."Starting Date")
                            THEN
                                BestSalesPrice := SalesPrice;
                    END;

                END;
            UNTIL SalesPrice.NEXT = 0;
        END;


        EXIT(TRUE);
    end;

    LOCAL procedure CalcBestLineDiscAmt(VAR SalesLineDisc: Record "Sales Line Discount")
    var
        BestSalesLineDisc: Record "Sales Line Discount";
    begin


        SalesLineDisc.SETRANGE(SalesLineDisc."Line Discount Type ELA", SalesLineDisc."Line Discount Type ELA"::Amount);
        IF SalesLineDisc.FINDSET THEN
            REPEAT
                IF IsInMinQty(SalesLineDisc."Unit of Measure Code", SalesLineDisc."Minimum Quantity") THEN
                    CASE TRUE OF
                        ((BestSalesLineDisc."Currency Code" = '') AND (SalesLineDisc."Currency Code" <> '')) OR
                      ((BestSalesLineDisc."Variant Code" = '') AND (SalesLineDisc."Variant Code" <> '')):
                            BestSalesLineDisc := SalesLineDisc;
                        ((BestSalesLineDisc."Currency Code" = '') OR (SalesLineDisc."Currency Code" <> '')) AND
                        ((BestSalesLineDisc."Variant Code" = '') OR (SalesLineDisc."Variant Code" <> '')):
                            BEGIN
                                ConvertPriceLCYToFCY(SalesLineDisc."Currency Code", SalesLineDisc."Line Discount %");
                                IF BestSalesLineDisc."Line Discount %" <= SalesLineDisc."Line Discount %" THEN
                                    BestSalesLineDisc := SalesLineDisc;
                            END;
                    END;
            UNTIL SalesLineDisc.NEXT = 0;


        SalesLineDisc := BestSalesLineDisc;
    end;

    LOCAL procedure CopySalesPriceToPriceList(VAR FromSalesPrice: Record "Sales Price"; VAR ToSalesPrice: Record "Sales Price")
    begin

        ToSalesPrice.DELETEALL;

        IF FromSalesPrice.FINDSET THEN
            REPEAT
                IF FromSalesPrice."Unit Price" <> 0 THEN BEGIN
                    ToSalesPrice := FromSalesPrice;
                    ToSalesPrice."Price Rule ELA" := gblnUseOppositeModel;
                    ToSalesPrice."Price Rule Code ELA" := gcodPriceRuleCode;
                    ToSalesPrice.INSERT;
                END;
            UNTIL FromSalesPrice.NEXT = 0;

    end;

    Procedure RankSalesPriceLines(VAR pSalesPrice: Record "Sales Price" TEMPORARY; pcodPriceHierarchyCode: Code[10])
    var
        lPricingHierarchy: Record "EN Price Rule";
    begin

        pSalesPrice.RESET;
        IF NOT pSalesPrice.FINDSET THEN
            EXIT;


        //Do pricing hiearchy by customer, if not one found use the "blank" hierarcy
        IF NOT lPricingHierarchy.GET(pcodPriceHierarchyCode) THEN
            IF NOT lPricingHierarchy.GET THEN
                EXIT;

        REPEAT
            CASE pSalesPrice."Sales Type ELA" OF
                pSalesPrice."Sales Type ELA"::Customer:
                    BEGIN
                        pSalesPrice."Specific Pricing Rank ELA" += lPricingHierarchy."Customer Rank";
                        IF pSalesPrice."Ship-To Code ELA" <> '' THEN
                            pSalesPrice."Specific Pricing Rank ELA" += lPricingHierarchy."Ship-to Modifier Rank";
                    END;
                pSalesPrice."Sales Type ELA"::"Customer Buying Group":
                    BEGIN
                        pSalesPrice."Specific Pricing Rank ELA" += lPricingHierarchy."Buying Group Rank";
                    END;
                pSalesPrice."Sales Type ELA"::"Customer Price Group":
                    BEGIN
                        pSalesPrice."Specific Pricing Rank ELA" += lPricingHierarchy."Customer Price Group Rank";
                    END;
                pSalesPrice."Sales Type ELA"::"Price List Group":
                    BEGIN
                        pSalesPrice."Specific Pricing Rank ELA" += lPricingHierarchy."List Price Group Rank";
                    END;
                pSalesPrice."Sales Type ELA"::Campaign:
                    BEGIN
                        pSalesPrice."Specific Pricing Rank ELA" += lPricingHierarchy."Campaign Rank";
                    END;
                pSalesPrice."Sales Type ELA"::"All Customers":
                    BEGIN
                        pSalesPrice."Specific Pricing Rank ELA" += lPricingHierarchy."All Customer Rank";
                    END;
            END;
            IF pSalesPrice."Variant Code" <> '' THEN
                pSalesPrice."Specific Pricing Rank ELA" += lPricingHierarchy."Variant Modifier Rank";

            IF pSalesPrice."Unit of Measure Code" <> '' THEN
                pSalesPrice."Specific Pricing Rank ELA" += lPricingHierarchy."Unit of Measure Modifier Rank";

            pSalesPrice.MODIFY;
        UNTIL pSalesPrice.NEXT = 0;
    end;

    procedure FindSalesLineLineDiscAmt(SalesHeader: Record "Sales Header"; VAR SalesLine: Record "Sales Line")
    begin

        gblnDiscAmtMode := TRUE;

        FindSalesLineLineDisc(SalesHeader, SalesLine);

        gblnDiscAmtMode := FALSE;
    end;

    Procedure GetDeliveryCharge(VAR precSalesPrice: Record "Sales Price")
    begin

        precSalesPrice := TempSalesPrice;
        precSalesPrice."Delivered Unit Price ELA" := ((grecTmpSalesPriceCalcLine.Value + grecTmpSalesPriceCalcLine."Del. Unit Cost Value") * QtyPerUOM);
    end;

    Procedure ReturnItemPriceCalcLines(precSalesLine: Record "Sales Line")
    var
        lfrmShowSalesPriceCalc: Page "Show Sales Price Calculation";
    begin

        grecTmpSalesPriceCalcLine.RESET;
        IF grecTmpSalesPriceCalcLine.FINDSET THEN BEGIN
            lfrmShowSalesPriceCalc.SetRecords(grecTmpSalesPriceCalcLine, precSalesLine);
            lfrmShowSalesPriceCalc.LOOKUPMODE := TRUE;
            IF lfrmShowSalesPriceCalc.RUNMODAL = ACTION::LookupOK THEN BEGIN
                lfrmShowSalesPriceCalc.GETRECORD(grecTmpSalesPriceCalcLine);
                IF grecTmpSalesPriceCalcLine.GUID <> precSalesLine."Price Calc. GUID ELA" THEN BEGIN
                    precSalesLine.VALIDATE("Unit Price", grecTmpSalesPriceCalcLine."Calculated Price");
                    precSalesLine."Price Calc. GUID ELA" := grecTmpSalesPriceCalcLine.GUID;
                    precSalesLine.MODIFY;
                END;
            END;


        end;
    end;

    /// <summary>
    /// CalcSalesPriceUOMPrice.
    /// </summary>
    /// <param name="pSalesLine">Record "Sales Line".</param>
    /// <returns>Return value of type Decimal.</returns>
    procedure CalcSalesPriceUOMPrice(pSalesLine: Record "Sales Line"): Decimal
    var
        ldecResult: Decimal;
        lItemUOM: Record "Item Unit of Measure";
        lCurrency: Record Currency;
    begin

        ldecResult := 0;


        IF (pSalesLine.Type <> pSalesLine.Type::Item) OR (pSalesLine."No." = '') OR (pSalesLine."Qty. per Unit of Measure" = 0) THEN
            EXIT(ldecResult);

        IF NOT lCurrency.GET(pSalesLine."Currency Code") THEN
            lCurrency.InitRoundingPrecision;

        IF (pSalesLine."Sales Price UOM ELA" <> '') AND (pSalesLine.Type = pSalesLine.Type::Item) THEN BEGIN
            lItemUOM.GET(pSalesLine."No.", pSalesLine."Sales Price UOM ELA");

            IF lItemUOM."Qty. per Unit of Measure" < 1 THEN BEGIN
                lItemUOM.TESTFIELD("Qty. per Base UOM ELA");
                ldecResult := ROUND(pSalesLine."Unit Price" / pSalesLine."Qty. per Unit of Measure" / lItemUOM."Qty. per Base UOM ELA",
                                    lCurrency."Unit-Amount Rounding Precision");
            END ELSE BEGIN
                ldecResult := ROUND(pSalesLine."Unit Price" / pSalesLine."Qty. per Unit of Measure" * lItemUOM."Qty. per Unit of Measure",
                                    lCurrency."Unit-Amount Rounding Precision");
            END;
        END;
        EXIT(ldecResult);
    END;

    Procedure GetDeliveryChargeWithUOM(VAR precSalesPrice: Record "Sales Price"; SalesPriceUOM: Text)
    begin

        precSalesPrice := TempSalesPrice;

        IF (grecTmpSalesPriceCalcLine."Del. Unit Cost Calc. Type" = grecTmpSalesPriceCalcLine."Del. Unit Cost Calc. Type"::Percent) THEN BEGIN
            precSalesPrice."Delivered Unit Price ELA" := grecTmpSalesPriceCalcLine.isCalcDelUnitCost;
            EXIT;
        END;

        precSalesPrice."Delivered Unit Price ELA" := ((grecTmpSalesPriceCalcLine.Value + grecTmpSalesPriceCalcLine."Del. Unit Cost Value") * QtyPerUOM);
    end;

    procedure GetDeliveryChargeWithUOM2(VAR precSalesPrice: Record "Sales Price"; UOM: Text)
    begin

        precSalesPrice := TempSalesPrice;
        IF (grecTmpSalesPriceCalcLine."Del. Unit Cost Calc. Type" = grecTmpSalesPriceCalcLine."Del. Unit Cost Calc. Type"::Percent) THEN BEGIN
            IF ((QtyPerUOM <> 1) AND (gcodCustUOM = '')) THEN BEGIN
                precSalesPrice."Delivered Unit Price ELA" := grecTmpSalesPriceCalcLine.isCalcDelUnitCost;
                EXIT;
            END;

            IF ((QtyPerUOM <> 1) AND (gcodCustUOM <> UOM)) THEN BEGIN
                precSalesPrice."Delivered Unit Price ELA" := ROUND(precSalesPrice."Unit Price" + ((grecTmpSalesPriceCalcLine.Value * QtyPerUOM * gdecCustUOMQtyPerBaseUOM) * (grecTmpSalesPriceCalcLine."Del. Unit Cost Value" / 100)),
                Currency."Unit-Amount Rounding Precision");
                EXIT;
            END;

            IF (gcodCustUOM = UOM) AND (QtyPerUOM = 1) THEN BEGIN
                precSalesPrice."Delivered Unit Price ELA" := ROUND((grecTmpSalesPriceCalcLine.Value * QtyPerUOM) + ((grecTmpSalesPriceCalcLine.Value * QtyPerUOM) * (grecTmpSalesPriceCalcLine."Del. Unit Cost Value" / 100)),
                Currency."Unit-Amount Rounding Precision");
                EXIT;
            END;

            IF (gcodCustUOM = UOM) OR (QtyPerUOM <> 1) THEN BEGIN
                precSalesPrice."Delivered Unit Price ELA" := ROUND(grecTmpSalesPriceCalcLine.Value * (QtyPerUOM * gdecCustUOMQtyPerBaseUOM) +
                ((grecTmpSalesPriceCalcLine.Value * (QtyPerUOM * gdecCustUOMQtyPerBaseUOM)) * (grecTmpSalesPriceCalcLine."Del. Unit Cost Value" / 100)), Currency."Unit-Amount Rounding Precision");  //</IB10456BS>
                                                                                                                                                                                                      //</IS24399RH>
                EXIT;
            END;
            IF gdecCustUOMQtyPerBaseUOM = 0 THEN BEGIN
                IF (gcodCustUOM <> UOM) AND (QtyPerUOM = 1) THEN BEGIN
                    precSalesPrice."Delivered Unit Price ELA" := ROUND((precSalesPrice."Unit Price" * QtyPerUOM) + ((grecTmpSalesPriceCalcLine.Value * QtyPerUOM) * (grecTmpSalesPriceCalcLine."Del. Unit Cost Value" / 100)),
                    Currency."Unit-Amount Rounding Precision");
                    EXIT;
                END;
            END ELSE BEGIN
                IF (gcodCustUOM <> UOM) AND (QtyPerUOM = 1) THEN BEGIN
                    precSalesPrice."Delivered Unit Price ELA" := ROUND((precSalesPrice."Unit Price" * QtyPerUOM) + ((grecTmpSalesPriceCalcLine.Value * QtyPerUOM) * (grecTmpSalesPriceCalcLine."Del. Unit Cost Value" / 100)) * gdecCustUOMQtyPerBaseUOM,
                    Currency."Unit-Amount Rounding Precision");
                    EXIT;
                END;
            END;
        END;

        //Begin when Calc Type is value
        IF ((QtyPerUOM <> 1) AND (gcodCustUOM = '')) THEN BEGIN
            precSalesPrice."Delivered Unit Price ELA" := ROUND(grecTmpSalesPriceCalcLine.isCalcDelUnitCost, Currency."Unit-Amount Rounding Precision");  //</IB10456BS>
            EXIT;
        END;


        IF ((QtyPerUOM <> 1) AND (gcodCustUOM <> UOM)) THEN BEGIN
            precSalesPrice."Delivered Unit Price ELA" := ROUND((precSalesPrice."Unit Price" + (grecTmpSalesPriceCalcLine."Del. Unit Cost Value" * (QtyPerUOM * gdecCustUOMQtyPerBaseUOM))), Currency."Unit-Amount Rounding Precision");  //</IB10456BS>
            EXIT;
        END;

        IF (gcodCustUOM = UOM) AND (QtyPerUOM = 1) THEN BEGIN
            precSalesPrice."Delivered Unit Price ELA" := ROUND(((grecTmpSalesPriceCalcLine.Value + grecTmpSalesPriceCalcLine."Del. Unit Cost Value") * QtyPerUOM), Currency."Unit-Amount Rounding Precision"); //</IB10456BS>
            EXIT;
        END;

        IF (gcodCustUOM = UOM) OR (QtyPerUOM <> 1) THEN BEGIN
            //<IS24399RH>
            precSalesPrice."Delivered Unit Price ELA" := ROUND(((grecTmpSalesPriceCalcLine.Value + grecTmpSalesPriceCalcLine."Del. Unit Cost Value") * (QtyPerUOM * gdecCustUOMQtyPerBaseUOM)), Currency."Unit-Amount Rounding Precision"); //</IB10456BS>
                                                                                                                                                                                                                                            //</IS24399RH>
            EXIT;
        END;

        IF gdecCustUOMQtyPerBaseUOM = 0 THEN BEGIN
            IF (gcodCustUOM <> UOM) AND (QtyPerUOM = 1) THEN BEGIN
                precSalesPrice."Delivered Unit Price ELA" := ROUND(((grecTmpSalesPriceCalcLine.Value + grecTmpSalesPriceCalcLine."Del. Unit Cost Value") * QtyPerUOM), Currency."Unit-Amount Rounding Precision"); //</IB10456BS>
                EXIT;
            END;
        END ELSE BEGIN
            IF (gcodCustUOM <> UOM) AND (QtyPerUOM = 1) THEN BEGIN
                precSalesPrice."Delivered Unit Price ELA" := ROUND(((grecTmpSalesPriceCalcLine.Value + grecTmpSalesPriceCalcLine."Del. Unit Cost Value") * QtyPerUOM) * gdecCustUOMQtyPerBaseUOM, Currency."Unit-Amount Rounding Precision");  //</IB10456BS>
                EXIT;
            END;
        END;
    end;

}
