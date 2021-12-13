codeunit 14229402 "Item Charge Assgnt (Purch) ELA"
{
    // ENRE1.00 2021-09-08 AJ
    trigger OnRun()
    begin

    end;

    procedure CreatePurchOrderChargeAssgnt(var precFromPurchOrderLine: Record "Purchase Line"; precItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)")
    var
        lrecItemChargeAssgntPurch2: Record "Item Charge Assignment (Purch)";
        lrecRcptLine: Record "Purch. Rcpt. Line";
        lintNextLine: Integer;
        con001: Text;
        con002: Text;
    begin
        //<ENRE1.00>
        precFromPurchOrderLine.TestField("Job No.", '');
        precFromPurchOrderLine.TestField("Work Center No.", '');

        lintNextLine := precItemChargeAssgntPurch."Line No.";

        lrecItemChargeAssgntPurch2.SetRange("Document Type", precItemChargeAssgntPurch."Document Type");
        lrecItemChargeAssgntPurch2.SetRange("Document No.", precItemChargeAssgntPurch."Document No.");
        lrecItemChargeAssgntPurch2.SetRange("Document Line No.", precItemChargeAssgntPurch."Document Line No.");

        repeat
            if precFromPurchOrderLine."Quantity Received" = precFromPurchOrderLine.Quantity then begin
                //-- line has been fully received so link the item charges to the associated receipt lines
                lrecRcptLine.SetCurrentKey("Order No.", "Order Line No.");

                lrecRcptLine.SetRange("Order No.", precFromPurchOrderLine."Document No.");
                lrecRcptLine.SetRange("Order Line No.", precFromPurchOrderLine."Line No.");

                if not lrecRcptLine.IsEmpty then begin
                    lrecRcptLine.FindSet;

                    repeat
                        if lrecRcptLine.Quantity <> 0 then begin
                            lrecItemChargeAssgntPurch2.SetRange("Applies-to Doc. Type", lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Receipt);
                            lrecItemChargeAssgntPurch2.SetRange("Applies-to Doc. No.", lrecRcptLine."Document No.");
                            lrecItemChargeAssgntPurch2.SetRange("Applies-to Doc. Line No.", lrecRcptLine."Line No.");

                            if not lrecItemChargeAssgntPurch2.FindFirst then begin
                                SetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                                 lrecRcptLine."Order No.",
                                                 lrecRcptLine."Order Line No.");

                                ItemChargeAssgnt.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Receipt,
                                  lrecRcptLine."Document No.", lrecRcptLine."Line No.",
                                  lrecRcptLine."No.", lrecRcptLine.Description, lintNextLine);

                                lintNextLine += 10000;
                            end;
                        end;
                    until lrecRcptLine.Next = 0;
                end else begin
                    Error(con002, precFromPurchOrderLine."Document No.", precFromPurchOrderLine."Line No.");
                end;
            end else
                if (precFromPurchOrderLine."Quantity Received" <> 0) and
                   (precFromPurchOrderLine."Quantity Received" < precFromPurchOrderLine.Quantity) then begin
                    //-- line has been partially received, so link item charges to receipt lines, and remaining to PO line

                    //-- RECEIPT ENTRIES
                    lrecRcptLine.SetCurrentKey("Order No.", "Order Line No.");

                    lrecRcptLine.SetRange("Order No.", precFromPurchOrderLine."Document No.");
                    lrecRcptLine.SetRange("Order Line No.", precFromPurchOrderLine."Line No.");

                    if not lrecRcptLine.IsEmpty then begin
                        lrecRcptLine.FindSet;

                        repeat
                            if lrecRcptLine.Quantity <> 0 then begin
                                lrecItemChargeAssgntPurch2.SetRange("Applies-to Doc. Type", lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Receipt);
                                lrecItemChargeAssgntPurch2.SetRange("Applies-to Doc. No.", lrecRcptLine."Document No.");
                                lrecItemChargeAssgntPurch2.SetRange("Applies-to Doc. Line No.", lrecRcptLine."Line No.");

                                if not lrecItemChargeAssgntPurch2.FindFirst then begin
                                    SetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                                     lrecRcptLine."Order No.",
                                                     lrecRcptLine."Order Line No.");

                                    ItemChargeAssgnt.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Receipt,
                                      lrecRcptLine."Document No.", lrecRcptLine."Line No.",
                                      lrecRcptLine."No.", lrecRcptLine.Description, lintNextLine);

                                    lintNextLine += 10000;
                                end;
                            end;
                        until lrecRcptLine.Next = 0;
                    end else begin
                        Error(con002, precFromPurchOrderLine."Document No.", precFromPurchOrderLine."Line No.");
                    end;

                    //-- PURCHASE ORDER ENTRY
                    lrecItemChargeAssgntPurch2.SetRange("Applies-to Doc. Type", lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order);
                    lrecItemChargeAssgntPurch2.SetRange("Applies-to Doc. No.", precFromPurchOrderLine."Document No.");
                    lrecItemChargeAssgntPurch2.SetRange("Applies-to Doc. Line No.", precFromPurchOrderLine."Line No.");

                    if not lrecItemChargeAssgntPurch2.FindFirst then begin
                        SetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                         precFromPurchOrderLine."Document No.",
                                         precFromPurchOrderLine."Line No.");

                        ItemChargeAssgnt.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                          precFromPurchOrderLine."Document No.", precFromPurchOrderLine."Line No.",
                          precFromPurchOrderLine."No.", precFromPurchOrderLine.Description, lintNextLine);
                    end;
                end else
                    if (precFromPurchOrderLine."Quantity Received" = 0) then begin
                        //-- line has not been received at all yet
                        lrecItemChargeAssgntPurch2.SetRange("Applies-to Doc. Type", lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order);
                        lrecItemChargeAssgntPurch2.SetRange("Applies-to Doc. No.", precFromPurchOrderLine."Document No.");
                        lrecItemChargeAssgntPurch2.SetRange("Applies-to Doc. Line No.", precFromPurchOrderLine."Line No.");

                        if not lrecItemChargeAssgntPurch2.FindFirst then begin
                            SetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                             precFromPurchOrderLine."Document No.",
                                             precFromPurchOrderLine."Line No.");

                            ItemChargeAssgnt.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                               precFromPurchOrderLine."Document No.", precFromPurchOrderLine."Line No.",
                               precFromPurchOrderLine."No.", precFromPurchOrderLine.Description, lintNextLine);
                        end;
                    end;
        until precFromPurchOrderLine.Next = 0;
        //</ENRE1.00>
    end;


    procedure SetOrigDocInfo(poptOrigDocType: Option; pcodOrigDocNo: Code[20]; pintOrigDocLineNo: Integer)
    begin
        //<ENRE1.00>
        goptOrigDocType := poptOrigDocType;
        gcodOrigDocNo := pcodOrigDocNo;
        gintOrigDocLineNo := pintOrigDocLineNo;
        //</ENRE1.00>
    end;

    var
        SuggestItemChargeMsg: Label 'Select how to distribute the assigned item charge when the document has more than one line of type Item.';
        EquallyTok: Label 'Equally';
        ByAmountTok: Label 'By Amount';
        ByWeightTok: Label 'By Weight';
        ByVolumeTok: Label 'By Volume';
        ItemChargesNotAssignedErr: Label 'No item charges were assigned.';
        UOMMgt: Codeunit "Unit of Measure Management";
        goptOrigDocType: Option;
        gcodOrigDocNo: Code[20];
        gintOrigDocLineNo: Integer;

        ItemChargeAssgnt: Codeunit "Item Charge Assgnt. (Purch.)";
}