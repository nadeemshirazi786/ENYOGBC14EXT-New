pageextension 14229636 "Whse Shpt ELA" extends "Warehouse Shipment"
{
    layout
    {
        addafter("Shipment Method Code")
        {
            field("Seal No."; "Seal No. ELA")
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