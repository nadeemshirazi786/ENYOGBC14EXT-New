table 51004 "Banana Allocation"
{
    fields
    {
        field(1; "Order No."; Code[20])
        {
            Editable = false;
            TableRelation = "Sales Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(2; "Order Line No."; Integer)
        {
            Editable = false;
        }
        field(4; "Customer No."; Code[20])
        {
            Editable = false;
            TableRelation = Customer;
        }
        field(5; "Shipment Date"; Date)
        {
            Editable = false;
        }
        field(6; "Total Quantity"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(7; "Breaking Quantity"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Breaking Quantity" > "Total Quantity" then
                    FieldError("Breaking Quantity", gText000);

                "Green Quantity" := "Total Quantity" - "Breaking Quantity";
            end;
        }
        field(8; "Green Quantity"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Green Quantity" > "Total Quantity" then
                    FieldError("Green Quantity", gText000);

                "Breaking Quantity" := "Total Quantity" - "Green Quantity";
            end;

        }

    }

    keys
    {
        key(Key1; "Order No.")
        {
            Clustered = true;
        }
        key(Key2; "Shipment Date")
        {
            SumIndexFields = "Breaking Quantity";
        }
        key(Key3; "Customer No.")
        {
            SumIndexFields = "Breaking Quantity";
        }
    }

    var
        gText000: Label 'may not exceed Total Quantity';

    [Scope('Internal')]
    procedure CustomerName(): Text[30]
    var
        Cust: Record Customer;
    begin
        if Cust.Get("Customer No.") then
            exit(Cust.Name)
        else
            exit('');
    end;
}

