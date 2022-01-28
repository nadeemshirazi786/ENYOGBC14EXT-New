tableextension 14229654 "Warehouse Activity Line" extends "Warehouse Activity Line"
{
    fields
    {
        field(14229220; "Assigned App. Role ELA";
        Code[20])
        {
            TableRelation = "App. Role ELA";
            DataClassification = ToBeClassified;
        }
        field(14229221; "Assigned App. User ELA"; Code[10])
        {
            TableRelation = "App. Role ELA";
            DataClassification = ToBeClassified;
        }
        field(14229222; "Original Qty. ELA"; Decimal)
        {
            Caption = 'Original Qty.';
            DataClassification = ToBeClassified;
        }
        field(14229223; "Released To Pick ELA"; Boolean)
        {
            Caption = 'Released To Pick';
            DataClassification = ToBeClassified;
        }
        field(14229224; "Released At ELA"; DateTime)
        {
            Caption = 'Released On';
            DataClassification = ToBeClassified;
        }
        field(14229225; "Prioritized ELA"; Boolean)
        {
            Caption = 'Prioritized';
            DataClassification = ToBeClassified;
        }
        field(14229226; "Trip No. ELA"; Code[10])
        {
            Caption = 'Trip No.';
            TableRelation = "Trip Load ELA";
            DataClassification = ToBeClassified;
        }
        field(14229227; "Ship Action ELA"; Option)
        {
            OptionMembers = "",Fullfill,Cut,"Over Ship","Back Order";
            Caption = 'Ship Action';
            DataClassification = ToBeClassified;
        }
        field(14229228; "Received By ELA"; Code[20])
        {
            Caption = 'Received By';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(14229229; "Received Date ELA"; Date)
        {
            Caption = 'Received Date';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(14229230; "Received Time ELA"; Time)
        {
            Caption = 'Received Time';
            Editable = false;
            DataClassification = ToBeClassified;
        }


        field(142292231; "Container No. ELA"; Code[20])
        {
            TableRelation = "Container ELA";
            DataClassification = ToBeClassified;
        }
        field(14229232; "Licnese Plate No. ELA"; code[20])
        {
            TableRelation = "License Plate ELA";
            DataClassification = ToBeClassified;
        }

        field(142292233; "Container Line No. ELA"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(142292234; "Parent Line No. ELA"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(14229243; "Reason Code ELA"; Code[20])
        {
            Caption = 'Reason Code';
            DataClassification = ToBeClassified;
        }
	}

}