pageextension 14229623 "EN LT ItemTrackingCode EXT ELA" extends "Item Tracking Code Card"
{
    layout
    {
        addlast("Lot No.")
        {
            group("Automatic No. Assignment")

            {
                field("Lot Purch. Inbound Assignment"; "Lot Purch. Inbound Assgnmt ELA")
                {
                    Caption = 'Lot Purchase Tracking';

                }
                field("Lot Sales Inbound Assignment"; "Lot Sales Inbound Assgnmt ELA")
                {
                    Caption = 'Lot Sales Tracking';
                }
                field("Lot Manuf. Inbound Assignment"; "Lot Manuf. Inbound Assgnmt ELA")
                {
                    Caption = 'Lot Manufacturing Tracking';
                }
            }
        }
    }
}

