tableextension 14228867 "EN Shipment Method Ext" extends "Shipment Method"
{
    fields
    {
        field(14228850; "Delivery Item Charge Code ELA"; Code[20])
        {
            Caption = 'Delivery Item Charge Code';
            DataClassification = ToBeClassified;
            TableRelation = "Item Charge"."No.";
        }
        field(14228851; "Delivery Allowance IC Code ELA"; Code[20])
        {
            Caption = 'Delivery Allowance IC Code';
            DataClassification = ToBeClassified;
            TableRelation = "Item Charge"."No.";
        }
        field(14228852; "Include DC in Unit Price ELA"; Boolean)
        {
            Caption = 'Include DC in Unit Price';
            DataClassification = ToBeClassified;
        }
        field(14228853; "Include DA in Unit Price ELA"; Boolean)
        {
            Caption = 'Include DA in Unit Price';
            DataClassification = ToBeClassified;
        }
    }
}

