pageextension 14229646 "Posted Purch Cr Memo" extends "Posted Purchase Credit Memo"
{
    layout
    {
        addlast("Shipping and Payment")
        {
            field("Shipping Instruction"; "Shipping Instruction ELA")
            {

            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}