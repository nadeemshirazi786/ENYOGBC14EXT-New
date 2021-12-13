codeunit 14229405 "Prod. Order Line-Reserve ELA"
{
    // ENRE1.00 2021-09-08 AJ
    trigger OnRun()
    begin

    end;

    procedure InitTrackingSpecification(VAR ProdOrderLine: Record "Prod. Order Line"; VAR TrackingSpecification: Record "Tracking Specification")
    begin


        //<ENRE1.00>
        TrackingSpecification.INIT;
        TrackingSpecification."Source Type" := DATABASE::"Prod. Order Line";

        TrackingSpecification."Item No." := ProdOrderLine."Item No.";
        TrackingSpecification."Location Code" := ProdOrderLine."Location Code";
        TrackingSpecification.Description := ProdOrderLine.Description;
        TrackingSpecification."Variant Code" := ProdOrderLine."Variant Code";
        TrackingSpecification."Source Subtype" := ProdOrderLine.Status;
        TrackingSpecification."Source ID" := ProdOrderLine."Prod. Order No.";
        TrackingSpecification."Source Batch Name" := '';
        TrackingSpecification."Source Prod. Order Line" := ProdOrderLine."Line No.";
        TrackingSpecification."Source Ref. No." := 0;
        TrackingSpecification."Quantity (Base)" := ProdOrderLine."Quantity (Base)";
        TrackingSpecification."Qty. to Handle" := ProdOrderLine."Remaining Quantity";
        TrackingSpecification."Qty. to Handle (Base)" := ProdOrderLine."Remaining Qty. (Base)";
        TrackingSpecification."Qty. to Invoice" := ProdOrderLine."Remaining Quantity";
        TrackingSpecification."Qty. to Invoice (Base)" := ProdOrderLine."Remaining Qty. (Base)";
        TrackingSpecification."Quantity Handled (Base)" := ProdOrderLine."Finished Qty. (Base)";
        TrackingSpecification."Quantity Invoiced (Base)" := ProdOrderLine."Finished Qty. (Base)";
        TrackingSpecification."Qty. per Unit of Measure" := ProdOrderLine."Qty. per Unit of Measure";

        TrackingSpecification."Net Weight ELA" := 0;
        TrackingSpecification."Net Weight to Invoice ELA" := 0;
        TrackingSpecification."Net Weight Invoiced ELA" := 0;
        TrackingSpecification."Net Weight to Handle ELA" := 0;
        TrackingSpecification."Net Weight Handled ELA" := 0;
    END;
    //</ENRE1.00>
    var
        myInt: Integer;
}