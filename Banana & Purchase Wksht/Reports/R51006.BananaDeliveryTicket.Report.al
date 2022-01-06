report 51006 "Banana Delivery Ticket"
{
    DefaultLayout = RDLC;
    RDLCLayout = './BananaDeliveryTicket.rdlc';

    Caption = 'Sales Order';

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING("Shipment Date", "Order Template Location ELA", "Route Stop Sequence") WHERE("Document Type" = CONST(Order));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Sell-to Customer No.", "Bill-to Customer No.", "Ship-to Code", "No. Printed";
            RequestFilterHeading = 'Sales Order';
            column(No_SalesHeader; "No.")
            {
            }
            column(Sales_No_Barcode; SalesNoBarcode)
            {
            }
            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE("Document Type" = CONST(Order));
                dataitem(SalesLineComments; "Sales Comment Line")
                {
                    DataItemLink = "No." = FIELD("Document No."), "Document Line No." = FIELD("Line No.");
                    DataItemTableView = SORTING("Document Type", "No.", "Document Line No.", "Line No.") WHERE("Document Type" = CONST(Order), "Print On Order Confirmation" = CONST(true));

                    trigger OnAfterGetRecord()
                    begin
                        TempSalesLine.INIT;
                        TempSalesLine."Document Type" := "Sales Header"."Document Type";
                        TempSalesLine."Document No." := "Sales Header"."No.";
                        TempSalesLine."Line No." := HighestLineNo + 10;
                        HighestLineNo := "Line No.";
                        IF STRLEN(Comment) <= MAXSTRLEN(TempSalesLine.Description) THEN BEGIN
                            TempSalesLine.Description := Comment;
                            TempSalesLine."Description 2" := '';
                        END ELSE BEGIN
                            SpacePointer := MAXSTRLEN(TempSalesLine.Description) + 1;
                            WHILE (SpacePointer > 1) AND (Comment[SpacePointer] <> ' ') DO
                                SpacePointer := SpacePointer - 1;
                            IF SpacePointer = 1 THEN
                                SpacePointer := MAXSTRLEN(TempSalesLine.Description) + 1;
                            TempSalesLine.Description := COPYSTR(Comment, 1, SpacePointer - 1);
                            TempSalesLine."Description 2" := COPYSTR(COPYSTR(Comment, SpacePointer + 1), 1, MAXSTRLEN(TempSalesLine."Description 2"));
                        END;
                        TempSalesLine.INSERT;
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    lrecItemTranslation: Record "Item Translation";
                    lrecItem: Record Item;
                begin
                    TempSalesLine := "Sales Line";
                    IF Type = Type::Item THEN BEGIN
                        IF gcodLanguageCode <> '' THEN BEGIN
                            IF CompanyInformation."Language Code" = gcodLanguageCode THEN BEGIN
                                lrecItem.GET("No.");

                                TempSalesLine.Description := lrecItem.Description;
                                TempSalesLine."Description 2" := lrecItem."Description 2";
                            END ELSE BEGIN
                                lrecItemTranslation.SETRANGE("Item No.", "No.");
                                lrecItemTranslation.SETRANGE("Variant Code", "Variant Code");
                                lrecItemTranslation.SETRANGE("Language Code", gcodLanguageCode);

                                IF lrecItemTranslation.FINDFIRST THEN BEGIN
                                    TempSalesLine.Description := lrecItemTranslation.Description;
                                    TempSalesLine."Description 2" := lrecItemTranslation."Description 2";
                                END;
                            END;
                        END;
                    END;
                    TempSalesLine."Drop Shipment" := FALSE;
                    gdecQty := 0;
                    IF TempSalesLine.Type = TempSalesLine.Type::Item THEN BEGIN
                        gdecQty := TempSalesLine.Quantity;
                        IF "Quantity Shipped" <> 0 THEN
                            QtyShipped := "Quantity Shipped"
                        ELSE
                            QtyShipped := Quantity;
                        IF "Original Order Qty. ELA" <> QtyShipped THEN
                            QtyShort := "Sales Line"."Original Order Qty. ELA" - QtyShipped
                        ELSE
                            QtyShort := 0;
                        IF QtyShort > 0 THEN BEGIN
                            TempSalesLine."Line No." := TempSalesLine."Line No." + 1000000000;
                            IF FirstShort THEN BEGIN
                                TempSalesLine."Drop Shipment" := TRUE;
                                FirstShort := FALSE;
                            END;
                        END;
                    END;
                    TempSalesLine.INSERT;
                    TempSalesLineAsm := "Sales Line";
                    TempSalesLineAsm."Line No." := TempSalesLine."Line No.";
                    TempSalesLineAsm.INSERT;

                    HighestLineNo := "Line No.";
                    IF ("Sales Header"."Tax Area Code" <> '') AND NOT UseExternalTaxEngine THEN
                        SalesTaxCalc.AddSalesLine(TempSalesLine);
                end;

                trigger OnPostDataItem()
                begin
                    IF "Sales Header"."Tax Area Code" <> '' THEN BEGIN
                        IF UseExternalTaxEngine THEN
                            SalesTaxCalc.CallExternalTaxEngineForSales("Sales Header", TRUE)
                        ELSE
                            SalesTaxCalc.EndSalesTaxCalculation(UseDate);
                        SalesTaxCalc.DistTaxOverSalesLines(TempSalesLine);
                        SalesTaxCalc.GetSummarizedSalesTaxTable(TempSalesTaxAmtLine);
                        BrkIdx := 0;
                        PrevPrintOrder := 0;
                        PrevTaxPercent := 0;
                        TempSalesTaxAmtLine.RESET;
                        TempSalesTaxAmtLine.SETCURRENTKEY("Print Order", "Tax Area Code for Key", "Tax Jurisdiction Code");
                        IF TempSalesTaxAmtLine.FIND('-') THEN
                            REPEAT
                                IF (TempSalesTaxAmtLine."Print Order" = 0) OR
                                  (TempSalesTaxAmtLine."Print Order" <> PrevPrintOrder) OR
                                  (TempSalesTaxAmtLine."Tax %" <> PrevTaxPercent)
                                THEN BEGIN
                                    BrkIdx := BrkIdx + 1;
                                    IF BrkIdx > 1 THEN BEGIN
                                        IF TaxArea."Country/Region" = TaxArea."Country/Region"::CA THEN
                                            BreakdownTitle := Text006
                                        ELSE
                                            BreakdownTitle := Text003;
                                    END;
                                    IF BrkIdx > ARRAYLEN(BreakdownAmt) THEN BEGIN
                                        BrkIdx := BrkIdx - 1;
                                        BreakdownLabel[BrkIdx] := Text004;
                                    END ELSE
                                        BreakdownLabel[BrkIdx] := STRSUBSTNO(TempSalesTaxAmtLine."Print Description", TempSalesTaxAmtLine."Tax %");
                                END;
                                BreakdownAmt[BrkIdx] := BreakdownAmt[BrkIdx] + TempSalesTaxAmtLine."Tax Amount";
                            UNTIL NEXT = 0;

                        IF BrkIdx = 1 THEN BEGIN
                            CLEAR(BreakdownLabel);
                            CLEAR(BreakdownAmt);
                        END;
                    END;
                end;

                trigger OnPreDataItem()
                begin
                    TempSalesLine.RESET;
                    TempSalesLine.DELETEALL;
                    TempSalesLineAsm.RESET;
                    TempSalesLineAsm.DELETEALL;

                    FirstShort := TRUE;
                end;
            }
            dataitem("Sales Comment Line"; "Sales Comment Line")
            {
                DataItemLink = "No." = FIELD("No.");
                DataItemTableView = SORTING("Document Type", "No.", "Document Line No.", "Line No.") WHERE("Document Type" = CONST(Order), "Print On Order Confirmation" = CONST(true), "Document Line No." = CONST(0));

                trigger OnAfterGetRecord()
                begin
                    TempSalesLine.INIT;
                    TempSalesLine."Document Type" := "Sales Header"."Document Type";
                    TempSalesLine."Document No." := "Sales Header"."No.";
                    TempSalesLine."Line No." := HighestLineNo + 1000;
                    HighestLineNo := "Line No.";

                    IF STRLEN(Comment) <= MAXSTRLEN(TempSalesLine.Description) THEN BEGIN
                        TempSalesLine.Description := Comment;
                        TempSalesLine."Description 2" := '';
                    END ELSE BEGIN
                        SpacePointer := MAXSTRLEN(TempSalesLine.Description) + 1;
                        WHILE (SpacePointer > 1) AND (Comment[SpacePointer] <> ' ') DO
                            SpacePointer := SpacePointer - 1;
                        IF SpacePointer = 1 THEN
                            SpacePointer := MAXSTRLEN(TempSalesLine.Description) + 1;
                        TempSalesLine.Description := COPYSTR(Comment, 1, SpacePointer - 1);
                        TempSalesLine."Description 2" := COPYSTR(COPYSTR(Comment, SpacePointer + 1), 1, MAXSTRLEN(TempSalesLine."Description 2"));
                    END;
                    TempSalesLine.INSERT;
                end;
            }
            dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
            {
                DataItemLink = "Customer No." = FIELD("Bill-to Customer No.");
                DataItemTableView = SORTING("Customer No.", Open, Positive, "Due Date", "Currency Code") WHERE("Document Type" = CONST(Invoice), Open = CONST(true));

                trigger OnAfterGetRecord()
                begin
                    TempCustLedger := "Cust. Ledger Entry";
                    TempCustLedger.INSERT;
                end;

                trigger OnPreDataItem()
                begin
                    TempCustLedger.RESET;
                    TempCustLedger.DELETEALL;
                end;
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                    column(CompanyAddress1; CompanyAddress[1])
                    {
                    }
                    column(CompanyAddress2; CompanyAddress[2])
                    {
                    }
                    column(CompanyAddress3; CompanyAddress[3])
                    {
                    }
                    column(CompanyAddress4; CompanyAddress[4])
                    {
                    }
                    column(CompanyAddress5; CompanyAddress[5])
                    {
                    }
                    column(CompanyAddress6; CompanyAddress[6])
                    {
                    }
                    column(CopyTxt; CopyTxt)
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
                    }
                    column(BillToAddress6; BillToAddress[6])
                    {
                    }
                    column(BillToAddress7; BillToAddress[7])
                    {
                    }
                    column(ShptDate_SalesHeader; FORMAT("Sales Header"."Shipment Date"))
                    {
                    }
                    column(ShipToAddress1; ShipToAddress[1])
                    {
                    }
                    column(ShipToAddress2; ShipToAddress[2])
                    {
                    }
                    column(ShipToAddress3; ShipToAddress[3])
                    {
                    }
                    column(ShipToAddress4; ShipToAddress[4])
                    {
                    }
                    column(ShipToAddress5; ShipToAddress[5])
                    {
                    }
                    column(ShipToAddress6; ShipToAddress[6])
                    {
                    }
                    column(ShipToAddress7; ShipToAddress[7])
                    {
                    }
                    column(BilltoCustNo_SalesHeader; "Sales Header"."Bill-to Customer No.")
                    {
                    }
                    column(YourRef_SalesHeader; "Sales Header"."Your Reference")
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    column(OrderDate_SalesHeader; FORMAT("Sales Header"."Order Date"))
                    {
                    }
                    column(CompanyAddress7; CompanyAddress[7])
                    {
                    }
                    column(CompanyAddress8; CompanyAddress[8])
                    {
                    }
                    column(BillToAddress8; BillToAddress[8])
                    {
                    }
                    column(ShipToAddress8; ShipToAddress[8])
                    {
                    }
                    column(ShipmentMethodDesc; ShipmentMethod.Description)
                    {
                    }
                    column(PaymentTermsDesc; PaymentTerms.Description)
                    {
                    }
                    column(TaxRegLabel; TaxRegLabel)
                    {
                    }
                    column(TaxRegNo; TaxRegNo)
                    {
                    }
                    column(CopyNo; CopyNo)
                    {
                    }
                    column(CustTaxIdentificationType; FORMAT(Cust."Tax Identification Type"))
                    {
                    }
                    column(SoldCaption; SoldCaptionLbl)
                    {
                    }
                    column(ToCaption; ToCaptionLbl)
                    {
                    }
                    column(ShipDateCaption; ShipDateCaptionLbl)
                    {
                    }
                    column(CustomerIDCaption; CustomerIDCaptionLbl)
                    {
                    }
                    column(PONumberCaption; PONumberCaptionLbl)
                    {
                    }
                    column(SalesPersonCaption; SalesPersonCaptionLbl)
                    {
                    }
                    column(ShipCaption; ShipCaptionLbl)
                    {
                    }
                    column(SalesOrderCaption; SalesOrderCaptionLbl)
                    {
                    }
                    column(SalesOrderNumberCaption; SalesOrderNumberCaptionLbl)
                    {
                    }
                    column(SalesOrderDateCaption; SalesOrderDateCaptionLbl)
                    {
                    }
                    column(PageCaption; PageCaptionLbl)
                    {
                    }
                    column(ShipViaCaption; ShipViaCaptionLbl)
                    {
                    }
                    column(TermsCaption; TermsCaptionLbl)
                    {
                    }
                    column(PODateCaption; PODateCaptionLbl)
                    {
                    }
                    column(TaxIdentTypeCaption; TaxIdentTypeCaptionLbl)
                    {
                    }
                    column(YOG; '--YOG--')
                    {
                    }
                    column(SalesHeader_OrderTemplateLocation; "Sales Header"."Supply Chain Group Code ELA")
                    {
                    }
                    column(SalesHeader_ExternalDocumentNo; "Sales Header"."External Document No.")
                    {
                    }
                    column(gblnShowPrices; gblnShowPrices)
                    {
                    }
                    column(gtxtUnitPriceCaption; gtxtUnitPriceCaption)
                    {
                    }
                    column(gtxtBottleDepositCaption; gtxtBottleDepositCaption)
                    {
                    }
                    column(gtxtTotalCaption; gtxtTotalCaption)
                    {
                    }
                    column(IsFirstShortLine_VariableAbuse; TempSalesLine."Drop Shipment")
                    {
                    }
                    column(gblnShowCustLedger; gblnShowCustLedger)
                    {
                    }
                    dataitem(SalesLine; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(PrintFooter; PrintFooter)
                        {
                        }
                        column(AmountExclInvDisc; AmountExclInvDisc)
                        {
                        }
                        column(TempSalesLineNo; TempSalesLine."No.")
                        {
                        }
                        column(TempSalesLineUOM; TempSalesLine."Unit of Measure")
                        {
                        }
                        column(TempSalesLineQuantity; gdecQty)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(UnitPriceToPrint; UnitPriceToPrint)
                        {
                            DecimalPlaces = 2 : 5;
                        }
                        column(TempSalesLineDesc; TempSalesLine.Description + ' ' + TempSalesLine."Description 2")
                        {
                        }
                        column(TempSalesLineDocumentNo; TempSalesLine."Document No.")
                        {
                        }
                        column(TempSalesLineLineNo; TempSalesLine."Line No.")
                        {
                        }
                        column(AsmInfoExistsForLine; AsmInfoExistsForLine)
                        {
                        }
                        column(TaxLiable; TaxLiable)
                        {
                        }
                        column(TempSalesLineLineAmtTaxLiable; TempSalesLine."Line Amount" - TaxLiable)
                        {
                        }
                        column(TempSalesLineInvDiscAmt; TempSalesLine."Inv. Discount Amount")
                        {
                        }
                        column(TaxAmount; TaxAmount)
                        {
                        }
                        column(TempSalesLineLineAmtTaxAmtInvDiscAmt; TempSalesLine."Line Amount" + TaxAmount - TempSalesLine."Inv. Discount Amount")
                        {
                        }
                        column(BreakdownTitle; BreakdownTitle)
                        {
                        }
                        column(BreakdownLabel1; BreakdownLabel[1])
                        {
                        }
                        column(BreakdownLabel2; BreakdownLabel[2])
                        {
                        }
                        column(BreakdownLabel3; BreakdownLabel[3])
                        {
                        }
                        column(BreakdownAmt1; BreakdownAmt[1])
                        {
                        }
                        column(BreakdownAmt2; BreakdownAmt[2])
                        {
                        }
                        column(BreakdownAmt3; BreakdownAmt[3])
                        {
                        }
                        column(BreakdownAmt4; BreakdownAmt[4])
                        {
                        }
                        column(BreakdownLabel4; BreakdownLabel[4])
                        {
                        }
                        column(TotalTaxLabel; TotalTaxLabel)
                        {
                        }
                        column(ItemNoCaption; ItemNoCaptionLbl)
                        {
                        }
                        column(UnitCaption; UnitCaptionLbl)
                        {
                        }
                        column(DescriptionCaption; DescriptionCaptionLbl)
                        {
                        }
                        column(QuantityCaption; QuantityCaptionLbl)
                        {
                        }
                        column(UnitPriceCaption; UnitPriceCaptionLbl)
                        {
                        }
                        column(TotalPriceCaption; TotalPriceCaptionLbl)
                        {
                        }
                        column(SubtotalCaption; SubtotalCaptionLbl)
                        {
                        }
                        column(InvoiceDiscountCaption; InvoiceDiscountCaptionLbl)
                        {
                        }
                        column(TotalCaption; TotalCaptionLbl)
                        {
                        }
                        column(AmtSubjecttoSalesTaxCptn; AmtSubjecttoSalesTaxCptnLbl)
                        {
                        }
                        column(AmtExemptfromSalesTaxCptn; AmtExemptfromSalesTaxCptnLbl)
                        {
                        }
                        column(gcodCustUOM; gcodCustUOM)
                        {
                        }
                        column(gdecCustUOMQty; gdecCustUOMQty)
                        {
                        }
                        column(gdecCustUOMPrice; gdecCustUOMPrice)
                        {
                        }
                        column(gdecFRChargeAmt; gdecFRChargeAmt)
                        {
                        }
                        column(gdecSALChargeAmt; gdecSALChargeAmt)
                        {
                        }
                        column(YOG_; '---YOG---')
                        {
                        }
                        column(TempSalesLineDescription; TempSalesLine.Description)
                        {
                        }
                        column(TempSalesLineDescription2; TempSalesLine."Description 2")
                        {
                        }
                        column(TempSalesLineOriginalOrderQty; TempSalesLine."Original Order Qty. ELA")
                        {
                        }
                        column(QtyShipped; QtyShipped)
                        {
                        }
                        column(TempSalesLineBotDep; BotDep)
                        {
                        }
                        column(TempSalesLineUPCCode; STRSUBSTNO('*%1*', UPCCode))
                        {
                        }
                        column(QtyShort; QtyShort)
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(gblnShowSalesLine; gblnShowSalesLine)
                        {
                        }
                        column(gblnShowDescLine; gblnShowDescLine)
                        {
                        }
                        column(DescText; DescText)
                        {
                        }
                        column(TempSalesLineGreen; TempSalesLine."Green Quantity")
                        {
                        }
                        column(TempSalesLineBrk; TempSalesLine."Breaking Quantity")
                        {
                        }
                        column(TempSalesLineNoGas; TempSalesLine."No Gas Quantity")
                        {
                        }
                        column(TempSalesLineColor; TempSalesLine."Color Quantity")
                        {
                        }
                        column(GreenQtyCaption; GreenQtyCaptionLabel)
                        {
                        }
                        column(BrkQtyCaption; BreakingQtyCaptionLabel)
                        {
                        }
                        column(NoGasCaption; NoGasQtyCaptionLabel)
                        {
                        }
                        column(ColorCaption; ColorQtyCaptionLabel)
                        {
                        }
                        column(GreenTracking; TempSalesLine."Green Tracking No.")
                        {
                        }
                        column(BrkTracking; TempSalesLine."Breaking Tracking No.")
                        {
                        }
                        column(ColorTracking; TempSalesLine."Color Tracking No.")
                        {
                        }
                        dataitem("Extended Text Header"; "Extended Text Header")
                        {
                            dataitem("Extended Text Line"; "Extended Text Line")
                            {
                                column(ExtendedText; "Extended Text Line".Text)
                                {
                                }

                                trigger OnPreDataItem()
                                begin
                                    SETRANGE("Table Name", "Extended Text Header"."Table Name");
                                    SETRANGE("No.", "Extended Text Header"."No.");
                                    SETRANGE("Text No.", "Extended Text Header"."Text No.");
                                end;
                            }

                            trigger OnPreDataItem()
                            begin
                                SETRANGE("Table Name", TempSalesLine.Type);
                                SETRANGE("No.", TempSalesLine."No.");
                                SETRANGE("Sales Order", TRUE);
                            end;
                        }
                        dataitem(AsmLoop; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            column(AsmLineUnitOfMeasureText; GetUnitOfMeasureDescr(AsmLine."Unit of Measure Code"))
                            {
                            }
                            column(AsmLineQuantity; AsmLine.Quantity)
                            {
                            }
                            column(AsmLineDescription; BlanksForIndent + AsmLine.Description)
                            {
                            }
                            column(AsmLineNo; BlanksForIndent + AsmLine."No.")
                            {
                            }
                            column(AsmLineType; AsmLine.Type)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                IF Number = 1 THEN
                                    AsmLine.FINDSET
                                ELSE
                                    AsmLine.NEXT;
                            end;

                            trigger OnPreDataItem()
                            begin
                                IF NOT DisplayAssemblyInformation THEN
                                    CurrReport.BREAK;
                                IF NOT AsmInfoExistsForLine THEN
                                    CurrReport.BREAK;
                                AsmLine.SETRANGE("Document Type", AsmHeader."Document Type");
                                AsmLine.SETRANGE("Document No.", AsmHeader."No.");
                                SETRANGE(Number, 1, AsmLine.COUNT);
                            end;
                        }
                        dataitem(LotDetail; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            column(gtxtLotCaption; gtxtLotCaption)
                            {
                            }
                            column(gtxtLotNo; gtxtLotNo[Number])
                            {
                            }

                            trigger OnPreDataItem()
                            begin
                                IF gintDetailLineNo = 0 THEN
                                    CurrReport.BREAK;

                                SETRANGE(Number, 1, gintDetailLineNo);
                            end;
                        }

                        trigger OnAfterGetRecord()
                        var
                            SalesLine: Record "Sales Line";
                            lrecItemUOM: Record "Item Unit of Measure";
                            lintLineNo: Integer;
                            lrecSalesLine: Record "Sales Line";
                        begin
                            CLEAR(gtxtLotCaption);
                            CLEAR(gtxtLotNo);
                            CLEAR(gintDetailLineNo);

                            OnLineNumber := OnLineNumber + 1;


                            IF OnLineNumber = 1 THEN
                                FIND('-')
                            ELSE
                                NEXT;

                            IF TempSalesLine.Type = 0 THEN BEGIN
                                TempSalesLine."No." := '';
                                TempSalesLine."Unit of Measure" := '';
                                TempSalesLine."Line Amount" := 0;
                                TempSalesLine."Inv. Discount Amount" := 0;
                                TempSalesLine.Quantity := 0;
                            END ELSE
                                IF TempSalesLine.Type = TempSalesLine.Type::"G/L Account" THEN
                                    TempSalesLine."No." := '';

                            IF TempSalesLine."Tax Area Code" <> '' THEN
                                TaxAmount := TempSalesLine."Amount Including VAT" - TempSalesLine.Amount
                            ELSE
                                TaxAmount := 0;

                            IF TaxAmount <> 0 THEN BEGIN
                                TaxFlag := TRUE;
                                TaxLiable := TempSalesLine.Amount;
                            END ELSE BEGIN
                                TaxFlag := FALSE;
                                TaxLiable := 0;
                            END;

                            AmountExclInvDisc := TempSalesLine."Line Amount";


                            IF (TempSalesLine.Type = TempSalesLine.Type::"Charge (Item)") AND (TempSalesLine."Attached to Line No." <> 0) AND TempSalesLine."Include IC in Unit Price ELA" THEN
                                AmountExclInvDisc := 0;

                            IF TempSalesLine.Quantity = 0 THEN
                                UnitPriceToPrint := 0
                            ELSE
                                UnitPriceToPrint := ROUND(AmountExclInvDisc / TempSalesLine.Quantity, 0.00001);

                            IF (TempSalesLine.Type = TempSalesLine.Type::"Charge (Item)") AND (TempSalesLine."No." = grecSalesSetup."Sales-Freight Item Charge") AND NOT
                               TempSalesLine."Include IC in Unit Price ELA"
                            THEN BEGIN
                                gdecFRChargeAmt := gdecFRChargeAmt + TempSalesLine."Line Amount";
                            END;

                            IF (TempSalesLine.Type = TempSalesLine.Type::"Charge (Item)") AND (TempSalesLine."No." = grecSalesSetup."Sales-Allowance Item Charge") AND NOT
                              TempSalesLine."Include IC in Unit Price ELA"
                            THEN BEGIN
                                gdecSALChargeAmt := gdecSALChargeAmt + TempSalesLine."Line Amount";
                            END;

                            grecSalesLine.SETRANGE("Document Type", TempSalesLine."Document Type");
                            grecSalesLine.SETRANGE("Document No.", TempSalesLine."Document No.");
                            grecSalesLine.SETRANGE(Type, grecSalesLine.Type::"Charge (Item)");
                            grecSalesLine.SETRANGE("Include IC in Unit Price ELA", TRUE);
                            IF grecSalesLine.FIND('-') THEN BEGIN
                                REPEAT
                                    IF TempSalesLine.Quantity = 0 THEN
                                        UnitPriceToPrint := 0
                                    ELSE
                                        UnitPriceToPrint := ROUND((AmountExclInvDisc + grecSalesLine."Line Amount") / grecSalesLine.Quantity, 0.00001);
                                    AmountExclInvDisc += grecSalesLine."Line Amount";
                                UNTIL grecSalesLine.NEXT = 0;
                            END;
                            IF TempSalesLine."Gross Weight" = 0 THEN
                                TempSalesLine."Gross Weight" := TempSalesLine."Net Weight";
                            gdecGrossWeight += ROUND(TempSalesLine.Quantity * TempSalesLine."Gross Weight", 0.00001);

                            CLEAR(gcodCustUOM);
                            CLEAR(gdecCustUOMQty);
                            CLEAR(gdecCustUOMPrice);

                            IF (TempSalesLine."Sales Price UOM ELA" <> '') AND
                               (TempSalesLine."Sales Price UOM ELA" <> TempSalesLine."Unit of Measure Code") AND
                               (TempSalesLine.Type = TempSalesLine.Type::Item)
                            THEN BEGIN
                                gcodCustUOM := TempSalesLine."Sales Price UOM ELA";
                                grecItemUOM.GET(TempSalesLine."No.", TempSalesLine."Sales Price UOM ELA");
                                IF grecItemUOM."Qty. per Unit of Measure" < 1 THEN BEGIN
                                    grecItemUOM.TESTFIELD("Qty. per Base UOM ELA");
                                    gdecCustUOMQty := TempSalesLine."Quantity (Base)" * grecItemUOM."Qty. per Base UOM ELA";
                                    gdecCustUOMPrice := ROUND(TempSalesLine."Unit Price" / TempSalesLine."Qty. per Unit of Measure" / grecItemUOM."Qty. per Base UOM ELA", 0.00001);
                                END ELSE BEGIN
                                    gdecCustUOMQty := TempSalesLine."Quantity (Base)" / grecItemUOM."Qty. per Unit of Measure";
                                    gdecCustUOMPrice := ROUND(TempSalesLine."Unit Price" / TempSalesLine."Qty. per Unit of Measure" * grecItemUOM."Qty. per Unit of Measure", 0.00001);
                                END;
                            END;
                            IF DisplayAssemblyInformation THEN BEGIN
                                AsmInfoExistsForLine := FALSE;
                                IF TempSalesLineAsm.GET(TempSalesLine."Document Type", TempSalesLine."Document No.", TempSalesLine."Line No.") THEN BEGIN
                                    SalesLine.GET(TempSalesLine."Document Type", TempSalesLine."Document No.", TempSalesLine."Line No.");
                                    AsmInfoExistsForLine := SalesLine.AsmToOrderExists(AsmHeader);
                                END;
                            END;
                            CLEAR(BotDep);

                            IF TempSalesLine."Line No." > 1000000000 THEN BEGIN
                                lintLineNo := TempSalesLine."Line No." - 1000000000;
                            END ELSE BEGIN
                                lintLineNo := TempSalesLine."Line No.";
                            END;
                            lrecSalesLine.GET(TempSalesLine."Document Type", TempSalesLine."Document No.", lintLineNo);
                            gtxtBotDep := lrecSalesLine.GetBottleAmount(lrecSalesLine);

                            IF EVALUATE(BotDep, gtxtBotDep) THEN BEGIN
                                BotDep := BotDep * TempSalesLine.Quantity;
                            END;
                            AmountExclInvDisc += BotDep;

                            CLEAR(UPCCode);
                            IF lrecItemUOM.GET(TempSalesLine."No.", TempSalesLine."Unit of Measure Code") THEN BEGIN
                                UPCCode := lrecItemUOM."Std. Pack UPC/EAN Number";
                            END;
                            gdecQty := 0;
                            IF TempSalesLine.Type = TempSalesLine.Type::Item THEN BEGIN
                                gdecQty := TempSalesLine.Quantity;
                                IF TempSalesLine."Quantity Shipped" <> 0 THEN
                                    QtyShipped := TempSalesLine."Quantity Shipped"
                                ELSE
                                    QtyShipped := TempSalesLine.Quantity;
                                IF TempSalesLine."Original Order Qty. ELA" <> QtyShipped THEN
                                    QtyShort := TempSalesLine."Original Order Qty. ELA" - QtyShipped
                                ELSE
                                    QtyShort := 0;
                                IF QtyShort < 0 THEN
                                    QtyShort := 0;
                            END;

                            gblnShowSalesLine :=
                              (TempSalesLine."Include IC in Unit Price ELA" <> TRUE)
                              AND (COPYSTR(TempSalesLine.Description, 1, 6) <> 'Bottle');


                            CurrReport.SHOWOUTPUT(TempSalesLine.Type = 0);

                            IF OnLineNumber = NumberOfLines THEN
                                PrintFooter := TRUE;

                        end;

                        trigger OnPreDataItem()
                        begin
                            CurrReport.CREATETOTALS(TaxLiable, TaxAmount, AmountExclInvDisc, TempSalesLine."Line Amount", TempSalesLine."Inv. Discount Amount");
                            NumberOfLines := TempSalesLine.COUNT;
                            SETRANGE(Number, 1, NumberOfLines);
                            OnLineNumber := 0;
                            PrintFooter := FALSE;
                        end;
                    }
                    dataitem(LedgerLine; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(LedgerLine_Number; Number)
                        {
                        }
                        column(TempCustLedger_DocumentNo; TempCustLedger."Document No.")
                        {
                        }
                        column(TempCustLedger_DocumentDate; FORMAT(TempCustLedger."Document Date"))
                        {
                        }
                        column(TempCustLedger_DueDate; FORMAT(TempCustLedger."Due Date"))
                        {
                        }
                        column(TempCustLedger_Amount; TempCustLedger.Amount)
                        {
                        }
                        column(TempCustLedger_RemainingAmount; TempCustLedger."Remaining Amount")
                        {
                        }

                        trigger OnAfterGetRecord()
                        var
                            lrecDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
                        begin

                            IF LedgerLine.Number = 1 THEN
                                FIND('-')
                            ELSE
                                NEXT;
                            TempCustLedger.CALCFIELDS(Amount, "Remaining Amount");
                            lrecDetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.");
                            lrecDetailedCustLedgEntry.SETRANGE("Cust. Ledger Entry No.", TempCustLedger."Entry No.");
                            lrecDetailedCustLedgEntry.SETRANGE("Document Type", lrecDetailedCustLedgEntry."Document Type"::Payment);
                            lrecDetailedCustLedgEntry.SETRANGE("Entry Type", lrecDetailedCustLedgEntry."Entry Type"::Application);
                            lrecDetailedCustLedgEntry.CALCSUMS(Amount);

                        end;

                        trigger OnPreDataItem()
                        begin
                            SETRANGE(Number, 1, TempCustLedger.COUNT);
                        end;
                    }
                    dataitem(Footer; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        MaxIteration = 1;
                        column(FooterNumber; Number)
                        {
                        }
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    CurrReport.PAGENO := 1;

                    IF CopyNo = NoLoops THEN BEGIN
                        IF NOT CurrReport.PREVIEW THEN
                            SalesPrinted.RUN("Sales Header");
                        CurrReport.BREAK;
                    END;
                    CopyNo := CopyNo + 1;
                    IF CopyNo = 1 THEN
                        CLEAR(CopyTxt)
                    ELSE
                        CopyTxt := Text000;
                end;

                trigger OnPreDataItem()
                begin
                    NoLoops := 1 + ABS(NoCopies);
                    IF NoLoops <= 0 THEN
                        NoLoops := 1;
                    CopyNo := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin


                CLEAR(gdecFRChargeAmt);
                CLEAR(gdecSALChargeAmt);
                CLEAR(gdecGrossWeight);


                IF PrintCompany THEN BEGIN
                    IF RespCenter.GET("Responsibility Center") THEN BEGIN
                        FormatAddress.RespCenter(CompanyAddress, RespCenter);
                        CompanyInformation."Phone No." := RespCenter."Phone No.";
                        CompanyInformation."Fax No." := RespCenter."Fax No.";
                    END;
                END;


                IF gcodLanguageCode <> '' THEN
                    CurrReport.LANGUAGE := Language.GetLanguageID(gcodLanguageCode)
                ELSE
                    CurrReport.LANGUAGE := Language.GetLanguageID("Language Code");


                IF "Salesperson Code" = '' THEN
                    CLEAR(SalesPurchPerson)
                ELSE
                    SalesPurchPerson.GET("Salesperson Code");

                IF "Payment Terms Code" = '' THEN
                    CLEAR(PaymentTerms)
                ELSE
                    PaymentTerms.GET("Payment Terms Code");

                IF "Shipment Method Code" = '' THEN
                    CLEAR(ShipmentMethod)
                ELSE
                    ShipmentMethod.GET("Shipment Method Code");

                IF NOT Cust.GET("Sell-to Customer No.") THEN
                    CLEAR(Cust);

                FormatAddress.SalesHeaderSellTo(BillToAddress, "Sales Header");
                FormatAddress.SalesHeaderShipTo(ShipToAddress, ShipToAddress, "Sales Header");

                IF NOT CurrReport.PREVIEW THEN BEGIN
                    IF ArchiveDocument THEN
                        ArchiveManagement.StoreSalesDocument("Sales Header", LogInteraction);

                    IF LogInteraction THEN BEGIN
                        CALCFIELDS("No. of Archived Versions");
                        IF "Bill-to Contact No." <> '' THEN
                            SegManagement.LogDocument(
                              3, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", DATABASE::Contact, "Bill-to Contact No."
                              , "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.")
                        ELSE
                            SegManagement.LogDocument(
                              3, "No.", "Doc. No. Occurrence",
                              "No. of Archived Versions", DATABASE::Customer, "Bill-to Customer No.",
                              "Salesperson Code", "Campaign No.", "Posting Description", "Opportunity No.");
                    END;
                END;

                CLEAR(BreakdownTitle);
                CLEAR(BreakdownLabel);
                CLEAR(BreakdownAmt);
                TotalTaxLabel := Text008;
                TaxRegNo := '';
                TaxRegLabel := '';
                IF "Tax Area Code" <> '' THEN BEGIN
                    TaxArea.GET("Tax Area Code");
                    CASE TaxArea."Country/Region" OF
                        TaxArea."Country/Region"::US:
                            TotalTaxLabel := Text005;
                        TaxArea."Country/Region"::CA:
                            BEGIN
                                TotalTaxLabel := Text007;
                                TaxRegNo := CompanyInformation."VAT Registration No.";
                                TaxRegLabel := CompanyInformation.FIELDCAPTION("VAT Registration No.");
                            END;
                    END;
                    UseExternalTaxEngine := TaxArea."Use External Tax Engine";
                    SalesTaxCalc.StartSalesTaxCalculation;
                END;

                IF "Posting Date" <> 0D THEN
                    UseDate := "Posting Date"
                ELSE
                    UseDate := WORKDATE;

                IF NOT grecShipAgent.GET("Shipping Agent Code") THEN
                    CLEAR(grecShipAgent);
                IF "No. Pallets" <> 0 THEN
                    gtxtPallets := 'No. Pallets:'
                ELSE
                    gtxtPallets := '';
                gblnShowPrices := FALSE;
                gblnShowCustLedger := FALSE;
                IF (
                  (NOT gblnShowPrices)
                ) THEN BEGIN
                    CLEAR(gtxtUnitPriceCaption);
                    CLEAR(gtxtBottleDepositCaption);
                    CLEAR(gtxtTotalCaption);
                END ELSE BEGIN
                    gtxtUnitPriceCaption := 'Unit Price';
                    gtxtBottleDepositCaption := 'Bottle Deposit';
                    gtxtTotalCaption := 'Total Price';
                END;
                CLEAR(SalesNoBarcode);
                SalesNoBarcode := '*' + COPYSTR(FORMAT("Sales Header"."No."), 3, 7) + '*';

            end;

            trigger OnPreDataItem()
            begin

                grecSalesSetup.GET;

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
                    field(NoCopies; NoCopies)
                    {
                        Caption = 'Number of Copies';
                    }
                    field(PrintCompanyAddress; PrintCompany)
                    {
                        Caption = 'Print Company Address';
                    }
                    field(ArchiveDocument; ArchiveDocument)
                    {
                        Caption = 'Archive Document';
                        Enabled = ArchiveDocumentEnable;

                        trigger OnValidate()
                        begin
                            IF NOT ArchiveDocument THEN
                                LogInteraction := FALSE;
                        end;
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;

                        trigger OnValidate()
                        begin
                            IF LogInteraction THEN
                                ArchiveDocument := ArchiveDocumentEnable;
                        end;
                    }
                    field("Display Assembly information"; DisplayAssemblyInformation)
                    {
                        Caption = 'Show Assembly Components';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            LogInteractionEnable := TRUE;
            ArchiveDocumentEnable := TRUE;
        end;

        trigger OnOpenPage()
        begin
            ArchiveDocument := ArchiveManagement.SalesDocArchiveGranule;
            LogInteraction := SegManagement.FindInteractTmplCode(3) <> '';

            ArchiveDocumentEnable := ArchiveDocument;
            LogInteractionEnable := LogInteraction;
        end;
    }

    labels
    {
        lblShip = 'Ship To:';
        lblTo = 'To:';
        lblInvoiceNo = 'Invoice Number:';
        lblInvoiceDate = 'Invoice Date:';
        lblPage = 'Page:';
        lblShipVia = 'Ship Via:';
        lblShipDate = 'Ship Date:';
        lblTruckRoute = 'Truck Route:';
        lblTerms = 'Terms:';
        lblCustomerID = 'Customer ID:';
        lblPONumber = 'P.O. Number:';
        lblPODate = 'P.O. Date:';
        lblSalesperson = 'Salesperson:';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.GET;
        SalesSetup.GET;


        IF PrintCompany THEN
            FormatAddress.Company(CompanyAddress, CompanyInformation)
        ELSE
            CLEAR(CompanyAddress);
    end;

    var
        [InDataSet]
        SalesNoBarcode: Text[100];
        TaxLiable: Decimal;
        UnitPriceToPrint: Decimal;
        AmountExclInvDisc: Decimal;
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        CompanyInformation: Record "Company Information";
        CompanyInfo1: Record "Company Information";
        CompanyInfo2: Record "Company Information";
        CompanyInfo3: Record "Company Information";
        SalesSetup: Record "Sales & Receivables Setup";
        TempSalesLine: Record "Sales Line" temporary;
        TempSalesLineAsm: Record "Sales Line" temporary;
        RespCenter: Record "Responsibility Center";
        Language: Record Language;
        TempSalesTaxAmtLine: Record "Sales Tax Amount Line" temporary;
        TaxArea: Record "Tax Area";
        Cust: Record Customer;
        AsmHeader: Record "Assembly Header";
        AsmLine: Record "Assembly Line";
        CompanyAddress: array[8] of Text[50];
        BillToAddress: array[8] of Text[50];
        ShipToAddress: array[8] of Text[50];
        CopyTxt: Text[10];
        PrintCompany: Boolean;
        PrintFooter: Boolean;
        TaxFlag: Boolean;
        NoCopies: Integer;
        NoLoops: Integer;
        CopyNo: Integer;
        NumberOfLines: Integer;
        OnLineNumber: Integer;
        HighestLineNo: Integer;
        SpacePointer: Integer;
        SalesPrinted: Codeunit "Sales-Printed";
        FormatAddress: Codeunit "Format Address";
        SalesTaxCalc: Codeunit "Sales Tax Calculate";
        TaxAmount: Decimal;
        SegManagement: Codeunit SegManagement;
        ArchiveManagement: Codeunit ArchiveManagement;
        ArchiveDocument: Boolean;
        LogInteraction: Boolean;
        Text000: Label 'COPY';
        Text003: Label 'Sales Tax Breakdown:';
        Text004: Label 'Other Taxes';
        Text005: Label 'Total Sales Tax:';
        Text006: Label 'Tax Breakdown:';
        Text007: Label 'Total Tax:';
        Text008: Label 'Tax:';
        TaxRegNo: Text[30];
        TaxRegLabel: Text[30];
        TotalTaxLabel: Text[30];
        BreakdownTitle: Text[30];
        BreakdownLabel: array[4] of Text[30];
        BreakdownAmt: array[4] of Decimal;
        BrkIdx: Integer;
        PrevPrintOrder: Integer;
        PrevTaxPercent: Decimal;
        UseDate: Date;
        UseExternalTaxEngine: Boolean;
        [InDataSet]
        ArchiveDocumentEnable: Boolean;
        [InDataSet]
        LogInteractionEnable: Boolean;
        DisplayAssemblyInformation: Boolean;
        AsmInfoExistsForLine: Boolean;
        SoldCaptionLbl: Label 'Sold';
        ToCaptionLbl: Label 'Ship To:';
        ShipDateCaptionLbl: Label 'Ship Date';
        CustomerIDCaptionLbl: Label 'Customer ID';
        PONumberCaptionLbl: Label 'P.O. Number';
        SalesPersonCaptionLbl: Label 'SalesPerson';
        ShipCaptionLbl: Label 'Ship To:';
        SalesOrderCaptionLbl: Label 'SALES ORDER';
        SalesOrderNumberCaptionLbl: Label 'Sales Order Number:';
        SalesOrderDateCaptionLbl: Label 'Sales Order Date:';
        PageCaptionLbl: Label 'Page:';
        ShipViaCaptionLbl: Label 'Ship Via';
        TermsCaptionLbl: Label 'Terms';
        PODateCaptionLbl: Label 'P.O. Date';
        TaxIdentTypeCaptionLbl: Label 'Tax Ident. Type';
        ItemNoCaptionLbl: Label 'Item No.';
        UnitCaptionLbl: Label 'Unit';
        DescriptionCaptionLbl: Label 'Description';
        QuantityCaptionLbl: Label 'Quantity';
        UnitPriceCaptionLbl: Label 'Unit Price';
        TotalPriceCaptionLbl: Label 'Total Price';
        SubtotalCaptionLbl: Label 'Subtotal:';
        InvoiceDiscountCaptionLbl: Label 'Invoice Discount:';
        TotalCaptionLbl: Label 'Total:';
        AmtSubjecttoSalesTaxCptnLbl: Label 'Amount Subject to Sales Tax';
        AmtExemptfromSalesTaxCptnLbl: Label 'Amount Exempt from Sales Tax';
        grecSalesSetup: Record "Sales & Receivables Setup";
        grecItemUOM: Record "Item Unit of Measure";
        grecSalesLine: Record "Sales Line";
        gtxtFRChargeItem: Text[30];
        gdecFRChargeAmt: Decimal;
        gtxtSALChargeItem: Text[30];
        gdecSALChargeAmt: Decimal;
        gintDetailLineNo: Decimal;
        gtxtLotCaption: Text[30];
        gtxtLotNo: array[1000] of Text[250];
        gtxtPallets: Text[30];
        gdecGrossWeight: Decimal;
        gtxtGrossWeight: Text[30];
        grecShipAgent: Record "Shipping Agent";
        gcodCustUOM: Code[10];
        gdecCustUOMQty: Decimal;
        gdecCustUOMPrice: Decimal;
        gcodLanguageCode: Code[20];
        "--YOG--": Integer;
        gtxtUnitPriceCaption: Text;
        gtxtBottleDepositCaption: Text;
        gtxtTotalCaption: Text;

        QtyShort: Decimal;
        QtyShipped: Decimal;
        BotDep: Decimal;
        TempCustLedger: Record "Cust. Ledger Entry" temporary;
        gtxtBotDep: Text[30];
        UPCCode: Text[100];
        FirstShort: Boolean;
        gblnShowSalesLine: Boolean;
        gblnShowPrices: Boolean;
        gblnShowDescLine: Boolean;
        DescText: Text[100];
        GreenQtyCaptionLabel: Label 'Green';
        BreakingQtyCaptionLabel: Label 'Break';
        NoGasQtyCaptionLabel: Label 'NoGas';
        ColorQtyCaptionLabel: Label 'Color';
        grecExtTextHeader: Record "Extended Text Header";
        gblnShowCustLedger: Boolean;
        gdecQty: Decimal;

    [Scope('Internal')]
    procedure GetUnitOfMeasureDescr(UOMCode: Code[10]): Text[10]
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        IF NOT UnitOfMeasure.GET(UOMCode) THEN
            EXIT(UOMCode);
        EXIT(UnitOfMeasure.Description);
    end;

    [Scope('Internal')]
    procedure BlanksForIndent(): Text[10]
    begin
        EXIT(PADSTR('', 2, ' '));
    end;

    [Scope('Internal')]
    procedure nsjjGetLotNo(): Text[30]
    var
        lrecItem: Record Item;
        lrecReservEntry: Record "Reservation Entry";
        lrecTrackingSpecification: Record "Tracking Specification";
        lintCount: Integer;
        lintCountonEachLine: Integer;
    begin
        lintCountonEachLine := 100;
        gintDetailLineNo := 0;

        lrecReservEntry.RESET;
        lrecReservEntry.SETCURRENTKEY("Source ID", "Source Ref. No.", "Source Type", "Source Subtype");
        lrecReservEntry.SETRANGE("Source ID", TempSalesLine."Document No.");
        lrecReservEntry.SETRANGE("Source Ref. No.", TempSalesLine."Line No.");
        lrecReservEntry.SETRANGE("Source Type", 37);
        lrecReservEntry.SETRANGE("Source Subtype", TempSalesLine."Document Type");
        IF lrecReservEntry.FIND('-') THEN BEGIN

            IF gintDetailLineNo = 0 THEN
                gintDetailLineNo := 1;

            lrecItem.GET(lrecReservEntry."Item No.");
            REPEAT
                IF lrecReservEntry."Lot No." <> '' THEN BEGIN
                    gtxtLotCaption := 'Lot No.:';

                    IF (STRLEN(gtxtLotNo[gintDetailLineNo]) +
                       STRLEN(lrecReservEntry."Lot No.") +
                       STRLEN(FORMAT(-lrecReservEntry."Quantity (Base)")) +
                       STRLEN(FORMAT(lrecItem."Base Unit of Measure")) + 6) <
                       lintCountonEachLine
                    THEN BEGIN
                        IF lintCount = 0 THEN
                            gtxtLotNo[gintDetailLineNo] :=
                              lrecReservEntry."Lot No." +
                              ' (' + FORMAT(-lrecReservEntry."Quantity (Base)") + ' ' +
                                     FORMAT(lrecItem."Base Unit of Measure") + ')'
                        ELSE
                            gtxtLotNo[gintDetailLineNo] :=
                              gtxtLotNo[gintDetailLineNo] + ', ' + lrecReservEntry."Lot No." +
                              ' (' + FORMAT(-lrecReservEntry."Quantity (Base)") + ' ' +
                                     FORMAT(lrecItem."Base Unit of Measure") + ')';

                        lintCount := lintCount + 1;

                    END ELSE BEGIN
                        gintDetailLineNo += 1;
                        lintCount := 0;
                        IF lintCount = 0 THEN
                            gtxtLotNo[gintDetailLineNo] :=
                              lrecReservEntry."Lot No." +
                              ' (' + FORMAT(-lrecReservEntry."Quantity (Base)") + ' ' +
                                     FORMAT(lrecItem."Base Unit of Measure") + ')'
                        ELSE
                            gtxtLotNo[gintDetailLineNo] :=
                              gtxtLotNo[gintDetailLineNo] + ', ' + lrecReservEntry."Lot No." +
                              ' (' + FORMAT(-lrecReservEntry."Quantity (Base)") + ' ' +
                                     FORMAT(lrecItem."Base Unit of Measure") + ')';

                        lintCount := lintCount + 1;
                    END;
                END;
            UNTIL lrecReservEntry.NEXT = 0;
        END;

        lrecTrackingSpecification.SETCURRENTKEY(
          "Source ID", "Source Type", "Source Subtype",
          "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.");
        lrecTrackingSpecification.SETRANGE("Source ID", TempSalesLine."Document No.");
        lrecTrackingSpecification.SETRANGE("Source Type", DATABASE::"Sales Line");
        lrecTrackingSpecification.SETRANGE("Source Subtype", TempSalesLine."Document Type");
        lrecTrackingSpecification.SETRANGE("Source Batch Name", '');
        lrecTrackingSpecification.SETRANGE("Source Prod. Order Line", 0);
        lrecTrackingSpecification.SETRANGE("Source Ref. No.", TempSalesLine."Line No.");

        IF lrecTrackingSpecification.FIND('-') THEN BEGIN
            IF gintDetailLineNo = 0 THEN
                gintDetailLineNo := 1;

            lrecItem.GET(lrecTrackingSpecification."Item No.");

            REPEAT
                IF lrecTrackingSpecification."Lot No." <> '' THEN BEGIN
                    gtxtLotCaption := 'Lot No.:';

                    IF (STRLEN(gtxtLotNo[gintDetailLineNo]) +
                       STRLEN(lrecTrackingSpecification."Lot No.") +
                       STRLEN(FORMAT(-lrecTrackingSpecification."Quantity (Base)")) +
                       STRLEN(FORMAT(lrecItem."Base Unit of Measure")) + 6) <
                       lintCountonEachLine
                    THEN BEGIN
                        IF lintCount = 0 THEN
                            gtxtLotNo[gintDetailLineNo] :=
                              lrecTrackingSpecification."Lot No." +
                              ' (' + FORMAT(-lrecTrackingSpecification."Quantity (Base)") + ' ' +
                                     FORMAT(lrecItem."Base Unit of Measure") + ')'
                        ELSE
                            gtxtLotNo[gintDetailLineNo] :=
                              gtxtLotNo[gintDetailLineNo] + ', ' + lrecTrackingSpecification."Lot No." +
                              ' (' + FORMAT(-lrecTrackingSpecification."Quantity (Base)") + ' ' +
                                     FORMAT(lrecItem."Base Unit of Measure") + ')';

                        lintCount := lintCount + 1;

                    END ELSE BEGIN
                        gintDetailLineNo += 1;
                        lintCount := 0;
                        IF lintCount = 0 THEN
                            gtxtLotNo[gintDetailLineNo] :=
                              lrecTrackingSpecification."Lot No." +
                              ' (' + FORMAT(-lrecTrackingSpecification."Quantity (Base)") + ' ' +
                                     FORMAT(lrecItem."Base Unit of Measure") + ')'
                        ELSE
                            gtxtLotNo[gintDetailLineNo] :=
                              gtxtLotNo[gintDetailLineNo] + ', ' + lrecTrackingSpecification."Lot No." +
                              ' (' + FORMAT(-lrecTrackingSpecification."Quantity (Base)") + ' ' +
                                     FORMAT(lrecItem."Base Unit of Measure") + ')';

                        lintCount := lintCount + 1;

                    END;
                END;

            UNTIL lrecTrackingSpecification.NEXT = 0;
        END;

        IF gtxtLotNo[1] = '' THEN
            gintDetailLineNo := 0;
    end;
}

