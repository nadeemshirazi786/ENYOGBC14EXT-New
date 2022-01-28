/// <summary>
/// PageExtension EN Sales Order Ext (ID 14228858) extends Record Sales Order.
/// </summary>
pageextension 14228858 "EN Sales Order Ext" extends "Sales Order"
{
    layout
    {
        modify("Sell-to Contact No.")
        {
            Visible = false;
        }
        modify("Sell-to Phone No.")
        {
            Visible = false;
        }
        modify("Sell-to E-Mail")
        {
            Visible = false;
        }
        modify("Campaign No.")
        {
            Visible = false;
        }
        modify("Opportunity No.")
        {
            Visible = false;
        }
        modify("CFDI Purpose")
        {
            Visible = false;
        }

        modify("CFDI Relation")
        {
            Visible = false;
        }
        modify("Requested Delivery Date")
        {
            Visible = false;
        }
        modify("Promised Delivery Date")
        {
            Visible = false;
        }
        modify("Due Date")
        {
            Visible = false;
        }
        modify(ShippingOptions)
        {
            Visible = false;
        }
        modify("Ship-to Code")
        {
            Caption = 'Ship-to Code';
        }
        modify("Shipment Method Code")
        {
            Caption = 'Shipment Method Code';
        }
        modify("Shipment Date")
        {
            ApplicationArea = all;
            trigger OnAfterValidate()
            begin
                IF "Shipment Date" <> xRec."Shipment Date" then begin
                    Validate("Posting Date", "Shipment Date");
                    Validate("Document Date", "Shipment Date");
                end;
                ShipmentDateOnAfterValidate;
            end;
        }
        movebefore("Document Date"; "Shipment Date")
        moveafter("Order Date"; "Location Code", ShippingOptions, "Ship-to Code", "Shipment Method Code")

        // Add changes to page layout here
        addafter("Attached Documents")
        {
            part(Control1000000000; "Sales Document Rbt FactBox ELA")
            {
                ApplicationArea = All;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "No." = FIELD("No.");
                Visible = true;
            }
        }
        addlast("Shipping and Billing")
        {
            field("Backorder Tolerance %"; "Backorder Tolerance % ELA")
            {
                ApplicationArea = All;
            }
            field("Delivery Zone Code"; "Delivery Zone Code ELA")
            {
                ApplicationArea = All;
            }
            field("Pallet Code"; "Pallet Code ELA")
            {
                ApplicationArea = All;
            }
            field("Date Order Created"; "Date Order Created ELA")
            {
                ApplicationArea = All;
            }
            field("Standing Order Status"; "Standing Order Status")
            {
                ApplicationArea = All;
            }
            field("Order Template Location"; "Order Template Location ELA")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Logistics Route No."; "Logistics Route No. ELA")
            {
                ApplicationArea = All;
            }
            field("Shipping Instructions ELA"; "Shipping Instructions ELA")
            {
                ApplicationArea = All;
            }

        }
        addafter("Direct Debit Mandate ID")
        {
            field("Bypass Order Rules"; "Bypass Order Rules ELA")
            {
                ApplicationArea = All;
            }
            field("Price List Group Code"; "Price List Group Code ELA")
            {
                ApplicationArea = All;
            }
            field("Order Rule Group"; "Order Rule Group ELA")
            {
                ApplicationArea = All;
            }
            field("Lock Pricing"; "Lock Pricing ELA")
            {
                ApplicationArea = All;
            }
        }
        addafter(Status)
        {
            field("Amt. To Collect"; "Seal No. ELA")
            {
                ApplicationArea = All;
            }
            field("No. Pallets"; "No. Pallets")
            {
                Caption = 'No. Pallets';
            }
            field("Warehouse Shipment Exists"; "Warehouse Shipment Exists ELA")
            {
                ApplicationArea = All;
            }

        }
        modify("Transport Method")
        {
            Caption = 'Checker';
        }
        modify("Transaction Type")
        {
            Caption = 'Checker Findings';
        }
        moveafter("No. Pallets"; "Transport Method")
        moveafter("Transport Method"; "Transaction Type")
		addlast("Work Description")
        {
            field("App. User ID"; Rec."App. User ID ELA")
            {
                ApplicationArea = All;
                ToolTip = 'Application users ID';
            }

            field("Delivery Route No."; "Route No. ELA")
            {
                ApplicationArea = all;
            }

            field("Stop No."; "Stop No. ELA")
            {
                ApplicationArea = All;
                ToolTip = 'Default stop no. on route';
            }

            field("Trip No."; rec."Trip No. ELA")
            {
                ApplicationArea = All;
                ToolTip = 'Outbound Load Trip No.';

                trigger OnAssistEdit()
                var
                    TripLoad: Record "Trip Load ELA";
                    TripLoadPage: Page "Outbound Trip Load ELA";
                begin
                    TripLoad.Get("Trip No. ELA", TripLoad.Direction::Outbound);
                    TripLoadPage.SetRecord(TripLoad);
                    TripLoadPage.Run();
                end;
            }
        }

    }
    actions
    {
        addlast("F&unctions")
        {
            group("Order Calc(s)")
            {
                action("Calc Rebates")
                {
                    trigger OnAction()
                    var
                        ///lcduRebateMgt: Codeunit "EN Order Rule Functions";
                        lrrfHeader: RecordRef;
                    begin

                        lrrfHeader.GETTABLE(Rec);
                        lrrfHeader.SETVIEW(Rec.GETVIEW);
                        ///lcduRebateMgt.JF_CalcSalesDocRebate(lrrfHeader, FALSE, TRUE);
                    end;
                }
                action("Calc Ord Rules")
                {
                    trigger OnAction()
                    var
                        lcduOrderRulesMgt: Codeunit "EN Order Rule Functions";
                        lcduCalcSurcharges: Codeunit "EN Delivery Charge Mgt";

                    begin
                        lcduCalcSurcharges.AddOrderSurcharges(Rec, TRUE);
                        lcduOrderRulesMgt.cbCheckOrder(Rec);
                    end;

                }
                action("Delivery Manifest Ticket")
                {
                    Promoted = true;
                    PromotedCategory = Process;
                    Image = Print;
                    trigger OnAction()
                    begin
                        PrintDeliveryManifest(Rec);
                    end;
                }
            }


        }
		addfirst(Processing)
        {
            action("Show Containers")
            {
                ApplicationArea = Warehouse;
                Promoted = true;
                PromotedCategory = Process;
                image = Resource;

                trigger OnAction()
                var
                    ContMgmt: codeunit "Container Mgmt. ELA";
                    WhseDocType: Enum "Whse. Doc. Type ELA";
                    SourceDoctypeFilter: Enum "WMS Source Doc Type ELA";
                    ActivityType: Enum "WMS Activity Type ELA";
                begin
                    ContMgmt.ShowContainer(SourceDoctypeFilter, '', "Location Code", "Document Type", "No.", WhseDocType::Shipment, ''
              , ActivityType, '');
                end;
            }


            action("Assign Container Contents")
            {
                ApplicationArea = Warehouse;
                Promoted = true;
                PromotedCategory = Process;
                image = Create;
                trigger OnAction()
                var
                    AssignContContents: Page "Assign Container Contents ELA";
                    WhseDocType: Enum "Whse. Doc. Type ELA";
                    ENWMSSourceDocTypeFilter: Enum "WMS Source Doc Type ELA";
                    ENWMSActType: Enum "WMS Activity Type ELA";
                begin
                    AssignContContents.SetDocumentFilters(ENWMSSourceDocTypeFilter::"Sales Order", "Document Type", "No.", 0,
                        WhseDocType, '', ENWMSActType, '', 0, '', false);
                    AssignContContents.Run();
                end;
            }
        }


    }
    procedure PrintDeliveryManifest(precSalesHeader: Record "Sales Header")
    var
        RptDeliveryManifest: Report "Delivery Manifest Ticket";
    begin
        precSalesHeader.SETRECFILTER;
        RptDeliveryManifest.SETTABLEVIEW(precSalesHeader);
        RptDeliveryManifest.RUN;
    end;

    procedure ShipmentDateOnAfterValidate()
    begin
        CurrPage.UPDATE(TRUE);
    end;


}
