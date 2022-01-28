//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// TableExtension EN WMS Activity Header (ID 14229225) extends Record Warehouse Activity Header.
/// </summary>
tableextension 14229225 "WMS Activity Header ELA" extends "Warehouse Activity Header"
{
    fields
    {
        field(14229200; "Assigned App. Role ELA"; Code[10])
        {
            TableRelation = "App. Role ELA";
            DataClassification = ToBeClassified;
        }
        field(14229201; "Assigned App. User ELA"; Code[10])
        {
            TableRelation = "Application User ELA";
            DataClassification = ToBeClassified;
        }
        field(14229220; "Ship-to Code ELA"; Code[10])
        {
            Caption = 'Ship-to Code';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229221; "Ship-to Name ELA"; Text[50])
        {
            Caption = 'Ship-to Name';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229222; "Trip No. ELA"; Code[10])
        {
            Caption = 'Trip No.';
            TableRelation = "Trip Load ELA";
            DataClassification = ToBeClassified;
            Editable = false;
        }


        // field(14229205; "Release Time"; DateTime)
        // {
        //     Caption = 'Release Time';
        //     DataClassification = ToBeClassified;
        //     Editable = false;
        // }
        field(14229270; "Created By ELA"; Code[20])
        {
            Caption = 'Created By';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229271; "Created On Date Time ELA"; DateTime)
        {
            Caption = 'Created On Date Time';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
}
