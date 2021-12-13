codeunit 14229406 "purch. Line-Reserve ELA"
{
    // ENRE1.00 2021-09-08 AJ
    trigger OnRun()
    begin

    end;

    procedure InitTrackingSpecification(VAR PurchLine: Record "Purchase Line"; VAR TrackingSpecification: Record "Tracking Specification")
    var

        lcduCWMgt: Codeunit "Rebate Sales Functions ELA";
        lrfRecordRef: RecordRef;
        ldecTotalNet: Decimal;
        ldecToShipRecNet: Decimal;
        ldecShippedReceivedNet: Decimal;
        ldecToInvoiceNet: Decimal;
        ldecInvoicedNet: Decimal;
    begin


        TrackingSpecification.INIT;
        TrackingSpecification."Source Type" := DATABASE::"Purchase Line";

        TrackingSpecification."Item No." := PurchLine."No.";
        TrackingSpecification."Location Code" := PurchLine."Location Code";
        TrackingSpecification.Description := PurchLine.Description;
        TrackingSpecification."Variant Code" := PurchLine."Variant Code";
        TrackingSpecification."Source Subtype" := PurchLine."Document Type";
        TrackingSpecification."Source ID" := PurchLine."Document No.";
        TrackingSpecification."Source Batch Name" := '';
        TrackingSpecification."Source Prod. Order Line" := 0;
        TrackingSpecification."Source Ref. No." := PurchLine."Line No.";
        TrackingSpecification."Quantity (Base)" := PurchLine."Quantity (Base)";
        TrackingSpecification."Qty. to Invoice (Base)" := PurchLine."Qty. to Invoice (Base)";
        TrackingSpecification."Qty. to Invoice" := PurchLine."Qty. to Invoice";
        TrackingSpecification."Quantity Invoiced (Base)" := PurchLine."Qty. Invoiced (Base)";
        TrackingSpecification."Qty. per Unit of Measure" := PurchLine."Qty. per Unit of Measure";
        TrackingSpecification."Bin Code" := PurchLine."Bin Code";

        IF PurchLine."Document Type" IN [PurchLine."Document Type"::"Return Order", PurchLine."Document Type"::"Credit Memo"] THEN BEGIN
            TrackingSpecification."Qty. to Handle (Base)" := PurchLine."Return Qty. to Ship (Base)";
            TrackingSpecification."Quantity Handled (Base)" := PurchLine."Return Qty. Shipped (Base)";
            TrackingSpecification."Qty. to Handle" := PurchLine."Return Qty. to Ship";
        END ELSE BEGIN
            TrackingSpecification."Qty. to Handle (Base)" := PurchLine."Qty. to Receive (Base)";
            TrackingSpecification."Quantity Handled (Base)" := PurchLine."Qty. Received (Base)";
            TrackingSpecification."Qty. to Handle" := PurchLine."Qty. to Receive";
        END;

        //<ENRE1.00>
        TrackingSpecification."Net Weight ELA" := ldecTotalNet;
        TrackingSpecification."Net Weight to Invoice ELA" := ldecToInvoiceNet;
        TrackingSpecification."Net Weight Invoiced ELA" := ldecInvoicedNet;
        TrackingSpecification."Net Weight to Handle ELA" := ldecToShipRecNet;
        TrackingSpecification."Net Weight Handled ELA" := ldecShippedReceivedNet;
        //</ENRE1.00>


    END;


    var
        myInt: Integer;
}