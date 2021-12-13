table 14229600 "Workwave Manifest ELA"
{


    fields
    {
        field(10; "No."; Code[20])
        {
            TableRelation = "Sales Header"."No." WHERE("Document Type" = FILTER(Order));
        }
        field(20; "Sell-To Customer No."; Code[20])
        {
            Description = '20';
            TableRelation = Customer;
        }
        field(30; "Order No."; Code[20])
        {
            TableRelation = "Sales Header"."No." WHERE("Document Type" = FILTER(Order));
        }
        field(35; "Shipment Date"; Date)
        {
        }
        field(36; Departured; Boolean)
        {
        }
        field(40; "Dropoff Service Time"; Integer)
        {
        }
        field(50; "Dropoff Full Address"; Text[250])
        {
        }
        field(60; "Dropoff Street"; Text[250])
        {
        }
        field(70; "Droppoff City"; Text[250])
        {
        }
        field(80; "Dropoff State"; Text[250])
        {
        }
        field(90; "Dropoff Zip"; Code[20])
        {
        }
        field(100; "Dropoff Country"; Code[20])
        {
        }
        field(110; Eligibilty; Text[30])
        {
        }
        field(120; "Dropoff Time Window Start"; Time)
        {
        }
        field(130; "Dropoff Time Window End"; Time)
        {
        }
        field(140; "Dropoff Time Window Start 2"; Time)
        {
        }
        field(150; "Dropoff Time Window End 2"; Time)
        {
        }
        field(160; Load; Decimal)
        {
        }
        field(170; "Required vehicle"; Code[20])
        {
            TableRelation = Resource."No." WHERE(Type = CONST(Machine));
        }
        field(180; "Dropoff Required Tag"; Code[20])
        {
            TableRelation = "FA Class";
        }
        field(190; "Dropoff Banned Tags"; Code[20])
        {
            TableRelation = "FA Class";
        }
        field(200; "Dropoff Latitude"; Decimal)
        {
            DecimalPlaces = 7;
        }
        field(210; "Dropoff Longitude"; Decimal)
        {
            DecimalPlaces = 7;
        }
        field(220; Quantity; Decimal)
        {
        }
        field(230; "Sent to workwave"; Boolean)
        {
        }
        field(240; "Route No."; Text[250])
        {
        }
        field(250; "Truck Code"; Code[20])
        {
            TableRelation = Resource;
        }
        field(260; "Driver Code"; Code[20])
        {
            TableRelation = Resource;
        }
        field(270; "Customer No."; Code[20])
        {
        }
        field(280; "WW UUID"; Text[250])
        {
        }
        field(290; "Service Time"; Integer)
        {


        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

}

