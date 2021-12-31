pageextension 14229641 "Whse. Receipt Subform" extends "Whse. Receipt Subform"
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