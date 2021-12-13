pageextension 14229400 "Vendor Card ELA" extends "Vendor Card"
{
    // ENRE1.00 2021-09-08 AJ
    layout
    {
        // Add changes to page layout here

        addlast("Foreign Trade")
        {


            field("Rebate Group Code"; "Rebate Group Code ELA")
            {
                ApplicationArea = All;
                ToolTip = 'Rebate group that applies to the vendor. Used to group vendors together for the purpose of setting up rebates.';

                trigger OnValidate()
                begin
                    //ENRE1.00
                end;
            }
        }
        addafter(Receiving)
        {
            group("Global Group ELA")
            {
                Caption = 'Global Group';
                field("Global Group 1 Code ELA"; "Global Group 1 Code ELA")
                {
                    Caption = 'Global Group 1 Code';
                }
                field("Global Group 2 Code ELA"; "Global Group 2 Code ELA")
                {
                    Caption = 'Global Group 2 Code';
                }
                field("Global Group 3 Code ELA"; "Global Group 3 Code ELA")
                {
                    Caption = 'Global Group 3 Code';
                }
                field("Global Group 4 Code ELA"; "Global Group 4 Code ELA")
                {
                    Caption = 'Global Group 4 Code';
                }
                field("Global Group 5 Code ELA"; "Global Group 5 Code ELA")
                {
                    Caption = 'Global Group 5 Code';
                }
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