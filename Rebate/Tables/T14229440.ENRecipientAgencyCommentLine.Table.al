table 14229440 "Reci. Agency Comment Line ELA"
{
    // ENRE1.00 2021-09-08 AJ
    fields
    {
        field(1; "Table Name"; Option)
        {
            Caption = 'Table Name';
            DataClassification = ToBeClassified;
            OptionCaption = 'Recipient Agency';
            OptionMembers = "Recipient Agency";
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = ToBeClassified;
            TableRelation = IF ("Table Name" = CONST("Recipient Agency")) "Recipient Agency ELA"."No.";
        }
        field(3; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = ToBeClassified;
            NotBlank = true;
            TableRelation = "Country/Region";
        }
        field(4; County; Text[30])
        {
            Caption = 'State';
            DataClassification = ToBeClassified;
            NotBlank = true;
            //This property is currently not supported
            //TestTableRelation = false;
            //The property 'ValidateTableRelation' can only be set if the property 'TableRelation' is set
            //ValidateTableRelation = false;

            trigger OnLookup()
            begin
                // - deleted code
            end;

            trigger OnValidate()
            begin
                // - deleted code
            end;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }
        field(6; Date; Date)
        {
            Caption = 'Date';
            DataClassification = ToBeClassified;
        }
        field(7; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(8; Comment; Text[80])
        {
            Caption = 'Comment';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Table Name")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }


    procedure SetUpNewLine()
    var
        lrecRACommentLine: Record "Reci. Agency Comment Line ELA";
    begin
        lrecRACommentLine.SetRange("Table Name", "Table Name");
        lrecRACommentLine.SetRange("No.", "No.");
        lrecRACommentLine.SetRange("Country/Region Code", "Country/Region Code");
        lrecRACommentLine.SetRange(County, County);
        lrecRACommentLine.SetRange(Date, WorkDate);
        if not lrecRACommentLine.Find('-') then
            Date := WorkDate;
    end;
}

