//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information/// <summary>

/// <summary>
/// Table EN WMS Bill of Lading Detail (ID 14229226).
/// </summary>
table 14229279 "WMS Bill of Lading Detail ELA"
{
    // DrillDownPageID = 50088;
    // LookupPageID = 50088;
    fields
    {
        field(10; "Bill of Lading No."; Code[20])
        {
        }
        field(20; "Line No."; Integer)
        {
        }
        field(21; "Line Type"; Option)
        {
            OptionCaption = 'Item,Text';
            OptionMembers = Item,Text;
        }
        field(30; "Order No."; Code[20])
        {
        }
        field(40; "Order Line No."; Integer)
        {
        }
        field(41; "Order Sub Line No."; Integer)
        {
        }
        field(50; "Shipment No."; Code[20])
        {
        }
        field(60; "Shipment Line No."; Integer)
        {
        }
        field(70; "Container ID"; Integer)
        {
        }
        field(71; "Pallet No."; Integer)
        {
        }
        field(73; "Pallet Line No."; Integer)
        {
        }
        field(74; "Load No."; Code[20])
        {
        }
        field(80; "Line Sequence"; Integer)
        {
        }
        field(90; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(100; Description; Text[50])
        {
        }
        field(120; "Product Date"; Date)
        {

            trigger OnValidate()
            begin
                //IF "Product Date" <> xRec."Product Date" THEN BEGIN
                // UpdateRegPickDocLine;
                VALIDATE("Prod. Date In Julian");
                //END;
            end;
        }
        field(130; "Prod. Date In Julian"; Text[10])
        {

            trigger OnValidate()
            var
                ENSysUtils: Codeunit "WMS Util ELA";
            begin
                // IF "Product Date" <> 0D THEN
                // "Prod. Date In Julian" := ENSysUtils.GetJulianDate("Product Date")
                // ELSE
                // "Prod. Date In Julian" := '';
            end;
        }
        field(140; "Qty on Pallet"; Decimal)
        {
            DecimalPlaces = 0 : 0;

            trigger OnValidate()
            begin
                // UpdateWeight; //9/15
            end;
        }
        field(160; Weight; Decimal)
        {
        }
        field(170; Comment; Text[80])
        {
        }
        field(180; "Bin Code"; Code[20])
        {
        }
        field(190; "Picked By"; Code[10])
        {
        }
        field(200; "Pick Ticket Sort"; Code[20])
        {
        }
        field(220; "Pick Ticket No."; Code[20])
        {

            trigger OnLookup()
            var
                RegWhseActHdr: Record "Registered Whse. Activity Hdr.";
            begin
                //<<EN1.04
                IF RegWhseActHdr.GET(RegWhseActHdr.Type::Pick, "Pick Ticket No.") THEN
                    PAGE.RUN(5798, RegWhseActHdr);
                //>>EN1.04
            end;
        }
        field(230; "Pick Ticket Line No."; Integer)
        {
        }
        field(231; "Reg. Pick Ticket No."; Code[20])
        {
        }
        field(232; "Reg. Pick Ticket Line No."; Integer)
        {
        }
        field(250; "Unit of Measure"; Code[10])
        {
        }
        field(260; Loaded; Boolean)
        {
        }
        field(300; "Line Status"; Option)
        {
            FieldClass = Normal;
            OptionMembers = Open,Deleted,Closed;
        }
        field(500; "QR Code"; BLOB)
        {
        }
        field(510; Signature; BLOB)
        {
        }
        field(50355; "EDI Segment Group"; Integer)
        {
            Caption = 'EDI Segment Group';
            Editable = false;
        }
        field(50356; "SSCC 18"; Text[30])
        {
        }
    }

    keys
    {
        key(Key1; "Bill of Lading No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = Weight, "Qty on Pallet";
        }
        key(Key2; "Product Date")
        {
        }
        key(Key3; "Load No.", "Pallet No.")
        {
        }
        key(Key4; "Bill of Lading No.", "Line Status", "Pallet No.")
        {
            SumIndexFields = "Qty on Pallet";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
    // PalletContInfo: Record "50072";
    begin
    end;

    var
        ShipDashbrdMgt: Codeunit "Shipment Mgmt. ELA";

    // procedure AssistEdit(OldBillOfLadingDet: Record "50055"): Boolean
    // var
    //     BillOfLadingDet: Record "EN WMS Bill of Lading Detail";
    // begin
    //     //<<EN1.01
    //     WITH BillOfLadingDet DO BEGIN
    //         BillOfLadingDet := OldBillOfLadingDet;
    //         // IF ShipDashbrdMgt.SelectBillOfLadingLine(OldBillOfLadingDet."Bill of Lading No.", OldBillOfLadingDet."Line No.",
    //         //    OldBillOfLadingDet."Container ID", OldBillOfLadingDet."Pallet No.", OldBillOfLadingDet."Pallet Line No.") THEN BEGIN
    //             BillOfLadingDet."Container ID" := OldBillOfLadingDet."Container ID";
    //             BillOfLadingDet."Pallet No." := OldBillOfLadingDet."Pallet No.";
    //             BillOfLadingDet."Pallet Line No." := OldBillOfLadingDet."Pallet Line No.";
    //             BillOfLadingDet.MODIFY;

    //             UpdateRegPickDocLine; //EN1.02
    //             EXIT(TRUE);
    //         END;
    //     END;
    //     //>>EN1.01
    // end;

    // procedure UpdateRegPickDocLine()
    // var
    //     RegWhseActLine: Record "Registered Whse. Activity Line";
    //     RegWhseActLine2: Record "Registered Whse. Activity Line";
    // begin
    //     //<<EN1.02
    //     IF RegWhseActLine.GET(RegWhseActLine."Activity Type"::Pick, "Pick Ticket No.", "Line No.") THEN BEGIN
    //         // IF "Product Date" <> 0D THEN
    //         //     RegWhseActLine."Code Date" := "Product Date";

    //         // IF "Container ID" <> 0 THEN
    //         //     RegWhseActLine."Container ID" := "Container ID";

    //         // IF "Pallet No." <> 0 THEN
    //         //     RegWhseActLine."Pallet No." := "Pallet No.";

    //         // IF "Pallet Line No." <> 0 THEN
    //         //     RegWhseActLine."Pallet Line No." := "Pallet Line No.";

    //         RegWhseActLine.MODIFY;

    //         RegWhseActLine2.RESET;
    //         RegWhseActLine2.SETRANGE("Activity Type", RegWhseActLine."Activity Type"::Pick);
    //         RegWhseActLine2.SETRANGE("No.", "Pick Ticket No.");
    //         // RegWhseActLine2.SETRANGE("Parent Line No.", "Line No.");
    //         IF RegWhseActLine2.FINDFIRST THEN BEGIN
    //             RegWhseActLine2."Code Date" := RegWhseActLine."Code Date";
    //             RegWhseActLine2."Container ID" := RegWhseActLine."Container ID";
    //             RegWhseActLine2."Pallet No." := RegWhseActLine."Pallet No.";
    //             RegWhseActLine2."Pallet Line No." := RegWhseActLine."Pallet Line No.";
    //             RegWhseActLine2.MODIFY;
    //         END;
    //     END;
    //     //>>EN1.02
    // end;

    procedure GetTotalPalletCount(BillOfLadingNo: Code[20]): Integer
    var
        TotalPallets: Integer;
        "Integer": Record Integer temporary;
    begin
        //<<EN1.05
        RESET;
        Rec.SETRANGE("Bill of Lading No.", BillOfLadingNo);
        Rec.SETFILTER("Line Status", '<>%1', "Line Status"::Deleted);
        IF FINDSET THEN
            REPEAT
                IF NOT Integer.GET("Pallet No.") THEN BEGIN
                    Integer.INIT;
                    Integer.Number := "Pallet No.";
                    Integer.INSERT;
                    TotalPallets := TotalPallets + 1;
                END;
            UNTIL NEXT = 0;

        EXIT(TotalPallets);
        //>>EN1.05
    end;

    procedure UpdateWeight()
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        //<<EN1.x 9/16
        IF ("Qty on Pallet" <> 0) AND ("Item No." <> '') AND ("Unit of Measure" <> '') THEN BEGIN
            IF ItemUOM.GET("Item No.", "Unit of Measure") THEN
                IF ItemUOM.Weight <> 0 THEN
                    Weight := ItemUOM.Weight * "Qty on Pallet";
        END ELSE
            Weight := 0;
        //>>EN1.x
    end;
}

