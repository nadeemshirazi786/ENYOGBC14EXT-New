pageextension 14229255 "Transfer Order Subform  ELA" extends "Transfer Order Subform"
{
    layout
    {
        addbefore("Item No.")
        {
            field("Line No."; "Line No.")
            {

                ApplicationArea = All;
            }

        }
    }
}