table 14229120 "EN Repack Order"
{

    Caption = 'Repack Order';


    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    InvSetup.Get;
                    NoSeriesMgt.TestManual(InvSetup."Repack Order Nos. ELA");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'Open,Finished';
            OptionMembers = Open,Finished;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item WHERE(Type = CONST(Inventory));

            trigger OnValidate()
            begin
                if "Item No." = '' then
                    exit;


                GetItem;
                Item.TestField(Blocked, false);
                Validate(Description, Item.Description);
                "Description 2" := Item."Description 2";
                Validate("Unit of Measure Code", Item."Base Unit of Measure");
                CreateDim(DATABASE::Item, "Item No.");
                InitRecord;


            end;
        }
        field(4; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                if "Variant Code" = '' then begin
                    Validate("Item No.");
                    exit;
                end;
                ItemVariant.Get("Item No.", "Variant Code");
                Description := ItemVariant.Description;
                "Description 2" := ItemVariant."Description 2";
            end;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                if ("Search Description" = UpperCase(xRec.Description)) or ("Search Description" = '') then
                    "Search Description" := Description;
            end;
        }
        field(6; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(7; "Search Description"; Code[100])
        {
            Caption = 'Search Description';
        }
        field(8; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            Editable = false;
        }
        field(9; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(10; Comment; Boolean)
        {
            Caption = 'Comment';
            Editable = false;
            FieldClass = Normal;
        }
        field(11; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(12; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(13; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(14; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(21; "Repack Location"; Code[10])
        {
            Caption = 'Repack Location';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate()
            var
                RepackLine: Record "EN Repack Order Line";
            begin
                if "Repack Location" <> '' then begin
                    Location.Get("Repack Location");
                    Location.TestField("Bin Mandatory", false);
                end;

                if "Destination Location" = xRec."Repack Location" then
                    Validate("Destination Location", "Repack Location");

                if "Repack Location" <> xRec."Repack Location" then begin
                    AutoLot;
                    if Modify then;
                    RepackLine.SetRange("Order No.", "No.");
                    if RepackLine.FindSet(true, false) then
                        repeat
                            RepackLine.TestField("Quantity Transferred", 0);
                            RepackLine.UpdateQtyToTransfer;
                            RepackLine.UpdateQtyToConsume;
                            RepackLine."Repack Location" := "Repack Location";
                            RepackLine.Modify;
                        until RepackLine.Next = 0;
                end;
            end;
        }
        field(22; "Destination Location"; Code[10])
        {
            Caption = 'Destination Location';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate()
            begin
                if "Destination Location" <> xRec."Destination Location" then begin
                    if "Destination Location" <> '' then
                        Location.Get("Destination Location")
                    else
                        Clear(Location);

                    Location.TestField("Directed Put-away and Pick", false);

                    "Bin Code" := '';
                    if ("Destination Location" <> '') and ("Item No." <> '') then
                        if Location."Bin Mandatory" then
                            WMSManagement.GetDefaultBin("Item No.", "Variant Code", "Destination Location", "Bin Code");
                end;
            end;
        }
        field(23; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Destination Location"),
                                            "Item Filter" = FIELD("Item No."),
                                            "Variant Filter" = FIELD("Variant Code"));
        }
        field(24; "Date Required"; Date)
        {
            Caption = 'Date Required';

            trigger OnValidate()
            var
                RepackLine: Record "EN Repack Order Line";
            begin

                if "Date Required" <> xRec."Date Required" then begin
                    if ("Due Date" = 0D) or ("Due Date" = xRec."Date Required") then
                        "Due Date" := "Date Required";
                end;

            end;
        }
        field(25; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                GetItem;

                ItemUOM.Get("Item No.", Item."Base Unit of Measure");
                "Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
                Validate(Quantity);

            end;
        }
        field(26; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            Editable = false;
        }
        field(27; Quantity; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            var
                factor: Decimal;
            begin
                "Quantity (Base)" := Round(Quantity * "Qty. per Unit of Measure", 0.00001);

                GetItem;

                Validate("Quantity to Produce", Quantity);

                RepackLine.Reset;
                RepackLine.SetRange("Order No.", "No.");
                if RepackLine.FindSet(true, false) then begin
                    factor := Quantity / xRec.Quantity;
                    repeat
                        RepackLine.Validate(Quantity, Round(RepackLine.Quantity * factor, 0.00001));
                        RepackLine.Modify;
                    until RepackLine.Next = 0;
                end;

            end;
        }
        field(28; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }

        field(30; "Quantity to Produce"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity to Produce';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Quantity to Produce" > Quantity then
                    Error(Text002, FieldCaption("Quantity to Produce"), FieldCaption(Quantity));

                "Quantity to Produce (Base)" := Round("Quantity to Produce" * "Qty. per Unit of Measure", 0.00001);
            end;
        }
        field(31; "Quantity to Produce (Base)"; Decimal)
        {
            Caption = 'Quantity to Produce (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }

        field(33; "Quantity Produced"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity Produced';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(34; "Quantity Produced (Base)"; Decimal)
        {
            Caption = 'Quantity Produced (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }

        field(36; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';

            trigger OnValidate()
            begin

                if "Lot No." <> '' then begin
                    GetItem;
                    Item.TestField("Item Tracking Code");
                end;


            end;
        }
        field(37; Farm; Text[30])
        {
            Caption = 'Farm';
        }
        field(38; Brand; Text[30])
        {
            Caption = 'Brand';
        }
        field(39; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
        }
        field(40; "Due Date"; Date)
        {
            Caption = 'Due Date';

            trigger OnValidate()
            begin
                // P8000936
                if "Due Date" <> xRec."Due Date" then begin
                    RepackLine.SetRange("Order No.", "No.");
                    if RepackLine.FindSet(true, false) then
                        repeat
                            RepackLine."Due Date" := "Due Date";
                            RepackLine.Modify;
                        until RepackLine.Next = 0;
                end;

            end;
        }
        field(50; Transfer; Boolean)
        {
            Caption = 'Transfer';
        }
        field(51; Produce; Boolean)
        {
            Caption = 'Produce';
        }

        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin

                ShowDocDim;
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; Status)
        {
        }
        key(Key3; "Search Description")
        {
        }
        key(Key4; Status, "Item No.", "Variant Code", "Destination Location", "Due Date")
        {
            SumIndexFields = "Quantity (Base)";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestField(Status, Status::Open);


        DeleteLines;



    end;

    trigger OnInsert()
    begin
        InvSetup.Get;
        if "No." = '' then begin
            InvSetup.TestField("Repack Order Nos. ELA");
            NoSeriesMgt.InitSeries(InvSetup."Repack Order Nos. ELA", xRec."No. Series", "Date Required", "No.", "No. Series");
        end;
        InitRecord;

        "Creation Date" := Today;
    end;

    trigger OnModify()
    begin
        TestField(Status, Status::Open);
        "Last Date Modified" := Today;
    end;

    trigger OnRename()
    begin
        Error(Text001, TableCaption);
    end;

    var
        RepackLine: Record "EN Repack Order Line";
        InvSetup: Record "Inventory Setup";
        Text001: Label 'You cannot rename a %1.';
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemUOM: Record "Item Unit of Measure";
        Location: Record Location;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        WMSManagement: Codeunit "WMS Management";
        Text002: Label '%1 cannot exceed %2.';
        Text003: Label 'Existing lines for %1 %2 will be deleted.  Continue?';
        Text005: Label 'Items have been transferred.  Continue?';


    procedure InitRecord()
    begin
        InvSetup.Get;

        Validate("Posting Date", WorkDate);
        Validate("Date Required", WorkDate);
        Validate("Repack Location", InvSetup."Default Repack Location ELA");
        Validate("Destination Location", "Repack Location");
        "Variant Code" := '';
        Validate(Quantity, 0);
        "Lot No." := '';
        Farm := '';
        Brand := '';

        DeleteLines;
    end;


    procedure DeleteLines()
    begin
        RepackLine.SetRange("Order No.", "No.");
        RepackLine.DeleteAll(true);
    end;


    procedure AssistEdit(OldRepackOrder: Record "EN Repack Order"): Boolean
    var
        RepackOrder: Record "EN Repack Order";
    begin

        RepackOrder := Rec;
        InvSetup.Get;
        InvSetup.TestField("Repack Order Nos. ELA");
        if NoSeriesMgt.SelectSeries(InvSetup."Repack Order Nos. ELA", OldRepackOrder."No. Series", "No. Series") then begin
            NoSeriesMgt.SetSeries(RepackOrder."No.");
            Rec := RepackOrder;
            exit(true);
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


    procedure ShowDocDim()
    begin

        if Status = Status::Open then
            DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', TableCaption, "No."))
        else begin
            TestField("No.");
            "Dimension Set ID" :=
              DimMgt.EditDimensionSet2(
                "Dimension Set ID", StrSubstNo('%1 %2', TableCaption, "No."),
                "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        end;
    end;


    procedure GetItem()
    begin
        if "Item No." <> Item."No." then
            if "Item No." <> '' then
                Item.Get("Item No.")
            else
                Clear(Item);
    end;


    procedure LotNoAssistEdit()
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        /*IF "Lot No." <> '' THEN 
          EXIT;                
        GetItem;
        Item.TESTFIELD("Item Tracking Code");
        
        Item.TESTFIELD("Lot Nos.");
        VALIDATE("Lot No.",NoSeriesMgt.GetNextNo(Item."Lot Nos.",WORKDATE,TRUE));
        
        *///TBR

    end;


    procedure CalculateLines()
    var
        RepackLine: Record "EN Repack Order Line";
        BOMComponent: Record "BOM Component";
    begin
        TestField(Status, Status::Open);

        TestField("Item No.");
        TestField(Quantity);

        RepackLine.SetRange("Order No.", "No.");
        if not RepackLine.IsEmpty then begin
            if not Confirm(Text003, false, TableCaption, "No.") then
                exit;
            DeleteLines;
        end;

        Clear(RepackLine);
        RepackLine."Order No." := "No.";

        BOMComponent.SetRange("Parent Item No.", "Item No.");
        BOMComponent.SetFilter(Type, '<>0');
        if BOMComponent.FindSet then
            repeat
                RepackLine.Init;
                RepackLine."Line No." += 10000;
                RepackLine.Validate(Type, BOMComponent.Type - 1);
                RepackLine.Validate("No.", BOMComponent."No.");
                RepackLine.Validate("Variant Code", BOMComponent."Variant Code");
                RepackLine.Validate("Unit of Measure Code", BOMComponent."Unit of Measure Code");
                RepackLine.Validate(Quantity, Round("Quantity (Base)" * BOMComponent."Quantity per", 0.00001));
                RepackLine.Insert(true);
            until BOMComponent.Next = 0;
    end;


    procedure Navigate()
    var
        NavigateForm: Page Navigate;
    begin
        NavigateForm.SetDoc(0D, "No.");
        NavigateForm.Run;
    end;


    procedure PrintLabels()
    var
        LabData: RecordRef;
        NoOfLabels: Integer;
        res: Integer;
    begin
        /*
        GetItem;
        
        
        NoOfLabels := LabelMgmt.GetNoOfLables(Rec,ROUND("Quantity to Produce",1,'>')); 
        
        IF NoOfLabels <= 0 THEN
          EXIT;
        
        ItemLabel.VALIDATE("Item No.","Item No.");
        ItemLabel.VALIDATE("Unit of Measure Code","Unit of Measure Code"); 
        ItemLabel.VALIDATE("Variant Code","Variant Code");                 
        ItemLabel.VALIDATE("Lot No.","Lot No.");                          
        ItemLabel."No. Of Copies" := NoOfLabels;
        ItemLabel.CreateUCC('');
        LabData.GETTABLE(ItemLabel);
        LabelMgmt.SetUser(USERID); 
        LabelMgmt.PrintLabel('',Item.GetLabelCode(1),"Repack Location",LabData);
        *///TBR

    end;


    procedure FinishOrder()
    var
        RepackLine: Record "EN Repack Order Line";
    begin
        TestField(Status, Status::Open);

        RepackLine.SetRange("Order No.", "No.");
        RepackLine.SetRange(Type, RepackLine.Type::Item);
        RepackLine.SetFilter("Source Location", '<>%1', "Repack Location");
        RepackLine.SetFilter("Quantity Transferred", '>0');
        if not RepackLine.IsEmpty then
            if not Confirm(Text005, false) then
                exit;

        Validate("Quantity to Produce", 0);
        Status := Status::Finished;
        Modify;

        RepackLine.Reset;
        RepackLine.SetRange("Order No.", "No.");
        if RepackLine.FindSet(true, false) then
            repeat
                RepackLine.UpdateQtyToTransfer;
                RepackLine.UpdateQtyToConsume;
                RepackLine.Status := Status;
                RepackLine.Modify;
            until RepackLine.Next = 0;
    end;


    procedure AutoLot()
    begin

        /*
        
        IF P800Tracking.AutoAssignLotNo(Rec,xRec,"Lot No.") THEN
          VALIDATE("Lot No.");
        *///TBR

    end;
}

