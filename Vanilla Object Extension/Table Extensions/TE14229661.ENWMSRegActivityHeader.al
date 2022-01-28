//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// TableExtension EN WMS Reg. Activity Header (ID 14229227) extends Record Registered Whse. Activity Hdr..
/// </summary>
tableextension 14229227 "WMS Reg. Activity Header ELA" extends "Registered Whse. Activity Hdr."
{
    fields
    {
        field(14229200; "Assigned App. Role ELA"; Code[10])
        {
            TableRelation = "App. Role ELA";
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229201; "Assigned App. User ELA"; Code[10])
        {
            TableRelation = "Application User ELA";
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229202; "Ship-to Code ELA"; Code[10])
        {
            Caption = 'Ship-to Code';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(14229203; "Ship-to Name ELA"; Text[50])
        {
            Caption = 'Ship-to Name';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(14229204; "Trip No. ELA"; Code[20])
        {
            Caption = 'Trip No.';
            TableRelation = "Trip Load ELA";
            Editable = false;
            // FieldClass = FlowField;
            // CalcFormula = lookup("Warehouse Activity Line"."Trip No." where("No." = field("No.")));
        }
        // field(14229205; "Release Time"; DateTime)
        // {
        //     Caption = 'Release Time';
        //     DataClassification = ToBeClassified;
        // }
        field(14229206; "Created By ELA"; Code[20])
        {
            Editable = false;
            Caption = 'Created By';
            DataClassification = ToBeClassified;
        }
        field(14229207; "Created On Date Time ELA"; DateTime)
        {
            Caption = 'Created On Date Time';
            Editable = false;
            DataClassification = ToBeClassified;
        }
    }
}
