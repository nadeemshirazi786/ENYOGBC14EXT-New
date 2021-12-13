pageextension 14229635 "Sales Credit Memo ELA" extends "Sales Credit Memo"
{
    layout
    {
        addafter("Location Code")
        {
            field("Delivery Zone Code"; "Delivery Zone Code ELA")
            {
                ApplicationArea = All;
            }
            field("Shipping Instructions ELA"; "Shipping Instructions ELA")
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