pageextension 14229633 "EN Ship-to Address List" extends "Ship-to Address List"
{
    layout
    {
        // Add changes to page layout here
        addafter("Location Code")
        {
            field("Shipping Agent Code"; "Shipping Agent Code")
            {
            }
            field("Ship-To Price Group"; "Ship-To Price Group")
            {
            }
            field("Shipment Method Code"; "Shipment Method Code")
            {
            }
            field("Order Rule Group"; "Order Rule Group")
            {
            }
        }
    }
}
