pageextension 51002 ItemChargePurchAssigExt extends "Item Charge Assignment (Purch)"
{
    layout
    {
        addlast(Control1)
        {
            field("Amount To Assign (LCY)"; "Amount To Assign (LCY)")
            {
                ApplicationArea = All;
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