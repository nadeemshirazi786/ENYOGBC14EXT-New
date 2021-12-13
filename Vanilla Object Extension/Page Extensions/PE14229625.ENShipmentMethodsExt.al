pageextension 14228855 "EN Shipment Methods Ext" extends "Shipment Methods"
{
    layout
    {

        addafter(Description)
        {
            field("Delivery Item Charge Code"; "Delivery Item Charge Code ELA")
            {

            }
            field("Include DC in Unit Price"; "Include DC in Unit Price ELA")
            {

            }
        }
    }
}
