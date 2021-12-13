/// <summary>
/// Table EN Item Sales Price Group (ID 14228854).
/// </summary>
table 14228854 "EN Item Sales Price Group"
{
    Caption = 'EN Item Sales Price Group';
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
    
}
