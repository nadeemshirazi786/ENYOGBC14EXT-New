//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information


/// <summary>
/// TableExtension Posted Whse Shipment Header (ID 14229243) extends Record Posted Whse. Shipment Header.
/// </summary>
tableextension 14229243 "Posted Whse Shipment Header" extends "Posted Whse. Shipment Header"
{
    fields
    {
        field(14229212; "Assigned App. Role"; code[10])
        {
            TableRelation = "App. Role ELA";
        }

        field(14229213; "Assigned To"; Code[10])
        {
            Caption = 'Assigned Picker';
            TableRelation = "Application User ELA"."User ID";
        }

        field(14229220; "Trip No."; Code[20])
        {
            TableRelation = "Trip Load ELA" where(Direction = const(Outbound));
            DataClassification = ToBeClassified;
        }
    }
}
