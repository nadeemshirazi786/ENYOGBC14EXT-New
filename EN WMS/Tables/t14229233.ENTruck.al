//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information 

/// <summary>
/// Table EN Truck (ID 14229233).
/// </summary>
table 14229233 "Truck ELA"
{
    Caption = 'Truck';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(3; "License/Plate No."; Code[10])
        {
            Caption = 'License/Plate No.';
            DataClassification = ToBeClassified;
        }
        field(4; "License Type"; Enum "Truck License Class ELA")
        {
            Caption = 'License Type';
            DataClassification = ToBeClassified;
        }
        field(5; "License Exp. Date"; Date)
        {
            Caption = 'License Exp. Date';
            DataClassification = ToBeClassified;
        }
        field(6; "VIN No."; Code[30])
        {
            Caption = 'VIN No.';
            DataClassification = ToBeClassified;
        }
        field(7; "Engine Type"; Code[20])
        {
            Caption = 'Engine Type';
            DataClassification = ToBeClassified;
        }
        field(8; "No. Of Axles"; Integer)
        {
            Caption = 'No. Of Axles';
            DataClassification = ToBeClassified;
        }

        field(10; Blocked; Boolean)
        {
            Caption = 'Blocked';
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
