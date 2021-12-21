pageextension 14229640 "Phys. Invnt. Ldgr. Entries ELA" extends "Phys. Inventory Ledger Entries"
{
    layout
    {
        addafter("Qty. (Calculated)")
        {
            field("Qty. (Phys. Count Detail)"; "Qty. (Phys. Count Detail)")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {

        addafter(SetDimensionFilter)
        {
            action("Phys. Inv. Ledger Details")
            {
                ApplicationArea = All;
                Caption = 'Phys. Inv. Ledger Details';
                RunObject = Page "Phys. Inv. Ledger Details ELA";
                RunPageLink = "Phys. Inv. Ledger Entry No." = FIELD("Entry No.");
            }
        }
    }

    var
        myInt: Integer;
}