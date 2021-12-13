table 14229415 "Item BOC Header ELA"
{

    // ENRE1.00 2021-09-08 AJ


    Caption = 'Bill of Commodities';
    DrillDownPageID = "Bill of Commodities List ELA"; //Bill of Commodities List
    LookupPageID = "Bill of Commodities List ELA";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                CheckStatus;

                if "No." <> xRec."No." then begin
                    PurchSetup.Get;
                    NoSeriesMgt.TestManual(PurchSetup."Item BOC Nos. ELA");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;

            trigger OnValidate()
            begin
                CheckStatus;

                if xRec."Item No." <> "Item No." then begin
                    Clear("Unit of Measure Code");
                    Clear("Net Weight");
                end;
            end;
        }
        field(3; "Item Description"; Text[100])
        {
            CalcFormula = Lookup(Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                CheckStatus;

                if "Unit of Measure Code" = '' then begin
                    Clear("Net Weight");
                end else begin
                    Clear(gdecBaseNetWeight);
                    grecItem.Get("Item No.");
                    gdecBaseNetWeight := RebateFunctions.CalcUnroundedNetWeight(grecItem);
                    grecItemUOM.Get("Item No.", "Unit of Measure Code");
                    "Net Weight" := gdecBaseNetWeight * grecItemUOM."Qty. per Unit of Measure";
                end;
            end;
        }
        field(5; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                CheckStatus;

                if ("Starting Date" > "Ending Date") and ("Ending Date" <> 0D) then
                    Error(Text000, FieldCaption("Starting Date"), FieldCaption("Ending Date"));
            end;
        }
        field(6; "Ending Date"; Date)
        {
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                CheckStatus;

                if CurrFieldNo = 0 then
                    exit;

                Validate("Starting Date");
            end;
        }
        field(7; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'New,Under Development,Certified,Closed';
            OptionMembers = New,"Under Development",Certified,Closed;

            trigger OnValidate()
            begin
                ChangeStatus;
            end;
        }
        field(8; "Commodity Relationship"; Option)
        {
            Caption = 'Commodity Relationship';
            OptionCaption = 'Independent,Dependent';
            OptionMembers = Independent,Dependent;

            trigger OnValidate()
            begin
                CheckStatus;
            end;
        }
        field(9; "No. Servings"; Integer)
        {
            CalcFormula = Lookup("Item Unit of Measure"."No. of Servings ELA" WHERE("Item No." = FIELD("Item No."),
                                                                             Code = FIELD("Unit of Measure Code")));
            Caption = 'No. Servings';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; "Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                CheckStatus;
            end;
        }
        field(107; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        lrecItemBOCLine: Record "Item BOC Line ELA";
    begin
        lrecItemBOCLine.SetRange("Item BOC No.", "No.");
        lrecItemBOCLine.DeleteAll;
    end;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            PurchSetup.Get;
            PurchSetup.TestField("Item BOC Nos. ELA");
            NoSeriesMgt.InitSeries(PurchSetup."Item BOC Nos. ELA", xRec."No. Series", 0D, "No.", "No. Series");
        end;
    end;

    var
        Text000: Label '%1 cannot be after %2';
        grecItem: Record Item;
        grecItemUOM: Record "Item Unit of Measure";
        PurchSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text001: Label 'Item Bill of Commodities %1 has the same Unit of Measure Code and Starting Date.';
        Text002: Label 'The %1 cannot be copied to itself.';
        Text003: Label '%1 on %2 %3 must not be %4';
        RebateFunctions: Codeunit "Rebate Sales Functions ELA";
        gdecBaseNetWeight: Decimal;
        Text004: Label 'Item Bill of Commodities %1 must have at least one line with a Quantity per.';


    procedure AssistEdit(precOldItemBOCHeader: Record "Item BOC Header ELA"): Boolean
    var
        lrecItemBOCHeader: Record "Item BOC Header ELA";
    begin

        lrecItemBOCHeader := Rec;
        PurchSetup.Get;
        PurchSetup.TestField("Item BOC Nos. ELA");
        if NoSeriesMgt.SelectSeries(PurchSetup."Item BOC Nos. ELA", precOldItemBOCHeader."No. Series", "No. Series") then begin
            NoSeriesMgt.SetSeries("No.");
            Rec := lrecItemBOCHeader;
            exit(true);
        end;

    end;


    procedure ChangeStatus()
    var
        lrecItemBOC: Record "Item BOC Header ELA";
        lrecItemBOCLine: Record "Item BOC Line ELA";
    begin
        if Status = Status::Certified then begin
            TestField("Item No.");
            TestField("Unit of Measure Code");
            TestField("Starting Date");

            lrecItemBOC.SetCurrentKey("No.");
            lrecItemBOC.SetFilter("No.", '<>%1', "No.");
            lrecItemBOC.SetRange("Item No.", "Item No.");
            lrecItemBOC.SetRange("Unit of Measure Code", "Unit of Measure Code");
            lrecItemBOC.SetRange("Starting Date", "Starting Date");
            lrecItemBOC.SetRange(Status, lrecItemBOC.Status::Certified);
            if lrecItemBOC.FindFirst then begin
                Error(Text001, lrecItemBOC."No.");
            end;

            lrecItemBOCLine.SetRange("Item BOC No.", "No.");
            lrecItemBOCLine.SetFilter("Quantity per", '>%1', 0);
            if not lrecItemBOCLine.FindFirst then begin
                Error(Text004, "No.");
            end;

        end;
    end;


    procedure CopyBOC(pcodBOCHeaderNo: Code[20]; precCurrentBOCHeader: Record "Item BOC Header ELA")
    var
        lconText000: Label 'Lab Version %1 must be certified and released.';
        lrecBOCHeader: Record "Item BOC Header ELA";
        lrecFromBOCLine: Record "Item BOC Line ELA";
        lrecToBOCLine: Record "Item BOC Line ELA";
    begin

        if (precCurrentBOCHeader."No." = pcodBOCHeaderNo) then
            Error(Text002, precCurrentBOCHeader.TableCaption);

        if precCurrentBOCHeader.Status = precCurrentBOCHeader.Status::Certified then
            Error(
              Text003,
              precCurrentBOCHeader.FieldCaption(Status),
              precCurrentBOCHeader.TableCaption,
              precCurrentBOCHeader."No.",
              precCurrentBOCHeader.Status);

        lrecBOCHeader.Get(pcodBOCHeaderNo);

        precCurrentBOCHeader.Validate("Item No.", lrecBOCHeader."Item No.");
        precCurrentBOCHeader.Modify;



        lrecToBOCLine.SetRange("Item BOC No.", precCurrentBOCHeader."No.");
        lrecToBOCLine.DeleteAll;

        lrecFromBOCLine.SetRange("Item BOC No.", pcodBOCHeaderNo);
        if lrecFromBOCLine.Find('-') then begin
            repeat
                lrecToBOCLine := lrecFromBOCLine;
                lrecToBOCLine."Item BOC No." := precCurrentBOCHeader."No.";

                lrecToBOCLine.Insert;
            until lrecFromBOCLine.Next = 0;
        end;
    end;


    procedure CheckStatus()
    begin
        if Status = Status::Certified then begin
            Error(
              Text003,
              FieldCaption(Status), TableCaption, "No.", Status);
        end;
    end;
}

