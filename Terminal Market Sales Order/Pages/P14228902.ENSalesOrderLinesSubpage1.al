page 14228902 "EN Sales Order Lines Subpage1"
{
    AutoSplitKey = true;
    Caption = 'Sales Order Subform';
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Sales Line";
    SourceTableView = WHERE("Document Type" = FILTER(Order));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Type; Type)
                {
                    Visible = false;

                    trigger OnValidate()
                    begin
                        SalesH.Get(1, "Document No.");   //JA 03-15-2010
                        SalesH.CashDrawerCheckELA;  //JA 03-15-2010
                    end;
                }
                field("No."; "No.")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupNoFieldELA(Text)); // PR3.60
                    end;

                    trigger OnValidate()
                    begin
                        SalesH.Get(1, "Document No.");   //JA 03-15-2010
                        SalesH.CashDrawerCheckELA;  //JA 03-15-2010
                        ShowShortcutDimCode(ShortcutDimCode);
                        NoOnAfterValidate;
                    end;
                }
                field("Cross-Reference No."; "Cross-Reference No.")
                {
                    Visible = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    Caption = 'Brand Code';

                    trigger OnValidate()
                    begin
                        SalesH.Get(1, "Document No.");   //JA 03-15-2010
                        SalesH.CashDrawerCheckELA;  //JA 03-15-2010
                    end;
                }
                field("Purchasing Code"; "Purchasing Code")
                {
                    Visible = false;
                }
                field(Nonstock; Nonstock)
                {
                    Visible = false;
                }
                field(Description; Description)
                {

                    trigger OnValidate()
                    begin
                        SalesH.Get(1, "Document No.");   //JA 03-15-2010
                        SalesH.CashDrawerCheckELA;  //JA 03-15-2010
                    end;
                }
                field("Drop Shipment"; "Drop Shipment")
                {
                    Visible = false;
                }
                field("Special Order"; "Special Order")
                {
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                    Visible = false;
                }
                field("Bin Code"; "Bin Code")
                {
                    Visible = false;
                }
                field(Reserve; Reserve)
                {
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ReserveOnAfterValidate;
                    end;
                }
                field(Quantity; Quantity)
                {
                    BlankZero = true;

                    trigger OnValidate()
                    var
                        SalesH: Record "Sales Header";
                    begin
                        SalesH.Get(1, "Document No.");   //JA 03-15-2010
                        SalesH.CashDrawerCheckELA;  //JA 03-15-2010
                        QuantityOnAfterValidate;
                    end;
                }
                field("Reserved Quantity"; "Reserved Quantity")
                {
                    BlankZero = true;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {

                    trigger OnValidate()
                    begin
                        UnitofMeasureCodeOnAfterValida;
                    end;
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    Visible = false;
                }
                field("Unit Cost (LCY)"; "Unit Cost (LCY)")
                {
                    Visible = false;
                }
                field(SalesPriceExist; PriceExists)
                {
                    Caption = 'Sales Price Exists';
                    Editable = false;
                    Visible = false;
                }
                field("Unit Price"; "Unit Price")
                {
                    BlankZero = true;

                    trigger OnValidate()
                    begin
                        SalesH.Get(1, "Document No.");   //JA 03-15-2010
                        SalesH.CashDrawerCheckELA;  //JA 03-15-2010
                    end;
                }
                field("Price After Sale"; "Price After Sale ELA")
                {

                    trigger OnValidate()
                    begin
                        if "Price After Sale ELA" = true then
                            "Unit Price" := 0;
                    end;
                }
                field("Tax Group Code"; "Tax Group Code")
                {
                    Visible = false;
                }
                field("Tax Area Code"; "Tax Area Code")
                {
                    Visible = false;
                }
                field("Tax Liable"; "Tax Liable")
                {
                    Visible = false;
                }
                field("Line Amount"; "Line Amount")
                {
                    BlankZero = true;

                    trigger OnValidate()
                    begin
                        SalesH.Get(1, "Document No.");   //JA 03-15-2010
                        SalesH.CashDrawerCheckELA;  //JA 03-15-2010
                    end;
                }
                field(SalesLineDiscExists; LineDiscExists)
                {
                    Caption = 'Sales Line Disc. Exists';
                    Editable = false;
                    Visible = false;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    Visible = false;
                }
                field("Line Discount %"; "Line Discount %")
                {
                    BlankZero = true;
                    Visible = false;
                }
                field("Line Discount Amount"; "Line Discount Amount")
                {
                    Visible = false;
                }
                field("Allow Invoice Disc."; "Allow Invoice Disc.")
                {
                    Visible = false;
                }
                field("Inv. Discount Amount"; "Inv. Discount Amount")
                {
                    Visible = false;
                }
                field("Qty. to Ship"; "Qty. to Ship")
                {
                    BlankZero = true;
                    Visible = false;
                }
                field("Quantity Shipped"; "Quantity Shipped")
                {
                    BlankZero = true;
                    Visible = false;
                }
                field("Qty. to Invoice"; "Qty. to Invoice")
                {
                    BlankZero = true;
                    Visible = false;
                }
                field("Quantity Invoiced"; "Quantity Invoiced")
                {
                    BlankZero = true;
                    Visible = false;
                }
                field("Allow Item Charge Assignment"; "Allow Item Charge Assignment")
                {
                    Visible = false;
                }
                field("Qty. to Assign"; "Qty. to Assign")
                {
                    BlankZero = true;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        ShowItemChargeAssgnt;
                        UpdateForm(false);
                    end;
                }
                field("Qty. Assigned"; "Qty. Assigned")
                {
                    BlankZero = true;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        ShowItemChargeAssgnt;
                        CurrPage.Update(false);
                    end;
                }
                field("Requested Delivery Date"; "Requested Delivery Date")
                {
                    Visible = false;
                }
                field("Promised Delivery Date"; "Promised Delivery Date")
                {
                    Visible = false;
                }
                field("Planned Delivery Date"; "Planned Delivery Date")
                {
                    Visible = false;
                }
                field("Planned Shipment Date"; "Planned Shipment Date")
                {
                    Visible = false;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    Visible = false;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    Visible = false;
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    Visible = false;
                }
                field("Shipping Time"; "Shipping Time")
                {
                    Visible = false;
                }
                field("Job No."; "Job No.")
                {
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field("Whse. Outstanding Qty. (Base)"; "Whse. Outstanding Qty. (Base)")
                {
                    Visible = false;
                }
                field("Outbound Whse. Handling Time"; "Outbound Whse. Handling Time")
                {
                    Visible = false;
                }
                field("Blanket Order No."; "Blanket Order No.")
                {
                    Visible = false;
                }
                field("Blanket Order Line No."; "Blanket Order Line No.")
                {
                    Visible = false;
                }
                field("FA Posting Date"; "FA Posting Date")
                {
                    Visible = false;
                }
                field("Depr. until FA Posting Date"; "Depr. until FA Posting Date")
                {
                    Visible = false;
                }
                field("Depreciation Book Code"; "Depreciation Book Code")
                {
                    Visible = false;
                }
                field("Use Duplication List"; "Use Duplication List")
                {
                    Visible = false;
                }
                field("Duplicate in Depreciation Book"; "Duplicate in Depreciation Book")
                {
                    Visible = false;
                }
                field("Appl.-from Item Entry"; "Appl.-from Item Entry")
                {
                    Visible = false;
                }
                field("Appl.-to Item Entry"; "Appl.-to Item Entry")
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
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    CaptionClass = '1,2,3';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupShortcutDimCode(3, ShortcutDimCode[3]);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    CaptionClass = '1,2,4';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupShortcutDimCode(4, ShortcutDimCode[4]);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    CaptionClass = '1,2,5';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupShortcutDimCode(5, ShortcutDimCode[5]);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    CaptionClass = '1,2,6';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupShortcutDimCode(6, ShortcutDimCode[6]);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    CaptionClass = '1,2,7';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupShortcutDimCode(7, ShortcutDimCode[7]);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    CaptionClass = '1,2,8';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupShortcutDimCode(8, ShortcutDimCode[8]);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        //  TMS 08042010
        SalesHeader.Get("Document Type", "Document No.");
        if SalesHeader."Cash Drawer No. ELA" <> '' then
            Error('%1', Text50000);
        //
    end;

    trigger OnInit()
    begin
        HideSalesLines := true; //TMS1.00
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        HideSalesLines := false; //TMS1.00
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Type := xRec.Type;
        Clear(ShortcutDimCode);
    end;

    trigger OnOpenPage()
    begin
        SetAltQtyControls; // PPR3.60

        HideSalesLines := true; //TMS1.00
    end;

    var
        SalesHeader: Record "Sales Header";
        SalesPriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        ShortcutDimCode: array[8] of Code[20];
        ItemTotal: Decimal;
        OrderTotal: Decimal;
        SalesH: Record "Sales Header";
        Text50000: Label 'You cannot delete lines from an order that is on a Cash Drawer.';
        [InDataSet]
        "Quantity (Alt.)Visible": Boolean;
        [InDataSet]
        "Qty. to Ship (Alt.)Visible": Boolean;
        [InDataSet]
        "Qty. Shipped (Alt.)Visible": Boolean;
        [InDataSet]
        "Qty. to Invoice (Alt.)Visible": Boolean;
        [InDataSet]
        "Qty. Invoiced (Alt.)Visible": Boolean;
        [InDataSet]
        HideSalesLines: Boolean;

    procedure ApproveCalcInvDisc()
    begin
        CODEUNIT.Run(CODEUNIT::"Sales-Disc. (Yes/No)", Rec);
    end;

    procedure CalcInvDisc()
    begin
        CODEUNIT.Run(CODEUNIT::"Sales-Calc. Discount", Rec);
    end;

    procedure CallItemSalesHistory()
    begin
        // DA0037A
        //RunItemSalesHistory("Sell-to Customer No.","No.");   TBR
    end;

    procedure ContainerTracking()
    begin
        //ContainerSpecification; // PR3.61    TBR
    end;

    procedure ExplodeBOM()
    begin
        CODEUNIT.Run(CODEUNIT::"Sales-Explode BOM", Rec);
    end;

    procedure GetLine(var SalesLine: Record "Sales Line")
    begin
        SalesLine := Rec;
    end;

    procedure InsertContainerCharges()
    begin
        // PR3.61 Begin
        /*CurrPage.SAVERECORD;
        IF ProcessFns.ContainerTrackingInstalled THEN // PR3.61.01
          IF ContainerFns.InsertContainerCharges(Rec) THEN
            CurrPage.UPDATE(TRUE);*///TBR
        // PR3.61 End
        //TBR
    end;

    procedure InsertExtendedText(Unconditionally: Boolean)
    begin
        if TransferExtendedText.SalesCheckIfAnyExtText(Rec, Unconditionally) then begin
            CurrPage.SaveRecord;
            TransferExtendedText.InsertSalesExtText(Rec);
        end;
        if TransferExtendedText.MakeUpdate then
            UpdateForm(true);
    end;

    procedure ItemAvailability(AvailabilityType: Option Date,Variant,Location,Bin)
    begin
        ///upgRec.ItemAvailability(AvailabilityType);
    end;

    procedure ItemChargeAssgnt()
    begin
        Rec.ShowItemChargeAssgnt;
    end;

    procedure OpenItemTrackLines()
    begin
        CurrPage.SaveRecord;
        Rec.OpenItemTrackingLines;
    end;

    procedure OpenPurchOrderForm()
    var
        PurchHeader: Record "Purchase Header";
        PurchOrder: Page "Purchase Order";
    begin
        PurchHeader.SetRange("No.", "Purchase Order No.");
        PurchOrder.SetTableView(PurchHeader);
        PurchOrder.Editable := false;
        PurchOrder.Run;
    end;

    procedure OpenSpecialPurchOrderForm()
    var
        PurchHeader: Record "Purchase Header";
        PurchOrder: Page "Purchase Order";
    begin
        PurchHeader.SetRange("No.", "Special Order Purchase No.");
        PurchOrder.SetTableView(PurchHeader);
        PurchOrder.Editable := false;
        PurchOrder.Run;
    end;

    procedure SetAltQtyControls()
    begin
        // PR3.60 Begin
        /*IF NOT ProcessFns.AltQtyInstalled THEN BEGIN
          "Quantity (Alt.)Visible" := FALSE;
          "Qty. to Ship (Alt.)Visible" := FALSE;
          "Qty. Shipped (Alt.)Visible" := FALSE;
          "Qty. to Invoice (Alt.)Visible" := FALSE;
          "Qty. Invoiced (Alt.)Visible" := FALSE;
        END;*///TBR
        // PR3.60 End

    end;

    procedure ShowDimension()
    begin
        Rec.ShowDimensions;
    end;

    procedure ShowSubItem()
    begin
        //Rec.ShowItemSub;TBR
    end;

    procedure ShowLineDisc()
    begin
        SalesHeader.Get("Document Type", "Document No.");
        SalesPriceCalcMgt.GetSalesLineLineDisc(SalesHeader, Rec);
    end;

    procedure ShowNonstockItems()
    begin
        Rec.ShowNonstock;
    end;

    procedure ShowPrices()
    begin
        SalesHeader.Get("Document Type", "Document No.");
        SalesPriceCalcMgt.GetSalesLinePrice(SalesHeader, Rec);
    end;


    procedure ShowReserv()
    begin
        Find;
        Rec.ShowReservation;
    end;

    procedure ShowReservationEntries()
    begin
        Rec.ShowReservationEntries(true);
    end;

    procedure ShowTracking()
    var
        TrackingForm: Page "Order Tracking";
    begin
        TrackingForm.SetSalesLine(Rec);
        TrackingForm.RunModal;
    end;

    procedure UpdateForm(SetSaveRecord: Boolean)
    begin
        CurrPage.Update(SetSaveRecord);
    end;

    procedure UpdateTotals(Amt: Decimal)
    begin
        OrderTotal := Amt;
    end;

    local procedure NoOnAfterValidate()
    begin
        InsertExtendedText(false);
        InsertContainerCharges;
        if (Type = Type::"Charge (Item)") and ("No." <> xRec."No.") and
           (xRec."No." <> '')
        then
            CurrPage.SaveRecord;
    end;

    local procedure QtytoShipAltOnAfterValidate()
    begin

        CurrPage.SaveRecord;
        //AltQtyMgmt.ValidateSalesAltQtyLine(Rec);TBR
        CurrPage.Update;

    end;

    local procedure QuantityOnAfterValidate()
    begin
        if Reserve = Reserve::Always then begin
            CurrPage.SaveRecord;
            AutoReserve;
            CurrPage.Update(false);
        end;
    end;

    local procedure ReserveOnAfterValidate()
    begin
        if (Reserve = Reserve::Always) and ("Outstanding Qty. (Base)" <> 0) then begin
            CurrPage.SaveRecord;
            AutoReserve;
            CurrPage.Update(false);
        end;
    end;

    local procedure UnitofMeasureCodeOnAfterValida()
    begin
        if Reserve = Reserve::Always then begin
            CurrPage.SaveRecord;
            AutoReserve;
            CurrPage.Update(false);
        end;
    end;
}

