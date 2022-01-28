pageextension 14229253 "Bin Content List ELA" extends "Bin Contents List"
{
    layout
    {
        addafter("Bin Code")
        {
            field("Blocked ELA"; "Blocked ELA")
            {
                Caption = 'Blocked';
                ApplicationArea = All;
                Visible = true;
            }
            field("Blocked Reason ELA"; "Blocked Reason ELA")
            {
                Caption = 'Blocked Reason';
                ApplicationArea = All;
                Visible = true;
            }
            field(CalcQtyAvailToPickUOM; CalcQtyAvailToPickUOM)
            {
                ApplicationArea = All;
                Visible = true;
            }
            field(CalcRemainingLife; CalcRemainingLife)
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Neg. Adjmt. Qty."; "Neg. Adjmt. Qty.")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Pick Qty."; "Pick Qty.")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Pos. Adjmt. Qty."; "Pos. Adjmt. Qty.")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Put-away Qty."; "Put-away Qty.")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Item Description ELA"; "Item Description ELA")
            {
                Caption = 'Item Description';
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
}