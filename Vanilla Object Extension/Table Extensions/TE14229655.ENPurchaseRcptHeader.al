tableextension 14229655 "EN Purchase Rcpt Header" extends "Purch. Rcpt. Header"
{
    fields
    {
        field(51001; "Shipping Agent Code"; Code[10])
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
        field(14229102; "Communication Group Code ELA"; Code[20])
        {
            Caption = 'Communication Group Code';
            DataClassification = ToBeClassified;
            TableRelation = "Communication Group ELA".Code;
        }
        field(14229103; "Shipping Instructions ELA"; Text[50])
        {
            Caption = 'Shipping Instructions';
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}