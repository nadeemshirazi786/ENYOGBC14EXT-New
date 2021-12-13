page 14228885 "EN CC Sales Order List"
{
    Caption = 'Sales Order Cash & Carry List';
    PageType = List;
    ApplicationArea = All;
    Editable = true;
    UsageCategory = Lists;
    InsertAllowed = false;
    CardPageId = "EN Sales Order C&C Card";
    SourceTable = "Sales Header";
    SourceTableView = SORTING("Document Type", "No.") ORDER(descending) WHERE("Document Type" = CONST(Order), "Cash & Carry ELA" = CONST(true));
    //WHERE("Document Type" = CONST(Order));
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                }
                field("Shipment Date"; "Shipment Date")
                {
                    Visible = true;
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                }
                field("Sell-to Customer Name"; "Sell-to Customer Name")
                {
                }
                field("External Document No."; "External Document No.")
                {
                }
                field("Sell-to Post Code"; "Sell-to Post Code")
                {
                    Visible = false;
                }
                field("Sell-to Country/Region Code"; "Sell-to Country/Region Code")
                {
                    Visible = false;
                }
                field("Sell-to Contact"; "Sell-to Contact")
                {
                    Visible = false;
                }
                field("Bill-to Customer No."; "Bill-to Customer No.")
                {
                    Visible = false;
                }
                field("Bill-to Name"; "Bill-to Name")
                {
                    Visible = false;
                }
                field("Bill-to Post Code"; "Bill-to Post Code")
                {
                    Visible = false;
                }
                field("Bill-to Country/Region Code"; "Bill-to Country/Region Code")
                {
                    Visible = false;
                }
                field("Bill-to Contact"; "Bill-to Contact")
                {
                    Visible = false;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    Visible = false;
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    Visible = false;
                }
                field("Ship-to Post Code"; "Ship-to Post Code")
                {
                    Visible = false;
                }
                field("Ship-to Country/Region Code"; "Ship-to Country/Region Code")
                {
                    Visible = false;
                }
                field("Ship-to Contact"; "Ship-to Contact")
                {
                    Visible = false;
                }
                field("Posting Date"; "Posting Date")
                {
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                    Visible = true;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    Visible = true;
                }
                field("Assigned User ID"; "Assigned User ID")
                {
                    Visible = false;
                }
                field("Currency Code"; "Currency Code")
                {
                    Visible = false;
                }
                field("Document Date"; "Document Date")
                {
                    Visible = false;
                }
                field("Requested Delivery Date"; "Requested Delivery Date")
                {
                    Visible = false;
                }
                field("Campaign No."; "Campaign No.")
                {
                    Visible = false;
                }
                field(Status; Status)
                {
                }
                field("Payment Terms Code"; "Payment Terms Code")
                {
                    Visible = true;
                }
                field("Due Date"; "Due Date")
                {
                    Visible = false;
                }
                field("Payment Discount %"; "Payment Discount %")
                {
                    Visible = false;
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    Visible = false;
                }
                field("Completely Shipped"; "Completely Shipped")
                {
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    Visible = false;
                }
                field("<Shipping Agent Code2>"; "Shipping Agent Code")
                {
                }
                field("Shipping Advice"; "Shipping Advice")
                {
                    Visible = false;
                }
                field("Job Queue Status"; "Job Queue Status")
                {
                    Visible = JobQueueActive;
                }
                field(gcodCreatedBy; gcodCreatedBy)
                {
                    Caption = 'Created By';
                }
                field(gdecTendered; gdecTendered)
                {
                    Caption = 'Amount Tendered';
                }
                field(gdecAppToCurr; gdecAppToCurr)
                {
                    Caption = 'Applied (Current)';
                }
                field(gdecAppToOther; gdecAppToOther)
                {
                    Caption = 'Applied (Other)';
                }

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
                        OrderForm: Page "EN Sales Order C&C Card";
                        CustNo: Code[20];
                        lcodShipTo: Code[10];
                        lctxtInvalidCustomerOrShip: Label 'Invalid %1 and/or %2.';
                    begin
                        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                        SalesHeader.Insert(true);
                        SalesHeader."Cash & Carry ELA" := true;
                        SalesHeader.Modify;
                        Rec := SalesHeader;
                        OrderForm.SetTableView(Rec);
                        OrderForm.Run();
                    end;
                }

                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDocDim;
                    end;
                }
                action(Statistics)
                {
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    begin
                        CalcInvDiscForHeader;
                        Commit;
                        if "Tax Area Code" = '' then
                            PAGE.RunModal(PAGE::"Sales Order Statistics", Rec)
                        else
                            PAGE.RunModal(PAGE::"Sales Order Stats.", Rec)
                    end;
                }
                action("A&pprovals")
                {
                    Caption = 'A&pprovals';
                    Image = Approvals;

                    trigger OnAction()
                    var
                        ApprovalEntries: Page "Approval Entries";
                    begin
                        ApprovalEntries.Setfilters(DATABASE::"Sales Header", "Document Type", "No.");
                        ApprovalEntries.Run;
                    end;
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Sales Comment Sheet";
                    RunPageLink = "Document Type" = FIELD("Document Type"),
                                  "No." = FIELD("No."),
                                  "Document Line No." = CONST(0);
                }
            }
            group(Documents)
            {
                Caption = 'Documents';
                Image = Documents;
                action("S&hipments")
                {
                    Caption = 'S&hipments';
                    Image = Shipment;
                    RunObject = Page "Posted Sales Shipments";
                    RunPageLink = "Order No." = FIELD("No.");
                    RunPageView = SORTING("Order No.");
                }
                action(Invoices)
                {
                    Caption = 'Invoices';
                    Image = Invoice;
                    RunObject = Page "Posted Sales Invoices";
                    RunPageLink = "Order No." = FIELD("No.");
                    RunPageView = SORTING("Order No.");
                }
                action("Prepa&yment Invoices")
                {
                    Caption = 'Prepa&yment Invoices';
                    Image = PrepaymentInvoice;
                    RunObject = Page "Posted Sales Invoices";
                    RunPageLink = "Prepayment Order No." = FIELD("No.");
                    RunPageView = SORTING("Prepayment Order No.");
                }
                action("Prepayment Credi&t Memos")
                {
                    Caption = 'Prepayment Credi&t Memos';
                    Image = PrepaymentCreditMemo;
                    RunObject = Page "Posted Sales Credit Memos";
                    RunPageLink = "Prepayment Order No." = FIELD("No.");
                    RunPageView = SORTING("Prepayment Order No.");
                }
            }
            group(Warehouse)
            {
                Caption = 'Warehouse';
                Image = Warehouse;
                action("Whse. Shipment Lines")
                {
                    Caption = 'Whse. Shipment Lines';
                    Image = ShipmentLines;
                    RunObject = Page "Whse. Shipment Lines";
                    RunPageLink = "Source Type" = CONST(37),
                                  "Source Subtype" = FIELD("Document Type"),
                                  "Source No." = FIELD("No.");
                    RunPageView = SORTING("Source Type", "Source Subtype", "Source No.", "Source Line No.");
                }
                action("In&vt. Put-away/Pick Lines")
                {
                    Caption = 'In&vt. Put-away/Pick Lines';
                    Image = PickLines;
                    RunObject = Page "Warehouse Activity List";
                    RunPageLink = "Source Document" = CONST("Sales Order"),
                                  "Source No." = FIELD("No.");
                    RunPageView = SORTING("Source Document", "Source No.", "Location Code");
                }
            }
        }
        area(processing)
        {
            group(Release)
            {
                Caption = 'Release';
                Image = ReleaseDoc;
                action("Re&lease")
                {
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Ctrl+F9';

                    trigger OnAction()
                    var
                        ReleaseSalesDoc: Codeunit "Release Sales Document";
                    begin
                        ReleaseSalesDoc.PerformManualRelease(Rec);

                        //<IS31761TZ>
                        //gcduEventNotMgt.ibOrderConfRealTime(Rec);
                        //</IS31761TZ>
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
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Pla&nning")
                {
                    Caption = 'Pla&nning';
                    Image = Planning;

                    trigger OnAction()
                    var
                        SalesOrderPlanningForm: Page "Sales Order Planning";
                    begin
                        SalesOrderPlanningForm.SetSalesOrder("No.");
                        SalesOrderPlanningForm.RunModal;
                    end;
                }
                action("Order &Promising")
                {
                    Caption = 'Order &Promising';
                    Image = OrderPromising;

                    trigger OnAction()
                    var
                        OrderPromisingLine: Record "Order Promising Line" temporary;
                    begin
                        OrderPromisingLine.SetRange("Source Type", "Document Type");
                        OrderPromisingLine.SetRange("Source ID", "No.");
                        PAGE.RunModal(PAGE::"Order Promising Lines", OrderPromisingLine);
                    end;
                }
                separator(Action23019000)
                {
                }
                action("<Action23019000>")
                {
                    Caption = 'Sales Profit Modifiers    TBR Page 23019153';
                    Image = EditForecast;
                }
                action("Send A&pproval Request")
                {
                    Caption = 'Send A&pproval Request';
                    Image = SendApprovalRequest;

                    trigger OnAction()
                    begin
                        //IF ApprovalMgt.SendSalesApprovalRequest(Rec) THEN; TBR
                    end;
                }
                action("Cancel Approval Re&quest")
                {
                    Caption = 'Cancel Approval Re&quest';
                    Image = Cancel;

                    trigger OnAction()
                    begin
                        //IF ApprovalMgt.CancelSalesApprovalRequest(Rec,TRUE,TRUE) THEN; TBR
                    end;
                }
                action("Send IC Sales Order Cnfmn.")
                {
                    Caption = 'Send IC Sales Order Cnfmn.';
                    Image = IntercompanyOrder;

                    trigger OnAction()
                    var
                        ICInOutboxMgt: Codeunit ICInboxOutboxMgt;
                        PurchaseHeader: Record "Purchase Header";
                    begin
                        /*IF ApprovalMgt.PrePostApprovalCheck(Rec,PurchaseHeader) THEN
                          ICInOutboxMgt.SendSalesDoc(Rec,FALSE);*///TBR

                    end;
                }
                action("E-&Mail Confirmation")
                {
                    Caption = 'E-&Mail Confirmation';
                    Image = Email;
                    Promoted = false;

                    trigger OnAction()
                    begin
                        /*TESTFIELD("E-Mail Confirmation Handled",FALSE);
                        
                        EMailMgt.SendSalesConfirmation(Rec,TRUE,FALSE);*///TBR

                        //<IS31761TZ>
                        //gcduEventNotMgt.ibOrderConfRealTime(Rec);
                        //</IS31761TZ>

                    end;
                }
                group("&E-Ship")
                {
                    Caption = '&E-Ship';
                    Visible = false;
                    action("Create Bill of Lading")
                    {
                        Caption = 'Create Bill of Lading';
                        Image = NewDocument;
                        Promoted = true;
                        PromotedCategory = Process;

                        trigger OnAction()
                        var
                            Text14000701: Label 'Sales Order %1 added to Bill of Lading %2.';
                        begin
                            /*BillOfLading.CreateBillOfLadingSalesHeader(Rec,TRUE);
                            
                            MESSAGE(Text14000701,"No.",BillOfLading."No.");*///TBR

                        end;
                    }
                    action("Fast Pack")
                    {
                        Caption = 'Fast Pack';
                        ShortCutKey = 'Alt+F11';

                        trigger OnAction()
                        begin
                            /*FastPackLine.RESET;
                            FastPackLine.SETRANGE("Source Type",DATABASE::"Sales Header");
                            FastPackLine.SETRANGE("Source Subtype","Document Type");
                            FastPackLine.SETRANGE("Source ID","No.");
                            PAGE.RUNMODAL(PAGE::"Fast Pack Order",FastPackLine);*///TBR

                        end;
                    }
                    action("Test E-Ship Requirement")
                    {
                        Caption = 'Test E-Ship Requirement';

                        trigger OnAction()
                        var
                            Text14000702: Label 'Information is OK';
                        begin
                            /*Package.TestFromSalesHeader(Rec);
                            
                            MESSAGE(Text14000702);*///TBR

                        end;
                    }
                    action("Quote Rate")
                    {
                        Caption = 'Quote Rate';

                        trigger OnAction()
                        begin
                            /*Shipping.QuoteRateSalesHeader(Rec);
                            
                            CurrPage.UPDATE;*///TBR

                        end;
                    }
                    action("Rate Shop")
                    {
                        Caption = 'Rate Shop';
                        Image = Calculate;
                        Promoted = true;
                        PromotedCategory = Process;
                        ShortCutKey = 'Ctrl+F11';

                        trigger OnAction()
                        begin
                            //Shipping.RateShopSalesHeader(Rec); TBR

                            CurrPage.Update;
                        end;
                    }
                    action("Add to Export Document")
                    {
                        Caption = 'Add to Export Document';

                        trigger OnAction()
                        begin
                            //Shipping.ExpDocAddFromOrder(DATABASE::"Sales Header","Document Type","No.");  TBR
                        end;
                    }
                }
            }
            group(Action3)
            {
                Caption = 'Warehouse';
                Image = Warehouse;
                action("Create Inventor&y Put-away/Pick")
                {
                    Caption = 'Create Inventor&y Put-away/Pick';
                    Ellipsis = true;
                    Image = CreatePutawayPick;

                    trigger OnAction()
                    begin
                        CreateInvtPutAwayPick;

                        if not Find('=><') then
                            Init;
                    end;
                }
                action("Create &Whse. Shipment")
                {
                    Caption = 'Create &Whse. Shipment';
                    Image = NewShipment;

                    trigger OnAction()
                    var
                        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
                    begin
                        GetSourceDocOutbound.CreateFromSalesOrder(Rec);

                        if not Find('=><') then
                            Init;
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("P&ost")
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
                        SendToPosting(CODEUNIT::"Sales-Post (Yes/No)");
                    end;
                }
                action("Post and &Print")
                {
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction()
                    begin
                        SendToPosting(CODEUNIT::"Sales-Post + Print");
                    end;
                }
                action("Test Report")
                {
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;

                    trigger OnAction()
                    begin
                        ReportPrint.PrintSalesHeader(Rec);
                    end;
                }
                action("Post &Batch")
                {
                    Caption = 'Post &Batch';
                    Ellipsis = true;
                    Image = PostBatch;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        REPORT.RunModal(REPORT::"Batch Post Sales Orders", true, true, Rec);
                        CurrPage.Update(false);
                    end;
                }
                action("Remove From Job Queue")
                {
                    Caption = 'Remove From Job Queue';
                    Image = RemoveLine;
                    Visible = JobQueueActive;

                    trigger OnAction()
                    begin
                        CancelBackgroundPosting;
                    end;
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                Image = Print;
                action("Order Confirmation")
                {
                    Caption = 'Order Confirmation';
                    Ellipsis = true;
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        DocPrint.PrintSalesOrder(Rec, Usage::"Order Confirmation");
                    end;
                }
                action("Work Order")
                {
                    Caption = 'Work Order';
                    Ellipsis = true;
                    Image = Print;

                    trigger OnAction()
                    begin
                        DocPrint.PrintSalesOrder(Rec, Usage::"Work Order");
                    end;
                }
                action("Pick Instruction")
                {
                    Caption = 'Pick Instruction';
                    Image = Print;

                    trigger OnAction()
                    begin
                        DocPrint.PrintSalesOrder(Rec, Usage::"Pick Instruction");
                    end;
                }
                action("Customer Balance to Date")
                {

                    trigger OnAction()
                    var
                        CustBalToDateReport: Report "EN Customer - Balance to Date";
                    begin
                        //EN1.00
                        Clear(CustBalToDateReport);
                        CustBalToDateReport.SetCustDate("Sell-to Customer No.", Today);
                        CustBalToDateReport.RunModal;
                        Clear(CustBalToDateReport);
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Sales Reservation Avail.")
            {
                Caption = 'Sales Reservation Avail.';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Sales Reservation Avail.";
            }
            action("Sale Order")
            {
                Caption = 'Sale Order';
                Image = Report;
                Promoted = true;
                PromotedCategory = "Report";
                trigger OnAction()
                begin
                    PrintAllBarcode("No.");
                end;
            }
        }

    }
    procedure PrintAllBarcode(AllOrderNo: code[20])
    var
        PrintBarcodeReport: Report "YOG Cash & Carry Order Barcode";
    begin

        CLEAR(PrintBarcodeReport);
        PrintBarcodeReport.SerAllOrder(AllOrderNo);
        PrintBarcodeReport.RUNMODAL;
    end;

    trigger OnOpenPage()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        if UserMgt.GetSalesFilter <> '' then begin
            FilterGroup(2);
            SetRange("Responsibility Center", UserMgt.GetSalesFilter);
            FilterGroup(0);
        end;

        //<DP20160322>
        SetRange("Date Filter", 0D, WorkDate);

        JobQueueActive := SalesSetup.JobQueueActive;
    end;

    var
        DocPrint: Codeunit "Document-Print";
        ReportPrint: Codeunit "Test Report-Print";
        UserMgt: Codeunit "User Setup Management";
        Usage: Option "Order Confirmation","Work Order","Pick Instruction";
        [InDataSet]
        JobQueueActive: Boolean;
        gcodCreatedBy: Code[50];
        gdecTendered: Decimal;
        gdecAppToCurr: Decimal;
        gdecAppToOther: Decimal;



}

