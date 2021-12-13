page 14229413 "Commodity Ledger Entries ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - new page
    //    - renumbered
    // 
    // ENRE1.00
    //    - Caption on Action group updated
    //        - editable = no
    //        - add new field "Functional Area", "Source Type", "Source No.", "Source Line No."
    //        - removed field "Entry Type"

    Caption = 'Commodity Ledger Entries';
    DelayedInsert = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Commodity Ledger ELA";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Commodity No."; "Commodity No.")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Amount (LCY)"; "Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Recipient Agency No."; "Recipient Agency No.")
                {
                    ApplicationArea = All;
                }
                field("Rebate Ledger Entry No."; "Rebate Ledger Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Functional Area"; "Functional Area")
                {
                    ApplicationArea = All;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                }
                field("Source Line No."; "Source Line No.")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            part(Control23019012; "Rebate Ledger FactBox ELA")
            {
                ApplicationArea = All;
                SubPageLink = "Entry No." = FIELD("Rebate Ledger Entry No.");
            }
            systempart(Control23019013; Notes)
            {
                ApplicationArea = All;
            }
            systempart(Control23019014; Links)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Ent&ry")
            {
                Caption = 'Ent&ry';
                action("Rebate Ledger Entries")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Ledger Entries';
                    Image = LedgerEntries;
                    RunObject = Page "Rebate Ledger Entries ELA";
                    RunPageLink = "Entry No." = FIELD("Rebate Ledger Entry No.");
                }
                action("<Action23019018>")
                {
                    ApplicationArea = All;
                    Caption = 'Commodities';
                    Image = Item;
                    RunObject = Page "Commodities ELA";
                    RunPageLink = "No." = FIELD("Commodity No.");
                }
            }
        }
    }
}

