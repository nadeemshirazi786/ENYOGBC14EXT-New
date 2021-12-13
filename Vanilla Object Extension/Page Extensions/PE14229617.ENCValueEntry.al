pageextension 14229617 "EN EC Value Entry" extends "Value Entries"
{
    layout
    {
        // Add changes to page layout here
        addlast("Control1")
        {
            field("Extra Charge"; "Extra Charge ELA")
            {
                ApplicationArea = All;
                Caption = 'Extra Charge';
            }
        }
    }
    actions
    {
        addlast("Ent&ry")
        {
            action("Extra Charges")
            {
                ApplicationArea = All;
                Image = Cost;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "EN Value Entry Extra Charges";
                RunPageLink = "Entry No." = field("Entry No.");

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}