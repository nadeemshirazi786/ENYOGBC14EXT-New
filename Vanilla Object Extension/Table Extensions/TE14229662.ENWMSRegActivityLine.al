//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// TableExtension EN WMS Reg Activity Line (ID 14229228) extends Record Registered Whse. Activity Line.
/// </summary>
tableextension 14229228 "WMS Reg Activity Line ELA" extends "Registered Whse. Activity Line"
{
    fields
    {
        field(14229220; "Assigned App. Role ELA"; Code[20])
        {
            TableRelation = "App. Role ELA";
            DataClassification = ToBeClassified;
        }
        field(14229221; "Assigned App. User ELA"; Code[10])
        {
            TableRelation = "App. Role ELA";
            DataClassification = ToBeClassified;
        }
        field(14229222; "Original Qty. ELA"; Decimal)
        {
            Caption = 'Original Qty.';
            DataClassification = ToBeClassified;
        }

        field(14229224; "Released On ELA"; DateTime)
        {
            Caption = 'Released On';
            DataClassification = ToBeClassified;
        }

        field(14229225; "Prioritized ELA"; Boolean)
        {
            Caption = 'Prioritized';
            DataClassification = ToBeClassified;
        }
        field(14229226; "Trip No. ELA"; Code[10])
        {
            Caption = 'Trip No.';
            DataClassification = ToBeClassified;
        }

        field(14229228; "Received By ELA"; Code[20])
        {
            Caption = 'Received By';
            DataClassification = ToBeClassified;
        }
        field(14229229; "Received Date ELA"; Date)
        {
            Caption = 'Received Date';
            DataClassification = ToBeClassified;
        }
        field(14229230; "Received Time ELA"; Time)
        {
            Caption = 'Received Time';
            DataClassification = ToBeClassified;
        }

        field(142292231; "Container No. ELA"; Code[20])
        {
            TableRelation = "Container ELA";
            DataClassification = ToBeClassified;
        }
        field(14229232; "Licnese Plate No. ELA"; code[20])
        {
            TableRelation = "License Plate ELA";
            DataClassification = ToBeClassified;
        }

        field(142292233; "Container Line No. ELA"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(142292234; "Parent Line No. ELA"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(144229240; "Pick Ticket No. ELA"; code[20])
        {

        }

        field(14229241; "Pick Ticket Line No. ELA"; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(14229242; "Processed Time ELA"; Time)
        {
            Caption = 'Processed Time';
            DataClassification = ToBeClassified;
        }
        field(14229243; "Reason Code ELA"; Code[20])
        {
            Caption = 'Reason Code';
            DataClassification = ToBeClassified;
        }
    }
}
