//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN License Plate Line (ID 14229222).
/// </summary>
table 14229272 "License Plate LineX ELA"
{
    Caption = 'License Plate LineX';
    DataClassification = ToBeClassified;

    fields
    {
        field(10; "License Plate No."; Code[20])
        {
            Caption = 'License Plate No.';
            DataClassification = ToBeClassified;
        }
        field(20; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }
        field(30; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                Item: Record "Item";
            begin
                item.Get("Item No.");
                Description := item.Description;
            end;
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

        field(80; "Location Code"; code[10])
        {
            TableRelation = Location;
            DataClassification = ToBeClassified;
        }

        field(90; "Zone Code"; Code[10])
        {
            TableRelation = Zone.Code WHERE("Location Code" = FIELD("Location Code"));
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

        field(110; "Gross Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(120; "Tare Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(5404; "Qty. Per Unit of Measure"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(6501; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';

            DataClassification = ToBeClassified;
            trigger onlookup()
            var
                ItemTrackingMgt: Codeunit "Item Tracking Management";
            begin
                ItemTrackingMgt.LookupLotSerialNoInfo("Item No.", "Variant Code", 1, "Lot No.");
            end;
        }
        field(6503; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = ToBeClassified;
        }
        field(6500; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            DataClassification = ToBeClassified;
        }
        field(6502; "Warranty Date"; Date)
        {
            Caption = 'Warranty Date';
            DataClassification = ToBeClassified;
        }

        field(14229270; "Created By"; Code[50])
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }

        field(14229271; "Created On"; DateTime)
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(14229272; "Last Updated By"; Code[50])
        {
            Editable = false;
            Caption = 'Last Updated By';
            TableRelation = user."User Name";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(14229273; "Last Updated On"; DateTime)
        {
            Editable = false;
            Caption = 'Last Updated On';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "License Plate No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        CheckLicensePlateIsValid;
        "Created By" := UserId();
        "Created On" := CurrentDateTime;
        "Last Updated By" := UserId();
        "Last Updated On" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        CheckLicensePlateIsValid;

        "Last Updated By" := UserId();
        "Last Updated On" := CurrentDateTime;
    end;

    local procedure CheckLicensePlateIsValid()
    var
        LicensePlateHdr: Record "License Plate ELA";
    begin
        LicensePlateHdr.Get();
        // if LicensePlateHdr.Status <> LicensePlateHdr.Status::Active then
        // Error(StrSubstNo(TEXT14229200, LicensePlateHdr."License No."));
    end;

    var
        TEXT14229200: TextConst ENU = 'License Plate %1 is not active';
}