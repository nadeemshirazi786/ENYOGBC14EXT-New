report 51013 "Delivery Tkt BANANA"
{
    // EN1.00 20-07-31 FS
    //   Addition of Barcode in report + Fixes
    // --------------------------------------------------------
    // 
    // Copyright Axentia Solutions Corp.  1999-2013.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // 
    // //<JF0000xxDO>
    //   Made changes to printing of Item charges if they come from Customer / Item Surcharges
    //   Allows the order to "hide" the surcharge in the unit price of the item if gblnIncludeSurchargeInUP;
    //   Added grecSalesSetup to get Sales Freight Charge Setup.
    // 
    // AX00015JJ
    //   20050924 - Changed the way that calculate Freight if the item is set to include IC in Unit Price
    //              To show the Fright Amount at the bottom instead of include the price in the Unit Price
    // 
    // JFMG
    //   20081104 - Update key for Comment table and add filter to show header comments only
    // 
    // JF10546AC
    //   20101122 - rename "No. Pallets (Std.)" -> "No. Pallets"
    // 
    // JF30041SHR
    //   20130121 - removed old jf report and add above changes added to base report
    // 
    // <YOG42476AC> 20140831 - merge in YOG custom stuff
    // 
    // MNJR01, Myers Nissi, Jack Reynolds, 18 JUN 02, YG0108B
    //   Accumulate freight charge (based on item type) and display in footer
    // 
    // YG0175B, Myers Nissi, Jack Reynolds, 25 MAR 03
    //   Remove quantity short from line item detail
    // 
    // YG0183B, Myers Nissi, Jack Reynolds, 29 APR 03
    //   Modify so that lines shipped short are grouped after the other lines
    // 
    // YG0187B, Myers Nissi, Jack Reynolds, 22 MAY 03
    //   Change the sort key on the Sales Line data item to process in the same order as the SalesLine
    //     data item (temp table)
    // 
    // YG0256A, VerticalSoft, Steve Post, 02 MAR 06
    //   added code and section to print comment sales lines
    // 
    // YG0259A, VerticalSoft, Steve Post, 13 JUL 06
    //   Add size control
    // 
    // YG0265A, VerticalSoft, Jack Reynolds, 22 NOV 06
    //   Modify to not print for any orders where picking status is Picking or Suspended
    // 
    // YG69101, VerticalSoft, Marie-Pierre Gagnon, 12 NOV 07
    //   CANCEL MNJR01 - freight is part again of unit price
    //   Stop deducting Total Freight from Invoice Discount footer total
    // 
    // EN1.00, Elation, KS, 08 Aug 2013
    //   Added Signature on Document
    // 
    // </YOG42476AC>
    // 
    // DP20150625
    //   -Changed sort order to be Shipment Date, Order Template Location, Stop No.
    // 
    // DP20151001
    //   20151001  - legacy code set Qty Shipped to equal Quantity instead of zero for some reason. Changed it to show zero accordingly.
    DefaultLayout = RDLC;
    RDLCLayout = './DeliveryTktBANANA.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
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
                        WITH TempSalesLine DO BEGIN
                            INIT;
                            "Document Type" := "Sales Header"."Document Type";
                            "Document No." := "Sales Header"."No.";
                            "Line No." := HighestLineNo + 10;
                            HighestLineNo := "Line No.";
                        END;
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

                    //<JF00043MG>
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
                    //</JF00043MG>

                    // YG0183B Begin
                    TempSalesLine."Drop Shipment" := FALSE; // used to mark the first short shipment line
                    IF "Quantity Shipped" <> 0 THEN
                        QtyShipped := "Quantity Shipped"
                    ELSE
                        //<DP20151001>
                        QtyShipped := 0;
                    //QtyShipped := Quantity;
                    //</DP20151001>
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
                    // YG0183B End

                    TempSalesLine.INSERT;
                    TempSalesLineAsm := "Sales Line";
                    //<YOG42476AC>
                    TempSalesLineAsm."Line No." := TempSalesLine."Line No.";
                    //</YOG42476AC>
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
                        WITH TempSalesTaxAmtLine DO BEGIN
                            RESET;
                            SETCURRENTKEY("Print Order", "Tax Area Code for Key", "Tax Jurisdiction Code");
                            IF FIND('-') THEN
                                REPEAT
                                    IF ("Print Order" = 0) OR
                                       ("Print Order" <> PrevPrintOrder) OR
                                       ("Tax %" <> PrevTaxPercent)
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
                                            BreakdownLabel[BrkIdx] := STRSUBSTNO("Print Description", "Tax %");
                                    END;
                                    BreakdownAmt[BrkIdx] := BreakdownAmt[BrkIdx] + "Tax Amount";
                                UNTIL NEXT = 0;
                        END;
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

                    FirstShort := TRUE; // YG0183B
                end;
            }
            dataitem("Sales Comment Line"; "Sales Comment Line")
            {
                DataItemLink = "No." = FIELD("No.");
                DataItemTableView = SORTING("Document Type", "No.", "Document Line No.", "Line No.") WHERE("Document Type" = CONST(Order), "Print On Order Confirmation" = CONST(true), "Document Line No." = CONST(0));

                trigger OnAfterGetRecord()
                begin
                    WITH TempSalesLine DO BEGIN
                        INIT;
                        "Document Type" := "Sales Header"."Document Type";
                        "Document No." := "Sales Header"."No.";
                        "Line No." := HighestLineNo + 1000;
                        HighestLineNo := "Line No.";
                    END;
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
                    column(CompanyInfo2Picture; CompanyInfo2.Picture)
                    {
                    }
                    column(CompanyInfo1Picture; CompanyInfo1.Picture)
                    {
                    }
                    column(CompanyInfoPicture; CompanyInfo3.Picture)
                    {
                    }
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
                    column(SalesHeader_OrderTemplateLocation; "Sales Header"."Order Template Location ELA")
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
                        column(TempSalesLineQuantity; TempSalesLine.Quantity)
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
                        column(grecUOMSize_Description; grecUOMSize.Description)
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

                                //<AX00015JJ>
                                IF gintDetailLineNo = 0 THEN
                                    CurrReport.BREAK;

                                SETRANGE(Number, 1, gintDetailLineNo);
                                //</AX00015JJ>
                            end;
                        }

                        trigger OnAfterGetRecord()
                        var
                            SalesLine: Record "Sales Line";
                            lrecItemUOM: Record "Item Unit of Measure";
                        begin

                            //<AX00015JJ>
                            CLEAR(gtxtLotCaption);
                            CLEAR(gtxtLotNo);
                            CLEAR(gintDetailLineNo);
                            //</AX00015JJ>

                            OnLineNumber := OnLineNumber + 1;

                            WITH TempSalesLine DO BEGIN
                                IF OnLineNumber = 1 THEN
                                    FIND('-')
                                ELSE
                                    NEXT;

                                IF Type = 0 THEN BEGIN
                                    "No." := '';
                                    "Unit of Measure" := '';
                                    "Line Amount" := 0;
                                    "Inv. Discount Amount" := 0;
                                    Quantity := 0;
                                END ELSE
                                    IF Type = Type::"G/L Account" THEN
                                        "No." := '';

                                IF "Tax Area Code" <> '' THEN
                                    TaxAmount := "Amount Including VAT" - Amount
                                ELSE
                                    TaxAmount := 0;

                                IF TaxAmount <> 0 THEN BEGIN
                                    TaxFlag := TRUE;
                                    TaxLiable := Amount;
                                END ELSE BEGIN
                                    TaxFlag := FALSE;
                                    TaxLiable := 0;
                                END;

                                AmountExclInvDisc := "Line Amount";


                                //<JF00008DO>
                                IF (Type = Type::"Charge (Item)") AND ("Attached to Line No." <> 0) AND "Include IC in Unit Price ELA" THEN
                                    AmountExclInvDisc := 0;
                                //<JF00008DO>

                                IF Quantity = 0 THEN
                                    UnitPriceToPrint := 0 // so it won't print
                                ELSE
                                    UnitPriceToPrint := ROUND(AmountExclInvDisc / Quantity, 0.00001);

                                //<JF00008DO>
                                IF (Type = Type::"Charge (Item)") AND ("No." = grecSalesSetup."Sales-Freight Item Charge") AND NOT
                                   "Include IC in Unit Price ELA"
                                THEN BEGIN
                                    gdecFRChargeAmt := gdecFRChargeAmt + "Line Amount";
                                END;

                                IF (Type = Type::"Charge (Item)") AND ("No." = grecSalesSetup."Sales-Allowance Item Charge") AND NOT
                                   "Include IC in Unit Price ELA"
                                THEN BEGIN
                                    gdecSALChargeAmt := gdecSALChargeAmt + "Line Amount";
                                END;

                                grecSalesLine.SETRANGE("Document Type", "Document Type");
                                grecSalesLine.SETRANGE("Document No.", "Document No.");
                                grecSalesLine.SETRANGE("Attached to Line No.", "Line No.");
                                grecSalesLine.SETRANGE(Type, grecSalesLine.Type::"Charge (Item)");
                                grecSalesLine.SETRANGE("Include IC in Unit Price ELA", TRUE);
                                IF grecSalesLine.FIND('-') THEN BEGIN
                                    REPEAT
                                        IF Quantity = 0 THEN
                                            UnitPriceToPrint := 0
                                        ELSE
                                            UnitPriceToPrint := ROUND((AmountExclInvDisc + grecSalesLine."Line Amount") / Quantity, 0.00001);
                                        AmountExclInvDisc += grecSalesLine."Line Amount";
                                    UNTIL grecSalesLine.NEXT = 0;
                                END;
                                //<JF00008DO>

                                //<JF00036DO>
                                IF "Gross Weight" = 0 THEN
                                    "Gross Weight" := "Net Weight";
                                gdecGrossWeight += ROUND(Quantity * "Gross Weight", 0.00001);
                                //<JF00036DO>

                                //<JF>

                                CLEAR(gcodCustUOM);
                                CLEAR(gdecCustUOMQty);
                                CLEAR(gdecCustUOMPrice);

                                IF ("Sales Price UOM ELA" <> '') AND
                                   ("Sales Price UOM ELA" <> "Unit of Measure Code") AND
                                   (Type = Type::Item)
                                THEN BEGIN
                                    gcodCustUOM := "Sales Price UOM ELA";
                                    grecItemUOM.GET("No.", "Sales Price UOM ELA");
                                    IF grecItemUOM."Qty. per Unit of Measure" < 1 THEN BEGIN
                                        grecItemUOM.TESTFIELD("Qty. per Base UOM ELA");
                                        gdecCustUOMQty := "Quantity (Base)" * grecItemUOM."Qty. per Base UOM ELA";
                                        gdecCustUOMPrice := ROUND("Unit Price" / "Qty. per Unit of Measure" / grecItemUOM."Qty. per Base UOM ELA", 0.00001);
                                    END ELSE BEGIN
                                        gdecCustUOMQty := "Quantity (Base)" / grecItemUOM."Qty. per Unit of Measure";
                                        gdecCustUOMPrice := ROUND("Unit Price" / "Qty. per Unit of Measure" * grecItemUOM."Qty. per Unit of Measure", 0.00001);
                                    END;
                                END;
                                //</JF>
                                IF DisplayAssemblyInformation THEN BEGIN
                                    AsmInfoExistsForLine := FALSE;
                                    IF TempSalesLineAsm.GET("Document Type", "Document No.", "Line No.") THEN BEGIN
                                        SalesLine.GET("Document Type", "Document No.", "Line No.");
                                        AsmInfoExistsForLine := SalesLine.AsmToOrderExists(AsmHeader);
                                    END;
                                END;

                                //<YOG42476AC>
                                IF (
                                  (NOT grecUOMSize.GET("Unit of Measure Code"))
                                ) THEN BEGIN
                                    CLEAR(grecUOMSize);
                                END;

                                gtxtBotDep := jfGetUDCalculation('85_BOTTLE');
                                IF EVALUATE(BotDep, gtxtBotDep) THEN BEGIN
                                    BotDep := BotDep * Quantity;
                                END;
                                AmountExclInvDisc += BotDep;

                                CLEAR(UPCCode);
                                IF lrecItemUOM.GET("No.", "Unit of Measure Code") THEN BEGIN
                                    UPCCode := lrecItemUOM."Std. Pack UPC/EAN Number";
                                END;

                                IF TempSalesLine."Quantity Shipped" <> 0 THEN
                                    QtyShipped := TempSalesLine."Quantity Shipped"
                                ELSE
                                    QtyShipped := TempSalesLine.Quantity;
                                IF TempSalesLine."Original Order Qty. ELA" <> QtyShipped THEN
                                    QtyShort := TempSalesLine."Original Order Qty. ELA" - QtyShipped
                                ELSE
                                    QtyShort := 0;
                                IF QtyShort < 0 THEN // YG0175B
                                    QtyShort := 0;     // YG0175B

                                gblnShowSalesLine :=
                                  (COPYSTR(TempSalesLine.Description, 1, 6) <> 'Pallet')
                                  AND (TempSalesLine.Type <> 0); // YG0256A

                                CurrReport.SHOWOUTPUT(TempSalesLine.Type = 0); // YG0256A

                                //</YOG424760AC>

                            END;

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
                            WITH TempCustLedger DO BEGIN
                                IF LedgerLine.Number = 1 THEN
                                    FIND('-')
                                ELSE
                                    NEXT;
                                CALCFIELDS(Amount, "Remaining Amount");

                                //<YOG42440AC>
                                //@@
                                lrecDetailedCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.");
                                lrecDetailedCustLedgEntry.SETRANGE("Cust. Ledger Entry No.", "Entry No.");
                                //lrecDetailedCustLedgEntry.SETRANGE( "Document No.", "Sales Invoice Header"."No." );
                                lrecDetailedCustLedgEntry.SETRANGE("Document Type", lrecDetailedCustLedgEntry."Document Type"::Payment);
                                lrecDetailedCustLedgEntry.SETRANGE("Entry Type", lrecDetailedCustLedgEntry."Entry Type"::Application);
                                lrecDetailedCustLedgEntry.CALCSUMS(Amount);

                                //@@gdecAppliedPaymentAmount := ABS( lrecDetailedCustLedgEntry.Amount );
                                //</YOG42440AC>

                            END;
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
                        column(Signature; Signature.Signature)
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
                    IF CopyNo = 1 THEN // Original
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

                //<JF000xxDO>
                CLEAR(gdecFRChargeAmt);
                CLEAR(gdecSALChargeAmt);
                CLEAR(gdecGrossWeight);
                //<JF000xxDO>

                IF PrintCompany THEN BEGIN
                    IF RespCenter.GET("Responsibility Center") THEN BEGIN
                        FormatAddress.RespCenter(CompanyAddress, RespCenter);
                        CompanyInformation."Phone No." := RespCenter."Phone No.";
                        CompanyInformation."Fax No." := RespCenter."Fax No.";
                    END;
                END;


                //<JF00043MG>
                /*
                CurrReport.LANGUAGE := Language.GetLanguageID("Language Code");
                */

                IF gcodLanguageCode <> '' THEN
                    CurrReport.LANGUAGE := Language.GetLanguageID(gcodLanguageCode)
                ELSE
                    CurrReport.LANGUAGE := Language.GetLanguageID("Language Code");
                //</JF00043MG>


                IF "Salesperson Code" = '' THEN
                    CLEAR(SalesPurchPerson)
                ELSE
                    SalesPurchPerson.GET("Salesperson Code");

                // EN1.00 START
                CLEAR(Signature);
                IF Signature.GET("Sales Header"."No.") THEN
                    Signature.CALCFIELDS(Signature);
                // EN1.00 END

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
                SalesHeaderShipTo(ShipToAddress, "Sales Header");

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


                //<JF000xxDO>
                IF NOT grecShipAgent.GET("Shipping Agent Code") THEN
                    CLEAR(grecShipAgent);
                //<JF000xxDO>

                //<JF00036DO>
                IF "No. Pallets" <> 0 THEN
                    gtxtPallets := 'No. Pallets:'
                ELSE
                    gtxtPallets := '';
                //<JF00036DO>


                //<JF12952>
                gblnShowPrices := FALSE;
                IF Cust.GET("Sell-to Customer No.") THEN BEGIN
                    gblnShowPrices := Cust."Prices on Invoice ELA";
                END;
                //</JF12952>

                //<YOG42476AC>
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
                //</YOG42476AC>

                SalesNoBarcode := '*' + COPYSTR(FORMAT("No."), 3, 7) + '*'; //EN1.00

            end;

            trigger OnPreDataItem()
            begin
                //<JF000xxDO>
                grecSalesSetup.GET;
                //<JF000xxDO>
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
        lblShip = 'Ship';
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

        CASE SalesSetup."Logo Position on Documents" OF
            SalesSetup."Logo Position on Documents"::"No Logo":
                ;
            SalesSetup."Logo Position on Documents"::Left:
                BEGIN
                    CompanyInfo3.GET;
                    CompanyInfo3.CALCFIELDS(Picture);
                END;
            SalesSetup."Logo Position on Documents"::Center:
                BEGIN
                    CompanyInfo1.GET;
                    CompanyInfo1.CALCFIELDS(Picture);
                END;
            SalesSetup."Logo Position on Documents"::Right:
                BEGIN
                    CompanyInfo2.GET;
                    CompanyInfo2.CALCFIELDS(Picture);
                END;
        END;

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
        ToCaptionLbl: Label 'To:';
        ShipDateCaptionLbl: Label 'Ship Date';
        CustomerIDCaptionLbl: Label 'Customer ID';
        PONumberCaptionLbl: Label 'P.O. Number';
        SalesPersonCaptionLbl: Label 'SalesPerson';
        ShipCaptionLbl: Label 'Ship';
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
        grecUOMSize: Record "Item Unit of Measure Size";
        QtyShort: Decimal;
        QtyShipped: Decimal;
        BotDep: Decimal;
        TempCustLedger: Record "Cust. Ledger Entry" temporary;
        gtxtBotDep: Text[30];
        UPCCode: Text[100];
        FirstShort: Boolean;
        gblnShowSalesLine: Boolean;
        gblnShowPrices: Boolean;
        grecUserDefCust: Record "User-Defined Fields - Customer";
        gblnShowDescLine: Boolean;
        DescText: Text[100];
        Signature: Record "EN Sales Order Signature";

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
        //How many charators to print on each line
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

    procedure SalesHeaderShipTo(VAR AddrArray: ARRAY[8] OF Text[50]; VAR SalesHeader: Record "Sales Header")
    var
        FormatAddress: Codeunit "Format Address";
    begin
        WITH SalesHeader DO
            FormatAddress.FormatAddr(
              AddrArray, "Ship-to Name", "Ship-to Name 2", "Ship-to Contact", "Ship-to Address", "Ship-to Address 2",
              "Ship-to City", "Ship-to Post Code", "Ship-to County", "Ship-to Country/Region Code");
    end;
}

