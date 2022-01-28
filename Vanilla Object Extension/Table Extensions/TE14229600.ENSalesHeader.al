tableextension 14229600 "EN Sales Header ELA" extends "Sales Header"
{
    fields
    {
        field(14229400; "SalesProfit Modifier Amt ELA"; Decimal)
        {
            CalcFormula = Sum("Sales Profit Modifier ELA".Amount WHERE("Document Type" = FIELD("Document Type"),
                                                                    "Document No." = FIELD("No."),
                                                                    "Source Type" = FIELD("SalesProfit Mod Typ Filter ELA")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
            Caption = 'Sales Profit Modifier Amount';
        }
        field(14229401; "SalesProfit Mod Typ Filter ELA"; Option)
        {
            Caption = 'Sales Profit Modifier Type Filter';
            Description = 'ENRE1.00';
            FieldClass = FlowFilter;
            OptionCaption = 'Purchase Rebate';
            OptionMembers = "Purchase Rebate";
        }
        field(14229403; "Bypass Rebate Calculation ELA"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Caption = 'Bypass Rebate Calculation';
        }
        field(14228850; "Price List Group Code ELA"; Code[20])
        {
            Caption = 'Price List Group Code';
            TableRelation = "EN Price List Group";
            DataClassification = ToBeClassified;

        }
        field(14228851; "Pallet Code ELA"; Code[10])
        {
            //TableRelation = "EN Container Type";
            Caption = 'Pallet Code';

        }
        field(14228852; "Bypass Surcharge Calc ELA"; Boolean)
        {
            Caption = 'Bypass Surcharge Calculation';
        }
        field(14228853; "Lock Pricing ELA"; Boolean)
        {
            Caption = 'Lock Pricing';
        }
        field(14228854; "Order Rule Group ELA"; Code[20])
        {
            Caption = 'Order Rule Group';
            TableRelation = "EN Order Rule Group";
        }
        field(14228855; "Bypass Order Rules ELA"; Boolean)
        {
            Caption = 'Bypass Order Rules';
        }
        field(14228880; "Source Type ELA"; Integer)
        {
            Caption = 'Source Type';
            NotBlank = true;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(14228881; "Source Subtype ELA"; Enum "EN Source Subtype")
        {
            Caption = 'Source Subtype';

        }
        field(14228882; "Source ID ELA"; Code[20])
        {
            Caption = 'Source ID';
        }
        field(14228883; "Authorized Amount ELA"; Decimal)
        {
            Caption = 'Authorized Amount';

        }
        field(14228884; "Authorized User ELA"; Code[20])
        {
            Caption = 'Authorized User';

        }

        field(14228885; "Cash vs Amount Incld Tax ELA"; Decimal)
        {
            Caption = 'Cash vs Amount Including Tax';
        }
        field(14228886; "Created By ELA"; Code[50])
        {
            Caption = 'Created By';

        }
        field(14228887; "Cash Applied (Other) ELA"; Decimal)
        {
            Caption = 'Cash Applied (Other)';
        }
        field(14228888; "Cash Applied (Current) ELA"; Decimal)
        {
            Caption = 'Cash Applied (Current)';
        }
        field(14228889; "Cash Tendered ELA"; Decimal)
        {
            Caption = 'Cash Tendered';
        }
        field(14228890; "Entered Amount to Apply ELA"; Decimal)
        {
            Caption = 'Entered Amount to Apply';
            Editable = true;
        }
        field(14228891; "Change Due ELA"; Decimal)
        {
            Caption = 'Change Due';
        }
        field(14228892; "Stop Arrival Time ELA"; Time)
        {
            Caption = 'Stop Arrival Time';

        }
        field(14228893; "Non-Commissionable ELA"; Boolean)
        {
            Caption = 'Non-Commissionable';


            trigger OnValidate()
            var

            begin
                UpdateSalesLinesELA(FieldCaption("Non-Commissionable ELA"));
            end;
        }
        field(14228894; "Approved By ELA"; Code[50])
        {
            Caption = 'Approved By';
            Editable = false;
        }
        field(14228895; "Approval Status ELA"; Enum "EN Approved Status")
        {
            Caption = 'Approval Status';
            Editable = false;

        }
        field(14228896; "Cash & Carry ELA"; Boolean)
        {
            Caption = 'Cash & Carry';
            DataClassification = ToBeClassified;
        }
        field(14228897; "Order Template Location ELA"; Code[10])
        {
            Caption = 'Order Template Location';
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(14228898; "Backorder Tolerance % ELA"; Decimal)
        {
            Caption = 'Backorder Tolerance %';
            DecimalPlaces = 0 : 5;
            BlankZero = true;
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                lrecSalesLine: Record "Sales Line";
                gjfText034: TextConst ENU = 'Backorder Tolerance % was changed. Do you want to update the lines?';
            begin
                IF "Backorder Tolerance % ELA" <> xRec."Backorder Tolerance % ELA" THEN BEGIN
                    lrecSalesLine.SETRANGE(lrecSalesLine."Document Type", "Document Type"::Order);
                    lrecSalesLine.SETRANGE(lrecSalesLine."Document No.", "No.");
                    IF NOT lrecSalesLine.ISEMPTY THEN
                        IF CONFIRM(gjfText034, TRUE) THEN
                            jfUpdateBackorderTolerance
                END;
            end;
        }
        field(14228900; "Supply Chain Group Code ELA"; Code[10])
        {
            Caption = 'Supply Chain Group Code';
            DataClassification = ToBeClassified;
        }
        field(14228901; "Delivery Route No. ELA"; Code[20])
        {
            Caption = 'Delivery Route No.';
            DataClassification = ToBeClassified;
        }
        field(14228902; "Cash Drawer No. ELA"; Code[20])
        {
            Caption = 'Cash Drawer No.';
            DataClassification = ToBeClassified;
        }
        field(14228903; "Terminal Market SO ELA"; Boolean)
        {
            Caption = 'Terminal Market SO';
            DataClassification = ToBeClassified;
        }
        field(51000; "Route Stop Sequence"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(51001; "No. Pallets"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(51003; "Standing Order Status"; Enum SHeaderOrderStatus)
        {
            DataClassification = ToBeClassified;
        }
        field(14229601; "Logistics Route No. ELA"; Code[20])
        {
            Caption = 'Logistics Route No.';
            DataClassification = ToBeClassified;
            // TableRelation="Logistics Route"
        }
        field(14229602; "Inquiry Tracking No. ELA"; Code[20])
        {
            Caption = 'Inquiry Tracking No.';
            DataClassification = ToBeClassified;
            //TableRelation="Inquiry Tracking".No.;
        }
        field(14228800; "Communication Group Code ELA"; Code[20])
        {
            TableRelation = "Communication Group ELA"."Code";
            DataClassification = ToBeClassified;
            Caption = 'Communication Group Code';
        }
        field(14228831; "Warehouse Shipment Exists ELA"; Boolean)
        {
            Caption = 'Warehouse Shipment Exists';
            FieldClass = FlowField;
            CalcFormula = Exist("Warehouse Shipment Line" WHERE("Source Type" = FILTER(37), "Source Subtype" = FIELD("Document Type"), "Source No." = FIELD("No."), "Location Code" = FIELD("Location Filter")));
        }
        field(14228832; "Date Order Created ELA"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'Date Order Created';
        }
        field(14228833; "Delivery Zone Code ELA"; Code[20])
        {
            TableRelation = "Delivery Zone ELA".Code;
            Caption = 'Delivery Zone Code';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                lrecDeliveryZone: Record "Delivery Zone ELA";
            begin
                TESTFIELD(Status, Status::Open);

                IF "Delivery Zone Code ELA" <> '' THEN BEGIN
                    lrecDeliveryZone.GET("Delivery Zone Code ELA");
                    lrecDeliveryZone.TESTFIELD(Type, lrecDeliveryZone.Type::Standard);
                END;

                //IF xRec."Delivery Zone Code ELA" <> "Delivery Zone Code ELA" THEN
                //  RecreateSalesLines(FIELDCAPTION("Delivery Zone Code ELA"));
            end;
        }
        field(14229634; "Shipping Instructions ELA"; Text[80])
        {
            Caption = 'Shipping Instructions';
            DataClassification = ToBeClassified;
        }
        field(14228835; "Seal No. ELA"; Code[20])
        {
            Caption = 'Amt. to Collect';
            DataClassification = ToBeClassified;
        }
        modify("Posting Date")
        {
            trigger OnAfterValidate()
            begin
                CustItemChargeMgt.AddOrderSurcharges(Rec, FALSE);
            end;
        }
        modify("Ship-to Code")
        {
            trigger OnAfterValidate()
            var
                lcduDSDTemplateMgmt: Codeunit "DSD Route Template Mgmt. ELA";
                ShipToAddr: Record "Ship-to Address";
            begin
                CustItemChargeMgt.AddOrderSurcharges(Rec, FALSE);
                "Delivery Zone Code ELA" := ShipToAddr."Delivery Zone Code ELA";
                "Shipping Instructions ELA" := ShipToAddr."Shipping Instructions ELA";
                IF ShipToAddr."Backorder Tolerance % ELA" <> 0 THEN
                    VALIDATE("Backorder Tolerance % ELA", ShipToAddr."Backorder Tolerance % ELA")
                ELSE BEGIN
                    GetCust("Sell-to Customer No.");
                    VALIDATE("Backorder Tolerance % ELA", Cust."Backorder Tolerance % ELA");
                END;
                UpdateOrderRuleGroup;

                IF (("Document Type" = "Document Type"::Order) OR ("Document Type" = "Document Type"::"Credit Memo") OR ("Document Type" = "Document Type"::"Return Order"))//<PD31395MK>
                AND ("Sell-to Customer No." <> '') THEN BEGIN
                    Cust.GET("Sell-to Customer No.");
                    IF Cust."Direct Store Delivery" THEN BEGIN
                        IF (grecDSDSetup.GET) THEN BEGIN
                            IF (grecDSDSetup."Orders Use Template Route") THEN BEGIN
                                IF (NOT gblnDSDBypassRouteTemplate) THEN BEGIN
                                    lcduDSDTemplateMgmt.ApplyDSDTemplateLocation(Rec);
                                END;
                            END;
                        END;
                    END;
                END;
                "Shipping Instructions ELA" := Cust."Shipping Instructions ELA";
                "Delivery Zone Code ELA" := Cust."Delivery Zone Code ELA";

                IF Cust."Backorder Tolerance % ELA" <> 0 THEN
                    VALIDATE("Backorder Tolerance % ELA", Cust."Backorder Tolerance % ELA");

            end;
        }
        modify("Sell-to Customer No.")
        {
            trigger OnAfterValidate()
            var
                lcduDSDTemplateMgmt: Codeunit "DSD Route Template Mgmt. ELA";
				Customer: Record Customer;
                WMSTripLoadMgmt: Codeunit "WMS Trip Load Mgmt. ELA";
                TripLoadOrder: Record "Trip Load Order ELA";
                TEXT14229200: Label 'Cannot validate user';
            begin
                GetCust("Sell-to Customer No.");
                IF Cust."Order Rule Usage ELA" = Cust."Order Rule Usage ELA"::None THEN
                    "Bypass Order Rules ELA" := TRUE;
                UpdateOrderRuleGroup;

                IF (("Document Type" = "Document Type"::Order) OR ("Document Type" = "Document Type"::"Credit Memo") OR ("Document Type" = "Document Type"::"Return Order"))//<PD31395MK>
                AND ("Sell-to Customer No." <> '') THEN BEGIN
                    Cust.GET("Sell-to Customer No.");
                    IF Cust."Direct Store Delivery" THEN BEGIN
                        IF (grecDSDSetup.GET) THEN BEGIN
                            IF (grecDSDSetup."Orders Use Template Route") THEN BEGIN
                                IF (NOT gblnDSDBypassRouteTemplate) THEN BEGIN
                                    lcduDSDTemplateMgmt.ApplyDSDTemplateLocation(Rec);
                                END;
                            END;
                        END;
                    END;
                END;
                "Delivery Zone Code ELA" := Cust."Delivery Zone Code ELA";
                "Shipping Instructions ELA" := Cust."Shipping Instructions ELA";
				
				if Customer.get("Sell-to Customer No.") then begin
                    if customer."Auto. Add to Outbound Load ELA" then begin
                        UpdateRouteCode();
                        "Stop No. ELA" := customer."Default Stop No. ELA";
                    end else begin
                        clear("Route No. ELA");
                        clear("Stop No. ELA");
                    end;
                end else
                    Error(TEXT14229200);
            end;
        }
        modify("Shipment Date")
        {
            trigger OnAfterValidate()
            var
                lcduDSDTemplateMgmt: Codeunit "DSD Route Template Mgmt. ELA";
				WMSTripLoadMgmt: Codeunit "WMS Trip Load Mgmt. ELA";
                TripLoadOrder: Record "Trip Load Order ELA";
            begin
                IF (("Document Type" = "Document Type"::Order) OR ("Document Type" = "Document Type"::"Credit Memo") OR ("Document Type" = "Document Type"::"Return Order"))//<PD31395MK>
                AND ("Sell-to Customer No." <> '') THEN BEGIN
                    Cust.GET("Sell-to Customer No.");
                    IF Cust."Direct Store Delivery" THEN BEGIN
                        IF (grecDSDSetup.GET) THEN BEGIN
                            IF (grecDSDSetup."Orders Use Template Route") THEN BEGIN
                                IF (NOT gblnDSDBypassRouteTemplate) THEN BEGIN
                                    lcduDSDTemplateMgmt.ApplyDSDTemplateLocation(Rec);
                                END;
                            END;
                        END;
                    END;
                END;
				UpdateRouteCode();
                if ((xrec."Shipment Date" <> rec."Shipment Date") and (rec."Trip No. ELA" <> '')) then begin
                    IF TripLoadOrder.get(rec."Trip No. ELA", TripLoadOrder.Direction::Outbound,
                        TripLoadOrder."Source Document Type"::"Sales Order", rec."No.") THEN begin
                        WMSTripLoadMgmt.RemoveOrderFromTrip("Trip No. ELA", TripLoadOrder.Direction::Outbound,
                                                 TripLoadOrder."Source Document Type"::"Sales Order", "No.");
                        clear("Trip No. ELA");
                    end;
                end;
            end;
        }
        modify("Location Code")
        {
            trigger OnAfterValidate()
            var
                lcduDSDTemplateMgmt: Codeunit "DSD Route Template Mgmt. ELA";
            begin
                IF (("Document Type" = "Document Type"::Order) OR ("Document Type" = "Document Type"::"Credit Memo") OR ("Document Type" = "Document Type"::"Return Order"))//<PD31395MK>
                AND ("Sell-to Customer No." <> '') THEN BEGIN
                    Cust.GET("Sell-to Customer No.");
                    IF Cust."Direct Store Delivery" THEN BEGIN
                        IF (grecDSDSetup.GET) THEN BEGIN
                            IF (grecDSDSetup."Orders Use Template Route") THEN BEGIN
                                IF (NOT gblnDSDBypassRouteTemplate) THEN BEGIN
                                    lcduDSDTemplateMgmt.ApplyDSDTemplateLocation(Rec);
                                END;
                            END;
                        END;
                    END;
                END;
            end;
        }
		field(14229200; "App. User ID ELA"; Code[10])
        {
            Caption = 'App. User ID';
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(14229201; "Route No. ELA"; Code[20])
        {
            Caption = 'Delivery Route No.';
            TableRelation = "Delivery Route ELA";
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                "14229220": Label 'You cannot change route no. after trip is assigned. Please un-link the sales order from trip %1';
            begin
                if ("Trip No. ELA" <> '') then
                    Error(
                        StrSubstNo(
                            "14229220",
                            "Trip No. ELA"));
            end;
        }

        field(14229202; "Stop No. ELA"; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(14229203; "Trip No. ELA"; code[20])
        {
            TableRelation = "Trip Load Order ELA"."Load No."
                where(Direction = const(Outbound), "Source Document Type" = const("Sales Order"));
            Editable = false;
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Source Type ELA", "Source Subtype ELA", "Source ID ELA")
        {

        }

    }

    procedure ibSetUserIDELA()
    var
        CCSalesOrder: Record "Sales Header";
    begin
        IF NOT ("Document Type" IN ["Document Type"::Order, "Document Type"::"Return Order"]) THEN BEGIN
            EXIT;
        END;
        //<<EN1.00
        CCSalesOrder.RESET;
        CCSalesOrder.SETRANGE("Source Type ELA", DATABASE::"Sales Header");
        CCSalesOrder.SETRANGE("Source Subtype ELA", CCSalesOrder."Source Subtype ELA"::"1");
        CCSalesOrder.SETRANGE("Source ID ELA", Rec."No.");
        IF NOT CCSalesOrder.FINDFIRST THEN BEGIN
            "Source Type ELA" := DATABASE::"Sales Header";
            "Source Subtype ELA" := "Source Subtype ELA"::"1";
            "Source ID ELA" := "No.";
            "Created By ELA" := USERID;
            MODIFY();
        END;
        //Commit();
        //>>EN1.00
    end;

    procedure OnSalesPaymentELA(VAR FoundPaymentLine: Record "EN Sales Payment Line"): Boolean
    var
        SalesPaymentLine: Record "EN Sales Payment Line";
    begin
        //<<ENSP1.00
        SalesPaymentLine.SETCURRENTKEY(Type, "No.");
        SalesPaymentLine.SETRANGE(Type, SalesPaymentLine.Type::Order);
        SalesPaymentLine.SETRANGE("No.", "No.");
        IF SalesPaymentLine.FINDFIRST THEN BEGIN
            FoundPaymentLine := SalesPaymentLine;
            EXIT(TRUE);
        END;
        //>>ENSP1.00
    end;

    procedure PrintTermMktPickTicketELA(CheckCashCust: Boolean)
    var
        PayTerms: Record "Payment Terms";
        SalesHeader: Record "Sales Header";
    begin
        //<<ENSP1.00
        IF CheckCashCust THEN
            IF PayTerms.GET("Payment Terms Code") THEN
                IF FORMAT(PayTerms."Due Date Calculation") <> '' THEN
                    IF (TODAY = CALCDATE(PayTerms."Due Date Calculation", TODAY)) AND
                        ((TODAY + 1) = CALCDATE(PayTerms."Due Date Calculation", TODAY + 1))
                    THEN
                        ERROR(Text14228900);
        SalesHeader.COPY(Rec);
        SalesHeader.SETRECFILTER;
        //REPORT.RUN(REPORT::"Terminal Market Pick Ticket",FALSE,FALSE,SalesHeader);    TBR
        //>>ENSP1.00  
    end;
    /// <summary>
    /// SetPriceDiscGroups."Sales Price/Disc Source ELA""Sales Price/Disc Source ELA"
    /// </summary>
    /// <param name="pintFieldNo">Integer.</param>
    procedure SetPriceDiscGroups(pintFieldNo: Integer)
    var
        lrecCustomer: Record Customer;
        lrecCustomerTemplate: Record "Customer Template";
        lrecShipTo: Record "Ship-to Address";
        ENSalesSetup: Record "Sales & Receivables Setup";
    begin

        ENSalesSetup.GET;

        "Customer Price Group" := '';
        "Invoice Disc. Code" := '';
        "Customer Disc. Group" := '';
        IF pintFieldNo IN [FIELDNO("Sell-to Customer No."), FIELDNO("Bill-to Customer No."), FIELDNO("Ship-to Code")] THEN BEGIN
            "Price List Group Code ELA" := '';
        END;
        //"Sales Price/Disc Source ELA""Sales Price/Disc Source ELA"

        CASE pintFieldNo OF
            FIELDNO("Sell-to Customer No."),
            FIELDNO("Bill-to Customer No."):
                BEGIN
                    IF ENSalesSetup."Sales Price/Disc Source ELA" = ENSalesSetup."Sales Price/Disc Source ELA"::"Sell-To Customer" THEN BEGIN
                        IF lrecCustomer.GET("Sell-to Customer No.") THEN BEGIN
                            "Customer Price Group" := lrecCustomer."Customer Price Group";
                            "Invoice Disc. Code" := lrecCustomer."Invoice Disc. Code";
                            "Customer Disc. Group" := lrecCustomer."Customer Disc. Group";
                            "Price List Group Code ELA" := lrecCustomer."Price List Group Code ELA";
                        END;
                    END ELSE BEGIN
                        IF lrecCustomer.GET("Bill-to Customer No.") THEN BEGIN
                            "Customer Price Group" := lrecCustomer."Customer Price Group";
                            "Invoice Disc. Code" := lrecCustomer."Invoice Disc. Code";
                            "Customer Disc. Group" := lrecCustomer."Customer Disc. Group";
                            "Price List Group Code ELA" := lrecCustomer."Price List Group Code ELA";
                        END;
                    END;
                END;
            FIELDNO("Ship-to Code"):
                BEGIN
                    IF ENSalesSetup."Sales Price/Disc Source ELA" = ENSalesSetup."Sales Price/Disc Source ELA"::"Sell-To Customer" THEN BEGIN
                        IF lrecShipTo.GET("Sell-to Customer No.", "Ship-to Code") THEN BEGIN
                            IF lrecShipTo."Ship-To Price Group" <> '' THEN
                                "Customer Price Group" := lrecShipTo."Ship-To Price Group";
                            IF lrecShipTo."Invoice Disc. Code" <> '' THEN
                                "Invoice Disc. Code" := lrecShipTo."Invoice Disc. Code";

                            IF lrecCustomer.GET("Sell-to Customer No.") THEN BEGIN
                                //--"Sales Price/Disc Source ELA"hip-to use the o"Sales Price/Disc Source ELA"
                                IF "Customer Price Group" = '' THEN BEGIN
                                    "Customer Price Group" := lrecCustomer."Customer Price Group";
                                END;

                                "Price List Group Code ELA" := lrecCustomer."Price List Group Code ELA";


                                IF "Invoice Disc. Code" = '' THEN
                                    "Invoice Disc. Code" := lrecCustomer."Invoice Disc. Code";

                                "Customer Disc. Group" := lrecCustomer."Customer Disc. Group";
                            END;
                        END ELSE BEGIN
                            //-- No ship-to found so revert to sell-to customer
                            SetPriceDiscGroups(FIELDNO("Sell-to Customer No."));
                        END;
                    END ELSE BEGIN
                        SetPriceDiscGroups(FIELDNO("Bill-to Customer No."));
                    END;
                END;
            FIELDNO("Sell-to Customer Template Code"),
            FIELDNO("Bill-to Customer Template Code"):
                BEGIN
                    IF ENSalesSetup."Sales Price/Disc Source ELA" = ENSalesSetup."Sales Price/Disc Source ELA"::"Sell-To Customer" THEN BEGIN
                        IF "Sell-to Customer Template Code" <> '' THEN BEGIN
                            IF lrecCustomerTemplate.GET("Sell-to Customer Template Code") THEN BEGIN
                                "Customer Price Group" := lrecCustomerTemplate."Customer Price Group";
                                "Invoice Disc. Code" := lrecCustomerTemplate."Invoice Disc. Code";
                                "Customer Disc. Group" := lrecCustomerTemplate."Customer Disc. Group";
                            END;
                        END ELSE BEGIN
                            SetPriceDiscGroups(FIELDNO("Sell-to Customer No."));
                        END;
                    END ELSE BEGIN
                        IF "Bill-to Customer Template Code" <> '' THEN BEGIN
                            IF lrecCustomerTemplate.GET("Bill-to Customer Template Code") THEN BEGIN
                                "Customer Price Group" := lrecCustomerTemplate."Customer Price Group";
                                "Invoice Disc. Code" := lrecCustomerTemplate."Invoice Disc. Code";
                                "Customer Disc. Group" := lrecCustomerTemplate."Customer Disc. Group";
                            END;
                        END ELSE BEGIN
                            SetPriceDiscGroups(FIELDNO("Bill-to Customer No."));
                        END;
                    END;
                END;
        END;

    end;

    /// <summary>
    /// UpdateOrderRuleGroup.
    /// </summary>
    procedure UpdateOrderRuleGroup()
    var
        lrecShipTo: Record "Ship-to Address";
        lrecCustomer: Record Customer;
    begin

        IF (
          ("Sell-to Customer No." = xRec."Sell-to Customer No.")
          AND ("Ship-to Code" = xRec."Ship-to Code")
        ) THEN BEGIN
            EXIT;
        END;

        IF (
          lrecShipTo.GET("Sell-to Customer No.", "Ship-to Code")
          AND (lrecShipTo."Order Rule Group" <> '')
        ) THEN BEGIN

            VALIDATE("Order Rule Group ELA", lrecShipTo."Order Rule Group");

            EXIT;

        END;

        // we only get here if we got a non-blank "Order Rule Group" from the Ship-to Address

        IF (
          NOT lrecCustomer.GET("Sell-to Customer No.")
        ) THEN BEGIN

            CLEAR(lrecCustomer);

        END;

        VALIDATE("Order Rule Group ELA", lrecCustomer."Order Rule Group ELA");

    end;

    /// <summary>
    /// GetCust.
    /// </summary>
    /// <param name="CustNo">Code[20].</param>
    procedure GetCust(CustNo: Code[20])
    BEGIN

        IF NOT (("Document Type" = "Document Type"::Quote) AND (CustNo = '')) THEN BEGIN
            IF CustNo <> Cust."No." THEN
                Cust.GET(CustNo);
        END ELSE
            CLEAR(Cust);
    END;

    var
        CustItemChargeMgt: Codeunit "EN Delivery Charge Mgt";
        Cust: Record Customer;
        Text14228880: TextConst ENU = 'You cannot make changes because this Sales Order is on Cash Drawer %1';
        Text14228881: TextConst ENU = 'No Record Extension Records exist for Sales %1 %2. Please update these entries.';
        Text14228900: TextConst ENU = 'Not allowed for cash customers.';
        Text14228901: TextConst ENU = 'You cannot make changes because this Sales Order is on Cash Drawer %1.';
        Text14228910: TextConst ENU = 'Not allowed for cash customers.';
        grecSalesLine: Record "Sales Line";
        gblnDSDBypassRouteTemplate: Boolean;
        grecDSDSetup: Record "DSD Setup";


    procedure UpdateSalesLinesELA(ChangedFieldName: Text[100])
    begin

        grecSalesLine.Reset;
        grecSalesLine.SetRange("Document Type", "Source Subtype ELA");
        grecSalesLine.SetRange("Document No.", "Source ID ELA");
        if grecSalesLine.FindSet then begin
            repeat

                /*CASE ChangedFieldName OF

                  FIELDCAPTION("Non-Commissionable") :
                    IF grecSalesLine."No." <> '' THEN BEGIN
                      IF (grecSalesLine."Comm. Bus. Group" <> '') AND (grecSalesLine."Comm. Prod. Group" <> '') THEN BEGIN
                        grecSalesLine.VALIDATE("Non-Commissionable","Non-Commissionable");
                      END;
                    END;
                END;*///TBR

                //grecSalesLine.MODIFY(TRUE);
                grecSalesLine.Modify;
            until grecSalesLine.Next = 0;
        end;

    end;

    procedure ibCheckExtDocNo(): Boolean
    var
        lrecCust: Record Customer;
    begin
        IF NOT ("Document Type" IN ["Document Type"::Order, "Document Type"::Invoice]) THEN EXIT(TRUE);
        IF "External Document No." <> '' THEN EXIT(TRUE);
        IF NOT lrecCust.GET("Sell-to Customer No.") THEN EXIT(TRUE);
        IF NOT lrecCust."Require Ext. Doc. No." THEN EXIT(TRUE);
        ERROR('External Document No. is required for customer %1', "Sell-to Customer No.");
        EXIT(FALSE);
    end;

    procedure jfUpdateBackorderTolerance()
    var
        lrecSalesLine: Record "Sales Line";
    begin
        lrecSalesLine.RESET;
        lrecSalesLine.SETRANGE("Document Type", "Document Type"::Order);
        lrecSalesLine.SETRANGE("Document No.", "No.");
        lrecSalesLine.SETRANGE(Type, lrecSalesLine.Type::Item);
        IF lrecSalesLine.FINDFIRST THEN
            REPEAT
                lrecSalesLine."Backorder Tolerance %" := "Backorder Tolerance % ELA";
                lrecSalesLine.MODIFY;
            UNTIL lrecSalesLine.NEXT = 0;
    end;

    procedure CashDrawerCheckELA()

    begin
        if Rec."Document Type" = Rec."Document Type"::Order then
            if Rec."Cash Drawer No. ELA" <> '' then
                Error(Text14228901, "Cash Drawer No. ELA");
    end;
	procedure UpdateRouteCode()
    begin
        "Route No. ELA" := GetRouteCode();
        Modify();
    end;

    procedure GetRouteCode(): Code[20]
    var
        Customer: Record Customer;
        RouteMatrix: Record "Route Matrix ELA";
        WeekDay: Text;
    begin
        if Customer.get("Sell-to Customer No.") then begin
            IF Customer."Default Delivery Route ELA" <> '' then
                exit(Customer."Default Delivery Route ELA")
            ELSE begin
                RouteMatrix.RESET;
                RouteMatrix.SetRange("Location Code", Rec."Location Code");
                RouteMatrix.SetRange("Customer Code", "Sell-to Customer No.");
                RouteMatrix.SetRange(Active, true);
                WeekDay := FORMAT("Shipment Date", 0, '<Weekday Text>');
                case WeekDay of
                    'Monday':
                        RouteMatrix.SetRange(Monday, true);
                    'Tuesday':
                        RouteMatrix.SetRange(Tuesday, true);
                    'Wednesday':
                        RouteMatrix.SetRange(Wednesday, true);
                    'Thursday':
                        RouteMatrix.SetRange(Thursday, true);
                    'Friday':
                        RouteMatrix.SetRange(Friday, true);
                    'Saturday':
                        RouteMatrix.SetRange(Saturday, true);
                    'Sunday':
                        RouteMatrix.SetRange(Sunday, true);
                end;
                IF RouteMatrix.FindFirst() then
                    exit(RouteMatrix."Route Code")
                else
                    exit('');
            end;
        end;
    end;
    trigger OnAfterInsert()
    begin
        "Date Order Created ELA" := WorkDate();
    end;

}

