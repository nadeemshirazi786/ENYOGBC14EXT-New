table 14228833 "Floor Setup ELA"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[1])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Default Place Bin"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Auto-Release Whse Ship on Pick"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Auto-Sort Pick on Creation"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Create Pick Temporarily"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "DoNot Allow Qty. over Rep Qty."; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Label Default No. of Copies"; Integer)
        {
            DataClassification = ToBeClassified;
            InitValue = 1;
        }
        field(8; "Reclass Posting No. Series"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(9; "Whse. Shipment Pick Creation"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Phys. Inv. Posting No. Series"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(11; "Quality Hold Post. No. Series"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(12; "Auto-Open QA on Receipt"; Boolean)
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
    procedure jfCheckPath(VAR CheckString: Text[100])
    var
        DirLength: Integer;
        Text001: TextConst ENU = 'You should not enter a period in this field.';
    begin
        DirLength := STRLEN(CheckString);
        IF (DirLength <> 0) THEN
            IF (COPYSTR(CheckString, DirLength, 1) <> '\') THEN
                CheckString := CheckString + '\';

        IF STRPOS(CheckString, '.') <> 0 THEN
            ERROR(Text001);
    end;

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}