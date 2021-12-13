table 51017 "UD Calculation ELA"
{
    
    LookupPageID = "UD Calculations ELA";

    fields
    {
        field(10; "Code"; Code[20])
        {
            NotBlank = true;
        }
        field(20; Description; Text[50])
        {
        }
        field(30; "Table No."; Integer)
        {
            TableRelation = Object.ID WHERE (Type = CONST (Table));

            trigger OnValidate()
            begin
                CALCFIELDS("Table Name");
            end;
        }
        field(35; "Table Name"; Text[30])
        {
            CalcFormula = Lookup (Object.Name WHERE (Type = CONST (Table), ID = FIELD ("Table No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Include on Calculation View"; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; "Table No.", "Include on Calculation View")
        {
        }
    }

    fieldgroups
    {
    }
}

