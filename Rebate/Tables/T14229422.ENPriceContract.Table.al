table 14229422 "Price Contract ELA"
{
    // ENRE1.00 2021-09-08 AJ
    DrillDownPageID = "Price Contracts ELA";
    LookupPageID = "Price Contracts ELA";

    fields
    {
        field(1; "Code"; Code[20])
        {
        }
        field(2; Description; Text[50])
        {
        }
        field(10; "Contract Type"; Code[10])
        {
        }
        field(15; "Created By"; Code[50])
        {
            TableRelation = User;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(16; "Created Date"; Date)
        {
        }
        field(20; "Approved By"; Code[50])
        {
            TableRelation = User;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                "Approved Date" := Today;
                Locked := true;
            end;
        }
        field(21; "Approved Date"; Date)
        {
        }
        field(30; "Sales Type"; Option)
        {
            OptionMembers = Customer,"Buying Group";
        }
        field(31; "Sales Entity"; Code[20])
        {
            TableRelation = IF ("Sales Type" = CONST(Customer)) Customer."No."
            ELSE
            IF ("Sales Type" = CONST("Buying Group")) "Customer Buying Group ELA".Code;
        }
        field(40; "Start Date"; Date)
        {
        }
        field(41; "End Date"; Date)
        {
        }
        field(50; Locked; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; "Sales Type", "Sales Entity", "Start Date", "End Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Created By" := UserId;
        "Created Date" := Today;
    end;

    trigger OnModify()
    begin
        if xRec.Locked = Locked then
            TestField(Locked, false);
    end;
}

