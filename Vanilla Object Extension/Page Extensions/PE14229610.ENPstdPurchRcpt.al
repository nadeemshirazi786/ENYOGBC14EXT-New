pageextension 14229610 "EN Posted Purchase Receipt" extends "Posted Purchase Receipt"
{

    actions
    {
        addafter(Approvals)
        {
            action("Extra Charge")
            {
                Caption = 'Extra Charge';
                ApplicationArea = All;
                RunObject = Page "EN Pstd.Doc Hdr. Extra Charges";
                RunPageLink = "Table ID" = CONST(120), "Document No." = FIELD("No.");
                Image = "Costs";
                Promoted = true;
                PromotedCategory = Process;
            }
        }
    }

}