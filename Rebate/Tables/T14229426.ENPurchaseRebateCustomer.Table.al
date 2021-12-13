table 14229426 "Purchase Rebate Customer ELA"
{
    // ENRE1.00 2021-09-08 AJ


    Caption = 'Purchase Rebate Customer';
    LookupPageID = "Purchase Rebate Customers ELA";

    fields
    {
        field(10; "Purchase Rebate Code"; Code[20])
        {
            Caption = 'Purchase Rebate Code';
            NotBlank = true;
            TableRelation = "Purchase Rebate Header ELA" WHERE("Rebate Type" = CONST("Sales-Based"));

            trigger OnValidate()
            var
                lrecPurchRebateHeader: Record "Purchase Rebate Header ELA";
            begin
                lrecPurchRebateHeader.Get("Purchase Rebate Code");

                lrecPurchRebateHeader.TestField("Rebate Type", lrecPurchRebateHeader."Rebate Type"::"Sales-Based");

                if (
                  ("Rebate Start Date" <> lrecPurchRebateHeader."Start Date")
                ) then begin
                    Validate("Rebate Start Date", lrecPurchRebateHeader."Start Date");
                end;

                if (
                  ("Rebate End Date" <> lrecPurchRebateHeader."End Date")
                ) then begin
                    Validate("Rebate End Date", lrecPurchRebateHeader."End Date");
                end;
            end;
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
        key(Key1; "Purchase Rebate Code", "Customer No.")
        {
            Clustered = true;
        }
        key(Key2; "Customer No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        lrecPurchRebateHeader: Record "Purchase Rebate Header ELA";
    begin
        lrecPurchRebateHeader.Get("Purchase Rebate Code");

        lrecPurchRebateHeader.TestField("Rebate Type", lrecPurchRebateHeader."Rebate Type"::"Sales-Based");
    end;

    trigger OnRename()
    var
        lrecPurchRebateHeader: Record "Purchase Rebate Header ELA";
    begin
        lrecPurchRebateHeader.Get("Purchase Rebate Code");

        lrecPurchRebateHeader.TestField("Rebate Type", lrecPurchRebateHeader."Rebate Type"::"Sales-Based");
    end;
}

