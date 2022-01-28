table 14229209 "Item Cross Link ELA"
{
    DataClassification = ToBeClassified;
    DataPerCompany = false;

    fields
    {
        field(14229200; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;

        }

        field(14229201; "Item Description"; Code[100])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(Item.Description WHERE("No." = FIELD("Item No.")));

        }
        field(14229202; "Linked Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = item."No.";

        }
        field(14229203; "Linked Item Description"; Code[100])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(Item.Description WHERE("No." = FIELD("Linked Item No.")));

        }
        field(14229204; "Use for Item Substitution"; Boolean)
        {
            DataClassification = ToBeClassified;

        }
        field(14229205; "Blocked for Item Substitution"; Boolean)
        {
            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(PK; "Item No.", "Linked Item No.")
        {
            Clustered = true;
        }
        key(SK; "Use for Item Substitution", "Linked Item No.")
        {
        }
    }

    procedure GetBaseXlinkItem(ItemNo: Code[20]): Code[20]
    var
    begin
        SETRANGE("Item No.", ItemNo);
        IF FINDFIRST THEN BEGIN
            IF "Linked Item No." <> '' THEN
                EXIT(ItemNo);
        END ELSE BEGIN
            RESET;
            SETRANGE("Linked Item No.", ItemNo);
            IF FINDFIRST THEN
                EXIT("Item No.");
        END;

        RESET;
    end;


}