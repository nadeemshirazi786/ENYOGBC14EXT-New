//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN Mobile User Permission (ID 14229206).
/// </summary>
table 14229206 "App. User Permission ELA"
{
    Caption = 'App. User Permission';
    DataClassification = ToBeClassified;
    DataPerCompany = false;
    fields
    {
        field(10; "App. User ID"; Code[10])
        {
            Caption = 'App. User ID';
            DataClassification = ToBeClassified;
        }

        field(20; "App. Type"; code[10])
        {
            TableRelation = "Application ELA";
        }

        field(100; "Register Output"; Boolean)
        {
            Caption = 'Register Output';
            DataClassification = ToBeClassified;
        }
        field(110; "Can Receive"; Boolean)
        {
            Caption = 'Can Receive';
            DataClassification = ToBeClassified;
        }
        field(120; "Can Putaway"; Boolean)
        {
            Caption = 'Can Putaway';
            DataClassification = ToBeClassified;
        }
        field(130; "Can Adjust Inventory"; Boolean)
        {
            Caption = 'Can Adjust Inventory';
            DataClassification = ToBeClassified;
        }
        field(140; "Can Load"; Boolean)
        {
            Caption = 'Can Load';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "App. User ID", "App. Type")
        {
            Clustered = true;
        }
    }
}
