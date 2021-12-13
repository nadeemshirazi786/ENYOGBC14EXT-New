pageextension 14229631 "Location ELA" extends "Location Card"
{
    layout
    {
        addlast(Warehouse)
        {
            field("Allow Multi-UOM Bin Content"; "Allow Multi-UOM Bin Contnt ELA")
            {
                ApplicationArea = All;
            }
        }
        addlast(General)
        {
            field("Item List Matrix"; "Item List Matrix ELA")
            {
                Caption = 'Item List Matrix';
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