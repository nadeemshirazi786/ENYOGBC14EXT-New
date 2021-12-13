report 14229413 "Rbt Analysis By Customer ELA"
{


    //ENRE1.00 2021-09-08 AJ
    Caption = 'Rebate Analysis By Customer';
    DefaultLayout = RDLC;
    RDLCLayout = './RebateAnalysisByCustomer.rdlc';

    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Customer Posting Group", "Currency Code", "Rebate Group Code ELA", "Rebate Code Filter ELA", "Date Filter";
            column(CompName; grecCompanyInfo.Name)
            {
            }
            column(gtxtFilterString; gtxtFilterString)
            {
            }
            column(No_Customer; Customer."No.")
            {
            }
            column(Name_Customer; Customer.Name)
            {
            }
            column(gdecCustTotalLCY; gdecCustTotalLCY)
            {
            }
            column(gdecRptTotalOpen; gdecRptTotalOpen)
            {
            }
            column(gdecRptTotalPending; gdecRptTotalPending)
            {
            }
            column(gdecRptTotalAccrued; gdecRptTotalAccrued)
            {
            }
            column(gdecRptTotalClosed; gdecRptTotalClosed)
            {
            }
            column(gdecRptTotal; gdecRptTotalOpen + gdecRptTotalPending + gdecRptTotalAccrued + gdecRptTotalClosed)
            {
            }
            column(Customer_No_; "No.")
            {
            }
            dataitem(OpenRebates; "Rebate Entry ELA")
            {
                DataItemLink = "Bill-To Customer No." = FIELD("No.");
                DataItemTableView = SORTING("Sell-to Customer No.", "Ship-To Code", "Rebate Code");
                column(SelltoCustomerNo_OpenRebates; OpenRebates."Sell-to Customer No.")
                {
                }
                column(SelltoCustomerName_OpenRebates; OpenRebates."Sell-to Customer Name")
                {
                }
                column(RebateCode_OpenRebates; OpenRebates."Rebate Code")
                {
                }
                column(RebateDescription_OpenRebates; OpenRebates."Rebate Description")
                {
                }
                column(FunctionalArea_OpenRebates; OpenRebates."Functional Area")
                {
                }
                column(SourceType_OpenRebates; OpenRebates."Source Type")
                {
                }
                column(SourceNo_OpenRebates; OpenRebates."Source No.")
                {
                }
                column(PostingDate_OpenRebates; OpenRebates."Posting Date")
                {
                }
                column(AmountLCY_OpenRebates; OpenRebates."Amount (LCY)")
                {
                }
                column(AmountDOC_OpenRebates; OpenRebates."Amount (DOC)")
                {
                }
                column(gcodDocCurrCode_OpenRebates; gcodDocCurrCode)
                {
                }

                trigger OnAfterGetRecord()
                var
                    lrecSalesHeader: Record "Sales Header";
                begin
                    if gblnShowOpen then begin
                        Clear(gcodDocCurrCode);

                        if lrecSalesHeader.Get(OpenRebates."Source Type", OpenRebates."Source No.") then begin
                            gcodDocCurrCode := lrecSalesHeader."Currency Code";
                            gdtePostingDate := lrecSalesHeader."Posting Date";

                            if gcodDocCurrCode = '' then begin
                                gcodDocCurrCode := grecGLSetup."LCY Code";
                            end;
                        end;

                        gdecCustTotalLCY += OpenRebates."Amount (LCY)";
                        gdecRptTotalOpen += OpenRebates."Amount (LCY)";

                        Clear(grecSellToCustomer);
                        if grecSellToCustomer.Get("Sell-to Customer No.") then;
                    end else begin
                        CurrReport.Skip;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    Customer.CopyFilter("Rebate Code Filter ELA", "Rebate Code");
                end;
            }
            dataitem(RegisteredRebates; "Rebate Ledger Entry ELA")
            {
                DataItemLink = "Bill-to Customer No." = FIELD("No.");
                DataItemTableView = SORTING("Sell-to Customer No.", "Ship-to Code", "Rebate Code") WHERE("Posted To G/L" = CONST(false));
                column(SelltoCustomerNo_RegisteredRebates; RegisteredRebates."Sell-to Customer No.")
                {
                }
                column(SelltoCustomerName_RegisteredRebates; RegisteredRebates."Sell-to Customer Name")
                {
                }
                column(RebateCode_RegisteredRebates; RegisteredRebates."Rebate Code")
                {
                }
                column(RebateDescription_RegisteredRebates; RegisteredRebates."Rebate Description")
                {
                }
                column(FunctionalArea_RegisteredRebates; RegisteredRebates."Functional Area")
                {
                }
                column(SourceType_RegisteredRebates; RegisteredRebates."Source Type")
                {
                }
                column(SourceNo_RegisteredRebates; RegisteredRebates."Source No.")
                {
                }
                column(PostingDate_RegisteredRebates; RegisteredRebates."Posting Date")
                {
                }
                column(AmountLCY_RegisteredRebates; RegisteredRebates."Amount (LCY)")
                {
                }
                column(AmountDOC_RegisteredRebates; RegisteredRebates."Amount (DOC)")
                {
                }
                column(gcodDocCurrCode_RegisteredRebates; gcodDocCurrCode)
                {
                }

                trigger OnAfterGetRecord()
                var
                    lrecSalesInvHeader: Record "Sales Invoice Header";
                    lrecSalesCrMemoHeader: Record "Sales Cr.Memo Header";
                begin
                    if gblnShowPending then begin
                        Clear(gcodDocCurrCode);

                        if "Source Type" = "Source Type"::"Posted Invoice" then begin
                            if lrecSalesInvHeader.Get("Source No.") then begin
                                gcodDocCurrCode := lrecSalesInvHeader."Currency Code";
                                gdtePostingDate := lrecSalesInvHeader."Posting Date";

                                if gcodDocCurrCode = '' then begin
                                    gcodDocCurrCode := grecGLSetup."LCY Code";
                                end;
                            end;
                        end else
                            if "Source Type" = "Source Type"::"Posted Cr. Memo" then begin
                                if lrecSalesCrMemoHeader.Get("Source No.") then begin
                                    gcodDocCurrCode := lrecSalesCrMemoHeader."Currency Code";
                                    gdtePostingDate := lrecSalesCrMemoHeader."Posting Date";

                                    if gcodDocCurrCode = '' then begin
                                        gcodDocCurrCode := grecGLSetup."LCY Code";
                                    end;
                                end;
                            end else
                                if "Source Type" = "Source Type"::"Credit Memo" then begin
                                end;

                        gdecCustTotalLCY += RegisteredRebates."Amount (LCY)";
                        gdecRptTotalPending += RegisteredRebates."Amount (LCY)";

                        Clear(grecSellToCustomer);
                        if grecSellToCustomer.Get("Sell-to Customer No.") then;
                    end else begin
                        CurrReport.Skip;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    Customer.CopyFilter("Rebate Code Filter ELA", "Rebate Code");
                    Customer.CopyFilter("Date Filter", "Posting Date");
                end;
            }
            dataitem(PostedRebates; "Rebate Ledger Entry ELA")
            {
                DataItemLink = "Bill-to Customer No." = FIELD("No.");
                DataItemTableView = SORTING("Sell-to Customer No.", "Ship-to Code", "Rebate Code") WHERE("Posted To G/L" = CONST(true), "Paid to Customer" = CONST(false));
                column(SelltoCustomerNo_PostedRebates; PostedRebates."Sell-to Customer No.")
                {
                }
                column(SelltoCustomerName_PostedRebates; PostedRebates."Sell-to Customer Name")
                {
                }
                column(RebateCode_PostedRebates; PostedRebates."Rebate Code")
                {
                }
                column(RebateDescription_PostedRebates; PostedRebates."Rebate Description")
                {
                }
                column(FunctionalArea_PostedRebates; PostedRebates."Functional Area")
                {
                }
                column(SourceType_PostedRebates; PostedRebates."Source Type")
                {
                }
                column(SourceNo_PostedRebates; PostedRebates."Source No.")
                {
                }
                column(PostingDate_PostedRebates; PostedRebates."Posting Date")
                {
                }
                column(AmountLCY_PostedRebates; PostedRebates."Amount (LCY)")
                {
                }
                column(AmountDOC_PostedRebates; PostedRebates."Amount (DOC)")
                {
                }
                column(gcodDocCurrCode_PostedRebates; gcodDocCurrCode)
                {
                }

                trigger OnAfterGetRecord()
                var
                    lrecSalesInvHeader: Record "Sales Invoice Header";
                    lrecSalesCrMemoHeader: Record "Sales Cr.Memo Header";
                begin
                    if gblnShowAccrued then begin
                        Clear(gcodDocCurrCode);

                        if "Source Type" = "Source Type"::"Posted Invoice" then begin
                            if lrecSalesInvHeader.Get("Source No.") then begin
                                gcodDocCurrCode := lrecSalesInvHeader."Currency Code";
                                gdtePostingDate := lrecSalesInvHeader."Posting Date";

                                if gcodDocCurrCode = '' then begin
                                    gcodDocCurrCode := grecGLSetup."LCY Code";
                                end;
                            end;
                        end else
                            if "Source Type" = "Source Type"::"Posted Cr. Memo" then begin
                                if lrecSalesCrMemoHeader.Get("Source No.") then begin
                                    gcodDocCurrCode := lrecSalesCrMemoHeader."Currency Code";
                                    gdtePostingDate := lrecSalesCrMemoHeader."Posting Date";

                                    if gcodDocCurrCode = '' then begin
                                        gcodDocCurrCode := grecGLSetup."LCY Code";
                                    end;
                                end;
                            end;

                        gdecCustTotalLCY += PostedRebates."Amount (LCY)";
                        gdecRptTotalAccrued += PostedRebates."Amount (LCY)";

                        Clear(grecSellToCustomer);
                        if grecSellToCustomer.Get("Sell-to Customer No.") then;
                    end else begin
                        CurrReport.Skip;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    Customer.CopyFilter("Rebate Code Filter ELA", "Rebate Code");
                    Customer.CopyFilter("Date Filter", "Posting Date");
                end;
            }
            dataitem(ClosedRebates; "Rebate Ledger Entry ELA")
            {
                DataItemLink = "Bill-to Customer No." = FIELD("No.");
                DataItemTableView = SORTING("Sell-to Customer No.", "Ship-to Code", "Rebate Code") WHERE("Paid to Customer" = CONST(true));
                column(SelltoCustomerNo_ClosedRebates; ClosedRebates."Sell-to Customer No.")
                {
                }
                column(SelltoCustomerName_ClosedRebates; ClosedRebates."Sell-to Customer Name")
                {
                }
                column(RebateCode_ClosedRebates; ClosedRebates."Rebate Code")
                {
                }
                column(RebateDescription_ClosedRebates; ClosedRebates."Rebate Description")
                {
                }
                column(FunctionalArea_ClosedRebates; ClosedRebates."Functional Area")
                {
                }
                column(SourceType_ClosedRebates; ClosedRebates."Source Type")
                {
                }
                column(SourceNo_ClosedRebates; ClosedRebates."Source No.")
                {
                }
                column(PostingDate_ClosedRebates; ClosedRebates."Posting Date")
                {
                }
                column(AmountLCY_ClosedRebates; ClosedRebates."Amount (LCY)")
                {
                }
                column(AmountDOC_ClosedRebates; ClosedRebates."Amount (DOC)")
                {
                }
                column(gcodDocCurrCode_ClosedRebates; gcodDocCurrCode)
                {
                }

                trigger OnAfterGetRecord()
                var
                    lrecSalesInvHeader: Record "Sales Invoice Header";
                    lrecSalesCrMemoHeader: Record "Sales Cr.Memo Header";
                begin
                    if gblnShowClosed then begin
                        Clear(gcodDocCurrCode);

                        if "Source Type" = "Source Type"::"Posted Invoice" then begin
                            if lrecSalesInvHeader.Get("Source No.") then begin
                                gcodDocCurrCode := lrecSalesInvHeader."Currency Code";
                                gdtePostingDate := lrecSalesInvHeader."Posting Date";

                                if gcodDocCurrCode = '' then begin
                                    gcodDocCurrCode := grecGLSetup."LCY Code";
                                end;
                            end;
                        end else
                            if "Source Type" = "Source Type"::"Posted Cr. Memo" then begin
                                if lrecSalesCrMemoHeader.Get("Source No.") then begin
                                    gcodDocCurrCode := lrecSalesCrMemoHeader."Currency Code";
                                    gdtePostingDate := lrecSalesCrMemoHeader."Posting Date";

                                    if gcodDocCurrCode = '' then begin
                                        gcodDocCurrCode := grecGLSetup."LCY Code";
                                    end;
                                end;
                            end;

                        gdecCustTotalLCY += ClosedRebates."Amount (LCY)";
                        gdecRptTotalClosed += ClosedRebates."Amount (LCY)";

                        Clear(grecSellToCustomer);
                        if grecSellToCustomer.Get("Sell-to Customer No.") then;
                    end else begin
                        CurrReport.Skip;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    Customer.CopyFilter("Rebate Code Filter ELA", "Rebate Code");
                    Customer.CopyFilter("Date Filter", "Posting Date");
                end;
            }

            trigger OnAfterGetRecord()
            var
                lrecRebateEntry: Record "Rebate Entry ELA";
                lrecPostedRebateEntry: Record "Rebate Ledger Entry ELA";
                lrecSalesHeader: Record "Sales Header";
                lrecSalesInvHeader: Record "Sales Invoice Header";
                lrecSalesCrMemoHeader: Record "Sales Cr.Memo Header";
            begin
                gdecCustTotalLCY := 0;
            end;

            trigger OnPreDataItem()
            begin
                grecGLSetup.Get;
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
                    group("Rebates to Show:")
                    {
                        Caption = 'Rebates to Show:';
                        field(gblnShowOpen; gblnShowOpen)
                        {
                            ApplicationArea = All;
                            Caption = 'Open';
                        }
                        field(gblnShowPending; gblnShowPending)
                        {
                            ApplicationArea = All;
                            Caption = 'Registered';
                        }
                        field(gblnShowAccrued; gblnShowAccrued)
                        {
                            ApplicationArea = All;
                            Caption = 'Posted';
                        }
                        field(gblnShowClosed; gblnShowClosed)
                        {
                            ApplicationArea = All;
                            Caption = 'Closed';
                        }
                    }
                    field(gblnNewPagePerCustomer; gblnNewPagePerCustomer)
                    {
                        ApplicationArea = All;
                        Caption = 'New Page Per Customer';
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
        Title = 'Rebate Analysis by Customer';
        SellTo = 'Sell-to Customer';
        FunctArea = 'Functional Area';
        DocType = 'Document Type';
        DocNo = 'Document No.';
        PostDate = 'PostingDate';
        Amount = 'Amount ($)';
        AmountDOC = 'Amount (DOC)';
        CurrencyDOC = 'Currency (DOC)';
        Open = 'Open';
        Registered = 'Registered';
        Posted = 'Posted';
        Closed = 'Closed';
        TotalFor = 'Total for';
        TotalOpen = 'Total Open';
        TotalPending = 'Total Pending';
        TotalAccrued = 'Total Accrued';
        TotalClosed = 'Total Closed';
        ReportSummary = 'Report Summary';
        Total = 'Total';
    }

    trigger OnPreReport()
    begin
        grecCompanyInfo.Get;
        gtxtFilterString := Customer.GetFilters;
    end;

    var
        grecCompanyInfo: Record "Company Information";
        gblnNewPagePerCustomer: Boolean;
        gcodDocCurrCode: Code[10];
        grecGLSetup: Record "General Ledger Setup";
        grecSellToCustomer: Record Customer;
        gdecCustTotalLCY: Decimal;
        gdtePostingDate: Date;
        gtxtFilterString: Text[250];
        gdecRptTotalOpen: Decimal;
        gdecRptTotalPending: Decimal;
        gdecRptTotalAccrued: Decimal;
        gdecRptTotalClosed: Decimal;
        gblnShowOpen: Boolean;
        gblnShowPending: Boolean;
        gblnShowAccrued: Boolean;
        gblnShowClosed: Boolean;
        Rebate_Analysis_by_CustomerCaptionLbl: Label 'Rebate Analysis by Customer';
        CurrReport_PAGENOCaptionLbl: Label 'Label1101769005';
        Currency__DOC_CaptionLbl: Label 'Currency (DOC)';
        Posting_DateCaptionLbl: Label 'Posting Date';
        Sell_to_CustomerCaptionLbl: Label 'Sell-to Customer';
        Report_SummaryCaptionLbl: Label 'Report Summary';
        OpenCaptionLbl: Label 'Open';
        RegisteredCaptionLbl: Label 'Registered';
        PostedCaptionLbl: Label 'Posted';
        ClosedCaptionLbl: Label 'Closed';
        TotalCaptionLbl: Label 'Total';
        OpenCaption_Control1101769007Lbl: Label 'Open';
        Total_OpenCaptionLbl: Label 'Total Open';
        RegisteredCaption_Control1101769010Lbl: Label 'Registered';
        Total_PendingCaptionLbl: Label 'Total Pending';
        PostedCaption_Control1101769013Lbl: Label 'Posted';
        Total_AccruedCaptionLbl: Label 'Total Accrued';
        ClosedCaption_Control1102631026Lbl: Label 'Closed';
        Total_ClosedCaptionLbl: Label 'Total Closed';
}

