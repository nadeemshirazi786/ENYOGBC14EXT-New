tableextension 14229648 "Whse Shpt Hdr ELA" extends "Warehouse Shipment Header"
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
		field(14229212; "Assigned App. Role ELA"; code[10])
        {
            DataClassification = ToBeClassified;
        }

        field(14229213; "Assigned To ELA"; Code[10])
        {
            DataClassification = ToBeClassified;
        }

        field(14229220; "Trip No. ELA"; Code[20])
        {
            TableRelation = "Trip Load ELA" where(Direction = const(Outbound));
            DataClassification = ToBeClassified;
        }
    }
    
    var
        UpdateSource: Option " ",Shipment,"Task Queue",Activity,ShipBoard;
        ActivityType: Option " ","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick";
}