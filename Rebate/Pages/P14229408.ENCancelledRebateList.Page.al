page 14229408 "Cancelled Rebate List ELA"
{

    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - add comment functionality


    Caption = 'Cancelled Rebates';
    CardPageID = "Cancelled Rebate Card ELA";
    Editable = false;
    PageType = List;
    SourceTable = "Cancelled Rebate Header ELA";
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
                field("Rebate Category Code"; "Rebate Category Code")
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
                field("Job No."; "Job No.")
                {
                    ApplicationArea = All;
                }
                field("Job Task No."; "Job Task No.")
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
        area(factboxes)
        {
            systempart(Control23019007; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Control23019006; Notes)
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("<Action1102631000>")
            {
                Caption = '&Rebate';
                action("Co&mments")
                {
                    ApplicationArea = All;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Cancel. Rbt Comment Sheet ELA";
                    RunPageLink = "Rebate Code" = FIELD(Code);
                }
                separator(Action1102631002)
                {
                }
                group(Entries)
                {
                    Caption = 'Entries';
                    Image = Entries;
                    action("<Action1102631006>")
                    {
                        ApplicationArea = All;
                        Caption = 'Registered';
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(false),
                                      "Paid to Customer" = CONST(false);
                    }
                    action("<Action1102631007>")
                    {
                        ApplicationArea = All;
                        Caption = 'Posted';
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(true),
                                      "Paid to Customer" = CONST(false);
                    }
                    action(Closed)
                    {
                        ApplicationArea = All;
                        Caption = 'Closed';
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(true),
                                      "Paid to Customer" = CONST(true);
                    }
                    separator(Action1102631009)
                    {
                    }
                    action("Customer Ledger Entries")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer Ledger Entries';
                        RunObject = Page "Customer Ledger Entries";
                        RunPageLink = "Rebate Code ELA" = FIELD(Code);
                    }
                }
            }
        }
    }
}

