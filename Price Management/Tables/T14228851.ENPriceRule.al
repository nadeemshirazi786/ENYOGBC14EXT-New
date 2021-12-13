/// <summary>
/// Table EN Price Rule (ID 14228851).
/// </summary>
table 14228851 "EN Price Rule"
{
    Caption = 'EN Price Rule';
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
        field(10; "Price Evaluation Rank"; Enum "EN Price Evaluation Rank")
        {
            Caption = 'Price Evaluation Rank';
            DataClassification = ToBeClassified;
        }
        field(20; "Customer Rank"; Integer)
        {
            Caption = 'Customer Rank';
            DataClassification = ToBeClassified;
        }
        field(30; "Ship-to Modifier Rank"; Integer)
        {
            Caption = 'Ship-to Modifier Rank';
            DataClassification = ToBeClassified;
        }
        field(40; "Buying Group Rank"; Integer)
        {
            Caption = 'Buying Group Rank';
            DataClassification = ToBeClassified;
        }
        field(50; "Customer Price Group Rank"; Integer)
        {
            Caption = 'Customer Price Group Rank';
            DataClassification = ToBeClassified;
        }
        field(60; "List Price Group Rank"; Integer)
        {
            Caption = 'List Price Group Rank';
            DataClassification = ToBeClassified;
        }
        field(70; "All Customer Rank"; Integer)
        {
            Caption = 'All Customer Rank';
            DataClassification = ToBeClassified;
        }
        field(80; "Contract Price Modifier Rank"; Integer)
        {
            Caption = 'Contract Price Modifier Rank';
            DataClassification = ToBeClassified;

        }
        field(90; "Variant Modifier Rank"; Integer)
        {
            Caption = 'Variant Modifier Rank';
            DataClassification = ToBeClassified;
        }
        field(100; "Unit of Measure Modifier Rank"; Integer)
        {
            Caption = 'Unit of Measure Modifier Rank';
            DataClassification = ToBeClassified;
        }
        field(110; "Quantity Modifier Rank"; Integer)
        {
            Caption = 'Quantity Modifier Rank';
            DataClassification = ToBeClassified;
        }
        field(120; "End Date Modifier Rank"; Integer)
        {
            Caption = 'End Date Modifier Rank';
            DataClassification = ToBeClassified;
        }
        field(130; "Campaign Rank"; Integer)
        {
            Caption = 'Campaign Rank';
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
