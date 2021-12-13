report 14229400 "Calc/Reg Purchase Rebates ELA"
{

    // ENRE1.00 2021-08-26 AJ
    //    - New Report
    // 
    // 
    //    - New DataItem
    //              - Guranteed Cost Rebates
    //            - Modified Function
    //              - SetParameters
    //            - New Functions
    //              - UpdatePostedSalesInvoices
    //              - UpdatePostedSalesCrMemos
    //              - UpdateSalesOrders
    //              - UpdateSalesReturnOrders
    //              - UpdateSalesCrMemos
    //              - UpdateSalesInvoices
    // 
    // 
    // 
    //     - rename CalcGuranteedCostDealRebate to CalcSalesBasedPurchRebate
    //     - replace "Rebate Type"::"Guaranteed Cost Deal" with ::"Sales-Based" option
    //     - create adjustment entries for Posted Sales Profit Modifier entries

    ApplicationArea = All;
    Caption = 'Calculate/Register Purchase Rebates';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Purchase Rebate Header"; "Purchase Rebate Header ELA")
        {
            DataItemTableView = SORTING(Code);
            RequestFilterFields = "Code", "Rebate Category Code", "Rebate Type";

            trigger OnPreDataItem()
            var
                lrecPurchRebate: Record "Purchase Rebate Header ELA";
            begin
                lrecPurchRebate.CopyFilters("Purchase Rebate Header");

                //-- Check for lump sum rebates
                lrecPurchRebate.SetRange("Rebate Type", "Rebate Type"::"Lump Sum");
                gblnProcessLumpSum := not lrecPurchRebate.IsEmpty;

                //-- Check for sales-based rebates
                lrecPurchRebate.SetRange("Rebate Type", "Rebate Type"::"Sales-Based");
                gblnProcessSalesBasedRebate := not lrecPurchRebate.IsEmpty;

                //-- build a list of the rebates that are eligible for adjustment
                lrecPurchRebate.SetFilter("Rebate Type", '%1|%2', lrecPurchRebate."Rebate Type"::"Off-Invoice",
                                          lrecPurchRebate."Rebate Type"::Everyday);

                if not lrecPurchRebate.IsEmpty then begin
                    gblnOtherRebates := true;

                    lrecPurchRebate.FindSet;

                    repeat
                        grecTEMPEligibleRebates.TransferFields(lrecPurchRebate);
                        grecTEMPEligibleRebates.Insert;
                    until lrecPurchRebate.Next = 0;
                end else begin
                    gblnOtherRebates := false;
                end;

                CurrReport.Break;
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

            trigger OnAfterGetRecord()
            var
                lrecPurchSetup: Record "Purchases & Payables Setup";
                lrecCustomer: Record Customer;
                ltxtDateFilter: Text[250];
                ldteStartDate: Date;
                lrecRebatesInReportFilter: Record "Purchase Rebate Header ELA";
                ltext000: Label 'Processing...\';
                ltext001: Label 'Posted Purchase Invoices        @2@@@@@@@@@@@@\';
                ltext002: Label 'Posted Purchase Cr. Memos       @3@@@@@@@@@@@@\';
                ltext003: Label 'Open Purchase Orders            @4@@@@@@@@@@@@\';
                ltext004: Label 'Open Purchase Ret. Orders       @5@@@@@@@@@@@@\';
                ltext005: Label 'Open Purchase Cr. Memos         @6@@@@@@@@@@@@\';
                ltext006: Label 'Open Purchase Invoices          @7@@@@@@@@@@@@\\';
                ltext007: Label 'Calculating Lump Sum Rebates @8@@@@@@@@@@@@';
            begin
                if gblnProcessLumpSum then begin
                    if GuiAllowed then
                        gdlgWindow.Open(ltext000 +
                                        ltext001 +
                                        ltext002 +
                                        ltext003 +
                                        ltext004 +
                                        ltext005 +
                                        ltext006 +
                                        ltext007);
                end else begin
                    if GuiAllowed then
                        gdlgWindow.Open(ltext000 +
                                        ltext001 +
                                        ltext002 +
                                        ltext003 +
                                        ltext004 +
                                        ltext005 +
                                        ltext006);
                end;

                lrecPurchSetup.Get;
                lrecPurchSetup.TestField("Rbt Calc. Date Formula ELA");

                if gdteAsOfDate = 0D then
                    gdteAsOfDate := WorkDate;

                //-- Make date filter
                if gdteStartDateOverride <> 0D then
                    ldteStartDate := gdteStartDateOverride
                else
                    ldteStartDate := CalcDate(lrecPurchSetup."Rbt Calc. Date Formula ELA", gdteAsOfDate);

                lrecCustomer.SetRange("Date Filter", ldteStartDate, gdteAsOfDate);
                ltxtDateFilter := lrecCustomer.GetFilter("Date Filter");

                //Check PurchJnl
                if gblnAccrueRebates then
                    CheckPurchJnl;

                if gblnOtherRebates then begin //<ENRE1.00/>
                                               //Update Posted Invoices
                    if gblnCalcPostedInvoice then begin
                        UpdatePostedInvoices(ltxtDateFilter);
                        Commit;
                    end;

                    //Update Posted Cr. Memo
                    if gblnCalcPostedCrMemo then begin
                        UpdatePostedCrMemos(ltxtDateFilter);
                        Commit;
                    end;

                    //Update Purchase Orders
                    if gblnCalcOpenOrder then begin
                        UpdatePurchaseOrders;
                        Commit;
                    end;

                    //Update Return Orders
                    if gblnCalcOpenRetOrder then begin
                        UpdateReturnOrders;
                        Commit;
                    end;

                    //Update Purchase Cr. Memos
                    if gblnCalcOpenCrMemo then begin
                        UpdatePurchaseCrMemos;
                        Commit;
                    end;

                    //Update Purchase Invoices
                    if gblnCalcOpenInvoice then begin
                        UpdatePurchaseInvoices;
                        Commit;
                    end;
                end; //<ENRE1.00/>

                //Calculate Lump Sum Rebates
                if gblnProcessLumpSum then begin
                    CalcLumpSumRebates;
                    Commit;
                end;

                if gblnAccrueRebates then begin
                    if gblnForceFullAccrual then
                        ltxtDateFilter := '';

                    grptPostRebate.SetRebateLedgerFilters(ltxtDateFilter, "Purchase Rebate Header", '');
                    grptPostRebate.SetPostOption(goptPostCalculateAction);
                    grptPostRebate.UseRequestPage(false);
                    grptPostRebate.RunModal;
                end;
            end;

            trigger OnPreDataItem()
            begin
                //<ENRE1.00>
                if not (gblnOtherRebates or gblnProcessLumpSum) then
                    CurrReport.Break;
                //</ENRE1.00>
            end;
        }
        dataitem("Sales-Based Rebates"; "Integer")
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending);
            MaxIteration = 1;

            trigger OnAfterGetRecord()
            var
                lrecPurchSetup: Record "Purchases & Payables Setup";
                lrecVendor: Record Vendor;
                ltxtDateFilter: Text[250];
                ldteStartDate: Date;
                lrecRebatesInReportFilter: Record "Purchase Rebate Header ELA";
                ltext000: Label 'Processing...\';
                ltext001: Label 'Posted Sales Invoices        @2@@@@@@@@@@@@\';
                ltext002: Label 'Posted Sales Cr. Memos       @3@@@@@@@@@@@@\';
                ltext003: Label 'Open Sales Orders            @4@@@@@@@@@@@@\';
                ltext004: Label 'Open Sales Ret. Orders       @5@@@@@@@@@@@@\';
                ltext005: Label 'Open Sales Cr. Memos         @6@@@@@@@@@@@@\';
                ltext006: Label 'Open Sales Invoices          @7@@@@@@@@@@@@\\';
            begin
                "Purchase Rebate Header".SetRange("Rebate Type", "Purchase Rebate Header"."Rebate Type"::"Sales-Based");
                if GuiAllowed then
                    gdlgWindow.Open(ltext000 +
                                    ltext001 +
                                    ltext002 +
                                    ltext003 +
                                    ltext004 +
                                    ltext005 +
                                    ltext006);
                lrecPurchSetup.Get;
                lrecPurchSetup.TestField("Rbt Calc. Date Formula ELA");
                if gdteAsOfDate = 0D then
                    gdteAsOfDate := WorkDate;
                if gdteStartDateOverride <> 0D then
                    ldteStartDate := gdteStartDateOverride
                else
                    ldteStartDate := CalcDate(lrecPurchSetup."Rbt Calc. Date Formula ELA", gdteAsOfDate);
                lrecVendor.SetRange("Date Filter", ldteStartDate, gdteAsOfDate);
                ltxtDateFilter := lrecVendor.GetFilter("Date Filter");
                if gblnAccrueRebates then
                    CheckPurchJnl;
                grecTEMPEligibleRebates.Reset;
                grecTEMPEligibleRebates.DeleteAll;
                lrecRebatesInReportFilter.CopyFilters("Purchase Rebate Header");
                if lrecRebatesInReportFilter.FindSet then begin
                    repeat
                        grecTEMPEligibleRebates.TransferFields(lrecRebatesInReportFilter, true);
                        grecTEMPEligibleRebates.Insert;
                    until lrecRebatesInReportFilter.Next = 0;
                end;
                if gblnCalcPostedSalesInvoice then begin
                    UpdatePostedSalesInvoices(ltxtDateFilter);
                    Commit;
                end;
                if gblnCalcPostedSalesCrMemo then begin
                    UpdatePostedSalesCrMemos(ltxtDateFilter);
                    Commit;
                end;
                if gblnCalcOpenSalesOrder then begin
                    UpdateSalesOrders;
                    Commit;
                end;
                if gblnCalcOpenSalesRetOrder then begin
                    UpdateSalesReturnOrders;
                    Commit;
                end;
                if gblnCalcOpenSalesCrMemo then begin
                    UpdateSalesCrMemos;
                    Commit;
                end;
                if gblnCalcOpenSalesInvoice then begin
                    UpdateSalesInvoices;
                    Commit;
                end;

                if gblnAccrueRebates then begin
                    if gblnForceFullAccrual then
                        ltxtDateFilter := '';

                    Clear(grptPostRebate);
                    grptPostRebate.SetRebateLedgerFilters(ltxtDateFilter, "Purchase Rebate Header", '');
                    grptPostRebate.SetPostOption(goptPostCalculateAction);
                    grptPostRebate.UseRequestPage(false);
                    grptPostRebate.RunModal;
                end;
            end;

            trigger OnPreDataItem()
            begin
                if not gblnProcessSalesBasedRebate then
                    CurrReport.Break;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(gdteAsOfDate; gdteAsOfDate)
                    {
                        ApplicationArea = All;
                        Caption = 'As of Date';
                    }
                    field(gblnAccrueRebates; gblnAccrueRebates)
                    {
                        ApplicationArea = All;
                        Caption = 'Post Registered Rebates';

                        trigger OnValidate()
                        begin
                            gblnAccrueRebatesOnAfterValida;
                        end;
                    }
                    field(ctrlBypassDateFilter; gblnForceFullAccrual)
                    {
                        ApplicationArea = All;
                        Caption = 'Ignore Periodic Date Formula For Posting';
                        Editable = ctrlBypassDateFilterEditable;
                        MultiLine = true;
                        ToolTip = 'If TRUE, all unaccrued rebate entries up to and including the As of Date will be posted, regardless of the Rebate Periodic Date Formula in Purchase && Receivables Setup.';
                    }
                    field(ctrlAccrualAction; goptPostCalculateAction)
                    {
                        ApplicationArea = All;
                        Caption = 'Post Action';
                        Editable = ctrlAccrualActionEditable;
                        HideValue = true;
                        Visible = false;
                    }
                    group("Calculate Rebates For:")
                    {
                        Caption = 'Calculate Rebates For:';
                        field(gblnCalcOpenOrder; gblnCalcOpenOrder)
                        {
                            ApplicationArea = All;
                            Caption = 'Open Purchase Orders';
                        }
                        field(gblnCalcOpenInvoice; gblnCalcOpenInvoice)
                        {
                            ApplicationArea = All;
                            Caption = 'Open Purchase Invoices';
                        }
                        field(gblnCalcOpenCrMemo; gblnCalcOpenCrMemo)
                        {
                            ApplicationArea = All;
                            Caption = 'Open Purchase Cr. Memos';
                        }
                        field(gblnCalcOpenRetOrder; gblnCalcOpenRetOrder)
                        {
                            ApplicationArea = All;
                            Caption = 'Open Purchase Ret. Orders';
                        }
                    }
                    group("Register Rebates For:")
                    {
                        Caption = 'Register Rebates For:';
                        field(gblnCalcPostedInvoice; gblnCalcPostedInvoice)
                        {
                            ApplicationArea = All;
                            Caption = 'Posted Purchase Invoices';
                        }
                        field(gblnCalcPostedCrMemo; gblnCalcPostedCrMemo)
                        {
                            ApplicationArea = All;
                            Caption = 'Posted Purchase Cr. Memos';
                        }
                    }
                    group("Calculate Sales-Based Rebates For:")
                    {
                        Caption = 'Calculate Sales-Based Rebates For:';
                        field(gblnCalcOpenSalesOrder; gblnCalcOpenSalesOrder)
                        {
                            ApplicationArea = All;
                            Caption = 'Open Sales Orders';
                        }
                        field(gblnCalcOpenSalesInvoice; gblnCalcOpenSalesInvoice)
                        {
                            ApplicationArea = All;
                            Caption = 'Open Sales Invoices';
                        }
                        field(gblnCalcOpenSalesCrMemo; gblnCalcOpenSalesCrMemo)
                        {
                            ApplicationArea = All;
                            Caption = 'Open Sales Cr. Memos';
                        }
                        field(gblnCalcOpenSalesRetOrder; gblnCalcOpenSalesRetOrder)
                        {
                            ApplicationArea = All;
                            Caption = 'Open Sales Ret. Orders';
                        }
                    }
                    group("Register Sales-Based Rebates For:")
                    {
                        Caption = 'Register Sales-Based Rebates For:';
                        field(gblnCalcPostedSalesInvoice; gblnCalcPostedSalesInvoice)
                        {
                            ApplicationArea = All;
                            Caption = 'Posted Sales Invoices';
                        }
                        field(gblnCalcPostedSalesCrMemo; gblnCalcPostedSalesCrMemo)
                        {
                            ApplicationArea = All;
                            Caption = 'Posted Sales Cr. Memos';
                        }
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            ctrlAccrualActionEditable := true;
            ctrlBypassDateFilterEditable := true;
        end;

        trigger OnOpenPage()
        begin
            gdteAsOfDate := WorkDate;
            ctrlBypassDateFilterEditable := gblnAccrueRebates;
            ctrlAccrualActionEditable := gblnAccrueRebates;
        end;
    }

    labels
    {
    }

    var
        grecPurchSetup: Record "Purchases & Payables Setup";
        gdlgWindow: Dialog;
        gintTotal: Integer;
        gintCount: Integer;
        grptPostRebate: Report "Post Purchase Rebates ELA";
        gcduPurchRebateMgt: Codeunit "Purchase Rebate Management ELA";
        gblnCalcOpenInvoice: Boolean;
        gblnCalcOpenOrder: Boolean;
        gblnCalcOpenCrMemo: Boolean;
        gblnCalcOpenRetOrder: Boolean;
        gblnCalcPostedInvoice: Boolean;
        gblnCalcPostedCrMemo: Boolean;
        gblnAccrueRebates: Boolean;
        gdteAsOfDate: Date;
        gText000: Label 'You cannot manually apply a filter to %1. \You must use the Options tab.';
        gblnProcessLumpSum: Boolean;
        gblnForceFullAccrual: Boolean;
        grecTEMPEligibleRebates: Record "Purchase Rebate Header ELA" temporary;
        gdecTotalAdjustment: Decimal;
        gblnPrintReport: Boolean;
        goptPostCalculateAction: Option "Post Generated Journal Lines","Do Not Post Generated Journal Lines";
        gdteStartDateOverride: Date;
        [InDataSet]
        ctrlBypassDateFilterEditable: Boolean;
        [InDataSet]
        ctrlAccrualActionEditable: Boolean;
        gblnCalcOpenSalesInvoice: Boolean;
        gblnCalcOpenSalesOrder: Boolean;
        gblnCalcOpenSalesCrMemo: Boolean;
        gblnCalcOpenSalesRetOrder: Boolean;
        gblnCalcPostedSalesInvoice: Boolean;
        gblnCalcPostedSalesCrMemo: Boolean;
        grecPurchRebateHeader: Record "Purchase Rebate Header ELA";
        gblnProcessSalesBasedRebate: Boolean;
        gblnOtherRebates: Boolean;


    procedure CheckPurchJnl()
    var
        lrecPurchSetup: Record "Purchases & Payables Setup";
        lrecGenJnlLine: Record "Gen. Journal Line";
        lcon0001: Label 'Purchase Journal must be empty.';
    begin
        lrecPurchSetup.Get;
        lrecPurchSetup.TestField("Rbt Refund Jnl. Template ELA");
        lrecPurchSetup.TestField("Rbt Refund Journal Batch ELA");

        lrecGenJnlLine.Reset;
        lrecGenJnlLine.SetRange("Journal Template Name", lrecPurchSetup."Rbt Refund Jnl. Template ELA");
        lrecGenJnlLine.SetRange("Journal Batch Name", lrecPurchSetup."Rbt Batch Name ELA");
        lrecGenJnlLine.SetFilter("Account No.", '<>%1', '');

        if not lrecGenJnlLine.IsEmpty then begin
            Error(lcon0001)
        end;
    end;


    procedure UpdatePostedInvoices(ptxtDateFilter: Text[250])
    var
        lrecInvLine: Record "Purch. Inv. Line";
        lrecTempInvLine: Record "Purch. Inv. Line" temporary;
        lrecGLSetup: Record "General Ledger Setup";
        lrecTempRebate: Record "Rebate Entry ELA" temporary;
        lrecPostedRebateEntry: Record "Rebate Ledger Entry ELA";
        lrecPostedRebateEntrySummary: Record "Rebate Ledger Entry ELA";
        lrecRebateEntry: Record "Rebate Entry ELA";
        lrecPostedRebateEntryIns: Record "Rebate Ledger Entry ELA";
        lrecTempPostedRebateEntry: Record "Rebate Ledger Entry ELA" temporary;
        lrrfLine: RecordRef;
        ldtePostingDateToUse: Date;
        lintLineNo: Integer;
        ldecRebateTotalLCY: Decimal;
        lintFoo: Integer;
        ldecAdjLCY: Decimal;
        ldecAdjRBT: Decimal;
        ldecAdjDOC: Decimal;
        lrecTEMPAppliedRebateCodes: Record "Purchase Rebate Header ELA" temporary;
        lrecRebateHeader: Record "Purchase Rebate Header ELA";
    begin
        lrecGLSetup.Get;

        lrecGLSetup.TestField("Allow Posting From");
        lrecGLSetup.TestField("Allow Posting To");

        if ptxtDateFilter <> '' then
            lrecInvLine.SetFilter("Posting Date", ptxtDateFilter);

        if lrecInvLine.IsEmpty then
            exit;

        lrecTempInvLine.Reset;
        lrecTempInvLine.DeleteAll;

        //-- Store all invoice lines to be processed in a temp table for increased performance
        if lrecInvLine.FindSet then begin
            repeat
                if lrecInvLine.Type = lrecInvLine.Type::Item then begin
                    if lrecInvLine.Quantity <> 0 then begin
                        lrecTempInvLine.Init;
                        lrecTempInvLine.TransferFields(lrecInvLine);
                        lrecTempInvLine.Insert;
                    end;
                end;
            until lrecInvLine.Next = 0;
        end;

        gintTotal := lrecTempInvLine.Count;
        gintCount := 0;

        //-- Store the Entry No. to be used later if we need to create ledger entries
        lrecPostedRebateEntryIns.SetCurrentKey("Entry No.");

        if lrecPostedRebateEntryIns.FindLast then begin
            lintLineNo := lrecPostedRebateEntryIns."Entry No.";
        end else begin
            lintLineNo := 0;
        end;

        //-- Loop through invoice lines (temp table) to process rebates
        if lrecTempInvLine.FindSet then begin
            repeat
                gintCount += 1;

                if GuiAllowed then
                    gdlgWindow.Update(2, Round(gintCount / gintTotal) * 10000);

                Clear(ldtePostingDateToUse);

                //-- determine which period to post any adjustments to
                if (lrecTempInvLine."Posting Date" >= lrecGLSetup."Allow Posting From") and
                   (lrecTempInvLine."Posting Date" <= lrecGLSetup."Allow Posting To") then
                    ldtePostingDateToUse := lrecTempInvLine."Posting Date"
                else
                    ldtePostingDateToUse := lrecGLSetup."Allow Posting From";

                lrecTEMPAppliedRebateCodes.Reset;
                lrecTEMPAppliedRebateCodes.DeleteAll;

                // 1. - CALCULATE
                // calculate the rebates that apply to this line
                lrecTempRebate.Reset;
                lrecTempRebate.DeleteAll;

                //-- Filter the "real" table to pass into the rebate calculation routine
                lrecInvLine.Reset;
                lrecInvLine.SetRange("Document No.", lrecTempInvLine."Document No.");
                lrecInvLine.SetRange("Line No.", lrecTempInvLine."Line No.");
                lrecInvLine.FindFirst;

                lrrfLine.GetTable(lrecInvLine);
                lrrfLine.SetView(lrecInvLine.GetView);

                gcduPurchRebateMgt.SetRebateFilter("Purchase Rebate Header");
                gcduPurchRebateMgt.CalcRebate(lrrfLine, true, lrecTempRebate);

                lrecTempRebate.Reset;

                // 3. - filter on the rebates that have already been accrued for this line
                lrecPostedRebateEntry.Reset;
                lrecPostedRebateEntry.SetCurrentKey("Functional Area", "Source Type", "Source No.",
                  "Source Line No.", "Rebate Code");
                lrecPostedRebateEntry.SetRange("Functional Area", lrecPostedRebateEntry."Functional Area"::Purchase);
                lrecPostedRebateEntry.SetRange("Source Type", lrecPostedRebateEntry."Source Type"::"Posted Invoice");
                lrecPostedRebateEntry.SetRange("Source No.", lrecTempInvLine."Document No.");
                lrecPostedRebateEntry.SetRange("Source Line No.", lrecTempInvLine."Line No.");

                // 4. - COMPARE, ADJUST BALANCES AND CREATE NEW ENTRIES
                // for each calculated rebate line, make adjustments vs accrued entries if necessary
                if lrecTempRebate.FindSet then begin
                    repeat
                        if lrecRebateHeader.Get(lrecTempRebate."Rebate Code") then begin
                            if not lrecRebateHeader.Blocked then begin
                                lrecPostedRebateEntry.SetRange("Rebate Code", lrecTempRebate."Rebate Code");
                                lrecPostedRebateEntry.CalcSums("Amount (LCY)", "Amount (RBT)", "Amount (DOC)");

                                if lrecPostedRebateEntry."Amount (LCY)" <> lrecTempRebate."Amount (LCY)" then begin
                                    ldecAdjLCY := lrecTempRebate."Amount (LCY)" - lrecPostedRebateEntry."Amount (LCY)";
                                    ldecAdjRBT := lrecTempRebate."Amount (RBT)" - lrecPostedRebateEntry."Amount (RBT)";
                                    ldecAdjDOC := lrecTempRebate."Amount (DOC)" - lrecPostedRebateEntry."Amount (DOC)";

                                    lrecPostedRebateEntryIns.Reset;

                                    lrecPostedRebateEntryIns.Init;
                                    lrecPostedRebateEntryIns.TransferFields(lrecTempRebate);

                                    lintLineNo := lintLineNo + 1;
                                    lrecPostedRebateEntryIns."Entry No." := lintLineNo;

                                    lrecPostedRebateEntryIns.Adjustment := lrecPostedRebateEntry.FindFirst;

                                    lrecPostedRebateEntryIns.Validate("Amount (LCY)", ldecAdjLCY);
                                    lrecPostedRebateEntryIns.Validate("Amount (RBT)", ldecAdjRBT);
                                    lrecPostedRebateEntryIns.Validate("Amount (DOC)", ldecAdjDOC);

                                    lrecPostedRebateEntryIns."Posted To G/L" := false;
                                    lrecPostedRebateEntryIns."Paid-by Vendor" := false;

                                    lrecPostedRebateEntryIns.Insert(true);
                                end;

                                if not lrecTEMPAppliedRebateCodes.Get(lrecTempRebate."Rebate Code") then begin
                                    lrecTEMPAppliedRebateCodes.Code := lrecTempRebate."Rebate Code";
                                    lrecTEMPAppliedRebateCodes.Insert;
                                end;
                            end;
                        end;
                    until lrecTempRebate.Next = 0;
                end;

                // 5. - REVERSE CANCELLED REBATES
                // check the posted rebate lines to confirm that they are still valid
                lrecPostedRebateEntry.SetRange("Rebate Code");

                if lrecPostedRebateEntry.FindSet then begin
                    repeat
                        // if this rebate code isn't current and it's within our report filter, reverse this entry
                        if (not lrecTEMPAppliedRebateCodes.Get(lrecPostedRebateEntry."Rebate Code"))
                        and grecTEMPEligibleRebates.Get(lrecPostedRebateEntry."Rebate Code") then begin
                            lrecPostedRebateEntrySummary.Copy(lrecPostedRebateEntry);
                            lrecPostedRebateEntrySummary.SetRange("Rebate Code", lrecPostedRebateEntry."Rebate Code");
                            lrecPostedRebateEntrySummary.CalcSums("Amount (LCY)", "Amount (RBT)", "Amount (DOC)");

                            if (lrecPostedRebateEntrySummary."Amount (LCY)" <> 0) then begin
                                lrecPostedRebateEntryIns.Reset;

                                lrecPostedRebateEntryIns.Init;
                                lrecPostedRebateEntryIns.TransferFields(lrecPostedRebateEntry);

                                lintLineNo := lintLineNo + 1;
                                lrecPostedRebateEntryIns."Entry No." := lintLineNo;

                                lrecPostedRebateEntryIns.Validate("Amount (LCY)", -lrecPostedRebateEntrySummary."Amount (LCY)");
                                lrecPostedRebateEntryIns.Validate("Amount (RBT)", -lrecPostedRebateEntrySummary."Amount (RBT)");
                                lrecPostedRebateEntryIns.Validate("Amount (DOC)", -lrecPostedRebateEntrySummary."Amount (DOC)");

                                lrecPostedRebateEntryIns.Adjustment := true;
                                lrecPostedRebateEntryIns."Posted To G/L" := false;
                                lrecPostedRebateEntryIns."Paid-by Vendor" := false;

                                lrecPostedRebateEntryIns.Insert(true);
                            end;
                        end;

                        if not lrecTEMPAppliedRebateCodes.Get(lrecPostedRebateEntry."Rebate Code") then begin
                            lrecTEMPAppliedRebateCodes.Code := lrecPostedRebateEntry."Rebate Code";
                            lrecTEMPAppliedRebateCodes.Insert;
                        end;
                    until lrecPostedRebateEntry.Next = 0;
                end;
            until lrecTempInvLine.Next = 0;
        end;
    end;


    procedure UpdatePostedCrMemos(ptxtDateFilter: Text[250])
    var
        lrecCrMemoLine: Record "Purch. Cr. Memo Line";
        lrecTempCrMemoLine: Record "Purch. Cr. Memo Line" temporary;
        lrecGLSetup: Record "General Ledger Setup";
        lrecTempRebate: Record "Rebate Entry ELA" temporary;
        lrecPostedRebateEntry: Record "Rebate Ledger Entry ELA";
        lrecRebateEntry: Record "Rebate Entry ELA";
        lrecPostedRebateEntryIns: Record "Rebate Ledger Entry ELA";
        lrecTempPostedRebateEntry: Record "Rebate Ledger Entry ELA" temporary;
        lrrfLine: RecordRef;
        ldtePostingDateToUse: Date;
        lintLineNo: Integer;
        ldecRebateTotalLCY: Decimal;
        ltxtFilterStr: Text[1024];
        lrecTEMPAppliedRebateCodes: Record "Purchase Rebate Header ELA" temporary;
        ldecAdjLCY: Decimal;
        ldecAdjRBT: Decimal;
        ldecAdjDOC: Decimal;
        lrecPostedRebateEntrySummary: Record "Rebate Ledger Entry ELA";
        lrecRebateHeader: Record "Purchase Rebate Header ELA";
    begin
        lrecGLSetup.Get;

        lrecGLSetup.TestField("Allow Posting From");
        lrecGLSetup.TestField("Allow Posting To");

        if ptxtDateFilter <> '' then
            lrecCrMemoLine.SetFilter("Posting Date", ptxtDateFilter);

        if lrecCrMemoLine.IsEmpty then
            exit;

        lrecTempCrMemoLine.Reset;
        lrecTempCrMemoLine.DeleteAll;

        //-- Store all credit memo lines to be processed in a temp table for increased performance
        if lrecCrMemoLine.FindSet then begin
            repeat
                if lrecCrMemoLine.Type = lrecCrMemoLine.Type::Item then begin
                    if lrecCrMemoLine.Quantity <> 0 then begin
                        lrecTempCrMemoLine.Init;
                        lrecTempCrMemoLine.TransferFields(lrecCrMemoLine);
                        lrecTempCrMemoLine.Insert;
                    end;
                end;
            until lrecCrMemoLine.Next = 0;
        end;

        gintTotal := lrecTempCrMemoLine.Count;
        gintCount := 0;

        lrecPostedRebateEntryIns.SetCurrentKey("Entry No.");

        if lrecPostedRebateEntryIns.FindLast then begin
            lintLineNo := lrecPostedRebateEntryIns."Entry No.";
        end else begin
            lintLineNo := 0;
        end;

        if lrecTempCrMemoLine.FindSet then begin
            repeat
                gintCount += 1;

                if GuiAllowed then
                    gdlgWindow.Update(3, Round(gintCount / gintTotal) * 10000);

                Clear(ldtePostingDateToUse);

                //-- determine which period to post any adjustments to
                if (lrecTempCrMemoLine."Posting Date" >= lrecGLSetup."Allow Posting From") and
                   (lrecTempCrMemoLine."Posting Date" <= lrecGLSetup."Allow Posting To") then
                    ldtePostingDateToUse := lrecTempCrMemoLine."Posting Date"
                else
                    ldtePostingDateToUse := lrecGLSetup."Allow Posting From";

                lrecTEMPAppliedRebateCodes.Reset;
                lrecTEMPAppliedRebateCodes.DeleteAll;

                // 1. - CALCULATE
                // calculate the rebates that apply to this line
                lrecTempRebate.Reset;
                lrecTempRebate.DeleteAll;

                //-- Filter the "real" table to pass into the rebate calculation routine
                lrecCrMemoLine.Reset;
                lrecCrMemoLine.SetRange("Document No.", lrecTempCrMemoLine."Document No.");
                lrecCrMemoLine.SetRange("Line No.", lrecTempCrMemoLine."Line No.");
                lrecCrMemoLine.FindFirst;

                lrrfLine.GetTable(lrecCrMemoLine);
                lrrfLine.SetView(lrecCrMemoLine.GetView);

                gcduPurchRebateMgt.SetRebateFilter("Purchase Rebate Header");
                gcduPurchRebateMgt.CalcRebate(lrrfLine, true, lrecTempRebate);

                lrecTempRebate.Reset;

                // 3. - filter on the rebates that have already been accrued for this line
                lrecPostedRebateEntry.Reset;
                lrecPostedRebateEntry.SetCurrentKey("Functional Area", "Source Type", "Source No.",
                  "Source Line No.", "Rebate Code");
                lrecPostedRebateEntry.SetRange("Functional Area", lrecPostedRebateEntry."Functional Area"::Purchase);
                lrecPostedRebateEntry.SetRange("Source Type", lrecPostedRebateEntry."Source Type"::"Posted Cr. Memo");
                lrecPostedRebateEntry.SetRange("Source No.", lrecTempCrMemoLine."Document No.");
                lrecPostedRebateEntry.SetRange("Source Line No.", lrecTempCrMemoLine."Line No.");

                // 4. - COMPARE, ADJUST BALANCES AND CREATE NEW ENTRIES
                // for each calculated rebate line, make adjustments vs accrued entries if necessary
                if lrecTempRebate.FindSet then begin
                    repeat
                        if lrecRebateHeader.Get(lrecTempRebate."Rebate Code") then begin
                            if not lrecRebateHeader.Blocked then begin
                                lrecPostedRebateEntry.SetRange("Rebate Code", lrecTempRebate."Rebate Code");
                                lrecPostedRebateEntry.CalcSums("Amount (LCY)", "Amount (RBT)", "Amount (DOC)");

                                if lrecPostedRebateEntry."Amount (LCY)" <> lrecTempRebate."Amount (LCY)" then begin
                                    ldecAdjLCY := lrecTempRebate."Amount (LCY)" - lrecPostedRebateEntry."Amount (LCY)";
                                    ldecAdjRBT := lrecTempRebate."Amount (RBT)" - lrecPostedRebateEntry."Amount (RBT)";
                                    ldecAdjDOC := lrecTempRebate."Amount (DOC)" - lrecPostedRebateEntry."Amount (DOC)";

                                    lrecPostedRebateEntryIns.Reset;

                                    lrecPostedRebateEntryIns.Init;
                                    lrecPostedRebateEntryIns.TransferFields(lrecTempRebate);

                                    lintLineNo := lintLineNo + 1;
                                    lrecPostedRebateEntryIns."Entry No." := lintLineNo;

                                    lrecPostedRebateEntryIns.Adjustment := lrecPostedRebateEntry.FindFirst;

                                    lrecPostedRebateEntryIns.Validate("Amount (LCY)", ldecAdjLCY);
                                    lrecPostedRebateEntryIns.Validate("Amount (RBT)", ldecAdjRBT);
                                    lrecPostedRebateEntryIns.Validate("Amount (DOC)", ldecAdjDOC);

                                    lrecPostedRebateEntryIns."Posted To G/L" := false;
                                    lrecPostedRebateEntryIns."Paid-by Vendor" := false;

                                    lrecPostedRebateEntryIns.Insert(true);
                                end;

                                if not lrecTEMPAppliedRebateCodes.Get(lrecTempRebate."Rebate Code") then begin
                                    lrecTEMPAppliedRebateCodes.Code := lrecTempRebate."Rebate Code";
                                    lrecTEMPAppliedRebateCodes.Insert;
                                end;
                            end;
                        end;
                    until lrecTempRebate.Next = 0;
                end;

                // 5. - REVERSE CANCELLED REBATES
                // check the posted rebate lines to confirm that they are still valid
                lrecPostedRebateEntry.SetRange("Rebate Code");

                if lrecPostedRebateEntry.FindSet then begin
                    repeat
                        // if this rebate code isn't current and it's within our report filter, reverse this entry
                        if (not lrecTEMPAppliedRebateCodes.Get(lrecPostedRebateEntry."Rebate Code"))
                        and grecTEMPEligibleRebates.Get(lrecPostedRebateEntry."Rebate Code") then begin
                            lrecPostedRebateEntrySummary.Copy(lrecPostedRebateEntry);
                            lrecPostedRebateEntrySummary.SetRange("Rebate Code", lrecPostedRebateEntry."Rebate Code");
                            lrecPostedRebateEntrySummary.CalcSums("Amount (LCY)", "Amount (RBT)", "Amount (DOC)");

                            if (lrecPostedRebateEntrySummary."Amount (LCY)" <> 0) then begin
                                lrecPostedRebateEntryIns.Reset;

                                lrecPostedRebateEntryIns.Init;
                                lrecPostedRebateEntryIns.TransferFields(lrecPostedRebateEntry);

                                lintLineNo := lintLineNo + 1;
                                lrecPostedRebateEntryIns."Entry No." := lintLineNo;

                                lrecPostedRebateEntryIns.Validate("Amount (LCY)", -lrecPostedRebateEntrySummary."Amount (LCY)");
                                lrecPostedRebateEntryIns.Validate("Amount (RBT)", -lrecPostedRebateEntrySummary."Amount (RBT)");
                                lrecPostedRebateEntryIns.Validate("Amount (DOC)", -lrecPostedRebateEntrySummary."Amount (DOC)");

                                lrecPostedRebateEntryIns.Adjustment := true;
                                lrecPostedRebateEntryIns."Posted To G/L" := false;
                                lrecPostedRebateEntryIns."Paid-by Vendor" := false;

                                lrecPostedRebateEntryIns.Insert(true);
                            end;
                        end;

                        if not lrecTEMPAppliedRebateCodes.Get(lrecPostedRebateEntry."Rebate Code") then begin
                            lrecTEMPAppliedRebateCodes.Code := lrecPostedRebateEntry."Rebate Code";
                            lrecTEMPAppliedRebateCodes.Insert;
                        end;
                    until lrecPostedRebateEntry.Next = 0;
                end;
            until lrecTempCrMemoLine.Next = 0;
        end;
    end;


    procedure UpdatePurchaseOrders()
    var
        lrecPurchHeader: Record "Purchase Header";
        lrecPurchHeader2: Record "Purchase Header";
        lrecRebateDetail: Record "Purchase Rebate Line ELA";
        lrrfHeader: RecordRef;
    begin
        lrecPurchHeader.Reset;

        lrecPurchHeader.SetRange("Document Type", lrecPurchHeader."Document Type"::Order);
        lrecPurchHeader.SetRange("No.");

        gintTotal := lrecPurchHeader.Count;
        gintCount := 0;

        if lrecPurchHeader.FindSet then begin
            repeat
                gintCount += 1;

                if GuiAllowed then
                    gdlgWindow.Update(4, Round(gintCount / gintTotal) * 10000);

                lrecPurchHeader2.SetRange("Document Type", lrecPurchHeader."Document Type");
                lrecPurchHeader2.SetRange("No.", lrecPurchHeader."No.");
                lrecPurchHeader2.FindFirst;

                lrrfHeader.GetTable(lrecPurchHeader);
                lrrfHeader.SetView(lrecPurchHeader.GetView);

                gcduPurchRebateMgt.SetRebateFilter("Purchase Rebate Header");
                gcduPurchRebateMgt.CalcPurchDocRebate(lrrfHeader, false, false);
            until lrecPurchHeader.Next = 0;
        end;
    end;


    procedure UpdateReturnOrders()
    var
        lrecPurchHeader: Record "Purchase Header";
        lrecPurchHeader2: Record "Purchase Header";
        lrecRebateDetail: Record "Purchase Rebate Line ELA";
        lrrfHeader: RecordRef;
    begin
        lrecPurchHeader.Reset;

        lrecPurchHeader.SetRange("Document Type", lrecPurchHeader."Document Type"::"Return Order");
        lrecPurchHeader.SetRange("No.");

        gintTotal := lrecPurchHeader.Count;
        gintCount := 0;

        if lrecPurchHeader.FindSet then begin
            repeat
                gintCount += 1;

                if GuiAllowed then
                    gdlgWindow.Update(5, Round(gintCount / gintTotal) * 10000);

                lrecPurchHeader2.SetRange("Document Type", lrecPurchHeader."Document Type");
                lrecPurchHeader2.SetRange("No.", lrecPurchHeader."No.");
                lrecPurchHeader2.FindFirst;

                lrrfHeader.GetTable(lrecPurchHeader);
                lrrfHeader.SetView(lrecPurchHeader.GetView);

                gcduPurchRebateMgt.SetRebateFilter("Purchase Rebate Header");
                gcduPurchRebateMgt.CalcPurchDocRebate(lrrfHeader, false, false);
            until lrecPurchHeader.Next = 0;
        end;
    end;


    procedure UpdatePurchaseCrMemos()
    var
        lrecPurchHeader: Record "Purchase Header";
        lrecPurchHeader2: Record "Purchase Header";
        lrecRebateDetail: Record "Purchase Rebate Line ELA";
        lrrfHeader: RecordRef;
    begin
        lrecPurchHeader.Reset;

        lrecPurchHeader.SetRange("Document Type", lrecPurchHeader."Document Type"::"Credit Memo");
        lrecPurchHeader.SetRange("No.");

        gintTotal := lrecPurchHeader.Count;
        gintCount := 0;

        if lrecPurchHeader.FindSet then begin
            repeat
                gintCount += 1;

                if GuiAllowed then
                    gdlgWindow.Update(6, Round(gintCount / gintTotal) * 10000);

                lrecPurchHeader2.SetRange("Document Type", lrecPurchHeader."Document Type");
                lrecPurchHeader2.SetRange("No.", lrecPurchHeader."No.");
                lrecPurchHeader2.FindFirst;

                lrrfHeader.GetTable(lrecPurchHeader);
                lrrfHeader.SetView(lrecPurchHeader.GetView);

                gcduPurchRebateMgt.SetRebateFilter("Purchase Rebate Header");
                gcduPurchRebateMgt.CalcPurchDocRebate(lrrfHeader, false, false);
            until lrecPurchHeader.Next = 0;
        end;
    end;


    procedure UpdatePurchaseInvoices()
    var
        lrecPurchHeader: Record "Purchase Header";
        lrecPurchHeader2: Record "Purchase Header";
        lrecRebateDetail: Record "Purchase Rebate Line ELA";
        lrrfHeader: RecordRef;
    begin
        lrecPurchHeader.Reset;

        lrecPurchHeader.SetRange("Document Type", lrecPurchHeader."Document Type"::Invoice);
        lrecPurchHeader.SetRange("No.");

        gintTotal := lrecPurchHeader.Count;
        gintCount := 0;

        if lrecPurchHeader.FindSet then begin
            repeat
                gintCount += 1;

                if GuiAllowed then
                    gdlgWindow.Update(7, Round(gintCount / gintTotal) * 10000);

                lrecPurchHeader2.SetRange("Document Type", lrecPurchHeader."Document Type");
                lrecPurchHeader2.SetRange("No.", lrecPurchHeader."No.");
                lrecPurchHeader2.FindFirst;

                lrrfHeader.GetTable(lrecPurchHeader);
                lrrfHeader.SetView(lrecPurchHeader.GetView);

                gcduPurchRebateMgt.SetRebateFilter("Purchase Rebate Header");
                gcduPurchRebateMgt.CalcPurchDocRebate(lrrfHeader, false, false);
            until lrecPurchHeader.Next = 0;
        end;
    end;


    procedure CalcLumpSumRebates()
    var
        lrecPurchRebate: Record "Purchase Rebate Header ELA";
    begin
        lrecPurchRebate.CopyFilters("Purchase Rebate Header");

        lrecPurchRebate.SetFilter("Start Date", '<=%1', gdteAsOfDate);
        lrecPurchRebate.SetRange("End Date");
        lrecPurchRebate.SetRange("Rebate Type", lrecPurchRebate."Rebate Type"::"Lump Sum");
        lrecPurchRebate.SetRange(Blocked, false);

        if not lrecPurchRebate.IsEmpty then begin
            lrecPurchRebate.FindSet;

            gintTotal := lrecPurchRebate.Count;
            gintCount := 0;

            repeat
                gintCount += 1;

                if GuiAllowed then
                    gdlgWindow.Update(8, Round(gintCount / gintTotal) * 10000);

                gcduPurchRebateMgt.CalcLumpSumRebate(gdteAsOfDate, lrecPurchRebate);
            until lrecPurchRebate.Next = 0;
        end;
    end;


    procedure SetParameters(pdteAsOfDate: Date; pblnCalcOpenInvoice: Boolean; pblnCalcOpenOrder: Boolean; pblnCalcOpenCrMemo: Boolean; pblnCalcOpenRetOrder: Boolean; pblnCalcPostedInvoice: Boolean; pblnCalcPostedCrMemo: Boolean; pblnAccrueRebates: Boolean; pblnIgnoreAccrualDateCalc: Boolean; poptAccrualAction: Option Post,"Do Not Post"; var precRebateFilter: Record "Purchase Rebate Header ELA"; pblnCalcOpenSalesOrder: Boolean; pblnCalcOpenSalesInvoice: Boolean; pblnCalcOpenSalesCrMemo: Boolean; pblnCalcOpenSalesRetOrder: Boolean; pblnCalcPostedSalesInvoice: Boolean; pblnCalcPostedSalesCrMemo: Boolean)
    begin
        gdteAsOfDate := pdteAsOfDate;
        gblnAccrueRebates := pblnAccrueRebates;
        gblnForceFullAccrual := pblnIgnoreAccrualDateCalc;
        goptPostCalculateAction := poptAccrualAction;
        gblnCalcOpenInvoice := pblnCalcOpenInvoice;
        gblnCalcOpenOrder := pblnCalcOpenOrder;
        gblnCalcOpenCrMemo := pblnCalcOpenCrMemo;
        gblnCalcOpenRetOrder := pblnCalcOpenRetOrder;
        gblnCalcPostedInvoice := pblnCalcPostedInvoice;
        gblnCalcPostedCrMemo := pblnCalcPostedCrMemo;
        "Purchase Rebate Header".CopyFilters(precRebateFilter);

        //<ENRE1.00>
        gblnCalcOpenSalesOrder := pblnCalcOpenSalesOrder;
        gblnCalcOpenSalesInvoice := pblnCalcOpenSalesInvoice;
        gblnCalcOpenSalesCrMemo := pblnCalcOpenSalesCrMemo;
        gblnCalcOpenSalesRetOrder := pblnCalcOpenSalesRetOrder;
        gblnCalcPostedSalesInvoice := pblnCalcPostedSalesInvoice;
        gblnCalcPostedSalesCrMemo := pblnCalcPostedSalesCrMemo;
        //</ENRE1.00>
    end;


    procedure OverrideStartDate(pdteDateToUse: Date)
    begin
        gdteStartDateOverride := pdteDateToUse;
    end;

    local procedure gblnAccrueRebatesOnAfterValida()
    begin
        ctrlBypassDateFilterEditable := gblnAccrueRebates;
        ctrlAccrualActionEditable := gblnAccrueRebates;
        gblnForceFullAccrual := gblnAccrueRebates;
    end;


    procedure UpdatePostedSalesInvoices(ptxtDateFilter: Text[250])
    var
        lrecInvLine: Record "Sales Invoice Line";
        lrecTempInvLine: Record "Sales Invoice Line" temporary;
        lrecGLSetup: Record "General Ledger Setup";
        lrecTempRebate: Record "Rebate Entry ELA" temporary;
        lrecPostedRebateEntry: Record "Rebate Ledger Entry ELA";
        lrecPostedRebateEntrySummary: Record "Rebate Ledger Entry ELA";
        lrecRebateEntry: Record "Rebate Entry ELA";
        lrecPostedRebateEntryIns: Record "Rebate Ledger Entry ELA";
        lrecTempPostedRebateEntry: Record "Rebate Ledger Entry ELA" temporary;
        lrrfLine: RecordRef;
        ldtePostingDateToUse: Date;
        lintLineNo: Integer;
        ldecRebateTotalLCY: Decimal;
        lintFoo: Integer;
        ldecAdjLCY: Decimal;
        ldecAdjRBT: Decimal;
        ldecAdjDOC: Decimal;
        lrecTEMPAppliedRebateCodes: Record "Purchase Rebate Header ELA" temporary;
        lrecPurchRebateHeader: Record "Purchase Rebate Header ELA";
        lrecPostedSalesProfitModifier: Record "Post. Sales Prof. Modifier ELA";
        lintPostedSalesProfitModifierEntryNo: Integer;
        lrecPostedSalesProfitModifierToInsert: Record "Post. Sales Prof. Modifier ELA";
        lrecPostedSalesProfitModifierSummary: Record "Post. Sales Prof. Modifier ELA";
    begin
        lrecGLSetup.Get;

        lrecGLSetup.TestField("Allow Posting From");
        lrecGLSetup.TestField("Allow Posting To");

        if ptxtDateFilter <> '' then
            lrecInvLine.SetFilter("Posting Date", ptxtDateFilter);

        if lrecInvLine.IsEmpty then
            exit;

        lrecTempInvLine.Reset;
        lrecTempInvLine.DeleteAll;

        //-- Store all invoice lines to be processed in a temp table for increased performance
        if lrecInvLine.FindSet then begin
            repeat
                if (lrecInvLine.Type = lrecInvLine.Type::Item) or (lrecInvLine."Ref. Item No. ELA" <> '') then begin
                    if lrecInvLine.Quantity <> 0 then begin
                        lrecTempInvLine.Init;
                        lrecTempInvLine.TransferFields(lrecInvLine);
                        lrecTempInvLine.Insert;
                    end;
                end;
            until lrecInvLine.Next = 0;
        end;

        gintTotal := lrecTempInvLine.Count;
        gintCount := 0;

        lrecPostedRebateEntryIns.SetCurrentKey("Entry No.");

        if lrecPostedRebateEntryIns.FindLast then begin
            lintLineNo := lrecPostedRebateEntryIns."Entry No.";
        end else begin
            lintLineNo := 0;
        end;

        //<ENRE1.00>
        if (
          (lrecPostedSalesProfitModifier.FindLast)
        ) then begin
            lintPostedSalesProfitModifierEntryNo := lrecPostedSalesProfitModifier."Entry No.";
        end else begin
            lintPostedSalesProfitModifierEntryNo := 0;
        end;
        //</ENRE1.00>

        if lrecTempInvLine.FindSet then begin
            repeat
                gintCount += 1;

                if GuiAllowed then
                    gdlgWindow.Update(2, Round(gintCount / gintTotal) * 10000);

                Clear(ldtePostingDateToUse);

                //-- determine which period to post any adjustments to
                if (lrecTempInvLine."Posting Date" >= lrecGLSetup."Allow Posting From") and
                   (lrecTempInvLine."Posting Date" <= lrecGLSetup."Allow Posting To") then
                    ldtePostingDateToUse := lrecTempInvLine."Posting Date"
                else
                    ldtePostingDateToUse := lrecGLSetup."Allow Posting From";

                lrecTEMPAppliedRebateCodes.Reset;
                lrecTEMPAppliedRebateCodes.DeleteAll;

                // 1. - CALCULATE
                // calculate the rebates that apply to this line
                lrecTempRebate.Reset;
                lrecTempRebate.DeleteAll;

                //-- Filter the "real" table to pass into the rebate calculation routine
                lrecInvLine.Reset;
                lrecInvLine.SetRange("Document No.", lrecTempInvLine."Document No.");
                lrecInvLine.SetRange("Line No.", lrecTempInvLine."Line No.");
                lrecInvLine.FindFirst;

                lrrfLine.GetTable(lrecInvLine);
                lrrfLine.SetView(lrecInvLine.GetView);

                gcduPurchRebateMgt.SetRebateFilter("Purchase Rebate Header");
                gcduPurchRebateMgt.SetSalesBasedRebateMode(true);
                gcduPurchRebateMgt.CalcRebate(lrrfLine, true, lrecTempRebate);

                lrecTempRebate.Reset;

                // 3. - filter on the rebates that have already been accrued for this line
                lrecPostedRebateEntry.Reset;
                lrecPostedRebateEntry.SetCurrentKey("Functional Area", "Source Type", "Source No.",
                  "Source Line No.", "Rebate Code");
                lrecPostedRebateEntry.SetRange("Functional Area", lrecPostedRebateEntry."Functional Area"::Purchase);
                lrecPostedRebateEntry.SetRange("Source Type", lrecPostedRebateEntry."Source Type"::"Posted Invoice");
                lrecPostedRebateEntry.SetRange("Source No.", lrecTempInvLine."Document No.");
                lrecPostedRebateEntry.SetRange("Source Line No.", lrecTempInvLine."Line No.");

                // 4. - COMPARE, ADJUST BALANCES AND CREATE NEW ENTRIES
                // for each calculated rebate line, make adjustments vs accrued entries if necessary
                if lrecTempRebate.FindSet then begin
                    repeat
                        if lrecPurchRebateHeader.Get(lrecTempRebate."Rebate Code") then begin
                            if not lrecPurchRebateHeader.Blocked then begin
                                lrecPostedRebateEntry.SetRange("Rebate Code", lrecTempRebate."Rebate Code");
                                lrecPostedRebateEntry.CalcSums("Amount (LCY)", "Amount (RBT)", "Amount (DOC)");

                                if lrecPostedRebateEntry."Amount (LCY)" <> lrecTempRebate."Amount (LCY)" then begin
                                    ldecAdjLCY := lrecTempRebate."Amount (LCY)" - lrecPostedRebateEntry."Amount (LCY)";
                                    ldecAdjRBT := lrecTempRebate."Amount (RBT)" - lrecPostedRebateEntry."Amount (RBT)";
                                    ldecAdjDOC := lrecTempRebate."Amount (DOC)" - lrecPostedRebateEntry."Amount (DOC)";

                                    lrecPostedRebateEntryIns.Init;
                                    lrecPostedRebateEntryIns.TransferFields(lrecTempRebate);

                                    lintLineNo := lintLineNo + 1;
                                    lrecPostedRebateEntryIns."Entry No." := lintLineNo;

                                    lrecPostedRebateEntryIns.Adjustment := lrecPostedRebateEntry.FindFirst;

                                    lrecPostedRebateEntryIns.Validate("Amount (LCY)", ldecAdjLCY);
                                    lrecPostedRebateEntryIns.Validate("Amount (RBT)", ldecAdjRBT);
                                    lrecPostedRebateEntryIns.Validate("Amount (DOC)", ldecAdjDOC);

                                    lrecPostedRebateEntryIns."Posted To G/L" := false;
                                    lrecPostedRebateEntryIns."Paid-by Vendor" := false;

                                    lrecPostedRebateEntryIns.Insert(true);
                                end;

                                //<ENRE1.00>
                                if (lrecPurchRebateHeader."Rebate Type" = lrecPurchRebateHeader."Rebate Type"::"Sales-Based") or
                                  (lrecPurchRebateHeader."Sales Profit Modifier") then begin

                                    lrecPostedSalesProfitModifier.SetRange("Document Type", lrecPostedSalesProfitModifier."Document Type"::Invoice);

                                    lrecPostedSalesProfitModifier.SetRange("Document No.", lrecTempInvLine."Document No.");
                                    lrecPostedSalesProfitModifier.SetRange("Document Line No.", lrecTempInvLine."Line No.");

                                    lrecPostedSalesProfitModifier.SetRange("Source Type", lrecPostedSalesProfitModifier."Source Type"::"Purchase Rebate");
                                    lrecPostedSalesProfitModifier.SetRange("Source No.", lrecPurchRebateHeader.Code);

                                    lrecPostedSalesProfitModifier.CalcSums("Amount (LCY)", Amount);

                                    if lrecPostedSalesProfitModifier."Amount (LCY)" <> lrecTempRebate."Amount (LCY)" then begin
                                        ldecAdjLCY := lrecTempRebate."Amount (LCY)" - lrecPostedSalesProfitModifier."Amount (LCY)";
                                        ldecAdjDOC := lrecTempRebate."Amount (DOC)" - lrecPostedSalesProfitModifier.Amount;

                                        lintPostedSalesProfitModifierEntryNo := lintPostedSalesProfitModifierEntryNo + 1;

                                        lrecPostedSalesProfitModifierToInsert.Init;
                                        lrecPostedSalesProfitModifierToInsert."Entry No." := lintPostedSalesProfitModifierEntryNo;
                                        lrecPostedSalesProfitModifierToInsert."Document Type" := lrecPostedSalesProfitModifierToInsert."Document Type"::Invoice;

                                        lrecPostedSalesProfitModifierToInsert."Document No." := lrecTempInvLine."Document No.";
                                        lrecPostedSalesProfitModifierToInsert."Document Line No." := lrecTempInvLine."Line No.";

                                        lrecPostedSalesProfitModifierToInsert."Source Type" := lrecPostedSalesProfitModifier."Source Type"::"Purchase Rebate";
                                        lrecPostedSalesProfitModifierToInsert."Source No." := lrecPurchRebateHeader.Code;
                                        lrecPostedSalesProfitModifierToInsert.Validate("Amount (LCY)", ldecAdjLCY);
                                        lrecPostedSalesProfitModifierToInsert.Validate(Amount, ldecAdjDOC);

                                        lrecPostedSalesProfitModifierToInsert.Insert;
                                    end;

                                end;
                                //</ENRE1.00>

                                if not lrecTEMPAppliedRebateCodes.Get(lrecTempRebate."Rebate Code") then begin
                                    lrecTEMPAppliedRebateCodes.Code := lrecTempRebate."Rebate Code";
                                    lrecTEMPAppliedRebateCodes.Insert;
                                end;
                            end;
                        end;
                    until lrecTempRebate.Next = 0;
                end;

                // 5. - REVERSE CANCELLED REBATES
                // check the posted rebate lines to confirm that they are still valid
                lrecPostedRebateEntry.SetRange("Rebate Code");

                if lrecPostedRebateEntry.FindSet then begin
                    repeat
                        if (not lrecTEMPAppliedRebateCodes.Get(lrecPostedRebateEntry."Rebate Code"))
                        and grecTEMPEligibleRebates.Get(lrecPostedRebateEntry."Rebate Code") then begin
                            lrecPostedRebateEntrySummary.Copy(lrecPostedRebateEntry);
                            lrecPostedRebateEntrySummary.SetRange("Rebate Code", lrecPostedRebateEntry."Rebate Code");
                            lrecPostedRebateEntrySummary.CalcSums("Amount (LCY)", "Amount (RBT)", "Amount (DOC)");

                            if (lrecPostedRebateEntrySummary."Amount (LCY)" <> 0) then begin
                                lrecPostedRebateEntryIns.Init;

                                lrecPostedRebateEntryIns.TransferFields(lrecPostedRebateEntry);

                                lintLineNo := lintLineNo + 1;
                                lrecPostedRebateEntryIns."Entry No." := lintLineNo;

                                lrecPostedRebateEntryIns.Validate("Amount (LCY)", -lrecPostedRebateEntrySummary."Amount (LCY)");
                                lrecPostedRebateEntryIns.Validate("Amount (RBT)", -lrecPostedRebateEntrySummary."Amount (RBT)");
                                lrecPostedRebateEntryIns.Validate("Amount (DOC)", -lrecPostedRebateEntrySummary."Amount (DOC)");

                                lrecPostedRebateEntryIns.Adjustment := true;
                                lrecPostedRebateEntryIns."Posted To G/L" := false;
                                lrecPostedRebateEntryIns."Paid-by Vendor" := false;

                                lrecPostedRebateEntryIns.Insert(true);
                            end;

                            //<ENRE1.00>
                            lrecPurchRebateHeader.Get(lrecPostedRebateEntry."Rebate Code");

                            lrecPostedSalesProfitModifierSummary.SetRange("Document Type", lrecPostedSalesProfitModifierSummary."Document Type"::Invoice);

                            lrecPostedSalesProfitModifierSummary.SetRange("Document No.", lrecPostedRebateEntry."Source No.");
                            lrecPostedSalesProfitModifierSummary.SetRange("Document Line No.", lrecPostedRebateEntry."Source Line No.");

                            lrecPostedSalesProfitModifierSummary.SetRange("Source Type", lrecPostedSalesProfitModifier."Source Type"::"Purchase Rebate");
                            lrecPostedSalesProfitModifierSummary.SetRange("Source No.", lrecPostedRebateEntry."Rebate Code");

                            lrecPostedSalesProfitModifierSummary.CalcSums("Amount (LCY)", Amount);

                            if lrecPostedSalesProfitModifierSummary."Amount (LCY)" <> 0 then begin

                                lrecPostedSalesProfitModifierToInsert.Init;

                                lrecPostedSalesProfitModifier.Copy(lrecPostedSalesProfitModifierSummary);
                                lrecPostedSalesProfitModifier.FindLast;

                                lrecPostedSalesProfitModifierToInsert.TransferFields(lrecPostedSalesProfitModifier);
                                lintPostedSalesProfitModifierEntryNo := lintPostedSalesProfitModifierEntryNo + 1;
                                lrecPostedSalesProfitModifierToInsert."Entry No." := lintPostedSalesProfitModifierEntryNo;

                                lrecPostedSalesProfitModifierToInsert.Validate("Amount (LCY)", -lrecPostedSalesProfitModifierSummary."Amount (LCY)");
                                lrecPostedSalesProfitModifierToInsert.Validate(Amount, -lrecPostedSalesProfitModifierSummary.Amount);

                                lrecPostedSalesProfitModifierToInsert.Insert;

                            end;
                            //</ENRE1.00>

                        end;

                        if not lrecTEMPAppliedRebateCodes.Get(lrecPostedRebateEntry."Rebate Code") then begin
                            lrecTEMPAppliedRebateCodes.Code := lrecPostedRebateEntry."Rebate Code";
                            lrecTEMPAppliedRebateCodes.Insert;
                        end;
                    until lrecPostedRebateEntry.Next = 0;
                end;
            until lrecTempInvLine.Next = 0;
        end;
    end;


    procedure UpdatePostedSalesCrMemos(ptxtDateFilter: Text[250])
    var
        lrecCrMemoLine: Record "Sales Cr.Memo Line";
        lrecTempCrMemoLine: Record "Sales Cr.Memo Line" temporary;
        lrecGLSetup: Record "General Ledger Setup";
        lrecTempRebate: Record "Rebate Entry ELA" temporary;
        lrecPostedRebateEntry: Record "Rebate Ledger Entry ELA";
        lrecRebateEntry: Record "Rebate Entry ELA";
        lrecPostedRebateEntryIns: Record "Rebate Ledger Entry ELA";
        lrecTempPostedRebateEntry: Record "Rebate Ledger Entry ELA" temporary;
        lrrfLine: RecordRef;
        ldtePostingDateToUse: Date;
        lintLineNo: Integer;
        ldecRebateTotalLCY: Decimal;
        ltxtFilterStr: Text[1024];
        lrecTEMPAppliedRebateCodes: Record "Purchase Rebate Header ELA" temporary;
        ldecAdjLCY: Decimal;
        ldecAdjRBT: Decimal;
        ldecAdjDOC: Decimal;
        lrecPostedRebateEntrySummary: Record "Rebate Ledger Entry ELA";
        lrecRebateHeader: Record "Purchase Rebate Header ELA";
    begin
        lrecGLSetup.Get;

        lrecGLSetup.TestField("Allow Posting From");
        lrecGLSetup.TestField("Allow Posting To");

        if ptxtDateFilter <> '' then
            lrecCrMemoLine.SetFilter("Posting Date", ptxtDateFilter);

        if lrecCrMemoLine.IsEmpty then
            exit;

        lrecTempCrMemoLine.Reset;
        lrecTempCrMemoLine.DeleteAll;

        //-- Store all credit memo lines to be processed in a temp table for increased performance
        if lrecCrMemoLine.FindSet then begin
            repeat
                if (lrecCrMemoLine.Type = lrecCrMemoLine.Type::Item) or (lrecCrMemoLine."Ref. Item No. ELA" <> '') then begin
                    if lrecCrMemoLine.Quantity <> 0 then begin
                        lrecTempCrMemoLine.Init;
                        lrecTempCrMemoLine.TransferFields(lrecCrMemoLine);
                        lrecTempCrMemoLine.Insert;
                    end;
                end;
            until lrecCrMemoLine.Next = 0;
        end;

        gintTotal := lrecTempCrMemoLine.Count;
        gintCount := 0;

        lrecPostedRebateEntryIns.SetCurrentKey("Entry No.");

        if lrecPostedRebateEntryIns.FindLast then begin
            lintLineNo := lrecPostedRebateEntryIns."Entry No.";
        end else begin
            lintLineNo := 0;
        end;

        if lrecTempCrMemoLine.FindSet then begin
            repeat
                gintCount += 1;

                if GuiAllowed then
                    gdlgWindow.Update(3, Round(gintCount / gintTotal) * 10000);

                Clear(ldtePostingDateToUse);

                if (lrecTempCrMemoLine."Posting Date" >= lrecGLSetup."Allow Posting From") and
                   (lrecTempCrMemoLine."Posting Date" <= lrecGLSetup."Allow Posting To") then
                    ldtePostingDateToUse := lrecTempCrMemoLine."Posting Date"
                else
                    ldtePostingDateToUse := lrecGLSetup."Allow Posting From";

                lrecTEMPAppliedRebateCodes.Reset;
                lrecTEMPAppliedRebateCodes.DeleteAll;

                // 1. - CALCULATE
                // calculate the rebates that apply to this line
                lrecTempRebate.Reset;
                lrecTempRebate.DeleteAll;

                //-- Filter the "real" table to pass into the rebate calculation routine
                lrecCrMemoLine.Reset;
                lrecCrMemoLine.SetRange("Document No.", lrecTempCrMemoLine."Document No.");
                lrecCrMemoLine.SetRange("Line No.", lrecTempCrMemoLine."Line No.");
                lrecCrMemoLine.FindFirst;

                lrrfLine.GetTable(lrecCrMemoLine);
                lrrfLine.SetView(lrecCrMemoLine.GetView);

                gcduPurchRebateMgt.SetRebateFilter("Purchase Rebate Header");
                gcduPurchRebateMgt.SetSalesBasedRebateMode(true);
                gcduPurchRebateMgt.CalcRebate(lrrfLine, true, lrecTempRebate);

                lrecTempRebate.Reset;

                // 3. - filter on the rebates that have already been accrued for this line
                lrecPostedRebateEntry.Reset;
                lrecPostedRebateEntry.SetCurrentKey("Functional Area", "Source Type", "Source No.",
                  "Source Line No.", "Rebate Code");
                lrecPostedRebateEntry.SetRange("Functional Area", lrecPostedRebateEntry."Functional Area"::Purchase);
                lrecPostedRebateEntry.SetRange("Source Type", lrecPostedRebateEntry."Source Type"::"Posted Cr. Memo");
                lrecPostedRebateEntry.SetRange("Source No.", lrecTempCrMemoLine."Document No.");
                lrecPostedRebateEntry.SetRange("Source Line No.", lrecTempCrMemoLine."Line No.");

                // 4. - COMPARE, ADJUST BALANCES AND CREATE NEW ENTRIES
                // for each calculated rebate line, make adjustments vs accrued entries if necessary
                if lrecTempRebate.FindSet then begin
                    repeat
                        if lrecRebateHeader.Get(lrecPostedRebateEntry."Rebate Code") then begin
                            if not lrecRebateHeader.Blocked then begin
                                lrecPostedRebateEntry.SetRange("Rebate Code", lrecTempRebate."Rebate Code");
                                lrecPostedRebateEntry.CalcSums("Amount (LCY)", "Amount (RBT)", "Amount (DOC)");

                                if lrecPostedRebateEntry."Amount (LCY)" <> lrecTempRebate."Amount (LCY)" then begin
                                    ldecAdjLCY := lrecTempRebate."Amount (LCY)" - lrecPostedRebateEntry."Amount (LCY)";
                                    ldecAdjRBT := lrecTempRebate."Amount (RBT)" - lrecPostedRebateEntry."Amount (RBT)";
                                    ldecAdjDOC := lrecTempRebate."Amount (DOC)" - lrecPostedRebateEntry."Amount (DOC)";

                                    lrecPostedRebateEntryIns.Init;
                                    lrecPostedRebateEntryIns.TransferFields(lrecTempRebate);

                                    lintLineNo := lintLineNo + 1;
                                    lrecPostedRebateEntryIns."Entry No." := lintLineNo;

                                    lrecPostedRebateEntryIns.Adjustment := lrecPostedRebateEntry.FindFirst;
                                    lrecPostedRebateEntryIns.Validate("Amount (LCY)", ldecAdjLCY);
                                    lrecPostedRebateEntryIns.Validate("Amount (RBT)", ldecAdjRBT);
                                    lrecPostedRebateEntryIns.Validate("Amount (DOC)", ldecAdjDOC);

                                    lrecPostedRebateEntryIns."Posted To G/L" := false;
                                    lrecPostedRebateEntryIns."Paid-by Vendor" := false;
                                    lrecPostedRebateEntryIns.Insert(true);
                                end;

                                if not lrecTEMPAppliedRebateCodes.Get(lrecTempRebate."Rebate Code") then begin
                                    lrecTEMPAppliedRebateCodes.Code := lrecTempRebate."Rebate Code";
                                    lrecTEMPAppliedRebateCodes.Insert;
                                end;
                            end;
                        end;
                    until lrecTempRebate.Next = 0;
                end;

                // 5. - REVERSE CANCELLED REBATES
                // check the posted rebate lines to confirm that they are still valid
                lrecPostedRebateEntry.SetRange("Rebate Code");

                if lrecPostedRebateEntry.FindSet then begin
                    repeat
                        if (not lrecTEMPAppliedRebateCodes.Get(lrecPostedRebateEntry."Rebate Code"))
                        and grecTEMPEligibleRebates.Get(lrecPostedRebateEntry."Rebate Code") then begin
                            lrecPostedRebateEntrySummary.Copy(lrecPostedRebateEntry);
                            lrecPostedRebateEntrySummary.SetRange("Rebate Code", lrecPostedRebateEntry."Rebate Code");
                            lrecPostedRebateEntrySummary.CalcSums("Amount (LCY)", "Amount (RBT)", "Amount (DOC)");

                            if (lrecPostedRebateEntrySummary."Amount (LCY)" <> 0) then begin
                                lrecPostedRebateEntryIns.Init;
                                lrecPostedRebateEntryIns.TransferFields(lrecPostedRebateEntry);

                                lintLineNo := lintLineNo + 1;
                                lrecPostedRebateEntryIns."Entry No." := lintLineNo;

                                lrecPostedRebateEntryIns.Validate("Amount (LCY)", -lrecPostedRebateEntrySummary."Amount (LCY)");
                                lrecPostedRebateEntryIns.Validate("Amount (RBT)", -lrecPostedRebateEntrySummary."Amount (RBT)");
                                lrecPostedRebateEntryIns.Validate("Amount (DOC)", -lrecPostedRebateEntrySummary."Amount (DOC)");

                                lrecPostedRebateEntryIns.Adjustment := true;
                                lrecPostedRebateEntryIns."Posted To G/L" := false;
                                lrecPostedRebateEntryIns."Paid-by Vendor" := false;

                                lrecPostedRebateEntryIns.Insert(true);
                            end;
                        end;

                        if not lrecTEMPAppliedRebateCodes.Get(lrecPostedRebateEntry."Rebate Code") then begin
                            lrecTEMPAppliedRebateCodes.Code := lrecPostedRebateEntry."Rebate Code";
                            lrecTEMPAppliedRebateCodes.Insert;
                        end;
                    until lrecPostedRebateEntry.Next = 0;
                end;
            until lrecTempCrMemoLine.Next = 0;
        end;
    end;


    procedure UpdateSalesOrders()
    var
        lrecSalesHeader: Record "Sales Header";
        lrecSalesHeader2: Record "Sales Header";
        lrecRebateDetail: Record "Rebate Line ELA";
        lrrfHeader: RecordRef;
    begin
        lrecSalesHeader.Reset;

        lrecSalesHeader.SetRange("Document Type", lrecSalesHeader."Document Type"::Order);
        lrecSalesHeader.SetRange("No.");

        gintTotal := lrecSalesHeader.Count;
        gintCount := 0;

        if lrecSalesHeader.FindSet then begin
            repeat
                gintCount += 1;

                if GuiAllowed then
                    gdlgWindow.Update(4, Round(gintCount / gintTotal) * 10000);

                lrecSalesHeader2.SetRange("Document Type", lrecSalesHeader."Document Type");
                lrecSalesHeader2.SetRange("No.", lrecSalesHeader."No.");
                lrecSalesHeader2.FindFirst;

                lrrfHeader.GetTable(lrecSalesHeader2);
                lrrfHeader.SetView(lrecSalesHeader2.GetView);

                gcduPurchRebateMgt.SetRebateFilter("Purchase Rebate Header");
                gcduPurchRebateMgt.CalcSalesBasedPurchRebate(lrrfHeader, false, false);
            until lrecSalesHeader.Next = 0;
        end;
    end;


    procedure UpdateSalesReturnOrders()
    var
        lrecSalesHeader: Record "Sales Header";
        lrecSalesHeader2: Record "Sales Header";
        lrecRebateDetail: Record "Rebate Line ELA";
        lrrfHeader: RecordRef;
    begin
        lrecSalesHeader.Reset;

        lrecSalesHeader.SetRange("Document Type", lrecSalesHeader."Document Type"::"Return Order");
        lrecSalesHeader.SetRange("No.");

        gintTotal := lrecSalesHeader.Count;
        gintCount := 0;

        if lrecSalesHeader.FindSet then begin
            repeat
                gintCount += 1;

                if GuiAllowed then
                    gdlgWindow.Update(5, Round(gintCount / gintTotal) * 10000);

                lrecSalesHeader2.SetRange("Document Type", lrecSalesHeader."Document Type");
                lrecSalesHeader2.SetRange("No.", lrecSalesHeader."No.");
                lrecSalesHeader2.FindFirst;

                lrrfHeader.GetTable(lrecSalesHeader2);
                lrrfHeader.SetView(lrecSalesHeader2.GetView);

                gcduPurchRebateMgt.SetRebateFilter("Purchase Rebate Header");
                gcduPurchRebateMgt.CalcSalesBasedPurchRebate(lrrfHeader, false, false);
            until lrecSalesHeader.Next = 0;
        end;
    end;


    procedure UpdateSalesCrMemos()
    var
        lrecSalesHeader: Record "Sales Header";
        lrecSalesHeader2: Record "Sales Header";
        lrecRebateDetail: Record "Rebate Line ELA";
        lrrfHeader: RecordRef;
    begin
        lrecSalesHeader.Reset;

        lrecSalesHeader.SetRange("Document Type", lrecSalesHeader."Document Type"::"Credit Memo");
        lrecSalesHeader.SetRange("No.");

        gintTotal := lrecSalesHeader.Count;
        gintCount := 0;

        if lrecSalesHeader.FindSet then begin
            repeat
                gintCount += 1;

                if GuiAllowed then
                    gdlgWindow.Update(6, Round(gintCount / gintTotal) * 10000);

                lrecSalesHeader2.SetRange("Document Type", lrecSalesHeader."Document Type");
                lrecSalesHeader2.SetRange("No.", lrecSalesHeader."No.");
                lrecSalesHeader2.FindFirst;

                lrrfHeader.GetTable(lrecSalesHeader2);
                lrrfHeader.SetView(lrecSalesHeader2.GetView);

                gcduPurchRebateMgt.SetRebateFilter("Purchase Rebate Header");
                gcduPurchRebateMgt.CalcSalesBasedPurchRebate(lrrfHeader, false, false);
            until lrecSalesHeader.Next = 0;
        end;
    end;


    procedure UpdateSalesInvoices()
    var
        lrecSalesHeader: Record "Sales Header";
        lrecSalesHeader2: Record "Sales Header";
        lrecRebateDetail: Record "Rebate Line ELA";
        lrrfHeader: RecordRef;
    begin
        lrecSalesHeader.Reset;

        lrecSalesHeader.SetRange("Document Type", lrecSalesHeader."Document Type"::Invoice);
        lrecSalesHeader.SetRange("No.");

        gintTotal := lrecSalesHeader.Count;
        gintCount := 0;

        if lrecSalesHeader.FindSet then begin
            repeat
                gintCount += 1;

                if GuiAllowed then
                    gdlgWindow.Update(7, Round(gintCount / gintTotal) * 10000);

                lrecSalesHeader2.SetRange("Document Type", lrecSalesHeader."Document Type");
                lrecSalesHeader2.SetRange("No.", lrecSalesHeader."No.");
                lrecSalesHeader2.FindFirst;

                lrrfHeader.GetTable(lrecSalesHeader2);
                lrrfHeader.SetView(lrecSalesHeader2.GetView);

                gcduPurchRebateMgt.SetRebateFilter("Purchase Rebate Header");
                gcduPurchRebateMgt.CalcSalesBasedPurchRebate(lrrfHeader, false, false);
            until lrecSalesHeader.Next = 0;
        end;
    end;
}

