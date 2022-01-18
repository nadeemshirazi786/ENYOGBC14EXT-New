tableextension 14229656 "Purch Cr Memo Hdr" extends "Purch. Cr. Memo Hdr."
{
    fields
    {
        field(50000; "Shipping Instruction ELA"; Text[50])
        {
            Caption = 'Shipping Instrction';
        }
    }

    var
        myInt: Integer;
}