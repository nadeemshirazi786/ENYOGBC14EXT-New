/// <summary>
/// Codeunit EN UOM Management (ID 14228853).
/// </summary>
codeunit 14228853 "EN UOM Management"
{
    /// <summary>
    /// TestItemUOMPrecision.
    /// </summary>
    /// <param name="pdecValue">Decimal.</param>
    procedure TestItemUOMPrecision(pdecValue: Decimal)
    var
        lrecInvSetup: Record "Inventory Setup";
        lintNoAllowedDecimals: Integer;
        lintNoActualDecimals: Integer;
        ltxtValue: Text;
        lText000: Label 'This value can have a maximum of %1 decimal places.';
    begin


        //-- Based on the field in Inventory Setup, make sure user does not specify more decimals than allowed
        lrecInvSetup.GET;

        //-- Get No. allowed decimals
        lintNoAllowedDecimals := 5;

        IF (lrecInvSetup."Item UOM Round Precision ELA" <> 0) AND
           (lrecInvSetup."Item UOM Round Precision ELA" <> 1) THEN BEGIN
            //-- Convert value into text and remove everything preceeding the decimal then take length to get no. decimals
            ltxtValue := FORMAT(lrecInvSetup."Item UOM Round Precision ELA");

            IF STRPOS(ltxtValue, '.') = 0 THEN BEGIN
                lintNoAllowedDecimals := 0;
            END ELSE BEGIN
                ltxtValue := COPYSTR(ltxtValue, STRPOS(ltxtValue, '.') + 1);
                lintNoAllowedDecimals := STRLEN(ltxtValue);
            END;
        END;

        //-- Determine decimals in parameter value
        ltxtValue := FORMAT(pdecValue);

        IF STRPOS(ltxtValue, '.') = 0 THEN
            EXIT;

        ltxtValue := COPYSTR(ltxtValue, STRPOS(ltxtValue, '.') + 1);

        lintNoActualDecimals := STRLEN(ltxtValue);

        IF lintNoActualDecimals > lintNoAllowedDecimals THEN
            ERROR(lText000, lintNoAllowedDecimals);

    end;

    procedure GetItemUOMPrecision(): Decimal
    var
        lrecInvSetup: Record "Inventory Setup";
    begin

        lrecInvSetup.GET;

        IF (lrecInvSetup."Item UOM Round Precision ELA" = 0) OR
           (lrecInvSetup."Item UOM Round Precision ELA" = 1) THEN BEGIN
            EXIT(0.00001);
        END ELSE BEGIN
            EXIT(lrecInvSetup."Item UOM Round Precision ELA");
        END;
    end;

    procedure CheckAllowVariableUOM(pcodItem: Code[20]; pcodUOM: Code[10]; pblnShowError: Boolean): Boolean
    var
        lrecItemUOM: Record "Item Unit of Measure";
    begin

        IF NOT lrecItemUOM.GET(pcodItem, pcodUOM) THEN
            EXIT(FALSE);

        IF pblnShowError AND NOT lrecItemUOM."Allow Variable Qty. Per ELA" THEN BEGIN

            lrecItemUOM.FIELDERROR("Allow Variable Qty. Per ELA");
        END;

        EXIT(lrecItemUOM."Allow Variable Qty. Per ELA");
    end;

    procedure CheckVariableUOMTolerance(pcodItem: Code[20]; pcodUOM: Code[10]; pdecNewQtyPer: Decimal; pblnShowError: Boolean)
    var
        lrecItemUOM: Record "Item Unit of Measure";
        lrecUserSetup: Record "User Setup";
    begin

        IF NOT lrecItemUOM.GET(pcodItem, pcodUOM) THEN
            EXIT;

        IF NOT lrecItemUOM."Allow Variable Qty. Per ELA" THEN
            EXIT;

        IF pdecNewQtyPer = 0 THEN
            EXIT;

    end;

    procedure GetSourceRecordUOM(ReservEntry: Record "Reservation Entry"; VAR pdecQty: Decimal; VAR pcodUOM: Code[10])
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        ReqLine: Record "Requisition Line";
        PurchLine: Record "Purchase Line";
        ItemJnlLine: Record "Item Journal Line";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        TransLine: Record "Transfer Line";

    begin

        WITH ReservEntry DO BEGIN
            CASE "Source Type" OF
                DATABASE::"Item Ledger Entry":
                    BEGIN
                        IF ItemLedgEntry.GET("Source Ref. No.") THEN BEGIN
                            pdecQty := ItemLedgEntry.Quantity;
                            pcodUOM := ItemLedgEntry."Unit of Measure Code";
                        END;
                    END;
                DATABASE::"Sales Line":
                    BEGIN
                        IF SalesLine.GET("Source Subtype", "Source ID", "Source Ref. No.") THEN BEGIN
                            pdecQty := SalesLine.Quantity;
                            pcodUOM := SalesLine."Unit of Measure Code";
                        END;
                    END;
                DATABASE::"Requisition Line":
                    BEGIN
                        IF ReqLine.GET("Source ID", "Source Batch Name", "Source Ref. No.") THEN BEGIN
                            pdecQty := ReqLine.Quantity;
                            pcodUOM := ReqLine."Unit of Measure Code";
                        END;
                    END;
                DATABASE::"Purchase Line":
                    BEGIN
                        IF PurchLine.GET("Source Subtype", "Source ID", "Source Ref. No.") THEN BEGIN
                            pdecQty := PurchLine.Quantity;
                            pcodUOM := PurchLine."Unit of Measure Code";
                        END;
                    END;
                DATABASE::"Item Journal Line":
                    BEGIN
                        IF ItemJnlLine.GET("Source ID", "Source Batch Name", "Source Ref. No.") THEN BEGIN
                            pdecQty := ItemJnlLine.Quantity;
                            pcodUOM := ItemJnlLine."Unit of Measure Code";
                        END;
                    END;
                DATABASE::"Prod. Order Line":
                    BEGIN
                        IF ProdOrderLine.GET("Source Subtype", "Source ID", "Source Prod. Order Line") THEN BEGIN
                            pdecQty := ProdOrderLine.Quantity;
                            pcodUOM := ProdOrderLine."Unit of Measure Code";
                        END;
                    END;
                DATABASE::"Prod. Order Component":
                    BEGIN
                        IF ProdOrderComp.GET("Source Subtype", "Source ID", "Source Prod. Order Line", "Source Ref. No.") THEN BEGIN
                            pdecQty := ProdOrderComp.Quantity;
                            pcodUOM := ProdOrderComp."Unit of Measure Code";
                        END;
                    END;

                DATABASE::"Transfer Line":
                    BEGIN
                        IF TransLine.GET("Source ID", "Source Ref. No.") THEN BEGIN
                            pdecQty := TransLine.Quantity;
                            pcodUOM := TransLine."Unit of Measure Code";
                        END;
                    END;

            END;
        END; // WITH 
    end;

    procedure GetConversion(precItem: Record Item; precToUOM: Record "Unit of Measure"): Decimal
    var
        lrecFromItemUOM: Record "Item Unit of Measure";
        lrecUOM: Record "Unit of Measure";
        lblnFoundUOMGroup: Boolean;
        ldecConversion: Decimal;
    begin

        //Find the Item UOM that has the same group as the chosen UOM for the report
        //Convert to this Unit of Measure (for this purpose, use 1)
        //Send this conversion of the common unit of measure to the codeunit for conversion to report uom.
        CLEAR(ldecConversion);

        IF precItem."Base Unit of Measure" = precToUOM.Code THEN BEGIN
            ldecConversion := 1;
            EXIT(ldecConversion);
        END;

        IF precToUOM."UOM Group Code ELA" <> '' THEN BEGIN
            IF precItem."Base Unit of Measure" <> precToUOM.Code THEN BEGIN
                //-- Look for specific UOM to convert to first then try first UOM group
                lrecFromItemUOM.RESET;
                lrecFromItemUOM.SETRANGE("Item No.", precItem."No.");
                lrecFromItemUOM.SETRANGE(Code, precToUOM.Code);

                IF lrecFromItemUOM.FINDFIRST THEN BEGIN
                    lrecFromItemUOM.TESTFIELD("Qty. per Unit of Measure");
                    EXIT(1 / lrecFromItemUOM."Qty. per Unit of Measure");
                END;

                lrecFromItemUOM.RESET;

                lrecFromItemUOM.SETRANGE("Item No.", precItem."No.");

                //-- If Base UOM is not in same group we cannot use it
                //<JF6176MG>
                precItem.TESTFIELD("Base Unit of Measure");
                //</JF6176MG>

                lrecUOM.GET(precItem."Base Unit of Measure");

                IF lrecUOM."UOM Group Code ELA" <> precToUOM."UOM Group Code ELA" THEN
                    lrecFromItemUOM.SETFILTER(Code, '<>%1', precItem."Base Unit of Measure")
                ELSE
                    lrecFromItemUOM.SETRANGE(Code);

                lrecFromItemUOM.SETRANGE("UOM Group ELA", precToUOM."UOM Group Code ELA");

                IF lrecFromItemUOM.FINDFIRST THEN BEGIN
                    lrecFromItemUOM.TESTFIELD("Qty. per Unit of Measure");

                    CLEAR(lblnFoundUOMGroup);

                    lrecUOM.GET(lrecFromItemUOM.Code);

                    ldecConversion := (1 / lrecFromItemUOM."Qty. per Unit of Measure") *
                                      (lrecUOM."Std. Qty. Per UOM ELA") /
                                      precToUOM."Std. Qty. Per UOM ELA";
                END ELSE BEGIN
                    ldecConversion := 0;
                END;
            END;
        END ELSE BEGIN
            //Get a specific item uom not by group
            IF precItem."Base Unit of Measure" <> precToUOM.Code THEN BEGIN
                IF lrecFromItemUOM.GET(precItem."No.", precToUOM.Code) THEN BEGIN
                    lrecFromItemUOM.TESTFIELD("Qty. per Unit of Measure");

                    EXIT(1 / lrecFromItemUOM."Qty. per Unit of Measure");
                END ELSE BEGIN
                    ldecConversion := 0;
                END;
            END;
        END;

        EXIT(ldecConversion);
    end;
}
