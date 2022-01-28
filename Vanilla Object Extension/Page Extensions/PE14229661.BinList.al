pageextension 14229254 "Bin List ELA" extends "Bin List"
{
    layout
    {
        addafter("Code")
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
        }
    }
}