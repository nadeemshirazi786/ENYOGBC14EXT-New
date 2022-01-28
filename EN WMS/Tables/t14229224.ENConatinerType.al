//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN Liceense Plate Type (ID 14229224).
/// </summary>
table 14229224 "Conatiner Type ELA"
{
    Caption = 'Container Type';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }

        field(3; Active; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(100; "Tare Weight"; Decimal)
        {
            Caption = 'Tare Weight';
            DataClassification = ToBeClassified;
        }
        field(101; "Tare Unit of Measure"; Code[10])
        {
            Caption = 'Tare Unit of Measure';
            TableRelation = "Unit of Measure";
            DataClassification = ToBeClassified;
        }
        field(102; Capcity; Decimal)
        {
            Caption = 'Capcity';
            DataClassification = ToBeClassified;
        }
        field(103; "Capacity Unit of Measure"; Code[10])
        {
            Caption = 'Capacity Unit of Measure';
            TableRelation = "Unit of Measure";
            DataClassification = ToBeClassified;
        }
        field(200; "No. of Labels"; Integer)
        {
            Caption = 'No. of Labels';
            DataClassification = ToBeClassified;
        }
        field(201; "Default Report ID"; Integer)
        {
            Caption = 'Default Report ID';
            // TableRelation = //where(Type = const(Report));
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

}
