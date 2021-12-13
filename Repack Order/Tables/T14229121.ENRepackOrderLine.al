table 14229121 "EN Repack Order Line"
{


    Caption = 'Repack Order Line';


    fields
    {
        field(1; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            TableRelation = "EN Repack Order";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            InitValue = Item;
            OptionCaption = 'Item,Resource';
            OptionMembers = Item,Resource;

            trigger OnValidate()
            var
                TempRepackLine: Record "EN Repack Order Line";
            begin
                TestStatusOpen;

                TestField("Quantity Transferred", 0);

                if Type <> xRec.Type then begin

                    TempRepackLine := Rec;
                    Init;
                    Type := TempRepackLine.Type;
                end;

            end;
        }
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(Item)) Item WHERE(Type = CONST(Inventory))
            ELSE
            IF (Type = CONST(Resource)) Resource;

            trigger OnValidate()
            var
                TempRepackLine: Record "EN Repack Order Line";
            begin
                TestStatusOpen;

                TestField("Quantity Transferred", 0);

                TempRepackLine := Rec;
                Init;
                Type := TempRepackLine.Type;
                "No." := TempRepackLine."No.";

                if "No." = '' then
                    exit;

                case Type of
                    Type::Item:
                        begin
                            GetItem;
                            Item.TestField(Blocked, false);

                            Description := Item.Description;
                            "Description 2" := Item."Description 2";
                            "Unit of Measure Code" := Item."Base Unit of Measure";

                        end;
                    Type::Resource:
                        begin
                            GetResource;
                            Resource.TestField(Blocked, false);
                            Description := Resource.Name;
                            "Description 2" := Resource."Name 2";
                            "Unit of Measure Code" := Resource."Base Unit of Measure";
                        end;
                end;

                Validate("Unit of Measure Code");

                CreateDim(TypeToTable, "No.");

                GetDefaultBin;

            end;
        }
        field(5; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate()
            begin
                if "Variant Code" <> '' then
                    TestField(Type, Type::Item);
                TestStatusOpen;

                if xRec."Variant Code" <> "Variant Code" then begin
                    TestField("Quantity Transferred", 0);
                    GetDefaultBin;
                end;
            end;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(7; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(8; "Source Location"; Code[10])
        {
            Caption = 'Source Location';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate()
            begin
                if "Source Location" <> '' then
                    TestField(Type, Type::Item);
                TestStatusOpen;

                if xRec."Source Location" <> "Source Location" then begin
                    TestField("Quantity Transferred", 0);

                    GetLocation;
                    Location.TestField("Directed Put-away and Pick", false);

                    "Bin Code" := '';
                    GetDefaultBin;

                    UpdateQtyToTransfer;
                    UpdateQtyToConsume;
                end;
            end;
        }
        field(9; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = IF (Type = CONST(Item)) "Bin Content"."Bin Code" WHERE("Location Code" = FIELD("Source Location"),
                                                                                  "Item No." = FIELD("No."),
                                                                                  "Variant Code" = FIELD("Variant Code"));

            trigger OnValidate()
            begin
                if "Bin Code" <> '' then
                    TestField(Type, Type::Item);
                TestStatusOpen;

                if "Bin Code" <> '' then
                    WMSManagement.FindBinContent("Source Location", "Bin Code", "No.", "Variant Code", '');

                if xRec."Bin Code" <> "Bin Code" then
                    TestField("Quantity Transferred", 0);

                TestField("Source Location");

                if (Type = Type::Item) and ("Bin Code" <> '') then begin
                    GetLocation;
                    Location.TestField("Bin Mandatory");
                end;
            end;
        }
        field(10; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            IF (Type = CONST(Resource)) "Resource Unit of Measure".Code WHERE("Resource No." = FIELD("No."));

            trigger OnValidate()
            begin
                TestStatusOpen;
                TestField("Quantity Transferred", 0);

                case Type of
                    Type::Item:
                        begin
                            GetItem;

                            ItemUOM.Get("No.", "Unit of Measure Code");
                            "Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
                        end;
                    Type::Resource:
                        begin
                            ResourceUOM.Get("No.", "Unit of Measure Code");
                            "Qty. per Unit of Measure" := ResourceUOM."Qty. per Unit of Measure";
                        end;
                end;
                Validate(Quantity);

            end;
        }
        field(11; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            Editable = false;
        }
        field(12; Quantity; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if Quantity < "Quantity Transferred" then
                    Error(Text003, FieldCaption("Quantity Transferred"), FieldCaption(Quantity));

                "Quantity (Base)" := Round(Quantity * "Qty. per Unit of Measure", 0.00001);

                UpdateQtyToTransfer;
                UpdateQtyToConsume;

            end;
        }
        field(13; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }

        field(15; "Quantity to Transfer"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity to Transfer';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Quantity to Transfer" <> 0 then begin
                    TestField(Type, Type::Item);
                    GetHeader;
                    if "Source Location" = RepackOrder."Repack Location" then
                        Error(Text002, RepackOrder.FieldCaption("Repack Location"), FieldCaption("Source Location"));
                    if Quantity < "Quantity Transferred" + "Quantity to Transfer" then
                        Error(Text003, FieldCaption("Quantity Transferred"), FieldCaption(Quantity));
                end;

                "Quantity to Transfer (Base)" := Round("Quantity to Transfer" * "Qty. per Unit of Measure", 0.00001);

                UpdateQtyToConsume;

            end;
        }
        field(16; "Quantity to Transfer (Base)"; Decimal)
        {
            Caption = 'Quantity to Transfer (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }

        field(18; "Quantity Transferred"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity Transferred';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(19; "Quantity Transferred (Base)"; Decimal)
        {
            Caption = 'Quantity Transferred (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }

        field(21; "Quantity to Consume"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity to Consume';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if Quantity < "Quantity to Consume" then
                    Error(Text003, FieldCaption("Quantity to Consume"), FieldCaption(Quantity));

                "Quantity to Consume (Base)" := Round("Quantity to Consume" * "Qty. per Unit of Measure", 0.00001);

            end;
        }
        field(22; "Quantity to Consume (Base)"; Decimal)
        {
            Caption = 'Quantity to Consume (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }

        field(24; "Quantity Consumed"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity Consumed';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(25; "Quantity Consumed (Base)"; Decimal)
        {
            Caption = 'Quantity Consumed (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }

        field(27; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            TableRelation = IF (Type = CONST(Item)) "Lot No. Information"."Lot No." WHERE("Item No." = FIELD("No."),
                                                                                         "Variant Code" = FIELD("Variant Code"));

            trigger OnValidate()
            begin
                if "Lot No." <> '' then
                    TestField(Type, Type::Item);
                TestField("No.");
                GetItem;
                Item.TestField("Item Tracking Code");

                if "Lot No." <> xRec."Lot No." then
                    TestField("Quantity Transferred", 0);


            end;
        }
        field(30; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(31; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }

        field(81; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'Open,Finished';
            OptionMembers = Open,Finished;
        }
        field(82; "Due Date"; Date)
        {
            Caption = 'Due Date';
            Editable = false;
        }
        field(83; "Repack Location"; Code[10])
        {
            Caption = 'Repack Location';
            Editable = false;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin

                ShowDimensions;
            end;
        }
    }

    keys
    {
        key(Key1; "Order No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; Status, Type, "No.", "Variant Code", "Source Location", "Due Date")
        {
            SumIndexFields = "Quantity (Base)", "Quantity Transferred (Base)";
        }
        key(Key3; Status, Type, "No.", "Variant Code", "Repack Location", "Due Date")
        {
            SumIndexFields = "Quantity Transferred (Base)";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestStatusOpen;

        TestField("Quantity Transferred", 0);


    end;

    trigger OnInsert()
    begin
        TestStatusOpen;

        GetHeader;
        RepackOrder.TestField("Item No.");
        RepackOrder.TestField(Quantity);


        "Due Date" := RepackOrder."Due Date";
        "Repack Location" := RepackOrder."Repack Location";

    end;

    trigger OnModify()
    begin
        TestStatusOpen;
    end;

    var
        RepackOrder: Record "EN Repack Order";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemUOM: Record "Item Unit of Measure";
        Resource: Record Resource;
        ResourceUOM: Record "Resource Unit of Measure";
        Location: Record Location;
        DimMgt: Codeunit DimensionManagement;
        Text001: Label '%1 %2 must be open.';
        WMSManagement: Codeunit "WMS Management";
        Text002: Label 'No transfer allowed when %1 is the same as %2.';
        Text003: Label '%1 cannot exceed %2.';


    procedure GetHeader()
    begin
        if "Order No." <> RepackOrder."No." then
            if "Order No." <> '' then
                RepackOrder.Get("Order No.")
            else
                Clear(RepackOrder);
    end;


    procedure GetItem()
    begin
        if Type <> Type::Item then
            Clear(Item)
        else
            if "No." <> Item."No." then
                Item.Get("No.")
            else
                if "No." = '' then
                    Clear(Item);
    end;


    procedure GetResource()
    begin
        if Type <> Type::Resource then
            Clear(Resource)
        else
            if "No." <> Resource."No." then
                Resource.Get("No.")
            else
                if "No." = '' then
                    Clear(Resource);
    end;


    procedure GetLocation()
    begin
        if "Source Location" <> Location.Code then
            Location.Get("Source Location")
        else
            Clear(Location);
    end;


    procedure TestStatusOpen()
    begin
        GetHeader;
        if RepackOrder.Status <> RepackOrder.Status::Open then
            Error(Text001, RepackOrder.TableCaption, RepackOrder."No.");
    end;


    procedure TypeToTable(): Integer
    begin
        case Type of
            Type::Item:
                exit(DATABASE::Item);
            Type::Resource:
                exit(DATABASE::Resource);
        end;
    end;


    procedure CreateDim(Type1: Integer; No1: Code[20])
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        TableID[1] := Type1;
        No[1] := No1;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" := DimMgt.GetDefaultDimID(
          TableID, No, '',
          "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
    end;


    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;


    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;


    procedure ShowDimensions()
    begin
        // P8001113
        if RepackOrder.Status = RepackOrder.Status::Open then
            DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', "Order No.", "Line No."))
        else
            "Dimension Set ID" :=
              DimMgt.EditDimensionSet2(
                "Dimension Set ID", StrSubstNo('%1 %2', "Order No.", "Line No."),
                "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    local procedure GetDefaultBin()
    var
        WMSManagement: Codeunit "WMS Management";
    begin
        if Type <> Type::Item then
            exit;

        if ("No." = xRec."No.") and
           ("Source Location" = xRec."Source Location") and
           ("Variant Code" = xRec."Variant Code")
        then
            exit;

        "Bin Code" := '';

        if ("Source Location" <> '') and ("No." <> '') then begin
            GetLocation;
            if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then
                WMSManagement.GetDefaultBin("No.", "Variant Code", "Source Location", "Bin Code");
        end;
    end;


    procedure UpdateQtyToTransfer()
    begin
        if Type <> Type::Item then
            exit;

        GetHeader;
        if (RepackOrder."Repack Location" = "Source Location") or (RepackOrder.Status = RepackOrder.Status::Finished) then
            Validate("Quantity to Transfer", 0)
        else
            if Quantity <= "Quantity Transferred" then
                Validate("Quantity to Transfer", 0)
            else
                Validate("Quantity to Transfer", Quantity - "Quantity Transferred");
    end;


    procedure UpdateQtyToConsume()
    begin
        GetHeader;
        if RepackOrder.Status = RepackOrder.Status::Finished then
            Validate("Quantity to Consume", 0)
        else
            case Type of
                Type::Item:
                    if RepackOrder."Repack Location" = "Source Location" then
                        Validate("Quantity to Consume", Quantity)
                    else
                        Validate("Quantity to Consume", "Quantity Transferred" + "Quantity to Transfer");
                Type::Resource:
                    Validate("Quantity to Consume", Quantity);
            end;
    end;


    procedure LotNoLookup(var LotNo: Text[1024]): Boolean
    var
        TrackingSpec: Record "Tracking Specification";
        ItemTrackingDCMgt: Codeunit "Item Tracking Data Collection";
    begin
        if Type <> Type::Item then
            exit(false);

        if "Quantity Transferred" <> 0 then
            exit(false);

        TestField("No.");
        GetItem;
        Item.TestField("Item Tracking Code");

        TrackingSpec."Item No." := "No.";
        TrackingSpec."Location Code" := "Source Location";
        TrackingSpec.Description := Description;
        TrackingSpec."Variant Code" := "Variant Code";
        TrackingSpec."Source Subtype" := 3;
        if "Quantity to Transfer" <> 0 then begin
            TrackingSpec."Quantity (Base)" := "Quantity to Transfer (Base)";
            TrackingSpec."Qty. to Handle" := "Quantity to Transfer";
            TrackingSpec."Qty. to Handle (Base)" := "Quantity to Transfer (Base)";
            TrackingSpec."Qty. to Invoice" := "Quantity to Transfer";
            TrackingSpec."Qty. to Invoice (Base)" := "Quantity to Transfer (Base)";
            TrackingSpec."Bin Code" := "Bin Code";
        end else begin
            TrackingSpec."Quantity (Base)" := "Quantity to Consume (Base)";
            TrackingSpec."Qty. to Handle" := "Quantity to Consume";
            TrackingSpec."Qty. to Handle (Base)" := "Quantity to Consume (Base)";
            TrackingSpec."Qty. to Invoice" := "Quantity to Consume";
            TrackingSpec."Qty. to Invoice (Base)" := "Quantity to Consume (Base)";
        end;
        TrackingSpec."Qty. per Unit of Measure" := "Qty. per Unit of Measure";

        ItemTrackingDCMgt.AssistEditTrackingNo(TrackingSpec, true, -1, 1, TrackingSpec."Quantity (Base)");
        LotNo := TrackingSpec."Lot No.";
        exit(LotNo <> '');
    end;
}

