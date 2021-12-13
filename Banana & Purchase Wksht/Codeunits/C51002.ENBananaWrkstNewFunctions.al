codeunit 51002 BananaWrkshtNewFunctions
{
    var
        gblnUseMultiFieldColumnCaption: Boolean;
        gintCaptionFieldNo1: Integer;
        gintCaptionFieldNo2: Integer;
        gintCaptionFieldNo3: Integer;
        gblnUseDateNameCaption: Boolean;
        PostingDate: Date;
        PostingDateExists: Boolean;
        ReplacePostingDate: Boolean;
        ReplaceDocumentDate: Boolean;

    procedure jfCreatePurchOrderChargeAssgnt(VAR precFromPurchOrderLine: Record "Purchase Line"; precItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)")
    var
        lrecItemChargeAssgntPurch2: Record "Item Charge Assignment (Purch)";
        lrecRcptLine: Record "Purch. Rcpt. Line";
        lintNextLine: Integer;
        jfcon001: TextConst;
        jfcon002: TextConst;
    begin
        precFromPurchOrderLine.TESTFIELD("Job No.", '');
        precFromPurchOrderLine.TESTFIELD("Work Center No.", '');

        lintNextLine := precItemChargeAssgntPurch."Line No.";

        lrecItemChargeAssgntPurch2.SETRANGE("Document Type", precItemChargeAssgntPurch."Document Type");
        lrecItemChargeAssgntPurch2.SETRANGE("Document No.", precItemChargeAssgntPurch."Document No.");
        lrecItemChargeAssgntPurch2.SETRANGE("Document Line No.", precItemChargeAssgntPurch."Document Line No.");
        REPEAT

            IF precFromPurchOrderLine."Quantity Received" = precFromPurchOrderLine.Quantity THEN BEGIN
                lrecRcptLine.SETCURRENTKEY("Order No.", "Order Line No.");

                lrecRcptLine.SETRANGE("Order No.", precFromPurchOrderLine."Document No.");
                lrecRcptLine.SETRANGE("Order Line No.", precFromPurchOrderLine."Line No.");

                IF NOT lrecRcptLine.ISEMPTY THEN BEGIN
                    lrecRcptLine.FINDSET;

                    REPEAT
                        IF lrecRcptLine.Quantity <> 0 THEN BEGIN
                            lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Type", lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Receipt);
                            lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. No.", lrecRcptLine."Document No.");
                            lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Line No.", lrecRcptLine."Line No.");

                            IF NOT lrecItemChargeAssgntPurch2.FINDFIRST THEN BEGIN
                                lrecItemChargeAssgntPurch2.jfSetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                                lrecRcptLine."Order No.",
                                                lrecRcptLine."Order Line No.");

                                lrecItemChargeAssgntPurch2.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Receipt,
                                lrecRcptLine."Document No.", lrecRcptLine."Line No.",
                                lrecRcptLine."No.", lrecRcptLine.Description, lintNextLine);

                                lintNextLine += 10000;
                            END;
                        END;
                    UNTIL lrecRcptLine.NEXT = 0;
                END ELSE BEGIN
                    ERROR(jfcon002, precFromPurchOrderLine."Document No.", precFromPurchOrderLine."Line No.");
                END;
            END ELSE
                IF (precFromPurchOrderLine."Quantity Received" <> 0) AND
                   (precFromPurchOrderLine."Quantity Received" < precFromPurchOrderLine.Quantity) THEN BEGIN
                    lrecRcptLine.SETCURRENTKEY("Order No.", "Order Line No.");

                    lrecRcptLine.SETRANGE("Order No.", precFromPurchOrderLine."Document No.");
                    lrecRcptLine.SETRANGE("Order Line No.", precFromPurchOrderLine."Line No.");

                    IF NOT lrecRcptLine.ISEMPTY THEN BEGIN
                        lrecRcptLine.FINDSET;

                        REPEAT
                            IF lrecRcptLine.Quantity <> 0 THEN BEGIN
                                lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Type", lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Receipt);
                                lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. No.", lrecRcptLine."Document No.");
                                lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Line No.", lrecRcptLine."Line No.");

                                IF NOT lrecItemChargeAssgntPurch2.FINDFIRST THEN BEGIN
                                    lrecItemChargeAssgntPurch2.jfSetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                                    lrecRcptLine."Order No.",
                                                    lrecRcptLine."Order Line No.");

                                    lrecItemChargeAssgntPurch2.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Receipt,
                                    lrecRcptLine."Document No.", lrecRcptLine."Line No.",
                                    lrecRcptLine."No.", lrecRcptLine.Description, lintNextLine);

                                    lintNextLine += 10000;
                                END;
                            END;
                        UNTIL lrecRcptLine.NEXT = 0;
                    END ELSE BEGIN
                        ERROR(jfcon002, precFromPurchOrderLine."Document No.", precFromPurchOrderLine."Line No.");
                    END;
                    lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Type", lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order);
                    lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. No.", precFromPurchOrderLine."Document No.");
                    lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Line No.", precFromPurchOrderLine."Line No.");

                    IF NOT lrecItemChargeAssgntPurch2.FINDFIRST THEN BEGIN
                        lrecItemChargeAssgntPurch2.jfSetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                        precFromPurchOrderLine."Document No.",
                                        precFromPurchOrderLine."Line No.");

                        lrecItemChargeAssgntPurch2.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                            precFromPurchOrderLine."Document No.", precFromPurchOrderLine."Line No.",
                            precFromPurchOrderLine."No.", precFromPurchOrderLine.Description, lintNextLine);
                    END;
                END ELSE
                    IF (precFromPurchOrderLine."Quantity Received" = 0) THEN BEGIN
                        lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Type", lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order);
                        lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. No.", precFromPurchOrderLine."Document No.");
                        lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Line No.", precFromPurchOrderLine."Line No.");

                        IF NOT lrecItemChargeAssgntPurch2.FINDFIRST THEN BEGIN
                            lrecItemChargeAssgntPurch2.jfSetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                            precFromPurchOrderLine."Document No.",
                                            precFromPurchOrderLine."Line No.");

                            lrecItemChargeAssgntPurch2.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                precFromPurchOrderLine."Document No.", precFromPurchOrderLine."Line No.",
                                precFromPurchOrderLine."No.", precFromPurchOrderLine.Description, lintNextLine);
                        END;
                    END;
        UNTIL precFromPurchOrderLine.NEXT = 0;
        precFromPurchOrderLine.TESTFIELD("Job No.", '');
        precFromPurchOrderLine.TESTFIELD("Work Center No.", '');

        lintNextLine := precItemChargeAssgntPurch."Line No.";

        lrecItemChargeAssgntPurch2.SETRANGE("Document Type", precItemChargeAssgntPurch."Document Type");
        lrecItemChargeAssgntPurch2.SETRANGE("Document No.", precItemChargeAssgntPurch."Document No.");
        lrecItemChargeAssgntPurch2.SETRANGE("Document Line No.", precItemChargeAssgntPurch."Document Line No.");
        REPEAT

            IF precFromPurchOrderLine."Quantity Received" = precFromPurchOrderLine.Quantity THEN BEGIN
                lrecRcptLine.SETCURRENTKEY("Order No.", "Order Line No.");

                lrecRcptLine.SETRANGE("Order No.", precFromPurchOrderLine."Document No.");
                lrecRcptLine.SETRANGE("Order Line No.", precFromPurchOrderLine."Line No.");

                IF NOT lrecRcptLine.ISEMPTY THEN BEGIN
                    lrecRcptLine.FINDSET;

                    REPEAT
                        IF lrecRcptLine.Quantity <> 0 THEN BEGIN
                            lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Type", lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Receipt);
                            lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. No.", lrecRcptLine."Document No.");
                            lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Line No.", lrecRcptLine."Line No.");

                            IF NOT lrecItemChargeAssgntPurch2.FINDFIRST THEN BEGIN
                                lrecItemChargeAssgntPurch2.jfSetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                                lrecRcptLine."Order No.",
                                                lrecRcptLine."Order Line No.");

                                lrecItemChargeAssgntPurch2.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Receipt,
                                lrecRcptLine."Document No.", lrecRcptLine."Line No.",
                                lrecRcptLine."No.", lrecRcptLine.Description, lintNextLine);

                                lintNextLine += 10000;
                            END;
                        END;
                    UNTIL lrecRcptLine.NEXT = 0;
                END ELSE BEGIN
                    ERROR(jfcon002, precFromPurchOrderLine."Document No.", precFromPurchOrderLine."Line No.");
                END;
            END ELSE
                IF (precFromPurchOrderLine."Quantity Received" <> 0) AND
                   (precFromPurchOrderLine."Quantity Received" < precFromPurchOrderLine.Quantity) THEN BEGIN
                    lrecRcptLine.SETCURRENTKEY("Order No.", "Order Line No.");

                    lrecRcptLine.SETRANGE("Order No.", precFromPurchOrderLine."Document No.");
                    lrecRcptLine.SETRANGE("Order Line No.", precFromPurchOrderLine."Line No.");

                    IF NOT lrecRcptLine.ISEMPTY THEN BEGIN
                        lrecRcptLine.FINDSET;

                        REPEAT
                            IF lrecRcptLine.Quantity <> 0 THEN BEGIN
                                lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Type", lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Receipt);
                                lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. No.", lrecRcptLine."Document No.");
                                lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Line No.", lrecRcptLine."Line No.");

                                IF NOT lrecItemChargeAssgntPurch2.FINDFIRST THEN BEGIN
                                    lrecItemChargeAssgntPurch2.jfSetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                                    lrecRcptLine."Order No.",
                                                    lrecRcptLine."Order Line No.");

                                    lrecItemChargeAssgntPurch2.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Receipt,
                                    lrecRcptLine."Document No.", lrecRcptLine."Line No.",
                                    lrecRcptLine."No.", lrecRcptLine.Description, lintNextLine);

                                    lintNextLine += 10000;
                                END;
                            END;
                        UNTIL lrecRcptLine.NEXT = 0;
                    END ELSE BEGIN
                        ERROR(jfcon002, precFromPurchOrderLine."Document No.", precFromPurchOrderLine."Line No.");
                    END;
                    lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Type", lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order);
                    lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. No.", precFromPurchOrderLine."Document No.");
                    lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Line No.", precFromPurchOrderLine."Line No.");

                    IF NOT lrecItemChargeAssgntPurch2.FINDFIRST THEN BEGIN
                        lrecItemChargeAssgntPurch2.jfSetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                        precFromPurchOrderLine."Document No.",
                                        precFromPurchOrderLine."Line No.");

                        lrecItemChargeAssgntPurch2.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                            precFromPurchOrderLine."Document No.", precFromPurchOrderLine."Line No.",
                            precFromPurchOrderLine."No.", precFromPurchOrderLine.Description, lintNextLine);
                    END;
                END ELSE
                    IF (precFromPurchOrderLine."Quantity Received" = 0) THEN BEGIN
                        lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Type", lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order);
                        lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. No.", precFromPurchOrderLine."Document No.");
                        lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Line No.", precFromPurchOrderLine."Line No.");

                        IF NOT lrecItemChargeAssgntPurch2.FINDFIRST THEN BEGIN
                            lrecItemChargeAssgntPurch2.jfSetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                            precFromPurchOrderLine."Document No.",
                                            precFromPurchOrderLine."Line No.");

                            lrecItemChargeAssgntPurch2.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                precFromPurchOrderLine."Document No.", precFromPurchOrderLine."Line No.",
                                precFromPurchOrderLine."No.", precFromPurchOrderLine.Description, lintNextLine);
                        END;
                    END;
        UNTIL precFromPurchOrderLine.NEXT = 0;
    end;

    procedure jfCreateSalesOrderChargeAssgnt(VAR precFromSalesOrderLine: Record "Sales Line"; precItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)")

    var
        lrecItemChargeAssgntPurch2: Record "Item Charge Assignment (Purch)";
        lrecShptLine: Record "Sales Shipment Line";
        lintNextLine: Integer;
        jfcon001: TextConst;
        jfcon002: TextConst;
        jfcon003: TextConst;
    begin
        precFromSalesOrderLine.TESTFIELD("Job No.", '');

        lintNextLine := precItemChargeAssgntPurch."Line No.";

        lrecItemChargeAssgntPurch2.SETRANGE("Document Type", precItemChargeAssgntPurch."Document Type");
        lrecItemChargeAssgntPurch2.SETRANGE("Document No.", precItemChargeAssgntPurch."Document No.");
        lrecItemChargeAssgntPurch2.SETRANGE("Document Line No.", precItemChargeAssgntPurch."Document Line No.");

        REPEAT
            IF precFromSalesOrderLine."Quantity Shipped" = precFromSalesOrderLine.Quantity THEN BEGIN
                lrecShptLine.SETCURRENTKEY("Order No.", "Order Line No.");

                lrecShptLine.SETRANGE("Order No.", precFromSalesOrderLine."Document No.");
                lrecShptLine.SETRANGE("Order Line No.", precFromSalesOrderLine."Line No.");

                IF NOT lrecShptLine.ISEMPTY THEN BEGIN
                    lrecShptLine.FINDSET;

                    REPEAT
                        IF lrecShptLine.Quantity <> 0 THEN BEGIN
                            lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Type",
                                                                lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::"Sales Shipment");
                            lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. No.", lrecShptLine."Document No.");
                            lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Line No.", lrecShptLine."Line No.");

                            IF NOT lrecItemChargeAssgntPurch2.FINDFIRST THEN BEGIN
                                lrecItemChargeAssgntPurch2.jfSetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                                lrecShptLine."Order No.",
                                                lrecShptLine."Order Line No.");

                                lrecItemChargeAssgntPurch2.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::"Sales Shipment",
                                lrecShptLine."Document No.", lrecShptLine."Line No.",
                                lrecShptLine."No.", lrecShptLine.Description, lintNextLine);

                                lintNextLine += 10000;
                            END;
                        END;
                    UNTIL lrecShptLine.NEXT = 0;
                END ELSE BEGIN
                    ERROR(jfcon003, precFromSalesOrderLine."Document No.", precFromSalesOrderLine."Line No.");
                END;
            END ELSE
                IF (precFromSalesOrderLine."Quantity Shipped" <> 0) AND
                   (precFromSalesOrderLine."Quantity Shipped" < precFromSalesOrderLine.Quantity) THEN BEGIN
                    lrecShptLine.SETCURRENTKEY("Order No.", "Order Line No.");

                    lrecShptLine.SETRANGE("Order No.", precFromSalesOrderLine."Document No.");
                    lrecShptLine.SETRANGE("Order Line No.", precFromSalesOrderLine."Line No.");

                    IF NOT lrecShptLine.ISEMPTY THEN BEGIN
                        lrecShptLine.FINDSET;

                        REPEAT
                            IF lrecShptLine.Quantity <> 0 THEN BEGIN
                                lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Type",
                                                                    lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::"Sales Shipment");
                                lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. No.", lrecShptLine."Document No.");
                                lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Line No.", lrecShptLine."Line No.");

                                IF NOT lrecItemChargeAssgntPurch2.FINDFIRST THEN BEGIN
                                    lrecItemChargeAssgntPurch2.jfSetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                                    lrecShptLine."Order No.",
                                                    lrecShptLine."Order Line No.");

                                    lrecItemChargeAssgntPurch2.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::"Sales Shipment",
                                    lrecShptLine."Document No.", lrecShptLine."Line No.",
                                    lrecShptLine."No.", lrecShptLine.Description, lintNextLine);

                                    lintNextLine += 10000;
                                END;
                            END;
                        UNTIL lrecShptLine.NEXT = 0;
                    END ELSE BEGIN
                        ERROR(jfcon003, precFromSalesOrderLine."Document No.", precFromSalesOrderLine."Line No.");
                    END;
                    lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Type", lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order);
                    lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. No.", precFromSalesOrderLine."Document No.");
                    lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Line No.", precFromSalesOrderLine."Line No.");

                    IF NOT lrecItemChargeAssgntPurch2.FINDFIRST THEN BEGIN
                        lrecItemChargeAssgntPurch2.jfSetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                        precFromSalesOrderLine."Document No.",
                                        precFromSalesOrderLine."Line No.");

                        lrecItemChargeAssgntPurch2.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                            precFromSalesOrderLine."Document No.", precFromSalesOrderLine."Line No.",
                            precFromSalesOrderLine."No.", precFromSalesOrderLine.Description, lintNextLine);
                    END;
                END ELSE
                    IF (precFromSalesOrderLine."Quantity Shipped" = 0) THEN BEGIN
                        lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Type", lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order);
                        lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. No.", precFromSalesOrderLine."Document No.");
                        lrecItemChargeAssgntPurch2.SETRANGE("Applies-to Doc. Line No.", precFromSalesOrderLine."Line No.");

                        IF NOT lrecItemChargeAssgntPurch2.FINDFIRST THEN BEGIN
                            lrecItemChargeAssgntPurch2.jfSetOrigDocInfo(lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                            precFromSalesOrderLine."Document No.",
                                            precFromSalesOrderLine."Line No.");

                            lrecItemChargeAssgntPurch2.InsertItemChargeAssgnt(precItemChargeAssgntPurch, lrecItemChargeAssgntPurch2."Applies-to Doc. Type"::Order,
                                precFromSalesOrderLine."Document No.", precFromSalesOrderLine."Line No.",
                                precFromSalesOrderLine."No.", precFromSalesOrderLine.Description, lintNextLine);
                        END;
                    END;
        UNTIL precFromSalesOrderLine.NEXT = 0;
    end;

    procedure jfSetMultiFieldColumnCaption(pintFieldNo1: Integer; pintFieldNo2: Integer; pintFieldNo3: Integer)
    var
        myInt: Integer;
    begin
        gblnUseMultiFieldColumnCaption := TRUE;
        gintCaptionFieldNo1 := pintFieldNo1;
        gintCaptionFieldNo2 := pintFieldNo2;
        gintCaptionFieldNo3 := pintFieldNo3;
    end;

    procedure SetPostingDate(NewReplacePostingDate: Boolean; NewReplaceDocumentDate: Boolean; NewPostingDate: Date)

    begin
        PostingDateExists := TRUE;
        ReplacePostingDate := NewReplacePostingDate;
        ReplaceDocumentDate := NewReplaceDocumentDate;
        PostingDate := NewPostingDate;
    end;

    procedure GenerateMatrixData(VAR RecRef: RecordRef; SetWanted: Enum SetWanted; MaximumSetLength: Integer; CaptionFieldNo: Integer; VAR PKFirstRecInCurrSet: Text[1024]; VAR CaptionSet: ARRAY[32] OF Text[1024]; VAR CaptionRange: Text[1024]; var CurrSetLength: Integer)
    var
        ltxtColumnCaption: Text[1024];
        Steps: Integer;
        Text001: TextConst ENU = 'The previous column set could not be found.';
    begin
        CLEAR(CaptionSet);
        CaptionRange := '';
        CurrSetLength := 0;

        IF RecRef.ISEMPTY THEN BEGIN
            PKFirstRecInCurrSet := '';
            EXIT;
        END;

        CASE SetWanted OF
            SetWanted::Initial:
                RecRef.FINDFIRST;
            SetWanted::Previous:
                BEGIN
                    RecRef.SETPOSITION(PKFirstRecInCurrSet);
                    RecRef.GET(RecRef.RECORDID);
                    Steps := RecRef.NEXT(-MaximumSetLength);
                    IF NOT (Steps IN [-MaximumSetLength, 0]) THEN
                        ERROR(Text001);
                END;
            SetWanted::Same:
                BEGIN
                    RecRef.SETPOSITION(PKFirstRecInCurrSet);
                    RecRef.GET(RecRef.RECORDID);
                END;
            SetWanted::Next:
                BEGIN
                    RecRef.SETPOSITION(PKFirstRecInCurrSet);
                    RecRef.GET(RecRef.RECORDID);
                    IF NOT (RecRef.NEXT(MaximumSetLength) = MaximumSetLength) THEN BEGIN
                        RecRef.SETPOSITION(PKFirstRecInCurrSet);
                        RecRef.GET(RecRef.RECORDID);
                    END;
                END;
            SetWanted::PreviousColumn:
                BEGIN
                    RecRef.SETPOSITION(PKFirstRecInCurrSet);
                    RecRef.GET(RecRef.RECORDID);
                    Steps := RecRef.NEXT(-1);
                    IF NOT (Steps IN [-1, 0]) THEN
                        ERROR(Text001);
                END;
            SetWanted::NextColumn:
                BEGIN
                    RecRef.SETPOSITION(PKFirstRecInCurrSet);
                    RecRef.GET(RecRef.RECORDID);
                    IF NOT (RecRef.NEXT(1) = 1) THEN BEGIN
                        RecRef.SETPOSITION(PKFirstRecInCurrSet);
                        RecRef.GET(RecRef.RECORDID);
                    END;
                END;
        END;

        PKFirstRecInCurrSet := RecRef.GETPOSITION;

        REPEAT
            CurrSetLength := CurrSetLength + 1;
            IF gblnUseMultiFieldColumnCaption THEN BEGIN
                ltxtColumnCaption := jfGetFieldCaptionValue(RecRef, gintCaptionFieldNo1);

                IF gintCaptionFieldNo2 <> 0 THEN
                    ltxtColumnCaption += ' (' + jfGetFieldCaptionValue(RecRef, gintCaptionFieldNo2) + ')';

                IF gintCaptionFieldNo3 <> 0 THEN
                    ltxtColumnCaption += ' (' + jfGetFieldCaptionValue(RecRef, gintCaptionFieldNo3) + ')';
            END ELSE BEGIN
                ltxtColumnCaption := jfGetFieldCaptionValue(RecRef, CaptionFieldNo);
            END;

            CaptionSet[CurrSetLength] := ltxtColumnCaption;
        UNTIL (CurrSetLength = MaximumSetLength) OR (RecRef.NEXT <> 1);

        IF CurrSetLength = 1 THEN
            CaptionRange := CaptionSet[1]
        ELSE
            CaptionRange := CaptionSet[1] + '..' + CaptionSet[CurrSetLength];
    end;

    procedure jfGetFieldCaptionValue(VAR prrfRecRef: RecordRef; pintFieldNo: Integer): Text
    var
        lfrfFieldRef: FieldRef;
        loptFieldClass: Enum JFFieldClass;
    begin
        lfrfFieldRef := prrfRecRef.FIELD(pintFieldNo);
        EVALUATE(loptFieldClass, FORMAT(lfrfFieldRef.CLASS));

        IF loptFieldClass = loptFieldClass::Flowfield THEN
            lfrfFieldRef.CALCFIELD;

        EXIT(FORMAT(lfrfFieldRef.VALUE));
    end;
}

