tableextension 14229646 "EN Whse Receipt Header Ext" extends "Warehouse Receipt Header"
{
    fields
    {
        field(14229700; "Name ELA"; Text[50])
        {
            Caption = 'Name';
        }
        field(14229701; "Address ELA"; Text[50])
        {
            Caption = 'Address';
        }
        field(14229702; "Address 2 ELA"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(14229703; "City ELA"; Text[30])
        {
            Caption = 'City';
        }

        field(14229704; "County ELA"; Text[30])
        {
            Caption = 'County';
        }
        field(14229705; "Post Code ELA"; Text[20])
        {
            Caption = 'Post Code';
        }
        field(14229706; "Country/Region Code ELA"; Text[10])
        {
            Caption = 'Country/Region Code';
        }
        field(14229707; "Contact ELA"; Text[50])
        {
            Caption = 'Contact';
        }
        field(51000; "No. Pallets"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(51001; "Shipping Agent Code ELA"; Code[10])
        {
            TableRelation = "Shipping Agent";
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


    }
}
