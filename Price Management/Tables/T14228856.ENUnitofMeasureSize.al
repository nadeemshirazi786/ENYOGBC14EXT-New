/// <summary>
/// Table EN Unit of Measure Size (ID 14228856).
/// </summary>
table 14228856 "EN Unit of Measure Size"
{

    Caption = 'EN Unit of Measure Size';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[80])
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
