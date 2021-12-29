pageextension 14229641 "Whse Pick Subform ELA" extends "Whse. Pick Subform"
{
    layout
    {
        modify("Qty. to Handle")
        {
            trigger OnAfterValidate()
            begin
                CurrPage.Update();
            end;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}