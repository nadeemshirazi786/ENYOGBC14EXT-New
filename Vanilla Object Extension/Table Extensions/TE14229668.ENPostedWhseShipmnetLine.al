//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// TableExtension EN Posted Whse. Shipmnet Line (ID 14229244) extends Record Posted Whse. Shipment Line.
/// </summary>
tableextension 14229244 "Posted Whse. Shipmnet Line ELA" extends "Posted Whse. Shipment Line"
{
    fields
    {

        field(14229200; "Assigned App. Role"; code[20])
        {
            TableRelation = "App. Role ELA";
        }

        field(14229201; "Assigned To"; Code[10])
        {
            Caption = 'Assigned Picker';
            TableRelation = "Application User ELA"."User ID";
        }

        field(14229220; "Ship Action"; Enum "WMS Ship Acion ELA")
        {
            Caption = 'Ship Action';
        }

        field(14229221; "Source Order No"; COde[20])
        {
            DataClassification = ToBeClassified;
        }

        field(14229222; "Source Ship-to"; Code[10])
        {
            Caption = 'Source Ship-to';
            Editable = false;
        }

        field(14229223; "Source Ship-to Name"; Text[100])
        {
            Caption = 'Source Ship-to Name';
            Editable = false;
        }

        field(14229224; "Source Ship-to Name 2"; Text[50])
        {
            Caption = 'Source Ship-to Name 2';
            Editable = false;
        }

        field(14229225; "Source Address"; Text[100])
        {
            Caption = 'Source Address';
        }

        field(14229226; "Source Address 2"; Text[50])
        {
            Caption = 'Source Address 2';
            Editable = false;
        }

        field(14229227; "Source Ship-to City"; Text[30])
        {
            Caption = 'Source Ship-to City';
            Editable = false;
        }

        field(14229228; "Source Ship-to Contact"; Text[100])
        {
            Caption = 'Source Ship-to Contact';
            Editable = false;
        }
        field(14229229; "Source Ship-to Post Code"; Code[20])
        {
            Caption = 'Source Ship-to Post Code';
            Editable = false;
        }
        field(14229230; "Source Ship-to County"; Text[30])
        {
            Caption = 'Source Ship-to County';
            // CaptionClass = '5,1,' + "Ship-to Country/Region Code";
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229231; "Source Ship-to Country"; Code[10])
        {
            Caption = 'Source Ship-to Country';
            TableRelation = "Country/Region";
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(14229232; "Orig. Ordered Qty"; Decimal)
        {

        }

        field(14229233; "Orig. Asked Qty."; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(14229234; "Last Modified Qty."; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(14229235; "Qty. to Handle"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(14229236; "Qty. to Handle (Base)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(14229237; "Cut/Overship Qty."; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(14229238; "Trip No."; code[20])
        {
            TableRelation = "Trip Load ELA" where(Direction = const(Outbound));
        }
    }
}
