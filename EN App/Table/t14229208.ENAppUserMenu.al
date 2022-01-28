table 14229208 "App. User Menu ELA"
{
    DataClassification = ToBeClassified;
    DataPerCompany = false;
    fields
    {
        field(10; "App. User ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Application User ELA";
        }
        field(20; "Menu ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "App. Menu ELA";
        }
        field(30; "Custom Filter"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(40; Enabled; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50; "Require Special Equipment"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "App. User ID", "Menu ID")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}