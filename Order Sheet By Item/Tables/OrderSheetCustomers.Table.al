table 14228815 "Order Sheet Customers"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // //<JF00042DO>
    // 
    // JF08476AC
    //   20100506 - added fields
    //     23019000 Order Template Location
    //     23019001 Requested Shipment Date
    //     23019002 Direct Store Delivery
    // 
    // JF8797SHR
    //   20100614 - Added new field
    //              23019500 Payment Terms Code
    //              23019501 Due Date
    // 
    // JF11506SHR
    //   20110203 - set editable to no on flowfields
    // 
    // JF12778SHR
    //   20110520 - new function jfDeleteDetails

    LookupPageID = "Order Sheet Customers";

    fields
    {
        field(1; "Order Sheet Batch Name"; Code[10])
        {
            TableRelation = "Order Sheet Batch";
        }
        field(2; "Line No."; Integer)
        {
        }
        field(10; "Sell-to Customer No."; Code[20])
        {
            TableRelation = Customer;
        }
        field(11; "Ship-to Code"; Code[10])
        {
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Sell-to Customer No."));
        }
        field(12; "Customer Name"; Text[50])
        {
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Sell-to Customer No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Qty. in Order Sheet"; Decimal)
        {
            CalcFormula = Sum("Order Sheet Details".Quantity WHERE("Order Sheet Batch Name" = FIELD("Order Sheet Batch Name"), "Sell-to Customer No." = FIELD("Sell-to Customer No."), "Ship-to Code" = FIELD("Ship-to Code"), "Item No." = FIELD("Item No. Filter"), "Variant Code" = FIELD("Variant Filter"), "Unit of Measure Code" = FIELD("Unit of Measure Filter"), "Requested Ship Date" = FIELD("Date Filter"), "External Doc. No." = FIELD("External Document No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(41; "Qty. Not Ordered"; Decimal)
        {
            CalcFormula = Sum("Order Sheet Details".Quantity WHERE("Order Sheet Batch Name"=FIELD("Order Sheet Batch Name"), "Sell-to Customer No."=FIELD("Sell-to Customer No."), "Ship-to Code"=FIELD("Ship-to Code"), "Item No."=FIELD("Item No. Filter"), "Variant Code"=FIELD("Variant Filter"), "Unit of Measure Code"=FIELD("Unit of Measure Filter"), "Requested Ship Date"=FIELD("Date Filter"), "Sales Order No."=FILTER(''), "External Doc. No."=FIELD("External Document No. Filter")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(42;"Has Qty. Ordered";Boolean)
        {
            CalcFormula = Exist("Order Sheet Details" WHERE ("Sell-to Customer No."=FIELD("Sell-to Customer No."), "Ship-to Code"=FIELD("Ship-to Code"), "Requested Ship Date"=FIELD("Date Filter")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(50;"Date Filter";Date)
        {
            FieldClass = FlowFilter;
        }
        field(51;"Item No. Filter";Code[20])
        {
            FieldClass = FlowFilter;
            TableRelation = Item;
        }
        field(52;"Variant Filter";Code[10])
        {
            FieldClass = FlowFilter;
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No. Filter"));
        }
        field(53;"Unit of Measure Filter";Code[10])
        {
            FieldClass = FlowFilter;
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No."=FIELD("Item No. Filter"));
        }
        field(23019000;"Order Template Location";Code[10])
        {
            Caption = 'Order Template Location';
            Description = 'JF08476AC';
            Editable = false;
            TableRelation = Location;
        }
        field(23019001;"Requested Shipment Date";Date)
        {
            Caption = 'Requested Shipment Date';
            Description = 'JF08476AC';
            Editable = false;
        }
        field(23019002;"Direct Store Delivery";Boolean)
        {
            CalcFormula = Lookup(Customer."Direct Store Delivery" WHERE ("No."=FIELD("Sell-to Customer No.")));
            Caption = 'Direct Store Delivery';
            Description = 'JF08476AC';
            Editable = false;
            FieldClass = FlowField;
        }
        field(23019003;"Ship-to Name";Text[50])
        {
            CalcFormula = Lookup("Ship-to Address".Name WHERE ("Customer No."=FIELD("Sell-to Customer No."), Code=FIELD("Ship-to Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(23019004;"Shipping Agent Code";Code[10])
        {
            TableRelation = "Shipping Agent";
        }
        field(23019005;"Shipping Agent Name";Text[50])
        {
            CalcFormula = Lookup("Shipping Agent".Name WHERE (Code=FIELD("Shipping Agent Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(23019006;"External Document No. Filter";Code[35])
        {
            FieldClass = FlowFilter;
        }
        field(23019007;"External Document No.";Code[35])
        {
        }
        field(23019008;"Shipment Date";Date)
        {

            trigger OnValidate()
            begin
                //<JF08476AC>
                IF "Shipment Date" <> xRec."Shipment Date" THEN BEGIN
                  "Requested Shipment Date" := "Shipment Date";
                  "Order Template Location" := '';
                END;
                //</JF08476AC>
            end;
        }
        field(23019500;"Payment Terms Code";Code[10])
        {
            Caption = 'Payment Terms Code';
            Description = 'JF8797SHR';
            TableRelation = "Payment Terms";
        }
        field(23019501;"Due Date";Date)
        {
            Caption = 'Due Date';
            Description = 'JF8797SHR';
        }
    }

    keys
    {
        key(Key1;"Order Sheet Batch Name","Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        //<JF12778SHR>
        jfDeleteDetails;
        //</JF12778SHR>
    end;

    [Scope('Internal')]
    procedure jfdoCreateOrders()
    var
        lrecOrderSheetDetails: Record "Order Sheet Details";
        lrecOrderSheetCustomers: Record "Order Sheet Customers";
        lrecOrderSheetItems: Record "Order Sheet Items";
    begin
        /*
        lrecORderSheetDetails.SETCURRENTKEY(
          "Order Sheet Batch Name",
          "Sell-to customer no.",
          "Ship-to Code",
          "Requested Ship Date",
          "Item No.",
          "Variant Code",
          "Unit of Measure Code");
        */
        
        
        lrecOrderSheetItems.SETRANGE("Order Sheet Batch Name", "Order Sheet Batch Name");

    end;

    [Scope('Internal')]
    procedure jfDeleteDetails()
    var
        lrecOrderSheetDetails: Record "Order Sheet Details";
    begin
        //<JF12778SHR>
        lrecOrderSheetDetails.SETRANGE("Order Sheet Batch Name","Order Sheet Batch Name");
        lrecOrderSheetDetails.SETRANGE("Sell-to Customer No.","Sell-to Customer No.");
        lrecOrderSheetDetails.SETRANGE("Ship-to Code","Ship-to Code");
        lrecOrderSheetDetails.DELETEALL;
        //</JF12778SHR>
    end;
}

