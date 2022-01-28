//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN Mobile App. Setup (ID 14229205).
/// </summary>
table 14229205 "Application Setup ELA"
{
    Caption = 'Application Setup';
    DataClassification = ToBeClassified;
    DataPerCompany = false;
    fields
    {
        field(10; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = ToBeClassified;
        }
        field(1000; "App. Login Time Out"; Integer)
        {
            Caption = 'App. Login Time Out';
            DataClassification = ToBeClassified;
        }

        field(1010; "Clear Assignments On Logout"; Boolean)
        {

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
