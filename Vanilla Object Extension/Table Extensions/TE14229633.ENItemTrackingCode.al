tableextension 14229633 "EN LT ItemTrackingCode EXT ELA" extends "Item Tracking Code"
{


    fields
    {
        field(14229400; "Variable Weight Tracking ELA"; Boolean)
        {
            Caption = 'Variable Weight Tracking';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                if "Variable Weight Tracking ELA" = xRec."Variable Weight Tracking ELA" then
                    exit;

                TestChangeCatchWeight(FieldCaption("Variable Weight Tracking ELA"));



                if not "Variable Weight Tracking ELA" then
                    "Variable Weight Tol Pct. ELA" := 0;

            end;
        }
        field(14229401; "Variable Weight Tol Pct. ELA"; Decimal)
        {
            BlankZero = true;
            Caption = 'Variable Weight Tolerance %';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Description = 'ENRE1.00';
            MinValue = 0;
        }
        field(14229150; "Allow Loose Lot Control ELA"; Boolean)
        {
            Caption = 'Allow Loose Lot Control';

            DataClassification = ToBeClassified;

        }
        field(14229151; "Lot Sales Inbound Assgnmt ELA"; Boolean)
        {
            Caption = 'Lot Sales Inbound Assignment';
            DataClassification = ToBeClassified;

        }
        field(14229152; "Lot Purch. Inbound Assgnmt ELA"; Boolean)
        {
            Caption = 'Lot Purch. Inbound Assignment';
            DataClassification = ToBeClassified;

        }
        field(14229153; "Lot Manuf. Inbound Assgnmt ELA"; Boolean)
        {
            Caption = 'Lot Manuf. Inbound Assignment';
            DataClassification = ToBeClassified;

        }
    }
    var

        Text000: Label 'Entries exist for item %1. The field %2 cannot be changed.';
        Item: Record Item;
        Text001: Label '%1 is %2 for item %3. The field %4 cannot be changed.';
        Text002: Label 'You cannot delete %1 %2 because it is used on one or more items.';

    procedure TestChangeCatchWeight(CurrentFieldname: Text[100])
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin

        Item.Reset;
        Item.SetRange("Item Tracking Code", Code);
        if Item.FindSet then
            repeat
                ItemLedgEntry.Reset;
                ItemLedgEntry.SetCurrentKey("Item No.");
                ItemLedgEntry.SetRange("Item No.", Item."No.");
                if not ItemLedgEntry.IsEmpty then
                    Error(
                      Text000,
                      Item."No.", CurrentFieldname);
            until Item.Next = 0;

    end;


}