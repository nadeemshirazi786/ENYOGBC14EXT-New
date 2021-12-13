tableextension 14229609 "EN Sales Invoice Line ELA" extends "Sales Invoice Line"
{
    fields
    {
        field(14229400; "Line Net Weight ELA"; Decimal)
        {
            Caption = 'Line Net Weight';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Description = 'ENRE1.00';
            Editable = false;
        }
        field(14228850; "Sales Price UOM ELA"; Code[20])
        {
            Caption = 'Sales Price Unit of Measure';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));

        }
        field(14228851; "Ref. Item No. ELA"; Code[20])
        {
            Caption = 'Ref. Item No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = Item;

        }

        field(14228853; "Sell Item at Cost ELA"; Boolean)
        {

            Caption = 'Sell Item at Cost';
        }

        field(14228854; "Lock Pricing ELA"; Boolean)
        {

            Caption = 'Lock Pricing';
        }
        field(14228855; "Price Calc. GUID ELA"; Guid)
        {
            Caption = 'Price Calc. GUID';

        }
        field(14228856; "Unit Price(SalesPrice UOM) ELA"; Decimal)
        {
            Caption = 'Unit Price (Sales Price UOM)';
        }
        field(14228857; "Unit Price (Base UOM) ELA"; Decimal)
        {
            Caption = 'Unit Price (Base UOM)';

        }
        field(14228858; "Sales Price Source ELA"; Text[30])
        {
            Editable = false;
            Caption = 'Sales Price Source';
        }
        field(14228859; "Unit Price Prot Level ELA"; Enum "EN Unit Price Protection Level")
        {
            Caption = 'Unit Price Protection Level';
        }
        field(14228860; "Sales App Price ELA"; Boolean)
        {
            Caption = 'Sales App Price';
        }
        field(14228861; "Price Change Reason Code ELA"; Text[30])
        {
            Caption = 'Price Change Reason Code';
        }
        field(14228862; "Shelf No. ELA"; Code[10])
        {
            Editable = false;
            Caption = 'Shelf No.';
        }
        field(14228863; "Size Code ELA"; Code[20])
        {
            TableRelation = "EN Unit of Measure Size".Code;
            Caption = 'Size Code';

        }
        field(14228864; "Requested Order Qty. ELA"; Decimal)
        {
            Caption = 'Requested Order Qty.';
        }
        field(14228865; "EDI Line No. ELA"; Integer)
        {
            Caption = 'EDI Line No.';
        }
        field(14228866; "Pallet Code ELA"; code[10])
        {
            Caption = 'Pallet Code';
            //TableRelation = "EN Container Type";
        }
        field(14228867; "Include IC in Unit Price ELA"; Boolean)
        {
            Caption = 'Include IC in Unit Price';
            trigger OnValidate()
            begin
                TESTFIELD(Type, Type::"Charge (Item)");
                TESTFIELD("Attached to Line No.");
            end;

        }
        field(14228868; "Item Charge Type ELA"; Enum "EN Item Charge Type")
        {
            Caption = 'Item Charge Type';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Editable = false;

        }
        field(14228869; "Original Order Qty. ELA"; Decimal)
        {
            Caption = 'Original Order Qty.';
            Editable = false;
            DecimalPlaces = 0 : 5;

        }
        field(14228880; "To be Authorized ELA"; Boolean)
        {
            Caption = 'To be Authorized';
            DataClassification = ToBeClassified;
        }
        field(14228881; "Authorized Unit Price ELA"; Decimal)
        {
            Caption = 'Authorized Unit Price';
            DataClassification = ToBeClassified;
        }
        field(14228882; "Authrzed Price below Cost ELA"; Code[20])
        {
            Caption = 'Authorized Price below Cost';
            DataClassification = ToBeClassified;
        }
        field(14228883; "Pricing Method ELA"; Enum "EN Pricing Method")
        {
            Caption = 'Pricing Method';
            DataClassification = ToBeClassified;

        }


    }
    procedure CalcDeliveredPrice(var pdecDeliveredPrice: Decimal)
    var
        RebateFunctions: Codeunit "Rebate Sales Functions ELA";
    begin

        pdecDeliveredPrice :=
          RebateFunctions.CalcDeliveredPrice(DATABASE::"Sales Invoice Line", 0, "Document No.", "Line No.", "Unit Price");

    end;
}

