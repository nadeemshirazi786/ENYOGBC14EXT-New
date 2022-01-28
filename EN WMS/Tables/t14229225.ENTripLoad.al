//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN Trip Load (ID 14229225).
/// </summary>
table 14229225 "Trip Load ELA"
{
    Caption = 'Trip Load';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = ToBeClassified;
        }
        field(2; Direction; Enum "WMS Trip Direction ELA")
        {
            Caption = 'Direction';
            DataClassification = ToBeClassified;
        }
        field(3; "Route No."; Code[20])
        {
            Caption = 'Route No.';
            TableRelation = "Delivery Route ELA";
            DataClassification = ToBeClassified;
        }
        field(4; Status; enum "WMS Document Status ELA")
        {
            Caption = 'Status';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "Load Date"; Date)
        {
            Caption = 'Load Date';
            DataClassification = ToBeClassified;
        }

        field(6; Location; code[20])
        {
            TableRelation = Location;
            DataClassification = ToBeClassified;
        }

        field(7; "Scheduled Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }


        field(14229220; "Total Weight"; Decimal)
        {
            Caption = 'Total Weight';
            DataClassification = ToBeClassified;
        }
        field(14229221; "No. of Pallets"; Decimal)
        {
            Caption = 'No. of Pallets';
            DataClassification = ToBeClassified;
        }
        field(14229222; "Temp Tag No."; Code[20])
        {
            Caption = 'Temp Tag No.';
            DataClassification = ToBeClassified;
        }
        field(14229223; "Door No."; Integer)
        {
            Caption = 'Door No.';
            DataClassification = ToBeClassified;
        }
        field(14229224; "Truck Code"; Code[20])
        {
            //todo #5 @Kamranshehzad add truck relation ship and populate info from truck table / create table if required .. 
            Caption = 'Truck Code';
            TableRelation = if ("Company owned Truck" = const(true)) "Truck ELA" where(Blocked = const(false));
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                TruckInfo: record "Truck ELA";
            begin
                if ("Company owned Truck") then begin
                    if TruckInfo.get("Truck Code") then begin
                        "Truck Plate No." := TruckInfo."License/Plate No.";
                    end else begin
                        "Truck Code" := '';
                        "Truck Plate No." := '';
                    end;
                end;
            end;
        }
        field(14229225; "Truck Plate No."; Code[10])
        {
            Caption = 'Truck Plate No.';
            DataClassification = ToBeClassified;
        }
        field(14229226; "Seal No."; Code[10])
        {
            Caption = 'Seal No.';
            DataClassification = ToBeClassified;
        }
        field(14229227; "Product Temperature"; Decimal)
        {
            Caption = 'Product Temperature';
            DataClassification = ToBeClassified;
        }
        field(14229228; "Truck Temperature"; Decimal)
        {
            Caption = 'Truck Temperature';
            DataClassification = ToBeClassified;
        }
        field(14229229; "Shipper Name"; Code[20])
        {
            Caption = 'Shipper Name';
            DataClassification = ToBeClassified;
        }
        field(14229230; "Carrier Name"; Code[20])
        {
            Caption = 'Carrier Name';
            DataClassification = ToBeClassified;
        }
        field(14229231; "Driver Name"; Code[20])
        {
            Caption = 'Driver Name';
            DataClassification = ToBeClassified;
        }

        field(14229232; "Company owned Truck"; Boolean)
        {
            Caption = 'Company Owned Vehicle';
            DataClassification = ToBeClassified;
        }

        field(14229233; "Tare Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(14229234; "Gross Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(14229290; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229291; "Created On"; DateTime)
        {
            Caption = 'Created On';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229292; "Last modified By"; Code[50])
        {
            Caption = 'Last modified By';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229293; "Last Modified On"; DateTime)
        {
            Caption = 'Last Modified On';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "No.", Direction)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        ENWMSSetup: record "WMS Setup ELA";
    begin

        ENWMSSetup.GET;
        IF (Direction = Direction::Outbound) THEN BEGIN
            ENWMSSetup.TESTFIELD("Outbound Load Nos.");
            "No." := NoSeriesMgt.GetNextNo(ENWMSSetup."Outbound Load Nos.", 0D, TRUE);
        END ELSE
            IF (Direction = Direction::Inbound) THEN BEGIN
                ENWMSSetup.TESTFIELD("Inbound Load Nos.");
                "No." := NoSeriesMgt.GetNextNo(ENWMSSetup."Inbound Load Nos.", 0D, TRUE);
            end;

        "Created On" := CurrentDateTime;
        "Created By" := UserId;
        "Last modified By" := UserId;
        "Last Modified On" := CurrentDateTime;
    end;

    trigger OnModify()
    var
    begin
        "Created On" := CurrentDateTime;
        "Created By" := UserId;
        "Last modified By" := UserId;
        "Last Modified On" := CurrentDateTime;
    end;

    trigger OnDelete()
    var
        TripLoadOrders: record "Trip Load Order ELA";
    begin
        TripLoadOrders.reset;
        TripLoadOrders.SetRange("Load No.", rec."No.");
        if TripLoadOrders.FindSet() then
            repeat
                TripLoadOrders.Delete(true);
            until TripLoadOrders.Next() = 0;
    end;

    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
}
