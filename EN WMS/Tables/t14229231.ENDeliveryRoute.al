//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN Delivery Route (ID 14229231).
/// </summary>
table 14229231 "Delivery Route ELA"
{
    Caption = 'Delivery Route';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location where("Use As In-Transit" = const(false));
            DataClassification = ToBeClassified;
        }
        field(4; "Default Driver No."; Code[20])
        {
            Caption = 'Default Driver No.';
            TableRelation = "Delivery Driver ELA";
            DataClassification = ToBeClassified;
        }
        field(5; "Default Truck Code"; Code[10])
        {
            Caption = 'Default Truck Code';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

}
