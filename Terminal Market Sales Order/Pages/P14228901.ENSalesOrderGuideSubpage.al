page 14228901 "EN Sales Order Guide Subpage"
{

    Caption = 'Sales Order Guide Subform';
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "EN Sales Guide Order Entry";
    SourceTableTemporary = false;

    layout
    {
        area(content)
        {
            group(Control1000000000)
            {
                ShowCaption = false;
                field(SearchItemtext; SearchItemtext)
                {
                    Caption = 'Filter Item No.';
                    QuickEntry = false;

                    trigger OnValidate()
                    begin
                        //TMS1.00
                        if SearchItemtext <> '' then
                            //  SETFILTER("Item No.",'%1','@*' +SearchItemtext+ '*')
                            SetFilter("Item No.", '%1', SearchItemtext + '*')
                        else
                            SetRange("Item No.");

                        CurrPage.Update(false);
                        //TMS1.00
                    end;
                }
            }
            repeater(Control1102603000)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    Caption = 'No.';
                    Editable = false;
                    QuickEntry = true;
                    Visible = "Item No.Visible";
                    Width = 20;
                }
                field(Description; Description)
                {
                    Editable = false;
                    QuickEntry = false;
                    Visible = DescriptionVisible;
                }
                field("Variant Code"; "Item Variant Code")
                {
                    Caption = 'Brand Code';
                    Editable = false;
                    Lookup = true;
                    QuickEntry = false;
                    TableRelation = "Item Variant"."Item No." WHERE("Item No." = FIELD("Item No."));
                    Visible = "Variant CodeVisible";
                    Width = 15;
                }
                field("Country/Region of Origin Code"; "Country/Region of Origin Code")
                {
                    QuickEntry = false;
                    Width = 10;
                }
                field("Description 2"; "Description 2")
                {
                    Editable = false;
                    QuickEntry = false;
                    Visible = false;
                }
                field(Clearance; Clearance)
                {
                    QuickEntry = false;
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                    Visible = false;
                }
                field("Quantity To Order"; QtyToOrder)
                {
                    BlankZero = true;
                    Caption = 'Order Quantity';
                    DecimalPlaces = 0 : 2;

                    trigger OnValidate()
                    var
                        SalesH: Record "Sales Header";
                    begin
                        SalesH.Get(1, OrderNo);   //JA 03-15-2010
                        SalesH.CashDrawerCheckELA;  //JA 03-15-2010

                        if QtyToOrder > QtyAvailable then
                            Message('You are OVERSELLING Item %1 Brand %2', "Item No.", "Item Variant Code");
                        Quantity := QtyToOrder;
                        Modify;
                        QtyToOrder := 0;

                        UpdateUnitPrice(FieldNo(Quantity));
                        QtyToOrderOnAfterValidate;

                        //TMS1.00
                        Clear(SearchItemtext);
                        SetRange(Description);
                        CurrPage.Update(false);
                        //TMS1.00

                    end;
                }
                field("Unit Price"; "Unit Price")
                {
                    Caption = 'Unit Price';
                    Visible = "Unit PriceVisible";
                }
                field("Quantity Available"; QtyAvailable)
                {
                    DecimalPlaces = 0 : 0;
                    Editable = false;
                    QuickEntry = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field(Inventory; Inventory)
                {
                    Caption = 'Quantity on Hand';
                    Editable = false;
                    QuickEntry = false;
                }
                field("Qty. on Sales Order"; "Qty. on Sales Order")
                {
                    Editable = false;
                    QuickEntry = false;
                    Style = Favorable;
                    StyleExpr = TRUE;
                    Width = 15;
                }
                field("Qty. on Purch. Order"; "Qty. on Purch. Order")
                {
                    Caption = 'Qty. on Purch. Order';
                    Editable = false;
                    QuickEntry = false;
                    Style = Attention;
                    StyleExpr = TRUE;
                    Width = 15;
                }
                field("Last Order Date"; LastOrderDate)
                {
                    Caption = 'Last Shipped Date';
                    Editable = false;
                    QuickEntry = false;
                }
                field("Last Order Unit Price"; LastOrderUnitPrice)
                {
                    Caption = 'Last Shipped Unit Price';
                    Editable = false;
                    QuickEntry = false;
                    Width = 15;
                }
                field("Last Order Quantity Shipped"; LastOrderQtyShipped)
                {
                    DecimalPlaces = 0 : 0;
                    Editable = false;
                    QuickEntry = false;
                }
                field("Supply Chain Group Code"; "Supply Chain Group Code")
                {
                    Caption = 'Sales Team';
                    Editable = false;
                    Enabled = false;
                    QuickEntry = false;
                    Visible = true;
                }
                field("Sales Unit of Measure"; "Sales Unit of Measure")
                {
                    Caption = 'Sales Unit of Measure';
                    Editable = false;
                    QuickEntry = false;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        UpdateDisplay;
    end;

    trigger OnClosePage()
    begin
        //DisplayAll := FALSE;      TBR
        EmptySlsGuideOrder();
    end;

    trigger OnInit()
    begin
        "Unit PriceVisible" := true;
        DescriptionVisible := true;
        "Variant CodeVisible" := true;
        "Item No.Visible" := true;
        FormUserID := UserId;
        FormStart := CurrentDateTime;
    end;

    trigger OnOpenPage()
    begin
        "Item No.Visible" := true;
        "Variant CodeVisible" := true;
        DescriptionVisible := true;
        "Unit PriceVisible" := true;

        //CurrForm.Quantity.VISIBLE(TRUE);      TBR
    end;

    var
        QtyToOrder: Decimal;
        OrderUOM: Code[10];
        SlsOrderGuideOrdEntry: Record "EN Sales Guide Order Entry";
        OrderGuideMgmt: Codeunit "EN Sales Guide - Order Entry";
        VariantCode: Code[10];
        QtyAvailable: Decimal;
        LastOrderDate: Date;
        LastOrderUnitPrice: Decimal;
        LastOrderQtyShipped: Decimal;
        SearchItemLedgEntry: Record "Item Ledger Entry";
        SalespersonFilter: Code[10];
        ItemT: Record Item;
        ItemCategoryFilter: Code[10];
        ProductGroupFilter: Code[10];
        SalesGuideOrderEntry1: Record "EN Sales Guide Order Entry";
        CustNo: Code[20];
        SalesPriceMgt: Codeunit "Sales Price Calc. Mgt.";
        LoadItems: Report "EN Sales Guide Order Entry";
        DisplayAll: Boolean;
        OrderNo: Code[20];
        SalesLine: Record "Sales Line" temporary;
        DisplayFrt1: Boolean;
        DisplayFrt2: Boolean;
        DisplayFrt3: Boolean;
        DisplayVeg1: Boolean;
        DisplayVeg2: Boolean;
        UserSetup: Record "User Setup";
        FormUserID: Code[50];
        FormStart: DateTime;
        [InDataSet]
        "Item No.Visible": Boolean;
        [InDataSet]
        "Variant CodeVisible": Boolean;
        [InDataSet]
        DescriptionVisible: Boolean;
        [InDataSet]
        "Unit PriceVisible": Boolean;
        SearchItemtext: Text[30];

    procedure UpdateFrmSlsGuideOrderEntry()
    begin
        // UpdateFrmSlsGuideOrderEntry
        if OrderNo = '' then      //TMS11-21-17
            exit;                   //TMS11-21-17
        SlsOrderGuideOrdEntry.SetRange("Order No.", OrderNo);
        SlsOrderGuideOrdEntry.SetRange("Item No.", "Item No.");
        SlsOrderGuideOrdEntry.SetFilter("Item Variant Code", '=%1', "Item Variant Code");
        SlsOrderGuideOrdEntry.SetRange("Country/Region of Origin Code", "Country/Region of Origin Code");  //84732

        if SlsOrderGuideOrdEntry.Find('-') then begin
            OrderUOM := SlsOrderGuideOrdEntry."Sales Unit of Measure";
            QtyToOrder := SlsOrderGuideOrdEntry.Quantity;
            LastOrderDate := SlsOrderGuideOrdEntry."Last Order Date";
            LastOrderUnitPrice := SlsOrderGuideOrdEntry."Last Order Unit Price";
            LastOrderQtyShipped := SlsOrderGuideOrdEntry."Last Order Quantity Shipped";
            FindLastValues();
        end else begin
            OrderUOM := '';
            QtyToOrder := 0;
        end;
    end;

    procedure UpdateDisplay()
    var
        LSalesLine: Record "Sales Line";
    begin
        // UpdateDisplay;
        SetRange("Date Filter", 0D, WorkDate);
        CalcFields("Qty. on Sales Order", Inventory, "Qty. on Purch. Order");
        ///
        LSalesLine.Reset;
        LSalesLine.SetRange("Document Type", LSalesLine."Document Type"::Order);
        LSalesLine.SetRange(Type, LSalesLine.Type::Item);
        LSalesLine.SetRange("No.", "Item No.");
        LSalesLine.SetRange("Variant Code", "Item Variant Code");
        LSalesLine.SetRange("Drop Shipment", false);
        //LSalesLine.SETRANGE("Country/Region of Origin Code","Country/Region of Origin Code");TBR
        LSalesLine.SetRange("Shipment Date", 0D, WorkDate);
        LSalesLine.CalcSums("Outstanding Qty. (Base)");
        QtyAvailable := Inventory - LSalesLine."Outstanding Qty. (Base)";
        ///
        ///QtyAvailable :=  Inventory - "Qty. on Sales Order");
        FindLastValues;
        UpdateFrmSlsGuideOrderEntry;
        if QtyToOrder = 0 then begin            //TMS to stop repricing line after qty entered
            GetUnitPrice;
        end;
    end;

    procedure FindLastValues()
    begin
        // FindLastValues
        if CustNo = '' then
            exit;

        //SearchItemLedgEntry.SETCURRENTKEY("Item No.","Variant Code","Drop Shipment","Location Code","Posting Date");
        SearchItemLedgEntry.SetCurrentKey("Entry Type", "Item No.", "Variant Code", "Source Type", "Source No.", "Posting Date");
        SearchItemLedgEntry.SetRange("Item No.", "Item No.");
        SearchItemLedgEntry.SetRange("Entry Type", SearchItemLedgEntry."Entry Type"::Sale);
        SearchItemLedgEntry.SetRange("Source No.", CustNo);
        SearchItemLedgEntry.SetRange("Source Type", SearchItemLedgEntry."Source Type"::Customer);

        SearchItemLedgEntry.SetFilter("Variant Code", '=%1', "Item Variant Code");

        if SearchItemLedgEntry.Find('+') then begin
            LastOrderDate := SearchItemLedgEntry."Posting Date";
            LastOrderQtyShipped := -SearchItemLedgEntry.Quantity;
            if LastOrderQtyShipped = 0 then
                LastOrderUnitPrice := 0
            else begin
                SearchItemLedgEntry.CalcFields("Sales Amount (Actual)");
                SearchItemLedgEntry.CalcFields("Sales Amount (Expected)");
                if SearchItemLedgEntry."Sales Amount (Actual)" <> 0 then
                    LastOrderUnitPrice := SearchItemLedgEntry."Sales Amount (Actual)" / LastOrderQtyShipped
                else
                    LastOrderUnitPrice := SearchItemLedgEntry."Sales Amount (Expected)" / LastOrderQtyShipped;
            end;
        end;
    end;

    procedure EmptySlsGuideOrder()
    begin
        // EmptySlsGuideOrder()

        SlsOrderGuideOrdEntry.Reset;
        //84732 Begin
        //SlsOrderGuideOrdEntry.SETRANGE("Order No.","Order No.");
        SlsOrderGuideOrdEntry.SetCurrentKey("User ID", "Form Start");
        SlsOrderGuideOrdEntry.SetRange("User ID", FormUserID);
        SlsOrderGuideOrdEntry.SetRange("Form Start", FormStart);
        if not SlsOrderGuideOrdEntry.IsEmpty then
            //84732 End
            SlsOrderGuideOrdEntry.DeleteAll(true);
    end;

    procedure GetUnitPrice(): Decimal
    var
        TempSalesPrice2: Record "Sales Price" temporary;
        Customer: Record Customer;
        Item: Record Item;
        SH: Record "Sales Header";
        SalesPriceCalc: Codeunit "Sales Price Calc. Mgt.";
        SalesLine: Record "Sales Line";
        ItemUOM: Record "Item Unit of Measure";
    begin
        /*
        IF CustNo = '' THEN
          "Unit Price" := 0
        ELSE
          BEGIN
            IF "Unit Price" <> 0 THEN
              EXIT;
            Item.GET("Item No.");
            Customer.GET(CustNo);
            ItemMarketPrice.SETRANGE("Item No.","Item No.");
            ItemMarketPrice.SETFILTER("Variant Code",'=%1',"Item Variant Code");
            ItemMarketPrice.SETFILTER("Effective Date",'<=%1',WORKDATE);
            IF ItemMarketPrice.FIND('+') THEN
              "Unit Price" := ItemMarketPrice."Market Price"
            ELSE BEGIN
              Item.GET("Item No.");
              "Unit Price" := Item."Unit Price";
            END;
          END;
         */

        //JA begin 20080429
        if CustNo = '' then
            "Unit Price" := 0
        else
            if OrderNo = '' then      //TMS11-21-17
                exit                         //TMS11-21-17
            else begin
                SH.Get(1, OrderNo);
                SalesLine."Document Type" := 1;
                SalesLine."Document No." := SH."No.";
                SalesLine."Sell-to Customer No." := SH."Sell-to Customer No.";
                SalesLine."Bill-to Customer No." := SH."Bill-to Customer No.";
                SalesLine."Customer Price Group" := SH."Customer Price Group";
                SalesLine.Type := SalesLine.Type::Item;
                SalesLine."No." := "Item No.";
                SalesLine.Quantity := 1;
                SalesLine."Unit of Measure Code" := "Sales Unit of Measure";
                SalesLine."Variant Code" := "Item Variant Code";
                ItemUOM.Get("Item No.", "Sales Unit of Measure");
                SalesLine."Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
                SalesLine."Quantity (Base)" := Round(SalesLine.Quantity * SalesLine."Qty. per Unit of Measure", 0.00001);
                SalesPriceCalc.FindSalesLinePrice(SH, SalesLine, 0);
                SalesPriceCalc.FindSalesLinePrice(SH, SalesLine, 0);
                "Unit Price" := SalesLine."Unit Price";
            end;
        //JA end

    end;

    procedure SetCust("Customer No.": Code[20])
    begin

        CustNo := "Customer No.";
    end;

    procedure UpdateForm()
    begin
        CurrPage.Update(true);
    end;

    procedure SetOrder(SalesOrderNo: Code[20])
    begin
        OrderNo := SalesOrderNo;
    end;

    procedure GetDisplayAll(): Boolean
    begin

        exit(DisplayAll);
    end;

    procedure SetDisplayAll(All: Boolean)
    begin
        DisplayAll := All
    end;

    procedure ChangeSalesTeamFilter()
    var
        Item: Record Item;
        FilterString: Text[255];
        sgoe: Record "EN Sales Guide Order Entry";
    begin
        //84732
        /* //tms1.00
        Item.SETRANGE("Supply Chain Group Code",UserSetup.GetUserSalesTeam);
        FilterString := SetSalesTeamFilter;
        CLEAR(LoadItems);
        LoadItems.SetStamp(FormUserID,FormStart);
        LoadItems.SetSalesTeamFilter(FilterString);
        LoadItems.SetReload(TRUE);
        LoadItems.SetOrderNo(OrderNo);
        LoadItems.RUNMODAL;
        */ // tms1.00

    end;

    procedure ChangeSuppChainGrpUserFilter()
    var
        FilterString: Text[255];
    begin
        //<<tms1.00
        FilterString := SetSupplyChainGrpFilter; // tms1.00
        Clear(LoadItems);
        LoadItems.SetStamp(FormUserID, FormStart);
        LoadItems.SetSupplyChGrpUsrFilter(FilterString);
        LoadItems.SetReload(true);
        LoadItems.SetOrderNo(OrderNo);
        LoadItems.RunModal;
        //>>tms1.00
    end;

    procedure GetStamp(var FormUser: Code[50]; var TimeStamp: DateTime)
    begin
        //84732
        FormUser := FormUserID;
        TimeStamp := FormStart;
    end;

    procedure SetSalesTeamFilter() FilterString: Text[255]
    begin
        //<<tms1.00
        /*
        //84732
        FilterString := UserSetup.GetUserSalesTeam;
        
        CASE FilterString OF
          'VEG1': DisplayVeg1 := TRUE;
          'VEG2': DisplayVeg2 := TRUE;
          'FRUIT1': DisplayFrt1 := TRUE;
          'FRUIT2': DisplayFrt2 := TRUE;
          'FRUIT3': DisplayFrt3 := TRUE;
        END;
        IF DisplayVeg1 THEN
          FilterString := FilterString + '|' + 'VEG1';
        IF DisplayVeg2 THEN
          FilterString := FilterString + '|' + 'VEG2';
        IF DisplayFrt1 THEN
          FilterString := FilterString + '|' + 'FRUIT1';
        IF DisplayFrt2 THEN
          FilterString := FilterString + '|' + 'FRUIT2';
        IF DisplayFrt3 THEN
          FilterString := FilterString + '|' + 'FRUIT3';
        
        FilterString := DELCHR(FilterString,'<','|');
        */ // tms1.00

    end;

    procedure SetSupplyChainGrpFilter() FilterString: Text[255]
    begin
        //<<tms1.00
        //FilterString := SupplyChainGroupUser.GetSupplyChainGroup;

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
        //>>tms1.00
    end;

    local procedure QtyToOrderOnAfterValidate()
    begin
        UpdateFrmSlsGuideOrderEntry;
    end;

    procedure DisplayAllOnAfterValidate(InputParamP: Boolean)
    var
        sgoe: Record "EN Sales Guide Order Entry";
    begin
        DisplayAll := InputParamP;
        Clear(LoadItems);
        LoadItems.ShowAll(DisplayAll);
        LoadItems.SetStamp(FormUserID, FormStart);
        LoadItems.SetReload(true);
        LoadItems.SetOrderNo(OrderNo);
        LoadItems.RunModal;
        CurrPage.Update;
    end;

    procedure DisplayVeg1OnAfterValidate(InputParamP: Boolean)
    begin
        DisplayVeg1 := InputParamP;
        //ChangeSalesTeamFilter; //84732 //tms1.00
        ChangeSuppChainGrpUserFilter; // tms1.00
        CurrPage.Update;
    end;

    procedure DisplayVeg2OnAfterValidate(InputParamP: Boolean)
    begin
        DisplayVeg2 := InputParamP;
        //ChangeSalesTeamFilter; //84732 // tms1.00
        ChangeSuppChainGrpUserFilter; //tms1.00
        CurrPage.Update;
    end;

    procedure DisplayFrt1OnAfterValidate(InputParamP: Boolean)
    begin
        DisplayFrt1 := InputParamP;
        //ChangeSalesTeamFilter; //84732 // tms1.00
        ChangeSuppChainGrpUserFilter; //tms1.00
        CurrPage.Update;
    end;

    procedure DisplayFrt2OnAfterValidate(InputParamP: Boolean)
    begin
        DisplayFrt2 := InputParamP;
        //ChangeSalesTeamFilter; //84732 // tms1.00
        ChangeSuppChainGrpUserFilter; //tms1.00
        CurrPage.Update;
    end;

    procedure DisplayFrt3OnAfterValidate(InputParamP: Boolean)
    begin
        DisplayFrt3 := InputParamP;
        // ChangeSalesTeamFilter; //84732 // tms1.00
        ChangeSuppChainGrpUserFilter; //tms1.00
        CurrPage.Update;
    end;

    procedure SetDisplayOptions(var DisplayVeg1P: Boolean; var DisplayVeg2P: Boolean; var DisplayFrt1P: Boolean; var DisplayFrt2P: Boolean; var DisplayFrt3P: Boolean)
    var
        FilterString: Text[255];
    begin

        DisplayVeg1 := DisplayVeg1P;
        DisplayVeg2 := DisplayVeg2P;
        DisplayFrt1 := DisplayFrt1P;
        DisplayFrt2 := DisplayFrt2P;
        DisplayFrt3 := DisplayFrt3P;
        // ChangeSalesTeamFilter; //84732 // tms1.00
        //ChangeSuppChainGrpUserFilter; //tms1.00
        //FilterString := SetSupplyChainGrpFilter; //tms1.00
        ChangeSuppChainGrpUserFilter;
        CurrPage.Update;
    end;

    procedure SetItemSearchFilter(ItemSearchText: Text[30])
    begin
        if ItemSearchText <> '' then begin
            Message(ItemSearchText);
            SlsOrderGuideOrdEntry.SetFilter(Description, '%1', '*' + ItemSearchText + '*');
            SlsOrderGuideOrdEntry.FindSet;
        end else
            SlsOrderGuideOrdEntry.FindSet;
    end;
}

