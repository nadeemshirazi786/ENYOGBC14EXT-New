page 51010 "YOG Package Tracking"
{
    AutoSplitKey = true;
    Caption = 'YOG Package Tracking';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    ApplicationArea = All;
    UsageCategory = Documents;
    PageType = Worksheet;
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

                    trigger OnValidate()
                    begin
                        TypeOnAfterValidate;
                        NoOnAfterValidate;
                    end;
                }
                field("No."; "No.")
                {

                    trigger OnValidate()
                    begin
                        ShowShortcutDimCode(ShortcutDimCode);
                        NoOnAfterValidate;
                    end;
                }
                field("Location Code"; "Location Code")
                {
                    QuickEntry = false;

                    trigger OnValidate()
                    begin
                        LocationCodeOnAfterValidate;
                    end;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    QuickEntry = false;

                    trigger OnValidate()
                    begin
                        ShipmentDateOnAfterValidate;
                    end;
                }
                field("Order Template Location"; "Order Template Location")
                {
                    Caption = 'Truck Route Code';
                }
                field("Document No."; "Document No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("SalesHeader.""Sell-to Customer No."""; SalesHeader."Sell-to Customer No.")
                {
                    Caption = 'Sell-to Customer No.';
                    Editable = false;
                }
                field("Line No."; "Line No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field(Description; Description)
                {
                    QuickEntry = false;
                }
                field("Description 2"; "Description 2")
                {
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    BlankZero = true;

                    trigger OnValidate()
                    begin
                        QuantityOnAfterValidate;
                    end;
                }
                field("Green Quantity"; "Green Quantity")
                {
                }
                field("Green Tracking No."; "Green Tracking No.")
                {
                }
                field("Breaking Quantity"; "Breaking Quantity")
                {
                }
                field("Breaking Tracking No."; "Breaking Tracking No.")
                {
                }
                field("No Gas Quantity"; "No Gas Quantity")
                {
                }
                field("No Gas Tracking No."; "No Gas Tracking No.")
                {
                }
                field("Color Quantity"; "Color Quantity")
                {
                }
                field("Color Tracking No."; "Color Tracking No.")
                {
                }
                field("ibGetCustomerName()"; ibGetCustomerName())
                {
                    Caption = 'Customer Name';
                    Editable = false;
                    TableRelation = Customer.Name WHERE("No." = FIELD("Sell-to Customer No."));
                }
                field("SalesHeader.""Ship-to Name"""; SalesHeader."Ship-to Name")
                {
                    Caption = 'Ship-to Name';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                group("Item Availability by")
                {
                    Caption = 'Item Availability by';
                    Image = ItemAvailability;
                    action("<Action3>")
                    {
                        Caption = 'Event';
                        Image = "Event";

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromSalesLine(Rec, ItemAvailFormsMgt.ByEvent)
                        end;
                    }
                    action(Period)
                    {
                        Caption = 'Period';
                        Image = Period;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromSalesLine(Rec, ItemAvailFormsMgt.ByPeriod)
                        end;
                    }
                    action(Variant)
                    {
                        Caption = 'Variant';
                        Image = ItemVariant;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromSalesLine(Rec, ItemAvailFormsMgt.ByVariant)
                        end;
                    }
                    action(Location)
                    {
                        Caption = 'Location';
                        Image = Warehouse;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromSalesLine(Rec, ItemAvailFormsMgt.ByLocation)
                        end;
                    }
                    action("BOM Level")
                    {
                        Caption = 'BOM Level';
                        Image = BOMLevel;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromSalesLine(Rec, ItemAvailFormsMgt.ByBOM)
                        end;
                    }
                }
                action("Reservation Entries")
                {
                    Caption = 'Reservation Entries';
                    Image = ReservationLedger;

                    trigger OnAction()
                    begin
                        ShowReservationEntries(true);
                    end;
                }
                action(ItemTrackingLines)
                {
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Shift+Ctrl+I';

                    trigger OnAction()
                    begin
                        OpenItemTrackingLines;
                    end;
                }
                action("Select Item Substitution")
                {
                    Caption = 'Select Item Substitution';
                    Image = SelectItemSubstitution;

                    trigger OnAction()
                    begin
                        ShowItemSub;
                    end;
                }
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDimensions;
                    end;
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;

                    trigger OnAction()
                    begin
                        ShowLineComments;
                    end;
                }
                action("Item Charge &Assignment")
                {
                    Caption = 'Item Charge &Assignment';

                    trigger OnAction()
                    begin
                        ItemChargeAssgnt;
                    end;
                }
                action("Line Costs")
                {
                    Caption = 'Line Costs';

                    trigger OnAction()
                    begin
                        jfDisplayLineCosts;
                    end;
                }
                action("Item Properties")
                {
                    Caption = 'Item Properties';
                    Image = ServiceItemWorksheet;

                    trigger OnAction()
                    begin
                        jfSalesItemProperties;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        ldecPct: Decimal;
        lblnItemTracking: Boolean;
    begin
        ShowShortcutDimCode(ShortcutDimCode);
        jfCalculateNetUnitPrice(gdecNetUnitAmount, gdecNetTotalAmount, gdecRebateUnitAmt, gdecNetUnitAmountBaseUOM, true);
        jfCalcDeliveredPrice(gdecDeliveredPrice);
        jfCalcPurchRebateUnitRate(gdecPurchRebateUnitRate);
        ldecPct := Round(doTrackingExistsELA("Quantity (Base)", lblnItemTracking));
        if SalesHeader.Get("Document Type", "Document No.") then;

    end;

    trigger OnDeleteRecord(): Boolean
    var
        ReserveSalesLine: Codeunit "Sales Line-Reserve";
    begin
        if (Quantity <> 0) and ItemExists("No.") then begin
            Commit;
            if not ReserveSalesLine.DeleteLineConfirm(Rec) then
                exit(false);
            ReserveSalesLine.DeleteLine(Rec);
        end;
    end;

    trigger OnInit()
    begin
        QtySecondaryBaseUOMEditable := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        InitType;
        Clear(ShortcutDimCode);
        jfCalculateNetUnitPrice(gdecNetUnitAmount, gdecNetTotalAmount, gdecRebateUnitAmt, gdecNetUnitAmountBaseUOM, true);
        jfCalcPurchRebateUnitRate(gdecPurchRebateUnitRate);
    end;

    var
        SalesHeader: Record "Sales Header";
        SalesPriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        ShortcutDimCode: array[8] of Code[20];
        Text001: Label 'You cannot use the Explode BOM function because a prepayment of the sales order has been invoiced.';
        gcduICMgmt: Codeunit BananaWrkshtCustomFunctions;
        gdecNetTotalAmount: Decimal;
        gdecNetUnitAmount: Decimal;
        gdecRebateUnitAmt: Decimal;
        gdecDeliveredPrice: Decimal;
        gdecNetUnitAmountBaseUOM: Decimal;
        [InDataSet]
        ItemPanelVisible: Boolean;
        [InDataSet]
        QtySecondaryBaseUOMEditable: Boolean;
        gdecPurchRebateUnitRate: Decimal;
        txtTrackingStatus: Code[10];
        StyleTxt: Text;
        gtxtCustomerName: Text[50];

    [Scope('Internal')]
    procedure ApproveCalcInvDisc()
    begin
        CODEUNIT.Run(CODEUNIT::"Sales-Disc. (Yes/No)", Rec);
    end;

    [Scope('Internal')]
    procedure CalcInvDisc()
    begin
        CODEUNIT.Run(CODEUNIT::"Sales-Calc. Discount", Rec);
    end;

    [Scope('Internal')]
    procedure ExplodeBOM()
    begin
        if "Prepmt. Amt. Inv." <> 0 then
            Error(Text001);
        CODEUNIT.Run(CODEUNIT::"Sales-Explode BOM", Rec);
    end;

    [Scope('Internal')]
    procedure OpenPurchOrderForm()
    var
        PurchHeader: Record "Purchase Header";
        PurchOrder: Page "Purchase Order";
    begin
        TestField("Purchase Order No.");
        PurchHeader.SetRange("No.", "Purchase Order No.");
        PurchOrder.SetTableView(PurchHeader);
        PurchOrder.Editable := false;
        PurchOrder.Run;
    end;

    [Scope('Internal')]
    procedure OpenSpecialPurchOrderForm()
    var
        PurchHeader: Record "Purchase Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchOrder: Page "Purchase Order";
    begin
        TestField("Special Order Purchase No.");
        PurchHeader.SetRange("No.", "Special Order Purchase No.");
        if not PurchHeader.IsEmpty then begin
            PurchOrder.SetTableView(PurchHeader);
            PurchOrder.Editable := false;
            PurchOrder.Run;
        end else begin
            PurchRcptHeader.SetRange("Order No.", "Special Order Purchase No.");
            if PurchRcptHeader.Count = 1 then
                PAGE.Run(PAGE::"Posted Purchase Receipt", PurchRcptHeader)
            else
                PAGE.Run(PAGE::"Posted Purchase Receipts", PurchRcptHeader);
        end;
    end;

    [Scope('Internal')]
    procedure InsertExtendedText(Unconditionally: Boolean)
    begin
        if TransferExtendedText.SalesCheckIfAnyExtText(Rec, Unconditionally) then begin
            CurrPage.SaveRecord;
            Commit;
            TransferExtendedText.InsertSalesExtText(Rec);
        end;
        if TransferExtendedText.MakeUpdate then
            UpdateForm(true);
    end;

    [Scope('Internal')]
    procedure ShowNonstockItems()
    begin
        ShowNonstock;
    end;

    [Scope('Internal')]
    procedure ShowTracking()
    var
        TrackingForm: Page "Order Tracking";
    begin
        TrackingForm.SetSalesLine(Rec);
        TrackingForm.RunModal;
    end;

    [Scope('Internal')]
    procedure ItemChargeAssgnt()
    begin
        ShowItemChargeAssgnt;
    end;

    [Scope('Internal')]
    procedure UpdateForm(SetSaveRecord: Boolean)
    begin
        CurrPage.Update(SetSaveRecord);
    end;

    [Scope('Internal')]
    procedure ShowPrices()
    begin
        SalesHeader.Get("Document Type", "Document No.");
        Clear(SalesPriceCalcMgt);
        SalesPriceCalcMgt.GetSalesLinePrice(SalesHeader, Rec);
    end;

    [Scope('Internal')]
    procedure ShowLineDisc()
    begin
        SalesHeader.Get("Document Type", "Document No.");
        Clear(SalesPriceCalcMgt);
        SalesPriceCalcMgt.GetSalesLineLineDisc(SalesHeader, Rec);
    end;

    [Scope('Internal')]
    procedure OrderPromisingLine()
    var
        OrderPromisingLine: Record "Order Promising Line" temporary;
        OrderPromisingLines: Page "Order Promising Lines";
    begin
        OrderPromisingLine.SetRange("Source Type", "Document Type");
        OrderPromisingLine.SetRange("Source ID", "Document No.");
        OrderPromisingLine.SetRange("Source Line No.", "Line No.");

        OrderPromisingLines.SetSourceType(OrderPromisingLine."Source Type"::Sales);
        OrderPromisingLines.SetTableView(OrderPromisingLine);
        OrderPromisingLines.RunModal;
    end;

    [Scope('Internal')]
    procedure JFShowLineRebates()
    begin

    end;

    [Scope('Internal')]
    procedure jfmgCallResetItemCharge()
    begin
        jfmgResetItemChargeLine;
    end;

    [Scope('Internal')]
    procedure jfDisplayLineCosts()
    begin
    end;

    [Scope('Internal')]
    procedure jfCallDisplayUserDefFields()
    begin
    end;

    local procedure TypeOnAfterValidate()
    begin
        ItemPanelVisible := Type = Type::Item;
    end;

    local procedure NoOnAfterValidate()
    begin
        InsertExtendedText(false);
        if (Type = Type::"Charge (Item)") and ("No." <> xRec."No.") and
           (xRec."No." <> '')
        then
            CurrPage.SaveRecord;

        SaveAndAutoAsmToOrder;

        if (Reserve = Reserve::Always) and
           ("Outstanding Qty. (Base)" <> 0) and
           ("No." <> xRec."No.")
        then begin
            CurrPage.SaveRecord;
            AutoReserve;
            CurrPage.Update(false);
        end;
        CurrPage.Update(true);
    end;

    local procedure CrossReferenceNoOnAfterValidat()
    begin
        InsertExtendedText(false);
        CurrPage.Update(true);
    end;

    local procedure VariantCodeOnAfterValidate()
    begin
        SaveAndAutoAsmToOrder;
    end;

    local procedure LocationCodeOnAfterValidate()
    begin
        SaveAndAutoAsmToOrder;

        if (Reserve = Reserve::Always) and
           ("Outstanding Qty. (Base)" <> 0) and
           ("Location Code" <> xRec."Location Code")
        then begin
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

    local procedure QuantityOnAfterValidate()
    var
        UpdateIsDone: Boolean;
    begin
        if Type = Type::Item then
            case Reserve of
                Reserve::Always:
                    begin
                        CurrPage.SaveRecord;
                        AutoReserve;
                        CurrPage.Update(false);
                        UpdateIsDone := true;
                    end;
                Reserve::Optional:
                    if (Quantity < xRec.Quantity) and (xRec.Quantity > 0) then begin
                        CurrPage.SaveRecord;
                        CurrPage.Update(false);
                        UpdateIsDone := true;
                    end;
            end;

        if (Type = Type::Item) and
           (Quantity <> xRec.Quantity) and
           not UpdateIsDone
        then
            CurrPage.Update(true);
        if Type = Type::Item then begin
            CurrPage.Update(true);
        end;
    end;

    local procedure QtyToAsmToOrderOnAfterValidate()
    begin
        CurrPage.SaveRecord;
        if Reserve = Reserve::Always then
            AutoReserve;
        CurrPage.Update(true);
    end;

    local procedure RequestedOrderQtyOnAfterValida()
    var
        UpdateIsDone: Boolean;
    begin
        if Type = Type::Item then
            case Reserve of
                Reserve::Always:
                    begin
                        CurrPage.SaveRecord;
                        AutoReserve;
                        CurrPage.Update(false);
                        UpdateIsDone := true;
                    end;
                Reserve::Optional:
                    if (Quantity < xRec.Quantity) and (xRec.Quantity > 0) then begin
                        CurrPage.SaveRecord;
                        CurrPage.Update(false);
                        UpdateIsDone := true;
                    end;
            end;

        if (Type = Type::Item) and
           (Quantity <> xRec.Quantity) and
           not UpdateIsDone
        then
            CurrPage.Update(true);

        if Type = Type::Item then begin
            CurrPage.Update(true);
        end;
    end;

    local procedure StdPackQuantityOnAfterValidate()
    begin
        if Type = Type::Item then begin
            CurrPage.Update(true);
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

    local procedure LineDiscount37OnAfterValidate()
    begin
        if Type = Type::Item then begin
            CurrPage.Update(true);
        end;
    end;

    local procedure LineDiscountAmountOnAfterValid()
    begin
        if Type = Type::Item then begin
            CurrPage.Update(true);
        end;
    end;

    local procedure ShipmentDateOnAfterValidate()
    begin
        if (Reserve = Reserve::Always) and
           ("Outstanding Qty. (Base)" <> 0) and
           ("Shipment Date" <> xRec."Shipment Date")
        then begin
            CurrPage.SaveRecord;
            AutoReserve;
            CurrPage.Update(false);
        end;
    end;

    local procedure SaveAndAutoAsmToOrder()
    begin
        if (Type = Type::Item) and IsAsmToOrderRequired then begin
            CurrPage.SaveRecord;
            AutoAsmToOrder;
            CurrPage.Update(false);
        end;
    end;

    [Scope('Internal')]
    procedure jfSalesItemProperties()
    begin
        jfShowItemProperties;
    end;

    [Scope('Internal')]
    procedure isGetUomSizeCode(): Code[10]
    var
        lrecItemUOM: Record "Item Unit of Measure";
    begin
        if Type <> Type::Item then exit('');
        if "No." = '' then exit('');
        if "Unit of Measure Code" = '' then exit('');
        if lrecItemUOM.Get("No.", "Unit of Measure Code") then;
        exit(lrecItemUOM."Item UOM Size Code ELA");
    end;

    [Scope('Internal')]
    procedure ibGetCustomerName(): Text[50]
    var
        lrecCustomer: Record Customer;
    begin
        if lrecCustomer.Get(SalesHeader."Sell-to Customer No.") then begin
            exit(lrecCustomer.Name);
        end else begin
            exit('');
        end;
    end;
}

