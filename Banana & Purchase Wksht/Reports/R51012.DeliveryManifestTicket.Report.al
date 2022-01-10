report 51012 "Delivery Manifest Ticket"
{
    // EN1.00 2020-12-04 KS
    //   Changed "Unit of Measure" Field to "Unit of Measure Code"
    // EN1.00 2019-12-16 HR
    //   Added Columns from Sales Header and Sales Line. Just those records that are being used for grouping.
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './DeliveryManifestTicket.rdl';
    Caption = 'Delivery Manifest Ticket';

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            CalcFields = Amount, "Amount Including VAT", "Invoice Discount Amount";
            DataItemTableView = SORTING("Shipment Date", "Order Template Location ELA", "Route Stop Sequence") WHERE("Document Type" = CONST(Order));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Sell-to Customer No.", "Bill-to Customer No.", "Ship-to Code", "No. Printed";
            RequestFilterHeading = 'Sales Order';
            column(No_SalesHeader; "No.")
            {
            }
            column(BillToAddress1; BillToAddress[1])
            {
            }
            column(BillToAddress2; BillToAddress[2])
            {
            }
            column(BillToAddress3; BillToAddress[3])
            {
            }
            column(BillToAddress4; BillToAddress[4])
            {
            }
            column(BillToAddress5; BillToAddress[5])
            {
                IncludeCaption = false;
            }
            column(BillToAddress6; BillToAddress[6])
            {
            }
            column(BillToAddress7; BillToAddress[7])
            {
            }
            column(BilltoCustNo_SalesHeader; "Sales Header"."Bill-to Customer No.")
            {
            }
            column(CustomerName; Cust.Name)
            {
            }
            column(ShipmentDate; "Sales Header"."Shipment Date")
            {
            }
            column(UserID; GetUserID("Sales Header"))
            {
            }
            column(SalesPurchasePersonName; SalesPurchPerson.Name)
            {
            }
            column(SalesHeader_OrderTemplateLocation; "Sales Header"."Order Template Location ELA")
            {
            }
            column(WarehouseShipmentExist; "Sales Header"."Warehouse Shipment Exists ELA")
            {
            }
            column(NoOfPallets; "Sales Header"."No. Pallets")
            {
            }
            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE("Document Type" = CONST(Order));
                column(SalesLineType; "Sales Line".Type)
                {
                }
                column(SalesLineDocumentNo; "Sales Line"."Document No.")
                {
                }
                column(SalesLineLineNo; "Sales Line"."Line No.")
                {
                }
                column(SalesLineItem; "Sales Line"."No.")
                {
                }
                column(SalesLineUOM; "Sales Line"."Unit of Measure Code")
                {
                }
                column(ItemPackSize; grecItemUOM."Item UOM Size Code ELA")
                {
                }
                column(SalesLineOriginalOrderedQty; "Sales Line"."Original Order Qty. ELA")
                {
                }
                column(SalesLineQuantity; "Sales Line".Quantity)
                {
                }
                column(SalesLineQtyShipped; "Sales Line"."Quantity Shipped")
                {
                }
                column(ItemOnHand; Item."Qty. on Hand (Rep. UOM) ELA")
                {
                }
                column(SalesLineCompletelyShipped; "Sales Line"."Completely Shipped")
                {
                }
                column(SalesLineUnitPrice; "Sales Line"."Unit Price")
                {
                }
                column(SalesLineUnitCost; "Sales Line"."Unit Cost")
                {
                }
                column(SalesLineDescription; FORMAT("Sales Line".Description + "Sales Line"."Description 2"))
                {
                }
                column(SalesLineItemCategoryCode; "Sales Line"."Item Category Code")
                {
                }
                column(SalesLineShelfNo; "Sales Line"."Shelf No. ELA")
                {
                }
                column(Indicator; Indicator)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    //<<EN1.00
                    IF ("Sales Line"."Document No." = '') OR ("Sales Line"."Line No." = 0) OR ("Sales Line"."No." = '') THEN
                        CurrReport.SKIP;
                    IF NOT ("Sales Line"."Item Category Code" IN
                      ['PRODUCE A', 'PRODUCE C', 'PRODUCE P', 'PRODUCE T', 'BANANAS', 'DAIRY', 'DELI', 'MEAT', 'SEAFOOD', 'BAKERY', 'BEVG', 'GROCERY', 'GEN MERCH', 'FROZEN']) THEN
                        CurrReport.SKIP;


                    Item.GET("No.");
                    Item.CALCFIELDS(Item."Qty. on Hand (Rep. UOM) ELA");

                    //<<EN1.00
                    IF grecItemUOM.GET("No.", "Unit of Measure Code") THEN;      //EN1.01
                    //IF grecItemUOM.GET("No.","Sales Price Unit of Measure") THEN;

                    CLEAR(Indicator);
                    CLEAR(IndicatorCheckPrice);
                    CLEAR(IndicatorCheckQuantity);
                    CLEAR(IndicatorCheckUnit);
                    CLEAR(IndicatorPartialShipment);
                    IF "Sales Line"."Unit Cost" > "Sales Line"."Unit Price" THEN
                        IndicatorCheckPrice := '*CP';
                    IF ("Sales Line"."Original Order Qty. ELA" - "Sales Line"."Quantity Shipped") > Item."Qty. on Hand (Rep. UOM) ELA" THEN
                        IndicatorCheckQuantity := '*CQ';
                    IF "Sales Line"."Unit of Measure Code" IN ['INNERPACK', 'EA', 'EACH'] THEN // EN1.01
                        IndicatorCheckUnit := '*CU';
                    IF "Sales Line"."Original Order Qty. ELA" > "Sales Line"."Quantity Shipped" THEN
                        IndicatorPartialShipment := '*PS';

                    Indicator := IndicatorCheckPrice + IndicatorCheckQuantity + IndicatorCheckUnit + IndicatorPartialShipment;
                    //>>EN1.00
                end;
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

                    trigger OnAfterGetRecord()
                    begin
                        //<<EN1.00
                        IF Number = 1 THEN BEGIN
                            "Sales Line".FINDFIRST;
                        END ELSE BEGIN
                            "Sales Line".NEXT;
                        END;
                        //>>EN1.00
                    end;

                    trigger OnPreDataItem()
                    begin
                        SETRANGE(Number, 1, "Sales Line".COUNT); //EN1.00
                    end;
                }

                trigger OnPreDataItem()
                begin
                    SETRANGE(Number, 1, NoCopies + 1);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                //<<EN1.00
                IF "Salesperson Code" = '' THEN
                    CLEAR(SalesPurchPerson)
                ELSE
                    SalesPurchPerson.GET("Salesperson Code");

                IF NOT Cust.GET("Sell-to Customer No.") THEN
                    CLEAR(Cust);


                //FormatAddress.SalesHeaderSellTo(BillToAddress,"Sales Header");
                BillToAddress[1] := "Sales Header"."Sell-to Customer Name";
                BillToAddress[2] := "Sales Header"."Sell-to Address";
                BillToAddress[3] := "Sales Header"."Sell-to Address 2";
                BillToAddress[4] := "Sales Header"."Sell-to City" + ', ' + "Sales Header"."Sell-to County" + ' ' + "Sales Header"."Sell-to Post Code";
                COMPRESSARRAY(BillToAddress);
                //<<EN1.00
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
        lblShip = 'Ship';
        lblTo = 'To:';
        lblInvoiceDate = 'Invoice Date:';
        lblPage = 'Page:';
        lblShipDate = 'Shipment Date';
        lblTerms = 'Terms:';
        lblCustomerID = 'Customer ID:';
        lblPONumber = 'P.O. Number:';
        lblPODate = 'P.O. Date:';
        lblSalesperson = 'Salesperson:';
        lblCustomerName = 'Customer Name';
        lblOrderNo = 'Order No';
        lblTruckRoute = 'Route';
        lblUserID = 'User ID:';
    }

    var
        SalesPurchPerson: Record "Salesperson/Purchaser";
        Cust: Record Customer;
        FormatAddress: Codeunit "Format Address";
        grecItemUOM: Record "Item Unit of Measure";
        grecUOMSize: Record "Item Unit of Measure Size";
        QtyShort: Decimal;
        QtyShipped: Decimal;
        RegWhseActHdr: Record "Registered Whse. Activity Hdr.";
        RegWhseActLine: Record "Registered Whse. Activity Line";
        BillToAddress: array[8] of Text[50];
        NoCopies: Integer;
        Item: Record Item;
        Indicator: Code[50];
        IndicatorCheckPrice: Code[10];
        IndicatorPartialShipment: Code[10];
        IndicatorCheckQuantity: Code[10];
        IndicatorCheckUnit: Code[10];

    [Scope('Internal')]
    procedure GetUserID(SalesHdr: Record "Sales Header"): Code[50]
    begin
        //<<EN1.00
        RegWhseActLine.RESET;
        RegWhseActLine.SETRANGE(RegWhseActLine."Source No.", SalesHdr."No.");
        IF RegWhseActLine.FINDFIRST THEN BEGIN
            RegWhseActHdr.RESET;
            RegWhseActHdr.SETRANGE(RegWhseActHdr."No.", RegWhseActLine."No.");
            IF RegWhseActHdr.FINDFIRST THEN
                EXIT(RegWhseActHdr."Assigned User ID");
        END;
        //EN1.00
    end;
}

