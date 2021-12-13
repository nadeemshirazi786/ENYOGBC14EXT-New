codeunit 14228881 "DSD Route Template Mgmt. ELA"
{
    trigger OnRun()
    begin

    end;

    procedure ApplyDSDTemplateLocation(VAR precSalesHeader: Record "Sales Header")
    var
        lrecDSDTemplateStop: Record "DSD Route Stop Tmplt. Detail";
        lrecDSDSetup: Record "DSD Setup";
        lrecOrder: Record "Sales Header";
        ldatDateToUse: Date;
    begin
        lrecDSDSetup.GET;
        IF lrecDSDSetup."Orders Use Template Route" THEN BEGIN
            // if there's already an order on this date with a location, use that

            lrecOrder.SETCURRENTKEY("Shipment Date",
                                    "Location Code", "Sell-to Customer No.");
            lrecOrder.SETRANGE("Shipment Date", precSalesHeader."Shipment Date");

            IF NOT lrecDSDSetup."Override Loc. from Route Temp." THEN BEGIN
                lrecOrder.SETFILTER("Location Code", '=%1', precSalesHeader."Location Code");
            END ELSE BEGIN
                lrecOrder.SETRANGE("Location Code");
            END;

            lrecOrder.SETRANGE("Sell-to Customer No.", precSalesHeader."Sell-to Customer No.");

            lrecOrder.SETFILTER("Ship-to Code", '=%1', precSalesHeader."Ship-to Code");

            lrecOrder.SETRANGE("Document Type", lrecOrder."Document Type"::Order);
            lrecOrder.SETFILTER("Standing Order Status", '<>%1', lrecOrder."Standing Order Status"::" ");
            IF precSalesHeader."Document Type" = precSalesHeader."Document Type"::Order THEN BEGIN
                lrecOrder.SETFILTER("No.", '<>%1', precSalesHeader."No.");
            END;
            IF lrecOrder.FINDFIRST THEN BEGIN

                IF lrecDSDSetup."Override Loc. from Route Temp." THEN BEGIN
                    precSalesHeader.VALIDATE("Location Code", lrecOrder."Location Code");
                END ELSE BEGIN
                    precSalesHeader.VALIDATE("Order Template Location ELA", lrecOrder."Order Template Location ELA");
                END;

                precSalesHeader."Route Stop Sequence" := lrecOrder."Route Stop Sequence";
                precSalesHeader."Standing Order Status" := precSalesHeader."Standing Order Status"::Special;
                EXIT;
            END;

            ldatDateToUse := precSalesHeader."Shipment Date";
            IF (ldatDateToUse = 0D) AND ((precSalesHeader."Document Type" = precSalesHeader."Document Type"::"Credit Memo")
                                     OR (precSalesHeader."Document Type" = precSalesHeader."Document Type"::"Return Order")) THEN BEGIN
                ldatDateToUse := precSalesHeader."Document Date";
            END;


            IF NOT FindDSDTemplateStop(lrecDSDTemplateStop,
                                        precSalesHeader."Sell-to Customer No.",
                                        ldatDateToUse,
                                        precSalesHeader."Location Code",
                                        precSalesHeader."Ship-to Code",
                                        FALSE
                                        )
            THEN BEGIN
                IF lrecDSDSetup."Override Loc. from Route Temp." THEN BEGIN
                    precSalesHeader.VALIDATE("Location Code", lrecDSDSetup."Unassigned Location Code");
                END;
                precSalesHeader.VALIDATE("Order Template Location ELA", lrecDSDSetup."Unassigned Location Code");
                precSalesHeader."Standing Order Status" := precSalesHeader."Standing Order Status"::Special;
                precSalesHeader."Route Stop Sequence" := 0;
                EXIT;
            END;

            precSalesHeader.VALIDATE("Order Template Location ELA", lrecDSDTemplateStop.Route);

            IF lrecDSDSetup."Override Loc. from Route Temp." THEN BEGIN

                precSalesHeader.VALIDATE("Location Code", lrecDSDTemplateStop.Route);
            END;
            precSalesHeader."Standing Order Status" := precSalesHeader."Standing Order Status"::Special;
            precSalesHeader."Route Stop Sequence" := lrecDSDTemplateStop."Line No.";
        END;
    end;

    procedure FindDSDTemplateStop(VAR precDSDTemplateStop: Record "DSD Route Stop Tmplt. Detail"; pcodCustomer: Code[20]; pdatDate: Date; pcodLocation: Code[10]; pcodShipTo: Code[10]; pblnExactMatch: Boolean) pbln: Boolean
    var
        lintWeekday: Integer;
    begin
        precDSDTemplateStop.SETCURRENTKEY("Customer No.", "Start Date", "End Date", Weekday);

        precDSDTemplateStop.SETRANGE("Customer No.", pcodCustomer);
        precDSDTemplateStop.SETFILTER("Start Date", '<=%1', pdatDate);
        precDSDTemplateStop.SETFILTER("End Date", '>=%1', pdatDate);

        lintWeekday := DATE2DWY(pdatDate, 1);

        precDSDTemplateStop.SETRANGE(Weekday, lintWeekday);

        grecDSDSetup.GET;

        IF pblnExactMatch THEN BEGIN
            IF (NOT grecDSDSetup."Override Loc. from Route Temp.") THEN BEGIN
                precDSDTemplateStop.SETFILTER("Location Code", '=%1', pcodLocation);
            END ELSE BEGIN
                precDSDTemplateStop.SETRANGE("Location Code");
            END;
            precDSDTemplateStop.SETFILTER("Ship-to Code", '=%1', pcodShipTo);

            EXIT(precDSDTemplateStop.FINDFIRST);
        END;

        IF pcodShipTo <> '' THEN BEGIN

            // 1. look for { Customer, Location, Ship-to } first, otherwise find { Customer, BLANK, Ship-to }
            // (in "Override Loc. from Route Temp." environments, skip Location dimension)

            // { Customer, Location, Ship-to }
            IF (NOT grecDSDSetup."Override Loc. from Route Temp.")
            AND (pcodLocation <> '') THEN BEGIN
                precDSDTemplateStop.SETRANGE("Location Code", pcodLocation);
                precDSDTemplateStop.SETRANGE("Ship-to Code", pcodShipTo);
                IF precDSDTemplateStop.FINDFIRST THEN BEGIN
                    EXIT(TRUE);
                END;
            END;

            // { Customer, BLANK, Ship-to }
            precDSDTemplateStop.SETFILTER("Location Code", '=%1', '');
            precDSDTemplateStop.SETRANGE("Ship-to Code", pcodShipTo);
            IF precDSDTemplateStop.FINDFIRST THEN BEGIN
                EXIT(TRUE);
            END;
        END;

        IF (pcodLocation <> '') AND (NOT grecDSDSetup."Override Loc. from Route Temp.") THEN BEGIN

            // 2. look for { Customer, Location, BLANK }
            // (non-"Orders Use Template Route" environments)

            precDSDTemplateStop.SETRANGE("Location Code", pcodLocation);
            precDSDTemplateStop.SETFILTER("Ship-to Code", '=%1', '');
            IF precDSDTemplateStop.FINDFIRST THEN BEGIN
                EXIT(TRUE);
            END;

        END;

        // 3. look for { Customer, BLANK, BLANK }

        precDSDTemplateStop.SETFILTER("Location Code", '=%1', '');
        precDSDTemplateStop.SETFILTER("Ship-to Code", '=%1', '');

        EXIT(precDSDTemplateStop.FINDFIRST);
    end;

    var
        grecDSDSetup: Record "DSD Setup";
}