tableextension 14229635 "EN LT WhseShpmtLine EXT ELA" extends "Warehouse Shipment Line"
{
    procedure SetLotQuantity(LotNo: Code[20])
    begin
        GetSourceDocumentLine(SalesLine, PurchLine, TransLine);
        UpdateLotQuantity(SalesLine, PurchLine, TransLine);

    end;

    local procedure GetSourceDocumentLine(VAR SalesLine: Record "Sales Line"; VAR PurchaseLine: Record "Purchase Line"; VAR TransferLine: Record "Transfer Line")
    begin
        CASE "Source Type" OF
            DATABASE::"Sales Line":
                SalesLine.GET("Source Subtype", "Source No.", "Source Line No.");
            DATABASE::"Purchase Line":
                PurchaseLine.GET("Source Subtype", "Source No.", "Source Line No.");
            DATABASE::"Transfer Line":
                TransferLine.GET("Source No.", "Source Line No.");
        END;

    end;

    local procedure UpdateLotQuantity(VAR SalesLine: Record "Sales Line"; VAR PurchaseLine: Record "Purchase Line"; VAR TransferLine: Record "Transfer Line")
    begin
        CASE "Source Type" OF
            DATABASE::"Sales Line":
                BEGIN
                    SalesLine.MODIFY(TRUE);
                    SalesLine.WarehouseLineQuantity("Qty. to Ship (Base)", QtyToShipAlt, SalesLine."Qty. to Invoice (Base)"); // P80077569
                    SalesLine.UpdateLotTracking(TRUE, 0);
                END;
            DATABASE::"Purchase Line":
                BEGIN
                    PurchaseLine.MODIFY(TRUE);
                    PurchaseLine.WarehouseLineQuantityELA("Qty. to Ship (Base)", QtyToShipAlt, PurchaseLine."Qty. to Invoice (Base)"); // P80077569
                    PurchaseLine.UpdateLotTracking(TRUE);
                END;
            DATABASE::"Transfer Line":
                BEGIN
                    TransferLine.MODIFY(TRUE);
                    TransferLine.UpdateLotTracking(TRUE, 0);
                END;
        END;
    end;

    procedure GetLotNo(): code[50]
    begin
        CASE "Source Type" OF
            DATABASE::"Sales Line":
                BEGIN
                    SalesLine.GET("Source Subtype", "Source No.", "Source Line No.");
                    SalesLine.GetLotNo;
                    EXIT(SalesLine."Lot No. ELA");
                END;
            DATABASE::"Purchase Line":
                BEGIN
                    PurchLine.GET("Source Subtype", "Source No.", "Source Line No.");
                    PurchLine.GetLotNo;
                    EXIT(PurchLine."Supplier Lot No. ELA");
                END;
            DATABASE::"Transfer Line":
                BEGIN
                    TransLine.GET("Source No.", "Source Line No.");
                    TransLine.GetLotNo;
                    EXIT(TransLine."Lot No. ELA");
                END;
        END;

    end;

    procedure AllowZeroQuantity(pblnAllowZeroQty: Boolean)
    begin
        gblnAllowZeroQty := pblnAllowZeroQty;
    end;

    procedure BypassStatusCheck(pblnBypassStatusCheck: Boolean)
    begin
        gblnBypassStatusCheck := pblnBypassStatusCheck;
    end;

    procedure jfFromWhsePost(pblnFromWhsePost: Boolean)
    begin
        gblnFromWhsePost := pblnFromWhsePost;
    end;

    var
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        SalesLine: Record "Sales Line";
        QtyToShipAlt: Decimal;
        gblnAllowZeroQty: Boolean;
        gblnBypassStatusCheck: Boolean;
        gblnFromWhsePost: Boolean;

}