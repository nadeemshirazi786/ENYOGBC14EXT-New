page 14229457 "Registered Vend GL Rbt Ldg ELA"
{

    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //   ENRE1.00 - New Page
    // 
    // ENRE1.00
    //   ENRE1.00 - new page action: 'Post Rebate Adjustment'


    Caption = 'Rebate Ledger Entries';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    RefreshOnActivate = true;
    SourceTable = Vendor;

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
                field("Vendor Posting Group"; "Vendor Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Rebate Group Code"; "Rebate Group Code ELA")
                {
                    ApplicationArea = All;
                }
                field("Vendor Buying Group Code"; "Vendor Buying Group Code ELA")
                {
                    ApplicationArea = All;
                }
            }
            part(Subform; "Reg. Vend GL Rbt Ldg Sform ELA")
            {
                ApplicationArea = All;
                SubPageLink = "Post-to Vendor No." = FIELD("No.");
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
                              "Post-to Vendor No." = FIELD("Post-to Vendor No."),
                              "Functional Area" = CONST(Purchase);
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("<Action64>")
            {
                Caption = 'Ven&dor';
                action("<Action70>")
                {
                    ApplicationArea = All;
                    Caption = 'Ledger E&ntries';
                    Image = VendorLedger;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Page "Vendor Ledger Entries";
                    RunPageLink = "Vendor No." = FIELD("No.");
                    RunPageView = SORTING("Vendor No.");
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
                    CurrPage.Subform.PAGE.NavigateFunc;
                end;
            }
            group("<Action23019002>")
            {
                Caption = 'F&unctions';
                action(ProcessAll)
                {
                    ApplicationArea = All;
                    Caption = 'Process All';
                    Image = WorkCenterLoad;

                    trigger OnAction()
                    begin
                        CurrPage.Subform.PAGE.MarkAll(true);
                    end;
                }
                action(UnSelectAll)
                {
                    ApplicationArea = All;
                    Caption = 'Unselect All';
                    Image = DisableAllBreakpoints;

                    trigger OnAction()
                    begin
                        CurrPage.Subform.PAGE.MarkAll(false);
                    end;
                }
                separator(Action23019033)
                {
                }
                action(ScheduleAll)
                {
                    ApplicationArea = All;
                    Caption = 'Schedule All';
                    Image = Calendar;

                    trigger OnAction()
                    begin
                        CurrPage.Subform.PAGE.ScheduleAll(true);
                    end;
                }
                action(UnScheduleAll)
                {
                    ApplicationArea = All;
                    Caption = 'UnSchedule All';
                    Image = Cancel;

                    trigger OnAction()
                    begin
                        CurrPage.Subform.PAGE.ScheduleAll(false);
                    end;
                }
                separator(Action23019010)
                {
                }
                action("Post Rebate Adjustment")
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
            }
            group("<Action23019006>")
            {
                Caption = 'Posting';
                action("Post Rebates To Vendor")
                {
                    ApplicationArea = All;
                    Caption = 'Post Rebates To Vendor';
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

