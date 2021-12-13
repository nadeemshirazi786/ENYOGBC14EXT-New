table 14229158 "EN Lot No. Custom Format ELA"
{
    Caption = 'Lot No. Custom Format';


    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }


    trigger OnDelete()
    begin
        Item.SetRange("Lot No. Assignment Method ELA", Item."Lot No. Assignment Method ELA"::Custom);
        Item.SetRange("Lot Nos.", Code);
        if not Item.IsEmpty then
            Error(Text001, TableCaption, Code, FieldCaption(Code));

        CustomFormatLine.SetRange("Custom Format Code", Code);
        CustomFormatLine.DeleteAll;
    end;

    var
        Item: Record Item;
        CustomFormatLine: Record "EN Lot No. Custm Frmt Line ELA";
        Text001: Label 'You cannot delete %1 %2 because there is at least one item with that %3.';
}

