report 14229408 "Post Purchase Rebates ELA"
{

    // 
    // ENRE1.00 2021-08-26 AJ
    //    - New Report
    // 
    // 
    //    - Modified Function
    //              - CreatePurchJnlLine
    // 
    // 
    //    - replace "Rebate Type"::"Guaranteed Cost Deal" with ::"Sales-Based" option
    //   - increased ltxtDescription to 50
    Caption = 'Post Purchase Rebates';
    ApplicationArea = All;
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

            trigger OnAfterGetRecord()
            var
                ltext000: Label 'Accruing Rebates   @1@@@@@@@@@@@@@@';
                lrecVendor: Record Vendor;
                lrecPurchRebateHeader: Record "Purchase Rebate Header ELA";
                lblnIsBlocked: Boolean;
            begin
                grecPostedRebateEntry.SetCurrentKey("Rebate Code", "Posting Date", "Posted To G/L", "Paid-by Vendor", "Rebate Type");
                if not gblnForceFilter then begin
                    grecPostedRebateEntry.Reset;

                    if grecRebateLedgerFilter.GetFilters <> '' then
                        grecPostedRebateEntry.CopyFilters(grecRebateLedgerFilter);
                end;
                grecPostedRebateEntry.SetRange("Functional Area", grecPostedRebateEntry."Functional Area"::Purchase);
                if gcodSourceNoFilter <> '' then
                    grecPostedRebateEntry.SetRange("Source No.", gcodSourceNoFilter);

                grecPostedRebateEntry.SetRange("Posted To G/L", false);
                grecPostedRebateEntry.SetRange("Paid-by Vendor");

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

                        lblnIsBlocked := false;

                        if not lblnIsBlocked then begin
                            if grecPostedRebateEntry."Amount (LCY)" <> 0 then begin
                                if grecPurchSetup."Use Src Doc No For Doc Rbt ELA" then begin
                                    if grecPostedRebateEntry."Rebate Type" in [grecPostedRebateEntry."Rebate Type"::"Off-Invoice",
                                                                               grecPostedRebateEntry."Rebate Type"::"Sales-Based", //<ENRE1.00/>
                                                                               grecPostedRebateEntry."Rebate Type"::Everyday] then begin
                                        grecPostedRebateEntry.Validate("Rebate Document No.", grecPostedRebateEntry."Source No.");
                                    end else begin
                                        grecPostedRebateEntry.Validate("Rebate Document No.", gcodDocNo);
                                    end;
                                end else begin
                                    grecPostedRebateEntry.Validate("Rebate Document No.", gcodDocNo);
                                end;

                                CreatePurchJnlLine(grecPostedRebateEntry);

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
                if goptPostCalculateAction = goptPostCalculateAction::"Post Generated Journal Lines" then begin
                    if (gintFirstLineNo <> 0) and (gintLastLineNo <> 0) then begin
                        grecGenJrnlLine.Reset;
                        grecGenJrnlLine.SetRange("Journal Template Name", gcodGenTemplateName);
                        grecGenJrnlLine.SetRange("Journal Batch Name", gcodGenBatchName);
                        grecGenJrnlLine.SetRange("Line No.", gintFirstLineNo, gintLastLineNo);
                        if grecGenJrnlLine.FindSet(true) then
                            gcduGenPostBatch.Run(grecGenJrnlLine);
                    end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                grecPurchSetup.Get;
                grecPurchSetup.TestField("Rbt Refund Jnl. Template ELA");
                grecPurchSetup.TestField("Rbt Refund Journal Batch ELA");
                grecPurchSetup.TestField("Rebate Nos.");
                grecPurchSetup.TestField("Rebate Document Nos. ELA");
                gcodGenTemplateName := grecPurchSetup."Rbt Refund Jnl. Template ELA";
                gcodGenBatchName := grecPurchSetup."Rbt Refund Journal Batch ELA";
                grecGenJrnlLine.Reset;
                grecGenJrnlLine.SetRange("Journal Template Name", gcodGenTemplateName);
                grecGenJrnlLine.SetRange("Journal Batch Name", gcodGenBatchName);
                grecGenJrnlLine.SetFilter("Account No.", '<>%1', '');
                if grecGenJrnlLine.FindFirst then
                    Error(gText000, gcodGenTemplateName, gcodGenBatchName);
                grecGenJrnlBatch.Get(gcodGenTemplateName, gcodGenBatchName);
                gcodDocNo := gcduNoSeriesMgt.GetNextNo(grecPurchSetup."Rebate Document Nos. ELA", WorkDate, true);
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
        grecPurchSetup: Record "Purchases & Payables Setup";
        grecGLSetup: Record "General Ledger Setup";
        grecPostedRebateEntry: Record "Rebate Ledger Entry ELA";
        grecGenJrnlLine: Record "Gen. Journal Line";
        grecPurchRebateHeader: Record "Purchase Rebate Header ELA";
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


    procedure CreatePurchJnlLine(var precPostedRebateEntry: Record "Rebate Ledger Entry ELA")
    var
        lrecDefaultDim: Record "Default Dimension";
        lrecCurrency: Record Currency;
        lrecVendLedgEntry: Record "Vendor Ledger Entry";
        ldtePostingDate: Date;
        lcodVendorNo: Code[20];
        lcodAccountNo: Code[20];
        ltxtDescription: Text[100];
        lcodBuyFromVendor: Code[20];
        lcodShipTo: Code[10];
        lrecPurchInvLine: Record "Purch. Inv. Line";
        lrecPurchCrMemoLine: Record "Purch. Cr. Memo Line";
        lrecPurchRcptLine: Record "Purch. Rcpt. Line";
        lrecPostedICAPurch: Record "Post. Item Chg Asgn Purch ELA";
        lrecItemCharge: Record "Item Charge";
        lrecTempDimBuf: Record "Dimension Buffer" temporary;
        lrecTempDimSetEntry: Record "Dimension Set Entry" temporary;
        lcduDimMgmt: Codeunit DimensionManagement;
    begin
        lrecCurrency.InitRoundingPrecision;

        if Round(-(precPostedRebateEntry."Amount (LCY)"), lrecCurrency."Amount Rounding Precision") = 0 then
            exit;

        grecPurchSetup.Get;
        grecGLSetup.Get;
        grecSourceCodeSetup.Get;
        grecPurchRebateHeader.Get(precPostedRebateEntry."Rebate Code");
        grecPurchRebateHeader.TestField(Blocked, false);

        if not gbolFirst then begin
            gintLineNo := gintLineNo + 1;
            gintLastLineNo := gintLineNo;
        end else begin
            grecGenJrnlLine.Reset;
            grecGenJrnlLine.SetRange("Journal Template Name", gcodGenTemplateName);
            grecGenJrnlLine.SetRange("Journal Batch Name", gcodGenBatchName);
            if grecGenJrnlLine.FindLast then
                gintLineNo := grecGenJrnlLine."Line No." + 1
            else
                gintLineNo := 1;
            gintFirstLineNo := gintLineNo;
            gintLastLineNo := gintLineNo;
            gbolFirst := false;
        end;

        ltxtDescription := grecPurchRebateHeader.Description;

        precPostedRebateEntry.TestField("Post-to Vendor No.");

        lcodVendorNo := precPostedRebateEntry."Post-to Vendor No.";
        lcodBuyFromVendor := precPostedRebateEntry."Buy-from Vendor No.";
        lcodShipTo := precPostedRebateEntry."Order Address Code";
        ldtePostingDate := precPostedRebateEntry."Posting Date";

        grecGenJrnlLine.Init;

        grecGenJrnlLine.Validate("Journal Template Name", gcodGenTemplateName);
        grecGenJrnlLine.Validate("Journal Batch Name", gcodGenBatchName);
        grecGenJrnlLine.Validate("Line No.", gintLineNo);
        grecGenJrnlLine."System-Created Entry" := true;
        grecGenJrnlLine.Validate("Posting Date", ldtePostingDate);
        grecGenJrnlLine.Validate("Document No.", precPostedRebateEntry."Rebate Document No.");
        grecGenJrnlLine.Validate("Rebate Source No. ELA", precPostedRebateEntry."Post-to Vendor No.");
        grecPurchRebateHeader.TestField("Credit G/L Account No.");

        if grecPurchRebateHeader."Post to Sub-Ledger" = grecPurchRebateHeader."Post to Sub-Ledger"::Post then begin
            grecGenJrnlLine.Validate("Account Type", grecGenJrnlLine."Account Type"::"G/L Account");
            grecGenJrnlLine.Validate("Account No.", grecPurchRebateHeader."Credit G/L Account No.");
            grecGenJrnlLine.Validate("Bal. Account Type", grecGenJrnlLine."Bal. Account Type"::Vendor);
            grecGenJrnlLine.Validate("Bal. Account No.", lcodVendorNo);
        end else begin
            grecPurchRebateHeader.TestField("Offset G/L Account No.");
            grecGenJrnlLine.Validate("Account Type", grecGenJrnlLine."Account Type"::"G/L Account");
            grecGenJrnlLine.Validate("Account No.", grecPurchRebateHeader."Credit G/L Account No.");
            grecGenJrnlLine.Validate("Bal. Account Type", grecGenJrnlLine."Bal. Account Type"::"G/L Account");
            grecGenJrnlLine.Validate("Bal. Account No.", grecPurchRebateHeader."Offset G/L Account No.");
        end;

        grecGenJrnlLine.Description := ltxtDescription;

        grecGenJrnlLine.Validate("Rebate Code ELA", precPostedRebateEntry."Rebate Code");
        grecGenJrnlLine.Validate("Rebate Source Type ELA", precPostedRebateEntry."Source Type");
        grecGenJrnlLine.Validate("Rebate Source No. ELA", precPostedRebateEntry."Source No.");
        grecGenJrnlLine.Validate("Rebate Source Line No. ELA", precPostedRebateEntry."Source Line No.");
        grecGenJrnlLine.Validate("Rebate Document No. ELA", precPostedRebateEntry."Rebate Document No.");
        grecGenJrnlLine.Validate("Posted Rebate Entry No. ELA", precPostedRebateEntry."Entry No.");
        grecGenJrnlLine.Validate("Rebate Vendor No. ELA", precPostedRebateEntry."Buy-from Vendor No.");
        grecGenJrnlLine.Validate("Rebate Item No. ELA", precPostedRebateEntry."Item No.");

        grecGenJrnlLine."Source Code" := grecSourceCodeSetup.Purchases;

        if grecPurchSetup."Auto-Apply Rebates on Post ELA" then begin
            lrecVendLedgEntry.Reset;
            lrecVendLedgEntry.SetCurrentKey("Document No.", "Document Type", "Vendor No.");

            if (grecPurchRebateHeader."Post to Sub-Ledger" = grecPurchRebateHeader."Post to Sub-Ledger"::Post) and
               (grecPurchRebateHeader."Rebate Type" <> grecPurchRebateHeader."Rebate Type"::"Sales-Based") then begin
                case precPostedRebateEntry."Source Type" of
                    precPostedRebateEntry."Source Type"::"Posted Invoice":
                        if precPostedRebateEntry."Amount (LCY)" > 0 then begin
                            lrecVendLedgEntry.SetRange("Document No.", precPostedRebateEntry."Source No.");
                            lrecVendLedgEntry.SetRange("Document Type", grecGenJrnlLine."Applies-to Doc. Type"::Invoice);
                            lrecVendLedgEntry.SetRange("Vendor No.", grecGenJrnlLine."Account No.");
                            lrecVendLedgEntry.SetRange("Vendor No.", grecGenJrnlLine."Bal. Account No.");
                            lrecVendLedgEntry.SetRange(Open, true);
                            if lrecVendLedgEntry.FindFirst then begin
                                grecGenJrnlLine."Applies-to Doc. Type" := grecGenJrnlLine."Applies-to Doc. Type"::Invoice;
                                grecGenJrnlLine.Validate("Applies-to Doc. No.", precPostedRebateEntry."Source No.");
                            end;
                        end;
                    precPostedRebateEntry."Source Type"::"Posted Cr. Memo":
                        if precPostedRebateEntry."Amount (LCY)" < 0 then begin
                            lrecVendLedgEntry.SetRange("Document No.", precPostedRebateEntry."Source No.");
                            lrecVendLedgEntry.SetRange("Document Type", grecGenJrnlLine."Applies-to Doc. Type"::"Credit Memo");
                            lrecVendLedgEntry.SetRange("Vendor No.", grecGenJrnlLine."Bal. Account No.");
                            lrecVendLedgEntry.SetRange(Open, true);
                            if lrecVendLedgEntry.FindFirst then begin
                                grecGenJrnlLine."Applies-to Doc. Type" := grecGenJrnlLine."Applies-to Doc. Type"::"Credit Memo";
                                grecGenJrnlLine.Validate("Applies-to Doc. No.", precPostedRebateEntry."Source No.");
                            end;
                        end;
                end;
            end;
        end;

        grecGenJrnlLine.Validate("Bill-to/Pay-to No.", lcodVendorNo);
        grecGenJrnlLine."Ship-to/Order Address Code" := lcodShipTo;
        grecGenJrnlLine.Validate("Sell-to/Buy-from No.", lcodBuyFromVendor);

        if precPostedRebateEntry."Amount (DOC)" = 0 then begin
            grecGenJrnlLine.Validate("Currency Code", '');
            grecGenJrnlLine.Validate(Amount, -1 * precPostedRebateEntry."Amount (LCY)");
        end else begin
            grecGenJrnlLine.Validate("Currency Code", precPostedRebateEntry."Currency Code (DOC)");
            grecGenJrnlLine.Validate(Amount, -1 * precPostedRebateEntry."Amount (DOC)");
        end;

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

        if precPostedRebateEntry."Rebate Type" = precPostedRebateEntry."Rebate Type"::"Sales-Based" then begin
            lrecDefaultDim.SetRange("Table ID", DATABASE::Vendor);
            lrecDefaultDim.SetRange("No.", lcodVendorNo);

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
        end else begin
            case precPostedRebateEntry."Source Type" of
                precPostedRebateEntry."Source Type"::"Posted Invoice":
                    begin
                        //-- Get dimensions from posted sales invoice line
                        lrecPurchInvLine.Get(precPostedRebateEntry."Source No.", precPostedRebateEntry."Source Line No.");
                        lcduDimMgmt.GetDimensionSet(lrecTempDimSetEntry, lrecPurchInvLine."Dimension Set ID");

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
                        lrecPurchCrMemoLine.Get(precPostedRebateEntry."Source No.", precPostedRebateEntry."Source Line No.");

                        if (lrecPurchCrMemoLine.Type = lrecPurchCrMemoLine.Type::"Charge (Item)") then begin
                            lrecItemCharge.Get(lrecPurchCrMemoLine."No.");
                            if lrecItemCharge."Inherit Dim From Assgnt ELA" then begin
                                lrecPostedICAPurch.SetRange("Document Type", lrecPostedICAPurch."Document Type"::"Posted Purchase Cr.Memo");
                                lrecPostedICAPurch.SetRange("Document No.", precPostedRebateEntry."Source No.");
                                lrecPostedICAPurch.SetRange("Document Line No.", precPostedRebateEntry."Source Line No.");
                                if lrecPostedICAPurch.FindSet then begin
                                    repeat
                                        case lrecPostedICAPurch."Applies-to Doc. Type" of
                                            lrecPostedICAPurch."Applies-to Doc. Type"::Receipt:
                                                begin
                                                    lrecPurchRcptLine.Get(lrecPostedICAPurch."Applies-to Doc. No.", lrecPostedICAPurch."Applies-to Doc. Line No.");
                                                    lcduDimMgmt.GetDimensionSet(lrecTempDimSetEntry, lrecPurchRcptLine."Dimension Set ID");

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
                                    until lrecPostedICAPurch.Next = 0;
                                end;
                            end;
                        end else begin
                            lcduDimMgmt.GetDimensionSet(lrecTempDimSetEntry, lrecPurchCrMemoLine."Dimension Set ID");

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
                precPostedRebateEntry."Source Type"::Vendor:
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


    procedure SetRebateLedgerFilters(ptxtDateFilter: Text[250]; var precRebateFilter: Record "Purchase Rebate Header ELA"; pcodSourceNoFilter: Code[20])
    begin
        gtxtDateFilter := ptxtDateFilter;

        grecRebateLedgerFilter.Reset;

        if precRebateFilter.GetFilter(Code) <> '' then
            precRebateFilter.CopyFilter(Code, grecRebateLedgerFilter."Rebate Code");

        if precRebateFilter.GetFilter("Rebate Type") <> '' then
            precRebateFilter.CopyFilter("Rebate Type", grecRebateLedgerFilter."Rebate Type");

        gcodSourceNoFilter := pcodSourceNoFilter;
    end;


    procedure SetPostOption(poptPostCalculateAction: Option "Post Generated Journal Lines","Do Not Post Generated Journal Lines")
    begin
        goptPostCalculateAction := poptPostCalculateAction;
    end;
}

