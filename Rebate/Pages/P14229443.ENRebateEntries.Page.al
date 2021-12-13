page 14229443 "Rebate Entries ELA"
{

    // 
    // ENRE1.00 2021-09-08 AJ
    //   ENRE1.00 - Add Accrual Customer fields
    // 
    // ENRE1.00
    //   ENRE1.00 - New Fields Added
    //                - Pay-to Vendor No.
    //                - Pay-to Name
    //                - Buy-from Vendor No.
    //                - Buy-from Vendor Name
    //                - Order Address Code
    //                - Ship-to Vendor Name
    // 
    // ENRE1.00
    //   ENRE1.00 - new page action: "Commoditiy Entries"

    Caption = 'Rebate Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Rebate Entry ELA";

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
                field("Bill-To Customer No."; "Bill-To Customer No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Bill-To Customer Name"; "Bill-To Customer Name")
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
            group("<Action1101769005>")
            {
                Caption = 'Entry';
                action("<Action1101769006>")
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
                action("Show Source Document")
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
                action("<Action23019008>")
                {
                    ApplicationArea = All;
                    Caption = 'Commoditiy Entries';
                    Image = ValueLedger;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Commodity Entries ELA";
                    RunPageLink = "Rebate Entry No." = FIELD("Entry No.");
                }
            }
        }
    }
}

