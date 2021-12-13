table 14229164 "EN Commdity Manifest Hdr ELA"
{
    Caption = 'Commodity Manifest Header';
    DataCaptionFields = "No.", "Item No.";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin

            end;
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Bin Mandatory" = CONST(true),
                                            "Require Put-away" = CONST(false),
                                            "Require Receive" = CONST(false));

            trigger OnValidate()
            begin
                if ("Location Code" <> xRec."Location Code") then begin
                    CheckAllLinesOpen(FieldCaption("Location Code"));
                    CheckAndDeleteDestBins(FieldCaption("Location Code"));
                    Validate("Bin Code", '');
                end;
            end;
        }
        field(3; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;

            trigger OnValidate()
            begin
                if ("Item No." <> xRec."Item No.") then begin
                    CheckAllLinesOpen(FieldCaption("Item No."));
                    Validate("Variant Code", '');
                    Validate("Unit of Measure Code", '');
                end;

                if ("Item No." <> '') then begin
                    Item.Get("Item No.");
                end;
            end;
        }
        field(5; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(6; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(7; "Received Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Received Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if ("Empty Scale Quantity" = 0) then
                    "Loaded Scale Quantity" := 0
                else
                    if ("Loaded Scale Quantity" = 0) then
                        "Empty Scale Quantity" := 0
                    else
                        "Loaded Scale Quantity" := "Empty Scale Quantity" + "Received Quantity";
            end;
        }
        field(8; "Loaded Scale Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Loaded Scale Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if ("Empty Scale Quantity" > "Loaded Scale Quantity") then
                    "Empty Scale Quantity" := "Loaded Scale Quantity";
                if ("Loaded Scale Quantity" <> 0) and ("Empty Scale Quantity" <> 0) then
                    "Received Quantity" := "Loaded Scale Quantity" - "Empty Scale Quantity";
            end;
        }
        field(9; "Empty Scale Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Empty Scale Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if ("Loaded Scale Quantity" < "Empty Scale Quantity") then
                    "Loaded Scale Quantity" := "Empty Scale Quantity";
                if ("Loaded Scale Quantity" <> 0) and ("Empty Scale Quantity" <> 0) then
                    "Received Quantity" := "Loaded Scale Quantity" - "Empty Scale Quantity";
            end;
        }
        field(10; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(11; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(12; "Receiving No."; Code[20])
        {
            Caption = 'Receiving No.';
        }
        field(13; "Receiving No. Series"; Code[20])
        {
            Caption = 'Receiving No. Series';
            TableRelation = "No. Series";

            trigger OnLookup()
            begin
                CommManifestHeader := Rec;
                InvtSetup.Get;
                Rec := CommManifestHeader;
            end;



            trigger OnValidate()
            begin
                if ("Receiving No. Series" <> '') then begin
                    InvtSetup.Get;
                end;
                TestField("Receiving No.", '');
            end;
        }
        field(15; "Manifest Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Manifest Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = Normal;
        }
        field(16; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(17; "Hauler No."; Code[20])
        {
            Caption = 'Hauler No.';
            TableRelation = Vendor WHERE("Commodity Vendor Type ELA" = CONST(Hauler));
        }
        field(18; "Product Rejected"; Boolean)
        {
            Caption = 'Product Rejected';

            trigger OnValidate()
            begin
                if "Product Rejected" then
                    CheckAndDeleteDestBins(FieldCaption("Product Rejected"))
                else begin
                    CommManifestLine.Reset;
                    CommManifestLine.SetRange("Commodity Manifest No.", "No.");
                    CommManifestLine.SetFilter("Rejection Action", '>0');
                    if CommManifestLine.FindFirst then
                        CommManifestLine.FieldError("Rejection Action");
                end;
            end;
        }
        field(19; "Broker No."; Code[20])
        {
            Caption = 'Broker No.';
            TableRelation = Vendor WHERE("Commodity Vendor Type ELA" = CONST(Broker));

            trigger OnValidate()
            begin
                if ("Broker No." <> xRec."Broker No.") then
                    CheckAllLinesOpen(FieldCaption("Broker No."));
            end;
        }
        field(20; "Destination Bin Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Destination Bin Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = Normal;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Location Code", "Bin Code", "Posting Date")
        {
        }
        key(Key3; "Item No.", "Posting Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CommManifestLine.Reset;
        CommManifestLine.SetRange("Commodity Manifest No.", "No.");
        CommManifestLine.DeleteAll(true);

    end;

    trigger OnInsert()
    begin
        InvtSetup.Get;
        if ("No." = '') then begin
        end;

        "Posting Date" := WorkDate;
        if ("Location Code" = '') then begin
        end;

    end;

    trigger OnRename()
    begin
        Error(Text000, TableCaption);
    end;

    var
        InvtSetup: Record "Inventory Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        CommManifestHeader: Record "EN Commdity Manifest Hdr ELA";
        CommManifestLine: Record "EN Commodity Manifest Line ELA";
        P800ItemTracking: Codeunit "Process 800 Item Tracking ELA";
        Item: Record Item;
        Location: Record Location;
        Text000: Label 'You cannot rename a %1.';
        Text001: Label 'You cannot change %1 with Destination Bins specified.';
        Text002: Label 'Do you want to assign a %1?';
        Text003: Label 'You cannot change %1 because linked Purchase Order Lines exist.';

    [Scope('Internal')]
    procedure AssistEditNo(OldCommManifestHeader: Record "EN Commdity Manifest Hdr ELA"): Boolean
    begin

    end;


    procedure AssistEditLotNo(OldCommManifestHeader: Record "EN Commdity Manifest Hdr ELA"): Boolean
    begin
        TestField("Item No.");
        if Confirm(Text002, false, FieldCaption("Lot No.")) then begin
            AssignLotNo;
            exit(true);
        end;
    end;

    procedure AssignLotNo()
    begin

    end;

    [Scope('Internal')]
    procedure GetBaseQty(Qty: Decimal): Decimal
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        ItemUOM.Get("Item No.", "Unit of Measure Code");
        exit(Round(Qty * ItemUOM."Qty. per Unit of Measure", 0.00001));
    end;

    local procedure CheckAndDeleteDestBins(FldCaption: Text[250])
    begin
    end;

    [Scope('Internal')]
    procedure GetAdjmtQty(): Decimal
    begin

    end;


    procedure CheckAllLinesOpen(FldCaption: Text[250])
    begin
        CommManifestLine.Reset;
        CommManifestLine.SetRange("Commodity Manifest No.", "No.");
        CommManifestLine.SetFilter("Purch. Order Status", '>%1', CommManifestLine."Purch. Order Status"::Open);
        if not CommManifestLine.IsEmpty then
            Error(Text003, FldCaption);
    end;
}

