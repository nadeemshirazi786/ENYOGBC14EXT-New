page 14229415 "Commodities ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - New page
    //    - renumbered
    // 
    // ENRE1.00
    //    - new page action for commodity ledger entries

    Caption = 'Commodities';
    PageType = List;
    SourceTable = "Commodity ELA";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("<Action23019005>")
            {
                Caption = 'List';
                action("<Action23019006>")
                {
                    ApplicationArea = All;
                    Caption = 'Ledger Entries';
                    Image = LedgerEntries;
                    RunObject = Page "Commodity Ledger Entries ELA";
                    RunPageLink = "Commodity No." = FIELD("No.");
                }
            }
        }
    }
}

