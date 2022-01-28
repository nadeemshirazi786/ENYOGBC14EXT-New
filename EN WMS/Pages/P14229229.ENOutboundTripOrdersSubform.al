//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Trip Orders Subform (ID 14229227).
/// </summary>
page 14229229 "OutBnd. Trip Orders SF ELA"
{

    Caption = 'Trip Outbound Orders';
    PageType = ListPart;
    SourceTable = "Trip Load Order ELA";
    InsertAllowed = true;
    ModifyAllowed = true;
    MultipleNewLines = true;
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Load No."; Rec."Load No.")
                {
                    ApplicationArea = All;
                }
                field(Direction; Rec.Direction)
                {
                    ApplicationArea = All;
                }
                field("Source Document Type"; Rec."Source Document Type")
                {
                    ApplicationArea = All;
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = All;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = All;
                }
                field("Source Location"; Rec."Source Location")
                {
                    ApplicationArea = All;
                }
                field("External Doc. No."; Rec."External Doc. No.")
                {
                    ApplicationArea = All;
                }

                field("Stop No."; Rec."Stop No.")
                {
                    ApplicationArea = All;
                }

                field("Whse. Shipment No."; "Whse. Shipment No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Destination Type"; Rec."Destination Type")
                {
                    ApplicationArea = All;
                }
                field("Destination Location"; Rec."Destination Location")
                {
                    ApplicationArea = All;
                }
                field("Added by User ID"; Rec."Added by User ID")
                {
                    ApplicationArea = All;
                }
                field("Added On"; Rec."Added On")
                {
                    ApplicationArea = All;
                }
            }
        }
    }


    actions
    {
        area(Processing)
        {

            action("Show Source Document")
            {
                ApplicationArea = All;
                Caption = 'Show Source Document';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Documents;
                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                    SalesOrderPage: Page "Sales Order";
                begin
                    IF NOT SalesHeader.get(SalesHeader."Document Type"::Order, Rec."Source Document No.") then
                        ERROR('Unable to find %1 %2', "Source Document Type", "Source Document No.");

                    SalesOrderPage.SetRecord(SalesHeader);
                    SalesOrderPage.Run();
                    // page.Run(0, SalesHeader);
                    // if page.Run(0, SalesHeader) = Action::LookupOK then begin
                    //   ENTripLoadMgmt.AddOrderOnTrip("Load No.", Direction, "Source Document Type"::"Sales Order", SalesHeader."No.");
                    // end;
                end;
            }

            action("Show Warehouse Shipment")
            {
                ApplicationArea = All;
                Caption = 'Show Warehouse Shipment';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Documents;
                trigger OnAction()
                var
                    WarehouseShipmentHeader: Record "Warehouse Shipment Header";
                    WhseShipment: Page "Warehouse Shipment";
                begin
                    if not WarehouseShipmentHeader.Get("Whse. Shipment No.") then
                        ERROR('Unable to find warehouse shipment %1', "Whse. Shipment No.");

                    WhseShipment.SetRecord(WarehouseShipmentHeader);
                    WhseShipment.Run();
                end;
            }

            action("Add Sales Orders")
            {
                ApplicationArea = All;
                Caption = 'Add Sales Orders';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Documents;
                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                    TripLoad: Record "Trip Load ELA";
                begin
                    // todo #6  @Kamranshehzad add a custom screen with filters and released orders to be added on trip
                    TripLoad.Get("Load No.", Direction::Outbound);
                    SalesHeader.SetFilter("Location Code", TripLoad.Location);
                    if page.RunModal(0, SalesHeader) = Action::LookupOK then begin
                        ENTripLoadMgmt.AddOrderOnTrip("Load No.", Direction, "Source Document Type"::"Sales Order", SalesHeader."No.");
                    end;
                end;
            }

            action("Add Transfer Orders")
            {
                ApplicationArea = All;
                Caption = 'Add Transfer Orders';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Documents;
                trigger OnAction()
                var
                    TransferHeader: Record "Transfer Header";
                begin

                    if page.RunModal(0, TransferHeader) = Action::LookupOK then begin
                        ENTripLoadMgmt.AddOrderOnTrip("Load No.", Direction, "Source Document Type"::"Transfer Order",
                            TransferHeader."No.");
                    end;
                end;
            }

            action("Remove Order")
            {
                ApplicationArea = All;
                Image = Delete;
                trigger OnAction()
                begin
                    ENTripLoadMgmt.RemoveOrderFromTrip("Load No.", Direction, "Source Document Type", "Source Document No.");
                end;
            }
        }
    }

    var
        ENTripLoadMgmt: Codeunit 14229222;

}
