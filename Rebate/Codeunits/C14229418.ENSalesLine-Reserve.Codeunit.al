codeunit 14229418 "Sales Line-Reserve ELA"
{
    // ENRE1.00 2021-09-08 AJ
    trigger OnRun()
    begin

    end;

    procedure InitTrackingSpecification(VAR SalesLine: Record "Sales Line"; VAR TrackingSpecification: Record "Tracking Specification")
    //<ENRE1.00>
    begin


        TrackingSpecification.INIT;
        TrackingSpecification."Source Type" := DATABASE::"Sales Line";

        TrackingSpecification."Item No." := SalesLine."No.";
        TrackingSpecification."Location Code" := SalesLine."Location Code";
        TrackingSpecification.Description := SalesLine.Description;
        TrackingSpecification."Variant Code" := SalesLine."Variant Code";
        TrackingSpecification."Source Subtype" := SalesLine."Document Type";
        TrackingSpecification."Source ID" := SalesLine."Document No.";
        TrackingSpecification."Source Batch Name" := '';
        TrackingSpecification."Source Prod. Order Line" := 0;
        TrackingSpecification."Source Ref. No." := SalesLine."Line No.";
        TrackingSpecification."Quantity (Base)" := SalesLine."Quantity (Base)";
        TrackingSpecification."Qty. to Invoice (Base)" := SalesLine."Qty. to Invoice (Base)";
        TrackingSpecification."Qty. to Invoice" := SalesLine."Qty. to Invoice";
        TrackingSpecification."Quantity Invoiced (Base)" := SalesLine."Qty. Invoiced (Base)";
        TrackingSpecification."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";
        TrackingSpecification."Bin Code" := SalesLine."Bin Code";

        IF SalesLine."Document Type" IN [SalesLine."Document Type"::"Return Order", SalesLine."Document Type"::"Credit Memo"] THEN BEGIN
            TrackingSpecification."Qty. to Handle (Base)" := SalesLine."Return Qty. to Receive (Base)";
            TrackingSpecification."Quantity Handled (Base)" := SalesLine."Return Qty. Received (Base)";
            TrackingSpecification."Qty. to Handle" := SalesLine."Return Qty. to Receive";
        END ELSE BEGIN
            TrackingSpecification."Qty. to Handle (Base)" := SalesLine."Qty. to Ship (Base)";
            TrackingSpecification."Quantity Handled (Base)" := SalesLine."Qty. Shipped (Base)";
            TrackingSpecification."Qty. to Handle" := SalesLine."Qty. to Ship";
        END;
        TrackingSpecification."Net Weight ELA" := 0;
        TrackingSpecification."Net Weight to Invoice ELA" := 0;
        TrackingSpecification."Net Weight Invoiced ELA" := 0;
        TrackingSpecification."Net Weight to Handle ELA" := 0;
        TrackingSpecification."Net Weight Handled ELA" := 0;


    end;
    //</ENRE1.00>
    var
        myInt: Integer;
}