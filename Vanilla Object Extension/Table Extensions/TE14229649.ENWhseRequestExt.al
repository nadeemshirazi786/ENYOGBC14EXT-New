tableextension 14229649 "Whse Request ELA" extends "Warehouse Request"
{
    fields
    {
        field(14228835; "Seal No. ELA"; Code[20])
        {
            Caption = 'Seal No.';
            DataClassification = ToBeClassified;
        }
        field(14228851; "Pallet Code ELA"; Code[10])
        {
            Caption = 'Pallet Code';
        }
        field(51000; "No. Pallets"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(51003; "Exp. Delivery Appointment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(51004; "Exp. Delivery Appointment Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(51005; "Act. Delivery Appointment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(51006; "Act. Delivery Appointment Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
		field(14229200; "Source Order No. ELA"; Code[20])
        {
            Caption = 'Source Order No.';
            DataClassification = ToBeClassified;
        }
        field(14229201; "Source Ship-to ELA"; Code[10])
        {
            Caption = 'Source Ship-to';
            DataClassification = ToBeClassified;
        }
        field(14229202; "Source Ship-to Name ELA"; Text[50])
        {
            Caption = 'Source Ship-to Name';
            DataClassification = ToBeClassified;
        }
        field(14229203; "Souce Ship-to Address ELA"; Text[50])
        {
            Caption = 'Souce Ship-to Address';
            DataClassification = ToBeClassified;
        }
        field(14229204; "Source Ship-to Address 2 ELA"; Text[50])
        {
            Caption = 'Source Ship-to Address 2';
            DataClassification = ToBeClassified;
        }
        field(14229205; "Source Ship-to City ELA"; Text[30])
        {
            Caption = 'Source Ship-to City';
            DataClassification = ToBeClassified;
        }
        field(14229206; "Source Ship-to State ELA"; Text[30])
        {
            Caption = 'Source Ship-to State';
            DataClassification = ToBeClassified;
        }
        field(14229207; "Source Ship-to Zip Code ELA"; Code[20])
        {
            Caption = 'Source Ship-to Zip Code';
            DataClassification = ToBeClassified;
        }
        field(14229208; "Ship-to Country Code ELA"; Code[10])
        {
            Caption = 'Ship-to Country/Region Code';
            DataClassification = ToBeClassified;
        }
        field(14229210; "Ship-to Contact ELA"; Text[50])
        {
            Caption = 'Ship-to Contact';
            DataClassification = ToBeClassified;
        }
        field(14229230; "Trip No. ELA"; Code[10])
        {
            Caption = 'Trip No.';
            DataClassification = ToBeClassified;
        }
        field(14229231; "Warehouse Shipment No. ELA"; Code[20])
        {
            Caption = 'Warehouse Shipment No.';
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}