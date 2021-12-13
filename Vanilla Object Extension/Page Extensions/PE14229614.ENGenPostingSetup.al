pageextension 14229614 "EN Gen. Posting Setup" extends "General Posting Setup"
{
    actions
    {
        addafter("&Copy")
        {
            action("E&xtra Charges")
            {
                ApplicationArea = All;
                RunObject = Page "EN Extra Charge Posting Setup";

                Image = "Costs";
                Promoted = true;
                PromotedCategory = Process;
                RunPageLink = "Gen. Bus. Posting Group" = FIELD("Gen. Bus. Posting Group"), "Gen. Prod. Posting Group" = FIELD("Gen. Prod. Posting Group");

            }
        }
    }
}