pageextension 14229601 "EN Posted Sales Invoice" extends "Posted Sales Invoice" // Wrong name of this file
{
    layout
    {
        addlast(General)
        {
            field("Authorized Amount"; "Authorized Amount ELA")
            {

            }
            field("Cash Applied (Other)"; "Cash Applied (Other) ELA")
            {
            }
            field("Cash Applied (Current)"; "Cash Applied (Current) ELA")
            {
            }
            field("Cash Tendered"; "Cash Tendered ELA")
            {

            }
            field("Authorized User"; "Authorized User ELA")
            {

            }
        }
		addlast("Work Description")
        {
            field("App. User ID"; Rec."App. User ID ELA")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {

        addlast("&Invoice")
        {
            // Add changes to page actions here
            group(Rebates)
            {
                Caption = 'Rebates';
                Image = Discount;
                action("<Action1101769001>")
                {
                    ApplicationArea = All;
                    Caption = 'Rebates';
                    Image = Discount;
                    RunObject = Page "Rebate Ledger Entries ELA";
                    RunPageLink = "Functional Area" = CONST(Sales),
                                      "Source Type" = CONST("Posted Invoice"),
                                      "Source No." = FIELD("No.");
                }
                action("<Action23019026>")
                {
                    ApplicationArea = All;
                    Caption = 'Sales-Based Purchase Rebates';
                    Image = CalculateInvoiceDiscount;
                    RunObject = Page "Rebate Ledger Entries ELA";
                    RunPageLink = "Functional Area" = CONST(Purchase),
                                      "Source Type" = CONST("Posted Invoice"),
                                      "Source No." = FIELD("No."),
                                      "Rebate Type" = CONST("Sales-Based");
                }
                action("<Action23019008>")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Profit Modifiers';
                    Image = EditForecast;
                    RunObject = Page "Posted Sale Prof. Modifier ELA";
                    RunPageLink = "Document Type" = CONST(Invoice),
                                      "Document No." = FIELD("No.");
                }
            }
        }

    }


}