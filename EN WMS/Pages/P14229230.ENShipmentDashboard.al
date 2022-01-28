//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Shipment Dashboard (ID 14229230).
/// </summary>
page 14229230 "Shipment Management ELA"
{
    Caption = 'Shipment Management';
    ApplicationArea = All;
    DeleteAllowed = false;
    PageType = Worksheet;
    PromotedActionCategories = 'Pick,Documents,Reports,Actions,Other Activities';
    RefreshOnActivate = true;
    ShowFilter = false;
    UsageCategory = Lists;
    SaveValues = false;
    SourceTable = "Shipment Dashboard ELA";
    SourceTableView = SORTING("Parent ID")
                      ORDER(Ascending);
    layout
    {
        area(content)
        {
            group(Group)
            {
                Caption = 'Filters';
                field(DateFilter; ShipDateFilter)
                {
                    Caption = 'Date Filter';
                    trigger OnValidate()
                    begin
                        PopulateData;
                    end;
                }
                field(OrderNoFilter; OrderNoFilter)
                {
                    Caption = 'Order No. Filter';

                    trigger OnValidate()
                    begin
                        PopulateData;
                    end;
                }
                field(ItemNoFilter; ItemNoFilter)
                {
                    Caption = 'Item No. Filter';

                    trigger OnValidate()
                    begin
                        PopulateData;
                    end;
                }
                field(LocationFilter; LocationFilter)
                {
                    Caption = 'Location Filter';
                    DrillDown = true;
                    Lookup = true;
                    TableRelation = Location.Code WHERE(
                                                         // "Require Pick" = CONST(true),
                                                         "Require Shipment" = CONST(true)
                                                         //  "Use Loc. for WMS" = CONST(true)
                                                         );
                    trigger OnValidate()
                    begin
                        PopulateData;
                    end;
                }

                field(TripIDFilter; TripIDFilter)
                {

                    Caption = 'Trip No. Filter';
                    DrillDown = true;
                    Lookup = true;
                    TableRelation = "Trip Load ELA"."No." where(Direction = const(Outbound));
                    //where(Status = Filter(Status::Open | Status::"In Progress"));
                    trigger OnValidate()
                    begin
                        PopulateData;
                    end;
                }

                field(ShowPickedOnly; ShowPickedOnly)
                {
                    Caption = 'Orders with Pick Tickets';
                    trigger OnValidate()
                    begin
                        PopulateData;
                    end;
                }
                field(ShowProcessedOnly; ShowProcessedOnly)
                {
                    Caption = 'Show Picked Orders';

                    trigger OnValidate()
                    begin
                        PopulateData();
                    end;
                }
                field(ShowSelectedOnly; ShowSelectedOnly)
                {
                    Caption = 'Show Selected Only';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        PopulateData;
                    end;
                }
                field(ShowUnassignedOnly; ShowUnassignedOnly)
                {
                    Caption = 'Show Un-assigned';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        PopulateData;
                    end;
                }
                field(DocumentFilter; DocumentFilter)
                {
                    Caption = 'Document Type Filter';

                    trigger OnValidate()
                    begin
                        PopulateData;
                    end;
                }
            }
            repeater(Group1)
            {
                FreezeColumn = "Source No.";
                IndentationColumn = Level;
                IndentationControls = "Parent ID";
                ShowAsTree = true;
                // TreeInitialState = CollapseAll;
                field(Level; Level)
                {
                    Visible = false;
                }
                field(Select; Select)
                {
                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Parent ID"; "Parent ID")
                {
                    Visible = false;
                }
                field(Completed; Completed)
                {
                    Caption = 'Picked';
                    Editable = false;
                }
                field("External Order No."; "External Doc. No.")
                {
                    Editable = false;
                    Visible = true;
                }
                field("Shipment Line No."; "Shipment Line No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Customer No."; "Destination No.")
                {
                    Caption = 'Customer No.';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                    Visible = true;
                }

                field("Trip No."; "Trip No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = strong;
                    StyleExpr = true;
                    Visible = true;
                }

                field("Source No."; "Source No.")
                {
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                    Visible = true;
                }
                field("Source Line No."; "Source Line No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    Editable = false;
                }
                field("Ship-to Address"; "Ship-to Address")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Ship-to Address 2"; "Ship-to Address 2")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Ship-to City"; "Ship-to City")
                {
                    Editable = false;
                }
                field("Ship-to State"; "Ship-to State")
                {
                    Editable = false;
                    Visible = false;
                }
                // field(Status; Status)
                // {
                //     Editable = false;
                //     Visible = false;
                // }
                field("Shipment Date"; "Shipment Date")
                {
                    Caption = 'Ship Date';
                    Editable = false;
                }

                field("Item No."; "Item No.")
                {
                    Editable = false;
                }
                field("Item Description"; "Item Description")
                {
                    Editable = false;
                }
                field("Orig. Ordered Qty."; "Orig. Ordered Qty.")
                {
                    DecimalPlaces = 2 : 0;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = ExAttention;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        if "Orig. Ordered Qty." > 0 then
                            ExAttention := false
                        else
                            ExAttention := true;

                        //CurrPage.UPDATE(FALSE);
                    end;
                }
                field("Last Modified Qty."; "Last Modified Qty.")
                {
                    Caption = 'Last Qty.';
                    DecimalPlaces = 2 : 0;
                    Editable = false;
                }
                field("Qty. Reqd."; "Qty. Reqd.")
                {
                    DecimalPlaces = 2 : 0;
                    Editable = false;
                    Style = Strong;

                    trigger OnValidate()
                    begin
                        if "Qty. Reqd." > 0 then
                            ExAttention := false
                        else
                            ExAttention := true;

                        CurrPage.Update(false);
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    Caption = 'UOM';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Qty. Avail."; "Qty. Avail.")
                {
                    Caption = 'Avail.';
                    DecimalPlaces = 2 : 0;
                    Editable = false;
                }
                field("Short By Qty."; "Short By Qty.")
                {
                    Caption = 'Short';
                    DecimalPlaces = 2 : 0;
                    Editable = false;
                    Style = Attention;

                    trigger OnValidate()
                    begin
                        if "Short By Qty." < 0 then
                            ExAttention := true
                        else
                            ExAttention := false;
                    end;
                }
                field("Qty. To Ship"; "Qty. To Ship")
                {
                    Caption = 'Ship';
                    DecimalPlaces = 2 : 0;
                    Style = Favorable;
                    StyleExpr = TRUE;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Cut/Overship"; "Cut/Overship")
                {
                    DecimalPlaces = 2 : 0;
                }
                field("Back Order Qty."; "Back Order Qty.")
                {
                    Caption = 'Back Order';
                    DecimalPlaces = 2 : 0;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = TRUE;
                }
                field("Qty. On Pick"; "Qty. On Pick")
                {
                    Caption = 'On Pick';
                }
                field("Picked Qty."; "Picked Qty.")
                {
                    Caption = 'Picked Qty.';
                    DecimalPlaces = 2 : 0;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                    Visible = true;
                }
                field("Has Qty. Allocated"; "Has Qty. Allocated")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Ship Action"; "Ship Action")
                {
                    //todo #13 @Kamranshehzad fix the action as it crashes the app.
                    Caption = 'Action';
                    Style = Attention;
                    StyleExpr = TRUE;
                }
                field("Assigned App. Role"; "Assigned App. Role")
                {
                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Assigned App. User"; "Assigned App. User")
                {
                    Visible = true;
                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field(Location; Location)
                {
                    Editable = false;
                    Visible = false;
                }
                field("Last Updated"; "Last Updated")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Full Pick"; "Full Pick")
                {
                    Caption = 'Full';
                    Editable = false;
                }
                field("Partial Pick"; "Partial Pick")
                {
                    Caption = 'Partial';
                    Editable = false;
                }
                // field("Receive To Pick"; "Receive To Pick")
                // {
                //     Caption = 'Auto Pick';
                //     Editable = false;
                // }
                field("Release to QC"; "Release to QC")
                {
                    Caption = 'Release to QC';
                    Editable = false;
                }
                field("Assigned QC User"; "Assigned QC User")
                {
                    Editable = true;
                }
                field("QC Completed"; "QC Completed")
                {
                    Caption = 'QC Completed';
                    Editable = false;
                }
                field("Locked By User ID"; "Locked By User ID")
                {
                    Caption = 'Locked By';
                    Editable = false;
                }
                field("Shipment No."; "Shipment No.")
                {
                    Editable = false;
                }


                // field("Packing Unit"; "Packing Unit")
                // {
                //     Visible = false;
                // }
            }
            group(Statistics)
            {
                Caption = 'Statistics';
                Visible = false;
                field(StatItemNo; StatItemNo)
                {
                    Caption = 'Item No.';
                    Editable = false;
                }
                field(StatItemDesc; StatItemDesc)
                {
                    Caption = 'Description';
                    Editable = false;
                }
                field(StatTotalRequiredQty; StatTotalRequiredQty)
                {
                    Caption = 'Total Reqd. Qty.';
                    Editable = false;
                }
                field(StatTotalAvailableQty; StatTotalAvailableQty)
                {
                    Caption = 'Total Avail. Qty.';
                    Editable = false;
                }
                field(StatTotalAllocatedQty; StatTotalAllocatedQty)
                {
                    Caption = 'Total Allocated Qty.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Actions")
            {
                action("Select A&ll")
                {
                    Caption = 'Select A&ll';
                    Image = SelectEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                }
                action("<Action1000000020>")
                {
                    Caption = '&Create Pick';
                    Image = CreateWarehousePick;
                    Promoted = true;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        UseTrip: Boolean;
                    begin
                        UseTrip := false;
                        if "Trip No." <> '' then
                            UseTrip := true;

                        ShipDBMgt.CreatePickTicketFromWhseShipment("Shipment No.", UserId, "Trip No.");
                        DeSelectOrder("Trip No.", "Source No.", UseTrip);
                        PopulateData;
                        PAGE.Run(14229235);
                        CurrPage.Update;
                    end;
                }
                action("Bin Allocations")
                {
                    Caption = 'Bin Allocations';
                    Image = ResourcePrice;
                    Promoted = true;
                    PromotedCategory = New;
                    PromotedIsBig = false;
                    // RunObject = Page "Picking Bin Allocation";
                }
                action("Show Pick Ticket")
                {
                    Caption = 'Show &Pick Ticket';
                    Image = OpenWorksheet;
                    Promoted = true;
                    PromotedCategory = New;
                    PromotedIsBig = false;

                    trigger OnAction()
                    var
                        ShipDashBrd: Record "Shipment Dashboard ELA";
                        WhseActivityLine: Record "Warehouse Activity Line";
                        WhseActivityHdr: Record "Warehouse Activity Header";
                        TmpWhseActivityHdr: Record "Warehouse Activity Header";
                        i: Integer;
                        LastPickNo: Code[20];
                        PickTicketFilterStr: Text[250];
                    begin
                        ShipDashBrd.Reset;
                        ShipDashBrd.SetRange("Shipment No.", "Shipment No.");
                        ShipDashBrd.SetRange(Level, 0);
                        if ShipDashBrd.FindFirst then
                            WhseActivityLine.Reset;

                        WhseActivityLine.SetRange("Whse. Document No.", ShipDashBrd."Shipment No.");
                        if WhseActivityLine.FindSet then begin
                            i := 1;
                            Clear(PickTicketNo);
                            repeat
                                if LastPickNo <> WhseActivityLine."No." then begin
                                    LastPickNo := WhseActivityLine."No.";
                                    PickTicketNo[i] := WhseActivityLine."No.";
                                    i := i + 1;
                                end;
                            until WhseActivityLine.Next = 0;

                            i := 1;
                            PickTicketFilterStr := '';
                            WhseActivityHdr.Reset;
                            WhseActivityHdr.SetFilter(Type, '%1', WhseActivityHdr.Type::Pick);
                            for i := 1 to 10 do begin
                                if PickTicketNo[i] <> '' then
                                    if i = 1 then
                                        PickTicketFilterStr := PickTicketNo[i]
                                    else
                                        PickTicketFilterStr := PickTicketFilterStr + '|' + PickTicketNo[i];
                            end;

                            WhseActivityHdr.SetFilter("No.", PickTicketFilterStr);
                            PAGE.Run(9313, WhseActivityHdr);
                        end;
                    end;
                }
                action("<Action1000000063>")
                {
                    Caption = '&Task Queue';
                    Image = EntriesList;
                    Promoted = true;
                    PromotedCategory = New;
                    PromotedIsBig = false;
                    // RunObject = Page "Whse. Tasks";
                }
                separator(Action1000000019)
                {
                }
                action("<Action1000000036>")
                {
                    Caption = '&Show Source Document';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        SalesHdr: Record "Sales Header";
                        TransHdr: Record "Transfer Header";
                    begin
                        if "Source Document" = "Source Document"::"Sales Order" then begin
                            if SalesHdr.Get(SalesHdr."Document Type"::Order, "Source No.") then
                                PAGE.Run(42, SalesHdr);
                        end else
                            if "Source Document" = "Source Document"::"Outbound Transfer" then begin
                                if TransHdr.Get("Source No.") then
                                    PAGE.Run(5740, TransHdr);
                            end;
                    end;
                }
                action("Registered Pick Lines")
                {
                    Caption = '&Registered Pick Lines';
                    Image = RegisteredDocs;
                    Promoted = True;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = page "Registered Whse. Act.-Lines";
                    RunPageView = SORTING("Whse. Document Type", "Whse. Document No.", "Whse. Document Line No.") WHERE("Whse. Document Type" = CONST(Shipment));
                    RunPageLink = "Whse. Document No." = FIELD("Shipment No.");

                }
                action("Registered Pick")
                {
                    Caption = '&Pick Manifest';
                    Image = RegisteredDocs;
                    Promoted = True;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        RegisteredPickLines: Record "Registered Whse. Activity Line";
                        RegisteredPickLines2: Record "Registered Whse. Activity Line";
                        PickManifest: page "Pick Manifest ELA";
                    begin
                        RegisteredPickLines.RESET;
                        RegisteredPickLines.SetRange("Whse. Document No.", Rec."Shipment No.");
                        IF RegisteredPickLines.FindFirst() then begin
                            RegisteredPickLines2.RESET;
                            RegisteredPickLines2.SetRange("No.", RegisteredPickLines."No.");
                            RegisteredPickLines2.SetRange("Action Type", RegisteredPickLines."Action Type"::Take);
                            RegisteredPickLines2.SetRange("Whse. Document Type", RegisteredPickLines."Whse. Document Type");
                            IF RegisteredPickLines2.FINDSET then begin
                                PickManifest.SetTableView(RegisteredPickLines2);
                                PickManifest.Run();
                            end;
                        end;

                    end;

                }

                action("Release to QC ELA")
                {
                    caption = 'Release to QC';
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        ShipDashBrd: record "Shipment Dashboard ELA";
                        ShipmentMgmt: Codeunit "Shipment Mgmt. ELA";
                        AssignedQCUser: Report "Assigned QC User ELA";
                        AssignedUser: Code[20];
                    begin
                        AssignedQCUser.RunModal();
                        IF NOT AssignedQCUser.ExecutedOk(AssignedUser) then
                            Error('');

                        if Level = 0 then begin
                            ShipDashBrd.Reset;
                            ShipDashBrd.SetRange("Parent ID", ID);
                            ShipDashBrd.SetRange(Level, 1);
                            ShipDashBrd.SetFilter("Picked Qty.", '>%1', 0);
                            if ShipDashBrd.FindSet then
                                repeat
                                    ShipmentMgmt.WhseShipmentReleaseToQC(ShipDashBrd."Shipment No.", ShipDashBrd."Shipment Line No.", true);
                                    ShipmentMgmt.WhseShipmentAssignQCUser(ShipDashBrd."Shipment No.", ShipDashBrd."Shipment Line No.", AssignedUser);
                                until ShipDashBrd.Next = 0;
                        end else begin
                            if (Level = 1) then begin
                                Rec.TestField("Picked Qty.");
                                ShipmentMgmt.WhseShipmentReleaseToQC(Rec."Shipment No.", Rec."Shipment Line No.", true);
                                ShipmentMgmt.WhseShipmentAssignQCUser(Rec."Shipment No.", Rec."Shipment Line No.", AssignedUser);

                            end;
                        end;

                        CurrPage.Update();
                    end;
                }

                action("Reopen For QC ELA")
                {
                    caption = 'Reopen For QC';
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        ShipDashBrd: record "Shipment Dashboard ELA";
                        ShipmentMgmt: Codeunit "Shipment Mgmt. ELA";
                        AssignedQCUser: Report "Assigned QC User ELA";
                        AssignedUser: Code[20];
                    begin
                        if Level = 0 then begin
                            ShipDashBrd.Reset;
                            ShipDashBrd.SetRange("Parent ID", ID);
                            ShipDashBrd.SetRange(Level, 1);
                            if ShipDashBrd.FindSet then
                                repeat
                                    ShipmentMgmt.WhseShipmentReleaseToQC(ShipDashBrd."Shipment No.", ShipDashBrd."Shipment Line No.", false);
                                    ShipmentMgmt.WhseShipmentAssignQCUser(ShipDashBrd."Shipment No.", ShipDashBrd."Shipment Line No.", '');
                                until ShipDashBrd.Next = 0;
                        end else begin
                            if (Level = 1) then begin
                                Rec.TestField("Picked Qty.");
                                ShipmentMgmt.WhseShipmentReleaseToQC(Rec."Shipment No.", Rec."Shipment Line No.", false);
                                ShipmentMgmt.WhseShipmentAssignQCUser(Rec."Shipment No.", Rec."Shipment Line No.", '');

                            end;
                        end;

                        CurrPage.Update();
                    end;
                }
                action("QC Complete")
                {
                    caption = 'QC Complete';
                    Image = Completed;
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        ShipDashBrd: record "Shipment Dashboard ELA";
                        ShipmentMgmt: Codeunit "Shipment Mgmt. ELA";
                    begin
                        if Level = 0 then begin
                            ShipDashBrd.Reset;
                            ShipDashBrd.SetRange("Parent ID", ID);
                            ShipDashBrd.SetRange(Level, 1);
                            ShipDashBrd.SetFilter("Picked Qty.", '>%1', 0);
                            if ShipDashBrd.FindSet then
                                repeat
                                    ShipmentMgmt.WhseShipmentQCComplete(ShipDashBrd."Shipment No.", ShipDashBrd."Shipment Line No.", true);
                                until ShipDashBrd.Next = 0;
                        end else begin
                            if (Level = 1) then begin
                                Rec.TestField("Picked Qty.");
                                ShipmentMgmt.WhseShipmentQCComplete(Rec."Shipment No.", Rec."Shipment Line No.", true);
                            end;
                        end;

                        CurrPage.Update();
                    end;
                }
                // action("<Action1000000080>")
                // {
                //     Caption = 'Show Bread Order';
                //     Image = Document;
                //     Promoted = true;
                //     PromotedCategory = Process;
                //     Visible = false;

                //     trigger OnAction()
                //     var
                //         ProdSalesOrder: Record "Prod. Sales Order";
                //         SalesProdOrder: Page "Sales Prod. Order";
                //     begin
                //         //<<EN1.02
                //         if ProdSalesOrder.Get("Source No.") then begin
                //             SalesProdOrder.SetRecord(ProdSalesOrder);
                //             SalesProdOrder.Run;
                //         end;
                //         //>>EN1.02
                //     end;
                // }
                action("Show Whse. Shipment")
                {
                    Caption = 'Show &Whse. Shipment';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        WhseShipHdr: Record "Warehouse Shipment Header";
                        WhseShipment: Page "Warehouse Shipment";
                        WhseShipmentDocsList: Page "Warehouse Shipment List";
                        SelectedShipment: Record "Warehouse Shipment Header";
                        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
                        WhseShipmentLine: record "Warehouse Shipment Line";
                        ShipmentListFilter: text;
                    begin
                        WhseShipmentLine.reset;
                        if "Source No." <> '' then
                            WhseShipmentLine.SetRange("Source No.", "Source No.")
                        else
                            WhseShipmentLine.SetRange("No.", "Shipment No.");

                        if WhseShipmentLine.FindSet() then
                            repeat
                                if strlen(ShipmentListFilter) = 0 then
                                    ShipmentListFilter := WhseShipmentLine."No."
                                else
                                    ShipmentListFilter := ShipmentListFilter + '|' + WhseShipmentLine."No.";
                            until WhseShipmentLine.Next() = 0;

                        WarehouseShipmentHeader.Reset;
                        WarehouseShipmentHeader.SetRange("No.", ShipmentListFilter);
                        if WarehouseShipmentHeader.FindSet then begin
                            if WarehouseShipmentHeader.Count > 1 then begin
                                WhseShipmentDocsList.SetTableView(WarehouseShipmentHeader);
                                WhseShipmentDocsList.LookupMode(true);
                                if WhseShipmentDocsList.RunModal = ACTION::LookupOK then begin
                                    WhseShipmentDocsList.GetRecord(SelectedShipment);
                                    PAGE.Run(7335, SelectedShipment);
                                end;
                            end else
                                if WhseShipHdr.Get("Shipment No.") then
                                    PAGE.Run(7335, WhseShipHdr);
                        end;
                    end;
                }

                action("Show Trip")
                {
                    Caption = 'Show &Trip';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        OutboundLoad: record "Trip Load ELA";
                        OutboundTripLoad: page "Outbound Trip Load ELA";
                    begin
                        if OutboundLoad.Get("Trip No.", OutboundLoad.Direction::Outbound) then begin
                            OutboundTripLoad.SetRecord(OutboundLoad);
                            OutboundTripLoad.Run();
                        end;
                    end;
                }
                action("&Update Stock Info")
                {
                    Caption = '&Update Stock Info';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+F5';
                    Visible = false;

                    trigger OnAction()
                    begin
                        ShipDBMgt.UpdateAllShipStockInfo();
                    end;
                }
                action("<Action1000000012>")
                {
                    Caption = 'Sales Order List';
                    Image = Documents;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = false;
                    // RunObject = Page "Open Sales Orders List";
                }
                // action("<Action1000000069>")
                // {
                //     Caption = 'Bread Order List';
                //     Image = Documents;
                //     Promoted = true;
                //     PromotedCategory = Process;
                //     // RunObject = Page "Sales Prod. Order List";
                //     Visible = false;
                // }
                action("<Action1000000087>")
                {
                    Caption = 'Whse. Shipment List';
                    Image = Documents;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Warehouse Shipment List";
                }
                // action("<Action1000000056>")
                // {
                //     Caption = 'Show &Bill of Lading';
                //     Image = SourceDocLine;
                //     Promoted = true;
                //     PromotedCategory = Process;
                //     PromotedIsBig = false;

                //     trigger OnAction()
                //     var
                //         // BillOfLadingHdr: Record "EN WMS Bill of Lading Header";
                //         BillofLadingNo: Code[20];
                //         ShipDBMgt: Codeunit "EN Shipment Dashboard Mgmt.";
                //         TEXT001: Label 'Load date field must have value..';
                //         LoadID: Code[20];
                //     // DeliveryLoadHdr: Record "Delivery Load Header";
                //     // DeliveryLoadMgt: Codeunit "Delivery Load Mgt.";
                //     begin
                //         //<<EN1.x 7/6
                //         // DeliveryLoadHdr.Reset;
                //         // DeliveryLoadHdr.SetRange("Source Document No.", "Source No.");
                //         // DeliveryLoadHdr.SetRange("Load Type", DeliveryLoadHdr."Load Type"::"Shipment Load");
                //         // DeliveryLoadHdr.SetRange(Closed, false);
                //         // if not DeliveryLoadHdr.FindFirst then
                //         //     LoadID := ShipDBMgt.CreateDeliveryLoadHdr("Source No.", Location)
                //         // else
                //         //     LoadID := DeliveryLoadHdr."Load ID";

                //         if LoadID = '' then
                //             Error('Please run delivery load');

                //         // DeliveryLoadMgt.UpdatePalletInfoOnDocumentsCon("Source No.", LoadID);//EN1.02
                //         ClearLastError();
                //         if GetLastErrorText <> '' then
                //             Message('%1', GetLastErrorText);

                //         // BillOfLadingHdr.Reset;
                //         // // BillOfLadingHdr.SetRange("Sales Order No.", "Source No.");
                //         // // BillOfLadingHdr.SetRange("Load ID", LoadID);
                //         // if not BillOfLadingHdr.FindFirst then begin
                //         //     BillofLadingNo := ShipDBMgt.CreateBillOfLading("Source No.", '', LoadID);
                //         //     BillOfLadingHdr.Get(BillofLadingNo);
                //         // end;

                //         // PAGE.Run(50085, BillOfLadingHdr);
                //         CurrPage.Update;
                //         //>>EN1.x 7/6
                //     end;
                // }
                action("<Action1000000109>")
                {
                    Caption = 'Picker Orders';
                    Image = LotInfo;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                    // OrderPicker: Page "Order Picker List";
                    begin
                        // OrderPicker.Run;
                    end;
                }
                separator(Action1000000063)
                {
                }
                action("<Action1000000041>")
                {
                    Caption = 'Post S&hipments';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        WhseShipHdrList: Record "Warehouse Shipment Header";
                        WhseShipLine: Record "Warehouse Shipment Line";
                    begin
                        WhseShipLine.Reset();
                        WhseShipLine.SetRange("No.", "Shipment No.");
                        If WhseShipLine.FindFirst() THEN
                            CODEUNIT.RUN(CODEUNIT::"Whse.-Post Shipment (Yes/No)", WhseShipLine);
                        //ShipDBMgt.PostWHShipments("Source No.",TRUE); //<<EN1.01
                        //<<EN1.09
                        /*  ShipmentDashbord.Reset;
                          ShipmentDashbord.SetRange(ShipmentDashbord."Shipment No.", "Shipment No.");
                          if ShipmentDashbord.FindSet then
                              repeat
                                  if ShipmentDashbord."Qty. Reqd." = 0 then begin
                                      ShipDBMgt.AdjustShipQtyToOrderLine(ShipmentDashbord, ShipmentDashbord."Shipment No.", ShipmentDashbord."Shipment Line No.",
                                        ShipmentDashbord."Qty. To Ship" + ShipmentDashbord."Picked Qty." + ShipmentDashbord."Qty. On Pick");
                                  end;
                              until ShipmentDashbord.Next = 0;
                          // //>>EN1.09 //tbr*/
                        /* WhseShipHdrList.Reset;
                         WhseShipHdrList.SetRange(WhseShipHdrList."No.", "Shipment No.");
                         if WhseShipHdrList.FindSet then
                             repeat
                                 ShipDBMgt.PostWHShipments("Source No.", true); //<<EN1.01 
                             until WhseShipHdrList.Next = 0;
 */
                        //<<EN1.10 //tbr
                        ShipmentDashbord.Reset;
                        ShipmentDashbord.SetRange("Shipment No.", "Shipment No.");
                        if ShipmentDashbord.FindFirst then begin
                            WhseShipHdrList.Reset;
                            WhseShipHdrList.SetRange("No.", "Shipment No.");
                            if not WhseShipHdrList.FindFirst then
                                ShipmentDashbord.DeleteAll;
                        end;
                        //>>EN1.10

                        ResetFilters;
                        CurrPage.Update;
                    end;
                }
                action("<Action1000000057>")
                {
                    Caption = '&Delete Shipment';
                    Image = Delete;

                    trigger OnAction()
                    begin
                        ShipDBMgt.DeleteWHShipmentInfo("Shipment No.");
                        ResetFilters;
                        CurrPage.Update;
                    end;
                }
                // action("<Action1000000076>")
                // {
                //     Caption = 'Get Order to Ship';
                //     Image = OrderList;
                //     Promoted = true;
                //     PromotedCategory = Category4;
                //     // RunObject = Page "Release Orders";
                // }
                action("Change Location")
                {
                    Image = Replan;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    begin
                        Single := false;
                        if (Rec."Full Pick") then
                            Error(TEXT004);

                        /*IF(Rec."Partial Pick") OR (Rec."Full Pick") AND (Rec.Level <> 0) THEN
                          ERROR(TEXT005); */

                        if Rec.Level <> 0 then
                            Single := true;
                        Loc := Rec.Location;
                        // ChangeLocation.SetShipmentHdr("Shipment No.");
                        // ChangeLocation.SetShipmentLine("Shipment Line No.");
                        // ChangeLocation.RunModal;
                        /*IF Single THEN BEGIN
                          Rec.DELETE;
                        END;*/
                        CurrPage.Update;

                    end;
                }
                action("<Action1000000018>")
                {
                    Caption = 'Re&fresh (F2)';
                    Image = Refresh;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'F2';

                    trigger OnAction()
                    begin
                        PopulateData;
                        CurrPage.Update;
                    end;
                }
                separator(Action1000000067)
                {
                }
                action("<Action1000000046>")
                {
                    Caption = 'Apply &Cut';
                    Image = ClosePeriod;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    Visible = false;

                    trigger OnAction()
                    begin
                        ShipDBMgt.ApplyCutQty("Source No.", UserId); //<<EN1.01
                    end;
                }

                action("Bulk Cut")
                {
                    Caption = 'Bulk Cut';
                    Image = CalculateShipment;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = true;
                    trigger OnAction()
                    var
                        myInt: Integer;
                    begin
                        ShipDBMgt.ApplyBulkCutQty("Shipment No.", "Trip No.", UserId); //<<EN1.01
                        CurrPage.Update();
                    end;
                }
                // action("<Action1000000042>")
                // {
                //     Caption = '&Allocate Stock';
                //     Image = SuggestLines;
                //     Promoted = true;
                //     PromotedCategory = Category5;

                //     trigger OnAction()
                //     var
                //     // ShipQtyAllocation: Page "Ship Qty Allocation";
                //     begin
                //         if "Item No." = '' then
                //             Error(TEXT001);

                //         ShipDBMgt.LoadStockAdjustmentInfo("Item No.");
                //         // ShipQtyAllocation.SetParams("Item No.", Location);
                //         // ShipQtyAllocation.Run;
                //     end;
                // }
                // action("<Action1000000048>")
                // {
                //     Caption = 'Item Re-Pac&k';
                //     Image = SelectItemSubstitution;
                //     Promoted = true;
                //     PromotedCategory = Category5;
                //     Visible = false;
                // }
                // action("<Action1000000248>")
                // {
                //     Caption = 'Daily/Order Subsitution';
                //     Image = SelectItemSubstitution;
                //     Promoted = true;
                //     PromotedCategory = Category5;

                //     trigger OnAction()
                //     var
                //     // ItemSubstWksht: Page "Daily/Order Item Substitution";
                //     begin
                //         //<<EN1.03
                //         // if Confirm(StrSubstNo(TEXT003, "Source No.")) then
                //         //     ItemSubstWksht.SetOrderNoFilter("Source No.");
                //         // ItemSubstWksht.Run;

                //         //>>EN1.03
                //     end;
                // }
                // action("Item Subsitution")
                // {
                //     Caption = 'Item Subsitution';
                //     Image = SelectItemSubstitution;
                //     Promoted = true;
                //     PromotedCategory = Category5;

                //     trigger OnAction()
                //     var
                //     // ItemSubWksht: Page "Item Substitution Wksht.";
                //     begin
                //         if "Item No." <> '' then begin
                //             // Clear(ItemSubWksht);
                //             // ItemSubWksht.SetValues("Item No.", "Unit of Measure Code", Location, "Qty. Reqd.", "Source No.");
                //             // ItemSubWksht.Run;
                //         end;
                //     end;
                // }
                action("<Action212>")
                {
                    Caption = '&Bin Contents';
                    Image = BinContent;
                    Promoted = true;
                    PromotedCategory = Category5;
                    RunPageMode = View;

                    trigger OnAction()
                    var
                        BinContent: Record "Bin Content";
                    begin
                        if "Item No." <> '' then begin
                            BinContent.Reset;
                            BinContent.SetRange("Location Code", Location);
                            BinContent.SetRange("Item No.", "Item No.");
                            if PAGE.RunModal(0, BinContent) = ACTION::LookupOK then
                                exit;
                        end;
                    end;
                }
                action("<Action1000000068>")
                {
                    Caption = '&Movment Wksht';
                    Image = CalculateBinReplenishment;
                    Promoted = true;
                    PromotedCategory = Category5;
                    RunObject = Page "Movement Worksheet";
                    Visible = true;
                }
                action("<Action1000000023>")
                {
                    Caption = 'User Activities';
                    Image = EntriesList;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = false;
                    RunPageMode = View;
                    Visible = false;

                    trigger OnAction()
                    var
                    // WMSActivities: Page "Completed WMS Activites";
                    begin
                        // Clear(WMSActivities);
                        // //WMSActivities.SetFilters("",1);
                        // WMSActivities.Run;
                    end;
                }
                action("<Action1000000236>")
                {
                    Caption = 'WMS Activity Log';
                    Image = EntriesList;
                    Promoted = true;
                    PromotedCategory = Category5;
                    // RunObject = Page "Whse. Activity Log";
                    RunPageMode = View;
                    Visible = false;
                }
                action("<Action1000000044>")
                {
                    Caption = 'Users Info';
                    Image = Setup;
                    Promoted = true;
                    PromotedCategory = Category5;
                    // RunObject = Page "WMS Users";
                    RunPageMode = View;
                }
                action("<Action1000000045>")
                {
                    Caption = 'User Sessions';
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Category5;
                    RunObject = Page "App. Sessions ELA";
                    Visible = false;
                }
                // action("WMS Roles")
                // {
                //     Caption = 'WMS Roles';
                //     Image = EntriesList;
                //     Promoted = false;
                //     //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //     //PromotedCategory = Category5;
                //     RunObject = Page "EN App. Roles";
                //     RunPageMode = View;
                //     Visible = false;
                // }
                // action("<Action1000000097>")
                // {
                //     Caption = 'Customer Documents';
                //     Image = Documents;
                //     Promoted = true;
                //     PromotedCategory = Category4;
                //     // RunObject = Page "Customer Document Search";
                // }
                // action("Bill of Lading")
                // {
                //     Caption = 'Bill of Lading';
                //     Promoted = true;
                //     PromotedCategory = "Report";
                //     Visible = false;

                //     trigger OnAction()
                //     var
                //         SalesHeader: Record "Sales Header";
                //     // BOLReport: Report "Bill of Lading Info";
                //     begin
                //         if SalesHeader.Get(SalesHeader."Document Type"::Order, "Source No.") then begin
                //             // BOLReport.SetTableView(Rec);
                //             // BOLReport.Run;
                //         end;
                //     end;
                // }
                // action("Delivery Note")
                // {
                //     Caption = 'Delivery Note';
                //     Promoted = true;
                //     PromotedCategory = "Report";
                //     Visible = false;

                //     trigger OnAction()
                //     var
                //         SalesHeader: Record "Sales Header";
                //     // DeliveryNote: Report "Delivery Note";
                //     begin
                //         if SalesHeader.Get(SalesHeader."Document Type"::Order, "Source No.") then begin
                //             // DeliveryNote.IntializeSalesHeader(SalesHeader."No.");
                //             // DeliveryNote.Run;
                //         end;
                //     end;
                // }
                // action("<Action100000294>")
                // {
                //     Caption = 'Export Bill Of Ladings';
                //     Image = Export;
                //     Promoted = true;
                //     PromotedCategory = Process;
                //     // RunObject = Report "Export Bill of ladings";
                //     Visible = false;
                // }
                // action("Inventory Routines")
                // {
                //     Caption = 'Inventory Routines';
                //     Image = TaskList;
                //     Promoted = true;
                //     PromotedCategory = Process;
                //     // RunObject = Page "Inventory Routines";
                // }
                // action("<Action1000000114>")
                // {
                //     Caption = 'Shipment Load';
                //     Image = Document;
                //     Promoted = true;
                //     PromotedCategory = Process;

                //     trigger OnAction()
                //     var
                //         SalesHeader: Record "Sales Header";
                //     // DeliveryLoadList: Page "EN Shipment Load List";
                //     // DeliveryLoadHdr: Record "EN Delivery Load Header";
                //     // ShipmentLoad: Page "EN Shipment Load";
                //     begin
                //         //EN1.12
                //         if SalesHeader.Get(SalesHeader."Document Type"::Order, "Source No.") then begin
                //             // DeliveryLoadHdr.Reset;
                //             // DeliveryLoadHdr.SetRange(DeliveryLoadHdr."Source Document No.", "Source No.");
                //             // if DeliveryLoadHdr.Count = 0 then
                //             //     ShipDBMgt.CreateDeliveryLoadHdr("Source No.", Location);  //EN1.11

                //             // //DeliveryLoadHdr.SETFILTER(Closed,'=%1',FALSE);  //EN1.19
                //             // if DeliveryLoadHdr.Count = 1 then begin
                //             //     if DeliveryLoadHdr.FindFirst then begin
                //             //         ShipmentLoad.SetTableView(DeliveryLoadHdr);
                //             //         ShipmentLoad.Run;
                //             //     end;
                //             // end else begin
                //             //     DeliveryLoadHdr.SetRange(Closed);
                //             //     if DeliveryLoadHdr.FindSet then begin
                //             //         DeliveryLoadList.SetTableView(DeliveryLoadHdr);
                //             //         DeliveryLoadList.Run;
                //             //     end;
                //             // end;
                //         end;
                //         //>EN1.12
                //     end;
                // }
                separator(Action1000000089)
                {
                }
                // action("<Action50001>")
                // {
                //     Caption = 'Hit List';
                //     Promoted = true;
                //     PromotedCategory = "Report";
                //     PromotedIsBig = false;

                //     trigger OnAction()
                //     begin
                //         ///HitListReportReport50118
                //         ///HitList.SetScheduled(FALSE); //EN1.07
                //         ///HitList.RUN;
                //     end;
                // }
                // action("Hit List Snapshot View")
                // {
                //     Caption = 'Hit List Snapshot View';
                //     Image = "Report";
                //     Promoted = true;
                //     PromotedCategory = "Report";

                //     trigger OnAction()
                //     begin
                //         // PAGE.Run(50137);
                //     end;
                // }
                // action("Hit List 2")
                // {
                //     Caption = 'Hit List 2';

                //     trigger OnAction()
                //     begin
                //         ///HitListReportReport50117
                //         ///HitList.SetScheduled(FALSE); //EN1.0x ks
                //         ///HitList.RUN;
                //     end;
                // }
                action("<Action50000>")
                {
                    Caption = 'Order Status';
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = false;
                    // RunObject = Report "Order Status List";
                }
                action("<Action50200>")
                {
                    Caption = 'Shipment Status';
                    Promoted = true;
                    PromotedCategory = "Report";
                    // RunObject = Report "Shipment Status List";
                }
                // action("Rack Utilization")
                // {
                //     Caption = 'Rack Utilization';
                //     Promoted = true;
                //     PromotedCategory = "Report";
                //     Visible = false;

                //     trigger OnAction()
                //     begin
                //         // REPORT.Run(50148);
                //     end;
                // }
                // action("WH Audit Trail")
                // {
                //     Caption = 'WH Audit Trail';
                //     Promoted = true;
                //     PromotedCategory = "Report";
                //     // RunObject = Report "WMS Audit TrailXXX";
                //     Visible = false;
                // }
                // action("<Action1000000088>")
                // {
                //     Caption = 'WH Audit Trail';
                //     Promoted = true;
                //     PromotedCategory = "Report";
                //     // RunObject = Report "WMS Audit Trail";
                // }
                action("Whse. Inventory")
                {
                    Caption = 'Whse. Inventory';
                    Promoted = true;
                    PromotedCategory = "Report";

                    trigger OnAction()
                    var
                    // WhseItemSummay: Report "WMS Item Summary";
                    begin
                        //Location Code,Bin Code,Item No.,Variant Code,Unit of Measure Code
                        // Clear(WhseItemSummay);
                        // //IF "Item No." <> '' THEN
                        // WhseItemSummay.SetItem("Item No.", 'WH148');
                        // WhseItemSummay.RunModal;
                        // Clear(WhseItemSummay);
                    end;
                }
                // action("<Action1000000123>")
                // {
                //     Caption = 'Cut-OverShip Report2';
                //     Image = "Report";
                //     Promoted = true;
                //     PromotedCategory = "Report";
                //     // RunObject = Report "Cut-OverShip Report2XXX";
                //     Visible = false;
                // }
                action("<Action1000000128>")
                {
                    Caption = 'Cut-OverShip Report';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    Visible = false;

                    trigger OnAction()
                    begin
                        REPORT.Run(50127);
                    end;
                }
                action("WMS Cut OverShip")
                {
                    Caption = 'WMS Cut OverShip';
                    Promoted = true;
                    PromotedCategory = "Report";
                    // RunObject = Report "Whse. Cut Overship";
                }
                // action("<Action5001102>")
                // {
                //     Caption = 'Pick Ticket';
                //     Image = "Report";
                //     Promoted = true;
                //     PromotedCategory = "Report";
                //     PromotedIsBig = false;

                //     trigger OnAction()
                //     var
                //         SalesHeader: Record "Sales Header";
                //         // PickListReport: Report "Picking List by Order New";
                //         // PickListByOrder: Report "Pick List By Order";
                //         ReleaseSalesDoc: Codeunit "Release Sales Document";
                //     begin

                //         if SalesHeader.Get(SalesHeader."Document Type"::Order, "Source No.") then begin
                //             // PickListByOrder.IntializeSalesHeader("Source No.");
                //             // SalesHeader.SetRecFilter;
                //             // PickListByOrder.SetTableView(SalesHeader);
                //             // PickListByOrder.Run;
                //             // Clear(PickListByOrder);
                //         end;
                //     end;
                // }
                action("<Action1000000100>")
                {
                    Caption = 'Clean up Orphaned';

                    trigger OnAction()
                    begin
                        ShipDBMgt.CleanOrphanedEntries;
                    end;
                }
                // action("<Action1000000276>")
                // {
                //     Caption = 'Picked Item List';
                //     Promoted = true;
                //     PromotedCategory = "Report";

                //     trigger OnAction()
                //     begin
                //         ///PickedItemsReportReport50206
                //         ///PickedItems.SetOrderNoFilter("Source No.");
                //         ///PickedItems.RUN
                //     end;
                // }
                action("Shipment Manifest Report")
                {
                    trigger OnAction()
                    var
                        WhseDocPrint: Codeunit "Warehouse Document-Print";
                        WhseShipmentHeader: Record "Warehouse Shipment Header";
                    begin
                        if WhseShipmentHeader.Get(Rec."Shipment No.") then begin
                            WhseDocPrint.PrintShptHeader(WhseShipmentHeader);
                        end;
                    end;
                }

                action("Show Container")
                {
                    ApplicationArea = Suite;
                    Caption = '&Container';
                    Image = ResourceGroup;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Shows Items in the container';
                    trigger OnAction()
                    var
                        ContMgmt: Codeunit "Container Mgmt. ELA";
                        WhseDocType: enum "Whse. Doc. Type ELA";
                        SourceDocTypeFilter: enum "WMS Source Doc Type ELA";
                        ActivityType: Enum "WMS Activity Type ELA";
                    begin
                        ContMgmt.ShowContainer(SourceDocTypeFilter::"Sales Order", '', Rec.Location, 1, rec."Source No.", WhseDocType::Shipment, Rec."Shipment No.",
                        ActivityType, '');
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        SETCURRENTKEY("ID", "Shipment Date", "Trip No.", "Source No.", "Shipment No.", Level);
        ShipDateFilter := '..' + Format(CalcDate('<+2D>', Today));
        "Whse. Employee".Reset;
        "Whse. Employee".SetRange("User ID", UserId);
        "Whse. Employee".SetRange(Default, true);
        if "Whse. Employee".FindFirst then
            LocationFilter := "Whse. Employee"."Location Code"
        else
            LocationFilter := '';

        PopulateData;
        CurrPage.Update;
    end;

    var
        ShipDBMgt: Codeunit "Shipment Mgmt. ELA";
        TripIDFilter: code[250];
        ShipDateFilter: Text[30];
        OrderNoFilter: Code[250];
        ItemNoFilter: Code[20];
        ICSourceFilter: Code[10];
        [InDataSet]
        ExAttention: Boolean;
        ShowProcessedOnly: Boolean;
        ShowPickedOnly: Boolean;
        ShowUnassignedOnly: Boolean;
        ShowSelectedOnly: Boolean;
        PickTicketNo: array[100] of Code[20];
        StatItemNo: Code[20];
        StatItemDesc: Text[50];
        StatTotalRequiredQty: Decimal;
        StatTotalAvailableQty: Decimal;
        StatTotalAllocatedQty: Decimal;
        TEXT001: Label 'No Line is selected. Please select a line/lines to allocate';
        TEXT002: Label 'No Item is focused. Please focus on Line Item';
        TEXT003: Label 'Do you want to run it for Order No. %1 or want to run substituations?';
        DocumentFilter: Option All,"Sales Order","Transfer Order";
        ShipmentDashbord: Record "Shipment Dashboard ELA";
        DocPrint: Codeunit "Document-Print";
        Usage: Option "Order Confirmation","Work Order","Pick Ticket";
        // ChangeLocation: Report "Change Location";
        Single: Boolean;
        LocationFilter: Code[20];
        TEXT004: Label 'All lines are fully picked.Open SaleOrder and Create New Lines.';
        TEXT005: Label 'Location cannot be changes because selected Line is already picked.';
        Loc: Code[10];
        "Whse. Employee": Record "Warehouse Employee";

    procedure PopulateData()
    var
        ShipmentDashboard: Record "Shipment Dashboard ELA";
    begin
        ShipDBMgt.AddApprovedOrders;
        filtergroup(2);
        if ShipDateFilter <> '' then
            SetFilter("Shipment Date", ShipDateFilter)
        else
            SetRange("Shipment Date");

        if OrderNoFilter <> '' then begin
            ShipmentDashboard.RESET;
            ShipmentDashboard.SetRange("Source No.", OrderNoFilter);
            if ShipmentDashboard.FINDFIRST THEN
                TripIDFilter := ShipmentDashboard."Trip No.";
            if TripIDFilter = '' then
                SetRange("Source No.", OrderNoFilter);
        end else begin
            SetRange("Source No.");
            TripIDFilter := '';
        end;


        if ItemNoFilter <> '' then
            SetFilter("Item No.", '%1', ItemNoFilter)
        else
            SetRange("Item No.");

        if TripIDFilter <> '' then
            SetFilter("Trip No.", '%1', TripIDFilter)
        else
            SetRange("Trip No.");

        if LocationFilter <> '' then
            SetFilter(Location, LocationFilter)
        else
            SetRange(Location);

        if ShowProcessedOnly then
            SetFilter(Completed, '%1', true)
        else
            SetRange(Completed);

        if ShowPickedOnly then
            SetFilter("Full Pick", '%1', true)
        else
            SetRange("Full Pick");

        if DocumentFilter = DocumentFilter::"Sales Order" then
            SetFilter("Source Document", '%1', "Source Document"::"Sales Order")
        else
            if DocumentFilter = DocumentFilter::"Transfer Order" then
                SetFilter("Source Document", '%1', "Source Document"::"Outbound Transfer")
            else
                SetRange("Source Document");

        if ShowSelectedOnly then begin
            SetFilter(Select, '%1', true);
            SetFilter("Locked By User ID", UserId);
        end else begin
            SetRange(Select);
            SetRange("Locked By User ID");
        end;

        IF ShowUnassignedOnly then begin
            setrange("Assigned App. User", '')
        end else
            setrange("Assigned App. User");

        Validate("Orig. Ordered Qty.");
        Validate("Qty. Reqd.");
        Validate("Short By Qty.");
        filtergroup(0);

        CurrPage.Update;

    end;

    procedure ResetFilters()
    begin
        SetRange("Shipment Date");
        SetRange("Source No.");
        SetRange("Item No.");
        SetRange(Completed);
        SetRange("Full Pick");
        Setrange("Trip No.");
        CurrPage.Update;
    end;

    procedure SetShipmentDashboard(ItemsFilter: Code[20])
    begin
        if ItemsFilter <> '' then begin
            ItemNoFilter := ItemsFilter;
            SetFilter("Item No.", '%1', ItemNoFilter);
        end;
    end;
}

