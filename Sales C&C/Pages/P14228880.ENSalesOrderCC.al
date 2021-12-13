page 14228880 "EN Sales Order C&C Card"
{
    Caption = 'Sales Order Cash & Carry';
    ApplicationArea = All;
    UsageCategory = Documents;
    Editable = true;
    InsertAllowed = true;
    PageType = Document;
    PromotedActionCategories = 'New,Process Order,Report,Authorize,Cash Register Functions,Lookup';
    RefreshOnActivate = true;
    SourceTable = "Sales Header";
    SourceTableView = WHERE("Document Type" = FILTER(Order), "Cash & Carry ELA" = CONST(true));
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    Importance = Promoted;

                    trigger OnAssistEdit()
                    begin
                        /*IF AssistEdit(xRec) then
                            CurrPAGE.Update();TBR*/
                    end;
                }

                group(Customer)
                {
                    ShowCaption = false;
                    field("Sell-to Customer No."; "Sell-to Customer No.")
                    {
                        Caption = 'Customer No.';
                        ColumnSpan = 1;
                        Importance = Promoted;
                        //ShowCaption = false;

                        trigger OnValidate()
                        var
                            SalesSetup: Record "Sales & Receivables Setup";
                        begin
                            //SelltoCustomerNoOnAfterValidat;
                            SalesSetup.Get();
                            Validate("Ship-to Code", SalesSetup."Ship-to Code for CC ELA");
                            // Validate("Order Template Location ELA", "Ship-to Code");
                        end;
                    }
                    field("Sell-to Customer Name"; "Sell-to Customer Name")
                    {
                        Caption = 'Customer Name';
                        ColumnSpan = 1;
                        QuickEntry = false;
                        //ShowCaption = false;

                    }
                    field("Sell-to Address"; "Sell-to Address")
                    {
                        Caption = 'Street';
                        ColumnSpan = 3;
                        //ShowCaption = false;
                    }
                    field("Sell-to City"; "Sell-to City")
                    {
                        Caption = 'City';
                        ColumnSpan = 1;
                        QuickEntry = false;
                        //ShowCaption = false;
                    }
                    field("Sell-to County"; "Sell-to County")
                    {
                        Caption = 'State';
                        ColumnSpan = 1;
                        //ShowCaption = false;
                    }
                    field("Sell-to Post Code"; "Sell-to Post Code")
                    {
                        Caption = 'ZIP Code';
                        ColumnSpan = 1;
                        //ShowCaption = false;
                    }


                }


                group(Control23019024)
                {
                    ShowCaption = false;
                    field("Order Date"; "Order Date")
                    {
                        Importance = Promoted;
                        QuickEntry = false;
                    }
                    field("Payment Method Code"; "Payment Method Code")
                    {
                        Editable = false;
                    }
                    field("External Document No."; "External Document No.")
                    {
                        Importance = Promoted;
                    }
                    field("Shipment Method Code"; "Shipment Method Code")
                    {
                    }
                    field("Order Template Location"; "Order Template Location ELA")
                    {
                        Caption = 'Order Template Location';

                    }
                }
            }
            part(SalesLines; "EN Sales Order Sub C&C")
            {
                SubPageLink = "Document No." = FIELD("No.");
            }
            // group("Extended Fields")
            // {
            //     Caption = 'Extended Fields';
            //     grid(Control23019025)
            //     {
            //         GridLayout = Rows;
            //         ShowCaption = false;
            //         group(Application)
            //         {
            //             field("Applies-to Doc. Type"; "Applies-to Doc. Type")
            //             {
            //             }
            //             field("Applies-to Doc. No."; "Applies-to Doc. No.")
            //             {
            //             }
            //         }

            //     }
            // }
            // group("Sell-To")
            // {
            //     group(Address)
            //     {
            //         ShowCaption = false;
            //         field("Sell-to Address"; "Sell-to Address")
            //         {
            //             Caption = 'Street';
            //             ColumnSpan = 3;
            //             //ShowCaption = false;
            //         }
            //         field("Sell-to City"; "Sell-to City")
            //         {
            //             Caption = 'City';
            //             ColumnSpan = 1;
            //             QuickEntry = false;
            //             //ShowCaption = false;
            //         }
            //         field("Sell-to County"; "Sell-to County")
            //         {
            //             Caption = 'State';
            //             ColumnSpan = 1;
            //             //ShowCaption = false;
            //         }
            //         field("Sell-to Post Code"; "Sell-to Post Code")
            //         {
            //             Caption = 'ZIP Code';
            //             ColumnSpan = 1;
            //             //ShowCaption = false;
            //         }
            //     }
            //     group(Contact)
            //     {
            //         field("Sell-to Contact"; "Sell-to Contact")
            //         {
            //             Caption = 'Name';
            //             ColumnSpan = 2;
            //             //ShowCaption = false;
            //         }
            //         field("Your Reference"; "Your Reference")
            //         {
            //             Caption = 'Phone No.';
            //             ColumnSpan = 1;
            //             Editable = false;
            //             //ShowCaption = false;
            //         }
            //     }
            // }
            group("Extended Fields")
            {
                group("Shipping-To")
                {
                    ShowCaption = false;
                    field("Ship-to Code"; "Ship-to Code")
                    {
                        ColumnSpan = 1;
                        Importance = Promoted;
                        //ShowCaption = false;
                    }
                    field("Ship-to Name"; "Ship-to Name")
                    {
                        ColumnSpan = 2;
                        Enabled = false;
                        //ShowCaption = false;
                    }
                    field("Ship-to Address"; "Ship-to Address")
                    {
                        ColumnSpan = 3;
                        Editable = false;
                        //ShowCaption = false;
                    }
                    // field("Ship-to Address 2"; "Ship-to Address 2")
                    // {
                    //     ColumnSpan = 3;
                    //     Editable = false;
                    //     //ShowCaption = false;
                    // }
                    field("Ship-to City"; "Ship-to City")
                    {
                        ColumnSpan = 1;
                        Editable = false;
                        //ShowCaption = false;
                    }

                }

                group(Control23019030)
                {
                    ShowCaption = false;
                    field("Ship-to County"; "Ship-to County")
                    {
                        Caption = 'Ship-to State / ZIP Code';
                        ColumnSpan = 1;
                        Editable = false;
                        //ShowCaption = false;
                    }
                    field("Ship-to Post Code"; "Ship-to Post Code")
                    {
                        ColumnSpan = 1;
                        Editable = false;
                        Importance = Promoted;
                        //ShowCaption = false;
                    }
                    field("Shipment Date"; "Shipment Date")
                    {
                        Importance = Promoted;

                        trigger OnValidate()
                        begin

                            CurrPage.Update(true);
                        end;
                    }
                    field("Shipment Method Code 2"; "Shipment Method Code")
                    {
                    }
                    field("Shipping Agent Code"; "Shipping Agent Code")
                    {
                    }
                    field("Salesperson Code"; "Salesperson Code")
                    {
                    }
                }
            }


        }
        area(factboxes)
        {
            part(CnCOrderSummaryFactbox; "EN C&C Order Summary Factbox")
            {
                ShowFilter = false;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "No." = FIELD("No.");
            }
            systempart(Control1900383207; Links)
            {
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("O&rder")
            {
                Caption = 'O&rder';
                Image = "Order";
                action("New Order")
                {
                    Image = NewOrder;
                    Promoted = true;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                        CustNoForm: Page "EM Customer Number";
                        CustNo: Code[20];
                        lcodShipTo: Code[10];
                        lctxtInvalidCustomerOrShip: Label 'Invalid %1 and/or %2.';
                    begin

                        // CustNoForm.ShipToCodeRequired(true);
                        // if CustNoForm.RunModal = ACTION::Cancel then
                        //     exit;
                        // CustNo := CustNoForm.GetCustomerNo;

                        // lcodShipTo := CustNoForm.GetShipToCode;
                        // if (
                        //   (CustNo = '')
                        //   or (lcodShipTo = '')
                        // ) then begin

                        //     Error(lctxtInvalidCustomerOrShip, SalesHeader.FieldCaption("Sell-to Customer No."),
                        //                                        SalesHeader.FieldCaption("Ship-to Code"));
                        // end;

                        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                        SalesHeader.Insert(true);
                        //SalesHeader.Validate("Sell-to Customer No.", CustNo);
                        //SalesHeader.Validate("Ship-to Code", CustNoForm.GetShipToCode);
                        SalesHeader."Cash & Carry ELA" := true;
                        SalesHeader.Modify;
                        Rec := SalesHeader;


                    end;
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "Sales Comment Sheet";
                    RunPageLink = "Document Type" = FIELD("Document Type"),
                                  "No." = FIELD("No."),
                                  "Document Line No." = CONST(0);
                }
                action("Sales History - Sell-to")
                {
                    Caption = 'Sales History';
                    Image = History;
                    Promoted = true;
                    PromotedCategory = Category6;

                    trigger OnAction()
                    begin

                        lpagCustSalesHistory.SetToSalesHeader(Rec, false);
                        lpagCustSalesHistory.RunModal;
                    end;
                }
                action("Customer Balance to date")
                {
                    Caption = 'Customer Balance to date';
                    Image = Report2;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        CustBalToDateReport: Report "EN Customer - Balance to Date";
                    begin

                        Clear(CustBalToDateReport);
                        CustBalToDateReport.SetCustDate("Sell-to Customer No.", Today);
                        CustBalToDateReport.RunModal;
                        Clear(CustBalToDateReport);
                    end;
                }
                action("Sale Order")
                {
                    Caption = 'Sale Order';
                    Image = Report;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    Ellipsis = true;
                    trigger OnAction()
                    begin
                        PrintBarcode(Rec."No.")
                    end;

                }
            }
        }
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action("Cash Drawer")
                {
                    Caption = 'Cash Drawer';
                    Image = CalculateSalesTax;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin

                        CurrPage.CnCOrderSummaryFactbox.PAGE.CCReceiveCash;
                    end;
                }

                action("Adjust Shortages")
                {
                    Caption = 'Adjust Shortages';
                    Image = AdjustEntries;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = false;
                    trigger OnAction()
                    begin
                        // Adjust Shortages
                        AdjustShortages;
                    end;
                }
                action("Recent Purchases")
                {
                    Caption = 'Recent Purchases';
                    Image = History;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        ItemLedg: Record "Item Ledger Entry";
                        OrdLine: Record "Sales Line";
                        LineNo: Integer;
                    begin
                        // Recent Purchases


                        Clear(OrdLine);
                        OrdLine.SetRange("Document No.", "No.");
                        if OrdLine.Count <> 0 then
                            Error('Existing Lines must be deleted before running this function.');

                        LineNo := 0;

                        ItemLedg.SetCurrentKey("Entry Type", "Item No.", "Variant Code", "Source Type", "Source No.", "Posting Date");

                        ItemLedg.SetRange("Entry Type", ItemLedg."Entry Type"::Sale);
                        ItemLedg.SetRange("Source Type", ItemLedg."Source Type"::Customer);
                        ItemLedg.SetRange("Source No.", Rec."Sell-to Customer No.");
                        FromDate := CalcDate('-21D', Rec."Order Date");
                        ItemLedg.SetRange("Posting Date", Rec."Order Date" - 21, Rec."Order Date");
                        if ItemLedg.Find('-') then
                            repeat
                                LineNo += 10000;
                                OrdLine.Init;
                                OrdLine.Validate("Document Type", OrdLine."Document Type"::Order);
                                OrdLine."Document No." := Rec."No.";
                                OrdLine."Line No." := LineNo;
                                OrdLine.Validate(Type, OrdLine.Type::Item);
                                OrdLine.Validate("No.", ItemLedg."Item No.");
                                OrdLine.Insert;
                                ItemLedg.SETRANGE("Item No.", ItemLedg."Item No.");
                                ItemLedg.FIND('+');
                                ItemLedg.SETRANGE(ItemLedg."Item No.");
                            until ItemLedg.Next = 0;

                    end;
                }
                action("Re&open")
                {
                    Caption = 'Re&open';
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        ReleaseSalesDoc: Codeunit "Release Sales Document";
                    begin
                        ReleaseSalesDoc.PerformManualReopen(Rec);
                    end;
                }
                action("Total Order")
                {
                    Caption = 'Total Order';
                    Image = Totals;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        lpagCnCReceiveCash: Page "EN C&C Receive Cash";
                        lrecSalesHeader: Record "Sales Header";
                    begin

                        CurrPage.CnCOrderSummaryFactbox.PAGE.TotalOrder;
                        Get("Document Type", "No.");
                        if PostOrder then begin
                            //NewOrder;
                        end;
                    end;
                }
                action("Total Cases")
                {
                    Caption = 'Save Order';
                    Image = Save;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        ReleaseSalesDoc: Codeunit "Release Sales Document";
                    begin
                        Rec.Get("Document Type", "No.");
                        if "Sell-to Customer No." = '' then
                            exit;

                        CurrPage.CnCOrderSummaryFactbox.PAGE.TotalOrderNotCash;
                    end;
                }
            }
            group(Authorize)
            {
                Caption = 'Authorize';
                Image = AuthorizeCreditCard;

                action(Price)
                {
                    Caption = 'Price';
                    Image = Price;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    begin
                        // Authorize
                        // Price

                        CurrPage.SalesLines.PAGE.AuthorizePrice;
                    end;
                }
                action("Order")
                {
                    Caption = 'Order';
                    Image = "Order";
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        Outstanding: array[2] of Decimal;
                        Limit: Decimal;
                    begin
                        gcduYOGFunctions.T36CalcCredit(Rec, Outstanding, Limit);
                        gcduYOGFunctions.T36AuthorizeOrder(Rec, Outstanding, Limit);
                    end;
                }
                action("Sign Order")
                {
                    Caption = 'Sign Order';
                    Image = Signature;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        // Authorize
                        // Sign Order
                        gcduYOGFunctions.T36SignOrder(Rec);


                        CurrPage.Update(true);
                        Modify;
                        if PostOrder then begin
                            //NewOrder;
                        end;
                    end;
                }
                action("Display Signature")
                {
                    Caption = 'Signature';
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "EN Signature Display";
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("Apply Entries")
                {
                    Caption = 'Apply Entries';
                    Ellipsis = true;
                    Image = ApplyEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+F11';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Sales Header Apply", Rec);
                    end;
                }

                action("Post Order")
                {
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        CurrPage.Update(true);
                        Modify;
                        if PostOrder then begin
                            //NewOrder;
                        end;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        JobQueueVisible := "Job Queue Status" = "Job Queue Status"::"Scheduled for Posting";


    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.SaveRecord;
        exit(ConfirmDeletion);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        //CheckCreditMaxBeforeInsert;TBR
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Responsibility Center" := UserMgt.GetSalesFilter;
    end;

    trigger OnOpenPage()

    begin
        if UserMgt.GetSalesFilter <> '' then begin
            FilterGroup(2);
            SetRange("Responsibility Center", UserMgt.GetSalesFilter);
            FilterGroup(0);
        end;

        if gcduYOGFunctions.GetSalesLocationFilter() <> '' then begin
            FilterGroup(2);
            SetFilter("Location Code", gcduYOGFunctions.GetSalesLocationFilter());
            FilterGroup(0);
        end;

        SetRange("Date Filter", 0D, WorkDate - 1);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin

        if gblnAfterPosting then begin
            gblnAfterPosting := false;
            exit(false);
        end else begin
            exit(true);
        end;
    end;

    var
        ZdRecRef: RecordRef;
        Text000: Label 'Unable to execute this function while in view only mode.';
        CopySalesDoc: Report "Copy Sales Document";
        MoveNegSalesLines: Report "Move Negative Sales Lines";
        ReportPrint: Codeunit "Test Report-Print";
        DocPrint: Codeunit "Document-Print";
        ArchiveManagement: Codeunit ArchiveManagement;
        ChangeExchangeRate: Page "Change Exchange Rate";
        UserMgt: Codeunit "User Setup Management";

        Usage: Option "Order Confirmation","Work Order","Pick Instruction";
        [InDataSet]
        JobQueueVisible: Boolean;
        Text001: Label 'Do you want to change %1 in all related records in the warehouse?';
        Text002: Label 'The update has been interrupted to respect the warning.';
        DynamicEditable: Boolean;
        SalesLine: Record "Sales Line";
        Text14000701: Label 'Sales Order %1 added to Bill of Lading %2.';
        Text14000702: Label 'Information is OK';

        "--From Original--": Integer;
        FromDate: Date;
        gblnAfterPosting: Boolean;
        grecUserSetup: Record "User Setup";
        grecSalesAndRecSetup: Record "Sales & Receivables Setup";
        lcduCreateIJ: Codeunit "EN Custom Functions";
        gcduYOGFunctions: Codeunit "EN Custom Functions";
        lpagCustSalesHistory: Page "EN Cust. Sales History";
        grecGenJnlLine_AdditionalPaymentsToPost: Record "Gen. Journal Line";
        gblnPostAdditionalPayments: Boolean;
        gblnSetAppliedAmt: Boolean;
        gdecAmountToApply: Decimal;

    local procedure Post(PostingCodeunitID: Integer)
    begin
        Error('POST!!!!');
        SendToPosting(PostingCodeunitID);
        if "Job Queue Status" = "Job Queue Status"::"Scheduled for Posting" then
            CurrPage.Close;
        CurrPage.Update(false);
    end;


    procedure UpdateAllowed(): Boolean
    begin
        if CurrPage.Editable = false then
            Error(Text000);
        exit(true);
    end;

    local procedure ApproveCalcInvDisc()
    begin
        CurrPage.SalesLines.PAGE.ApproveCalcInvDisc;
    end;

    local procedure SelltoCustomerNoOnAfterValidat()
    begin
        if GetFilter("Sell-to Customer No.") = xRec."Sell-to Customer No." then
            if "Sell-to Customer No." <> xRec."Sell-to Customer No." then
                SetRange("Sell-to Customer No.");
        CurrPage.Update;
    end;

    local procedure SalespersonCodeOnAfterValidate()
    begin
        CurrPage.SalesLines.PAGE.UpdateForm(true);
    end;

    local procedure BilltoCustomerNoOnAfterValidat()
    begin
        CurrPage.Update;
    end;

    local procedure ShortcutDimension1CodeOnAfterV()
    begin
        CurrPage.Update;
    end;

    local procedure ShortcutDimension2CodeOnAfterV()
    begin
        CurrPage.Update;
    end;

    local procedure Prepayment37OnAfterValidate()
    begin
        CurrPage.Update;
    end;


    procedure AssignLots(pblnReqForm: Boolean)
    var
        lrecSalesHeader: Record "Sales Header";
    begin
        //<JF11582RH> - New function
        /*lrecSalesHeader.SETRANGE("No.","No.");
        REPORT.RUNMODAL(REPORT::"YOG Cash & Carry - Assign Lot",TRUE,FALSE,lrecSalesHeader);
        REPORT.RUNMODAL(REPORT::"YOG Cash & Carry - Assign Lot",pblnReqForm,FALSE,lrecSalesHeader);*/ //TBR

    end;


    procedure AdjustShortages()
    begin
        lcduCreateIJ.CreateQuickItemJnl(Rec); // CU "Create/Post Quick Item Journal"

    end;

    procedure "--From-Original--"()
    begin
    end;


    procedure PostOrder(): Boolean
    var
        SalesLine: Record "Sales Line";
        PaymentMethod: Record "Payment Method";
        Payment: Record "Gen. Journal Line";
        lrecGenJnlLine: Record "Gen. Journal Line";
        CustLedger: Record "Cust. Ledger Entry";
        SalesInvHeader: Record "Sales Invoice Header";
        ReportSelection: Record "Report Selections";
        SalesPost: Codeunit "Sales-Post";
        GenJnlPost: Codeunit "Gen. Jnl.-Post Line";
        EntryNo: Integer;
        AppliedToOrder: Decimal;
        ldecAppliedToOrder: Decimal;
        Outstanding: array[2] of Decimal;
        Limit: Decimal;
        SlsHdr: Record "Sales Header";
        ldecAppliedToOthers: Decimal;
        lcduGenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        lcduReleaseOrder: Codeunit "Release Sales Document";
    begin


        CurrPage.CnCOrderSummaryFactbox.PAGE.CalcTotalTax("Document Type", "No.");

        SlsHdr.Get("Document Type", "No.");
        lcduReleaseOrder.Run(SlsHdr);
        CheckTotals;
        Clear(SalesPost);
        SalesLine.Reset;
        SalesLine.SetRange("Document Type", "Document Type");
        SalesLine.SetRange("Document No.", "No.");
        if not SalesLine.Find('-') then
            Error('Nothing to post.');



        if not gcduYOGFunctions.T36OKtoPost(Rec, true) then begin
            exit(false);
        end;
        if not Confirm('Post order?', true) then
            exit(false);

        gblnAfterPosting := true;

        Commit();

        if CustLedger.Find('+') then
            EntryNo := CustLedger."Entry No."
        else
            EntryNo := 0;


        SlsHdr.Get("Document Type", "No.");
        SlsHdr.Ship := true;
        SlsHdr.Invoice := true;
        YGGetUserSetupForCCInfo;

        if (grecUserSetup.IsEmpty) or (grecUserSetup."CC Journal Template ELA" = '') then begin
            Payment.SetRange("Journal Template Name", grecSalesAndRecSetup."C&C Journal Template ELA");
            Payment.SetRange("Journal Batch Name", grecSalesAndRecSetup."C&C Cash Journal Batch ELA");
        end
        else begin
            Payment.SetRange("Journal Template Name", grecUserSetup."CC Journal Template ELA");
            Payment.SetRange("Journal Batch Name", grecUserSetup."CC Cash Journal Batch ELA");
        end;

        Payment.SetRange("Document No.", "No.");
        if (
          (not Payment.IsEmpty)
        ) then begin
            Payment.Find('-');
            SetGenJournalLineOfAdditionalPaymentsToPost(Payment); //TBR
        end;

        SetApplyAmount(-"Cash Applied (Current) ELA");//TBR
        AdjustShortages;

        SlsHdr.Modify();
        COMMIT();

        SalesPost.Run(SlsHdr);

        if (grecUserSetup.IsEmpty) or (grecUserSetup."CC Journal Template ELA" = '') then begin

            Payment.SetRange("Journal Template Name", grecSalesAndRecSetup."C&C Journal Template ELA");
            Payment.SetRange("Journal Batch Name", grecSalesAndRecSetup."C&C Cash Journal Batch ELA");
        end
        else begin
            Payment.SetRange("Journal Template Name", grecUserSetup."CC Journal Template ELA");
            Payment.SetRange("Journal Batch Name", grecUserSetup."CC Cash Journal Batch ELA");
        end;
        Payment.SetRange("Document No.", "No.");
        if Payment.FindSet then
            repeat
                Payment.Delete;
            until Payment.Next = 0;

        if SalesInvHeader.Get("No.") then begin

            SalesInvHeader.SetRecFilter;
            ReportSelection.Reset;
            ReportSelection.SetRange(Usage, ReportSelection.Usage::"S.Invoice");
            ReportSelection.Find('-');
            repeat
                ReportSelection.TestField("Report ID");
                REPORT.Run(ReportSelection."Report ID", false, false, SalesInvHeader);
            until ReportSelection.Next = 0;
        end;

        exit(true);
    end;

    procedure SetGenJournalLineOfAdditionalPaymentsToPost(precGenJnlLine_AdditionalPaymentsToPost: Record "Gen. Journal Line")
    begin
        grecGenJnlLine_AdditionalPaymentsToPost.COPY(precGenJnlLine_AdditionalPaymentsToPost);
        gblnPostAdditionalPayments := TRUE;
    end;

    procedure SetApplyAmount(pdecAmountToApply: Decimal)
    begin
        gdecAmountToApply := pdecAmountToApply;
        gblnSetAppliedAmt := TRUE;
    end;

    procedure CheckTotals()
    var
        SalesHeader: Record "Sales Header";
        FormTotals: array[5] of Decimal;
        ltxtDiag: Label '%1 %2 %3 %4 %5 %6 %7 %8 %9 %10';
    begin
        CalcFields("Amount Including VAT");


        if (
        ("Amount Including VAT" <> "Cash vs Amount Incld Tax ELA")
        ) then begin
            Error('The order has changed; please update the Cash Receipt page.');
        end;

    end;

    local procedure YGGetUserSetupForCCInfo()
    begin
        grecUserSetup.SetFilter("User ID", UserId);
        if grecUserSetup.FindFirst then;
        if grecSalesAndRecSetup.FindFirst then;
    end;

    procedure PrintBarcode(OrderNo: Code[20])
    var
        CCOrderBarcode: Report "YOG Cash & Carry Order Barcode";
    begin
        CLEAR(CCOrderBarcode);
        CCOrderBarcode.SetOrderNo(OrderNo);
        CCOrderBarcode.RUNMODAL();
    end;
}

