pageextension 14229258 "Posted Purchase Receipts ELA" extends "Posted Purchase Receipts"
{
    layout
    {
        addlast(Content)
        {
            field("Order No."; "Order No.")
            {

                ApplicationArea = All;
            }

        }
    }
}