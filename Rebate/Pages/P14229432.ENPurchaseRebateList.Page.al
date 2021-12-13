page 14229432 "Purchase Rebate List ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - New Form
    // 
    // ENRE1.00
    //   
    //     - add Customers to the Rebate actions group
    // ENRE1.00  disallow users from opening Purchase Rebate Customers from non-Sales-Based rebates


    Caption = 'Purchase Rebates';
    CardPageID = "Purchase Rebate Card ELA";
    Editable = false;
    PageType = List;
    SourceTable = "Purchase Rebate Header ELA";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                        ShowStatistics;
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
                separator(Action23019022)
                {
                }
                action(Customers)
                {
                    ApplicationArea = All;
                    Caption = 'Customers';
                    Image = TeamSales;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        lrecPurchaseRebateCustomer: Record "Purchase Rebate Customer ELA";
                        lpagPurchaseRebateCustomers: Page "Purchase Rebate Customers ELA";
                        lctxtPurchaseRebateCustomers: Label '%1 can only apply to a %2 %3; the Page cannot open.';
                    begin
                        //<ENRE1.00>
                        if (
                          ("Rebate Type" <> "Rebate Type"::"Sales-Based")
                        ) then begin
                            // %1 can only apply to a %2 %3; the Page cannot open.
                            Message(StrSubstNo(lctxtPurchaseRebateCustomers, lpagPurchaseRebateCustomers.Caption,
                                                                             Format("Rebate Type"::"Sales-Based"),
                                                                             TableCaption));
                            exit;
                        end;
                        lrecPurchaseRebateCustomer.SetRange("Purchase Rebate Code", Code);
                        lpagPurchaseRebateCustomers.SetTableView(lrecPurchaseRebateCustomer);
                        lpagPurchaseRebateCustomers.Run;
                        //</ENRE1.00>
                    end;
                }
                separator(Action23019023)
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
                        Image = Open;
                        RunObject = Page "Rebate Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Functional Area" = CONST(Purchase);
                    }
                    action("<Action23019005>")
                    {
                        ApplicationArea = All;
                        Caption = 'Registered';
                        Image = Registered;
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(false),
                                      "Paid-by Vendor" = CONST(false),
                                      "Functional Area" = CONST(Purchase);
                    }
                    action("<Action23019006>")
                    {
                        ApplicationArea = All;
                        Caption = 'Posted';
                        Image = Post;
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(true),
                                      "Paid-by Vendor" = CONST(false),
                                      "Functional Area" = CONST(Purchase);
                    }
                    action("<Action23019007>")
                    {
                        ApplicationArea = All;
                        Caption = 'Closed';
                        Image = Close;
                        RunObject = Page "Rebate Ledger Entries ELA";
                        RunPageLink = "Rebate Code" = FIELD(Code),
                                      "Posted To G/L" = CONST(true),
                                      "Paid-by Vendor" = CONST(true),
                                      "Functional Area" = CONST(Purchase);
                    }
                    separator(Action23019016)
                    {
                    }
                    action("<Action23019009>")
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor Ledger Entries';
                        Image = VendorLedger;
                        RunObject = Page "Vendor Ledger Entries";
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
                        CancelRebate;
                        CurrPage.Update;
                    end;
                }
            }
        }
    }
}

