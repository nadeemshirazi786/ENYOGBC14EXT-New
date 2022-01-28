//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN Mobile App (ID 14229201).
/// </summary>
table 14229201 "Application ELA"
{
    DataPerCompany = false;
    fields
    {
        field(10; "App. Code"; Code[10])
        {
        }

        field(20; "App. Name"; text[30])
        {
        }

        field(30; Enabled; Boolean) { }

        field(40; "Use Roles"; Boolean)
        {

        }
        field(1000; "License Key"; Text[255])
        {

        }

        field(60; "App. Type"; Option)
        {
            OptionMembers = Floor,DSD,Sales;
        }

        field(1010; "Use Multi company"; Boolean)
        {

        }

        field(1020; "Default Company Code"; text[30])
        {
            TableRelation = Company;
        }
    }

    keys
    {
        key("PK"; "App. Code") { Clustered = true; }
    }

    trigger OnInsert()
    begin
        // "App. Code" := CreateGuid();
    end;
}