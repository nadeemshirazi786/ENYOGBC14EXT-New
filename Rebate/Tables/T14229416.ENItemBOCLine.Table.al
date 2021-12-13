table 14229416 "Item BOC Line ELA"
{
    /// ENRE1.00 2021-09-08 AJ


    DrillDownPageID = "Bill of Commod. Line List ELA"; //Bill of Commodities Line List
    LookupPageID = "Bill of Commod. Line List ELA";

    fields
    {
        field(1; "Item BOC No."; Code[20])
        {
            Caption = 'Item BOC No.';
            NotBlank = true;
            TableRelation = "Item BOC Header ELA";
        }
        field(2; "Commodity No."; Code[20])
        {
            Caption = 'Commodity No.';
            NotBlank = true;
            TableRelation = "Commodity ELA";

            trigger OnValidate()
            begin
                CheckItemBOCStatus;
            end;
        }
        field(3; "Quantity per"; Decimal)
        {
            Caption = 'Quantity per';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                CheckItemBOCStatus; //ENRE1.00
            end;
        }
        field(4; "Unit Amount"; Decimal)
        {
            Caption = 'Unit Amount';
            DecimalPlaces = 2 : 5;

            trigger OnValidate()
            begin
                CheckItemBOCStatus;
            end;
        }
        field(12; "Replacement Commodity No."; Code[20])
        {
            Caption = 'Replacement Commodity No.';
            NotBlank = true;
            TableRelation = "Commodity ELA";

            trigger OnValidate()
            begin
                CheckItemBOCStatus;
            end;
        }
        field(13; "Replacement Quantity per"; Decimal)
        {
            Caption = 'Replacement Quantity per';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                CheckItemBOCStatus;
            end;
        }
        field(14; "Replacement Unit Amount"; Decimal)
        {
            Caption = 'Replacement Unit Amount';
            DecimalPlaces = 2 : 5;

            trigger OnValidate()
            begin
                CheckItemBOCStatus;
            end;
        }
    }

    keys
    {
        key(Key1; "Item BOC No.", "Commodity No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        lrecItemBOCline: Record "Item BOC Line ELA";
    begin
    end;

    trigger OnRename()
    var
        lrecItemBOCline: Record "Item BOC Line ELA";
    begin
    end;

    var
        grecItemBOCHeader: Record "Item BOC Header ELA";
        Text000: Label '%1 cannot equal %2.';


    procedure CheckItemBOCStatus()
    begin
        grecItemBOCHeader.Get("Item BOC No.");
        grecItemBOCHeader.CheckStatus;
    end;
}

