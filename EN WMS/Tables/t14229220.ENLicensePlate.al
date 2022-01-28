//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN License Plate (ID 14229221).
/// </summary>
table 14229220 "License Plate ELA"
{
    Caption = 'License Plate';
    DataClassification = ToBeClassified;
    LookupPageId = "License Plate List ELA";

    fields
    {
        field(10; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = ToBeClassified;
            trigger Onvalidate()
            begin
                IF "No." <> xRec."No." THEN BEGIN
                    GetWMSSetup;
                    NoSeriesMgt.TestManual(WMSSetup."License Plate Nos.");
                END;
            end;
        }

        field(20; "Parent Plate No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        // field(20; Status; Enum "EN WMS License Plate Status")
        // {
        //     Caption = 'Status';
        //     DataClassification = ToBeClassified;
        // }
        field(30; Type; Code[10])
        {
            // TableRelation = "EN Conatiner Type".Code where(Active = const(true));
        }

        // field(40; "Location"; Code[20])
        // {
        //     TableRelation = Location;
        //     DataClassification = ToBeClassified;
        // }

        // field(50; Direction; Enum "EN WMS Trip Direction")
        // {
        //     DataClassification = ToBeClassified;
        // }

        // field(60; "Document Type"; Integer)
        // {
        //     DataClassification = ToBeClassified;
        // }

        // field(70; "Doc. Sub Type"; Blob)
        // {
        //     DataClassification = ToBeClassified;
        // }

        // field(80; "Document No."; Code[20])
        // {
        //     DataClassification = ToBeClassified;
        // }

        // field(90; "Whse. Document Type"; Enum "EN Whse. Doc. Type")
        // {
        //     DataClassification = ToBeClassified;
        // }

        // field(100; "Whse. Document No."; code[20])
        // {
        //     DataClassification = ToBeClassified;
        // }

        // field(110; "Tare Weight"; Decimal)
        // {
        //     DataClassification = ToBeClassified;
        // }

        // field(120; "Pallet Weight"; Decimal)
        // {
        //     DataClassification = ToBeClassified;
        // }

        field(1000; "No. Series"; code[20])
        {
            TableRelation = "No. Series";
            DataClassification = ToBeClassified;
        }

        field(14229290; "Created On"; DateTime)
        {
            Caption = 'Created On';
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(14229291; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229292; "Last Updated By"; Code[50])
        {
            Caption = 'Last Updated By';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14229293; "Last Updated On"; DateTime)
        {
            Caption = 'Last Updated On';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
        NoSeriesMgt: Codeunit "NoSeriesManagement";
        HasWMSSetup: boolean;
        WMSSetup: Record "WMS Setup ELA";

    trigger OnInsert()
    begin
        IF "No." = '' THEN BEGIN
            GetWMSSetup();
            WMSSetup.TESTFIELD("License Plate Nos.");
            NoSeriesMgt.InitSeries(WMSSetup."License Plate Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        END;
        // Status := Status::Active;
        "Created On" := CurrentDateTime;
        "Created By" := UserId();
        "Last Updated By" := userid;
        "Last Updated On" := CurrentDateTime;
    end;


    trigger OnModify()
    begin
        "Last Updated By" := userid;
        "Last Updated On" := CurrentDateTime;
    end;

    local procedure GetWMSSetup()
    begin
        if NOT HasWMSSetup then begin
            WMSSetup.get;
            HasWMSSetup := true;
        end;
    end;
}
