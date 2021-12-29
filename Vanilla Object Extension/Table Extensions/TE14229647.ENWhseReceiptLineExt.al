tableextension 14229647 "EN Whse Receipt Line Ext" extends "Warehouse Receipt Line"
{
    fields
    {
        field(14229700; "Receiving Quantity ELA"; Decimal)
        {
            Caption = 'Receiving Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            trigger OnValidate()
            var
                lrecItem: Record Item;
                lrecUOM: Record "Unit of Measure";
                ldecConversion: Decimal;
                ldecBaseQty: Decimal;
                lcduUOMConstant: Codeunit "EN UOM Management";
            begin

                TESTFIELD("Receiving UOM ELA");

                lrecItem.GET("Item No.");
                lrecUOM.GET("Receiving UOM ELA");

                ldecConversion := lcduUOMConstant.GetConversion(lrecItem, lrecUOM);

                IF ldecConversion = 0 THEN
                    ldecConversion := 1;

                ldecBaseQty := "Receiving Quantity ELA" / ldecConversion;

                gblnFromReceiveQty := TRUE;
                VALIDATE("Qty. to Receive", CalcQty(ldecBaseQty));
                gblnFromReceiveQty := FALSE;
            end;
        }
        field(14229701; "Receiving UOM ELA"; Code[10])
        {
            Caption = 'Receiving Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
            trigger OnValidate()
            begin
                VALIDATE("Receiving Quantity ELA");
            end;
        }
        field(14229702; "Receiving Complete ELA"; Boolean)
        {
            Caption = 'Receiving Complete';
        }
        field(14229703; "Vendor Item No. ELA"; Text[20])
        {
            Caption = 'Vendor Item No.';
            FieldClass = FlowField;
            CalcFormula = Lookup(Item."Vendor Item No." WHERE("No." = FIELD("Item No.")));
            Editable = false;

        }
        field(14229704; "Qty. Secondary (Base UOM) ELA"; Decimal)
        {
            Caption = 'Qty. Secondary (Base UOM)';
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            var
                lcduSecUOMMgt: codeunit "EN UOM Management";
                lrecPurchLine: Record "Purchase Line";
                lrecPurchHeader: Record "Purchase Header";
                lrecTransferLine: Record "Transfer Line";
            begin
                IF lcduSecUOMMgt.CheckAllowVariableUOM("Item No.", "Unit of Measure Code", TRUE) THEN BEGIN
                    IF Quantity <> 0 THEN BEGIN
                        "Qty. per Unit of Measure" := ROUND("Qty. Secondary (Base UOM) ELA" / Quantity, 0.00001);
                        lcduSecUOMMgt.CheckVariableUOMTolerance("Item No.", "Unit of Measure Code", "Qty. per Unit of Measure", TRUE);

                        "Qty. (Base)" := "Qty. Secondary (Base UOM) ELA";
                        "Qty. to Receive (Base)" := "Qty. Secondary (Base UOM) ELA";
                        "Qty. Outstanding (Base)" := "Qty. Secondary (Base UOM) ELA";

                        CASE "Source Type" OF
                            DATABASE::"Purchase Line":
                                BEGIN
                                    IF lrecPurchLine.GET("Source Subtype", "Source No.", "Source Line No.") THEN BEGIN
                                        lrecPurchHeader.GET("Source Subtype", "Source No.");
                                        lrecPurchLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
                                        lrecPurchLine."Quantity (Base)" := "Qty. Secondary (Base UOM) ELA";
                                        lrecPurchLine."Qty. to Invoice (Base)" := "Qty. Secondary (Base UOM) ELA";
                                        lrecPurchLine."Qty. to Receive (Base)" := "Qty. Secondary (Base UOM) ELA";
                                        lrecPurchLine."Qty. Secondary (Base UOM) ELA" := "Qty. Secondary (Base UOM) ELA";
                                        lrecPurchLine.MODIFY;

                                        lrecPurchLine.UpdateAmounts;
                                        lrecPurchLine.MODIFY;
                                        lrecPurchLine.CalcSalesTaxLines(lrecPurchHeader, lrecPurchLine);
                                        lrecPurchLine.MODIFY;

                                    END;
                                END;

                            DATABASE::"Transfer Line":
                                BEGIN
                                    IF lrecTransferLine.GET("Source No.", "Source Line No.") THEN BEGIN
                                        ERROR(gjfText000);
                                    END;
                                END;
                        END;
                    END;
                END;
            end;
        }
        modify("Qty. to Receive")
        {
            trigger OnAfterValidate()
            begin
                JfOverReceive();
            end;
        }
    }

    procedure CalcQty(QtyBase: Decimal): Decimal
    begin

        TESTFIELD("Qty. per Unit of Measure");
        EXIT(ROUND(QtyBase / "Qty. per Unit of Measure", 0.00001));
    end;

    procedure JfOverReceive()
    var
        lrecPurchHeader: Record "Purchase Header";
        lrecPurchLine: Record "Purchase Line";
        lrecPurchSetup: Record "Purchases & Payables Setup";
        lcduRelPurchDoc: Codeunit "Release Purchase Document";
        lcodUserID: code[20];
        ldecQtyToReceive: Decimal;
        lblnWasReleased: Boolean;

    begin

        //<JF00026CB>
        IF "Qty. to Receive" = 0 THEN
            EXIT;

        lrecPurchSetup.GET;
        IF lrecPurchSetup."Allow Over Receiving ELA" THEN BEGIN
            IF "Source Document" = "Source Document"::"Purchase Order" THEN BEGIN
                lrecPurchHeader.GET("Source Subtype", "Source No.");

                IF (ABS("Qty. to Receive") > ABS("Qty. Outstanding")) THEN BEGIN
                    //IF lrecPurchSetup."Use Over Receiving Approvals" THEN BEGIN
                    //  lcodUserID := lcduApprovePurch.jfcbApproveOverReceiveWhse(Rec);
                END;

                IF (lrecPurchHeader."Tax Area Code" <> '') AND (lrecPurchHeader.Status = lrecPurchHeader.Status::Released) THEN BEGIN
                    lblnWasReleased := TRUE;
                    lcduRelPurchDoc.Reopen(lrecPurchHeader);
                END;

                gblnOverReceive := TRUE;
                VALIDATE(Quantity, "Qty. to Receive" + "Qty. Received");
                gblnOverReceive := FALSE;
                IF lrecPurchLine.GET("Source Subtype", "Source No.", "Source Line No.") THEN BEGIN
                    lrecPurchLine.SuspendUpdateDirectUnitCost(TRUE);
                    lrecPurchLine.jfAllowQtyChangeWhse;
                    lrecPurchLine.VALIDATE(Quantity, Quantity);
                    lrecPurchLine."Approved By ELA" := lcodUserID;
                    lrecPurchLine.UpdateAmounts;
                    lrecPurchLine.MODIFY;
                END;

                IF lblnWasReleased THEN BEGIN
                    lcduRelPurchDoc.RUN(lrecPurchHeader);
                END;
            END ELSE BEGIN
                IF lrecPurchLine.GET("Source Subtype", "Source No.", "Source Line No.") THEN BEGIN
                    IF (lrecPurchLine."Original Order Qty. ELA" <> 0) AND
                       (lrecPurchLine.Quantity <> lrecPurchLine."Original Order Qty. ELA")
                    THEN BEGIN
                        IF (lrecPurchHeader."Tax Area Code" <> '') AND (lrecPurchHeader.Status = lrecPurchHeader.Status::Released) THEN BEGIN
                            lblnWasReleased := TRUE;
                            lcduRelPurchDoc.Reopen(lrecPurchHeader);
                            lrecPurchHeader.MODIFY;
                        END;

                        lrecPurchLine.GET(lrecPurchLine."Document Type", lrecPurchLine."Document No.", lrecPurchLine."Line No.");

                        lrecPurchLine.jfAllowQtyChangeWhse;
                        lrecPurchLine.SuspendUpdateDirectUnitCost(TRUE);


                        IF lrecPurchLine."Quantity Received" <> 0 THEN BEGIN
                            IF lrecPurchLine."Quantity Received" + "Qty. to Receive" <> lrecPurchLine.Quantity THEN BEGIN
                                lrecPurchLine.VALIDATE(Quantity, lrecPurchLine."Quantity Received" + "Qty. to Receive");
                                lrecPurchLine."Approved By ELA" := lcodUserID;
                                lrecPurchLine.UpdateAmounts;
                                lrecPurchLine.MODIFY;

                                gblnOverReceive := TRUE;
                                ldecQtyToReceive := "Qty. to Receive";
                                VALIDATE(Quantity, lrecPurchLine.Quantity);
                                VALIDATE("Qty. to Receive", ldecQtyToReceive);
                                gblnOverReceive := FALSE;

                            END;
                        END ELSE BEGIN
                            IF (ABS("Qty. to Receive") <= lrecPurchLine."Original Order Qty. ELA") THEN BEGIN
                                lrecPurchLine.VALIDATE(Quantity, lrecPurchLine."Original Order Qty. ELA");
                                lrecPurchLine."Approved By ELA" := lcodUserID;
                                lrecPurchLine.UpdateAmounts;
                                lrecPurchLine.MODIFY;

                                gblnOverReceive := TRUE;
                                ldecQtyToReceive := "Qty. to Receive";
                                VALIDATE(Quantity, lrecPurchLine.Quantity);
                                VALIDATE("Qty. to Receive", ldecQtyToReceive);
                                gblnOverReceive := FALSE;
                            END ELSE BEGIN
                                IF NOT gblnOverReceive THEN BEGIN
                                    lrecPurchLine.VALIDATE(Quantity, "Qty. to Receive");
                                    lrecPurchLine."Approved By ELA" := lcodUserID;
                                    lrecPurchLine.UpdateAmounts;
                                    lrecPurchLine.MODIFY;

                                    gblnOverReceive := TRUE;
                                    ldecQtyToReceive := "Qty. to Receive";
                                    VALIDATE(Quantity, lrecPurchLine.Quantity);
                                    VALIDATE("Qty. to Receive", ldecQtyToReceive);
                                    gblnOverReceive := FALSE;
                                END;
                            END;
                        END;

                        IF lblnWasReleased THEN BEGIN
                            lcduRelPurchDoc.RUN(lrecPurchHeader);
                            lrecPurchHeader.MODIFY;
                        END;
                    END;
                END;
            END;
        END;
    END;
    //</JF00026CB>
    //end;

    var
        gblnFromReceiveQty: Boolean;
        gblnOverReceive: boolean;
        gjfText000: Label 'Variable weight items must be fully received.';
}
