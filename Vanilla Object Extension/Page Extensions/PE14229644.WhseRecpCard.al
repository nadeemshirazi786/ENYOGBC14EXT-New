pageextension 14229644 "Whse Recepit" extends "Warehouse Receipt"
{
    layout
    {
        addafter(WhseReceiptLines)
        {
            group(Shipping)
            {
                field("Shipping Agent Code ELA"; "Shipping Agent Code ELA")
                {
                    Caption = 'Shipping Agent Code';
                }
                field("Act. Delivery Appointment Date"; "Act. Delivery Appointment Date")
                {

                }
                field("Act. Delivery Appointment Time"; "Act. Delivery Appointment Time")
                {

                }
                field("Exp. Delivery Appointment Date"; "Exp. Delivery Appointment Date")
                {

                }
                field("Exp. Delivery Appointment Time"; "Exp. Delivery Appointment Time")
                {

                }
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