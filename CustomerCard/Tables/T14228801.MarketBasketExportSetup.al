table 14228801 "Market Basket Export Setup"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(10;"Primary Key"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Destination Folder Path"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "File Name"; Text[10])
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Vendor No."; Code[6])
        {
            DataClassification = ToBeClassified;
        }

    }
    
    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
    
    
    
}