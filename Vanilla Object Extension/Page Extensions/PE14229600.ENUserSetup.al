pageextension 14229600 "EN User Setup ELA" extends "User Setup"
{
    layout
    {
        addafter(Email)
        {
            field("Allow EC Button Use"; "Allow EC Button Use ELA")
            {
                ApplicationArea = All;
            }
        }
        addlast(Control1)
        {
            field("CC Journal Template"; "CC Journal Template ELA")
            {

            }

            field("CC Cash Journal Batch"; "CC Cash Journal Batch ELA")
            {

            }
            field("CC Credit Journal Batch"; "CC Credit Journal Batch ELA")
            {

            }

            field("Sales Location Filter"; "Sales Location Filter ELA")
            {

            }
            field("Use Signature"; "Use Signature ELA")
            {

            }
            field("Allow C&C Authorization"; "Allow C&C Authorization ELA")
            {

            }
            field("Approval Password"; "Approval Password ELA")
            {

            }



        }
    }

    actions
    {
        // Add changes to page actions here
    }


}