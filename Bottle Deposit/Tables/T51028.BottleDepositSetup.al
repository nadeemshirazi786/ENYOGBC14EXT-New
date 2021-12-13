table 51028 "Bottle Deposit Setup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            TableRelation = Item;
            DataClassification = ToBeClassified;
        }
        field(2; "Item Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Bottle Deposit State"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Bottle Deposit Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Bottle Deposit Account"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("State ELA"."Bottle Deposit Account" where(State = field("Bottle Deposit State")));
        }
    }

    keys
    {
        key(Key1; "Item No.", "Bottle Deposit State")
        {
            Clustered = true;
        }
    }

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