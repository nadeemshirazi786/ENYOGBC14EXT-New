page 14229411 "Cancelled Purch Rbt List ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // 
    // ENRE1.00
    //    - New Page
    // 
    // ENRE1.00
    //   20111028
    //     - add Customers to the Rebate actions group


    Caption = 'Cancelled Purchase Rebates';
    CardPageID = "Cancelled Purch Rbt Card ELA";
    Editable = false;
    PageType = List;
    SourceTable = "Cancel Purch. Rbt Header ELA";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control1101769000)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = All;
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = All;
                }
                field("Calculation Basis"; "Calculation Basis")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Minimum Quantity (Base)"; "Minimum Quantity (Base)")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Cancelled Date"; "Cancelled Date")
                {
                    ApplicationArea = All;
                }
                field("Cancelled By User ID"; "Cancelled By User ID")
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
            group("<Action23019000>")
            {
                Caption = '&Rebate';
                action("<Action23019027>")
                {
                    ApplicationArea = All;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Can. Purch Rbt Comm. Sheet ELA";
                    RunPageLink = "Rebate Code" = FIELD(Code);
                }
                separator(Action23019011)
                {
                }
                action("<Action23019016>")
                {
                    ApplicationArea = All;
                    Caption = 'Customers';
                    Image = TeamSales;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Cancelled Purch Rbt Cust ELA";
                    RunPageLink = "Cancelled Purch. Rebate Code" = FIELD(Code);
                    RunPageView = SORTING("Cancelled Purch. Rebate Code", "Customer No.");
                }
                separator(Action23019009)
                {
                }
                group("<Action23019003>")
                {
                    Caption = 'Entries';
                    Image = Entries;
                    action("<Action23019005>")
                    {
                        ApplicationArea = All;
                        Caption = 'Registered';
                        Image = Registered;
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(false),
                                      "Paid to Customer" = CONST(false);
                    }
                    action("<Action23019006>")
                    {
                        ApplicationArea = All;
                        Caption = 'Posted';
                        Image = Post;
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(true),
                                      "Paid to Customer" = CONST(false);
                    }
                    action("<Action23019007>")
                    {
                        ApplicationArea = All;
                        Caption = 'Closed';
                        Image = Close;
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(true),
                                      "Paid to Customer" = CONST(true);
                    }
                    separator(Action23019003)
                    {
                    }
                    action("<Action23019009>")
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor Ledger Entries';
                        RunObject = Page "Vendor Ledger Entries";
                        RunPageLink = "Rebate Code ELA" = FIELD(Code);
                    }
                }
            }
        }
    }
}

