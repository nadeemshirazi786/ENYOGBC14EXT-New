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
        
    }

    var
        myInt: Integer;
}