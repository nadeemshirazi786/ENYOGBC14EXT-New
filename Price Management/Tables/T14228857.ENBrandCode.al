/// <summary>
/// Table EN Brand Code (ID 14228857).
/// </summary>
table 14228857 "EN Brand Code"
{
    Caption = 'EN Brand Code';
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(3; "Private Label"; Boolean)
        {
            Caption = 'Private Label';
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
