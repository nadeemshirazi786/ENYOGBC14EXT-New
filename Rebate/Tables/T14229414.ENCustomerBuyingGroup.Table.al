table 14229414 "Customer Buying Group ELA"
{

    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //   
    //     changed field names to reflect their usage:
    //       - Customer No. -> Rebate Accrual Customer No.
    //       - Customer Name -> Rebate Accrual Customer Name
    //     allow blank Rebate Accrual Customer No.
    //       (so that this table can be used as a pure supplemental table by sales pricing)

    DrillDownPageID = "Customer Buying Groups ELA"; //Customer Buying Groups
    LookupPageID = "Customer Buying Groups ELA";

    fields
    {
        field(1; "Code"; Code[20])
        {
        }
        field(2; Description; Text[50])
        {
        }
        field(3; "Rebate Accrual Customer No."; Code[20])
        {
            Caption = 'Rebate Accrual Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            begin
                CalcFields("Rebate Accrual Customer Name");
            end;
        }
        field(4; "Rebate Accrual Customer Name"; Text[100])
        {
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Rebate Accrual Customer No.")));
            Caption = 'Rebate Accrual Customer Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(12; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
        }
        field(13; Address; Text[50])
        {
            Caption = 'Address';
        }
        field(14; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(15; City; Text[30])
        {
            Caption = 'City';
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code".City
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code".City WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(16; County; Text[30])
        {
            Caption = 'State';
        }
        field(17; "Post Code"; Code[20])
        {
            Caption = 'ZIP Code';
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code"
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(18; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(20; Contact; Text[100])
        {
            Caption = 'Contact';
        }
        field(21; "Primary Contact No."; Code[20])
        {
            Caption = 'Primary Contact No.';
            TableRelation = Contact;

            trigger OnLookup()
            var
                Cont: Record Contact;
                ContBusRel: Record "Contact Business Relation";
            begin
            end;

            trigger OnValidate()
            var
                Cont: Record Contact;
                ContBusRel: Record "Contact Business Relation";
            begin
                Contact := '';
                if "Primary Contact No." <> '' then begin
                    Cont.Get("Primary Contact No.");

                    if Cont.Type = Cont.Type::Person then
                        Contact := Cont.Name
                end;
            end;
        }
        field(30; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        TestField(Code);
        //<ENRE1.00> - deleted code
    end;

    var
        PostCode: Record "Post Code";
}

