tableextension 14229652 "Item Croess Refernece Ext" extends "Item Cross Reference"
{
    fields
    {
        field(50000; Status; Option)
        {
            OptionMembers = ,Pending,Approved;
            Caption = 'Status';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                ItemVend: Record "Item Vendor";
            begin
                ItemVend.RESET;
                ItemVend.SETRANGE("Item No.", "Item No.");
                ItemVend.SETRANGE("Vendor No.", "Cross-Reference Type No.");
                ItemVend.SETRANGE("Variant Code", "Variant Code");
                IF ItemVend.FIND('-') THEN BEGIN
                    ItemVend.Status := Status;
                    ItemVend.MODIFY;
                END;
            end;
        }

    }
}
