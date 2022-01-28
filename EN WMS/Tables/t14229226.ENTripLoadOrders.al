//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN Trip Load Order (ID 14229226).
/// </summary>
table 14229226 "Trip Load Order ELA"
{
    Caption = 'Trip Load Orders';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Load No."; Code[20])
        {
            Caption = 'Load No.';
            DataClassification = ToBeClassified;
        }
        field(2; Direction; Enum "WMS Trip Direction ELA")
        {
            DataClassification = ToBeClassified;
        }

        field(3; "Source Document Type"; Enum "WMS Source Doc Type ELA")
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            TableRelation = if ("Source Document Type" = const("Purchase Order")) "Purchase Header"."No."
             where("Document Type" = const(Order))
            else
            if ("Source Document Type" = const("Sales Order")) "Sales Header"."No."
            where("Document Type" = const(order))
            else
            if ("Source Document Type" = const("Transfer Order")) "Transfer Header"."No.";
            DataClassification = ToBeClassified;
        }

        field(5; "Source Location"; Code[10])
        {
            Caption = 'Source Location';
            DataClassification = ToBeClassified;
        }

        field(6; "Destination Type"; Enum "WMS Trip Direction ELA")
        {
            // Caption = 'Destination Type';
            // OptionMembers = Inbound,Outbound;
            DataClassification = ToBeClassified;
        }
        field(7; "Destination Location"; Code[20])
        {
            Caption = 'Destination Location';
            TableRelation = if ("Destination Type" = const(Inbound)) Location;
            DataClassification = ToBeClassified;
        }
        field(8; "Source Type"; Enum "WMS Source Type ELA")
        {
            // Caption = 'Source Type';
            // OptionMembers = Vendor,Customer,Location;
            DataClassification = ToBeClassified;
        }
        field(9; "Source Code"; Code[20])
        {
            Caption = 'Source Code';
            TableRelation = if ("Source Type" = const(Vendor)) Vendor else
            if ("Source Type" = const(Customer)) Customer
            else
            if ("Source Type" = const(Location)) Location;
            DataClassification = ToBeClassified;
        }
        field(10; "External Doc. No."; Code[30])
        {
            Caption = 'External Doc. No.';
            Editable = false;
            DataClassification = ToBeClassified;
        }

        field(11; "Shipment Date"; Date)
        {
            Editable = false;
        }

        field(12; "Stop No."; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(13; "Whse. Shipment No."; code[10])
        {
            TableRelation = "Warehouse Shipment Header";
            DataClassification = ToBeClassified;
        }

        field(14; "Posted. Whse. Shipment No."; code[10])
        {
            TableRelation = "Posted Whse. Shipment Header";
            DataClassification = ToBeClassified;
        }

        field(15; "Shipment Posted"; Boolean)
        {
            trigger OnValidate()
            var
            begin
                CheckAndUpdateTripStatus();
            end;
        }

        field(110; "Added On"; DateTime)
        {
            Caption = 'Added On';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(100; "Added by User ID"; Code[50])
        {
            Caption = 'Added by User ID';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Load No.", Direction, "Source Document Type", "Source Document No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
    begin
        if (Direction = Direction::Outbound) then
            setfilter("Source Document Type", '%1|%2', "Source Document Type"::"Sales Order", "Source Document Type"::"Transfer Order")
        else
            SetFilter("Source Document Type", '%1', "Source Document Type"::"Purchase Order");

        "Added On" := currentdatetime;
        "Added by User ID" := UserId();

    end;

    trigger OnModify()
    var
    begin
        if (Direction = Direction::Outbound) then
            setfilter("Source Document Type", '%1|%2', "Source Document Type"::"Sales Order", "Source Document Type"::"Transfer Order")
        else
            SetFilter("Source Document Type", '%1', "Source Document Type"::"Purchase Order");
    end;

    trigger OnDelete()
    var
        SalesHeader: record "Sales Header";
        WhseShipHdr: Record "Warehouse Shipment Header";
        TransferHeader: Record "Transfer Header";
        PurchaseHeader: record "Purchase Header";
        TripLoad: Record "Trip Load ELA";
        ShipDashBrd: Record "Shipment Dashboard ELA";
    begin
        if "Source Document Type" = "Source Document Type"::"Sales Order" then begin
            IF TripLoad.get(Rec."Load No.", Direction) THEN
                if TripLoad.Status in [TripLoad.Status::Completed] then
                    ERROR(StrSubstNo('Cannot modify Trip %1 as it is already closed.', "Load No."));

            if "Posted. Whse. Shipment No." <> '' then
                error(StrSubstNo('%1 %2 cannot be deleted from load as a posted whse. shipment %3 exists',
                  "Source Document Type", "Source Document No.", "Posted. Whse. Shipment No."));

            // if WhseShipHdr.get("Whse. Shipment No.") then
            //     WhseShipHdr.Delete(true);

            ShipDashBrd.reset;
            ShipDashBrd.setrange("Trip No.", Rec."Load No.");
            ShipDashBrd.setrange("Source No.", "Source Document No.");
            ShipDashBrd.DeleteAll();

            if WhseShipHdr.get("Whse. Shipment No.") then
                WhseShipHdr.Delete(true);

            if SalesHeader.get(SalesHeader."Document Type"::Order, "Source Document No.") then begin
                SalesHeader."Trip No. ELA" := '';
                SalesHeader.Modify();
            end;
        end;
    end;

    local procedure CheckAndUpdateTripStatus()
    var
        ENTripLoad: Record "Trip Load ELA";
        ENTripLoadOrders: Record "Trip Load Order ELA";
        AllOrdersArePosted: Boolean;
    begin
        AllOrdersArePosted := true;
        ENTripLoadOrders.SetRange("Source Document Type", rec."Source Document Type");
        ENTripLoadOrders.SetRange("Source Document No.", rec."Source Document No.");
        if ENTripLoadOrders.FindSet() then
            repeat
                if NOT ENTripLoadOrders."Shipment Posted" then begin
                    AllOrdersArePosted := false;
                end;
            until ENTripLoadOrders.Next() = 0;

        if AllOrdersArePosted then begin
            ENTripLoad.Get(ENTripLoadOrders."Load No.", ENTripLoad.Direction);
            ENTripLoad.Status := ENTripLoad.Status::Completed;
            ENTripLoad.Modify();
        end;

    end;

}
