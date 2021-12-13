report 14229401 "Calculate/Register Rebates ELA"
{
    // 
    // 
    // ENRE1.00 2021-08-26 AJ
    //   - Rebates
    // 
    // 
    //    - Post Rebate Type to the Rebate Ledger and Posted Rebate Ledger
    //            - Set filter on Rebate Type
    // 
    // 
    //   - fix posted invoice adjustment logic
    // 
    // 
    //    - handle blocked rebates
    // 
    // 
    //    - modified for commodity
    // 
    // 
    //    - bypass Sales-Based Purchase Rebates
    Caption = 'Calculate/Register Rebates';
    ApplicationArea = All;
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Rebate Header"; "Rebate Header ELA")
        {
            DataItemTableView = SORTING(Code);
            RequestFilterFields = "Code", "Rebate Category Code", "Rebate Type";

            trigger OnPreDataItem()
            var
                lrecRebate: Record "Rebate Header ELA";
            begin
                lrecRebate.CopyFilters("Rebate Header");

                //-- Check for lump sum rebates
                lrecRebate.SetRange("Rebate Type", "Rebate Type"::"Lump Sum");
                gblnProcessLumpSum := not lrecRebate.IsEmpty;

                //-- build a list of the rebates that are eligible for adjustment
                lrecRebate.SetFilter("Rebate Type", '%1|%2', lrecRebate."Rebate Type"::"Off-Invoice", lrecRebate."Rebate Type"::Everyday);

                if not lrecRebate.IsEmpty then begin
                    lrecRebate.FindSet;

                    repeat
                        grecTEMPEligibleRebates.TransferFields(lrecRebate);
                        grecTEMPEligibleRebates.Insert;
                    until lrecRebate.Next = 0;
                end;

                CurrReport.Break;
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

            trigger OnAfterGetRecord()
            var
                lrecSalesSetup: Record "Sales & Receivables Setup";
                lrecCustomer: Record Customer;
                ltxtDateFilter: Text[250];
                ldteStartDate: Date;
                ltext000: Label 'Processing...\';
                ltext001: Label 'Posted Sales Invoices        @2@@@@@@@@@@@@\';
                ltext002: Label 'Posted Sales Cr. Memos       @3@@@@@@@@@@@@\';
                ltext003: Label 'Open Sales Orders            @4@@@@@@@@@@@@\';
                ltext004: Label 'Open Sales Ret. Orders       @5@@@@@@@@@@@@\';
                ltext005: Label 'Open Sales Cr. Memos         @6@@@@@@@@@@@@\';
                ltext006: Label 'Open Sales Invoices          @7@@@@@@@@@@@@\\';
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

                lrecSalesSetup.Get;
                lrecSalesSetup.TestField("Rebate Calc. Date Formula ELA");

                if gdteAsOfDate = 0D then
                    gdteAsOfDate := WorkDate;

                //-- Make date filter
                if gdteStartDateOverride <> 0D then
                    ldteStartDate := gdteStartDateOverride
                else
                    ldteStartDate := CalcDate(lrecSalesSetup."Rebate Calc. Date Formula ELA", gdteAsOfDate);

                lrecCustomer.SetRange("Date Filter", ldteStartDate, gdteAsOfDate);
                ltxtDateFilter := lrecCustomer.GetFilter("Date Filter");

                //Check SalesJnl
                if gblnAccrueRebates then
                    CheckSalesJnl;


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

                //Update Sales Orders
                if gblnCalcOpenOrder then begin
                    UpdateSalesOrders;
                    Commit;
                end;

                //Update Return Orders
                if gblnCalcOpenRetOrder then begin
                    UpdateReturnOrders;
                    Commit;
                end;

                //Update Sales Cr. Memos
                if gblnCalcOpenCrMemo then begin
                    UpdateSalesCrMemos;
                    Commit;
                end;

                //Update Sales Invoices
                if gblnCalcOpenInvoice then begin
                    UpdateSalesInvoices;
                    Commit;
                end;

                //Calculate Lump Sum Rebates
                if gblnProcessLumpSum then begin
                    CalcLumpSumRebates;
                    Commit;
                end;

                //Create and Post Rebate to G/L from Posted Rebate Entry
                if gblnAccrueRebates then begin
                    if gblnForceFullAccrual then
                        ltxtDateFilter := '';

                    grptPostRebate.SetRebateLedgerFilters(ltxtDateFilter, "Rebate Header", '');
                    grptPostRebate.SetPostOption(goptPostCalculateAction);
                    grptPostRebate.UseRequestPage(false);
                    grptPostRebate.RunModal;
                end;
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
                        ToolTip = 'If TRUE, all unaccrued rebate entries up to and including the As of Date will be posted, regardless of the Rebate Periodic Date Formula in Sales && Receivables Setup.';
                    }
                    field(ctrlAccrualAction; goptPostCalculateAction)
                    {
                        ApplicationArea = All;
                        Caption = 'Post Action';
                        Editable = ctrlAccrualActionEditable;
                    }
                    group("Calculate Rebates For:")
                    {
                        Caption = 'Calculate Rebates For:';
                        field(gblnCalcOpenOrder; gblnCalcOpenOrder)
                        {
                            ApplicationArea = All;
                            Caption = 'Open Sales Orders';
                        }
                        field(gblnCalcOpenInvoice; gblnCalcOpenInvoice)
                        {
                            ApplicationArea = All;
                            Caption = 'Open Sales Invoices';
                        }
                        field(gblnCalcOpenCrMemo; gblnCalcOpenCrMemo)
                        {
                            ApplicationArea = All;
                            Caption = 'Open Sales Cr. Memos';
                        }
                        field(gblnCalcOpenRetOrder; gblnCalcOpenRetOrder)
                        {
                            ApplicationArea = All;
                            Caption = 'Open Sales Ret. Orders';
                        }
                    }
                    group("Register Rebates For:")
                    {
                        Caption = 'Register Rebates For:';
                        field(gblnCalcPostedInvoice; gblnCalcPostedInvoice)
                        {
                            ApplicationArea = All;
                            Caption = 'Posted Sales Invoices';
                        }
                        field(gblnCalcPostedCrMemo; gblnCalcPostedCrMemo)
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
        grecSalesSetup: Record "Sales & Receivables Setup";
        gdlgWindow: Dialog;
        gintTotal: Integer;
        gintCount: Integer;
        grptPostRebate: Report "Post Rebates ELA";
        gcduRebateMgt: Codeunit "Rebate Management ELA";
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
        grecTEMPEligibleRebates: Record "Rebate Header ELA" temporary;
        gdecTotalAdjustment: Decimal;
        gblnPrintReport: Boolean;
        goptPostCalculateAction: Option "Post Generated Journal Lines","Do Not Post Generated Journal Lines";
        gdteStartDateOverride: Date;
        [InDataSet]
        ctrlBypassDateFilterEditable: Boolean;
        [InDataSet]
        ctrlAccrualActionEditable: Boolean;


    procedure CheckSalesJnl()
    var
        lrecSalesSetup: Record "Sales & Receivables Setup";
        lrecGenJnlLine: Record "Gen. Journal Line";
        lcon0001: Label 'Sales Journal must be empty.';
    begin
        lrecSalesSetup.Get;
        lrecSalesSetup.TestField("Rebate Batch Name ELA");

        lrecGenJnlLine.Reset;
        lrecGenJnlLine.SetRange("Journal Template Name", 'SALES');
        lrecGenJnlLine.SetRange("Journal Batch Name", lrecSalesSetup."Rebate Batch Name ELA");
        lrecGenJnlLine.SetFilter("Account No.", '<>%1', '');

        if not lrecGenJnlLine.IsEmpty then begin
            Error(lcon0001)
        end;
    end;


    procedure UpdatePostedInvoices(ptxtDateFilter: Text[250])
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
        lrecTEMPAppliedRebateCodes: Record "Rebate Header ELA" temporary;
        lrecRebateHeader: Record "Rebate Header ELA";
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

                gcduRebateMgt.SetRebateFilter("Rebate Header");
                gcduRebateMgt.CalcRebate(lrrfLine, true, lrecTempRebate);

                lrecTempRebate.Reset;

                // 3. - filter on the rebates that have already been accrued for this line
                lrecPostedRebateEntry.Reset;
                lrecPostedRebateEntry.SetCurrentKey("Functional Area", "Source Type", "Source No.", "Source Line No.", "Rebate Code");
                lrecPostedRebateEntry.SetRange("Functional Area", lrecPostedRebateEntry."Functional Area"::Sales);
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

                                    lintLineNo += 1;
                                    lrecPostedRebateEntryIns."Entry No." := lintLineNo;

                                    lrecPostedRebateEntryIns.Adjustment := lrecPostedRebateEntry.FindFirst;

                                    lrecPostedRebateEntryIns.Validate("Amount (LCY)", ldecAdjLCY);
                                    lrecPostedRebateEntryIns.Validate("Amount (RBT)", ldecAdjRBT);
                                    lrecPostedRebateEntryIns.Validate("Amount (DOC)", ldecAdjDOC);

                                    lrecPostedRebateEntryIns."Posted To G/L" := false;
                                    lrecPostedRebateEntryIns."Paid to Customer" := false;

                                    //<ENRE1.00>
                                    if (lrecRebateHeader."Rebate Type" = lrecRebateHeader."Rebate Type"::Commodity) then begin
                                        if not lrecPostedRebateEntryIns.Adjustment then begin
                                            lrecPostedRebateEntryIns.Insert(true);
                                        end;
                                    end else begin
                                        lrecPostedRebateEntryIns.Insert(true);
                                    end;
                                    //</ENRE1.00>
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

                                lintLineNo += 1;
                                lrecPostedRebateEntryIns."Entry No." := lintLineNo;

                                lrecPostedRebateEntryIns.Validate("Amount (LCY)", -lrecPostedRebateEntrySummary."Amount (LCY)");
                                lrecPostedRebateEntryIns.Validate("Amount (RBT)", -lrecPostedRebateEntrySummary."Amount (RBT)");
                                lrecPostedRebateEntryIns.Validate("Amount (DOC)", -lrecPostedRebateEntrySummary."Amount (DOC)");

                                lrecPostedRebateEntryIns.Adjustment := true;
                                lrecPostedRebateEntryIns."Posted To G/L" := false;
                                lrecPostedRebateEntryIns."Paid to Customer" := false;

                                //<ENRE1.00>
                                if (lrecRebateHeader."Rebate Type" = lrecRebateHeader."Rebate Type"::Commodity) then begin
                                    if not lrecPostedRebateEntryIns.Adjustment then begin
                                        lrecPostedRebateEntryIns.Insert(true);
                                    end;
                                end else begin
                                    lrecPostedRebateEntryIns.Insert(true);
                                end;
                                //</ENRE1.00>
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
        lrecTEMPAppliedRebateCodes: Record "Rebate Header ELA" temporary;
        ldecAdjLCY: Decimal;
        ldecAdjRBT: Decimal;
        ldecAdjDOC: Decimal;
        lrecPostedRebateEntrySummary: Record "Rebate Ledger Entry ELA";
        lrecRebateHeader: Record "Rebate Header ELA";
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

                //-- determine which period to post any adjustments to
                if (lrecTempCrMemoLine."Posting Date" >= lrecGLSetup."Allow Posting From") and
                   (lrecTempCrMemoLine."Posting Date" <= lrecGLSetup."Allow Posting To") then
                    ldtePostingDateToUse := lrecTempCrMemoLine."Posting Date"
                else
                    ldtePostingDateToUse := lrecGLSetup."Allow Posting From";

                lrecTEMPAppliedRebateCodes.Reset;
                lrecTEMPAppliedRebateCodes.DeleteAll;
                Clear(lrecTEMPAppliedRebateCodes);

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

                gcduRebateMgt.SetRebateFilter("Rebate Header");
                gcduRebateMgt.CalcRebate(lrrfLine, true, lrecTempRebate);

                lrecTempRebate.Reset;

                // 3. - filter on the rebates that have already been accrued for this line
                lrecPostedRebateEntry.Reset;
                lrecPostedRebateEntry.SetCurrentKey("Functional Area", "Source Type", "Source No.", "Source Line No.", "Rebate Code");
                lrecPostedRebateEntry.SetRange("Functional Area", lrecPostedRebateEntry."Functional Area"::Sales);
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

                                    lintLineNo += 1;
                                    lrecPostedRebateEntryIns."Entry No." := lintLineNo;

                                    lrecPostedRebateEntryIns.Adjustment := lrecPostedRebateEntry.FindFirst;

                                    lrecPostedRebateEntryIns.Validate("Amount (LCY)", ldecAdjLCY);
                                    lrecPostedRebateEntryIns.Validate("Amount (RBT)", ldecAdjRBT);
                                    lrecPostedRebateEntryIns.Validate("Amount (DOC)", ldecAdjDOC);

                                    lrecPostedRebateEntryIns."Posted To G/L" := false;
                                    lrecPostedRebateEntryIns."Paid to Customer" := false;

                                    //<ENRE1.00>
                                    if (lrecRebateHeader."Rebate Type" = lrecRebateHeader."Rebate Type"::Commodity) then begin
                                        if not lrecPostedRebateEntryIns.Adjustment then begin
                                            lrecPostedRebateEntryIns.Insert(true);
                                        end;
                                    end else begin
                                        lrecPostedRebateEntryIns.Insert(true);
                                    end;
                                    //</ENRE1.00>
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

                            if lrecPostedRebateEntrySummary."Amount (LCY)" <> 0 then begin
                                lrecPostedRebateEntryIns.Reset;

                                lrecPostedRebateEntryIns.Init;
                                lrecPostedRebateEntryIns.TransferFields(lrecPostedRebateEntry);

                                lintLineNo += 1;
                                lrecPostedRebateEntryIns."Entry No." := lintLineNo;

                                lrecPostedRebateEntryIns.Validate("Amount (LCY)", -lrecPostedRebateEntrySummary."Amount (LCY)");
                                lrecPostedRebateEntryIns.Validate("Amount (RBT)", -lrecPostedRebateEntrySummary."Amount (RBT)");
                                lrecPostedRebateEntryIns.Validate("Amount (DOC)", -lrecPostedRebateEntrySummary."Amount (DOC)");

                                lrecPostedRebateEntryIns.Adjustment := true;
                                lrecPostedRebateEntryIns."Posted To G/L" := false;
                                lrecPostedRebateEntryIns."Paid to Customer" := false;

                                //<ENRE1.00>
                                if (lrecRebateHeader."Rebate Type" = lrecRebateHeader."Rebate Type"::Commodity) then begin
                                    if not lrecPostedRebateEntryIns.Adjustment then begin
                                        lrecPostedRebateEntryIns.Insert(true);
                                    end;
                                end else begin
                                    lrecPostedRebateEntryIns.Insert(true);
                                end;
                                //</ENRE1.00>
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

                gcduRebateMgt.SetRebateFilter("Rebate Header");

                //<ENRE1.00>
                gcduRebateMgt.BypassPurchRebates(true);
                //</ENRE1.00>

                gcduRebateMgt.CalcSalesDocRebate(lrrfHeader, false, false);

                //<ENRE1.00>
                gcduRebateMgt.BypassPurchRebates(false);
            //</ENRE1.00>
            until lrecSalesHeader.Next = 0;
        end;
    end;


    procedure UpdateReturnOrders()
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

                gcduRebateMgt.SetRebateFilter("Rebate Header");

                //<ENRE1.00>
                gcduRebateMgt.BypassPurchRebates(true);
                //</ENRE1.00>

                gcduRebateMgt.CalcSalesDocRebate(lrrfHeader, false, false);

                //<ENRE1.00>
                gcduRebateMgt.BypassPurchRebates(false);
            //</ENRE1.00>
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

                gcduRebateMgt.SetRebateFilter("Rebate Header");

                //<ENRE1.00>
                gcduRebateMgt.BypassPurchRebates(true);
                //</ENRE1.00>

                gcduRebateMgt.CalcSalesDocRebate(lrrfHeader, false, false);

                //<ENRE1.00>
                gcduRebateMgt.BypassPurchRebates(false);
            //</ENRE1.00>
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

                gcduRebateMgt.SetRebateFilter("Rebate Header");

                //<ENRE1.00>
                gcduRebateMgt.BypassPurchRebates(true);
                //</ENRE1.00>

                gcduRebateMgt.CalcSalesDocRebate(lrrfHeader, false, false);

                //<ENRE1.00>
                gcduRebateMgt.BypassPurchRebates(false);
            //</ENRE1.00>
            until lrecSalesHeader.Next = 0;
        end;
    end;


    procedure CalcLumpSumRebates()
    var
        lrecRebate: Record "Rebate Header ELA";
    begin
        lrecRebate.CopyFilters("Rebate Header");

        //-- Override some filters
        lrecRebate.SetRange("Rebate Type", lrecRebate."Rebate Type"::"Lump Sum");
        lrecRebate.SetFilter("Start Date", '<=%1', gdteAsOfDate);
        lrecRebate.SetRange("End Date");

        //<ENRE1.00>
        lrecRebate.SetRange(Blocked, false);
        //</ENRE1.00>

        if not lrecRebate.IsEmpty then begin
            lrecRebate.FindSet;

            gintTotal := lrecRebate.Count;
            gintCount := 0;

            repeat
                gintCount += 1;

                if GuiAllowed then
                    gdlgWindow.Update(8, Round(gintCount / gintTotal) * 10000);

                gcduRebateMgt.CalcLumpSumRebate(gdteAsOfDate, lrecRebate);
            until lrecRebate.Next = 0;
        end;
    end;


    procedure SetParameters(pdteAsOfDate: Date; pblnCalcOpenInvoice: Boolean; pblnCalcOpenOrder: Boolean; pblnCalcOpenCrMemo: Boolean; pblnCalcOpenRetOrder: Boolean; pblnCalcPostedInvoice: Boolean; pblnCalcPostedCrMemo: Boolean; pblnAccrueRebates: Boolean; pblnIgnoreAccrualDateCalc: Boolean; poptAccrualAction: Option Post,"Do Not Post"; var precRebateFilter: Record "Rebate Header ELA")
    begin
        //-- The following function can be used to pre-populate any of the request form options
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

        "Rebate Header".CopyFilters(precRebateFilter);
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
}

