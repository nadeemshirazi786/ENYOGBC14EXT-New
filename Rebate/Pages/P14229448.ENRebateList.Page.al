page 14229448 "Rebate List ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - add comment functionality


    Caption = 'Rebates';
    CardPageID = "Rebate Card ELA";
    Editable = false;
    PageType = List;
    SourceTable = "Rebate Header ELA";
    UsageCategory = Lists;

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
            }
        }
        area(factboxes)
        {
            systempart(Control23019005; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Control23019004; Notes)
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
            group("<Action23019000>")
            {
                Caption = '&Rebate';
                action("<Action23019011>")
                {
                    ApplicationArea = All;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    begin
                        //<ENRE1.00>
                        ShowStatistics;
                        //</ENRE1.00>
                    end;
                }
                action("<Action23019027>")
                {
                    ApplicationArea = All;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Rebate Comment Sheet ELA";
                    RunPageLink = "Rebate Code" = FIELD(Code);
                }
                separator(Action23019015)
                {
                }
                group("<Action23019003>")
                {
                    Caption = 'Entries';
                    Image = Entries;
                    action("<Action23019004>")
                    {
                        ApplicationArea = All;
                        Caption = 'Open';
                        RunObject = Page "Rebate Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code);
                    }
                    action("<Action23019005>")
                    {
                        ApplicationArea = All;
                        Caption = 'Registered';
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(false),
                                      "Paid to Customer" = CONST(false);
                    }
                    action("<Action23019006>")
                    {
                        ApplicationArea = All;
                        Caption = 'Posted';
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(true),
                                      "Paid to Customer" = CONST(false);
                    }
                    action("<Action23019007>")
                    {
                        ApplicationArea = All;
                        Caption = 'Closed';
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(true),
                                      "Paid to Customer" = CONST(true);
                    }
                    separator(Action23019009)
                    {
                    }
                    action("<Action23019009>")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer Ledger Entries';
                        RunObject = Page "Customer Ledger Entries";
                        RunPageLink = "Rebate Code ELA" = FIELD(Code);
                    }
                }
            }
        }
        area(processing)
        {
            group("<Action1101769026>")
            {
                Caption = 'F&unctions';
                action("<Action23019014>")
                {
                    ApplicationArea = All;
                    Caption = 'Cancel Rebate';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        //<ENRE1.00>
                        CancelRebate;
                        CurrPage.Update;
                        //</ENRE1.00>
                    end;
                }
            }
        }
    }
}

