pageextension 14229244 "WMS Item Journal ELA" extends "Whse. Item Journal"
{
    layout
    {
        addafter("Item No.")
        {
            field("Journal Template Name"; "Journal Template Name")
            {
                ApplicationArea = All;
            }
            field("Journal Batch Name"; "Journal Batch Name")
            {
                ApplicationArea = All;
            }
            field("Location Code"; "Location Code")
            {
                ApplicationArea = All;
            }
            field("Line No."; "Line No.")
            {
                ApplicationArea = All;
            }
        }
    }
}