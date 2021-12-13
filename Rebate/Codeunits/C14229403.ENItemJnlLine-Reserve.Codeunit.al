codeunit 14229403 "Item Jnl. Line-Reserve ELA"
{
    // ENRE1.00 2021-09-08 AJ
    trigger OnRun()
    begin

    end;

    procedure InitTrackingSpecification(VAR ItemJnlLine: Record "Item Journal Line"; VAR TrackingSpecification: Record "Tracking Specification")
    begin


        //<ENRE1.00>
        TrackingSpecification.INIT;
        TrackingSpecification."Source Type" := DATABASE::"Item Journal Line";

        TrackingSpecification."Item No." := ItemJnlLine."Item No.";
        TrackingSpecification."Location Code" := ItemJnlLine."Location Code";
        TrackingSpecification.Description := ItemJnlLine.Description;
        TrackingSpecification."Variant Code" := ItemJnlLine."Variant Code";
        TrackingSpecification."Source Subtype" := ItemJnlLine."Entry Type";
        TrackingSpecification."Source ID" := ItemJnlLine."Journal Template Name";
        TrackingSpecification."Source Batch Name" := ItemJnlLine."Journal Batch Name";
        TrackingSpecification."Source Prod. Order Line" := 0;
        TrackingSpecification."Source Ref. No." := ItemJnlLine."Line No.";
        TrackingSpecification."Quantity (Base)" := ItemJnlLine."Quantity (Base)";
        TrackingSpecification."Qty. to Handle" := ItemJnlLine.Quantity;
        TrackingSpecification."Qty. to Handle (Base)" := ItemJnlLine."Quantity (Base)";
        TrackingSpecification."Qty. to Invoice" := ItemJnlLine.Quantity;
        TrackingSpecification."Qty. to Invoice (Base)" := ItemJnlLine."Quantity (Base)";
        TrackingSpecification."Quantity Handled (Base)" := 0;
        TrackingSpecification."Quantity Invoiced (Base)" := 0;
        TrackingSpecification."Qty. per Unit of Measure" := ItemJnlLine."Qty. per Unit of Measure";
        TrackingSpecification."Bin Code" := ItemJnlLine."Bin Code";
        TrackingSpecification."Net Weight ELA" := 0;
        TrackingSpecification."Net Weight to Invoice ELA" := 0;
        TrackingSpecification."Net Weight Invoiced ELA" := 0;
        TrackingSpecification."Net Weight to Handle ELA" := 0;
        TrackingSpecification."Net Weight Handled ELA" := 0;

    end;

    var
        myInt: Integer;
}