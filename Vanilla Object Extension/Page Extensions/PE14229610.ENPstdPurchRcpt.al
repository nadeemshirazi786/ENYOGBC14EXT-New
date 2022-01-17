pageextension 14229610 "EN Posted Purchase Receipt" extends "Posted Purchase Receipt"
{
    layout
    {
        addlast(Shipping)
        {
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
            field("Shipping Agent Code"; "Shipping Agent Code")
            {

            }
            field("Shipping Instructions"; "Shipping Instructions ELA")
            {

            }
        }
    }
    actions
    {
        addafter(Approvals)
        {
            action("Extra Charge")
            {
                Caption = 'Extra Charge';
                ApplicationArea = All;
                RunObject = Page "EN Pstd.Doc Hdr. Extra Charges";
                RunPageLink = "Table ID" = CONST(120), "Document No." = FIELD("No.");
                Image = "Costs";
                Promoted = true;
                PromotedCategory = Process;
            }
        }
    }

}