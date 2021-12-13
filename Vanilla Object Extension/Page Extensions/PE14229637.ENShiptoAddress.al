pageextension 14229637 "EN Ship-to Address" extends "Ship-to Address"
{
    layout
    {
        // Add changes to page layout here
        addafter("Last Date Modified")
        {



            field("Order Rule Group"; "Order Rule Group")
            {
            }
            field("Ship-To Price Group"; "Ship-To Price Group")
            {
            }
        }
		addafter("Service Zone Code")
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
}
