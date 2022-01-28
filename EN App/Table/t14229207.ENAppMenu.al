table 14229207 "App. Menu ELA"
{
    DataClassification = ToBeClassified;
    DataPerCompany = false;

    fields
    {
        field(10; "Menu Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; Name; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Menu Type"; Enum "Menu Type ELA")
        {
            DataClassification = ToBeClassified;
        }
        field(40; Enabled; Boolean)
        {
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(PK; "Menu Code")
        {
            Clustered = true;
        }
    }
}