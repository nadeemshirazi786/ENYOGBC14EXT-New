report 14229409 "Post Rebates ELA"
{
    // 
    // ENRE1.00 2021-08-26 AJ
    //   - Created to Post Sales Jnl Line based on Posted Rebate Entry
    // 
    // 
    //    - Post to Customer only if the A/R Sub-Ledger Usage is set to Post on Rebate card.
    //              Otherwise, post to Rebate Expense Account and balance to the Offset GL Account
    // 
    //    - Change line number increment from 10000 to 1 to keep line number within the integer range
    // 
    // 
    // 
    //     - negative adjustments to a rebate don't try to "apply to" invoice
    //     - positive adjustments to a rebate don't try to "apply to" credit memo
    // 
    // 
    //    - add flag to alloow generated journal lines to remain in the journal for manual posting
    // 
    // 
    //    - Modified function CreateSalesJnlLine to have credit memo charges item that cretae rebates inherit
    //              dimensions form related shipments
    // 
    // 
    //    - Modified function CreateSalesJnlLine to populate "Currency Code"  on general journal line
    // 
    // 
    //   - Check Job Source code setups
    //   - Added functionaility to copy job fields on the sales journal for rebates related to promotional jobs
    // 
    // 
    //    - handle blocked rebates
    // 
    // 
    //    - fix an issue where rebates that do not post to the customer ledger are posting "backwards"
    // 
    // 
    //    - code to accrue commodity rebates
    //   - set userequestpageto no
    //   - Increased ltxtDescription from 30 to 50
    //   - New Event
    Caption = 'Post Rebates';
    ApplicationArea = All;
    ProcessingOnly = true;
    UsageCategory = Tasks;
    UseRequestPage = false;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

            trigger OnAfterGetRecord()
            var
                ltext000: Label 'Accruing Rebates   @1@@@@@@@@@@@@@@';
                lrecCustomer: Record Customer;
                lrecRebateHeader: Record "Rebate Header ELA";
                lblnIsBlocked: Boolean;
            begin
                grecPostedRebateEntry.SetCurrentKey("Rebate Code", "Posting Date", "Posted To G/L", "Paid to Customer", "Rebate Type");

                if not gblnForceFilter then begin
                    grecPostedRebateEntry.Reset;

                    if grecRebateLedgerFilter.GetFilters <> '' then
                        grecPostedRebateEntry.CopyFilters(grecRebateLedgerFilter);
                end;

                if gcodSourceNoFilter <> '' then
                    grecPostedRebateEntry.SetRange("Source No.", gcodSourceNoFilter);

                grecPostedRebateEntry.SetRange("Posted To G/L", false);
                grecPostedRebateEntry.SetRange("Paid to Customer");

                if gtxtDateFilter <> '' then
                    grecPostedRebateEntry.SetFilter("Posting Date", gtxtDateFilter)
                else
                    grecPostedRebateEntry.SetRange("Posting Date");

                if GuiAllowed then
                    gdlgWindow.Open(ltext000);

                if grecPostedRebateEntry.FindSet(true) then begin
                    gintCount := grecPostedRebateEntry.Count;
                    gintCounter := 0;

                    repeat
                        gintCounter += 1;

                        if GuiAllowed then
                            gdlgWindow.Update(1, Round(gintCounter / gintCount) * 10000);

                        //-- Skip blocked customers
                        lblnIsBlocked := false;

                        if lrecCustomer.Get(grecPostedRebateEntry."Post-to Customer No.") then
                            lblnIsBlocked := lrecCustomer.Blocked > lrecCustomer.Blocked::Ship;

                        //<ENRE1.00>
                        if not lblnIsBlocked then begin
                            if lrecRebateHeader.Get(grecPostedRebateEntry."Rebate Code") then
                                lblnIsBlocked := lrecRebateHeader.Blocked;
                        end;
                        //</ENRE1.00>

                        if not lblnIsBlocked then begin
                            if grecPostedRebateEntry."Amount (LCY)" <> 0 then begin
                                //Create Sales Jnl Line
                                if grecSalesSetup."Use Src DocNo For Doc Rbt ELA" then begin
                                    //<ENRE1.00>
                                    if grecPostedRebateEntry."Rebate Type" in [grecPostedRebateEntry."Rebate Type"::"Off-Invoice",
                                                                               grecPostedRebateEntry."Rebate Type"::Everyday,
                                                                               grecPostedRebateEntry."Rebate Type"::Commodity]
                                                                               then begin
                                        //</ENRE1.00>
                                        grecPostedRebateEntry.Validate("Rebate Document No.", grecPostedRebateEntry."Source No.");
                                    end else begin
                                        grecPostedRebateEntry.Validate("Rebate Document No.", gcodDocNo);
                                    end;
                                end else begin
                                    grecPostedRebateEntry.Validate("Rebate Document No.", gcodDocNo);
                                end;

                                CreateSalesJnlLine(grecPostedRebateEntry);

                                grecPostedRebateEntry.Modify;
                            end;
                        end;
                    until grecPostedRebateEntry.Next = 0;
                end;

                if GuiAllowed then
                    gdlgWindow.Close;
            end;

            trigger OnPostDataItem()
            begin
                //<ENRE1.00>
                if goptPostCalculateAction = goptPostCalculateAction::"Post Generated Journal Lines" then begin
                    //</ENRE1.00>
                    if (gintFirstLineNo <> 0) and (gintLastLineNo <> 0) then begin
                        grecGenJrnlLine.Reset;

                        grecGenJrnlLine.SetRange("Journal Template Name", gcodGenTemplateName);
                        grecGenJrnlLine.SetRange("Journal Batch Name", gcodGenBatchName);
                        grecGenJrnlLine.SetRange("Line No.", gintFirstLineNo, gintLastLineNo);

                        if grecGenJrnlLine.FindSet(true) then
                            gcduGenPostBatch.Run(grecGenJrnlLine);
                    end;
                    //<ENRE1.00>
                end;
                //</ENRE1.00>
            end;

            trigger OnPreDataItem()
            begin
                grecSalesSetup.Get;
                grecSalesSetup.TestField("Rebate Batch Name ELA");
                grecSalesSetup.TestField("Rebate Nos. ELA");
                grecSalesSetup.TestField("Rebate Document Nos. ELA");

                gcodGenTemplateName := 'SALES';
                gcodGenBatchName := grecSalesSetup."Rebate Batch Name ELA";

                grecGenJrnlLine.Reset;
                grecGenJrnlLine.SetRange("Journal Template Name", gcodGenTemplateName);
                grecGenJrnlLine.SetRange("Journal Batch Name", gcodGenBatchName);
                grecGenJrnlLine.SetFilter("Account No.", '<>%1', '');

                if grecGenJrnlLine.FindFirst then
                    Error(gText000, gcodGenTemplateName, gcodGenBatchName);

                grecGenJrnlBatch.Get(gcodGenTemplateName, gcodGenBatchName);

                gcodDocNo := gcduNoSeriesMgt.GetNextNo(grecSalesSetup."Rebate Document Nos. ELA", WorkDate, true);

                gbolFirst := true;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(goptPostCalculateAction; goptPostCalculateAction)
                    {
                        ApplicationArea = All;
                        Caption = 'Post Action';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        grecSalesSetup: Record "Sales & Receivables Setup";
        grecGLSetup: Record "General Ledger Setup";
        grecPostedRebateEntry: Record "Rebate Ledger Entry ELA";
        grecGenJrnlLine: Record "Gen. Journal Line";
        grecRebateHeader: Record "Rebate Header ELA";
        grecGenJrnlBatch: Record "Gen. Journal Batch";
        grecSourceCodeSetup: Record "Source Code Setup";
        gcodGenTemplateName: Code[20];
        gcodGenBatchName: Code[20];
        gbolFirst: Boolean;
        gintLineNo: Integer;
        gcduNoSeriesMgt: Codeunit NoSeriesManagement;
        gcduGenPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        gcduGenPostLine: Codeunit "Gen. Jnl.-Post Line";
        gcodDocNo: Code[20];
        gcduSale: Integer;
        gText000: Label 'Please post/delete existing entries in Journal Template %1, Batch %2';
        gintFirstLineNo: Integer;
        gintLastLineNo: Integer;
        gblnForceFilter: Boolean;
        gtxtDateFilter: Text[250];
        grecRebateLedgerFilter: Record "Rebate Ledger Entry ELA";
        gdlgWindow: Dialog;
        gintCount: Integer;
        gintCounter: Integer;
        gcodSourceNoFilter: Code[20];
        goptPostCalculateAction: Option "Post Generated Journal Lines","Do Not Post Generated Journal Lines";


    procedure CreateSalesJnlLine(var precPostedRebateEntry: Record "Rebate Ledger Entry ELA")
    var
        lrecDefaultDim: Record "Default Dimension";
        lrecCurrency: Record Currency;
        lrecCustLedgEntry: Record "Cust. Ledger Entry";
        ldtePostingDate: Date;
        lcodCustomerNo: Code[20];
        lcodAccountNo: Code[20];
        ltxtDescription: Text[100];
        lcodSellToCustomer: Code[20];
        lcodShipTo: Code[10];
        lrecSalesInvLine: Record "Sales Invoice Line";
        lrecSalesCrMemoLine: Record "Sales Cr.Memo Line";
        lrecSalesShipLine: Record "Sales Shipment Line";
        lrecPostedICASales: Record "Posted Item Chg Asgn Sales ELA";
        lrecItemCharge: Record "Item Charge";
        lrecTempDimBuf: Record "Dimension Buffer" temporary;
        lrecTempDimSetEntry: Record "Dimension Set Entry" temporary;
        lcduDimMgmt: Codeunit DimensionManagement;
    begin
        lrecCurrency.InitRoundingPrecision;

        if Round(-(precPostedRebateEntry."Amount (LCY)"), lrecCurrency."Amount Rounding Precision") = 0 then
            exit;

        grecSalesSetup.Get;
        grecGLSetup.Get;
        grecSourceCodeSetup.Get;

        grecRebateHeader.Get(precPostedRebateEntry."Rebate Code");

        //<ENRE1.00>
        grecRebateHeader.TestField(Blocked, false);
        //</ENRE1.00>

        if not gbolFirst then begin
            gintLineNo := gintLineNo + 1;
            gintLastLineNo := gintLineNo;
        end else begin
            grecGenJrnlLine.Reset;

            grecGenJrnlLine.SetRange("Journal Template Name", gcodGenTemplateName);
            grecGenJrnlLine.SetRange("Journal Batch Name", gcodGenBatchName);

            //-- increment by 1 since we can generate a lot (!!!) of entries here
            if grecGenJrnlLine.FindLast then
                gintLineNo := grecGenJrnlLine."Line No." + 1
            else
                gintLineNo := 1;

            gintFirstLineNo := gintLineNo;
            gintLastLineNo := gintLineNo;

            gbolFirst := false;
        end;

        ltxtDescription := grecRebateHeader.Description;

        precPostedRebateEntry.TestField("Post-to Customer No.");

        lcodCustomerNo := precPostedRebateEntry."Post-to Customer No.";
        lcodSellToCustomer := precPostedRebateEntry."Sell-to Customer No.";
        lcodShipTo := precPostedRebateEntry."Ship-to Code";

        //-- This allows us to use a different Posting Date than the source document (eg. adjustments)
        ldtePostingDate := precPostedRebateEntry."Posting Date";

        grecGenJrnlLine.Init;

        //<ENRE1.00>
        rdOnAfterInitlGenJrnlLine(grecGenJrnlLine);
        //</ENRE1.00>

        grecGenJrnlLine.Validate("Journal Template Name", gcodGenTemplateName);
        grecGenJrnlLine.Validate("Journal Batch Name", gcodGenBatchName);
        grecGenJrnlLine.Validate("Line No.", gintLineNo);

        //-- Avoid having to turn on Direct Posting to GL Account
        grecGenJrnlLine."System-Created Entry" := true;

        grecGenJrnlLine.Validate("Posting Date", ldtePostingDate);

        grecGenJrnlLine.Validate("Document No.", precPostedRebateEntry."Rebate Document No.");

        grecRebateHeader.TestField("Expense G/L Account No.");

        if grecRebateHeader."Post to Sub-Ledger" = grecRebateHeader."Post to Sub-Ledger"::Post then begin
            //<ENRE1.00>
            grecGenJrnlLine.Validate("Account Type", grecGenJrnlLine."Account Type"::"G/L Account");
            grecGenJrnlLine.Validate("Account No.", grecRebateHeader."Expense G/L Account No.");

            grecGenJrnlLine.Validate("Bal. Account Type", grecGenJrnlLine."Bal. Account Type"::Customer);
            grecGenJrnlLine.Validate("Bal. Account No.", lcodCustomerNo);
            //</ENRE1.00>
        end else begin
            grecRebateHeader.TestField("Offset G/L Account No.");

            //<ENRE1.00>
            grecGenJrnlLine.Validate("Account Type", grecGenJrnlLine."Account Type"::"G/L Account");
            grecGenJrnlLine.Validate("Account No.", grecRebateHeader."Expense G/L Account No.");
            grecGenJrnlLine.Validate("Bal. Account Type", grecGenJrnlLine."Bal. Account Type"::"G/L Account");
            grecGenJrnlLine.Validate("Bal. Account No.", grecRebateHeader."Offset G/L Account No.");
            //</ENRE1.00>
        end;

        grecGenJrnlLine.Description := ltxtDescription;

        grecGenJrnlLine.Validate("Rebate Code ELA", precPostedRebateEntry."Rebate Code");
        grecGenJrnlLine.Validate("Rebate Source Type ELA", precPostedRebateEntry."Source Type");
        grecGenJrnlLine.Validate("Rebate Source No. ELA", precPostedRebateEntry."Source No.");
        grecGenJrnlLine.Validate("Rebate Source Line No. ELA", precPostedRebateEntry."Source Line No.");
        grecGenJrnlLine.Validate("Rebate Document No. ELA", precPostedRebateEntry."Rebate Document No.");
        grecGenJrnlLine.Validate("Posted Rebate Entry No. ELA", precPostedRebateEntry."Entry No.");

        //<ENRE1.00>
        grecGenJrnlLine.Validate("Rebate Accrual Customer No.", precPostedRebateEntry."Post-to Customer No.");
        grecGenJrnlLine.Validate("Rebate Customer No. ELA", precPostedRebateEntry."Sell-to Customer No.");
        grecGenJrnlLine.Validate("Rebate Item No. ELA", precPostedRebateEntry."Item No.");
        //</ENRE1.00>

        grecGenJrnlLine."Source Code" := grecSourceCodeSetup.Sales;

        if grecSalesSetup."Auto-Apply Rebates on Post ELA" then begin
            lrecCustLedgEntry.Reset;
            lrecCustLedgEntry.SetCurrentKey("Document No.", "Document Type", "Customer No.");

            if grecRebateHeader."Post to Sub-Ledger" = grecRebateHeader."Post to Sub-Ledger"::Post then begin
                case precPostedRebateEntry."Source Type" of
                    precPostedRebateEntry."Source Type"::"Posted Invoice":
                        if precPostedRebateEntry."Amount (LCY)" > 0 then begin
                            lrecCustLedgEntry.SetRange("Document No.", precPostedRebateEntry."Source No.");
                            lrecCustLedgEntry.SetRange("Document Type", grecGenJrnlLine."Applies-to Doc. Type"::Invoice);

                            //<ENRE1.00>
                            lrecCustLedgEntry.SetRange("Customer No.", grecGenJrnlLine."Bal. Account No.");
                            //</ENRE1.00>

                            lrecCustLedgEntry.SetRange(Open, true);

                            if lrecCustLedgEntry.FindFirst then begin
                                grecGenJrnlLine."Applies-to Doc. Type" := grecGenJrnlLine."Applies-to Doc. Type"::Invoice;
                                grecGenJrnlLine.Validate("Applies-to Doc. No.", precPostedRebateEntry."Source No.");
                            end;
                        end;
                    precPostedRebateEntry."Source Type"::"Posted Cr. Memo":
                        if precPostedRebateEntry."Amount (LCY)" < 0 then begin
                            lrecCustLedgEntry.SetRange("Document No.", precPostedRebateEntry."Source No.");
                            lrecCustLedgEntry.SetRange("Document Type", grecGenJrnlLine."Applies-to Doc. Type"::"Credit Memo");

                            //<ENRE1.00>
                            lrecCustLedgEntry.SetRange("Customer No.", grecGenJrnlLine."Bal. Account No.");
                            //</ENRE1.00>

                            lrecCustLedgEntry.SetRange(Open, true);

                            if lrecCustLedgEntry.FindFirst then begin
                                grecGenJrnlLine."Applies-to Doc. Type" := grecGenJrnlLine."Applies-to Doc. Type"::"Credit Memo";
                                grecGenJrnlLine.Validate("Applies-to Doc. No.", precPostedRebateEntry."Source No.");
                            end;
                        end;
                end;
            end;
        end;

        grecGenJrnlLine.Validate("Bill-to/Pay-to No.", lcodCustomerNo);
        grecGenJrnlLine."Ship-to/Order Address Code" := lcodShipTo;
        grecGenJrnlLine.Validate("Sell-to/Buy-from No.", lcodSellToCustomer);

        if precPostedRebateEntry."Amount (DOC)" = 0 then begin
            grecGenJrnlLine.Validate("Currency Code", '');  //-- use LCY

            //<ENRE1.00>
            grecGenJrnlLine.Validate(Amount, precPostedRebateEntry."Amount (LCY)");
            //</ENRE1.00>
        end else begin
            //-- Post in document currency (eg. customer's currency)
            //<ENRE1.00>
            grecGenJrnlLine.Validate("Currency Code", precPostedRebateEntry."Currency Code (DOC)");
            //</ENRE1.00>

            //<ENRE1.00>
            grecGenJrnlLine.Validate(Amount, precPostedRebateEntry."Amount (DOC)");
            //</ENRE1.00>
        end;

        //<ENRE1.00>
        if ((precPostedRebateEntry."Job No." <> '') and
           (grecRebateHeader."Post to Sub-Ledger" = grecRebateHeader."Post to Sub-Ledger"::Post)) then begin

            grecGenJrnlLine."System-Created Entry" := false;

            if grecSourceCodeSetup.Get then begin
                grecSourceCodeSetup.TestField("Job G/L Journal");
                grecSourceCodeSetup.TestField("Job G/L WIP");
            end;

            grecGenJrnlLine.Validate(grecGenJrnlLine."Job No.", precPostedRebateEntry."Job No.");
            if precPostedRebateEntry."Job Task No." <> '' then
                grecGenJrnlLine.Validate(grecGenJrnlLine."Job Task No.", precPostedRebateEntry."Job Task No.");
            grecGenJrnlLine.Validate("Job Quantity", 1);
        end;
        //</ENRE1.00>

        //-- Handle Dimensions --
        //-- the dimensions for this entry will be a combination of the applied posted document dimensions and the dimensions generated form the journal line itself
        //-- the journal line will have priority otherwise posting may fail
        lrecTempDimBuf.Reset;
        lrecTempDimBuf.DeleteAll;

        //-- Get journal line dimensions
        lcduDimMgmt.GetDimensionSet(lrecTempDimSetEntry, grecGenJrnlLine."Dimension Set ID");

        if lrecTempDimSetEntry.FindSet then begin
            repeat
                lrecTempDimBuf.Init;

                lrecTempDimBuf."Table ID" := DATABASE::"Gen. Journal Line";
                lrecTempDimBuf."Entry No." := 0;
                lrecTempDimBuf."Dimension Code" := lrecTempDimSetEntry."Dimension Code";
                lrecTempDimBuf."Dimension Value Code" := lrecTempDimSetEntry."Dimension Value Code";
                lrecTempDimBuf."New Dimension Value Code" := '';
                lrecTempDimBuf."Line No." := 0;
                lrecTempDimBuf."No. Of Dimensions" := 0;

                lrecTempDimBuf.Insert;
            until lrecTempDimSetEntry.Next = 0;
        end;

        case precPostedRebateEntry."Source Type" of
            precPostedRebateEntry."Source Type"::"Posted Invoice":
                begin
                    //-- Get dimensions from posted sales invoice line
                    lrecSalesInvLine.Get(precPostedRebateEntry."Source No.", precPostedRebateEntry."Source Line No.");
                    lcduDimMgmt.GetDimensionSet(lrecTempDimSetEntry, lrecSalesInvLine."Dimension Set ID");

                    if lrecTempDimSetEntry.FindSet then begin
                        repeat
                            lrecTempDimBuf.Init;

                            lrecTempDimBuf."Table ID" := DATABASE::"Gen. Journal Line";
                            lrecTempDimBuf."Entry No." := 0;
                            lrecTempDimBuf."Dimension Code" := lrecTempDimSetEntry."Dimension Code";
                            lrecTempDimBuf."Dimension Value Code" := lrecTempDimSetEntry."Dimension Value Code";
                            lrecTempDimBuf."New Dimension Value Code" := '';
                            lrecTempDimBuf."Line No." := 0;
                            lrecTempDimBuf."No. Of Dimensions" := 0;

                            if lrecTempDimBuf.Insert then;
                        until lrecTempDimSetEntry.Next = 0;
                    end;
                end;
            precPostedRebateEntry."Source Type"::"Posted Cr. Memo":
                begin
                    lrecSalesCrMemoLine.Get(precPostedRebateEntry."Source No.", precPostedRebateEntry."Source Line No.");

                    if (lrecSalesCrMemoLine.Type = lrecSalesCrMemoLine.Type::"Charge (Item)") and
                       (lrecSalesCrMemoLine."Ref. Item No. ELA" <> '') then begin
                        lrecItemCharge.Get(lrecSalesCrMemoLine."No.");
                        if lrecItemCharge."Inherit Dim From Assgnt ELA" then begin
                            lrecPostedICASales.SetRange("Document Type", lrecPostedICASales."Document Type"::"Posted Sales Cr. Memo");
                            lrecPostedICASales.SetRange("Document No.", precPostedRebateEntry."Source No.");
                            lrecPostedICASales.SetRange("Document Line No.", precPostedRebateEntry."Source Line No.");

                            if lrecPostedICASales.FindSet then begin
                                repeat
                                    case lrecPostedICASales."Applies-to Doc. Type" of
                                        lrecPostedICASales."Applies-to Doc. Type"::Shipment:
                                            begin
                                                lrecSalesShipLine.Get(lrecPostedICASales."Applies-to Doc. No.", lrecPostedICASales."Applies-to Doc. Line No.");
                                                lcduDimMgmt.GetDimensionSet(lrecTempDimSetEntry, lrecSalesShipLine."Dimension Set ID");

                                                if lrecTempDimSetEntry.FindSet then begin
                                                    repeat
                                                        lrecTempDimBuf.Init;

                                                        lrecTempDimBuf."Table ID" := DATABASE::"Gen. Journal Line";
                                                        lrecTempDimBuf."Entry No." := 0;
                                                        lrecTempDimBuf."Dimension Code" := lrecTempDimSetEntry."Dimension Code";
                                                        lrecTempDimBuf."Dimension Value Code" := lrecTempDimSetEntry."Dimension Value Code";
                                                        lrecTempDimBuf."New Dimension Value Code" := '';
                                                        lrecTempDimBuf."Line No." := 0;
                                                        lrecTempDimBuf."No. Of Dimensions" := 0;

                                                        if lrecTempDimBuf.Insert then;
                                                    until lrecTempDimSetEntry.Next = 0;
                                                end;
                                            end;
                                    end;
                                until lrecPostedICASales.Next = 0;
                            end;
                        end;
                    end else begin
                        lcduDimMgmt.GetDimensionSet(lrecTempDimSetEntry, lrecSalesCrMemoLine."Dimension Set ID");

                        if lrecTempDimSetEntry.FindSet then begin
                            repeat
                                lrecTempDimBuf.Init;

                                lrecTempDimBuf."Table ID" := DATABASE::"Gen. Journal Line";
                                lrecTempDimBuf."Entry No." := 0;
                                lrecTempDimBuf."Dimension Code" := lrecTempDimSetEntry."Dimension Code";
                                lrecTempDimBuf."Dimension Value Code" := lrecTempDimSetEntry."Dimension Value Code";
                                lrecTempDimBuf."New Dimension Value Code" := '';
                                lrecTempDimBuf."Line No." := 0;
                                lrecTempDimBuf."No. Of Dimensions" := 0;

                                if lrecTempDimBuf.Insert then;
                            until lrecTempDimSetEntry.Next = 0;
                        end;
                    end;
                end;
            precPostedRebateEntry."Source Type"::Customer:
                begin
                    //-- Add default item dimensions
                    lrecDefaultDim.SetRange("Table ID", DATABASE::Item);
                    lrecDefaultDim.SetRange("No.", precPostedRebateEntry."Item No.");

                    if lrecDefaultDim.FindSet then begin
                        repeat
                            lrecTempDimBuf.Init;

                            lrecTempDimBuf."Table ID" := DATABASE::"Gen. Journal Line";
                            lrecTempDimBuf."Entry No." := 0;
                            lrecTempDimBuf."Dimension Code" := lrecDefaultDim."Dimension Code";
                            lrecTempDimBuf."Dimension Value Code" := lrecDefaultDim."Dimension Value Code";
                            lrecTempDimBuf."New Dimension Value Code" := '';
                            lrecTempDimBuf."Line No." := 0;
                            lrecTempDimBuf."No. Of Dimensions" := 0;

                            if lrecTempDimBuf.Insert then;
                        until lrecDefaultDim.Next = 0;
                    end;
                end;
        end;

        //-- Update the dimension set ID based on the new combination of dimensions
        grecGenJrnlLine."Dimension Set ID" := lcduDimMgmt.CreateDimSetIDFromDimBuf(lrecTempDimBuf);

        //-- Update global dimension fields
        lcduDimMgmt.UpdateGlobalDimFromDimSetID(grecGenJrnlLine."Dimension Set ID",
          grecGenJrnlLine."Shortcut Dimension 1 Code", grecGenJrnlLine."Shortcut Dimension 2 Code");

        grecGenJrnlLine.Insert(true);
    end;


    procedure SetEntryFilter(var precRebateLedgerEntry: Record "Rebate Ledger Entry ELA")
    begin
        precRebateLedgerEntry.CopyFilter(precRebateLedgerEntry."Entry No.", grecPostedRebateEntry."Entry No.");
        gblnForceFilter := true;
    end;


    procedure SetRebateLedgerFilters(ptxtDateFilter: Text[250]; var precRebateFilter: Record "Rebate Header ELA"; pcodSourceNoFilter: Code[20])
    begin
        gtxtDateFilter := ptxtDateFilter;

        grecRebateLedgerFilter.Reset;

        if precRebateFilter.GetFilter(Code) <> '' then
            precRebateFilter.CopyFilter(Code, grecRebateLedgerFilter."Rebate Code");

        if precRebateFilter.GetFilter("Rebate Type") <> '' then
            precRebateFilter.CopyFilter("Rebate Type", grecRebateLedgerFilter."Rebate Type");

        gcodSourceNoFilter := pcodSourceNoFilter;
    end;

    procedure SetRebateLedgerFilters2(ptxtDateFilter: Text[250]; VAR precRebateFilter: Record "Purchase Rebate Header ELA"; pcodSourceNoFilter: Code[20])
    begin


        gtxtDateFilter := ptxtDateFilter;

        grecRebateLedgerFilter.RESET;

        IF precRebateFilter.GETFILTER(Code) <> '' THEN
            precRebateFilter.COPYFILTER(Code, grecRebateLedgerFilter."Rebate Code");

        IF precRebateFilter.GETFILTER("Rebate Type") <> '' THEN
            precRebateFilter.COPYFILTER("Rebate Type", grecRebateLedgerFilter."Rebate Type");

        gcodSourceNoFilter := pcodSourceNoFilter;
    end;


    procedure SetPostOption(poptPostCalculateAction: Option "Post Generated Journal Lines","Do Not Post Generated Journal Lines")
    begin
        goptPostCalculateAction := poptPostCalculateAction;
    end;

    [IntegrationEvent(false, false)]
    local procedure rdOnAfterInitlGenJrnlLine(var pGenJrnlLine: Record "Gen. Journal Line")
    begin
    end;
}

