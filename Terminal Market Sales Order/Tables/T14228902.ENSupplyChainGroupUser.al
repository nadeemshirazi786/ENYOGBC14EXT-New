table 14228902 "EN Supply Chain Group User"
{
    Caption = 'Supply Chain Group User';

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            NotBlank = true;
            TableRelation = User."User Security ID";

            trigger OnLookup()
            var
                LoginMgt: Codeunit "User Management";
            begin

            end;

            trigger OnValidate()
            var
                LoginMgt: Codeunit "User Management";
            begin

            end;
        }
        field(14228900; "Supply Chain Group Code"; Code[10])
        {
            Caption = 'Supply Chain Group Code';
            NotBlank = true;
            TableRelation = "EN Supply Chain Group".Code;
        }
    }

    keys
    {
        key(Key1; "User ID", "Supply Chain Group Code")
        {
            Clustered = true;
        }
        key(Key2; "Supply Chain Group Code")
        {
        }
    }

    fieldgroups
    {
    }
}

