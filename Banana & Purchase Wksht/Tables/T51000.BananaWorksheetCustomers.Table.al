table 51000 "Banana Worksheet Customers"
{
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            TableRelation = Customer;
        }
        field(2; "Ship-to Code"; Code[10])
        {
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Customer No."));
        }
        field(3; "Customer Name"; Text[100])
        {
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Customer No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Ship-to Name"; Text[100])
        {
            CalcFormula = Lookup("Ship-to Address".Name WHERE("Customer No." = FIELD("Customer No."),
                                                               Code = FIELD("Ship-to Code")));
            FieldClass = FlowField;
        }
        field(10; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(11; "Item Filter"; Code[20])
        {
            Description = 'YOG9155MG';
            FieldClass = FlowFilter;
            TableRelation = Item;
        }
        field(12; "Preference Filter"; Code[10])
        {
            Description = 'YOG9155MG';
            FieldClass = FlowFilter;
            TableRelation = "Banana Preference";
        }
        field(13; "Variant Filter"; Code[20])
        {
            Description = 'JF09582';
            FieldClass = FlowFilter;
        }
        field(20; "Banana Quantity"; Decimal)
        {
            CalcFormula = Sum("Banana Worksheet".Quantity WHERE("Customer No." = FIELD("Customer No."),
                                                                 "Item No." = FIELD("Item Filter"),
                                                                 "Preference Code" = FIELD("Preference Filter"),
                                                                 Date = FIELD("Date Filter"),
                                                                 "Variant Code" = FIELD("Variant Filter"),
                                                                 "Ship-to Code" = FIELD("Ship-to Code Filter"),
                                                                 "Location Code" = FIELD("Location Code")));
            Description = 'YOG9155MG,JF09582,JF9155RH,JF10807SPK';
            FieldClass = FlowField;
        }
        field(21; "Ship-to Code Filter"; Code[10])
        {
            FieldClass = FlowFilter;
        }
        field(22; "Location Code"; Code[20])
        {
            Description = 'JF10807SPK';
            TableRelation = Location.Code;
        }
        field(23; "Requested Shipment Date"; Date)
        {
            Description = 'JF10807SPK';
        }
        field(24; "Order Template Location"; Code[20])
        {
            Description = 'JF10807SPK';
        }
        field(25; "Direct Store Delivery"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Max(Customer."Direct Store Delivery" WHERE("No." = FIELD("Customer No.")));
            Description = 'JF10807SPK';

        }
        field(26; "Allow Banana Allocation"; Boolean)

        {

            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(Key1; "Customer No.", "Ship-to Code", "Location Code")
        {
            Clustered = true;
        }
    }
}

