table 14229243 "WMS Order Picker ELA"
{
    DataClassification = ToBeClassified;
    Caption = 'WMS Order Picker';

    fields
    {
        field(10; "Picker Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Application User ELA";
        }
        field(20; "Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Sales Header"."No.";
        }
        field(30; "Pick Created"; Boolean)
        {
            DataClassification = ToBeClassified;

        }
        field(40; "Location Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location;

        }
        field(50; "Shipment No."; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(60; "Trip ID"; Code[10])
        {
            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(PK; "Picker Code", "Order No.", "Location Code")
        {
            Clustered = true;
        }
    }

}