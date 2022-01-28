pageextension 14229257 "Purchase Order List  ELA" extends "Purchase Order List"
{
    layout
    {
        addlast(Content)
        {
            field("PO Receiving Status ELA"; "PO Receiving Status ELA")
            {

                ApplicationArea = All;
            }
            field("Use for IC Receiving ELA"; "Use for IC Receiving ELA")
            {
                ApplicationArea = ALL;
            }
            field("Your Reference"; "Your Reference")
            {
                ApplicationArea = ALL;
            }

        }
    }
}