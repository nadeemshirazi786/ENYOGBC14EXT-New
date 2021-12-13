/// <summary>
/// Table EN Item Customer (ID 14228858).
/// </summary>
table 14228858 "EN Item Customer"
{
    Caption = 'EN Item Customer';
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = ToBeClassified;
            TableRelation = Item;
            NotBlank = true;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = ToBeClassified;
            TableRelation = Customer;
            NotBlank = true;
        }
        field(3; "Customer Item No."; Text[20])
        {
            Caption = 'Customer Item No.';
            DataClassification = ToBeClassified;
        }
        field(4; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = ToBeClassified;
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(5; "Sales Unit of Measure"; Code[10])
        {
            Caption = 'Sales Unit of Measure';
            DataClassification = ToBeClassified;
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(6; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            FieldClass = FlowField;
            CalcFormula = Lookup(Item.Description WHERE ("No."=FIELD("Item No.")));
            
            
        }
        field(7; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = Lookup(Customer.Name WHERE ("No."=FIELD("Customer No.")));
        }
        field(8; "Sales Price Unit of Measure"; Code[10])
        {
            Caption = 'Sales Price Unit of Measure';
            DataClassification = ToBeClassified;
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No."=FIELD("Item No."));
        }
    }
    keys
    {
        key(PK; "Customer No.","Item No.","Variant Code")
        {
            Clustered = true;
        }
    }
    
}
