page 14229446 "Rebate Ledger Entries ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00  - Modified Menu Item: Entry, Card
    // ENRE1.00  - new page action for commodity ledger entries
    //             - page renumber, fix page action
    // ENRE1.00  - Updated Entry page action caption
    // ENRE1.00  - add Claim Reference No. to page

    Caption = 'Rebate Ledger Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Rebate Ledger Entry ELA";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control1101769000)
            {
                ShowCaption = false;
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                    Visible = false;

                    trigger OnAssistEdit()
                    begin
                        ShowSourceDoc;
                    end;
                }
                field("Source Line No."; "Source Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Pay-to Vendor No."; "Pay-to Vendor No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Pay-to Name"; "Pay-to Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Buy-from Vendor No."; "Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Buy-from Vendor Name"; "Buy-from Vendor Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Order Address Code"; "Order Address Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Ship-to Vendor Name"; "Ship-to Vendor Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Sell-to Customer Name"; "Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Bill-to Customer No."; "Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Bill-to Customer Name"; "Bill-to Customer Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Post-to Customer No."; "Post-to Customer No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Post-to Customer Name"; "Post-to Customer Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Rebate Type"; "Rebate Type")
                {
                    ApplicationArea = All;
                }
                field("Rebate Code"; "Rebate Code")
                {
                    ApplicationArea = All;
                }
                field("Rebate Description"; "Rebate Description")
                {
                    ApplicationArea = All;
                    AssistEdit = false;
                    DrillDown = false;
                    Lookup = false;
                }
                field("Amount (LCY)"; "Amount (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Amount (RBT)"; "Amount (RBT)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Amount (DOC)"; "Amount (DOC)")
                {
                    ApplicationArea = All;
                }
                field("Date Created"; "Date Created")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Paid to Customer"; "Paid to Customer")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Rebate Document No."; "Rebate Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Rebate Batch Name"; "Rebate Batch Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Adjustment; Adjustment)
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                }
                field("Rebate Unit Rate (LCY)"; "Rebate Unit Rate (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Rebate Unit Rate (RBT)"; "Rebate Unit Rate (RBT)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Rebate Unit Rate (DOC)"; "Rebate Unit Rate (DOC)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Job No."; "Job No.")
                {
                    ApplicationArea = All;
                }
                field("Job Task No."; "Job Task No.")
                {
                    ApplicationArea = All;
                }
                field("Claim Reference No."; "Claim Reference No.")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("<Action1101769001>")
            {
                Caption = 'Entry';
                action("<Action1101769002>")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Card';
                    Image = Document;
                    RunObject = Page "Rebate Card ELA";
                    RunPageLink = Code = FIELD("Rebate Code");
                    RunPageView = SORTING(Code);
                    ShortCutKey = 'Shift+F7';
                }
                separator(Action1102631004)
                {
                }
                action("<Action1102631005>")
                {
                    ApplicationArea = All;
                    Caption = 'Show Source Document';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        ShowSourceDoc;
                    end;
                }
                action("Commodity Ledger")
                {
                    ApplicationArea = All;
                    Caption = 'Commodity Ledger Entries';
                    Image = LedgerEntries;
                    RunObject = Page "Commodity Ledger Entries ELA";
                    RunPageLink = "Rebate Ledger Entry No." = FIELD("Entry No.");
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
                    if not ("Source Type" in ["Source Type"::Customer, "Source Type"::Vendor]) then begin
                        Navigate.SetDoc("Posting Date", "Source No.");
                        Navigate.Run;
                    end;
                end;
            }
        }
    }

    var
        Navigate: Page Navigate;
}

