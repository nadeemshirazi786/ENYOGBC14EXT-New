/// <summary>
/// PageExtension EN WMS Posted Whse. Receipt (ID 14229242) extends Record Posted Whse. Receipt Subform.
/// </summary>
pageextension 14229242 "WMS Posted Whse Receipt SF ELA" extends "Posted Whse. Receipt Subform"
{
    layout
    {
        addafter("Unit of Measure Code")
        {
            field("Received By"; "Received By ELA")
            {
                ApplicationArea = All;
            }

            field("Received Date"; "Received Date ELA")
            {
                ApplicationArea = All;
            }

            field("Received Time"; "Received Time ELA")
            {
                ApplicationArea = All;
            }
        }
    }
}
