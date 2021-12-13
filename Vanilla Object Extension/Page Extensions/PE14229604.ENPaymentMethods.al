pageextension 14229604 "EN Payment Methods " extends "Payment Methods"
{
    layout
    {
        addlast(Control1)
        {
            field("Cash Tender Method"; "Cash Tender Method ELA")
            {

            }
        }
        addafter("Use for Invoicing")
        {
            field("Automatic Refund"; Rec."Automatic Refund ELA")
            {
                ApplicationArea = All;
            }
        }
    }


}