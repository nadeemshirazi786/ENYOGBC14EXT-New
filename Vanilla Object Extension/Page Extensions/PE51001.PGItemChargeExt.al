pageextension 51001 ItemChargePgExt extends "Item Charges"
{
    layout
    {
        addlast(Control1)
        {
            field("Inherit Dimensions From Assgnt"; "Inherit Dim From Assgnt ELA")
            {
                ApplicationArea = All;
            }

        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}