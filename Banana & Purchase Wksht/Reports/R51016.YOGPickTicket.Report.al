report 51016 "YOG Pick Ticket"
{
    // IB47526RH 20151019 - Re-implementation/re-write of YOG's Pick Ticket Report from 2009R2 (which had no layout.)
    // 
    // DP20160307
    //   20160307  - Fix Bar Code to 128Large and surround with asterisks
    //             - Sort by Sku Shelf No
    //             - Layout changes to reduce wasted space
    // 
    // DP20160410
    //   20160410  - Changed bar code to BC 39
    // 
    // DP20160502
    //   20160502  - Get UPC copied the code from Receipt Ticket but removed Variant
    // 
    // DP20160509  - Dotted line above Item No. row to clarify whih Desc belongs to which Item
    DefaultLayout = RDLC;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = './YOGPickTicket.rdl';
    Caption = 'YOG Pick Ticket';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.") ORDER(Ascending) WHERE("Document Type" = CONST(Order));
            RequestFilterFields = "No.";
            column(SalesHeader_OrderNo; "Sales Header"."No.")
            {
            }
            column(SalesHeader_OrderDate; "Sales Header"."Order Date")
            {
            }
            column(SalesHeader_SellToCustomerNo; "Sales Header"."Sell-to Customer No.")
            {
            }
            column(SalesHeader_ShipmentDate; "Sales Header"."Shipment Date")
            {
            }
            column(SalesPurchPerson_Name; SalesPurchPerson.Name)
            {
            }
            column(ShipmentMethod_Description; ShipmentMethod.Description)
            {
            }
            column(SalesHeader_TruckRouteCode; "Sales Header"."Order Template Location ELA")
            {
            }
            column(Address_1; Address[1])
            {
            }
            column(Address_2; Address[2])
            {
            }
            column(Address_3; Address[3])
            {
            }
            column(Address_4; Address[4])
            {
            }
            column(Address_5; Address[5])
            {
            }
            column(Address_6; Address[6])
            {
            }
            column(Address_7; Address[7])
            {
            }
            column(ShipToAddress_1; ShipToAddress[1])
            {
            }
            column(ShipToAddress_2; ShipToAddress[2])
            {
            }
            column(ShipToAddress_3; ShipToAddress[3])
            {
            }
            column(ShipToAddress_4; ShipToAddress[4])
            {
            }
            column(ShipToAddress_5; ShipToAddress[5])
            {
            }
            column(ShipToAddress_6; ShipToAddress[6])
            {
            }
            column(ShipToAddress_7; ShipToAddress[7])
            {
            }
            column(WhseShipmentNo; gWhseShipmentNo)
            {
            }
            dataitem(Location; Location)
            {
                column(Location_Code; Location.Code)
                {
                }
                dataitem(CopyLoop; "Integer")
                {
                    dataitem(Lines; "Integer")
                    {
                        DataItemLinkReference = "Sales Header";
                        DataItemTableView = SORTING(Number) ORDER(Ascending);
                        column(Item_ShelfNo; gItemRec."Shelf No.")
                        {
                        }
                        column(Item_ShelfLifeRequirement; gItemRec."Shelf Life Requirement")
                        {
                        }
                        column(Item_QuantityOnPurchaseOrder; gItemRec."Qty. on Purch. Order")
                        {
                        }
                        column(ItemLedgerEntry_Quantity; ItemLedger.Quantity)
                        {
                        }
                        column(QtyPicked; gQtyPicked)
                        {
                        }
                        column(OnHandQty; gOnHandQty)
                        {
                        }
                        column(QtyInbound; gQtyInbound)
                        {
                        }
                        column(ItemUOM_Size; 'ItemUom.Size')
                        {
                        }
                        column(DefaultBinCode; gDefaultBinCode)
                        {
                        }
                        column(ItemSize; gItemSize)
                        {
                        }
                        column(StockkeepingUnit_ShelfNo; gSKUrec."Shelf No.")
                        {
                        }
                        column(BinContent_DefaultBin; gBinContent."Bin Code")
                        {
                        }
                        column(SalesLine_UnitOfMeasureCode; gSalesLineTMP."Unit of Measure Code")
                        {
                        }
                        column(SalesLine_Quantity; gSalesLineTMP.Quantity - gQtyPicked)
                        {
                        }
                        column(SalesLine_QuantityShipped; gSalesLineTMP."Quantity Shipped")
                        {
                        }
                        column(SalesLine_Description; gSalesLineTMP.Description)
                        {
                        }
                        column(SalesLine_Description2; gSalesLineTMP."Description 2")
                        {
                        }
                        column(SalesLine_No; gSalesLineTMP."No.")
                        {
                        }
                        column(TotalCases; TotalCases)
                        {
                        }
                        column(TotalLbs; TotalLbs)
                        {
                        }
                        column(ItemUOM__Std__Pack_UPC_EAN_Number_; UPCCode)
                        {
                        }

                        trigger OnAfterGetRecord()
                        var
                            lBinContent: Record "Bin Content";
                            lTransferLine: Record "Transfer Line";
                            lWhseActivityLine: Record "Registered Whse. Activity Line";
                            lUOMSize: Record "Item Unit of Measure Size";
                        begin
                            IF Number = 1 THEN BEGIN
                                gSalesLineTMP.FINDFIRST;
                            END ELSE BEGIN
                                gSalesLineTMP.NEXT;
                            END;

                            IF gSalesLineTMP."No." <> '' THEN BEGIN
                                gItemRec.GET(gSalesLineTMP."No.");

                                // Calc Qty. on Hand
                                ItemLedger.RESET;
                                ItemLedger.SETCURRENTKEY("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
                                ItemLedger.SETRANGE("Item No.", gItemRec."No.");
                                ItemLedger.SETRANGE("Location Code", Location.Code);
                                ItemLedger.CALCSUMS("Remaining Quantity");
                                gOnHandQty := ItemLedger."Remaining Quantity";

                                gBinContent.RESET;
                                gBinContent.SETFILTER("Location Code", Location.Code);
                                gBinContent.SETRANGE("Bin Code", gShipBinCode);
                                gBinContent.SETFILTER("Item No.", gItemRec."No.");
                                gBinContent.SETFILTER("Variant Code", gSalesLineTMP."Variant Code");
                                gBinContent.SETFILTER("Unit of Measure Code", gSalesLineTMP."Unit of Measure Code");
                                IF gBinContent.FINDFIRST THEN BEGIN
                                    REPEAT
                                        gBinContent.CALCFIELDS(Quantity);
                                        gOnHandQty -= gBinContent.Quantity;
                                    UNTIL gBinContent.NEXT = 0;
                                END;

                                // Calc Qty. on P.O.
                                gItemRec.CALCFIELDS("Qty. on Purch. Order");
                                gQtyInbound := ibUOMConvert(
                                              gSalesLineTMP."No.",
                                              gItemRec."Base Unit of Measure",
                                              gSalesLineTMP."Unit of Measure Code",
                                              gItemRec."Qty. on Purch. Order",
                                              0.01
                                            );
                                CLEAR(TransferQty);
                                lTransferLine.RESET;
                                lTransferLine.SETCURRENTKEY(
                                  "Transfer-to Code", Status, "Derived From Line No.", "Item No.", "Variant Code",
                                  "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Receipt Date", "In-Transit Code"
                                );
                                lTransferLine.SETRANGE("Transfer-to Code", Location.Code);
                                lTransferLine.SETFILTER("Item No.", gSalesLineTMP."No.");
                                lTransferLine.SETFILTER("Variant Code", gSalesLineTMP."Variant Code");
                                IF lTransferLine.FINDSET THEN BEGIN
                                    REPEAT

                                        TransferQty += lTransferLine."Outstanding Qty. (Base)";
                                    UNTIL lTransferLine.NEXT = 0;
                                END;
                                lTransferLine.CALCSUMS("Qty. to Receive (Base)");
                                gQtyInbound += ibUOMConvert(
                                              gSalesLineTMP."No.",
                                              gItemRec."Base Unit of Measure",
                                              gSalesLineTMP."Unit of Measure Code",
                                              TransferQty,
                                              0.01
                                            );

                                IF NOT gSKUrec.GET(gSalesLineTMP."Location Code", gSalesLineTMP."No.", gSalesLineTMP."Variant Code") THEN BEGIN
                                    CLEAR(gSKUrec);
                                END;

                                // Default Bin Code
                                gDefaultBinCode := '';
                                gBinContent.RESET;
                                gBinContent.SETFILTER(Default, '%1', TRUE);
                                gBinContent.SETFILTER("Location Code", Location.Code);
                                gBinContent.SETFILTER("Item No.", gItemRec."No.");
                                gBinContent.SETFILTER("Variant Code", gSalesLineTMP."Variant Code");
                                gBinContent.SETFILTER("Unit of Measure Code", gSalesLineTMP."Unit of Measure Code");
                                IF gBinContent.FINDFIRST THEN BEGIN
                                    gDefaultBinCode := gBinContent."Bin Code";
                                END;

                                // Quantity Picked
                                gQtyPicked := 0;
                                lWhseActivityLine.RESET;
                                lWhseActivityLine.SETRANGE("Activity Type", lWhseActivityLine."Activity Type"::Pick);
                                lWhseActivityLine.SETRANGE("Whse. Document Type", lWhseActivityLine."Whse. Document Type"::Shipment);
                                lWhseActivityLine.SETRANGE("Source Type", DATABASE::"Sales Line");
                                lWhseActivityLine.SETRANGE("Source Subtype", 1);
                                lWhseActivityLine.SETRANGE("Source No.", gSalesLineTMP."Document No.");
                                lWhseActivityLine.SETRANGE("Source Line No.", gSalesLineTMP."Attached to Line No.");
                                lWhseActivityLine.SETRANGE("Action Type", lWhseActivityLine."Action Type"::Take);
                                lWhseActivityLine.SETRANGE("Unit of Measure Code", gSalesLineTMP."Unit of Measure Code");
                                IF lWhseActivityLine.FINDFIRST THEN BEGIN
                                    REPEAT
                                        gQtyPicked += lWhseActivityLine.Quantity;
                                    UNTIL lWhseActivityLine.NEXT = 0;
                                END;

                                // Item Size
                                gItemSize := gSalesLineTMP."Unit of Measure Code";
                                ItemUom.GET(gItemRec."No.", gSalesLineTMP."Unit of Measure Code");
                                IF lUOMSize.GET(ItemUom."Item UOM Size Code ELA") THEN BEGIN
                                    gItemSize := lUOMSize.Description;
                                END;

                                //<DP20160502>
                                UPCCode := ibGetUps(gItemRec."No.", gSalesLineTMP."Unit of Measure Code");
                                //</DP20160502>

                            END;
                        end;

                        trigger OnPreDataItem()
                        begin
                            gSalesLineTMP.FINDFIRST;
                            TotalLbs := 0;
                            TotalCases := 0;
                            REPEAT
                                IF gSalesLineTMP."No." <> '' THEN BEGIN
                                    // RTH - I just had to leave this original code here for "reference". :-)
                                    //CASE TRUE OF
                                    //  "Unit of Measure Code" = 'LB':
                                    //    TotalLbs := TotalLbs + Quantity;
                                    //  "Unit of Measure Code" <> 'LB':
                                    //    TotalCases := TotalCases + Quantity;
                                    //END;
                                    //
                                    IF gSalesLineTMP."Unit of Measure Code" = 'LB' THEN BEGIN
                                        TotalLbs := TotalLbs + gSalesLineTMP.Quantity;
                                    END ELSE BEGIN
                                        TotalCases := TotalCases + gSalesLineTMP.Quantity;
                                    END;
                                END;
                            UNTIL gSalesLineTMP.NEXT = 0;

                            SETRANGE(Number, 1, gSalesLineTMP.COUNT);
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        SETRANGE(Number, 1, NoCopies + 1);
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    lSalesLine: Record "Sales Line";
                    lLineNo: Integer;
                    lSalesCommentLine: Record "Sales Comment Line";
                begin
                    lSalesLine.SETFILTER("Document Type", '%1', lSalesLine."Document Type"::Order);
                    lSalesLine.SETFILTER("Document No.", "Sales Header"."No.");
                    lSalesLine.SETFILTER(Type, '%1', lSalesLine.Type::Item);
                    lSalesLine.SETFILTER("Outstanding Quantity", '>%1', 0);
                    lSalesLine.SETFILTER("No.", '<>%1', '');
                    lSalesLine.SETFILTER("Location Code", Code);
                    IF NOT lSalesLine.FINDFIRST THEN
                        CurrReport.SKIP;

                    lLineNo := 10000;
                    gSalesLineTMP.RESET;
                    gSalesLineTMP.DELETEALL;
                    REPEAT
                        gSalesLineTMP := lSalesLine;
                        gSalesLineTMP."Line No." := lLineNo;
                        gSalesLineTMP."Attached to Line No." := lSalesLine."Line No.";   // Need original line no. later to find picks
                        gSalesLineTMP.INSERT;
                        lLineNo += 10000;
                        lSalesCommentLine.SETFILTER("Document Type", '%1', lSalesCommentLine."Document Type"::Order);
                        lSalesCommentLine.SETFILTER("No.", "Sales Header"."No.");
                        lSalesCommentLine.SETFILTER("Document Line No.", '%1', lSalesLine."Line No.");
                        lSalesCommentLine.SETFILTER("Print On Pick Ticket", '%1', TRUE);
                        IF lSalesCommentLine.FINDFIRST THEN BEGIN
                            REPEAT
                                gSalesLineTMP.Description := COPYSTR(lSalesCommentLine.Comment, 1, 50);
                                gSalesLineTMP."Description 2" := COPYSTR(lSalesCommentLine.Comment, 51, 30);
                                gSalesLineTMP."No." := '';
                                gSalesLineTMP."Line No." := lLineNo;
                                gSalesLineTMP.INSERT;
                                lLineNo += 10000;
                            UNTIL lSalesCommentLine.NEXT = 0;
                        END;
                    UNTIL lSalesLine.NEXT = 0;

                    gLocation.GET(Code);
                    gShipBinCode := gLocation."Shipment Bin Code";
                end;
            }

            trigger OnAfterGetRecord()
            begin


                IF "Salesperson Code" = '' THEN
                    CLEAR(SalesPurchPerson)
                ELSE
                    SalesPurchPerson.GET("Salesperson Code");

                IF "Shipment Method Code" = '' THEN
                    CLEAR(ShipmentMethod)
                ELSE
                    ShipmentMethod.GET("Shipment Method Code");

                IF "Payment Terms Code" = '' THEN
                    CLEAR(PaymentTerms)
                ELSE
                    PaymentTerms.GET("Payment Terms Code");

                FormatAddress;

                gWhseShipmentNo := '';
                gWhseShipmentLine.SETCURRENTKEY("Source Type", "Source Subtype", "Source No.", "Source Line No.", "Assemble to Order", "Location Code");
                gWhseShipmentLine.SETFILTER("Source Type", '%1', DATABASE::"Sales Line");
                gWhseShipmentLine.SETFILTER("Source Subtype", '%1', 1);
                gWhseShipmentLine.SETFILTER("Location Code", "Location Code");
                gWhseShipmentLine.SETFILTER("Source No.", "Sales Header"."No.");
                IF gWhseShipmentLine.FINDFIRST THEN BEGIN
                    gWhseShipmentNo := gWhseShipmentLine."No.";
                END;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        Item: Record Item;
        SalesPurchPerson: Record "Salesperson/Purchaser";
        Address: array[7] of Text[30];
        ShipToAddress: array[7] of Text[30];
        NoCopies: Integer;
        TotalCases: Decimal;
        TotalLbs: Decimal;
        ItemUom: Record "Item Unit of Measure";
        ItemLedger: Record "Item Ledger Entry";
        gItemRec: Record Item;
        gSKUrec: Record "Stockkeeping Unit";
        gBinContent: Record "Bin Content";
        gSalesLineTMP: Record "Sales Line" temporary;
        gShipBinCode: Code[20];
        gLocation: Record Location;
        gOnHandQty: Decimal;
        gQtyInbound: Decimal;
        gWhseShipmentLine: Record "Warehouse Shipment Line";
        gWhseShipmentNo: Code[20];
        gDefaultBinCode: Code[20];
        gQtyPicked: Decimal;
        gItemSize: Text[80];
        TransferQty: Decimal;
        UPCCode: Text[100];

    [Scope('Internal')]
    procedure FormatAddress()
    var
        TempAddress3: Text[100];
    begin
        CLEAR(Address);
        Address[1] := "Sales Header"."Bill-to Contact";
        Address[2] := "Sales Header"."Bill-to Name";
        Address[3] := "Sales Header"."Bill-to Name 2";
        Address[4] := "Sales Header"."Bill-to Address";
        Address[5] := "Sales Header"."Bill-to Address 2";
        TempAddress3 := "Sales Header"."Bill-to City" + ', '
                                            + "Sales Header"."Bill-to County"
                                            + '  '
                                            + "Sales Header"."Bill-to Post Code";
        IF STRLEN(TempAddress3) > MAXSTRLEN(Address[6]) THEN BEGIN
            Address[6] := "Sales Header"."Bill-to City";
            Address[7] := "Sales Header"."Bill-to County" + '  ' + "Sales Header"."Bill-to Post Code";
        END ELSE BEGIN
            IF ("Sales Header"."Bill-to City" <> '') AND ("Sales Header"."Bill-to County" <> '') THEN
                Address[6] := TempAddress3
            ELSE
                Address[6] := DELCHR("Sales Header"."Bill-to City" + ' '
                                                         + "Sales Header"."Bill-to County"
                                                         + '  '
                                                         + "Sales Header"."Bill-to Post Code", '<>');
        END;
        COMPRESSARRAY(Address);

        CLEAR(ShipToAddress);
        ShipToAddress[1] := "Sales Header"."Ship-to Contact";
        ShipToAddress[2] := "Sales Header"."Ship-to Name";
        ShipToAddress[3] := "Sales Header"."Ship-to Name 2";
        ShipToAddress[4] := "Sales Header"."Ship-to Address";
        ShipToAddress[5] := "Sales Header"."Ship-to Address 2";
        TempAddress3 := "Sales Header"."Ship-to City" + ', '
                                                      + "Sales Header"."Ship-to County"
                                                      + '  '
                                                      + "Sales Header"."Ship-to Post Code";
        IF STRLEN(TempAddress3) > MAXSTRLEN(ShipToAddress[6]) THEN BEGIN
            ShipToAddress[6] := "Sales Header"."Ship-to City";
            ShipToAddress[7] := "Sales Header"."Ship-to County" + '  ' + "Sales Header"."Ship-to Post Code";
        END ELSE BEGIN
            IF ("Sales Header"."Ship-to City" <> '') AND ("Sales Header"."Ship-to County" <> '') THEN
                ShipToAddress[6] := TempAddress3
            ELSE
                ShipToAddress[6] := DELCHR("Sales Header"."Ship-to City" + ' '
                                                                         + "Sales Header"."Ship-to County"
                                                                         + '  '
                                                                         + "Sales Header"."Ship-to Post Code", '<>');
        END;
        COMPRESSARRAY(ShipToAddress);
    end;

    [Scope('Internal')]
    procedure ibUOMConvert(pcodItemNo: Code[20]; pcodFromUOM: Code[10]; pcodToUOM: Code[10]; pdecQtyToConvert: Decimal; pdecRoundingPrec: Decimal): Decimal
    var
        lFromItemUOM: Record "Item Unit of Measure";
        lToItemUOM: Record "Item Unit of Measure";
    begin
        IF pcodFromUOM = pcodToUOM THEN
            EXIT(pdecQtyToConvert);
        IF pdecQtyToConvert = 0 THEN
            EXIT(0);

        IF NOT lFromItemUOM.GET(pcodItemNo, pcodFromUOM) THEN
            EXIT(0);
        IF NOT lToItemUOM.GET(pcodItemNo, pcodToUOM) THEN
            EXIT(0);

        IF ROUND(lFromItemUOM."Qty. per Unit of Measure", 1.0) = lFromItemUOM."Qty. per Unit of Measure" THEN
            EXIT(ROUND(pdecQtyToConvert * lFromItemUOM."Qty. per Unit of Measure" / lToItemUOM."Qty. per Unit of Measure", pdecRoundingPrec))
        ELSE
            EXIT(ROUND(pdecQtyToConvert * lToItemUOM."Qty. per Base UOM ELA" / lFromItemUOM."Qty. per Base UOM ELA", pdecRoundingPrec));
    end;

    [Scope('Internal')]
    procedure ibGetUps(pcodItemNo: Code[20]; pcodUoMCode: Code[10]): Text[50]
    var
        lrecItemCrossRefer: Record "Item Cross Reference";
    begin
        //<DP20160502>
        lrecItemCrossRefer.SETRANGE("Item No.", pcodItemNo);
        lrecItemCrossRefer.SETRANGE("Unit of Measure", pcodUoMCode);
        lrecItemCrossRefer.SETRANGE("Cross-Reference Type", lrecItemCrossRefer."Cross-Reference Type"::"Bar Code");
        lrecItemCrossRefer.SETRANGE(Status, lrecItemCrossRefer.Status::Approved);
        IF lrecItemCrossRefer.FINDFIRST THEN BEGIN
            EXIT(lrecItemCrossRefer."Cross-Reference No.");
        END;

        EXIT('');
        //</DP20160502>
    end;
}

