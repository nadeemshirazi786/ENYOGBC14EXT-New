/// <summary>
/// Table EN Customer Buying Group (ID 14228852).
/// </summary>
table 14228852 "EN Customer Buying Group"
{
    Caption = 'EN Customer Buying Group';
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
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

}
