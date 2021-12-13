codeunit 51000 BananaWrkshtCustomFunctions
{

    trigger OnRun()
    begin
    end;

    var
        grecDSDSetup: Record "DSD Setup";
        grrfRecordRefMaster: RecordRef;
        grecPurchLine: Record "Purchase Line";

    [Scope('Internal')]
    procedure FindDSDTemplateStop(var precDSDTemplateStop: Record "DSD Route Stop Tmplt. Detail"; pcodCustomer: Code[20]; pdatDate: Date; pcodLocation: Code[10]; pcodShipTo: Code[10]; pblnExactMatch: Boolean) pbln: Boolean
    var
        lintWeekday: Integer;
    begin

        precDSDTemplateStop.SetCurrentKey("Customer No.", "Start Date", "End Date", Weekday);

        precDSDTemplateStop.SetRange("Customer No.", pcodCustomer);
        precDSDTemplateStop.SetFilter("Start Date", '<=%1', pdatDate);
        precDSDTemplateStop.SetFilter("End Date", '>=%1', pdatDate);

        lintWeekday := Date2DWY(pdatDate, 1);

        precDSDTemplateStop.SetRange(Weekday, lintWeekday);

        //<JF09573AC>
        grecDSDSetup.Get;

        if pblnExactMatch then begin
            if (not grecDSDSetup."Override Loc. from Route Temp.") then begin
                precDSDTemplateStop.SetFilter("Location Code", '=%1', pcodLocation);
            end else begin
                precDSDTemplateStop.SetRange("Location Code");
            end;
            precDSDTemplateStop.SetFilter("Ship-to Code", '=%1', pcodShipTo);

            exit(precDSDTemplateStop.FindFirst);
        end;

        if pcodShipTo <> '' then begin

            // 1. look for { Customer, Location, Ship-to } first, otherwise find { Customer, BLANK, Ship-to }
            // (in "Override Loc. from Route Temp." environments, skip Location dimension)

            // { Customer, Location, Ship-to }
            if (not grecDSDSetup."Override Loc. from Route Temp.")
            and (pcodLocation <> '') then begin
                precDSDTemplateStop.SetRange("Location Code", pcodLocation);
                precDSDTemplateStop.SetRange("Ship-to Code", pcodShipTo);
                if precDSDTemplateStop.FindFirst then begin
                    exit(true);
                end;
            end;

            // { Customer, BLANK, Ship-to }
            precDSDTemplateStop.SetFilter("Location Code", '=%1', '');
            precDSDTemplateStop.SetRange("Ship-to Code", pcodShipTo);
            if precDSDTemplateStop.FindFirst then begin
                exit(true);
            end;
        end;

        if (pcodLocation <> '') and (not grecDSDSetup."Override Loc. from Route Temp.") then begin

            // 2. look for { Customer, Location, BLANK }
            // (non-"Orders Use Template Route" environments)

            precDSDTemplateStop.SetRange("Location Code", pcodLocation);
            precDSDTemplateStop.SetFilter("Ship-to Code", '=%1', '');
            if precDSDTemplateStop.FindFirst then begin
                exit(true);
            end;

        end;

        // 3. look for { Customer, BLANK, BLANK }

        precDSDTemplateStop.SetFilter("Location Code", '=%1', '');
        precDSDTemplateStop.SetFilter("Ship-to Code", '=%1', '');
        //</JF09573AC>

        exit(precDSDTemplateStop.FindFirst);
    end;

    [Scope('Internal')]
    procedure isPurchLineExtGet(precPurchLine: Record "Purchase Line"; var precRecordExt: Record "Custom Record Extension"; pblnForce: Boolean): Boolean
    begin
        grrfRecordRefMaster.GetTable(precPurchLine);
        exit(isRecordExtGet(grrfRecordRefMaster, precRecordExt, pblnForce));
    end;

    local procedure isRecordExtGet(prrfMaster: RecordRef; var precRecordExt: Record "Custom Record Extension"; pblnForce: Boolean): Boolean
    var
        lrecRecordExt: Record "Custom Record Extension";
        lblnFound: Boolean;
        lfrfFieldRef1: FieldRef;
        lfrfFieldRef2: FieldRef;
        ErrorText001: Label '%1 called with unsupported record type %2.';
        lfrfFieldRef3: FieldRef;
    begin
        lblnFound := true;
        case prrfMaster.Number of
            DATABASE::"Purchase Line":
                begin
                    lfrfFieldRef1 := prrfMaster.Field(grecPurchLine.FieldNo("Document Type"));
                    lfrfFieldRef2 := prrfMaster.Field(grecPurchLine.FieldNo("Document No."));
                    lfrfFieldRef3 := prrfMaster.Field(grecPurchLine.FieldNo("Line No."));
                    if not precRecordExt.Get(
                      prrfMaster.Number,
                      lfrfFieldRef1.Value,
                      lfrfFieldRef2.Value,
                      0,
                      0,
                      lfrfFieldRef3.Value
                     ) then
                        lblnFound := false;
                end;

            else
                Error(StrSubstNo(ErrorText001, 'jfExtRecordGet', prrfMaster.Number));
        end;
        if lblnFound then begin
            exit(true);
        end;
        if not pblnForce then
            exit(false);
        isRecordExtCreate(prrfMaster, precRecordExt);
        exit(true);
    end;

    local procedure isRecordExtCreate(prrfMaster: RecordRef; var precRecordExt: Record "Custom Record Extension")
    var
        lrecRecordExt: Record "Custom Record Extension";
        lfrfFieldRef1: FieldRef;
        lfrfFieldRef2: FieldRef;
        lfrfFieldRef3: FieldRef;
    begin
        if isRecordExtGet(prrfMaster, precRecordExt, false) then
            exit;

        precRecordExt."Source Type" := prrfMaster.Number;
        case prrfMaster.Number of
            DATABASE::"Purchase Line":
                begin
                    lfrfFieldRef1 := prrfMaster.Field(grecPurchLine.FieldNo("Document Type"));
                    lfrfFieldRef2 := prrfMaster.Field(grecPurchLine.FieldNo("Document No."));
                    lfrfFieldRef3 := prrfMaster.Field(grecPurchLine.FieldNo("Line No."));
                    precRecordExt."Source Subtype" := lfrfFieldRef1.Value;
                    precRecordExt."Source ID" := lfrfFieldRef2.Value;
                    precRecordExt."Source Ref. No." := lfrfFieldRef3.Value;
                end;
        end;
        precRecordExt.Insert;

    end;

    [Scope('Internal')]
    procedure jfAllocateFreight(precPurchaseHeader: Record "Purchase Header"; pcodItemChargeCode: Code[10]; pdecItemChargeAmount: Decimal): Code[20]
    var
        lrecShippingAgent: Record "Shipping Agent";
        Text001: Label 'The Shipping Agent Code is missing from Purchase Order %1, vendor %2.';
        Text002: Label 'Shipping Agent %1 has no Vendor No.';
        lcduItemChgMgt: Codeunit BananaWrkshtCustomFunctions;
        lrecFreightPurchaseHeader: Record "Purchase Header";
        lrecFreightPurchaseLine: Record "Purchase Line";
        lrecItemChgWsEntry: Record "Item Charge Worksheet Entry";
        lrecItemChgAssgPurch: Record "Item Charge Assignment (Purch)";
    begin
        if precPurchaseHeader."Shipping Agent Code" = '' then
            Error(Text001, precPurchaseHeader."No.", precPurchaseHeader."Buy-from Vendor No.");

        lrecShippingAgent.Get(precPurchaseHeader."Shipping Agent Code");
        if lrecShippingAgent."Vendor No." = '' then
            Error(Text002, precPurchaseHeader."Shipping Agent Code");

        lrecItemChgWsEntry.Validate("Posting Date", precPurchaseHeader."Posting Date");
        lrecItemChgWsEntry.Validate("Applies-To Functional Area", lrecItemChgWsEntry."Applies-To Functional Area"::Purchase);
        lrecItemChgWsEntry.Validate("Applies-To Document Type", lrecItemChgWsEntry."Applies-To Document Type"::Order);
        lrecItemChgWsEntry.Validate("Applies-To Document No.", precPurchaseHeader."No.");
        lrecItemChgWsEntry.Validate("Vendor No.", lrecShippingAgent."Vendor No.");
        lrecItemChgWsEntry.Validate("Cost Type", lrecItemChgWsEntry."Cost Type"::Document);
        lrecItemChgWsEntry.Validate("Distribution Type", lrecItemChgWsEntry."Distribution Type"::Pallet);
        lrecItemChgWsEntry.Validate("Item Charge No.", pcodItemChargeCode);
        lrecItemChgWsEntry.Validate("Qty. to Assign", 1);
        lrecItemChgWsEntry.Validate("Unit Cost", pdecItemChargeAmount);
        lrecItemChgWsEntry."Make Invoice" := false;
        lrecItemChgWsEntry.Validate("Vendor No.", lrecShippingAgent."Vendor No.");
        lrecItemChgWsEntry.Processed := false;
        lrecItemChgWsEntry.Insert;
        jfCreatePurchOrder(lrecItemChgWsEntry, true, lrecFreightPurchaseHeader);
        exit(lrecItemChgWsEntry."Document No.");

    end;

    [Scope('Internal')]
    procedure jfCreatePurchOrder(var precItemChargeWkshtEntry: Record "Item Charge Worksheet Entry"; pblnNewVendor: Boolean; var precPurchHeader: Record "Purchase Header")
    var
        lrecSourcePurchHeader: Record "Purchase Header";
        lrecSourceSalesHeader: Record "Sales Header";
        lrecSourceTransHeader: Record "Transfer Header";
        lrecPurchLine: Record "Purchase Line";
        lrecProdPurchLine: Record "Purchase Line";
        lrecItemChargeAssgnt: Record "Item Charge Assignment (Purch)";
        lrecAppliesToPurchLine: Record "Purchase Line";
        lrecAppliesToSalesLine: Record "Sales Line";
        lrecAppliesToTransLine: Record "Transfer Line";
        lintLineNo: Integer;
        lcduItemChargeAssgntPurch: Codeunit "Item Charge Assgnt. (Purch.)";
        lintTotal: Integer;
        lintCount: Integer;
        lrecPurchSetup: Record "Purchases & Payables Setup";
        lcon000: Label 'Purchase %1 No. %2, Line No. %3 was succcessfully created for the item charge.';
    begin
        if precItemChargeWkshtEntry.Processed then
            exit;

        precItemChargeWkshtEntry.TestField("Vendor No.");
        precItemChargeWkshtEntry.TestField("Vendor No.");
        precItemChargeWkshtEntry.TestField("Item Charge No.");
        precItemChargeWkshtEntry.TestField("Qty. to Assign");
        precItemChargeWkshtEntry.TestField("Unit Cost");
        precItemChargeWkshtEntry.TestField("Posting Date");

        if precItemChargeWkshtEntry."Cost Type" = precItemChargeWkshtEntry."Cost Type"::Line then begin
            precItemChargeWkshtEntry.TestField("Line No.");
            precItemChargeWkshtEntry.TestField("Distribution Type", precItemChargeWkshtEntry."Distribution Type"::Amount);
        end;

        lrecPurchSetup.Get;

        if pblnNewVendor then begin
            precPurchHeader."Document Type" := precPurchHeader."Document Type"::Order;

            precPurchHeader.SetHideValidationDialog(true);
            precPurchHeader."No." := '';

            precPurchHeader.Insert(true);

            precPurchHeader.Validate(precPurchHeader."Posting Date", precItemChargeWkshtEntry."Posting Date");

            precPurchHeader.Validate("Buy-from Vendor No.", precItemChargeWkshtEntry."Vendor No.");
            precPurchHeader.Validate("Currency Code", precItemChargeWkshtEntry."Currency Code");

            if precItemChargeWkshtEntry."Currency Factor" <> 0 then begin
                precPurchHeader.Validate("Currency Factor", precItemChargeWkshtEntry."Currency Factor");
            end;

            case precItemChargeWkshtEntry."Applies-To Functional Area" of
                precItemChargeWkshtEntry."Applies-To Functional Area"::Purchase:
                    begin
                        lrecSourcePurchHeader.Get(precItemChargeWkshtEntry."Applies-To Document Type",
                                                  precItemChargeWkshtEntry."Applies-To Document No.");

                        precPurchHeader.Validate("Responsibility Center", lrecSourcePurchHeader."Responsibility Center");
                        precPurchHeader.Validate("Shortcut Dimension 1 Code", lrecSourcePurchHeader."Shortcut Dimension 1 Code");
                        precPurchHeader.Validate("Shortcut Dimension 2 Code", lrecSourcePurchHeader."Shortcut Dimension 2 Code");
                        precPurchHeader.Validate("Location Code", lrecSourcePurchHeader."Location Code"); //<JF10667SPK>
                    end;
                precItemChargeWkshtEntry."Applies-To Functional Area"::Sales:
                    begin
                        lrecSourceSalesHeader.Get(precItemChargeWkshtEntry."Applies-To Document Type",
                                                  precItemChargeWkshtEntry."Applies-To Document No.");

                        precPurchHeader.Validate("Responsibility Center", lrecSourceSalesHeader."Responsibility Center");
                        precPurchHeader.Validate("Shortcut Dimension 1 Code", lrecSourceSalesHeader."Shortcut Dimension 1 Code");
                        precPurchHeader.Validate("Shortcut Dimension 2 Code", lrecSourceSalesHeader."Shortcut Dimension 2 Code");
                        precPurchHeader.Validate("Location Code", lrecSourceSalesHeader."Location Code"); //<JF10667SPK>
                    end;
                precItemChargeWkshtEntry."Applies-To Functional Area"::Transfer:
                    begin
                        lrecSourceTransHeader.Get(precItemChargeWkshtEntry."Applies-To Document No.");

                        precPurchHeader.Validate("Shortcut Dimension 1 Code", lrecSourceTransHeader."Shortcut Dimension 1 Code");
                        precPurchHeader.Validate("Shortcut Dimension 2 Code", lrecSourceTransHeader."Shortcut Dimension 2 Code");
                        precPurchHeader.Validate("Location Code", lrecSourceTransHeader."Transfer-to Code"); //<JF10667SPK>
                    end;
            end;

            precPurchHeader.Modify;
        end;

        lrecPurchLine.SetRange("Document Type", precPurchHeader."Document Type");
        lrecPurchLine.SetRange("Document No.", precPurchHeader."No.");
        lrecPurchLine.SetRange("Line No.");

        if lrecPurchLine.Find('+') then
            lintLineNo := lrecPurchLine."Line No." + 10000
        else
            lintLineNo := 10000;

        lrecPurchLine.Init;

        lrecPurchLine."Document Type" := precPurchHeader."Document Type";
        lrecPurchLine."Document No." := precPurchHeader."No.";
        lrecPurchLine."Line No." := lintLineNo;
        lrecPurchLine."System-Created Entry" := true;

        lrecPurchLine.Insert(true);

        lrecPurchLine.Validate(Type, lrecPurchLine.Type::"Charge (Item)");
        lrecPurchLine.Validate("No.", precItemChargeWkshtEntry."Item Charge No.");
        lrecPurchLine.Validate("Unit of Measure Code", precItemChargeWkshtEntry."Unit of Measure Code");
        lrecPurchLine.Validate(Quantity, precItemChargeWkshtEntry."Qty. to Assign");
        lrecPurchLine.Validate("Direct Unit Cost", precItemChargeWkshtEntry."Unit Cost");

        lrecPurchLine.Modify;

        case precItemChargeWkshtEntry."Cost Type" of
            precItemChargeWkshtEntry."Cost Type"::Document:
                begin
                    case precItemChargeWkshtEntry."Applies-To Functional Area" of
                        precItemChargeWkshtEntry."Applies-To Functional Area"::Purchase:
                            begin
                                lrecAppliesToPurchLine.Reset;

                                lrecAppliesToPurchLine.SetRange("Document Type", precItemChargeWkshtEntry."Applies-To Document Type");
                                lrecAppliesToPurchLine.SetRange("Document No.", precItemChargeWkshtEntry."Applies-To Document No.");
                                lrecAppliesToPurchLine.SetRange("Line No.");

                                lrecAppliesToPurchLine.SetRange("Allow Item Charge Assignment", true);
                                lrecAppliesToPurchLine.SetFilter(Quantity, '<>%1', 0);

                                if not lrecAppliesToPurchLine.IsEmpty then begin
                                    lintTotal := lrecAppliesToPurchLine.Count;
                                    lintCount := 0;

                                    lrecAppliesToPurchLine.Find('-');

                                    repeat
                                        lintCount += 1;

                                        if lintCount = lintTotal then
                                            jfInsertSingleAssgntPurch(precPurchHeader,
                                                                      lrecPurchLine,
                                                                      precItemChargeWkshtEntry."Applies-To Functional Area",
                                                                      lrecAppliesToPurchLine."Document Type",
                                                                      lrecAppliesToPurchLine."Document No.",
                                                                      lrecAppliesToPurchLine."Line No.",
                                                                      precItemChargeWkshtEntry."Distribution Type",
                                                                      true)
                                        else
                                            jfInsertSingleAssgntPurch(precPurchHeader,
                                                                      lrecPurchLine,
                                                                      precItemChargeWkshtEntry."Applies-To Functional Area",
                                                                      lrecAppliesToPurchLine."Document Type",
                                                                      lrecAppliesToPurchLine."Document No.",
                                                                      lrecAppliesToPurchLine."Line No.",
                                                                      precItemChargeWkshtEntry."Distribution Type",
                                                                      false);
                                    until lrecAppliesToPurchLine.Next = 0;
                                end;
                            end;
                        precItemChargeWkshtEntry."Applies-To Functional Area"::Sales:
                            begin
                                lrecAppliesToSalesLine.Reset;

                                lrecAppliesToSalesLine.SetRange("Document Type", precItemChargeWkshtEntry."Applies-To Document Type");
                                lrecAppliesToSalesLine.SetRange("Document No.", precItemChargeWkshtEntry."Applies-To Document No.");
                                lrecAppliesToSalesLine.SetRange("Line No.");

                                lrecAppliesToSalesLine.SetRange("Allow Item Charge Assignment", true);
                                lrecAppliesToSalesLine.SetFilter(Quantity, '<>%1', 0);

                                if not lrecAppliesToSalesLine.IsEmpty then begin
                                    lintTotal := lrecAppliesToSalesLine.Count;
                                    lintCount := 0;

                                    lrecAppliesToSalesLine.Find('-');

                                    repeat
                                        lintCount += 1;

                                        if lintCount = lintTotal then begin
                                            jfInsertSingleAssgntPurch(precPurchHeader,
                                                                      lrecPurchLine,
                                                                      precItemChargeWkshtEntry."Applies-To Functional Area",
                                                                      lrecAppliesToSalesLine."Document Type",
                                                                      lrecAppliesToSalesLine."Document No.",
                                                                      lrecAppliesToSalesLine."Line No.",
                                                                      precItemChargeWkshtEntry."Distribution Type",
                                                                      true);
                                        end else begin
                                            jfInsertSingleAssgntPurch(precPurchHeader,
                                                                      lrecPurchLine,
                                                                      precItemChargeWkshtEntry."Applies-To Functional Area",
                                                                      lrecAppliesToSalesLine."Document Type",
                                                                      lrecAppliesToSalesLine."Document No.",
                                                                      lrecAppliesToSalesLine."Line No.",
                                                                      precItemChargeWkshtEntry."Distribution Type",
                                                                      false);
                                        end;
                                    until lrecAppliesToSalesLine.Next = 0;
                                end;
                            end;
                        precItemChargeWkshtEntry."Applies-To Functional Area"::Transfer:
                            begin
                                lrecAppliesToTransLine.Reset;

                                lrecAppliesToTransLine.SetRange("Document No.", precItemChargeWkshtEntry."Applies-To Document No.");
                                lrecAppliesToTransLine.SetRange("Line No.");

                                lrecAppliesToTransLine.SetFilter(Quantity, '<>%1', 0);
                                lrecAppliesToTransLine.SetRange("Derived From Line No.", 0);

                                if not lrecAppliesToTransLine.IsEmpty then begin
                                    lintTotal := lrecAppliesToTransLine.Count;
                                    lintCount := 0;

                                    lrecAppliesToTransLine.Find('-');

                                    repeat
                                        lintCount += 1;

                                        if lintCount = lintTotal then
                                            jfInsertSingleAssgntPurch(precPurchHeader,
                                                                      lrecPurchLine,
                                                                      precItemChargeWkshtEntry."Applies-To Functional Area",
                                                                      0,
                                                                      lrecAppliesToTransLine."Document No.",
                                                                      lrecAppliesToTransLine."Line No.",
                                                                      precItemChargeWkshtEntry."Distribution Type",
                                                                      true)
                                        else
                                            jfInsertSingleAssgntPurch(precPurchHeader,
                                                                      lrecPurchLine,
                                                                      precItemChargeWkshtEntry."Applies-To Functional Area",
                                                                      0,
                                                                      lrecAppliesToTransLine."Document No.",
                                                                      lrecAppliesToTransLine."Line No.",
                                                                      precItemChargeWkshtEntry."Distribution Type",
                                                                      false);
                                    until lrecAppliesToTransLine.Next = 0;
                                end;
                            end;
                    end;

                    if lrecPurchSetup."Retain Exp. Purch. Cost Detail" then begin
                        precItemChargeWkshtEntry.Processed := true;
                        precItemChargeWkshtEntry."Document No." := precPurchHeader."No.";
                        precItemChargeWkshtEntry.Modify;
                    end else begin
                        precItemChargeWkshtEntry.Delete(true);
                    end;
                end;
            precItemChargeWkshtEntry."Cost Type"::Line:
                begin
                    jfInsertSingleAssgntPurch(precPurchHeader,
                                              lrecPurchLine,
                                              precItemChargeWkshtEntry."Applies-To Functional Area",
                                              precItemChargeWkshtEntry."Applies-To Document Type",
                                              precItemChargeWkshtEntry."Applies-To Document No.",
                                              precItemChargeWkshtEntry."Applies-To Document Line No.",
                                              precItemChargeWkshtEntry."Distribution Type",
                                              true);

                    if lrecPurchSetup."Retain Exp. Purch. Cost Detail" then begin
                        precItemChargeWkshtEntry.Processed := true;
                        precItemChargeWkshtEntry."Document No." := precPurchHeader."No.";
                        precItemChargeWkshtEntry.Modify;
                    end else begin
                        precItemChargeWkshtEntry.Delete(true);
                    end;
                end;
        end;
    end;

    [Scope('Internal')]
    procedure jfInsertSingleAssgntPurch(var precPurchHeader: Record "Purchase Header"; var precPurchLine: Record "Purchase Line"; poptAppliesToFuncArea: Enum ApplToFunctionalArea; poptAppliesToDocType: Option; pcodAppliesToDocNo: Code[20]; pintAppliesToDocLineNo: Integer; poptDistType: Enum DistributionType; pblnDistribute: Boolean)
    var
        lrecItemChargeAssgnt: Record "Item Charge Assignment (Purch)";
        lrecAppliesToPurchLine: Record "Purchase Line";
        lrecAppliesToSalesLine: Record "Sales Line";
        lrecAppliesToTransLine: Record "Transfer Line";
        lcduItemChargeAssgntPurch: Codeunit "Item Charge Assgnt. (Purch.)";
        ldecQtyToAssign: Decimal;
        BananaWrkshtNewFunction: Codeunit BananaWrkshtNewFunctions;
    begin
        lrecItemChargeAssgnt.Reset;

        lrecItemChargeAssgnt.SetRange("Document Type", precPurchHeader."Document Type");
        lrecItemChargeAssgnt.SetRange("Document No.", precPurchHeader."No.");
        lrecItemChargeAssgnt.SetRange("Document Line No.", precPurchLine."Line No.");

        if lrecItemChargeAssgnt.FindLast then begin
            lrecItemChargeAssgnt."Initial Distribution Type" := poptDistType;
            lrecItemChargeAssgnt."Unit Cost" := precPurchLine."Unit Cost";
        end else begin
            lrecItemChargeAssgnt.Reset;

            lrecItemChargeAssgnt.Init;

            lrecItemChargeAssgnt."Document Type" := precPurchHeader."Document Type";
            lrecItemChargeAssgnt."Document No." := precPurchHeader."No.";
            lrecItemChargeAssgnt."Document Line No." := precPurchLine."Line No.";

            lrecItemChargeAssgnt."Applies-to Doc. Type" := poptAppliesToDocType;
            lrecItemChargeAssgnt."Applies-to Doc. No." := pcodAppliesToDocNo;
            lrecItemChargeAssgnt."Applies-to Doc. Line No." := pintAppliesToDocLineNo;

            lrecItemChargeAssgnt."Item Charge No." := precPurchLine."No.";
            lrecItemChargeAssgnt."Unit Cost" := precPurchLine."Unit Cost";
            lrecItemChargeAssgnt."Initial Distribution Type" := poptDistType;
        end;

        case poptAppliesToFuncArea of
            poptAppliesToFuncArea::Purchase:
                begin
                    lrecAppliesToPurchLine.SetRange("Document Type", poptAppliesToDocType);
                    lrecAppliesToPurchLine.SetRange("Document No.", pcodAppliesToDocNo);
                    lrecAppliesToPurchLine.SetRange("Line No.", pintAppliesToDocLineNo);
                    lrecAppliesToPurchLine.FindSet;

                    BananaWrkshtNewFunction.jfCreatePurchOrderChargeAssgnt(lrecAppliesToPurchLine, lrecItemChargeAssgnt);
                end;
            poptAppliesToFuncArea::Sales:
                begin
                    lrecAppliesToSalesLine.SetRange("Document Type", poptAppliesToDocType);
                    lrecAppliesToSalesLine.SetRange("Document No.", pcodAppliesToDocNo);
                    lrecAppliesToSalesLine.SetRange("Line No.", pintAppliesToDocLineNo);
                    lrecAppliesToSalesLine.FindSet;

                    BananaWrkshtNewFunction.jfCreateSalesOrderChargeAssgnt(lrecAppliesToSalesLine, lrecItemChargeAssgnt);
                end;
        end;
        ldecQtyToAssign := jfCalcQtyToAssign(DATABASE::"Purchase Line", precPurchLine."Document Type", precPurchLine."Document No.", precPurchLine."Line No.");

        if pblnDistribute then
            lcduItemChargeAssgntPurch.SuggestAssgnt2(
              precPurchLine,
              ldecQtyToAssign,
              ldecQtyToAssign * precPurchLine."Direct Unit Cost",
              poptDistType + 1);
    end;

    [Scope('Internal')]
    procedure jfCalcQtyToAssign(pintTableNo: Integer; poptDocType: Option; pcodDocNo: Code[20]; pintDocLineNo: Integer): Decimal
    var
        lrecPurchLine: Record "Purchase Line";
        lrecSalesLine: Record "Sales Line";
        lrecTransferLine: Record "Transfer Line";
        ldecResult: Decimal;
    begin
        ldecResult := 0;

        case pintTableNo of
            DATABASE::"Purchase Line":
                begin
                    lrecPurchLine.Get(poptDocType, pcodDocNo, pintDocLineNo);
                    lrecPurchLine.CalcFields("Qty. Assigned");
                    ldecResult := lrecPurchLine.Quantity - lrecPurchLine."Qty. Assigned";
                end;
            DATABASE::"Sales Line":
                begin
                    lrecSalesLine.Get(poptDocType, pcodDocNo, pintDocLineNo);
                    lrecSalesLine.CalcFields("Qty. Assigned");
                    ldecResult := lrecSalesLine.Quantity - lrecSalesLine."Qty. Assigned";
                end;
        end;

        exit(ldecResult);

    end;

    [Scope('Internal')]
    procedure jfCheckSalesBackorder(var precSalesHeader: Record "Sales Header")
    var
        lrecCustomer: Record Customer;
        lrecShipTo: Record "Ship-to Address";
        lrecSalesLine: Record "Sales Line";
        ldecTolerance: Decimal;
        lblnFoundTolerance: Boolean;
        lblnUpdatedLine: Boolean;
    begin
        if precSalesHeader."Document Type" = precSalesHeader."Document Type"::Order then begin
            if precSalesHeader.Ship then begin
                if precSalesHeader."Prepayment %" <> 0 then
                    exit;
                ldecTolerance := 0;
                lblnFoundTolerance := false;

                if precSalesHeader."Ship-to Code" <> '' then begin
                    lrecShipTo.Get(precSalesHeader."Sell-to Customer No.", precSalesHeader."Ship-to Code");

                    if lrecShipTo."Use Backorder Tolerance ELA" then begin
                        lblnFoundTolerance := true;
                    end;
                end;

                if not lblnFoundTolerance then begin
                    lrecCustomer.Get(precSalesHeader."Sell-to Customer No.");

                    if lrecCustomer."Use Backorder Tolerance ELA" then begin
                        lblnFoundTolerance := true;
                    end;
                end;

                if lblnFoundTolerance then begin
                    lrecSalesLine.SetRange("Document Type", precSalesHeader."Document Type");
                    lrecSalesLine.SetRange("Document No.", precSalesHeader."No.");
                    lrecSalesLine.SetRange("Line No.");
                    lrecSalesLine.SetRange(Type, lrecSalesLine.Type::Item);

                    if lrecSalesLine.FindSet(true) then begin
                        repeat
                            ldecTolerance := lrecSalesLine."Backorder Tolerance %";
                            if jfCheckSalesLineTolerance(lrecSalesLine, ldecTolerance) then
                                lblnUpdatedLine := true;
                        until lrecSalesLine.Next = 0;
                    end;
                end;
            end;
        end;
    end;

    [Scope('Internal')]
    procedure jfCheckSalesLineTolerance(var precSalesLine: Record "Sales Line"; pdecTolerance: Decimal): Boolean
    var
        ldecQtyToShip: Decimal;
    begin

        if precSalesLine."Qty. to Ship" + precSalesLine."Quantity Shipped" >= precSalesLine.Quantity then
            exit(false);

        if Round((1 - (precSalesLine."Qty. to Ship" + precSalesLine."Quantity Shipped") / precSalesLine.Quantity) * 100, 0.00001) <= pdecTolerance then begin
            precSalesLine.SuspendStatusCheck(true);
            precSalesLine.jfSuspendPriceCalc(true);

            jfAdjustSalesLineItemTracking(precSalesLine, precSalesLine."Qty. to Ship (Base)" + precSalesLine."Qty. Shipped (Base)");

            ldecQtyToShip := precSalesLine."Qty. to Ship";

            precSalesLine.Validate(Quantity, precSalesLine."Qty. to Ship" + precSalesLine."Quantity Shipped");
            precSalesLine.Validate("Qty. to Ship", ldecQtyToShip);

            precSalesLine.Modify;

            exit(true);
        end;


        exit(false);
    end;

    [Scope('Internal')]
    procedure jfAdjustSalesLineItemTracking(precSalesLine: Record "Sales Line"; pdecNewQtyBase: Decimal)
    var
        ldecPct: Decimal;
        lblnItemTracking: Boolean;
        lrecReservEntry: Record "Reservation Entry";
        lrecReservEntry2: Record "Reservation Entry";
        ldecQtyToRemove: Decimal;
    begin
        ldecPct := Round(precSalesLine.doTrackingExistsELA(pdecNewQtyBase, lblnItemTracking));

        if lblnItemTracking then begin
            if ldecPct > 100 then begin
                lrecReservEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
                                              "Source Ref. No.", "Expiration Date", "Lot No.", "Serial No.");

                lrecReservEntry.Ascending(false);

                lrecReservEntry.SetRange("Source Type", DATABASE::"Sales Line");
                lrecReservEntry.SetRange("Source Subtype", precSalesLine."Document Type");
                lrecReservEntry.SetRange("Source ID", precSalesLine."Document No.");
                lrecReservEntry.SetRange("Source Batch Name");
                lrecReservEntry.SetRange("Source Ref. No.", precSalesLine."Line No.");
                lrecReservEntry.SetRange("Expiration Date");
                lrecReservEntry.SetRange("Lot No.");
                lrecReservEntry.SetRange("Serial No.");

                if lrecReservEntry.Find('-') then begin
                    lrecReservEntry.CalcSums("Quantity (Base)");
                    ldecQtyToRemove := Abs(lrecReservEntry."Quantity (Base)") - pdecNewQtyBase;

                    repeat
                        if Abs(lrecReservEntry."Quantity (Base)") <= ldecQtyToRemove then begin
                            ldecQtyToRemove -= Abs(lrecReservEntry."Quantity (Base)");

                            lrecReservEntry2.Get(lrecReservEntry."Entry No.", lrecReservEntry.Positive);
                            lrecReservEntry2.Delete(true);
                        end else begin
                            lrecReservEntry2.Get(lrecReservEntry."Entry No.", lrecReservEntry.Positive);

                            if lrecReservEntry2.Positive then
                                lrecReservEntry2.Validate("Quantity (Base)", lrecReservEntry2."Quantity (Base)" - ldecQtyToRemove)
                            else
                                lrecReservEntry2.Validate("Quantity (Base)", lrecReservEntry2."Quantity (Base)" + ldecQtyToRemove);

                            lrecReservEntry2.Modify;
                            ldecQtyToRemove := 0;
                        end;
                    until (lrecReservEntry.Next = 0) or (ldecQtyToRemove = 0);
                end;
            end else
                if ldecPct = 0 then begin
                    lrecReservEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
                                                  "Source Ref. No.", "Expiration Date", "Lot No.", "Serial No.");

                    lrecReservEntry.SetRange("Source Type", DATABASE::"Sales Line");
                    lrecReservEntry.SetRange("Source Subtype", precSalesLine."Document Type");
                    lrecReservEntry.SetRange("Source ID", precSalesLine."Document No.");
                    lrecReservEntry.SetRange("Source Batch Name");
                    lrecReservEntry.SetRange("Source Ref. No.", precSalesLine."Line No.");
                    lrecReservEntry.SetRange("Expiration Date");
                    lrecReservEntry.SetRange("Lot No.");
                    lrecReservEntry.SetRange("Serial No.");

                    lrecReservEntry.DeleteAll;
                end;
        end;
    end;

    procedure CreatECEntry(precPurchaseHeader: Record "Purchase Header"; AdditionalFreight: Record "Additional Freight"): Code[20]
    var
        lrecShippingAgent: Record "Shipping Agent";
        Text001: Label 'The Shipping Agent Code is missing from Purchase Order %1, vendor %2.';
        Text002: Label 'Shipping Agent %1 has no Vendor No.';
        ExtraCharge: Record "EN Document Extra Charge";
        PurchLine: Record "Purchase Line";
        ExtraChargeSetup: Record "EN Extra Charge";
        ExtraCharge2: Record "EN Extra Charge";
    begin
        if precPurchaseHeader."Shipping Agent Code" = '' then
            Error(Text001, precPurchaseHeader."No.", precPurchaseHeader."Buy-from Vendor No.");

        lrecShippingAgent.Get(AdditionalFreight."Shipping Agent Code");
        if lrecShippingAgent."Vendor No." = '' then
            Error(Text002, precPurchaseHeader."Shipping Agent Code");


        ExtraCharge.Init();
        ExtraCharge.Validate("Document Type", ExtraCharge."Document Type"::Order);
        ExtraCharge.Validate("Document No.", precPurchaseHeader."No.");
        ExtraChargeSetup.Reset();
        ExtraChargeSetup.SetRange("Def. Purch Worksheet FRT Order", true);
        IF ExtraChargeSetup.FindFirst() then begin
            ExtraCharge.Reset();
            ExtraCharge.SetRange("Document No.", precPurchaseHeader."No.");
            ExtraCharge.SetRange("Document Type", ExtraCharge."Document Type"::Order);
            ExtraCharge.SetRange("Extra Charge Code", ExtraChargeSetup.Code);
            IF not ExtraCharge.FindFirst() then begin
                ExtraCharge.Validate("Extra Charge Code", ExtraChargeSetup.Code);
                ExtraCharge.Validate("Allocation Method", ExtraChargeSetup."Def.Purch WSheet Alloc Method");
                ExtraCharge.Validate("Vendor No.", lrecShippingAgent."Vendor No.");
            end else begin
                ExtraCharge2.Reset();
                ExtraCharge2.SetRange("Def. Purch Worksheet FRT Order", true);
                ExtraCharge2.SetFilter(Code, '<>%1', ExtraChargeSetup.Code);
                IF ExtraCharge2.FindFirst() then begin
                    ExtraCharge.Validate("Extra Charge Code", ExtraCharge2.Code);
                    ExtraCharge.Validate("Allocation Method", ExtraCharge2."Def.Purch WSheet Alloc Method");
                    ExtraCharge.Validate("Vendor No.", lrecShippingAgent."Vendor No.");
                end;
            end;
        end;
        ExtraCharge.Validate(Charge, AdditionalFreight."Freight Cost");
        ExtraCharge.Validate("Table ID", 38);
        ExtraCharge.Insert(true);

        //jfCreatePurchOrder(lrecItemChgWsEntry, true, lrecFreightPurchaseHeader);
        exit(ExtraCharge."Document No.");

    end;

    procedure AllocateExtraCharge(var precItemChargeWkshtEntry: Record "Item Charge Worksheet Entry"; pblnNewVendor: Boolean; var precPurchHeader: Record "Purchase Header")
    var
        lrecSourcePurchHeader: Record "Purchase Header";
        lrecSourceSalesHeader: Record "Sales Header";
        lrecSourceTransHeader: Record "Transfer Header";
        lrecPurchLine: Record "Purchase Line";
        lrecProdPurchLine: Record "Purchase Line";
        lrecItemChargeAssgnt: Record "Item Charge Assignment (Purch)";
        lrecAppliesToPurchLine: Record "Purchase Line";
        lrecAppliesToSalesLine: Record "Sales Line";
        lrecAppliesToTransLine: Record "Transfer Line";
        lintLineNo: Integer;
        lcduItemChargeAssgntPurch: Codeunit "Item Charge Assgnt. (Purch.)";
        lintTotal: Integer;
        lintCount: Integer;
        lrecPurchSetup: Record "Purchases & Payables Setup";
        lcon000: Label 'Purchase %1 No. %2, Line No. %3 was succcessfully created for the item charge.';
    begin
        if precItemChargeWkshtEntry.Processed then
            exit;

        precItemChargeWkshtEntry.TestField("Vendor No.");
        precItemChargeWkshtEntry.TestField("Vendor No.");
        precItemChargeWkshtEntry.TestField("Item Charge No.");
        precItemChargeWkshtEntry.TestField("Qty. to Assign");
        precItemChargeWkshtEntry.TestField("Unit Cost");
        precItemChargeWkshtEntry.TestField("Posting Date");

        if precItemChargeWkshtEntry."Cost Type" = precItemChargeWkshtEntry."Cost Type"::Line then begin
            precItemChargeWkshtEntry.TestField("Line No.");
            precItemChargeWkshtEntry.TestField("Distribution Type", precItemChargeWkshtEntry."Distribution Type"::Amount);
        end;

        lrecPurchSetup.Get;

        if pblnNewVendor then begin
            precPurchHeader."Document Type" := precPurchHeader."Document Type"::Order;

            precPurchHeader.SetHideValidationDialog(true);
            precPurchHeader."No." := '';

            precPurchHeader.Insert(true);

            precPurchHeader.Validate(precPurchHeader."Posting Date", precItemChargeWkshtEntry."Posting Date");

            precPurchHeader.Validate("Buy-from Vendor No.", precItemChargeWkshtEntry."Vendor No.");
            precPurchHeader.Validate("Currency Code", precItemChargeWkshtEntry."Currency Code");

            if precItemChargeWkshtEntry."Currency Factor" <> 0 then begin
                precPurchHeader.Validate("Currency Factor", precItemChargeWkshtEntry."Currency Factor");
            end;

            case precItemChargeWkshtEntry."Applies-To Functional Area" of
                precItemChargeWkshtEntry."Applies-To Functional Area"::Purchase:
                    begin
                        lrecSourcePurchHeader.Get(precItemChargeWkshtEntry."Applies-To Document Type",
                                                  precItemChargeWkshtEntry."Applies-To Document No.");

                        precPurchHeader.Validate("Responsibility Center", lrecSourcePurchHeader."Responsibility Center");
                        precPurchHeader.Validate("Shortcut Dimension 1 Code", lrecSourcePurchHeader."Shortcut Dimension 1 Code");
                        precPurchHeader.Validate("Shortcut Dimension 2 Code", lrecSourcePurchHeader."Shortcut Dimension 2 Code");
                        precPurchHeader.Validate("Location Code", lrecSourcePurchHeader."Location Code"); //<JF10667SPK>
                    end;
                precItemChargeWkshtEntry."Applies-To Functional Area"::Sales:
                    begin
                        lrecSourceSalesHeader.Get(precItemChargeWkshtEntry."Applies-To Document Type",
                                                  precItemChargeWkshtEntry."Applies-To Document No.");

                        precPurchHeader.Validate("Responsibility Center", lrecSourceSalesHeader."Responsibility Center");
                        precPurchHeader.Validate("Shortcut Dimension 1 Code", lrecSourceSalesHeader."Shortcut Dimension 1 Code");
                        precPurchHeader.Validate("Shortcut Dimension 2 Code", lrecSourceSalesHeader."Shortcut Dimension 2 Code");
                        precPurchHeader.Validate("Location Code", lrecSourceSalesHeader."Location Code"); //<JF10667SPK>
                    end;
                precItemChargeWkshtEntry."Applies-To Functional Area"::Transfer:
                    begin
                        lrecSourceTransHeader.Get(precItemChargeWkshtEntry."Applies-To Document No.");

                        precPurchHeader.Validate("Shortcut Dimension 1 Code", lrecSourceTransHeader."Shortcut Dimension 1 Code");
                        precPurchHeader.Validate("Shortcut Dimension 2 Code", lrecSourceTransHeader."Shortcut Dimension 2 Code");
                        precPurchHeader.Validate("Location Code", lrecSourceTransHeader."Transfer-to Code"); //<JF10667SPK>
                    end;
            end;

            precPurchHeader.Modify;
        end;

        lrecPurchLine.SetRange("Document Type", precPurchHeader."Document Type");
        lrecPurchLine.SetRange("Document No.", precPurchHeader."No.");
        lrecPurchLine.SetRange("Line No.");

        if lrecPurchLine.Find('+') then
            lintLineNo := lrecPurchLine."Line No." + 10000
        else
            lintLineNo := 10000;

        lrecPurchLine.Init;

        lrecPurchLine."Document Type" := precPurchHeader."Document Type";
        lrecPurchLine."Document No." := precPurchHeader."No.";
        lrecPurchLine."Line No." := lintLineNo;
        lrecPurchLine."System-Created Entry" := true;

        lrecPurchLine.Insert(true);

        lrecPurchLine.Validate(Type, lrecPurchLine.Type::"Charge (Item)");
        lrecPurchLine.Validate("No.", precItemChargeWkshtEntry."Item Charge No.");
        lrecPurchLine.Validate("Unit of Measure Code", precItemChargeWkshtEntry."Unit of Measure Code");
        lrecPurchLine.Validate(Quantity, precItemChargeWkshtEntry."Qty. to Assign");
        lrecPurchLine.Validate("Direct Unit Cost", precItemChargeWkshtEntry."Unit Cost");

        lrecPurchLine.Modify;

        case precItemChargeWkshtEntry."Cost Type" of
            precItemChargeWkshtEntry."Cost Type"::Document:
                begin
                    case precItemChargeWkshtEntry."Applies-To Functional Area" of
                        precItemChargeWkshtEntry."Applies-To Functional Area"::Purchase:
                            begin
                                lrecAppliesToPurchLine.Reset;

                                lrecAppliesToPurchLine.SetRange("Document Type", precItemChargeWkshtEntry."Applies-To Document Type");
                                lrecAppliesToPurchLine.SetRange("Document No.", precItemChargeWkshtEntry."Applies-To Document No.");
                                lrecAppliesToPurchLine.SetRange("Line No.");

                                lrecAppliesToPurchLine.SetRange("Allow Item Charge Assignment", true);
                                lrecAppliesToPurchLine.SetFilter(Quantity, '<>%1', 0);

                                if not lrecAppliesToPurchLine.IsEmpty then begin
                                    lintTotal := lrecAppliesToPurchLine.Count;
                                    lintCount := 0;

                                    lrecAppliesToPurchLine.Find('-');

                                    repeat
                                        lintCount += 1;

                                        if lintCount = lintTotal then
                                            jfInsertSingleAssgntPurch(precPurchHeader,
                                                                      lrecPurchLine,
                                                                      precItemChargeWkshtEntry."Applies-To Functional Area",
                                                                      lrecAppliesToPurchLine."Document Type",
                                                                      lrecAppliesToPurchLine."Document No.",
                                                                      lrecAppliesToPurchLine."Line No.",
                                                                      precItemChargeWkshtEntry."Distribution Type",
                                                                      true)
                                        else
                                            jfInsertSingleAssgntPurch(precPurchHeader,
                                                                      lrecPurchLine,
                                                                      precItemChargeWkshtEntry."Applies-To Functional Area",
                                                                      lrecAppliesToPurchLine."Document Type",
                                                                      lrecAppliesToPurchLine."Document No.",
                                                                      lrecAppliesToPurchLine."Line No.",
                                                                      precItemChargeWkshtEntry."Distribution Type",
                                                                      false);
                                    until lrecAppliesToPurchLine.Next = 0;
                                end;
                            end;
                        precItemChargeWkshtEntry."Applies-To Functional Area"::Sales:
                            begin
                                lrecAppliesToSalesLine.Reset;

                                lrecAppliesToSalesLine.SetRange("Document Type", precItemChargeWkshtEntry."Applies-To Document Type");
                                lrecAppliesToSalesLine.SetRange("Document No.", precItemChargeWkshtEntry."Applies-To Document No.");
                                lrecAppliesToSalesLine.SetRange("Line No.");

                                lrecAppliesToSalesLine.SetRange("Allow Item Charge Assignment", true);
                                lrecAppliesToSalesLine.SetFilter(Quantity, '<>%1', 0);

                                if not lrecAppliesToSalesLine.IsEmpty then begin
                                    lintTotal := lrecAppliesToSalesLine.Count;
                                    lintCount := 0;

                                    lrecAppliesToSalesLine.Find('-');

                                    repeat
                                        lintCount += 1;

                                        if lintCount = lintTotal then begin
                                            jfInsertSingleAssgntPurch(precPurchHeader,
                                                                      lrecPurchLine,
                                                                      precItemChargeWkshtEntry."Applies-To Functional Area",
                                                                      lrecAppliesToSalesLine."Document Type",
                                                                      lrecAppliesToSalesLine."Document No.",
                                                                      lrecAppliesToSalesLine."Line No.",
                                                                      precItemChargeWkshtEntry."Distribution Type",
                                                                      true);
                                        end else begin
                                            jfInsertSingleAssgntPurch(precPurchHeader,
                                                                      lrecPurchLine,
                                                                      precItemChargeWkshtEntry."Applies-To Functional Area",
                                                                      lrecAppliesToSalesLine."Document Type",
                                                                      lrecAppliesToSalesLine."Document No.",
                                                                      lrecAppliesToSalesLine."Line No.",
                                                                      precItemChargeWkshtEntry."Distribution Type",
                                                                      false);
                                        end;
                                    until lrecAppliesToSalesLine.Next = 0;
                                end;
                            end;
                        precItemChargeWkshtEntry."Applies-To Functional Area"::Transfer:
                            begin
                                lrecAppliesToTransLine.Reset;

                                lrecAppliesToTransLine.SetRange("Document No.", precItemChargeWkshtEntry."Applies-To Document No.");
                                lrecAppliesToTransLine.SetRange("Line No.");

                                lrecAppliesToTransLine.SetFilter(Quantity, '<>%1', 0);
                                lrecAppliesToTransLine.SetRange("Derived From Line No.", 0);

                                if not lrecAppliesToTransLine.IsEmpty then begin
                                    lintTotal := lrecAppliesToTransLine.Count;
                                    lintCount := 0;

                                    lrecAppliesToTransLine.Find('-');

                                    repeat
                                        lintCount += 1;

                                        if lintCount = lintTotal then
                                            jfInsertSingleAssgntPurch(precPurchHeader,
                                                                      lrecPurchLine,
                                                                      precItemChargeWkshtEntry."Applies-To Functional Area",
                                                                      0,
                                                                      lrecAppliesToTransLine."Document No.",
                                                                      lrecAppliesToTransLine."Line No.",
                                                                      precItemChargeWkshtEntry."Distribution Type",
                                                                      true)
                                        else
                                            jfInsertSingleAssgntPurch(precPurchHeader,
                                                                      lrecPurchLine,
                                                                      precItemChargeWkshtEntry."Applies-To Functional Area",
                                                                      0,
                                                                      lrecAppliesToTransLine."Document No.",
                                                                      lrecAppliesToTransLine."Line No.",
                                                                      precItemChargeWkshtEntry."Distribution Type",
                                                                      false);
                                    until lrecAppliesToTransLine.Next = 0;
                                end;
                            end;
                    end;

                    if lrecPurchSetup."Retain Exp. Purch. Cost Detail" then begin
                        precItemChargeWkshtEntry.Processed := true;
                        precItemChargeWkshtEntry."Document No." := precPurchHeader."No.";
                        precItemChargeWkshtEntry.Modify;
                    end else begin
                        precItemChargeWkshtEntry.Delete(true);
                    end;
                end;
            precItemChargeWkshtEntry."Cost Type"::Line:
                begin
                    jfInsertSingleAssgntPurch(precPurchHeader,
                                              lrecPurchLine,
                                              precItemChargeWkshtEntry."Applies-To Functional Area",
                                              precItemChargeWkshtEntry."Applies-To Document Type",
                                              precItemChargeWkshtEntry."Applies-To Document No.",
                                              precItemChargeWkshtEntry."Applies-To Document Line No.",
                                              precItemChargeWkshtEntry."Distribution Type",
                                              true);

                    if lrecPurchSetup."Retain Exp. Purch. Cost Detail" then begin
                        precItemChargeWkshtEntry.Processed := true;
                        precItemChargeWkshtEntry."Document No." := precPurchHeader."No.";
                        precItemChargeWkshtEntry.Modify;
                    end else begin
                        precItemChargeWkshtEntry.Delete(true);
                    end;
                end;
        end;
    end;

}

