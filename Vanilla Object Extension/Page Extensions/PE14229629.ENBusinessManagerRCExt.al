pageextension 14229629 "Business Manager RC ELA" extends "Business Manager Role Center"
{
    layout
    {


    }

    actions
    {
        addafter(SetupAndExtensions)
        {
            group("Elation Sales Objects")
            {
                Caption = 'Elation Sales Objects';
                Image = Sales;

                action("Sales Order CC")
                {
                    ApplicationArea = All;
                    Image = SalesInvoice;
                    RunObject = Page "EN CC Sales Order List";
                }

                action("Banana Worksheet")
                {
                    ApplicationArea = All;
                    Image = Worksheet;
                    RunObject = Page "Banana Worksheet";  
                }


            }
            group("Elation Purchase Objects")
            {
                Caption = 'Elation Purchase Objects';
                Image = Purchasing;
                action("Purchase Worksheet")
                {
                    ApplicationArea = All;
                    Image = Worksheet;
                    RunObject = Page "Purchase Worksheet";  
                }


            }
        }
    }

    var
        myInt: Integer;
}