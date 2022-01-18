pageextension 14229613 "Pstd. Purch. Inv. Subform" extends "Posted Purch. Invoice Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Extra Charge Code"; "Extra Charge Code ELA")
            {
                ApplicationArea = All;
            }
            field("Purch. Order for Extra Charge"; "Purch. Ord for Extra Chrg ELA")
            {
                ApplicationArea = All;
            }
        }
        addafter("Line Discount %")
        {
            field("List Cost"; "List Cost ELA")
            {

            }
            field("Upcharge Amount"; "Upcharge Amount ELA")
            {

            }
            field("Billback Amount"; "Billback Amount ELA")
            {

            }
            field("Freight Amount"; "Freight Amount ELA")
            {

            }
        }
    }
}