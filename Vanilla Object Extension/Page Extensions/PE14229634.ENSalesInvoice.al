pageextension 14229634 "Sales Invoice ELA" extends "Sales Invoice"
{
    layout
    {
        addafter("Ship-to UPS Zone")
        {
            field("Delivery Zone Code"; "Delivery Zone Code ELA")
            {
                ApplicationArea = All;
            }
            field("Shipping Instructions ELA"; "Shipping Instructions ELA")
            {
                ApplicationArea = All;
            }
        }
		addlast("Work Description")
        {
            field("App. User ID"; Rec."App. User ID ELA")
            {
                ApplicationArea = All;
            }

            field("Delivery Route No."; "Route No. ELA")
            {
                ApplicationArea = all;
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