table 14229109 "EN Global Buffer"
{
    Caption = 'EN Global Buffer';
    DataClassification = ToBeClassified;
    
    fields
    {
        field(10; "Key 1"; Integer)
        {
            Caption = 'Key 1';
            DataClassification = ToBeClassified;
        }
        field(20; "Key 2"; Code[20])
        {
            Caption = 'Key 2';
            DataClassification = ToBeClassified;
        }
        field(30; "Code Value 1"; Code[20])
        {
            Caption = 'Code Value 1';
            DataClassification = ToBeClassified;
        }
        field(31; "Code Value 2"; Code[20])
        {
            Caption = 'Code Value 2';
            DataClassification = ToBeClassified;
        }
        field(40; "Text Value 1"; Text[250])
        {
            Caption = 'Text Value 1';
            DataClassification = ToBeClassified;
        }
        field(41; "Text Value 2"; Text[250])
        {
            Caption = 'Text Value 2';
            DataClassification = ToBeClassified;
        }
        field(50; "Boolean Value 1"; Boolean)
        {
            Caption = 'Boolean Value 1';
            DataClassification = ToBeClassified;
        }
        field(51; "Boolean Value 2"; Boolean)
        {
            Caption = 'Boolean Value 2';
            DataClassification = ToBeClassified;
        }
        field(52; "Boolean Value 3"; Boolean)
        {
            Caption = 'Boolean Value 3';
            DataClassification = ToBeClassified;
        }
        field(32; "Code Value 3"; Code[20])
        {
            Caption = 'Code Value 3';
            DataClassification = ToBeClassified;
        }
        field(42; "Text Value 3"; Text[250])
        {
            Caption = 'Text Value 3';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Key 1","Key 2")
        {
            Clustered = true;
        }
    }
    
}
