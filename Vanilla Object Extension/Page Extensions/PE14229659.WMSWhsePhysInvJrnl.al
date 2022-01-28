pageextension 14229252 "WMS Whse. Phys. Inv. Jnl. ELA" extends "Whse. Phys. Invt. Journal"
{
    layout
    {
        addafter("Item No.")
        {

            field("Journal Batch Name"; "Journal Batch Name")
            {
                ApplicationArea = All;
            }
            field("Journal Template Name"; "Journal Template Name")
            {
                ApplicationArea = All;
            }
            field("Line No."; "Line No.")
            {
                ApplicationArea = All;
            }
            field("Location Code"; "Location Code")
            {
                ApplicationArea = All;
            }


        }
    }
}