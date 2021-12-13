tableextension 14228872 "EN Sales Shipment Header Ext" extends "Sales Shipment Header"
{
    fields
    {
        field(14228850; "Price List Group Code ELA"; Code[20])
        {
            Caption = 'Price List Group Code';
            TableRelation = "EN Price List Group";
            DataClassification = ToBeClassified;

        }
        field(14228851; "Pallet Code ELA"; Code[10])
        {
            //TableRelation = "EN Container Type";
            Caption = 'Pallet Code';

        }
        field(14228852; "Bypass Surcharge Calc ELA"; Boolean)
        {
            Caption = 'Bypass Surcharge Calculation';
        }
        field(14228853; "Lock Pricing ELA"; Boolean)
        {
            Caption = 'Lock Pricing';
        }
        field(14228854; "Order Rule Group ELA"; Code[20])
        {
            Caption = 'Order Rule Group';
            TableRelation = "EN Order Rule Group";
        }
        field(14228855; "Bypass Order Rules ELA"; Boolean)
        {
            Caption = 'Bypass Order Rules';
        }
    }
}
