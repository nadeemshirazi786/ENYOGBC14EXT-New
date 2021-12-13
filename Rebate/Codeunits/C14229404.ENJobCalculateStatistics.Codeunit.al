codeunit 14229404 "Job Calculate Statistics ELA"
{
    // ENRE1.00 2021-09-08 AJ
    trigger OnRun()
    begin

    end;

    var
        JobLedgEntry: Record "Job Ledger Entry";
        JobLedgEntry2: Record "Job Ledger Entry";
        JobPlanningLine: Record "Job Planning Line";
        JobPlanningLine2: Record "Job Planning Line";
        AmountType: Option TotalCostLCY,LineAmountLCY,TotalCost,LineAmount;
        PlanLineType: Option Schedule,Contract;
        JobLedgAmounts: array[10, 4, 4] of Decimal;
        JobPlanAmounts: array[10, 4, 4] of Decimal;
        Text000: Label 'Budget Price,Usage Price,Billable Price,Inv. Price,Budget Cost,Usage Cost,Billable Cost,Inv. Cost,Budget Profit,Usage Profit,Billable Profit,Inv. Profit';
        grecJob: Record Job;
        grecRebateLedgerEntry: Record "Rebate Ledger Entry ELA";
        grecJobTask: Record "Job Task";
        gdecPromotionQty: Decimal;
        gPUOM: Code[20];
        gdecPromotionUnitPrice: Decimal;
        gdecPromotionUnitPriceLCY: Decimal;
        gdecPPlannedRebateCost: Decimal;
        gdecPActualRebateCost: Decimal;
        gdecPRebateCostVar: Decimal;
        gdecPRebateVarPercent: Decimal;
        gdecPPlannedRebateCostLCY: Decimal;
        gdecPActualRebateCostLCY: Decimal;
        gdecPRebateCostVarLCY: Decimal;
        gdecPRebateVarPercentLCY: Decimal;
        gdecPPlannedOtherCost: Decimal;
        gdecPActualOtherCost: Decimal;
        gdecPOtherCostVar: Decimal;
        gdecPOtherVarPercent: Decimal;
        gdecPPlannedOtherCostLCY: Decimal;
        gdecPActualOtherCostLCY: Decimal;
        gdecPOtherCostVarLCY: Decimal;
        gdecPOtherVarPercentLCY: Decimal;
        gdecPPlannedTotalCost: Decimal;
        gdecPActualTotalCost: Decimal;
        gdecPTotalCostVar: Decimal;
        gdecPTotalVarPercent: Decimal;
        gdecPPlannedTotalCostLCY: Decimal;
        gdecPActualTotalCostLCY: Decimal;
        gdecPTotalCostVarLCY: Decimal;
        gdecPTotalVarPercentLCY: Decimal;
        gdecPPlannedSalesAmount: Decimal;
        gdecPActualSalesAmount: Decimal;
        gdecPSalesVar: Decimal;
        gdecPSalesVarPercent: Decimal;
        gdecPPlannedSalesAmountLCY: Decimal;
        gdecPActualSalesAmountLCY: Decimal;
        gdecPSalesVarLCY: Decimal;
        gdecPSalesVarPercentLCY: Decimal;
        gdecPPlannedSalesRev: Decimal;
        gdecPActualSalesRev: Decimal;
        gdecPSalesRevVar: Decimal;
        gdecPSalesRevVarPercent: Decimal;
        gdecPPlannedSalesRevLCY: Decimal;
        gdecPActualSalesRevLCY: Decimal;
        gdecPSalesRevVarLCY: Decimal;
        gdecPSalesRevVarPercentLCY: Decimal;
        gdecPPlannedSpendRate: Decimal;
        gdecPActualSpendRate: Decimal;
        gdecPSpendRateVar: Decimal;
        gdecPSpendRateVarPercent: Decimal;
        gdecPPlannedSpendRateLCY: Decimal;
        gdecPActualSpendRateLCY: Decimal;
        gdecPSpendRateVarLCY: Decimal;
        gdecPSpendRateVarPercentLCY: Decimal;
        gdecPPlannedSalesRevPercent: Decimal;
        gdecPActualSalesRevPercent: Decimal;
        gdecPSalesRevPercentVar: Decimal;
        gdecPSalesRevPercentVarPercent: Decimal;
        gdecPPlannedSalesRevPercentLCY: Decimal;
        gdecPActualSalesRevPercentLCY: Decimal;
        gdecPSalesRevPercentVarLCY: Decimal;
        gdecPSalesRevPercentVarPerLCY: Decimal;
        gdecActualPromotionQty: Decimal;

    procedure JobCalcCommonPromoFilters(VAR Job: Record Job)
    begin


        //<<ENRE1.00
        CLEARALL;
        grecJob.SETRANGE("No.", Job."No.");
        grecRebateLedgerEntry.SETCURRENTKEY("Job No.");
        grecRebateLedgerEntry.SETRANGE("Job No.", Job."No.");

        grecJobTask.SETCURRENTKEY("Job No.");
        grecJobTask.SETRANGE("Job No.", Job."No.");
        grecJobTask.SETRANGE("Job Task Type", grecJobTask."Job Task Type"::Posting);
    end;

    procedure CalcJobPromotionStatistics()
    var
        lrecSalesInvHdr: Record "Sales Invoice Header";
        lrecSalesInvLine: Record "Sales Invoice Line";
        lrecItemUOM: Record "Item Unit of Measure";
        ldecQty: Decimal;
        ldecAmount: Decimal;
        lrecGLSetup: Record "General Ledger Setup";
        lrecCurrExchangeRate: Record "Currency Exchange Rate";
    begin


        IF grecJob.FINDFIRST THEN BEGIN
            gdecPromotionQty := grecJob."Promotion Quantity ELA";
            gdecPromotionUnitPrice := grecJob."Promotion Unit Price ELA";
            gdecPromotionUnitPriceLCY := GetAmountInLCY(gdecPromotionUnitPrice);
            gPUOM := grecJob."Promo Unit of Measure Code ELA";
            gdecPPlannedSalesAmount := grecJob."Sched. (Promotion Revenue) ELA";

            grecRebateLedgerEntry.SETRANGE("Source Type", grecRebateLedgerEntry."Source Type"::"Posted Invoice");

            IF NOT grecRebateLedgerEntry.ISEMPTY THEN
                IF grecRebateLedgerEntry.FINDSET THEN
                    REPEAT
                        grecRebateLedgerEntry.SETRANGE("Source No.", grecRebateLedgerEntry."Source No.");
                        grecRebateLedgerEntry.SETRANGE("Source Line No.", grecRebateLedgerEntry."Source Line No.");

                        IF grecRebateLedgerEntry.FINDLAST THEN BEGIN
                            lrecSalesInvLine.RESET;
                            lrecSalesInvLine.SETRANGE("Document No.", grecRebateLedgerEntry."Source No.");
                            lrecSalesInvLine.SETRANGE("Line No.", grecRebateLedgerEntry."Source Line No.");
                            IF lrecSalesInvLine.FINDFIRST THEN BEGIN
                                ldecQty := lrecSalesInvLine.Quantity;
                                IF gPUOM <> lrecSalesInvLine."Unit of Measure" THEN BEGIN
                                    IF lrecSalesInvLine.Type = lrecSalesInvLine.Type::Item THEN BEGIN
                                        lrecItemUOM.RESET;
                                        lrecItemUOM.SETRANGE("Item No.", lrecSalesInvLine."No.");
                                        IF lrecItemUOM.FINDFIRST AND (lrecItemUOM."Qty. per Unit of Measure" <> 0) THEN BEGIN
                                            ldecQty := lrecSalesInvLine."Quantity (Base)" / lrecItemUOM."Qty. per Unit of Measure";
                                        END;
                                    END;
                                END;
                                gdecActualPromotionQty += ldecQty;
                                gdecPActualSalesAmount += lrecSalesInvLine."Line Amount";
                                ldecAmount := lrecSalesInvLine."Line Amount";
                                lrecSalesInvHdr.GET(lrecSalesInvLine."Document No.");
                                IF lrecSalesInvHdr."Currency Code" <> '' THEN BEGIN
                                    lrecGLSetup.GET;
                                    ldecAmount := (lrecCurrExchangeRate.ExchangeAmtFCYToLCY(
                                                    lrecSalesInvHdr."Posting Date",
                                                    lrecSalesInvHdr."Currency Code",
                                                    ldecAmount,
                                                    lrecCurrExchangeRate.ExchangeRate(lrecSalesInvHdr."Posting Date", lrecSalesInvHdr."Currency Code")));
                                END;
                                gdecPActualSalesAmountLCY += ldecAmount;
                            END;
                        END;
                        grecRebateLedgerEntry.SETRANGE("Source No.");
                        grecRebateLedgerEntry.SETRANGE("Source Line No.");
                    UNTIL grecRebateLedgerEntry.NEXT = 0;
        END;

        //Rebate Costs
        grecJobTask.SETRANGE("Rebate Type ELA");
        grecJobTask.SETFILTER("Rebate Type ELA", '<>%1', grecJobTask."Rebate Type ELA"::" ");
        IF grecJobTask.FINDSET THEN
            REPEAT
                grecJobTask.CALCFIELDS("Schedule (Promotion Cost) ELA", "Usage (Total Cost)");
                gdecPPlannedRebateCost += grecJobTask."Schedule (Promotion Cost) ELA";
                gdecPActualRebateCost += grecJobTask."Usage (Total Cost)";
            UNTIL grecJobTask.NEXT = 0;
        gdecPRebateCostVar := gdecPPlannedRebateCost - gdecPActualRebateCost;
        IF gdecPPlannedRebateCost <> 0 THEN
            gdecPRebateVarPercent := (gdecPRebateCostVar / gdecPPlannedRebateCost) * 100;

        gdecPPlannedRebateCostLCY := GetAmountInLCY(gdecPPlannedRebateCost);
        gdecPActualRebateCostLCY := GetAmountInLCY(gdecPActualRebateCost);
        gdecPRebateCostVarLCY := gdecPPlannedRebateCostLCY - gdecPActualRebateCostLCY;
        IF gdecPPlannedRebateCostLCY <> 0 THEN
            gdecPRebateVarPercentLCY := (gdecPRebateCostVarLCY / gdecPPlannedRebateCostLCY) * 100;

        //Other Costs
        grecJobTask.SETRANGE("Rebate Type ELA");
        grecJobTask.SETFILTER("Rebate Type ELA", '%1', grecJobTask."Rebate Type ELA"::" ");
        IF grecJobTask.FINDSET THEN
            REPEAT
                grecJobTask.CALCFIELDS("Schedule (Promotion Cost) ELA", "Usage (Total Cost)");
                gdecPPlannedOtherCost += grecJobTask."Schedule (Promotion Cost) ELA";
                gdecPActualOtherCost += grecJobTask."Usage (Total Cost)";
            UNTIL grecJobTask.NEXT = 0;
        gdecPOtherCostVar := gdecPPlannedOtherCost - gdecPActualOtherCost;
        IF gdecPPlannedOtherCost <> 0 THEN
            gdecPOtherVarPercent := (gdecPOtherCostVar / gdecPPlannedOtherCost) * 100;

        gdecPPlannedOtherCostLCY := GetAmountInLCY(gdecPPlannedOtherCost);
        gdecPActualOtherCostLCY := GetAmountInLCY(gdecPActualOtherCost);
        gdecPOtherCostVarLCY := gdecPPlannedOtherCostLCY - gdecPActualOtherCostLCY;
        IF gdecPPlannedOtherCostLCY <> 0 THEN
            gdecPOtherVarPercentLCY := (gdecPOtherCostVarLCY / gdecPPlannedOtherCostLCY) * 100;

        //Total Cost
        gdecPPlannedTotalCost := gdecPPlannedRebateCost + gdecPPlannedOtherCost;
        gdecPActualTotalCost := gdecPActualRebateCost + gdecPActualOtherCost;
        gdecPTotalCostVar := gdecPPlannedTotalCost - gdecPActualTotalCost;
        IF gdecPPlannedTotalCost <> 0 THEN
            gdecPTotalVarPercent := (gdecPTotalCostVar / gdecPPlannedTotalCost) * 100;

        gdecPPlannedTotalCostLCY := GetAmountInLCY(gdecPPlannedTotalCost);
        gdecPActualTotalCostLCY := GetAmountInLCY(gdecPActualTotalCost);
        gdecPTotalCostVarLCY := gdecPPlannedTotalCostLCY - gdecPActualTotalCostLCY;
        IF gdecPPlannedTotalCostLCY <> 0 THEN
            gdecPTotalVarPercentLCY := (gdecPTotalCostVarLCY / gdecPPlannedTotalCostLCY) * 100;

        //Sales Amount
        gdecPSalesVar := gdecPPlannedSalesAmount - gdecPActualSalesAmount;
        IF gdecPPlannedSalesAmount <> 0 THEN
            gdecPSalesVarPercent := (gdecPSalesVar / gdecPPlannedSalesAmount) * 100;

        gdecPPlannedSalesAmountLCY := GetAmountInLCY(gdecPPlannedSalesAmount);
        gdecPSalesVarLCY := gdecPPlannedSalesAmountLCY - gdecPActualSalesAmountLCY;
        IF gdecPPlannedSalesAmountLCY <> 0 THEN
            gdecPSalesVarPercentLCY := (gdecPSalesVarLCY / gdecPPlannedSalesAmountLCY) * 100;

        //Sales Revenue
        gdecPPlannedSalesRev := gdecPPlannedSalesAmount - gdecPPlannedTotalCost;
        gdecPActualSalesRev := gdecPActualSalesAmount - gdecPActualTotalCost;
        gdecPSalesRevVar := gdecPPlannedSalesRev - gdecPActualSalesRev;
        IF gdecPPlannedSalesRev <> 0 THEN
            gdecPSalesRevVarPercent := (gdecPSalesRevVar / gdecPPlannedSalesRev) * 100;

        gdecPPlannedSalesRevLCY := GetAmountInLCY(gdecPPlannedSalesRev);
        gdecPActualSalesRevLCY := GetAmountInLCY(gdecPActualSalesRev);
        gdecPSalesRevVarLCY := gdecPPlannedSalesRevLCY - gdecPActualSalesRevLCY;
        IF gdecPPlannedSalesRevLCY <> 0 THEN
            gdecPSalesRevVarPercentLCY := (gdecPSalesRevVarLCY / gdecPPlannedSalesRevLCY) * 100;

        //Spend Rate
        IF gdecPromotionQty <> 0 THEN
            gdecPPlannedSpendRate := (gdecPPlannedTotalCost / gdecPromotionQty);
        IF gdecActualPromotionQty <> 0 THEN
            gdecPActualSpendRate := (gdecPActualTotalCost / gdecActualPromotionQty);
        gdecPSpendRateVar := gdecPPlannedSpendRate - gdecPActualSpendRate;
        IF gdecPPlannedSpendRate <> 0 THEN
            gdecPSpendRateVarPercent := (gdecPSpendRateVar / gdecPPlannedSpendRate) * 100;

        gdecPPlannedSpendRateLCY := GetAmountInLCY(gdecPPlannedSpendRate);
        gdecPActualSpendRateLCY := GetAmountInLCY(gdecPActualSpendRate);
        gdecPSpendRateVarLCY := gdecPPlannedSpendRate - gdecPActualSpendRate;
        IF gdecPPlannedSpendRateLCY <> 0 THEN
            gdecPSpendRateVarPercentLCY := (gdecPSpendRateVarLCY / gdecPPlannedSpendRateLCY) * 100;

        // % Sales Revenue
        IF gdecPPlannedSalesAmount <> 0 THEN
            gdecPPlannedSalesRevPercent := (gdecPPlannedTotalCost / gdecPPlannedSalesAmount);

        IF gdecPActualSalesAmount <> 0 THEN
            gdecPActualSalesRevPercent := (gdecPActualTotalCost / gdecPActualSalesAmount);

        gdecPSalesRevPercentVar := gdecPPlannedSalesRevPercent - gdecPActualSalesRevPercent;

        gdecPPlannedSalesRevPercentLCY := GetAmountInLCY(gdecPPlannedSalesRevPercent);
        gdecPActualSalesRevPercentLCY := GetAmountInLCY(gdecPActualSalesRevPercent);
        gdecPSalesRevPercentVarLCY := gdecPPlannedSalesRevPercentLCY - gdecPActualSalesRevPercentLCY;
        IF gdecPPlannedSalesRevPercentLCY <> 0 THEN
            gdecPSalesRevPercentVarPercent := (gdecPSalesRevPercentVarLCY / gdecPPlannedSalesRevPercentLCY) * 100;
    end;

    procedure JTCalculateCommonPromoFilter(VAR JT2: Record "Job Task"; VAR Job2: Record Job; UseJobFilter: Boolean)
    var
        JT: Record "Job Task";
    begin


        CLEARALL;
        JT := JT2;
        grecJob.SETRANGE("No.", JT."Job No.");
        grecRebateLedgerEntry.SETCURRENTKEY("Job No.");
        grecRebateLedgerEntry.SETRANGE("Job No.", JT."Job No.");
        grecRebateLedgerEntry.SETRANGE("Job Task No.", JT."Job Task No.");

        grecJobTask.SETCURRENTKEY("Job No.");
        grecJobTask.SETRANGE("Job No.", JT."Job No.");
        grecJobTask.SETRANGE("Job Task No.", JT."Job Task No.");
        grecJobTask.SETRANGE("Job Task Type", grecJobTask."Job Task Type"::Posting);

        IF NOT UseJobFilter THEN BEGIN
            grecRebateLedgerEntry.SETFILTER("Posting Date", JT2.GETFILTER("Posting Date Filter"));
        END ELSE BEGIN
            grecRebateLedgerEntry.SETFILTER("Posting Date", Job2.GETFILTER("Posting Date Filter"));
        END;
    end;

    procedure GetAmountInLCY(pdecAmount: Decimal): Decimal
    var
        lblnJobCurrencyIsFCY: Boolean;
        lrecGLSetUp: Record "General Ledger Setup";
        lrecCurrExchangeRate: Record "Currency Exchange Rate";
    begin


        lrecGLSetUp.GET;
        IF (grecJob."Currency Code" <> lrecGLSetUp."LCY Code") AND (grecJob."Currency Code" <> '') THEN BEGIN
            EXIT(lrecCurrExchangeRate.ExchangeAmtFCYToLCY(
                  WORKDATE,
                  grecJob."Currency Code",
                  pdecAmount,
                  lrecCurrExchangeRate.ExchangeRate(WORKDATE, grecJob."Currency Code")))
        END;
        EXIT(pdecAmount);
    end;
    //>>ENRE1.00

    var
        myInt: Integer;
}