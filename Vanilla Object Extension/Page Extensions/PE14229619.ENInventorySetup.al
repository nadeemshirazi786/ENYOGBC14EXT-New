pageextension 14229619 "EN Inventory Setup" extends "Inventory Setup"
{
    layout
    {
       
        addlast(Numbering)
        {
            field("Repack Order Nos."; "Repack Order Nos. ELA")
            {
                ApplicationArea = All;

            }
        }
        addlast(Location)
        {
            field("Default Repack Location"; "Default Repack Location ELA")
            {
                ApplicationArea = All;

            }
        }
        addlast(General)
        {
            field("Copy to Sales Documents"; "Copy to Sales Documents")
            {
                ApplicationArea = All;
            }
            field("Copy to Purchase Documents"; "Copy to Purchase Documents")
            {
                ApplicationArea = All;
            }
	    field("Item UOM Round Precision ELA"; "Item UOM Round Precision ELA")
            {
                ApplicationArea = All;

            }
        }
        addafter(Dimensions)
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


}