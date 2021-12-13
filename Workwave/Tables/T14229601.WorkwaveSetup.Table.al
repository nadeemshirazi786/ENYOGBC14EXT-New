table 14229601 "Workwave Setup ELA"
{

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
        }
        field(2; "API Key"; Text[250])
        {
        }
        field(3; "Base URL"; Text[250])
        {
        }
        field(4; "Territory API"; Text[250])
        {
        }
        field(5; "Order API"; Text[250])
        {
        }
        field(6; "Driver API"; Text[250])
        {
        }
        field(7; "Route API"; Text[250])
        {
        }
        field(8; "Vehicle ApI"; Text[250])
        {
        }
        field(9; "Territory Id"; Text[250])
        {
        }
        field(10; "Service Time"; Integer)
        {
            
        }

    }
    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
    
var
workwave:Record "Workwave Manifest ELA";
workwavesetup:Record "Workwave Setup ELA";

}

