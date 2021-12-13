table 14229401 "Cancelled Purch. Rbt Cust. ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - New table

    Caption = 'Cancelled Purchase Rebate Cust.';
    LookupPageID = "Cancelled Purch Rbt Cust ELA";

    fields
    {
        field(10; "Cancelled Purch. Rebate Code"; Code[20])
        {
            Caption = 'Cancelled Purchase Rebate Code';
            NotBlank = true;
            TableRelation = "Cancel Purch. Rbt Header ELA" WHERE("Rebate Type" = CONST("Sales-Based"));
        }
        field(20; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            NotBlank = true;
            TableRelation = Customer;
        }
        field(100; "Customer Name"; Text[100])
        {
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Customer No.")));
            Caption = 'Customer Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; "Rebate Start Date"; Date)
        {
            Caption = 'Rebate Start Date';
            Editable = false;
        }
        field(120; "Rebate End Date"; Date)
        {
            Caption = 'Rebate End Date';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Cancelled Purch. Rebate Code", "Customer No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

