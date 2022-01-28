tableextension 14229604 "EN Warehouse Setup ELA" extends "Warehouse Setup"
{
    fields
    {
        field(14228880; "Cash Carry Pick Location ELA"; Code[10])
        {
            Caption = 'Cash Carry Pick Location';
            DataClassification = ToBeClassified;
        }
        field(14228881; "Cash Carry Reclass Templte ELA"; Code[10])
        {
            Caption = 'Cash Carry Reclass Template';
            DataClassification = ToBeClassified;
        }
        field(14228882; "Cash Carry Reclass Batch ELA"; Code[10])
        {
            Caption = 'Cash Carry Reclass Batch';
            DataClassification = ToBeClassified;
        }
		field(14229200; "WMS Item Jnl. Template ELA"; Code[20])
        {
            Caption = 'WMS Item Jnl. Template';
            DataClassification = ToBeClassified;
            TableRelation = "Warehouse Journal Template".Name WHERE(Type = CONST(Item));
        }
        field(14229201; "WMS Item Jnl. No. ELA"; Code[20])
        {
            Caption = 'WMS Item Jnl. No.';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(14229202; "Batch Post WMS Adjustment ELA"; Boolean)
        {
            Caption = 'Batch Post WMS Adjustment';
            DataClassification = ToBeClassified;
        }

        field(14229203; "Item Jnl Temp. for WMS Adj ELA"; Code[20])
        {
            Caption = 'Item Jnl Temp. for WMS Adjust';
            TableRelation = "Item Journal Template".Name;
            DataClassification = ToBeClassified;
        }
        field(14229204; "WMS Phys. Jnl. Template ELA"; Code[20])
        {
            Caption = ' WMS Phys. Jnl. Template';
            TableRelation = "Warehouse Journal Template".Name WHERE(Type = CONST("Physical Inventory"));
            DataClassification = ToBeClassified;
        }
        field(14229205; "WMS Phys. Jnl. Nos. ELA"; Code[20])
        {
            Caption = 'WMS Phys. Jnl. Nos.';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(14229206; "Phys. Jnl Template ELA"; Code[20])
        {
            Caption = 'Phys. Jnl Template';
            DataClassification = ToBeClassified;
            TableRelation = "Item Journal Template".Name WHERE(Type = CONST("Phys. Inventory"));
        }
        field(14229207; "Item Reclass Jnl Template ELA"; Code[20])
        {
            Caption = 'Item Reclass Jnl Template';
            DataClassification = ToBeClassified;
            TableRelation = "Item Journal Template".Name WHERE(Type = CONST(Transfer));
        }
        field(14229208; "Move Adjusted Stock Back ELA"; Boolean)
        {
            Caption = 'Move Adjusted BOL Stock Back';
            DataClassification = ToBeClassified;

        }
    }
}