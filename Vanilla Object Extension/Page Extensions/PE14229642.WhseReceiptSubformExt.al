pageextension 14229642 "Whse. Receipt Subform" extends "Whse. Receipt Subform"
{
    layout
    {
        addafter("Qty. Received")
        {
            field("Receiving UOM ELA"; "Receiving UOM ELA")
            {
                Caption = 'Receiving Unit of Measure';
            }
        }
    }
}