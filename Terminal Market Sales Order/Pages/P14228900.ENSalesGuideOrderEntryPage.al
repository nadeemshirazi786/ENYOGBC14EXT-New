page 14228900 "EN Sales Guide Order Entry"
{
    ApplicationArea = All;
    UsageCategory = Documents;
    Caption = 'Terminal Market Sales Order';

    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Sales Header";
    /* SourceTableView = sorting("Salesperson Code")                  
                      WHERE("Document Type" = FILTER(Order)); */   //      TBR1.01  

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    QuickEntry = false;
                    Visible = false;

                    trigger OnAssistEdit()
                    begin
                        /*if AssistEdit(xRec) then
                            CurrPage.Update;*///TBR
                    end;
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    Editable = "Sell-to Customer No.Editable";

                    trigger OnValidate()
                    begin
                        CashDrawerCheckELA;           //JA 06-26-2010

                        if DirectCustomer.Get("Sell-to Customer No.") then
                            if DirectCustomer."Direct Customer ELA" then
                                Error(Text50000, "Sell-to Customer No.");

                        SelltoCustomerNoOnAfterValidat;
                        if WorkDate <> Today then
                            Message(Text50004);
                    end;
                }
                field("Sell-to Customer Name"; "Sell-to Customer Name")
                {
                    QuickEntry = false;
                }
                field("Sell-to Contact"; "Sell-to Contact")
                {
                    Importance = Additional;
                    QuickEntry = false;
                }
                group(Address)
                {
                    Caption = 'Address';
                    field("Sell-to Address"; "Sell-to Address")
                    {
                        Importance = Additional;
                        QuickEntry = false;
                    }
                    field("Sell-to Address 2"; "Sell-to Address 2")
                    {
                        Importance = Additional;
                        QuickEntry = false;
                    }
                    field("Sell-to City"; "Sell-to City")
                    {
                        Importance = Additional;
                        QuickEntry = false;
                    }
                    field("Sell-to County"; "Sell-to County")
                    {
                        Importance = Additional;
                        QuickEntry = false;
                    }
                    field("Sell-to Post Code"; "Sell-to Post Code")
                    {
                        Importance = Additional;
                        QuickEntry = false;
                    }
                }
                field("Posting Date"; "Posting Date")
                {
                    QuickEntry = false;

                    trigger OnValidate()
                    var
                        Text50006: Label 'Warning, Posting Date does not equal TODAY.';
                    begin
                        CashDrawerCheckELA;           //JA 06-26-2010
                        if "Posting Date" <> Today then
                            Message(Text50006);
                    end;
                }
                field("Order Date"; "Order Date")
                {
                    Importance = Additional;
                    QuickEntry = false;
                }
                field("Document Date"; "Document Date")
                {
                    Importance = Additional;
                    QuickEntry = false;
                }
                field("External Document No."; "External Document No.")
                {
                    Caption = 'Cust PO No.';
                }
                field(Status; Status)
                {
                    QuickEntry = false;
                }
                field("Supply Chain Group Code"; "Supply Chain Group Code ELA")
                {
                    Caption = 'Sales Team';
                    Description = '<Sales Team, DA0066>';
                    Editable = false;
                    Importance = Promoted;
                    QuickEntry = false;
                }
            }
            group("Item Display Options")
            {
                Caption = 'Item Display Options';
                field(DisplayAll; DisplayAll)
                {
                    Caption = 'Display All';
                    QuickEntry = false;

                    trigger OnValidate()
                    var
                        UserSetupL: Record "User Setup";
                    begin

                        SetDisplayAll(UserId, DisplayAll, false, true);

                        // UserSetupL.Get(UserId);
                        // UserSetupL."Display All Items" := DisplayAll;
                        // UserSetupL.Modify
                    end;
                }
                field(DisplayVeg1; DisplayVeg1)
                {
                    Caption = 'Veg 1';
                    QuickEntry = false;

                    trigger OnValidate()
                    begin
                        SendDisplayOptions;
                    end;
                }
                field(DisplayVeg2; DisplayVeg2)
                {
                    Caption = 'Veg 2';
                    QuickEntry = false;

                    trigger OnValidate()
                    begin
                        SendDisplayOptions;
                    end;
                }
                field(DisplayFrt1; DisplayFrt1)
                {
                    Caption = 'Frt 1';
                    QuickEntry = false;

                    trigger OnValidate()
                    begin
                        SendDisplayOptions;
                    end;
                }
                field(DisplayFrt2; DisplayFrt2)
                {
                    Caption = 'Frt 2';
                    QuickEntry = false;

                    trigger OnValidate()
                    begin
                        SendDisplayOptions;
                    end;
                }
                field(DisplayFrt3; DisplayFrt3)
                {
                    Caption = 'Frt 3';
                    QuickEntry = false;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        SendDisplayOptions;
                    end;
                }
            }
            part("Sales Order Guide Lines"; "EN Sales Order Guide Subpage")
            {
                Caption = 'Items';
                SubPageLink = "Order No." = FIELD("No.");
                // SubPageView = SORTING("Order No.", "Item No.", "Item Variant Code", "Country/Region of Origin Code")
                //               ORDER(Ascending);  TBR1.00
            }
            part(SalesLines; "EN Sales Order Lines Subpage1")
            {
                Caption = 'Sales Order Lines';
                SubPageLink = "Document No." = FIELD("No.");
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';
                Visible = false;
                field("Bill-to Customer No."; "Bill-to Customer No.")
                {

                    trigger OnValidate()
                    begin
                        BilltoCustomerNoOnAfterValidat;
                    end;
                }
                field("Bill-to Name"; "Bill-to Name")
                {
                }
                field("Bill-to Contact"; "Bill-to Contact")
                {
                }
                field("Bill-to Address"; "Bill-to Address")
                {
                }
                field("Bill-to Address 2"; "Bill-to Address 2")
                {
                }
                field("Bill-to City"; "Bill-to City")
                {
                }
                field("Bill-to County"; "Bill-to County")
                {
                }
                field("Bill-to Post Code"; "Bill-to Post Code")
                {
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {

                    trigger OnValidate()
                    begin
                        ShortcutDimension1CodeOnAfterV;
                    end;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {

                    trigger OnValidate()
                    begin
                        ShortcutDimension2CodeOnAfterV;
                    end;
                }
                field("Payment Terms Code"; "Payment Terms Code")
                {
                }
                field("Due Date"; "Due Date")
                {
                }
                field("Payment Discount %"; "Payment Discount %")
                {
                }
                field("Pmt. Discount Date"; "Pmt. Discount Date")
                {
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                }
                field("Tax Area Code"; "Tax Area Code")
                {
                }
                field("Tax Liable"; "Tax Liable")
                {
                }
            }
            group(Shipping)
            {
                Caption = 'Shipping';
                Visible = false;
                field("Ship-to Code"; "Ship-to Code")
                {
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                }
                field("Ship-to Contact"; "Ship-to Contact")
                {
                }
                field("Ship-to UPS Zone"; "Ship-to UPS Zone")
                {
                }
                field("Delivery Route No."; "Delivery Route No. ELA")
                {
                }
                field("Ship-to Address"; "Ship-to Address")
                {
                }
                field("Ship-to Address 2"; "Ship-to Address 2")
                {
                }
                field("Ship-to City"; "Ship-to City")
                {
                }
                field("Ship-to County"; "Ship-to County")
                {
                }
                field("Ship-to Post Code"; "Ship-to Post Code")
                {
                }
                field("Location Code"; "Location Code")
                {
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                }
                field("Shipping Time"; "Shipping Time")
                {
                }
                field("Package Tracking No."; "Package Tracking No.")
                {
                }
                field("Shipment Date"; "Shipment Date")
                {
                }
                field("Shipping Advice"; "Shipping Advice")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("<Action50004>")
            {
                Caption = 'New Order';
                Image = NewDocument;
                InFooterBar = true;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SalesHeaderL: Record "Sales Header";
                begin
                    ValidatePriceAfterSale; //EN1.01
                    CurrPage.SaveRecord;
                    CurrPage.Close;
                    SalesHeaderL."Document Type" := "Document Type"::Order;
                    SalesHeaderL."No." := '';
                    SalesHeaderL.Insert(true);
                    SalesHeaderL."Terminal Market SO ELA" := true;
                    SalesHeaderL.Modify(true);
                    SalesHeaderL.SetRecFilter;
                    PAGE.Run(14228900, SalesHeaderL);
                end;
            }
            group("O&rder")
            {
                Caption = 'O&rder';
                action(Statistics)
                {
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    begin
                        SalesSetup.Get;
                        if SalesSetup."Calc. Inv. Discount" then begin
                            CurrPage.SalesLines.PAGE.CalcInvDisc;
                            Commit
                        end;
                        if "Tax Area Code" = '' then
                            PAGE.RunModal(PAGE::"Sales Order Statistics", Rec)
                        else
                            PAGE.RunModal(PAGE::"Sales Order Stats.", Rec)
                    end;
                }
                action(Card)
                {
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Customer Card";
                    RunPageLink = "No." = FIELD("Sell-to Customer No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Sales Comment Sheet";
                    RunPageLink = "Document Type" = FIELD("Document Type"),
                                  "No." = FIELD("No.");
                }
                action("S&hipments")
                {
                    Caption = 'S&hipments';
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
                separator(Action173)
                {
                }
                action("Whse. Shipment Lines")
                {
                    Caption = 'Whse. Shipment Lines';
                    RunObject = Page "Whse. Shipment Lines";
                    RunPageLink = "Source Type" = CONST(37),
                                  "Source Subtype" = FIELD("Document Type"),
                                  "Source No." = FIELD("No.");
                    RunPageView = SORTING("Source Type", "Source Subtype", "Source No.", "Source Line No.");
                }
                action("In&vt. Put-away/Pick Lines")
                {
                    Caption = 'In&vt. Put-away/Pick Lines';
                    RunObject = Page "Warehouse Activity List";
                    RunPageLink = "Source Document" = CONST("Sales Order"),
                                  "Source No." = FIELD("No.");
                    RunPageView = SORTING("Source Document", "Source No.", "Location Code");
                }
                separator(Action120)
                {
                }
                action("Pla&nning")
                {
                    Caption = 'Pla&nning';

                    trigger OnAction()
                    var
                        SalesPlanForm: Page "Sales Order Planning";
                    begin
                        SalesPlanForm.SetSalesOrder("No.");
                        SalesPlanForm.RunModal;
                    end;
                }
                action("Order &Promising")
                {
                    Caption = 'Order &Promising';

                    trigger OnAction()
                    var
                        OrderPromisingLine: Record "Order Promising Line" temporary;
                    begin
                        OrderPromisingLine.SetRange("Source Type", "Document Type");
                        OrderPromisingLine.SetRange("Source ID", "No.");
                        PAGE.RunModal(PAGE::"Order Promising Lines", OrderPromisingLine);
                    end;
                }
                group("Dr&op Shipment")
                {
                    Caption = 'Dr&op Shipment';
                    action("Purchase &Order")
                    {
                        Caption = 'Purchase &Order';
                        Image = Document;

                        trigger OnAction()
                        begin
                            CurrPage.SalesLines.PAGE.OpenPurchOrderForm;
                        end;
                    }
                }
                group("Speci&al Order")
                {
                    Caption = 'Speci&al Order';
                    action(Action203)
                    {
                        Caption = 'Purchase &Order';
                        Image = Document;

                        trigger OnAction()
                        begin
                            CurrPage.SalesLines.PAGE.OpenSpecialPurchOrderForm;
                        end;
                    }
                }
                separator(Action1102603007)
                {
                }
                action("Order &Guide")
                {
                    Caption = 'Order &Guide';
                    //RunObject = Codeunit Codeunit37002041;  TBR
                    ShortCutKey = 'Ctrl+G';
                }
            }
            group("&Line")
            {
                Caption = '&Line';
                group("Item Availability by")
                {
                    Caption = 'Item Availability by';
                    action(Period)
                    {
                        Caption = 'Period';

                        trigger OnAction()
                        begin
                            CurrPage.SalesLines.PAGE.ItemAvailability(0);
                        end;
                    }
                    action(Variant)
                    {
                        Caption = 'Variant';

                        trigger OnAction()
                        begin
                            CurrPage.SalesLines.PAGE.ItemAvailability(1);
                        end;
                    }
                    action(Location)
                    {
                        Caption = 'Location';

                        trigger OnAction()
                        begin
                            CurrPage.SalesLines.PAGE.ItemAvailability(2);
                        end;
                    }
                }
                separator(Action71)
                {
                }
                action("Reservation Entries")
                {
                    Caption = 'Reservation Entries';
                    Image = ReservationLedger;

                    trigger OnAction()
                    begin
                        CurrPage.SalesLines.PAGE.ShowReservationEntries;
                    end;
                }
                action("Item &Tracking Lines")
                {
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;

                    trigger OnAction()
                    begin
                        CurrPage.SalesLines.PAGE.OpenItemTrackLines;
                    end;

                }
                action("Co&ntainers")
                {
                    Caption = 'Co&ntainers';
                    ShortCutKey = 'Shift+Ctrl+N';

                    trigger OnAction()
                    begin
                        CurrPage.SalesLines.PAGE.ContainerTracking;
                    end;
                }
                separator(Action151)
                {
                }
                action("Select Item Substitution")
                {
                    Caption = 'Select Item Substitution';
                    Image = SelectItemSubstitution;

                    trigger OnAction()
                    begin
                        CurrPage.SalesLines.PAGE.ShowSubItem;
                    end;

                }
                separator(Action152)
                {
                }
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        CurrPage.SalesLines.PAGE.ShowDimension;
                    end;

                }
                action("Item Charge &Assignment")
                {
                    Caption = 'Item Charge &Assignment';

                    trigger OnAction()
                    begin
                        CurrPage.SalesLines.PAGE.ItemChargeAssgnt;
                    end;
                }
            }
        }
        area(processing)
        {
            action("Post Shipment")
            {
                Caption = 'Post Shipment';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                //RunObject = Codeunit Codeunit50002;    TBR
                Visible = false;
            }
            action("Item History")
            {
                Caption = 'Item History';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CurrPage.SalesLines.PAGE.CallItemSalesHistory;
                end;
            }
            action("&Order Items")
            {
                Caption = '&Order Items';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+O';

                trigger OnAction()
                var
                    UserSetupL: Record "User Setup";
                    IsDisplayAll: Boolean;
                begin

                    //<<TMS1.01

                    UserSetupL.Get(UserId);
                    if UserSetupL."Display All Items ELA" then
                        IsDisplayAll := true;
                    //>>TMS1.01

                    Clear(SalesGuide);
                    CashDrawerCheckELA;           //JA 03-15-2010

                    //IF CheckCustomerPOReq THEN
                    SalesGuide.Run(Rec);

                    //<<TMS1.01
                    if IsDisplayAll then begin
                        CurrPage."Sales Order Guide Lines".PAGE.DisplayAllOnAfterValidate(true);
                        DisplayAll := true;
                    end;
                    //>>TMS1.01

                    //    ERROR('Cust. PO No. entry is required for this customer');
                    //  END;

                    //ShowInvoiceLinesTab := TRUE; // TMS1.00
                    //SendKey('%{F6}');
                end;
            }
            action("Enable Display All For Day")
            {
                Caption = 'Enable Display All For Day';
                Image = Task;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    UserSetupL: Record "User Setup";
                begin
                    SetDisplayAll(UserId, true, true, true);//<<TMS1.02
                    CurrPage.Update;
                end;
            }
            action("Disable Display All For Day")
            {
                Caption = 'Disable Display All For Day';
                Image = RemoveLine;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    SetDisplayAll(UserId, false, true, true);//<<TMS1.02
                    CurrPage.Update;
                end;
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Calculate &Invoice Discount")
                {
                    Caption = 'Calculate &Invoice Discount';
                    Image = CalculateInvoiceDiscount;
                    Visible = false;

                    trigger OnAction()
                    begin
                        CurrPage.SalesLines.PAGE.ApproveCalcInvDisc;
                    end;
                }
                action("Get Price")
                {
                    Caption = 'Get Price';
                    Ellipsis = true;

                    trigger OnAction()
                    begin
                        CurrPage.SalesLines.PAGE.ShowPrices
                    end;
                }
                action("Get Li&ne Discount")
                {
                    Caption = 'Get Li&ne Discount';
                    Ellipsis = true;
                    Visible = false;

                    trigger OnAction()
                    begin
                        CurrPage.SalesLines.PAGE.ShowLineDisc
                    end;
                }
                separator(Action172)
                {
                }
                action("E&xplode BOM")
                {
                    Caption = 'E&xplode BOM';
                    Image = ExplodeBOM;
                    Visible = false;

                    trigger OnAction()
                    begin
                        CurrPage.SalesLines.PAGE.ExplodeBOM;
                    end;
                }
                action("Insert &Ext. Text")
                {
                    Caption = 'Insert &Ext. Text';
                    Visible = false;

                    trigger OnAction()
                    begin
                        CurrPage.SalesLines.PAGE.InsertExtendedText(true);
                    end;
                }
                separator(Action176)
                {
                }
                action("Get St&d. Cust. Sales Codes")
                {
                    Caption = 'Get St&d. Cust. Sales Codes';
                    Ellipsis = true;
                    Visible = false;

                    trigger OnAction()
                    var
                        StdCustSalesCode: Record "Standard Customer Sales Code";
                    begin
                        StdCustSalesCode.InsertSalesLines(Rec);
                    end;
                }
                separator(Action171)
                {
                }
                action("&Reserve")
                {
                    Caption = '&Reserve';
                    Ellipsis = true;
                    Visible = false;

                    trigger OnAction()
                    begin
                        CurrPage.SalesLines.PAGE.ShowReserv;
                    end;
                }
                action("Order &Tracking")
                {
                    Caption = 'Order &Tracking';

                    trigger OnAction()
                    begin
                        CurrPage.SalesLines.PAGE.ShowTracking;
                    end;
                }
                separator(Action177)
                {
                }
                action("Nonstoc&k Items")
                {
                    Caption = 'Nonstoc&k Items';
                    Visible = false;

                    trigger OnAction()
                    begin
                        if not UpdateAllowed then
                            exit;

                        CurrPage.SalesLines.PAGE.ShowNonstockItems;
                    end;
                }
                separator(Action192)
                {
                }
                action("Copy Document")
                {
                    Caption = 'Copy Document';
                    Ellipsis = true;
                    Image = CopyDocument;

                    trigger OnAction()
                    begin
                        CopySalesDoc.SetSalesHeader(Rec);
                        CopySalesDoc.RunModal;
                        Clear(CopySalesDoc);
                    end;
                }
                action("Archi&ve Document")
                {
                    Caption = 'Archi&ve Document';
                    Visible = false;

                    trigger OnAction()
                    begin
                        ArchiveManagement.ArchiveSalesDocument(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action("Move Negative Lines")
                {
                    Caption = 'Move Negative Lines';
                    Ellipsis = true;

                    trigger OnAction()
                    begin
                        Clear(MoveNegSalesLines);
                        MoveNegSalesLines.SetSalesHeader(Rec);
                        MoveNegSalesLines.RunModal;
                        MoveNegSalesLines.ShowDocument;
                    end;
                }
                separator(Action195)
                {
                }
                action("Create &Whse. Shipment")
                {
                    Caption = 'Create &Whse. Shipment';
                    Visible = false;

                    trigger OnAction()
                    var
                        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
                    begin
                        GetSourceDocOutbound.CreateFromSalesOrder(Rec);
                    end;
                }
                action("Create Inventor&y Put-away / Pick")
                {
                    Caption = 'Create Inventor&y Put-away / Pick';
                    Ellipsis = true;
                    Image = CreateInventoryPickup;
                    Visible = false;

                    trigger OnAction()
                    begin
                        CreateInvtPutAwayPick;
                    end;
                }
                separator(Action174)
                {
                }
                action("Re&lease")
                {
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    RunObject = Codeunit "Release Sales Document";
                    ShortCutKey = 'Ctrl+F9';
                }
                action("Re&open")
                {
                    Caption = 'Re&open';
                    Image = ReOpen;

                    trigger OnAction()
                    var
                        ReleaseSalesDoc: Codeunit "Release Sales Document";
                    begin
                        ReleaseSalesDoc.Reopen(Rec);
                    end;
                }
                separator(Action175)
                {
                }
                action("&Send BizTalk Sales Order Cnfmn.")
                {
                    Caption = '&Send BizTalk Sales Order Cnfmn.';
                    Visible = false;

                    trigger OnAction()
                    begin
                        ///BizTalkManagement.SendSalesOrderConf(Rec);
                    end;
                }
            }
            action("Order Setup Ticket")
            {
                Caption = 'Order Setup Ticket';
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SalesHead: Record "Sales Header";
                begin
                    SalesHead := Rec;
                    SalesHead.SetFilter("Sell-to Customer No.", '%1', Rec."Sell-to Customer No.");
                    SalesHead.SetRange("Document Type", SalesHead."Document Type"::Order);
                    SalesHead.SetFilter("No.", '%1', Rec."No.");
                    SalesHead.SetRecFilter;

                    //CLEAR(SetupTicket);
                    //SetupTicket.SetOrderDate(Rec."Order Date",Rec."Sell-to Customer No.",Rec."No.");
                    /*
                    NonCashCustRcpt.RUNMODAL;
                    CLEAR(SetupTicket);
                    */
                    //REPORT.RunModal(REPORT::"Order Setup Ticket", false, true, SalesHead);
                    //Clear(SetupTicket);

                end;
            }
            action("Multi Order Setup")
            {
                Caption = 'Multi Order Setup';
                //RunObject = Report "Multi-order Setup Ticket";
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        //DynamicEditable := CurrPage.EDITABLE;
    end;

    trigger OnAfterGetRecord()
    var
        FilterString: Text[255];
    begin
        SetControlVisibility;
        DisplayAll := CheckForDisplayAll; //tms1.02
        FilterString := SetDisplayOptions;
        //IF UsersetupG.GET(USERID) THEN
        //DisplayAll := UserSetup."Display All Items";

        CurrPage."Sales Order Guide Lines".PAGE.SetOrder("No.");
        CurrPage."Sales Order Guide Lines".PAGE.GetStamp(FormUser, TimeStamp);
        if "Sell-to Customer No." > '' then begin
            Clear(LoadItems);
            //<<TMS1.01
            if (CurrPage."Sales Order Guide Lines".PAGE.GetDisplayAll) or (DisplayAll) then begin
                LoadItems.ShowAll(true);
                DisplayAll := true;
                //ELSE
                //TMS1.01                                                          
            end else begin
                DisplayAll := false;
                LoadItems.ShowAll(false);
                //FilterString := CurrPage."Sales Order Guide Lines".FORM.SetSalesTeamFilter; 
                // LoadItems.SetSalesTeamFilter(FilterString);                                  //TMS1.00
                LoadItems.SetSupplyChGrpUsrFilter(FilterString); // tms1.00
            end;
            LoadItems.SetReload(false);
            LoadItems.SetOrderNo("No.");
            LoadItems.SetStamp(FormUser, TimeStamp);
            LoadItems.RunModal;
            CurrPage."Sales Order Guide Lines".PAGE.SetCust("Sell-to Customer No.");
            CurrPage."Sales Order Guide Lines".PAGE.UpdateForm;
            "Sell-to Customer No.Editable" := false;
        end else
            "Sell-to Customer No.Editable" := true;

        if "Payment Method Code" <> 'CREDIT' then
            TicketCt := "No. Printed";
        //  TicketCt := "Pick Ticket Count"; TBR
        //CheckInvoiceLineExists; //tms1.00
    end;

    trigger OnClosePage()
    begin
        SetDisplayAll(UserId, false, false, true);


        if SalesLine."Price After Sale ELA" = true then begin
            SalesLine.SetRange("Document Type", 1);
            SalesLine.SetRange("Document No.", Rec."No.");
            SalesLine.SetRange("Price After Sale ELA", false);
            if SalesLine.FindFirst then
                Error(Text50005);
        end;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.SaveRecord;
        Error('%1', Text50002);

    end;

    trigger OnInit()
    begin
        "Sell-to Customer No.Editable" := true;
        //P800Globals.SetOrderTypeTerminal; TBR

    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        //CheckCreditMaxBeforeInsert;TBR
        //CashDrawerCheck;           //JA 03-15-2010
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Responsibility Center" := UserMgt.GetSalesFilter();
        "Sell-to Customer No.Editable" := true;
    end;

    trigger OnOpenPage()
    begin

        // Logic moved to list Page 37002678

        /*///
        IF UserMgt.GetSalesFilter() <> '' THEN BEGIN
          FILTERGROUP(2);
          SETRANGE("Responsibility Center",UserMgt.GetSalesFilter());
          FILTERGROUP(0);
        END;
        *////
        DisplayAll := CheckForDisplayAll; //tms1.02
        SetRange("Date Filter", 0D, WorkDate);   ///
        OnActivateForm;

        // Logic moved to list Page 37002678
        SetDocNoVisible;

    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        ValidatePriceAfterSale; //EN1.01
    end;

    var
        Text000: Label 'Unable to execute this function while in view only mode.';
        CopySalesDoc: Report "Copy Sales Document";
        MoveNegSalesLines: Report "Move Negative Sales Lines";
        ReportPrint: Codeunit "Test Report-Print";
        DocPrint: Codeunit "Document-Print";
        ArchiveManagement: Codeunit ArchiveManagement;
        SalesSetup: Record "Sales & Receivables Setup";
        ChangeExchangeRate: Page "Change Exchange Rate";
        UserMgt: Codeunit "User Setup Management";
        ItemCategory: array[2] of Code[10];
        ProductGroup: array[2] of Code[10];
        SlsOrderGuideOrdEntry: Record "EN Sales Guide Order Entry";
        DirectCustomer: Record Customer;
        Text50000: Label 'Direct Customer %1 can not be entered here.';
        SalesGuide: Codeunit "EN Sales Guide - Order Entry";
        LoadItems: Report "EN Sales Guide Order Entry";
        Text50001: Label 'Customer cannot be changed';
        UserSetup: Record "User Setup";
        Text50002: Label 'Orders cannot be deleted from here.';
        FormUser: Code[50];
        TimeStamp: DateTime;
        PrinterName: Text[250];
        [InDataSet]
        "Sell-to Customer No.Editable": Boolean;
        DisplayAll: Boolean;
        DisplayFrt1: Boolean;
        DisplayFrt2: Boolean;
        DisplayFrt3: Boolean;
        DisplayVeg1: Boolean;
        DisplayVeg2: Boolean;
        UsersetupG: Record "User Setup";
        SearchItem: Text[30];
        DocNoVisible: Boolean;
        [InDataSet]
        JobQueueVisible: Boolean;
        HasIncomingDocument: Boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        ExternalDocNoMandatory: Boolean;
        /*WSH: Automation;
        [InDataSet]   *///TBR1.04
        ShowInvoiceLinesTab: Boolean;
        TicketCt: Decimal;
        Text50004: Label 'Warning, WORKDATE does not equal TODAY.';
        SalesLine: Record "Sales Line";
        Text50005: Label 'Some, but not all lines on this order are checked as PAS. An order must have all lines or no lines marked as PAS.  Please correct before closing.';


    procedure UpdateAllowed(): Boolean
    begin
        CurrPage.Update;
    end;

    local procedure SelltoCustomerNoOnAfterValidat()
    begin
        CurrPage."Sales Order Guide Lines".PAGE.SetCust("Sell-to Customer No.");
        CurrPage."Sales Order Guide Lines".PAGE.UpdateForm;
        CurrPage.Update;
    end;

    local procedure BilltoCustomerNoOnAfterValidat()
    begin
        CurrPage.Update;
    end;

    local procedure ShortcutDimension1CodeOnAfterV()
    begin
        CurrPage.SalesLines.PAGE.UpdateForm(true);
    end;

    local procedure ShortcutDimension2CodeOnAfterV()
    begin
        CurrPage.SalesLines.PAGE.UpdateForm(true);
    end;

    local procedure OnActivateForm()
    begin
        //P800Globals.SetOrderTypeTerminal; TBR
    end;

    procedure SetDisplayOptions() FilterString: Text[255]
    var
        SalesGuideOrderEntry: Codeunit "EN Sales Guide - Order Entry";
    begin

        FilterString := UserSetup.GetUserSalesTeam; //tms1.00
        FilterString := SalesGuideOrderEntry.GetSupplyChainGroup; // tms1.00
        case FilterString of
            'VEG 1':
                DisplayVeg1 := true;
            'VEG 2':
                DisplayVeg2 := true;
            'FRUIT 1':
                DisplayFrt1 := true;
            'FRUIT 2':
                DisplayFrt2 := true;
            'FRUIT 3':
                DisplayFrt3 := true;
        end;

        if DisplayVeg1 then
            FilterString := FilterString + '|' + 'VEG 1';
        if DisplayVeg2 then
            FilterString := FilterString + '|' + 'VEG 2';
        if DisplayFrt1 then
            FilterString := FilterString + '|' + 'FRUIT 1';
        if DisplayFrt2 then
            FilterString := FilterString + '|' + 'FRUIT 2';
        if DisplayFrt3 then
            FilterString := FilterString + '|' + 'FRUIT 3';

        FilterString := DelChr(FilterString, '<', '|');
    end;


    procedure SendDisplayOptions()
    begin

        CurrPage."Sales Order Guide Lines".PAGE.SetDisplayOptions(DisplayVeg1, DisplayVeg2, DisplayFrt1, DisplayFrt2, DisplayFrt3);
    end;

    local procedure SetDocNoVisible()
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
        DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",Reminder,FinChMemo;
    begin
        DocNoVisible := DocumentNoVisibility.SalesDocumentNoIsVisible(DocType::Order, "No.");
    end;

    local procedure SetControlVisibility()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        JobQueueVisible := "Job Queue Status" = "Job Queue Status"::"Scheduled for Posting";
        HasIncomingDocument := "Incoming Document Entry No." <> 0;
        SetExtDocNoMandatoryCondition;

        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);
    end;

    local procedure SetExtDocNoMandatoryCondition()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get;
        ExternalDocNoMandatory := SalesReceivablesSetup."Ext. Doc. No. Mandatory"
    end;

    procedure SendKey(KeyText: Text[5])
    begin
        /*
        if IsClear(WSH) then
            Create(WSH, true, true);

        WSH.SendKeys(KeyText); */  //TBR1.05
    end;

    procedure CheckInvoiceLineExists()
    var
        lSalesLine: Record "Sales Line";
    begin
        //<<TMS1.00
        lSalesLine.Reset;
        lSalesLine.SetRange("Document Type", Rec."Document Type");
        lSalesLine.SetRange("Document No.", Rec."No.");
        if lSalesLine.CountApprox > 0 then
            ShowInvoiceLinesTab := true
        else
            ShowInvoiceLinesTab := false;
        //>>TMS1.00
    end;


    procedure SetDisplayAll(UserID: Code[50]; SetStatus: Boolean; ForDay: Boolean; CalledFromPage: Boolean)
    var
        UserSetupL: Record "User Setup";
    begin
        //<<TMS1.02
        if UserSetupL.Get(UserID) then begin
            DisplayAll := SetStatus;
            if (UserSetupL."Display All Items ELA") and (not ForDay) and (UserSetupL."Display All Date ELA" = 0D) then
                UserSetupL."Display All Items ELA" := SetStatus;
            if ForDay then begin
                if SetStatus then
                    UserSetupL."Display All Date ELA" := Today
                else
                    UserSetupL."Display All Date ELA" := 0D;

                UserSetupL."Display All Items ELA" := SetStatus;
            end;

            UserSetupL.Modify;
            if CalledFromPage then
                CurrPage."Sales Order Guide Lines".PAGE.DisplayAllOnAfterValidate(DisplayAll);
        end;
        //>>TMS1.02
    end;

    local procedure CheckForDisplayAll(): Boolean
    var
        UserSetupL: Record "User Setup";
    begin
        //<<TMS1.02
        if UserSetupL.Get(UserId) then
            if UserSetupL."Display All Items ELA" then begin
                if (UserSetupL."Display All Date ELA" <> Today) and (UserSetupL."Display All Date ELA" <> 0D) then begin
                    UserSetupL."Display All Date ELA" := 0D;
                    UserSetupL."Display All Items ELA" := false;
                    UserSetupL.Modify;
                    exit(false);
                end;
                exit(true);
            end else
                exit(false);
        //>>TMS1.02
    end;

    local procedure ValidatePriceAfterSale()
    var
        SalesLine: Record "Sales Line";
        CheckPriceAfterSales: Boolean;
        SalesOrder: Page "Sales Order";
    begin
        //<<EN1.01
        Clear(CheckPriceAfterSales);
        SalesLine.SetRange("Document Type", "Document Type"::Order);
        SalesLine.SetRange("Document No.", "No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        //SalesLine.SETRANGE("Gen. Bus. Posting Group", 'PAS');
        //IF NOT SalesLine.ISEMPTY OR  ("Gen. Bus. Posting Group" = 'PAS') THEN
        //  CheckPriceAfterSales := TRUE;
        //SalesLine.SETRANGE("Gen. Bus. Posting Group");
        SalesLine.SetRange("Price After Sale ELA", true);
        if not SalesLine.IsEmpty then
            CheckPriceAfterSales := true;
        if CheckPriceAfterSales then begin
            if "Gen. Bus. Posting Group" <> 'PAS' then
                Error('All line should be enabled for Price After Sales');
            SalesLine.SetRange("Price After Sale ELA");
            if SalesLine.FindSet then
                repeat
                    if SalesLine."Price After Sale ELA" = false then
                        Error('All line should be enabled for Price After Sales');
                until SalesLine.Next = 0;
        end;
        //>>EN1.01
    end;
}

