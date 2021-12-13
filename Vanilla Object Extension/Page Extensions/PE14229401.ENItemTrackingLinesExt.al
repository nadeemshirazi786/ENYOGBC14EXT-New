pageextension 14229401 "Item Tracking Lines ELA" extends "Item Tracking Lines"
{
    // ENRE1.00 2021-09-08 AJ
    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {
            field("Quantity (Source UOM)"; "Quantity (Source UOM) ELA")
            {
                trigger OnValidate()
                begin
                    CurrPage.UPDATE;
                end;
            }

        }

    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;

    procedure ReturnTrackingSpecifications(var precTrackingSpecTMP: Record "Tracking Specification" temporary)
    begin

        precTrackingSpecTMP.DeleteAll;

        if Rec.FindSet then
            repeat
                precTrackingSpecTMP := Rec;
                precTrackingSpecTMP.Insert;
            until Rec.Next = 0;
    end;
}