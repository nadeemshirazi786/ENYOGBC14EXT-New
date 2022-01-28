//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN Conatiner (ID 14229223).
/// </summary>

table 14229223 "Container Content ELA"
{
    Caption = 'Container Content';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Container No."; Code[20])
        {
            Caption = 'Container No.';
            TableRelation = "Container ELA";
            DataClassification = ToBeClassified;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }

        // field(3; "Pallet No."; Integer)
        // {
        //     Caption = 'Pallet No.';
        //     DataClassification = ToBeClassified;
        // }

        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                Item.Get("Item No.");
                Description := item.Description;
            end;
        }

        field(11; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }

        field(12; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
        }

        field(13; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
            DataClassification = ToBeClassified;
        }

        field(14; "License Plate No."; Code[20])
        {
            Caption = 'License Plate No.';
            TableRelation = "License Plate ELA";
            DataClassification = ToBeClassified;
        }

        field(15; "Location Code"; Code[20])
        {
            Caption = 'Location';
            TableRelation = Location;
            DataClassification = ToBeClassified;
        }

        field(16; Zone; Code[10])
        {
            Caption = 'Zone';
            TableRelation = Zone where("Location Code" = field("Location Code"));
            DataClassification = ToBeClassified;
        }

        field(17; "Bin Code"; Code[10])
        {
            Caption = 'Bin Code';
            TableRelation = Bin where("Location Code" = field("Location Code"));
            DataClassification = ToBeClassified;
        }

        field(18; Weight; Decimal)
        {
            Caption = 'Weight';
            DataClassification = ToBeClassified;
        }

        field(19; "Vendor Lot No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Document Type"; Integer)
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(20; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(21; "Document Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(22; "Whse. Document Type"; Enum "Whse. Doc. Type ELA")
        {
            DataClassification = ToBeClassified;
        }

        field(23; "Whse. Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(24; "Activity Type"; Enum "WMS Activity Type ELA")
        {
            DataClassification = ToBeClassified;
        }

        field(25; "Activity No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(26; "Activity Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(30; "Trip No."; code[20])
        {
            TableRelation = "Trip Load ELA";
        }
    }

    keys
    {
        key(PK; "Container No.", "Line No.")
        {
            Clustered = true;
        }
    }


    trigger OnInsert()
    var
        Container: Record "Container ELA";
        LicensePlateMgmt: Codeunit "License Plate Mgmt. ELA";
        LicensePlateNo: code[20];
    begin
        if Container.Get("Container No.") then
            validate("Location Code", Container."Location Code");

        //  LicensePlateNo := LicensePlateMgmt.CreateNewLicensePlate('', Container."Container Type");
        "License Plate No." := LicensePlateMgmt.GetLicensePlateByContainerNo(Container."No.", Container."Container Type");
        // incrementing by 2 ? 
    end;

    trigger OnDelete()
    var
        WhseActLine: record "Warehouse Activity Line";
    begin
        if rec."Activity Type" = "Activity Type"::Pick then begin
            if "Activity No." <> '' then begin
                WhseActLine.reset;
                WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::Pick);
                WhseActLine.SetRange("No.", "Activity No.");
                WhseActLine.SetRange("Container No. ELA", "Container No.");
                if whseactline.FindSet() then
                    repeat
                        WhseActLine."Container No. ELA" := '';
                        WhseActLine."Licnese Plate No. ELA" := '';
                        WhseActLine.Modify();
                    until WhseActLine.Next() = 0;
            end;
        end;
    end;
}
