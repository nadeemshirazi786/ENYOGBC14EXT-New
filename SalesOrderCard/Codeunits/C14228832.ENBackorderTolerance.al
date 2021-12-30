codeunit 14228832 "Func. Backorder Tolr. ELA"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeVerifyReservedQty', '', true, true)]
    local procedure BeforeVerifyReservedQty(var SalesLine: Record "Sales Line")
    begin
        SalesLine.BeforeVerifyReservedQty();
    end;

    [EventSubscriber(ObjectType::Table, 5767, 'OnBeforeValidateQtyToHandle', '', true, true)]
    local procedure BeforeValidateQtyToHandle(var WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
        // IF WarehouseActivityLine."Action Type" = WarehouseActivityLine."Action Type"::Take THEN BEGIN
        //     WarehouseActivityLine.jfSetUpdatePlaceLine(true);
        // END;
        IsHandled := true;
        //WarehouseActivityLine.jfUpdatePlaceLine(WarehouseActivityLine.FIELDNO("Qty. to Handle"));
    end;

    [EventSubscriber(ObjectType::Codeunit, 88, 'OnBeforeReleaseSalesDoc', '', true, true)]
    local procedure BeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        jfCheckSalesBackorder(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5763, 'OnBeforeCheckWhseShptLines', '', true, true)]
    procedure BeforeCheckWhseShptLines(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    var
        WhseShptLine2: Record "Warehouse Shipment Line";
        lrecWhseShipLine: Record "Warehouse Shipment Line";
        lrecTransHeader: Record "Transfer Header";
        gblnDirectTransfer: Boolean;
    begin
        //-- Check Tolerance on ALL lines (including ones not being shipped)
        IF WarehouseShipmentLine.FINDSET(TRUE) THEN BEGIN
            REPEAT
                jfCheckWhseShptLineTolerance(WarehouseShipmentLine);

                //-- Remove line if Quantity = 0 (i.e. no backorders)
                IF WarehouseShipmentLine.Quantity = 0 THEN BEGIN
                    lrecWhseShipLine.GET(WarehouseShipmentLine."No.", WarehouseShipmentLine."Line No.");
                    lrecWhseShipLine.DELETE;
                END;

                //<JF2927MG>
                //-- For direct transfers, set Quantity = Qty. To Ship if Qty. To Ship < Quantity
                IF WarehouseShipmentLine."Source Document" = WarehouseShipmentLine."Source Document"::"Outbound Transfer" THEN BEGIN

                    //<JF32614SHR>
                    lrecTransHeader.GET(WarehouseShipmentLine."Source No.");
                    IF lrecTransHeader."Direct Transfer" THEN BEGIN
                        gblnDirectTransfer := TRUE;
                    END;
                    //</JF32614SHR>

                    IF (WarehouseShipmentLine."Qty. to Ship" <> 0) AND (WarehouseShipmentLine."Qty. to Ship" < WarehouseShipmentLine.Quantity) THEN BEGIN
                        lrecTransHeader.GET(WarehouseShipmentLine."Source No.");

                        IF lrecTransHeader."Direct Transfer" THEN BEGIN
                            lrecWhseShipLine.GET(WarehouseShipmentLine."No.", WarehouseShipmentLine."Line No.");

                            //<JF23902MG>
                            lrecWhseShipLine.jfFromWhsePost(TRUE);
                            //</JF23902MG>

                            lrecWhseShipLine.VALIDATE(Quantity, WarehouseShipmentLine."Qty. to Ship");
                            lrecWhseShipLine.VALIDATE("Qty. to Ship", lrecWhseShipLine.Quantity);
                            lrecWhseShipLine.MODIFY;
                        END;
                    END;
                END;
                //</JF2927MG>


                //<JF23902MG>
                WarehouseShipmentLine.jfFromWhsePost(TRUE);

            // IF grecWhseSetup."Auto Calc Whse. Shpmt. Pallets" THEN BEGIN
            //     WarehouseShipmentLine."No. of Pallets" := WarehouseShipmentLine.jxCalcNoStdPallets(FALSE, 0, TRUE);
            //     WarehouseShipmentLine."No. of Pallets to Ship" := WarehouseShipmentLine.jxCalcNoStdPallets(FALSE, 0, FALSE);
            //     WarehouseShipmentLine.MODIFY;
            // END;
            //</JF23902MG>

            UNTIL WarehouseShipmentLine.NEXT = 0;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5763, 'OnBeforeDeleteUpdateWhseShptLine', '', true, true)]
    local procedure BeforeDeleteUpdateWhseShptLine(WhseShptLine: Record "Warehouse Shipment Line")
    var
        lrecWhseActivityLine: Record "Warehouse Activity Line";
        lrecWhseActivityLine1: Record "Warehouse Activity Line";
        lrecWhseActivityHeader: Record "Warehouse Activity Header";
        loptActivityType: Integer;
        lcodNo: Code[20];
    begin
        IF WhseShptLine."Qty. Outstanding" = WhseShptLine."Qty. to Ship" THEN BEGIN
            lrecWhseActivityLine.RESET;

            lrecWhseActivityLine.SETCURRENTKEY("Whse. Document No.", "Whse. Document Type");
            lrecWhseActivityLine.SETRANGE("Whse. Document Type", lrecWhseActivityLine."Activity Type"::Pick);
            lrecWhseActivityLine.SETRANGE("Whse. Document No.", WhseShptLine."No.");
            lrecWhseActivityLine.SETRANGE("Whse. Document Line No.", WhseShptLine."Line No.");

            IF NOT lrecWhseActivityLine.ISEMPTY THEN BEGIN
                IF lrecWhseActivityLine.FINDSET(TRUE) THEN
                    REPEAT
                        CLEAR(loptActivityType);
                        CLEAR(lcodNo);

                        lrecWhseActivityLine.SETRANGE("Activity Type", lrecWhseActivityLine."Activity Type");
                        lrecWhseActivityLine.SETRANGE("No.", lrecWhseActivityLine."No.");
                        lrecWhseActivityLine.SETRANGE("Line No.", lrecWhseActivityLine."Line No.");

                        IF lrecWhseActivityLine.FINDLAST THEN BEGIN
                            loptActivityType := lrecWhseActivityLine."Activity Type";
                            lcodNo := lrecWhseActivityLine."No.";

                            lrecWhseActivityLine.DELETEALL(TRUE);

                            lrecWhseActivityLine1.RESET;

                            lrecWhseActivityLine1.SETRANGE("Activity Type", loptActivityType);
                            lrecWhseActivityLine1.SETRANGE("No.", lcodNo);

                            IF lrecWhseActivityLine1.ISEMPTY THEN BEGIN
                                IF lrecWhseActivityHeader.GET(loptActivityType, lcodNo) THEN
                                    lrecWhseActivityHeader.DELETE(TRUE);
                            END;
                        END;

                        lrecWhseActivityLine.SETRANGE("Activity Type");
                        lrecWhseActivityLine.SETRANGE("No.");
                        lrecWhseActivityLine.SETRANGE("Line No.");
                    UNTIL lrecWhseActivityLine.NEXT = 0;
            END;
            WhseShptLine.DELETE;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5764, 'OnAfterConfirmPost', '', true, true)]
    local procedure AfterConfirmPost(WhseShipmentLine: Record "Warehouse Shipment Line")
    var
        WhseShptHdr: Record "Warehouse Shipment Header";
    begin
        if WhseShptHdr.Get(WhseShipmentLine."No.") then
            jfdoOpenPostedShipment(WhseShptHdr);
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
        // IF lblnUpdatedLine THEN
        //     gcduCalcSurcharges.jfAddOrderSurcharges(precSalesHeader, TRUE);
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

    procedure jfCheckWhseShptLineTolerance(VAR precWhseShptLine: Record "Warehouse Shipment Line")
    var
        lrecCustomer: Record Customer;
        lrecSalesHeader: Record "Sales Header";
        lrecSalesLine: Record "Sales Line";
        lrecShipTo: Record "Ship-to Address";
        ldecTolerance: Decimal;
        lblnFoundTolerance: Boolean;
        ldecQtyToShip: Decimal;
    begin
        //-- If the Qty. To Ship + Qty. Shipped is within the tolerance then close the line
        WITH precWhseShptLine DO BEGIN
            IF ("Source Type" = DATABASE::"Sales Line") AND
               ("Source Subtype" = 1)
            THEN BEGIN
                //-- Get the SO Line in order to get the tolerance
                IF lrecSalesLine.GET("Source Subtype", "Source No.", "Source Line No.") THEN BEGIN
                    IF "Qty. to Ship" + lrecSalesLine."Quantity Shipped" >= lrecSalesLine.Quantity THEN
                        EXIT;

                    //-- check if Item lines are within backorder tolerance
                    ldecTolerance := 0;
                    lblnFoundTolerance := FALSE;

                    lrecSalesHeader.GET(lrecSalesLine."Document Type", lrecSalesLine."Document No.");

                    //<JF8401SHR>
                    IF lrecSalesHeader."Prepayment %" <> 0 THEN
                        EXIT;
                    //</JF8401SHR>
                    IF lrecSalesHeader."Ship-to Code" <> '' THEN BEGIN
                        lrecShipTo.GET(lrecSalesHeader."Sell-to Customer No.", lrecSalesHeader."Ship-to Code");

                        IF lrecShipTo."Use Backorder Tolerance ELA" THEN BEGIN
                            lblnFoundTolerance := TRUE;
                            //ldecTolerance := lrecShipTo."Backorder Tolerance %"; //<JF12270DT>
                        END;
                    END;

                    IF NOT lblnFoundTolerance THEN BEGIN
                        lrecCustomer.GET(lrecSalesHeader."Sell-to Customer No.");

                        IF lrecCustomer."Use Backorder Tolerance ELA" THEN BEGIN
                            lblnFoundTolerance := TRUE;
                            //ldecTolerance := lrecCustomer."Backorder Tolerance %"; //<JF12270DT>
                        END;
                    END;

                    IF lblnFoundTolerance THEN BEGIN

                        IF ROUND((1 - ("Qty. to Ship" + lrecSalesLine."Quantity Shipped") / lrecSalesLine.Quantity) * 100, 0.00001)
                                   <= lrecSalesLine."Backorder Tolerance %" THEN BEGIN
                            //</JF12270DT>

                            //-- Update Whse. Shipment Line
                            AllowZeroQuantity(TRUE);
                            BypassStatusCheck(TRUE);

                            ldecQtyToShip := "Qty. to Ship";

                            VALIDATE(Quantity, "Qty. to Ship");
                            VALIDATE("Qty. to Ship", ldecQtyToShip);
                            MODIFY;

                            //-- Update sales line
                            lrecSalesLine.SuspendStatusCheck(TRUE);
                            lrecSalesLine.jfSuspendPriceCalc(TRUE);
                            lrecSalesLine.jfmgAllowQtyChangeWhse;

                            //<JF07972AC>
                            lrecSalesLine.jfBypassPlanningWarning;
                            //</JF07972AC>

                            //-- Remove any "extra" item tracking that may already be set up for the sales line
                            jfAdjustSalesLineItemTracking(lrecSalesLine, "Qty. to Ship (Base)" + lrecSalesLine."Qty. Shipped (Base)");

                            ldecQtyToShip := "Qty. to Ship";

                            lrecSalesLine.VALIDATE(Quantity, "Qty. to Ship" + lrecSalesLine."Quantity Shipped");
                            lrecSalesLine.VALIDATE("Qty. to Ship", ldecQtyToShip);

                            lrecSalesLine.MODIFY;
                            //<<EN1.00
                            //gcduCalcSurcharges.jfAddOrderSurcharges(lrecSalesHeader,TRUE);
                            // IF NOT lrecSalesLine."Lock Pricing ELA" THEN
                            //     gcduCalcSurcharges.jfAddOrderSurcharges(lrecSalesHeader, TRUE);
                            //>>EN1.00
                        END;
                    END;
                END;
            END;
        END;
    end;

    procedure jfdoOpenPostedShipment(WhseShptHeader: Record "Warehouse Shipment Header")
    var
        lrecPostedWhseShpt: Record "Posted Whse. Shipment Header";
    begin
        IF lrecPostedWhseShpt.GET(WhseShptHeader."Shipping No.") THEN
            PAGE.RUN(PAGE::"Posted Whse. Shipment", lrecPostedWhseShpt);
    end;


}