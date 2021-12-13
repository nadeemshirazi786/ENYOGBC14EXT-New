page 14229456 "Registered Cust GL Rbt Ldg ELA"
{

    // ENRE1.00
    //   ENRE1.00 - new form to make applications a bit easier since you can now scroll through customers
    //            - customer button was added behind the subform to allow for list lookup
    // 
    // ENRE1.00
    //   ENRE1.00
    //     new Function::MenuButton functions: Schedule All, Unschedule All
    //     - "marks" the records for the scheduled batch posting report 23019640 "Post Scheduled Rebate Entries"
    // 
    // ENRE1.00
    //   ENRE1.00 - remove all attachment functionality (replaced by Links in v5.0)
    // 
    // ENRE1.00
    //   ENRE1.00 - Add new function 'Create Rebate Adjustment'
    //            - Add FactBox RLFFactBox


    Caption = 'Rebate Ledger Entries';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    RefreshOnActivate = true;
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Contact; Contact)
                {
                    ApplicationArea = All;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Balance (LCY)"; "Balance (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Customer Posting Group"; "Customer Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Rebate Group Code"; "Rebate Group Code ELA")
                {
                    ApplicationArea = All;
                }
                field("Customer Buying Group Code"; "Customer Buying Group ELA")
                {
                    ApplicationArea = All;
                }
            }
            part(Subform; "Reg Cust GL Rbt Ldg Sform ELA")
            {
                ApplicationArea = All;
                SubPageLink = "Post-to Customer No." = FIELD("No.");
            }
        }
        area(factboxes)
        {
            part(RLFFactBox; "Rebate Ledger FactBox ELA")
            {
                ApplicationArea = All;
                Provider = Subform;
                SubPageLink = "Entry No." = FILTER(<> 0),
                              "Source Type" = FIELD("Source Type"),
                              "Source No." = FIELD("Source No."),
                              "Source Line No." = FIELD("Source Line No."),
                              "Post-to Customer No." = FIELD("Post-to Customer No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Customer")
            {
                Caption = '&Customer';
                action("Ledger E&ntries")
                {
                    ApplicationArea = All;
                    Caption = 'Ledger E&ntries';
                    Image = LedgerEntries;
                    RunObject = Page "Customer Ledger Entries";
                    RunPageLink = "Customer No." = FIELD("No.");
                    RunPageView = SORTING("Customer No.");
                    ShortCutKey = 'Ctrl+F7';
                }
            }
        }
        area(processing)
        {
            action("&Navigate")
            {
                ApplicationArea = All;
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CurrPage.Subform.PAGE.Navigatefunc;
                end;
            }
            group("<Action23019002>")
            {
                Caption = 'F&unctions';
                action("<Action23019004>")
                {
                    ApplicationArea = All;
                    Caption = 'Post Rebate Adjustment';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        CurrPage.Subform.PAGE.RebateAdjustment;
                    end;
                }
                separator(Action23019010)
                {
                }
                action("<Action23019012>")
                {
                    ApplicationArea = All;
                    Caption = 'Post Rebates to Customer';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        CurrPage.Subform.PAGE.AccrueRebates;
                    end;
                }
            }
        }
    }

    var
        Navigate: Page Navigate;
        CustomizedCalEntry: Record "Customized Calendar Entry";
        CustomizedCalendar: Record "Customized Calendar Change";
        CalendarMgmt: Codeunit "Calendar Management";
        PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
        gcodShipToCode: Code[20];
}

