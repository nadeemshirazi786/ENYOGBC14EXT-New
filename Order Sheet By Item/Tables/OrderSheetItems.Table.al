table 14228817 "Order Sheet Items"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // //<JF00042DO>
    // 
    // JF4953DD - Order Sheet Items Additions
    //   20090820 - Added Fields:
    //              * 60        "On Special"                    Boolean
    //              * 65        "Item Description"              Text 30
    // 
    // JF5918SHR
    //   20091102 - Added new field
    //              * 66        "Item Description 2"              Text 30
    // 
    // JF6603MG
    //   20091209 - Add new field
    //              * 67 Backordered Item
    // 
    // JF11506SHR
    //   20110203 - Added new field:
    //              46 'Qty. Not Ordered'
    // 
    // JF12779SHR
    //   20110520 - new function jfDeleteDetails

    LookupPageID = "Order Sheet Items";

    fields
    {
        field(1; "Order Sheet Batch Name"; Code[10])
        {
            TableRelation = "Order Sheet Batch";
        }
        field(10; "Item No."; Code[20])
        {
            TableRelation = Item;

            trigger OnValidate()
            begin
                //<JF4953DD>
                CALCFIELDS("Item Description", "Item Description 2");
                //</JF4953DD>
            end;
        }
        field(11; "Variant Code"; Code[10])
        {
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(12;"Unit of Measure Code";Code[10])
        {
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(40;"Qty. Ordered";Decimal)
        {
            CalcFormula = Sum("Order Sheet Details".Quantity WHERE ("Order Sheet Batch Name"=FIELD("Order Sheet Batch Name"), "Sell-to Customer No."=FIELD("Customer No. Filter"), "Ship-to Code"=FIELD("Ship-to Code Filter"), "Requested Ship Date"=FIELD("Date Filter"), "Item No."=FIELD("Item No."), "Variant Code"=FIELD("Variant Code"), "Unit of Measure Code"=FIELD("Unit of Measure Code"), "External Doc. No."=FIELD("External Document No. Filter")));
            FieldClass = FlowField;
        }
        field(41;"Qty. on Hand (Base)";Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE ("Item No."=FIELD("Item No."), "Variant Code"=FIELD("Variant Code"), "Location Code"=FIELD("Location Filter")));
            Caption = 'Qty. on Hand (Base)';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(42;"Qty. on Sales Order (Base)";Decimal)
        {
            CalcFormula = Sum("Sales Line"."Outstanding Qty. (Base)" WHERE ("Document Type"=CONST(Order), Type=CONST(Item), "No."=FIELD("Item No."), "Variant Code"=FIELD("Variant Code"), "Location Code"=FIELD("Location Filter"), "Shipment Date"=FIELD("Date Filter")));
            Caption = 'Qty. on Sales Order (Base)';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(43;"Scheduled Receipt (Qty.)";Decimal)
        {
            CalcFormula = Sum("Prod. Order Line"."Remaining Qty. (Base)" WHERE (Status=FILTER(Planned..Released), "Item No."=FIELD("Item No."), "Variant Code"=FIELD("Variant Code"), "Location Code"=FIELD("Location Filter"), "Due Date"=FIELD("Date Filter")));
            Caption = 'Scheduled Receipt (Qty.)';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(44;"Total Qty. Ordered";Decimal)
        {
            CalcFormula = Sum("Order Sheet Details".Quantity WHERE ("Order Sheet Batch Name"=FIELD("Order Sheet Batch Name"), "Requested Ship Date"=FIELD("Date Filter"), "Item No."=FIELD("Item No."), "Variant Code"=FIELD("Variant Code"), "Unit of Measure Code"=FIELD("Unit of Measure Code")));
            Caption = 'Total Qty. Ordered';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(45;"Base UOM";Code[10])
        {
            CalcFormula = Lookup(Item."Base Unit of Measure" WHERE ("No."=FIELD("Item No.")));
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(46;"Qty. Not Ordered";Decimal)
        {
            CalcFormula = Sum("Order Sheet Details".Quantity WHERE ("Order Sheet Batch Name"=FIELD("Order Sheet Batch Name"), "Requested Ship Date"=FIELD("Date Filter"), "Item No."=FIELD("Item No."), "Variant Code"=FIELD("Variant Code"), "Unit of Measure Code"=FIELD("Unit of Measure Code"), "Sales Order No."=FILTER('')));
            Caption = 'Qty. Not Ordered';
            DecimalPlaces = 0:5;
            Description = 'JF11506SHR';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50;"Date Filter";Date)
        {
            FieldClass = FlowFilter;
        }
        field(51;"Customer No. Filter";Code[20])
        {
            FieldClass = FlowFilter;
            TableRelation = Customer;
        }
        field(52;"Ship-to Code Filter";Code[10])
        {
            FieldClass = FlowFilter;
            TableRelation = "Ship-to Address".Code WHERE ("Customer No."=FIELD("Customer No. Filter"));
        }
        field(53;"Location Filter";Code[10])
        {
            FieldClass = FlowFilter;
            TableRelation = Location;
        }
        field(60;"On Special";Boolean)
        {
            Caption = 'On Special';
            Description = 'JF4953DD';
        }
        field(65;"Item Description";Text[50])
        {
            CalcFormula = Lookup(Item.Description WHERE ("No."=FIELD("Item No.")));
            Caption = 'Item Description';
            Description = 'JF4953DD';
            Editable = false;
            FieldClass = FlowField;
        }
        field(66;"Item Description 2";Text[50])
        {
            CalcFormula = Lookup(Item."Description 2" WHERE ("No."=FIELD("Item No.")));
            Caption = 'Item Description 2';
            Description = 'JF5918SHR';
            Editable = false;
            FieldClass = FlowField;
        }
        field(67;"Backordered Item";Boolean)
        {
            Description = 'JF6603MG';
        }
        field(68;"External Document No. Filter";Code[35])
        {
            FieldClass = FlowFilter;
        }
        field(69;"External Document No.";Code[35])
        {
        }
    }

    keys
    {
        key(Key1;"Order Sheet Batch Name","Item No.","Variant Code","Unit of Measure Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        //<JF12779SHR>
        jfDeleteDetails;
        //</JF12779SHR>
    end;

    [Scope('Internal')]
    procedure jfDeleteDetails()
    var
        lrecOrderSheetDetails: Record "Order Sheet Details";
    begin
        //<JF12779SHR>
        lrecOrderSheetDetails.SETRANGE("Order Sheet Batch Name","Order Sheet Batch Name");
        lrecOrderSheetDetails.SETRANGE("Item No.","Item No.");
        lrecOrderSheetDetails.SETRANGE("Variant Code","Variant Code");
        lrecOrderSheetDetails.SETRANGE("Unit of Measure Code","Unit of Measure Code");
        lrecOrderSheetDetails.DELETEALL;
        //</JF12779SHR>
    end;
}

