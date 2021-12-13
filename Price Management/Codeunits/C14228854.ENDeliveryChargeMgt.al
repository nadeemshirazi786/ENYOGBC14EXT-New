codeunit 14228854 "EN Delivery Charge Mgt"
{
    var
        IsOrderRuleCombo: Boolean;
        SalesHeader: Record "Sales Header";
        DimMgt: Codeunit DimensionManagement;
        OrderRuleSalesLine: Record "EN Order Rule Sales Line";

    procedure AddOrderSurcharges(precSalesHeader: Record "Sales Header"; pblnIncludeDocLevelSurcharges: Boolean)
    var
        lSalesLine: Record "Sales Line";
    begin

        IF precSalesHeader."Document Type" = precSalesHeader."Document Type"::"Blanket Order" THEN
            EXIT;

        IF precSalesHeader."Bypass Surcharge Calc ELA" THEN
            EXIT;

        lSalesLine.SETRANGE("Document Type", precSalesHeader."Document Type");
        lSalesLine.SETRANGE("Document No.", precSalesHeader."No.");
        lSalesLine.SETRANGE(Type, lSalesLine.Type::Item);
        IF lSalesLine.ISEMPTY THEN
            EXIT;

        IF lSalesLine.FINDSET THEN
            REPEAT
                IF (lSalesLine.Quantity > lSalesLine."Quantity Shipped") AND
                   (lSalesLine."Allow Item Charge Assignment") THEN BEGIN
                    ProcessSalesLineSurcharges(lSalesLine);
                END;
            UNTIL lSalesLine.NEXT = 0;
    end;

    procedure ProcessSalesLineSurcharges(precSalesLine: Record "Sales Line")
    var
        lSalesHeader: Record "Sales Header";
        lEnumItemChrgType: Enum "EN Item Charge Type";
    begin

        IF precSalesLine."Document Type" = precSalesLine."Document Type"::"Blanket Order" THEN
            EXIT;

        lSalesHeader.GET(precSalesLine."Document Type", precSalesLine."Document No.");

        IF lSalesHeader."Bypass Surcharge Calc ELA" THEN
            EXIT;

        DeleteExistingChargeLines(precSalesLine);

        IF precSalesLine.Quantity <> 0 THEN BEGIN

            AddDeliveryChargeLine(precSalesLine, lEnumItemChrgType::"Delivery Charge");
            AddDeliveryChargeLine(precSalesLine, lEnumItemChrgType::"Delivery Allowance");

            CASE precSalesLine."Document Type" OF
                precSalesLine."Document Type"::Order, precSalesLine."Document Type"::Invoice:
                    BEGIN
                        UpdateLinkedItemCharges(precSalesLine, precSalesLine.FIELDNO("Qty. to Ship"));
                        IF precSalesLine."Qty. to Ship" <> 0 THEN BEGIN
                            UpdateLinkedItemCharges(precSalesLine, precSalesLine.FIELDNO("Qty. to Invoice"));
                        END;
                    END;
                precSalesLine."Document Type"::"Return Order", precSalesLine."Document Type"::"Credit Memo":
                    BEGIN
                        UpdateLinkedItemCharges(precSalesLine, precSalesLine.FIELDNO("Return Qty. to Receive"));
                        IF precSalesLine."Return Qty. to Receive" <> 0 THEN BEGIN
                            UpdateLinkedItemCharges(precSalesLine, precSalesLine.FIELDNO("Qty. to Invoice"));
                        END;

                    END;
            END;
        END;
    end;

    procedure DeleteExistingChargeLines(precSourceSalesLine: Record "Sales Line")

    var
        lSalesLine: Record "Sales Line";
    begin

        lSalesLine.SETRANGE("Document Type", precSourceSalesLine."Document Type");
        lSalesLine.SETRANGE("Document No.", precSourceSalesLine."Document No.");
        lSalesLine.SETRANGE(Type, lSalesLine.Type::"Charge (Item)");
        lSalesLine.SETFILTER("Quantity Shipped", '=%1', 0);
        lSalesLine.SETRANGE("Attached to Line No.", precSourceSalesLine."Line No.");
        IF (
          (lSalesLine.ISEMPTY)
        ) THEN BEGIN
            EXIT;
        END;
        IF lSalesLine.FINDSET(TRUE) THEN BEGIN
            REPEAT
                IF (lSalesLine."Quantity Shipped" = 0) AND
                   (lSalesLine."Attached to Line No." = precSourceSalesLine."Line No.") THEN BEGIN
                    lSalesLine.SuspendStatusCheck(TRUE);
                    lSalesLine.DELETE(TRUE);
                END;
            UNTIL lSalesLine.NEXT = 0;
        END;

    end;

    procedure AddDeliveryChargeLine(precSourceSalesLine: Record "Sales Line"; poptSurchargeType: Enum "EN Item Charge Type")
    var

        lInventorySetup: Record "Inventory Setup";
        lSalesHeader: Record "Sales Header";
        lSalesLine: Record "Sales Line";
        lShipmentMethod: Record "Shipment Method";
        lDeliveryCharge: Record "Sales Price";
        CalcSalesPrice: Codeunit "EN Sales Price Calc. Mgt.";
        ldecDeliveryCharge: Decimal;
        lSalesLineExisting: Record "Sales Line";
        IsExistingItemChargeLine: Boolean;
    begin

        IF precSourceSalesLine."Document Type" = precSourceSalesLine."Document Type"::"Blanket Order" THEN
            EXIT;

        lInventorySetup.GET;

        lSalesHeader.GET(precSourceSalesLine."Document Type", precSourceSalesLine."Document No.");

        IF lSalesHeader."Shipment Method Code" = '' THEN
            EXIT;

        IF precSourceSalesLine."Sales App Price ELA" THEN
            EXIT;

        IF NOT lShipmentMethod.GET(lSalesHeader."Shipment Method Code") THEN
            EXIT;

        CASE poptSurchargeType OF
            poptSurchargeType::"Delivery Charge":
                BEGIN
                    IF (lShipmentMethod."Delivery Item Charge Code ELA" = '') THEN
                        EXIT;
                END;
            poptSurchargeType::"Delivery Allowance":
                BEGIN
                    IF (lShipmentMethod."Delivery Allowance IC Code ELA" = '') THEN
                        EXIT;
                END;
        END;
        lSalesLine := precSourceSalesLine;  // create local instance of sales line to find pricing

        lSalesLine.SuspendStatusCheck(TRUE);

        //-- Clear out any posted quantities/amounts as this will cause an error when the type field is validated later on
        lSalesLine."Qty. Shipped Not Invoiced" := 0;
        lSalesLine."Shipped Not Invoiced" := 0;
        lSalesLine."Quantity Shipped" := 0;
        lSalesLine."Quantity Invoiced" := 0;
        lSalesLine."Shipped Not Invoiced (LCY)" := 0;
        lSalesLine."Qty. Shipped Not Invd. (Base)" := 0;
        lSalesLine."Qty. Shipped (Base)" := 0;
        lSalesLine."Qty. Invoiced (Base)" := 0;
        lSalesLine."Shipment No." := '';
        lSalesLine."Drop Shipment" := FALSE;
        lSalesLine."Purchase Order No." := '';
        lSalesLine."Purch. Order Line No." := 0;

        IF NOT IsOrderRuleCombo THEN BEGIN
            CalcSalesPrice.FindSalesLinePrice(lSalesHeader, lSalesLine, lSalesLine.FIELDNO("No."));

            CalcSalesPrice.GetDeliveryChargeWithUOM2(lDeliveryCharge, precSourceSalesLine."Unit of Measure Code");   //ES15876OPO

        END ELSE BEGIN
            lDeliveryCharge."Unit Price" := OrderRuleSalesLine."Combination Unit Price";
            lDeliveryCharge."Delivered Unit Price ELA" := OrderRuleSalesLine."Combination Delivered Price";
            lDeliveryCharge."Currency Code" := OrderRuleSalesLine."Currency Code";
        END;

        //<JF30735SHR>
        CASE poptSurchargeType OF
            poptSurchargeType::"Delivery Charge":
                BEGIN
                    IF lDeliveryCharge."Delivered Unit Price ELA" <> 0 THEN BEGIN
                        ldecDeliveryCharge := lDeliveryCharge."Delivered Unit Price ELA" - lDeliveryCharge."Unit Price";
                    END;
                END;
            poptSurchargeType::"Delivery Allowance":
                BEGIN
                    IF lDeliveryCharge."Delivery Allowance ELA" <> 0 THEN BEGIN
                        ldecDeliveryCharge := lDeliveryCharge."Delivery Allowance ELA";
                    END;
                END;
        END;

        IF ldecDeliveryCharge <> 0 THEN BEGIN

            //-- Does line already exist (i.e. shipped)
            IsExistingItemChargeLine := FALSE;

            lSalesLineExisting.SETRANGE("Document Type", precSourceSalesLine."Document Type");
            lSalesLineExisting.SETRANGE("Document No.", precSourceSalesLine."Document No.");
            lSalesLineExisting.SETRANGE("Line No.");
            lSalesLineExisting.SETRANGE(Type, lSalesLineExisting.Type::"Charge (Item)");
            lSalesLineExisting.SETRANGE("Attached to Line No.", precSourceSalesLine."Line No.");

            CASE poptSurchargeType OF
                poptSurchargeType::"Delivery Charge":
                    BEGIN
                        lSalesLineExisting.SETRANGE("No.", lShipmentMethod."Delivery Item Charge Code ELA");
                        lSalesLineExisting.SETRANGE("Item Charge Type ELA", lSalesLineExisting."Item Charge Type ELA"::"Delivery Charge");
                    END;
                poptSurchargeType::"Delivery Allowance":
                    BEGIN
                        lSalesLineExisting.SETRANGE("No.", lShipmentMethod."Delivery Allowance IC Code ELA");
                        lSalesLineExisting.SETRANGE("Item Charge Type ELA", lSalesLineExisting."Item Charge Type ELA"::"Delivery Allowance");
                    END;
            END;
            IsExistingItemChargeLine := lSalesLineExisting.FINDFIRST;

            IF NOT IsExistingItemChargeLine THEN
                lSalesLine := precSourceSalesLine
            ELSE
                lSalesLine.GET(lSalesLineExisting."Document Type",
                                  lSalesLineExisting."Document No.", lSalesLineExisting."Line No.");

            lSalesLine.SuspendStatusCheck(TRUE);

            IF NOT IsExistingItemChargeLine THEN BEGIN
                //-- reset type field to avoid error if document is released
                lSalesLine.Type := lSalesLine.Type::" ";

                //-- Clear out any posted quantities/amounts as this will cause an error when the type field is validated later on
                lSalesLine."Qty. Shipped Not Invoiced" := 0;
                lSalesLine."Shipped Not Invoiced" := 0;
                lSalesLine."Quantity Shipped" := 0;
                lSalesLine."Quantity Invoiced" := 0;
                lSalesLine."Shipped Not Invoiced (LCY)" := 0;
                lSalesLine."Qty. Shipped Not Invd. (Base)" := 0;
                lSalesLine."Qty. Shipped (Base)" := 0;
                lSalesLine."Qty. Invoiced (Base)" := 0;

                lSalesLine."Line No." := GetNextSalesLineNo(precSourceSalesLine);

                lSalesLine.VALIDATE(Type, lSalesLine.Type::"Charge (Item)");

                //<JF30735SHR>
                CASE poptSurchargeType OF
                    poptSurchargeType::"Delivery Charge":
                        BEGIN
                            lSalesLine.VALIDATE("No.", lShipmentMethod."Delivery Item Charge Code ELA");
                            lSalesLine."Item Charge Type ELA" := lSalesLine."Item Charge Type ELA"::"Delivery Charge";
                        END;
                    poptSurchargeType::"Delivery Allowance":
                        BEGIN
                            lSalesLine.VALIDATE("No.", lShipmentMethod."Delivery Allowance IC Code ELA");
                            lSalesLine."Item Charge Type ELA" := lSalesLine."Item Charge Type ELA"::"Delivery Allowance";
                        END;
                END;
                //</JF30735SHR>

                lSalesLine.VALIDATE("Unit of Measure Code", precSourceSalesLine."Unit of Measure Code");

                //-- reset quantity so that it revalidates properly
                lSalesLine.Quantity := 0;

                lSalesLine.VALIDATE(Quantity, precSourceSalesLine.Quantity);

                lSalesLine."Attached to Line No." := precSourceSalesLine."Line No.";

                //<JF30735SHR>
                CASE poptSurchargeType OF
                    poptSurchargeType::"Delivery Charge":
                        BEGIN
                            lSalesLine."Include IC in Unit Price ELA" := lShipmentMethod."Include DC in Unit Price ELA";
                            lSalesLine."Allow Invoice Disc." := lDeliveryCharge."Dlvry. Chg. Allow InvDisc ELA";
                        END;
                    poptSurchargeType::"Delivery Allowance":
                        BEGIN
                            lSalesLine."Include IC in Unit Price ELA" := lShipmentMethod."Include DA in Unit Price ELA";
                            lSalesLine."Allow Invoice Disc." := lDeliveryCharge."Dlvry. Allw. Allow InvDisc ELA";
                        END;
                END;
                IF lSalesLine.CheckItemChgInherit(lSalesLine."No.") THEN BEGIN
                    lSalesLine."Shortcut Dimension 1 Code" := '';
                    lSalesLine."Shortcut Dimension 2 Code" := '';
                END;
                //</JF00037MG>
            END ELSE BEGIN
                lSalesLine."Line No." := lSalesLineExisting."Line No.";
            END;

            IF lDeliveryCharge."Currency Code" = precSourceSalesLine."Currency Code" THEN BEGIN
                lSalesLine.VALIDATE("Unit Price", ldecDeliveryCharge)
            END ELSE BEGIN
                lSalesLine.VALIDATE("Unit Price",
                  ConvertChargeCurrency(lSalesLine, lDeliveryCharge."Currency Code", (ldecDeliveryCharge)));
                //(lrecDeliveryCharge."Delivered Unit Price" - lrecDeliveryCharge."Unit Price")));
            END;

            IF precSourceSalesLine."Outstanding Quantity" = 0 THEN BEGIN
                //-- the item line has completely been shipped so we need to set the item charge to fully ship/invoice
                IF lSalesLine."Document Type" IN [lSalesLine."Document Type"::"Credit Memo",
                                                     lSalesLine."Document Type"::"Return Order"] THEN
                    lSalesLine.VALIDATE("Return Qty. to Receive", lSalesLine.Quantity - lSalesLine."Return Qty. Received")
                ELSE
                    lSalesLine.VALIDATE("Qty. to Ship", lSalesLine.Quantity - lSalesLine."Quantity Shipped");

                lSalesLine.VALIDATE("Qty. to Invoice", lSalesLine.Quantity - lSalesLine."Quantity Invoiced");
            END ELSE BEGIN
                IF lSalesLine."Document Type" IN [lSalesLine."Document Type"::"Credit Memo",
                                                     lSalesLine."Document Type"::"Return Order"] THEN
                    lSalesLine.VALIDATE("Return Qty. to Receive", lSalesLine."Outstanding Quantity")
                ELSE
                    lSalesLine.VALIDATE("Qty. to Ship", lSalesLine."Outstanding Quantity");

                lSalesLine.VALIDATE("Qty. to Invoice", lSalesLine."Outstanding Quantity");
            END;

            lSalesLine."Requested Order Qty. ELA" := precSourceSalesLine."Requested Order Qty. ELA";
            lSalesLine.VALIDATE("Location Code", precSourceSalesLine."Location Code");
            IF NOT IsExistingItemChargeLine THEN BEGIN
                IF lSalesLine.CheckItemChgInherit(lSalesLine."No.") THEN BEGIN

                    lSalesLine."Dimension Set ID" := 0;
                    lSalesLine."Shortcut Dimension 1 Code" := '';
                    lSalesLine."Shortcut Dimension 2 Code" := '';
                    lSalesLine."Dimension Set ID" := precSourceSalesLine."Dimension Set ID";

                    DimMgt.UpdateGlobalDimFromDimSetID(
                      lSalesLine."Dimension Set ID", lSalesLine."Shortcut Dimension 1 Code", lSalesLine."Shortcut Dimension 2 Code");
                END;

                lSalesLine.INSERT;

                CreateRelatedChargeRecords(precSourceSalesLine, lSalesLine);
            END ELSE BEGIN
                lSalesLine.MODIFY;
                ModifyRelatedChargeRecords(precSourceSalesLine, lSalesLine);
            END;
        END;
    end;

    procedure UpdateLinkedItemCharges(precSalesLine: Record "Sales Line"; pintFieldNo: Integer)
    var
        lInventorySetup: Record "Inventory Setup";
        lSalesLine: Record "Sales Line";
        lItemUOM: Record "Item Unit of Measure";
        lText0001: Label 'Item %1 must have %2 defined in the %3 table.';
    begin

        IF precSalesLine."Line No." = 0 THEN
            EXIT;

        lInventorySetup.GET;

        lSalesLine.SETRANGE("Document Type", precSalesLine."Document Type");
        lSalesLine.SETRANGE("Document No.", precSalesLine."Document No.");
        IF lSalesLine.FINDSET THEN BEGIN
            REPEAT
                IF (lSalesLine.Quantity <> 0) AND
                   (lSalesLine."Attached to Line No." = precSalesLine."Line No.") THEN BEGIN
                    lSalesLine.SuspendStatusCheck(TRUE);
                    CASE lSalesLine."Item Charge Type ELA" OF
                        lSalesLine."Item Charge Type ELA"::"Delivery Charge",
                        lSalesLine."Item Charge Type ELA"::"Delivery Allowance":
                            BEGIN
                                IF NOT lItemUOM.GET(precSalesLine."No.", lSalesLine."Unit of Measure Code") THEN
                                    ERROR(lText0001, precSalesLine."No.", lSalesLine."Unit of Measure Code", lItemUOM.TABLENAME);

                                IF (ROUND(precSalesLine."Quantity (Base)" /
                                          precSalesLine."Qty. per Unit of Measure", 0.00001) <> lSalesLine.Quantity) THEN BEGIN
                                    lSalesLine.VALIDATE(Quantity, ROUND(precSalesLine."Quantity (Base)" /
                                        precSalesLine."Qty. per Unit of Measure", 0.00001));
                                END;
                                lSalesLine."Requested Order Qty. ELA" := precSalesLine."Requested Order Qty. ELA";

                                CASE pintFieldNo OF
                                    lSalesLine.FIELDNO("Qty. to Ship"):
                                        BEGIN
                                            lSalesLine.VALIDATE("Qty. to Ship", precSalesLine."Qty. to Ship");
                                            lSalesLine.MODIFY;
                                        END;
                                    lSalesLine.FIELDNO("Qty. to Invoice"):
                                        BEGIN
                                            IF ((lSalesLine."Document Type" IN [lSalesLine."Document Type"::"Return Order"]) AND
                                             (lSalesLine."Return Qty. to Receive" <> 0)) OR
                                             ((lSalesLine."Document Type" IN [lSalesLine."Document Type"::Order]) AND
                                             (lSalesLine."Qty. to Ship" <> 0)) OR
                                             (lSalesLine."Document Type" IN [lSalesLine."Document Type"::Invoice,
                                                                          lSalesLine."Document Type"::"Credit Memo"])
                                              THEN BEGIN
                                                lSalesLine.VALIDATE("Qty. to Invoice", precSalesLine."Qty. to Invoice");

                                                lSalesLine.MODIFY;
                                                UpdateItremChgAssignments(lSalesLine);
                                            END ELSE BEGIN
                                                lSalesLine.InitQtyToInvoice;
                                                lSalesLine.MODIFY;
                                                UpdateItremChgAssignments(lSalesLine);
                                            END;
                                        END;
                                END;
                            end;
                    end;
                end;
            until lSalesLine.Next() = 0;
        end;
    end;

    procedure UpdateItremChgAssignments(precSalesLine: Record "Sales Line")
    var
        lItemChgAssignment: Record "Item Charge Assignment (Sales)";
    begin

        lItemChgAssignment.SETRANGE("Document Type", precSalesLine."Document Type");
        lItemChgAssignment.SETRANGE("Document No.", precSalesLine."Document No.");
        lItemChgAssignment.SETRANGE("Document Line No.", precSalesLine."Line No.");

        IF lItemChgAssignment.FINDFIRST THEN BEGIN
            lItemChgAssignment."Qty. to Assign" := precSalesLine."Qty. to Invoice";
            lItemChgAssignment.VALIDATE("Amount to Assign");
            lItemChgAssignment.MODIFY;
        END;
    end;

    procedure PriceFromOrderRuleCombo(pblnOrderRuleCombo: Boolean; precOrderRuleSalesLine: Record "EN Order Rule Sales Line")
    begin

        IsOrderRuleCombo := pblnOrderRuleCombo;
        OrderRuleSalesLine := precOrderRuleSalesLine;
    end;

    procedure ModifyRelatedChargeRecords(precSourceSalesLine: Record "Sales Line"; precNewSalesLine: Record "Sales Line")
    var
        lSalesICAssign: Record "Item Charge Assignment (Sales)";
    begin

        //------------------------------------------
        // Update Item Charge Assigments
        //------------------------------------------
        lSalesICAssign.SETRANGE("Document Type", precNewSalesLine."Document Type");
        lSalesICAssign.SETRANGE("Document No.", precNewSalesLine."Document No.");
        lSalesICAssign.SETRANGE("Document Line No.", precNewSalesLine."Line No.");
        lSalesICAssign.SETRANGE("Line No.");

        IF lSalesICAssign.FINDFIRST THEN BEGIN
            lSalesICAssign."Unit Cost" := precNewSalesLine."Unit Price";
            lSalesICAssign.VALIDATE("Qty. to Assign", precNewSalesLine.Quantity - lSalesICAssign."Qty. Assigned");
            lSalesICAssign.MODIFY;
        END;
    end;

    procedure CreateRelatedChargeRecords(precSourceSalesLine: Record "Sales Line"; precNewSalesLine: Record "Sales Line")
    var
        lSalesICAssign: Record "Item Charge Assignment (Sales)";
    begin

        SalesHeader.GET(precSourceSalesLine."Document Type", precSourceSalesLine."Document No.");

        //------------------------------------------
        // Insert Item Charge Assigments
        //------------------------------------------
        lSalesICAssign."Document Type" := precNewSalesLine."Document Type";
        lSalesICAssign."Document No." := precNewSalesLine."Document No.";
        lSalesICAssign."Document Line No." := precNewSalesLine."Line No.";
        lSalesICAssign."Line No." := 10000;
        lSalesICAssign."Item Charge No." := precNewSalesLine."No.";
        lSalesICAssign."Item No." := precSourceSalesLine."No.";
        lSalesICAssign.Description := precSourceSalesLine.Description;
        lSalesICAssign."Qty. to Assign" := precNewSalesLine.Quantity;

        IF (precNewSalesLine."Inv. Discount Amount" = 0) AND (precNewSalesLine."Line Discount Amount" = 0) AND
           (NOT SalesHeader."Prices Including VAT") THEN BEGIN
            lSalesICAssign."Unit Cost" := precNewSalesLine."Unit Price";
        END ELSE BEGIN
            IF SalesHeader."Prices Including VAT" THEN BEGIN
                lSalesICAssign."Unit Cost" :=
                  ROUND(
                    (precNewSalesLine."Line Amount" - precNewSalesLine."Inv. Discount Amount") /
                     precNewSalesLine.Quantity / (1 + precNewSalesLine."VAT %" / 100), 0.00001);
            END ELSE BEGIN
                lSalesICAssign."Unit Cost" :=
                  ROUND((precNewSalesLine."Line Amount" - precNewSalesLine."Inv. Discount Amount") /
                    precNewSalesLine.Quantity, 0.00001);
            END;
        END;

        lSalesICAssign."Amount to Assign" := precNewSalesLine."Line Amount" -
          (precNewSalesLine."Line Discount Amount" + precNewSalesLine."Inv. Discount Amount");

        lSalesICAssign."Applies-to Doc. Type" := precSourceSalesLine."Document Type";
        lSalesICAssign."Applies-to Doc. No." := precSourceSalesLine."Document No.";
        lSalesICAssign."Applies-to Doc. Line No." := precSourceSalesLine."Line No.";

        lSalesICAssign."Applies-to Doc. Line Amount" := precSourceSalesLine."Line Amount" -
          (precSourceSalesLine."Line Discount Amount" + precSourceSalesLine."Inv. Discount Amount");

        lSalesICAssign.INSERT;
    end;

    procedure GetNextSalesLineNo(precSourceSalesLine: Record "Sales Line"): Integer
    var
        lLineCounter: Integer;
        lSalesLine: Record "Sales Line";
    begin

        lLineCounter := precSourceSalesLine."Line No.";

        WHILE lSalesLine.GET(precSourceSalesLine."Document Type", precSourceSalesLine."Document No.", lLineCounter) DO BEGIN
            lLineCounter += 10;
        END;

        //IF Source line is not yet inserted in the database.
        IF lLineCounter = precSourceSalesLine."Line No." THEN BEGIN
            lLineCounter += 10;
            WHILE lSalesLine.GET(precSourceSalesLine."Document Type", precSourceSalesLine."Document No.", lLineCounter) DO BEGIN
                lLineCounter += 10;
            END;
        END;
        EXIT(lLineCounter);
    end;

    procedure ConvertChargeCurrency(precSalesLine: Record "Sales Line"; pcodCurrency: Code[10]; pdecAmount: Decimal): Decimal
    var
        lSalesHeader: Record "Sales Header";
        lCurrency: Record Currency;
        lCurrencyExch: Record "Currency Exchange Rate";
        lGLSetup: Record "General Ledger Setup";
    begin

        IF precSalesLine."Currency Code" <> '' THEN BEGIN
            lSalesHeader.GET(precSalesLine."Document Type", precSalesLine."Document No.");
            lCurrency.GET(lSalesHeader."Currency Code");
            EXIT(
              ROUND(lCurrencyExch.ExchangeAmtLCYToFCY(
                lSalesHeader."Posting Date",
                lSalesHeader."Currency Code",
                pdecAmount,
                lSalesHeader."Currency Factor"), lCurrency."Unit-Amount Rounding Precision"));
        END ELSE BEGIN
            lGLSetup.GET;
            EXIT(
              ROUND(lCurrencyExch.ExchangeAmtFCYToLCY(
                lSalesHeader."Posting Date",
                pcodCurrency,
                pdecAmount,
                lSalesHeader."Currency Factor"), lGLSetup."Unit-Amount Rounding Precision"));
        END;
    end;

    procedure CalcDeliveredPrice(pintSourceType: Integer; pintSourceSubType: Integer; pintSourceNo: Code[20]; pintSourceRefNo: Integer; pdecBasePrice: Decimal): Decimal
    var
        ldecResult: Decimal;
        lrecSalesLine: Record "Sales Line";
        lrecSalesInvLine: Record "Sales Invoice Line";
        lrecSalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin

        ldecResult := pdecBasePrice;

        CASE pintSourceType OF
            DATABASE::"Sales Line":
                BEGIN
                    IF lrecSalesLine.GET(pintSourceSubType, pintSourceNo, pintSourceRefNo) THEN BEGIN
                        IF lrecSalesLine.Type <> lrecSalesLine.Type::Item THEN
                            EXIT(ldecResult);
                    END;

                    ldecResult := pdecBasePrice;

                    lrecSalesLine.SETRANGE("Document Type", pintSourceSubType);
                    lrecSalesLine.SETRANGE("Document No.", pintSourceNo);
                    lrecSalesLine.SETRANGE("Line No.");
                    lrecSalesLine.SETRANGE("Attached to Line No.", pintSourceRefNo);
                    lrecSalesLine.SETFILTER("Item Charge Type ELA", '%1|%2',
                                            lrecSalesLine."Item Charge Type ELA"::"Delivery Charge",
                                            lrecSalesLine."Item Charge Type ELA"::"Delivery Allowance");

                    //-- Don't want to create a key just for this. Just loop through and add up amounts since there will only be few records
                    IF lrecSalesLine.FINDSET THEN BEGIN
                        REPEAT
                            ldecResult += lrecSalesLine."Unit Price";
                        UNTIL lrecSalesLine.NEXT = 0;
                    END;
                END;
            DATABASE::"Sales Invoice Line":
                BEGIN
                    IF lrecSalesInvLine.GET(pintSourceNo, pintSourceRefNo) THEN BEGIN
                        IF lrecSalesInvLine.Type <> lrecSalesInvLine.Type::Item THEN
                            EXIT(ldecResult);
                    END;

                    ldecResult := pdecBasePrice;

                    lrecSalesInvLine.SETRANGE("Document No.", pintSourceNo);
                    lrecSalesInvLine.SETRANGE("Line No.");
                    lrecSalesInvLine.SETRANGE("Attached to Line No.", pintSourceRefNo);
                    lrecSalesInvLine.SETFILTER("Item Charge Type ELA", '%1|%2',
                                               lrecSalesInvLine."Item Charge Type ELA"::"Delivery Charge",
                                               lrecSalesInvLine."Item Charge Type ELA"::"Delivery Allowance");

                    //-- Don't want to create a key just for this. Just loop through and add up amounts since there will only be few records
                    IF lrecSalesInvLine.FINDSET THEN BEGIN
                        REPEAT
                            ldecResult += lrecSalesInvLine."Unit Price";
                        UNTIL lrecSalesInvLine.NEXT = 0;
                    END;
                END;
            DATABASE::"Sales Cr.Memo Line":
                BEGIN
                    IF lrecSalesCrMemoLine.GET(pintSourceNo, pintSourceRefNo) THEN BEGIN
                        IF lrecSalesCrMemoLine.Type <> lrecSalesCrMemoLine.Type::Item THEN
                            EXIT(ldecResult);
                    END;

                    ldecResult := pdecBasePrice;

                    lrecSalesCrMemoLine.SETRANGE("Document No.", pintSourceNo);
                    lrecSalesCrMemoLine.SETRANGE("Line No.");
                    lrecSalesCrMemoLine.SETRANGE("Attached to Line No.", pintSourceRefNo);
                    lrecSalesCrMemoLine.SETFILTER("Item Charge Type ELA", '%1|%2',
                                                  lrecSalesCrMemoLine."Item Charge Type ELA"::"Delivery Charge",
                                                  lrecSalesCrMemoLine."Item Charge Type ELA"::"Delivery Allowance");

                    //-- Don't want to create a key just for this. Just loop through and add up amounts since there will only be few records
                    IF lrecSalesCrMemoLine.FINDSET THEN BEGIN
                        REPEAT
                            ldecResult += lrecSalesCrMemoLine."Unit Price";
                        UNTIL lrecSalesCrMemoLine.NEXT = 0;
                    END;
                END;
        END;

        EXIT(ldecResult);
    end;
}
