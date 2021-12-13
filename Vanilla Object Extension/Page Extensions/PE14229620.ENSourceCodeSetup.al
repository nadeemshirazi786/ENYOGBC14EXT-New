pageextension 14229620 "EN Source Code Setup" extends "Source Code Setup"
{
    layout
    {
        addlast(Inventory)
        {
            field("Repack Order"; "Repack Order ELA")
            {
                ApplicationArea = All;

            }
        }
    }


}