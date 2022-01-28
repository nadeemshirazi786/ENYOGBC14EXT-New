pageextension 14229260 "WMS Item Rec Class ELA" extends "Item Reclass. Journal"
{
    layout
    {
        addlast(Content)
        {
            field("Journal Template Name"; "Journal Template Name")
            {

                ApplicationArea = All;
            }
            field("Journal Batch Name"; "Journal Batch Name")
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