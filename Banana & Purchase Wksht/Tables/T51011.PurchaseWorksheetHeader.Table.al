table 51011 "Purchase Worksheet Header"
{
    fields
    {
        field(1; "Order Date"; Date)
        {
        }
        field(2; "Order No."; Integer)
        {
            AutoIncrement = true;
        }
        field(3; "Vendor No."; Code[20])
        {
            TableRelation = Vendor;
        }
        field(4; "Shipping Agent Code"; Code[10])
        {
            TableRelation = "Shipping Agent";
        }
        field(5; "Customer PO"; Code[20])
        {
        }
        field(6; "Freight Cost"; Decimal)
        {
            trigger OnValidate()
            var
                AdditionalFreight: Record "Additional Freight";
            begin
                AdditionalFreight.Init();
                AdditionalFreight.Validate("Order Date", "Order Date");
                AdditionalFreight.Validate("Order No.", "Order No.");
                AdditionalFreight.Validate("Shipping Agent Code", "Shipping Agent Code");
                AdditionalFreight.Validate("Freight Cost", "Freight Cost");
                AdditionalFreight.Insert(true);


            end;
        }
        field(7; "Expected Receipt Date"; Date)
        {
        }
        field(8; "Expected Pickup Date"; Date)
        {
            Description = 'JF9366RH';
        }
    }

    keys
    {
        key(Key1; "Order Date", "Order No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
    trigger OnInsert()
    var
        myInt: Integer;
    begin
    end;

    trigger OnDelete()
    begin
        PWLine.Reset;
        PWLine.SetRange("Order Date", "Order Date");
        PWLine.SetRange("Order No.", "Order No.");
        PWLine.DeleteAll;
    end;

    procedure ShowAdditionalFreight(PWHeader: Record "Purchase Worksheet Header")
    var
        AdditionalFreight: Record "Additional Freight";
        AddFreight: Page "Additional Freight";
    begin
        TestField("Order No.");
        AdditionalFreight.Reset();
        AdditionalFreight.SetRange("Order Date", PWHeader."Order Date");
        AdditionalFreight.SetRange("Order No.", PWHeader."Order No.");
        AdditionalFreight.SetRange("Shipping Agent Code", PWHeader."Shipping Agent Code");
        AddFreight.SetTableView(AdditionalFreight);
        AddFreight.RunModal();
    end;

    var
        PWLine: Record "Purchase Worksheet Line";
}

