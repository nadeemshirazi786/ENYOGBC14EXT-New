//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN License Plate Line History (ID 14229223).
/// </summary>
table 14229221 "License Plate Tracking ELA"
{
    Caption = 'License Plate Tracking';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "ID"; Integer)
        {
            Caption = 'ID';
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(10; "License Plate No."; Code[20])
        {
            Caption = 'License Plate No.';
            DataClassification = ToBeClassified;
        }
        field(20; "Parent Plate No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            DataClassification = ToBeClassified;
        }
        field(40; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(5402; "Variant Code"; code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
            DataClassification = ToBeClassified;
        }

        field(5407; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
            DataClassification = ToBeClassified;
        }
        field(50; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
        }
        field(60; "Qty. (Base)"; Decimal)
        {
            Caption = 'Qty. (Base)';
            DataClassification = ToBeClassified;
        }

        field(5404; "Qty. Per Unit of Measure"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(80; "Location Code"; code[10])
        {
            TableRelation = Location;
            DataClassification = ToBeClassified;
        }

        field(90; "Zone Code"; Code[10])
        {
            TableRelation = Zone;
            DataClassification = ToBeClassified;
        }

        field(100; "Bin Code"; Code[20])
        {
            TableRelation =
            IF ("Zone Code" = FILTER('')) Bin.Code WHERE("Location Code" = FIELD("Location Code"))
            ELSE
            if ("Zone Code" = FILTER(<> '')) Bin.Code WHERE("Location Code" = FIELD("Location Code"), "Zone Code" = FIELD("Zone Code"));
            DataClassification = ToBeClassified;
        }
        field(110; "Action"; text[30])
        {
            // OptionMembers = "","Added","Removed","Moved";
        }

        field(14229270; "Created By"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = user."User Name";
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(14229271; "Created On"; Date)
        {
            Caption = 'Created On';
            Editable = false;
            DataClassification = ToBeClassified;
        }

    }
    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}
