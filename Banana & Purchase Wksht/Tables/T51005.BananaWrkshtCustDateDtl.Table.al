table 51005 "Banana Wrksht. Cust. Date Dtl."
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
        field(22; "Location Code"; Code[20])
        {
            TableRelation = Location.Code;
        }
        field(23; Date; Date)
        {
        }
        field(30; "PO Number"; Code[35])
        {
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Ship-to Code", "Location Code", Date)
        {
            Clustered = true;
        }
    }

}

