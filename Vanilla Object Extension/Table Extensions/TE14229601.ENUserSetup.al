tableextension 14229601 "EN User Setup ELA" extends "User Setup"
{
    fields
    {
        field(14228880; "CC Cash Journal Batch ELA"; Code[20])
        {
            Caption = 'CC Cash Journal Batch';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = FIELD("CC Journal Template ELA"));
        }
        field(14228881; "CC Credit Journal Batch ELA"; Code[20])
        {
            Caption = 'CC Credit Journal Batch';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = FIELD("CC Journal Template ELA"));
            DataClassification = ToBeClassified;
        }
        field(14228882; "CC Journal Template ELA"; Code[20])
        {
            Caption = 'CC Cash Journal Template';
            DataClassification = ToBeClassified;
        }
        field(14228883; "Sales Location Filter ELA"; Code[250])
        {
            Caption = 'Sales Location Filter';
            DataClassification = ToBeClassified;
        }
        field(14228884; "C&C Extended Fields ELA"; Boolean)
        {
            Caption = 'C&C Extended Fields';
            DataClassification = ToBeClassified;
        }
        field(14228885; "Use Signature ELA"; Boolean)
        {
            Caption = 'Use Signature';
            DataClassification = ToBeClassified;
        }
        field(14228886; "Allow C&C Authorization ELA"; Boolean)
        {
            Caption = 'Allow C&C Authorization';
            DataClassification = ToBeClassified;
        }
        field(14228887; "Approval Password ELA"; Text[100])
        {
            Caption = 'Approval Password';
            DataClassification = ToBeClassified;
        }
        field(14228900; "Display All Items ELA"; Boolean)
        {
            Caption = 'Display All Items';
            DataClassification = ToBeClassified;
        }
        field(14228901; "Display All Date ELA"; Date)
        {
            Caption = 'Display All Date';
            DataClassification = ToBeClassified;
        }
        field(14228902; "Sales Team ELA"; Code[20])
        {
            Caption = 'Sales Team';
            DataClassification = ToBeClassified;
        }
        field(14229100; "Allow EC Button Use ELA"; Boolean)
        {
            Caption = 'Allow EC Button Use';
            DataClassification = ToBeClassified;
        }

    }
    procedure GetUserSalesTeam(): Code[10]
    begin
        Get(UserId);
        exit("Sales Team ELA");

    end;

}