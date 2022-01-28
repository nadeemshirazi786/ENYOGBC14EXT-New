pageextension 14229246 "Bin Content ELA" extends "Bin Contents"
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
        }
    }
}