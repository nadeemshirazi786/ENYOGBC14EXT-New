pageextension 14229645 "EN Purchase Invoice" extends "Purchase Invoice"
{
    layout
    {
        addlast("Shipping and Payment")
        {
            field("Shipping Instructions"; "Shipping Instructions ELA")
            {

            }
            field("No. Pallets"; "No. Pallets")
            {

            }
        }
    }

    actions
    {
    }

    var
        myInt: Integer;
}