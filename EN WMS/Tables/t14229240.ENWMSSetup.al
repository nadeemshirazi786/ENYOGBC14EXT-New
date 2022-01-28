//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN WMS Setup (ID 14229220).
/// </summary>
table 14229240 "WMS Setup ELA"
{
    Caption = 'WMS Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = ToBeClassified;
        }

        field(2; "Add Orders to Outb. Loads"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(3; "Enforce Containers Use"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(100; "License Plate Nos."; Code[10])
        {
            TableRelation = "No. Series";
            DataClassification = ToBeClassified;
        }

        field(101; "Bill of Lading Nos."; code[10])
        {
            TableRelation = "No. Series";
        }

        field(102; "Inbound Load Nos."; code[10])
        {
            TableRelation = "No. Series";
        }
        field(103; "Outbound Load Nos."; code[10])
        {
            TableRelation = "No. Series";
        }

        field(104; "Container Nos."; Code[10])
        {
            TableRelation = "No. Series";
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

}
