codeunit 14228832 "FN Backorder Tolerance ELA"
{
    trigger OnRun()
    begin

    end;

    procedure jfCheckSalesBackorder(VAR precSalesHeader: Record "Sales Header")
    var
        lrecCustomer: Record Customer;
        lrecShipTo: Record "Ship-to Address";
        lrecSalesLine: Record "Sales Line";
        ldecTolerance: Decimal;
        lblnFoundTolerance: Boolean;
        lblnUpdatedLine: Boolean;
    begin
        WITH precSalesHeader DO BEGIN
            IF "Document Type" = "Document Type"::Order THEN BEGIN
                IF Ship THEN BEGIN

                    IF precSalesHeader."Prepayment %" <> 0 THEN
                        EXIT;


                    //-- check if Item lines are within backorder tolerance
                    ldecTolerance := 0;
                    lblnFoundTolerance := FALSE;

                    IF "Ship-to Code" <> '' THEN BEGIN
                        lrecShipTo.GET("Sell-to Customer No.", "Ship-to Code");

                        IF lrecShipTo."Use Backorder Tolerance ELA" THEN BEGIN
                            lblnFoundTolerance := TRUE;
                            //ldecTolerance := lrecShipTo."Backorder Tolerance %"; //<JF12270DT>
                        END;
                    END;

                    IF NOT lblnFoundTolerance THEN BEGIN
                        lrecCustomer.GET("Sell-to Customer No.");

                        IF lrecCustomer."Use Backorder Tolerance ELA" THEN BEGIN
                            lblnFoundTolerance := TRUE;
                            //ldecTolerance := lrecCustomer."Backorder Tolerance %"; //<JF12270DT>
                        END;
                    END;

                    IF lblnFoundTolerance THEN BEGIN
                        lrecSalesLine.SETRANGE("Document Type", "Document Type");
                        lrecSalesLine.SETRANGE("Document No.", "No.");
                        lrecSalesLine.SETRANGE("Line No.");
                        lrecSalesLine.SETRANGE(Type, lrecSalesLine.Type::Item);

                        IF lrecSalesLine.FINDSET(TRUE) THEN BEGIN
                            REPEAT
                                ldecTolerance := lrecSalesLine."Backorder Tolerance %"; //<JF12270DT>
                                IF jfCheckSalesLineTolerance(lrecSalesLine, ldecTolerance) THEN
                                    lblnUpdatedLine := TRUE;
                            UNTIL lrecSalesLine.NEXT = 0;
                        END;
                    END;
                END;
            END;
        END;

        //-- Update document item charges if any line quantities were updated
        IF lblnUpdatedLine THEN
            gcduCalcSurcharges.jfAddOrderSurcharges(precSalesHeader, TRUE);
    end;

    procedure jfCheckSalesLineTolerance(VAR precSalesLine: Record "Sales Line"; pdecTolerance: Decimal): Boolean
    var
        ldecQtyToShip: Decimal;
    begin
        WITH precSalesLine DO BEGIN

            IF "Qty. to Ship" + "Quantity Shipped" >= Quantity THEN
                EXIT(FALSE);

            IF ROUND((1 - ("Qty. to Ship" + "Quantity Shipped") / Quantity) * 100, 0.00001) <= pdecTolerance THEN BEGIN
                SuspendStatusCheck(TRUE);
                jfSuspendPriceCalc(TRUE);

                //-- Remove any "extra" item tracking that may already be set up for the sales line
                jfAdjustSalesLineItemTracking(precSalesLine, "Qty. to Ship (Base)" + "Qty. Shipped (Base)");

                ldecQtyToShip := "Qty. to Ship";

                VALIDATE(Quantity, "Qty. to Ship" + "Quantity Shipped");
                VALIDATE("Qty. to Ship", ldecQtyToShip);

                MODIFY;

                EXIT(TRUE);
            END;
        END;

        EXIT(FALSE);
    end;


    procedure jfAdjustSalesLineItemTracking(precSalesLine: Record "Sales Line"; pdecNewQtyBase: Decimal)
    var
        ldecPct: Decimal;
        lblnItemTracking: Boolean;
        lrecReservEntry: Record "Reservation Entry";
        lrecReservEntry2: Record "Reservation Entry";
        ldecQtyToRemove: Decimal;
    begin
        ldecPct := ROUND(precSalesLine.doTrackingExistsELA(pdecNewQtyBase, lblnItemTracking));

        IF lblnItemTracking THEN BEGIN
            IF ldecPct > 100 THEN BEGIN
                //-- Remove extra reservation entries
                lrecReservEntry.SETCURRENTKEY("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
                                              "Source Ref. No.", "Expiration Date", "Lot No.", "Serial No.");

                //-- Loop through from newest lot down to oldest lot
                lrecReservEntry.ASCENDING(FALSE);

                lrecReservEntry.SETRANGE("Source Type", DATABASE::"Sales Line");
                lrecReservEntry.SETRANGE("Source Subtype", precSalesLine."Document Type");
                lrecReservEntry.SETRANGE("Source ID", precSalesLine."Document No.");
                lrecReservEntry.SETRANGE("Source Batch Name");
                lrecReservEntry.SETRANGE("Source Ref. No.", precSalesLine."Line No.");
                lrecReservEntry.SETRANGE("Expiration Date");
                lrecReservEntry.SETRANGE("Lot No.");
                lrecReservEntry.SETRANGE("Serial No.");

                IF lrecReservEntry.FIND('-') THEN BEGIN
                    lrecReservEntry.CALCSUMS("Quantity (Base)");
                    ldecQtyToRemove := ABS(lrecReservEntry."Quantity (Base)") - pdecNewQtyBase;

                    REPEAT
                        IF ABS(lrecReservEntry."Quantity (Base)") <= ldecQtyToRemove THEN BEGIN
                            //-- Delete the reservation entry
                            ldecQtyToRemove -= ABS(lrecReservEntry."Quantity (Base)");

                            lrecReservEntry2.GET(lrecReservEntry."Entry No.", lrecReservEntry.Positive);
                            lrecReservEntry2.DELETE(TRUE);
                        END ELSE BEGIN
                            //-- Remove quantity from the reservation entry
                            lrecReservEntry2.GET(lrecReservEntry."Entry No.", lrecReservEntry.Positive);

                            IF lrecReservEntry2.Positive THEN
                                lrecReservEntry2.VALIDATE("Quantity (Base)", lrecReservEntry2."Quantity (Base)" - ldecQtyToRemove)
                            ELSE
                                lrecReservEntry2.VALIDATE("Quantity (Base)", lrecReservEntry2."Quantity (Base)" + ldecQtyToRemove);

                            lrecReservEntry2.MODIFY;
                            ldecQtyToRemove := 0;
                        END;
                    UNTIL (lrecReservEntry.NEXT = 0) OR (ldecQtyToRemove = 0);
                END;
            END ELSE
                IF ldecPct = 0 THEN BEGIN
                    //-- Remove all entries against the line
                    lrecReservEntry.SETCURRENTKEY("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
                                                  "Source Ref. No.", "Expiration Date", "Lot No.", "Serial No.");

                    lrecReservEntry.SETRANGE("Source Type", DATABASE::"Sales Line");
                    lrecReservEntry.SETRANGE("Source Subtype", precSalesLine."Document Type");
                    lrecReservEntry.SETRANGE("Source ID", precSalesLine."Document No.");
                    lrecReservEntry.SETRANGE("Source Batch Name");
                    lrecReservEntry.SETRANGE("Source Ref. No.", precSalesLine."Line No.");
                    lrecReservEntry.SETRANGE("Expiration Date");
                    lrecReservEntry.SETRANGE("Lot No.");
                    lrecReservEntry.SETRANGE("Serial No.");

                    lrecReservEntry.DELETEALL;
                END;
        END;
    end;

    procedure jfAddOrderSurcharges(precSalesHeader: Record "Sales Header"; pblnIncludeDocLevelSurcharges: Boolean)
    var
        lrecSalesLine: Record "Sales Line";
        lrecSalesLine2: Record "Sales Line";
        lrecCustItemSurcharge: Record "Customer Item Surcharge";
    begin
        IF precSalesHeader."Document Type" = precSalesHeader."Document Type"::"Blanket Order" THEN
            EXIT;

        // IF precSalesHeader."Bypass Surcharge Calculation" THEN
        //     EXIT;

        lrecSalesLine.SETRANGE("Document Type", precSalesHeader."Document Type");
        lrecSalesLine.SETRANGE("Document No.", precSalesHeader."No.");
        lrecSalesLine.SETRANGE(Type, lrecSalesLine.Type::Item);
        IF lrecSalesLine.ISEMPTY THEN
            EXIT;

        IF lrecSalesLine.FINDSET THEN
            REPEAT
                IF (lrecSalesLine.Quantity > lrecSalesLine."Quantity Shipped") AND
                   (lrecSalesLine."Allow Item Charge Assignment") THEN BEGIN
                    IF NOT lrecSalesLine."Lock Pricing ELA" THEN
                        jfProcessSalesLineSurcharges(lrecSalesLine);
                END;

            UNTIL lrecSalesLine.NEXT = 0;

        //-- Document Surcharges/Allowances
        jfAddDocCharges(precSalesHeader, pblnIncludeDocLevelSurcharges);
    end;

    procedure jfProcessSalesLineSurcharges(precSalesLine: Record "Sales Line")
    var
        lrecSalesHeader: Record "Sales Header";
        lrecSalesLine: Record "Sales Line";
    begin
        IF precSalesLine."Document Type" = precSalesLine."Document Type"::"Blanket Order" THEN
            EXIT;

        lrecSalesHeader.GET(precSalesLine."Document Type", precSalesLine."Document No.");

        // IF lrecSalesHeader."Bypass Surcharge Calculation" THEN
        //     EXIT;

        jfDeleteExistingChargeLines(precSalesLine);

        IF precSalesLine.Quantity <> 0 THEN BEGIN

            jfAddDeliveryChargeLine(precSalesLine, 0);
            jfAddDeliveryChargeLine(precSalesLine, 1);

            jfAddItemChargeLines(precSalesLine, 1);
            jfAddItemChargeLines(precSalesLine, 0);

            CASE precSalesLine."Document Type" OF
                precSalesLine."Document Type"::Order, precSalesLine."Document Type"::Invoice:
                    BEGIN
                        jfUpdateLinkedItemCharges(precSalesLine, precSalesLine.FIELDNO("Qty. to Ship"));
                        IF precSalesLine."Qty. to Ship" <> 0 THEN BEGIN
                            jfUpdateLinkedItemCharges(precSalesLine, precSalesLine.FIELDNO("Qty. to Invoice"));
                        END;
                    END;
                precSalesLine."Document Type"::"Return Order", precSalesLine."Document Type"::"Credit Memo":
                    BEGIN
                        jfUpdateLinkedItemCharges(precSalesLine, precSalesLine.FIELDNO("Return Qty. to Receive"));
                        IF precSalesLine."Return Qty. to Receive" <> 0 THEN BEGIN
                            jfUpdateLinkedItemCharges(precSalesLine, precSalesLine.FIELDNO("Qty. to Invoice"));
                        END;

                    END;
            END;
        END;
    end;

    procedure jfDeleteExistingChargeLines(precSourceSalesLine: Record "Sales Line")
    var
        lrecSalesLine: Record "Sales Line";
    begin
        lrecSalesLine.SETRANGE("Document Type", precSourceSalesLine."Document Type");
        lrecSalesLine.SETRANGE("Document No.", precSourceSalesLine."Document No.");
        lrecSalesLine.SETRANGE(Type, lrecSalesLine.Type::"Charge (Item)");
        lrecSalesLine.SETFILTER("Quantity Shipped", '=%1', 0);
        lrecSalesLine.SETRANGE("Attached to Line No.", precSourceSalesLine."Line No.");
        IF (
          (lrecSalesLine.ISEMPTY)
        ) THEN BEGIN
            EXIT;
        END;

        IF lrecSalesLine.FINDSET(TRUE) THEN BEGIN
            REPEAT
                IF (lrecSalesLine."Quantity Shipped" = 0) AND
                   (lrecSalesLine."Attached to Line No." = precSourceSalesLine."Line No.") THEN BEGIN
                    lrecSalesLine.SuspendStatusCheck(TRUE);
                    lrecSalesLine.DELETE(TRUE);
                END;
            UNTIL lrecSalesLine.NEXT = 0;
        END;
    end;

    procedure jfAddItemChargeLines(precSourceSalesLine: Record "Sales Line"; poptSurchargeType: 'Surcharge,Allowance')
    var
        lrecItem: Record Item;
        lrecCustomer: Record Customer;
        lrecCustItemSurcharge: Record "Customer Item Surcharge";
        lrecCustItemSurcharge2: Record "Customer Item Surcharge";
        lrecTempCustItemSurcharge: Record "Customer Item Surcharge";
        lrecSalesLine: Record "Sales Line";
        lrecSalesLineExisting: Record "Sales Line";
        lrecSalesICAssign: Record "Item Charge Assignment (Sales)";
        lrecInventorySetup: Record "Inventory Setup";
        lrecUOM: Record "Unit of Measure";
        lrecUOM2: Record "Unit of Measure";
        lrecUOMSourceLine: Record "Unit of Measure";
        lrecItemUOM: Record "Item Unit of Measure";
        lrecSalesHeader: Record "Sales Header";
        lrecItemChgAssignment: Record "Item Charge Assignment (Sales)";
        lcduUOMConst: Codeunit "UOM Constants Mgmt.";
        lcodPreviousCharge: Code[20];
        lblnSkipCurrRecord: Boolean;
        lblnExistingItemChargeLine: Boolean;
    begin
        IF precSourceSalesLine."Document Type" = precSourceSalesLine."Document Type"::"Blanket Order" THEN
            EXIT;

        //<JF7910SHR>
        IF precSourceSalesLine."Sell-to Customer No." = '' THEN
            EXIT;
        //</JF7910SHR>

        lrecCustomer.GET(precSourceSalesLine."Sell-to Customer No.");
        lrecItem.GET(precSourceSalesLine."No.");
        lrecSalesHeader.GET(precSourceSalesLine."Document Type", precSourceSalesLine."Document No.");
        lrecInventorySetup.GET;

        //<JF10860SHR>
        lrecCustItemSurcharge.SETCURRENTKEY("Delivery Zone Code", "Item Container Type",
          "Surcharge Type", "Surcharge Code", "Sales Type", "Sales Code", "Ship-To Code",
          "Item Type", "Item No.", "Starting Date", "Currency Code", "Variant Code", "Minimum Quantity");
        //</JF10860SHR>


        lrecCustItemSurcharge.SETRANGE("Sales Type");
        //<JF5786SHR>
        lrecCustItemSurcharge.SETFILTER("Sales Code", '%1|%2|%3|%4',
          lrecCustomer."No.",
          precSourceSalesLine."Customer Price Group",
          lrecSalesHeader."Campaign No.", '');
        //</JF5786SHR>

        lrecCustItemSurcharge.SETFILTER("Ship-To Code", '%1|%2', lrecSalesHeader."Ship-to Code", '');
        lrecCustItemSurcharge.SETFILTER("Item No.", '%1|%2|%3', lrecItem."No.", lrecItem."Item Category Code", '');

        //<JF00116SHR>
        CASE lrecCustomer."Sales Price/Sur. Date Control" OF
            lrecCustomer."Sales Price/Sur. Date Control"::"Order Date":
                BEGIN
                    lrecCustItemSurcharge.SETFILTER("Starting Date", '..%1', lrecSalesHeader."Order Date");
                END;
            lrecCustomer."Sales Price/Sur. Date Control"::"Shipment Date":
                BEGIN
                    lrecCustItemSurcharge.SETFILTER("Starting Date", '..%1', precSourceSalesLine."Shipment Date");
                END;
            lrecCustomer."Sales Price/Sur. Date Control"::"Req. Delivery Date":
                BEGIN
                    IF lrecSalesLine."Requested Delivery Date" <> 0D THEN BEGIN
                        lrecCustItemSurcharge.SETFILTER("Starting Date", '..%1', precSourceSalesLine."Requested Delivery Date");
                    END ELSE BEGIN
                        lrecCustItemSurcharge.SETFILTER("Starting Date", '..%1', precSourceSalesLine."Planned Delivery Date");
                    END;
                END;
        END;
        //<JF00116SHR>

        lrecCustItemSurcharge.SETFILTER("Currency Code", '%1|%2', precSourceSalesLine."Currency Code", '');
        lrecCustItemSurcharge.SETFILTER("Variant Code", '%1|%2', precSourceSalesLine."Variant Code", '');
        lrecCustItemSurcharge.SETRANGE("Minimum Quantity", 0, precSourceSalesLine.Quantity);
        //<JF3694SHR>
        CASE lrecCustomer."Sales Price/Sur. Date Control" OF
            lrecCustomer."Sales Price/Sur. Date Control"::"Order Date":
                BEGIN
                    lrecCustItemSurcharge.SETFILTER("End Date", '%1|>=%2', 0D, lrecSalesHeader."Order Date");
                END;
            lrecCustomer."Sales Price/Sur. Date Control"::"Shipment Date":
                BEGIN
                    lrecCustItemSurcharge.SETFILTER("End Date", '%1|>=%2', 0D, precSourceSalesLine."Shipment Date");
                END;
            lrecCustomer."Sales Price/Sur. Date Control"::"Req. Delivery Date":
                BEGIN
                    IF lrecSalesLine."Requested Delivery Date" <> 0D THEN BEGIN
                        lrecCustItemSurcharge.SETFILTER("End Date", '%1|>=%2', 0D, precSourceSalesLine."Requested Delivery Date");
                    END ELSE BEGIN
                        lrecCustItemSurcharge.SETFILTER("End Date", '%1|>=%2', 0D, precSourceSalesLine."Planned Delivery Date");
                    END;
                END;
        END;
        //<JF3694SHR>

        //<JF10860SHR>
        lrecCustItemSurcharge.SETFILTER("Delivery Zone Code", '%1|%2', lrecSalesHeader."Delivery Zone Code", '');
        lrecCustItemSurcharge.SETFILTER("Item Container Type", '%1|%2', precSourceSalesLine."Item Container Type", '');
        //</JF10860SHR>

        lrecCustItemSurcharge.SETFILTER("Surcharge UOM", '%1|%2|%3',
          precSourceSalesLine."Unit of Measure Code", '', lrecInventorySetup."Standard Weight UOM");

        //<JF30735SHR>
        CASE poptSurchargeType OF
            poptSurchargeType::Surcharge:
                BEGIN
                    lrecCustItemSurcharge.SETRANGE("Surcharge Type", lrecCustItemSurcharge."Surcharge Type"::Surcharge);
                END;
            poptSurchargeType::Allowance:
                BEGIN
                    lrecCustItemSurcharge.SETRANGE("Surcharge Type", lrecCustItemSurcharge."Surcharge Type"::Allowance);
                END;
        END;
        //</JF30735SHR>


        //Use uom group here to figure out if there is a surcharge that doesn't belong to std. weight, etc...
        IF lrecCustItemSurcharge.ISEMPTY THEN
            lrecCustItemSurcharge.SETRANGE("Surcharge UOM");

        jmGetSalesSetup;

        IF lrecCustItemSurcharge.FIND('+') THEN BEGIN
            REPEAT
                IF lrecCustItemSurcharge."Surcharge Code" <> lcodPreviousCharge THEN BEGIN
                    //-- If blank ship-to and for a specific customer, look for same surcharge code with a ship-to defined
                    //--  If we find one use the one with the ship-to as it overrides the blank one
                    lblnSkipCurrRecord := FALSE;

                    IF grecSalesSetup."Ship-to Surcharge Filter" = grecSalesSetup."Ship-to Surcharge Filter"::"All Surcharges" THEN BEGIN
                        IF (lrecCustItemSurcharge."Ship-To Code" = '') AND
                           (lrecSalesHeader."Ship-to Code" <> '') THEN BEGIN
                            lrecCustItemSurcharge2.COPYFILTERS(lrecCustItemSurcharge);
                            lrecCustItemSurcharge2.SETRANGE("Sales Type", lrecCustItemSurcharge2."Sales Type"::Customer);
                            lrecCustItemSurcharge2.SETRANGE("Sales Code", lrecCustomer."No.");
                            lrecCustItemSurcharge2.SETRANGE("Ship-To Code", lrecSalesHeader."Ship-to Code");

                            IF lrecCustItemSurcharge2.FINDFIRST THEN BEGIN
                                lblnSkipCurrRecord := TRUE;
                            END;
                        END;
                    END;

                    lcodPreviousCharge := lrecCustItemSurcharge."Surcharge Code";

                    IF NOT lblnSkipCurrRecord THEN BEGIN
                        //-- reset type field to avoid error if document is released
                        lrecSalesLine.Type := lrecSalesLine.Type::" ";

                        lrecSalesLine := precSourceSalesLine;

                        lrecSalesLine.SuspendStatusCheck(TRUE);

                        //-- Does line already exist (i.e. shipped)
                        lblnExistingItemChargeLine := FALSE;

                        lrecSalesLineExisting.SETRANGE("Document Type", precSourceSalesLine."Document Type");
                        lrecSalesLineExisting.SETRANGE("Document No.", precSourceSalesLine."Document No.");
                        lrecSalesLineExisting.SETRANGE("Line No.");
                        lrecSalesLineExisting.SETRANGE(Type, lrecSalesLineExisting.Type::"Charge (Item)");
                        lrecSalesLineExisting.SETRANGE("No.", lrecCustItemSurcharge."Surcharge Code");
                        lrecSalesLineExisting.SETRANGE("Attached to Line No.", precSourceSalesLine."Line No.");

                        IF lrecSalesLineExisting.FINDFIRST THEN BEGIN
                            lrecSalesLine.GET(lrecSalesLineExisting."Document Type",
                                              lrecSalesLineExisting."Document No.",
                                              lrecSalesLineExisting."Line No.");

                            lblnExistingItemChargeLine := TRUE;
                        END ELSE BEGIN
                            lrecSalesLine."Line No." := jfGetNextSalesLineNo(precSourceSalesLine);
                        END;

                        IF NOT lblnExistingItemChargeLine THEN BEGIN
                            lrecSalesLine."No." := '';
                            lrecSalesLine.Quantity := 0;
                            lrecSalesLine."Qty. to Invoice" := 0;
                            lrecSalesLine."Qty. to Ship" := 0;
                            lrecSalesLine."Qty. Shipped Not Invoiced" := 0;
                            lrecSalesLine."Quantity Shipped" := 0;
                            lrecSalesLine."Quantity Invoiced" := 0;
                            lrecSalesLine."Outstanding Quantity" := 0;
                            lrecSalesLine."Quantity (Base)" := 0;
                            lrecSalesLine."Outstanding Qty. (Base)" := 0;
                            lrecSalesLine."Qty. to Invoice (Base)" := 0;
                            lrecSalesLine."Qty. to Ship (Base)" := 0;
                            lrecSalesLine."Qty. Shipped Not Invd. (Base)" := 0;
                            lrecSalesLine."Qty. Shipped (Base)" := 0;
                            lrecSalesLine."Qty. Invoiced (Base)" := 0;
                            lrecSalesLine."Shipment No." := '';
                            //<JF7732SHR>
                            lrecSalesLine."Drop Shipment" := FALSE;
                            lrecSalesLine."Purchase Order No." := '';
                            lrecSalesLine."Purch. Order Line No." := 0;
                            //</JF7732SHR>

                            //<JF18333MG>
                            lrecSalesLine."Prepayment %" := 0;
                            lrecSalesLine."Prepmt. Line Amount" := 0;
                            lrecSalesLine."Prepmt. Amt. Inv." := 0;
                            lrecSalesLine."Prepmt. Amt. Incl. VAT" := 0;
                            lrecSalesLine."Prepayment Amount" := 0;
                            lrecSalesLine."Prepmt. VAT Base Amt." := 0;
                            lrecSalesLine."Prepayment VAT %" := 0;
                            lrecSalesLine."Prepmt Amt to Deduct" := 0;
                            lrecSalesLine."Prepmt Amt Deducted" := 0;
                            lrecSalesLine."Prepmt. Amount Inv. Incl. VAT" := 0;
                            lrecSalesLine."Prepmt. Amount Inv. (LCY)" := 0;
                            //</JF18333MG>

                            lrecSalesLine.VALIDATE(Type, lrecSalesLine.Type::"Charge (Item)");
                            lrecSalesLine.VALIDATE("No.", lrecCustItemSurcharge."Surcharge Code");

                            //<JF18333MG>
                            lrecSalesLine."Prepayment %" := 0;
                            lrecSalesLine."Prepmt. Line Amount" := 0;
                            lrecSalesLine."Prepmt. Amt. Inv." := 0;
                            lrecSalesLine."Prepmt. Amt. Incl. VAT" := 0;
                            lrecSalesLine."Prepayment Amount" := 0;
                            lrecSalesLine."Prepmt. VAT Base Amt." := 0;
                            lrecSalesLine."Prepayment VAT %" := 0;
                            lrecSalesLine."Prepmt Amt to Deduct" := 0;
                            lrecSalesLine."Prepmt Amt Deducted" := 0;
                            lrecSalesLine."Prepmt. Amount Inv. Incl. VAT" := 0;
                            lrecSalesLine."Prepmt. Amount Inv. (LCY)" := 0;
                            //</JF18333MG>

                            lrecSalesLine."Item Charge Type" := lrecSalesLine."Item Charge Type"::Surcharge;

                            //<JF30735SHR>
                            CASE poptSurchargeType OF
                                poptSurchargeType::Surcharge:
                                    BEGIN
                                        lrecSalesLine."Item Charge Type" := lrecSalesLine."Item Charge Type"::Surcharge;
                                    END;
                                poptSurchargeType::Allowance:
                                    BEGIN
                                        lrecSalesLine."Item Charge Type" := lrecSalesLine."Item Charge Type"::Allowance;
                                    END;
                            END;
                            //</JF30735SHR>

                            //<JF11233SHR>
                            lrecSalesLine."Item Container Type" := lrecCustItemSurcharge."Item Container Type";
                            //</JF11233SHR>
                        END;

                        lrecUOM.GET(lrecCustItemSurcharge."Surcharge UOM");
                        lrecUOM2.GET(lrecInventorySetup."Standard Weight UOM");
                        lrecUOMSourceLine.GET(precSourceSalesLine."Unit of Measure Code");

                        //------------------------------------------
                        // Is surcharge for a Weight Unit of Measure, Grouped Unit of Measure, or Unit?
                        //------------------------------------------
                        CASE TRUE OF
                            lrecUOM."UOM Group Code" = lrecInventorySetup."Weight UOM Group":
                                //------------------------------------------
                                // 1.  Weight Unit of Measure:
                                //------------------------------------------
                                BEGIN
                                    IF lrecUOMSourceLine."UOM Group Code" = lrecInventorySetup."Weight UOM Group" THEN BEGIN
                                        IF lrecUOMSourceLine.Code = lrecUOM.Code THEN BEGIN
                                            lrecSalesLine.VALIDATE(Quantity, precSourceSalesLine.Quantity);
                                        END ELSE BEGIN
                                            lcduUOMConst.jfBypassRounding(TRUE);
                                            //-- Convert weight into UOM on item line
                                            //<JF8584SHR>
                                            CASE grecSalesSetup."Sales Surcharge Weight Type" OF
                                                grecSalesSetup."Sales Surcharge Weight Type"::Net:
                                                    BEGIN
                                                        precSourceSalesLine."Net Weight" :=
                                                        lcduUOMConst.jmdoConvertUOMConst(lrecUOM2.Code, lrecUOMSourceLine.Code, precSourceSalesLine."Net Weight");
                                                        lrecSalesLine.VALIDATE(Quantity, precSourceSalesLine."Net Weight" * precSourceSalesLine."Quantity (Base)");
                                                    END;
                                                grecSalesSetup."Sales Surcharge Weight Type"::"Gross if Not Zero Else Net":
                                                    BEGIN
                                                        IF precSourceSalesLine."Gross Weight" <> 0 THEN BEGIN
                                                            precSourceSalesLine."Gross Weight" :=
                                                            lcduUOMConst.jmdoConvertUOMConst(lrecUOM2.Code, lrecUOMSourceLine.Code,
                                                                                             precSourceSalesLine."Gross Weight");
                                                            lrecSalesLine.VALIDATE(Quantity,
                                                                                   precSourceSalesLine."Gross Weight" * precSourceSalesLine."Quantity (Base)");
                                                        END ELSE BEGIN
                                                            precSourceSalesLine."Net Weight" :=
                                                            lcduUOMConst.jmdoConvertUOMConst(lrecUOM2.Code, lrecUOMSourceLine.Code, precSourceSalesLine."Net Weight");
                                                            lrecSalesLine.VALIDATE(Quantity,
                                                                                   precSourceSalesLine."Net Weight" * precSourceSalesLine."Quantity (Base)");
                                                        END;
                                                    END;
                                                grecSalesSetup."Sales Surcharge Weight Type"::Gross:
                                                    BEGIN
                                                        precSourceSalesLine."Gross Weight" :=
                                                        lcduUOMConst.jmdoConvertUOMConst(lrecUOM2.Code, lrecUOMSourceLine.Code, precSourceSalesLine."Gross Weight");
                                                        lrecSalesLine.VALIDATE(Quantity, precSourceSalesLine."Gross Weight" * precSourceSalesLine."Quantity (Base)");
                                                    END;
                                            END;
                                            //</JF8584SHR>
                                        END;
                                    END ELSE BEGIN
                                        //-- Item line is non-weight UOM
                                        lcduUOMConst.jfBypassRounding(TRUE);

                                        //-- Convert weight into UOM on item line
                                        //<JF8584SHR>
                                        CASE grecSalesSetup."Sales Surcharge Weight Type" OF
                                            grecSalesSetup."Sales Surcharge Weight Type"::Net:
                                                BEGIN
                                                    precSourceSalesLine."Net Weight" :=
                                                    lcduUOMConst.jmdoConvertUOMConst(lrecUOM2.Code, lrecUOM.Code, precSourceSalesLine."Net Weight");
                                                    lrecSalesLine.VALIDATE(Quantity, precSourceSalesLine."Net Weight" * precSourceSalesLine.Quantity);
                                                END;
                                            grecSalesSetup."Sales Surcharge Weight Type"::"Gross if Not Zero Else Net":
                                                BEGIN
                                                    IF precSourceSalesLine."Gross Weight" <> 0 THEN BEGIN
                                                        precSourceSalesLine."Gross Weight" :=
                                                        lcduUOMConst.jmdoConvertUOMConst(lrecUOM2.Code, lrecUOM.Code, precSourceSalesLine."Gross Weight");
                                                        lrecSalesLine.VALIDATE(Quantity, precSourceSalesLine."Gross Weight" * precSourceSalesLine.Quantity);
                                                    END ELSE BEGIN
                                                        precSourceSalesLine."Net Weight" :=
                                                        lcduUOMConst.jmdoConvertUOMConst(lrecUOM2.Code, lrecUOM.Code, precSourceSalesLine."Net Weight");
                                                        lrecSalesLine.VALIDATE(Quantity, precSourceSalesLine."Net Weight" * precSourceSalesLine.Quantity);
                                                    END;
                                                END;
                                            grecSalesSetup."Sales Surcharge Weight Type"::Gross:
                                                BEGIN
                                                    precSourceSalesLine."Gross Weight" :=
                                                    lcduUOMConst.jmdoConvertUOMConst(lrecUOM2.Code, lrecUOM.Code, precSourceSalesLine."Gross Weight");
                                                    lrecSalesLine.VALIDATE(Quantity, precSourceSalesLine."Gross Weight" * precSourceSalesLine.Quantity);
                                                END;
                                        END;
                                        //</JF8584SHR>
                                    END;
                                END;
                            ELSE
                                //------------------------------------------
                                // 2. Non-Grouped Unit:
                                //------------------------------------------
                                IF NOT lrecItemUOM.GET(precSourceSalesLine."No.", lrecCustItemSurcharge."Surcharge UOM") THEN
                                    ERROR(JMText0001, precSourceSalesLine."No.", lrecCustItemSurcharge."Surcharge UOM", lrecItemUOM.TABLENAME);
                                lrecSalesLine.VALIDATE(Quantity, ROUND(precSourceSalesLine."Quantity (Base)" /
                                    lrecItemUOM."Qty. per Unit of Measure", lrecCustItemSurcharge."Rounding Precision"));
                        END;

                        IF NOT lblnExistingItemChargeLine THEN BEGIN
                            lrecSalesLine.VALIDATE("Unit of Measure Code", lrecCustItemSurcharge."Surcharge UOM");
                        END;

                        IF lrecCustItemSurcharge."Currency Code" = precSourceSalesLine."Currency Code" THEN BEGIN
                            lrecSalesLine.VALIDATE("Unit Price", lrecCustItemSurcharge."Surcharge Amount")
                        END ELSE BEGIN
                            lrecSalesLine.VALIDATE("Unit Price",
                              jfConvertChargeCurrency(lrecSalesLine, lrecCustItemSurcharge."Currency Code",
                                                      lrecCustItemSurcharge."Surcharge Amount"));
                        END;

                        lrecSalesLine."Item Charge Reference No." := lrecCustItemSurcharge."External Reference No.";

                        //<JF2277DD>
                        lrecSalesLine."Requested Order Qty." := precSourceSalesLine."Requested Order Qty.";
                        //</JF2277DD>

                        IF NOT lblnExistingItemChargeLine THEN BEGIN
                            lrecSalesLine."Attached to Line No." := precSourceSalesLine."Line No.";
                            lrecSalesLine."Include IC in Unit Price" := lrecCustItemSurcharge."Include in Unit Price";

                            lrecSalesLine."Allow Invoice Disc." := lrecCustItemSurcharge."Allow Invoice Disc.";
                            lrecSalesLine."Allow Line Disc." := lrecCustItemSurcharge."Allow Line Disc.";

                            IF lrecSalesLine."Allow Line Disc." THEN
                                lrecSalesLine.VALIDATE("Line Discount %", precSourceSalesLine."Line Discount %");

                            IF lrecSalesLine.jfmgCheckItemChgInherit(lrecSalesLine."No.") THEN BEGIN

                                lrecSalesLine."Dimension Set ID" := 0;
                                lrecSalesLine."Shortcut Dimension 1 Code" := '';
                                lrecSalesLine."Shortcut Dimension 2 Code" := '';
                                //</JF42512SHR>
                                lrecSalesLine."Dimension Set ID" := precSourceSalesLine."Dimension Set ID";

                                DimMgt.UpdateGlobalDimFromDimSetID(
                                  lrecSalesLine."Dimension Set ID", lrecSalesLine."Shortcut Dimension 1 Code", lrecSalesLine."Shortcut Dimension 2 Code");
                            END;

                            lrecSalesLine.INSERT;

                            jfCreateRelatedChargeRecords(precSourceSalesLine, lrecSalesLine);
                        END ELSE BEGIN
                            IF lrecSalesLine."Allow Line Disc." THEN
                                lrecSalesLine.VALIDATE("Line Discount %", precSourceSalesLine."Line Discount %");

                            lrecSalesLine.MODIFY;

                            jfModifyRelatedChargeRecords(precSourceSalesLine, lrecSalesLine);
                        END;
                    END;
                END;
            UNTIL lrecCustItemSurcharge.NEXT(-1) = 0;
        END;
    end;

    var
        myInt: Integer;
}