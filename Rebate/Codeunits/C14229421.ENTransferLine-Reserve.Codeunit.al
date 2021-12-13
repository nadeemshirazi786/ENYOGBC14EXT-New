codeunit 14229421 "Transfer Line-Reserve ELA"
{
    // ENRE1.00 2021-09-08 AJ
    trigger OnRun()
    begin

    end;


    procedure InitTrackingSpecification(VAR TransLine: Record "Transfer Line"; VAR TrackingSpecification: Record "Tracking Specification"; VAR AvalabilityDate: Date; Direction: Option Outbound,Inbound)
    begin


        //<ENRE1.00>
        TrackingSpecification."Source Type" := DATABASE::"Transfer Line";

        TrackingSpecification."Item No." := TransLine."Item No.";
        TrackingSpecification.Description := TransLine.Description;
        TrackingSpecification."Variant Code" := TransLine."Variant Code";
        TrackingSpecification."Source Subtype" := Direction;
        TrackingSpecification."Source ID" := TransLine."Document No.";
        TrackingSpecification."Source Batch Name" := '';
        TrackingSpecification."Source Prod. Order Line" := TransLine."Derived From Line No.";
        TrackingSpecification."Source Ref. No." := TransLine."Line No.";
        TrackingSpecification."Quantity (Base)" := TransLine."Quantity (Base)";
        TrackingSpecification."Qty. to Invoice (Base)" := TransLine."Quantity (Base)";
        TrackingSpecification."Qty. to Invoice" := TransLine.Quantity;
        TrackingSpecification."Quantity Invoiced (Base)" := 0;
        TrackingSpecification."Qty. per Unit of Measure" := TransLine."Qty. per Unit of Measure";
        TrackingSpecification."Location Code" := '';
        CASE Direction OF
            Direction::Outbound:
                BEGIN
                    TrackingSpecification."Location Code" := TransLine."Transfer-from Code";
                    TrackingSpecification."Bin Code" := TransLine."Transfer-from Bin Code";
                    TrackingSpecification."Qty. to Handle (Base)" := TransLine."Qty. to Ship (Base)";
                    TrackingSpecification."Qty. to Handle" := TransLine."Qty. to Ship";
                    TrackingSpecification."Quantity Handled (Base)" := TransLine."Qty. Shipped (Base)";
                    AvalabilityDate := TransLine."Shipment Date";
                END;
            Direction::Inbound:
                BEGIN
                    TrackingSpecification."Location Code" := TransLine."Transfer-to Code";
                    TrackingSpecification."Bin Code" := TransLine."Transfer-To Bin Code";
                    TrackingSpecification."Qty. to Handle (Base)" := TransLine."Qty. to Receive (Base)";
                    TrackingSpecification."Qty. to Handle" := TransLine."Qty. to Receive";
                    TrackingSpecification."Quantity Handled (Base)" := TransLine."Qty. Received (Base)";
                    AvalabilityDate := TransLine."Receipt Date";
                END;
        END;
        TrackingSpecification."Net Weight ELA" := 0;
        TrackingSpecification."Net Weight to Invoice ELA" := 0;
        TrackingSpecification."Net Weight Invoiced ELA" := 0;
        TrackingSpecification."Net Weight to Handle ELA" := 0;
        TrackingSpecification."Net Weight Handled ELA" := 0;


        //</ENRE1.00>
    end;

    var
        myInt: Integer;
}