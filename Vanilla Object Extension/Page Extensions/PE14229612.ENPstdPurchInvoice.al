pageextension 14229612 "EN Pstd. Purch. Invoice" extends "Posted Purchase Invoice"
{
    actions
    {
        addlast("&Invoice")
        {

            action("<Action23019002>")
            {
                ApplicationArea = All;
                Caption = 'Rebates';
                Image = Discount;
                RunObject = Page "Rebate Ledger Entries ELA";
                RunPageLink = "Functional Area" = CONST(Purchase),
                                  "Source Type" = CONST("Posted Invoice"),
                                  "Source No." = FIELD("No.");
            }

        }
        addafter(Approvals)
        {
            action("Extra Charge")
            {
                Caption = 'Extra Charge';
                ApplicationArea = All;
                RunObject = Page "EN Pstd.Doc Hdr. Extra Charges";
                RunPageLink = "Table ID" = CONST(122), "Document No." = FIELD("No.");
                Image = "Costs";
                Promoted = true;
                PromotedCategory = Process;
            }
        }
    }
}