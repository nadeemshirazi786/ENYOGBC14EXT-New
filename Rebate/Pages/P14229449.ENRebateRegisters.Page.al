page 14229449 "Rebate Registers ELA"
{

    // ENRE1.00 2021-09-08 AJ

    Caption = 'Rebate Registers';
    Editable = false;
    PageType = List;
    SourceTable = "Rebate Register ELA";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Source Code"; "Source Code")
                {
                    ApplicationArea = All;
                }
                field("Journal Batch Name"; "Journal Batch Name")
                {
                    ApplicationArea = All;
                }
                field("From Entry No."; "From Entry No.")
                {
                    ApplicationArea = All;
                }
                field("To Entry No."; "To Entry No.")
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
            group("&Register")
            {
                Caption = '&Register';
                action("Rebate Ledger")
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Ledger';
                    Image = Ledger;

                    trigger OnAction()
                    begin
                        ShowRebateRegister;
                    end;
                }
            }
        }
    }


    procedure ShowRebateRegister()
    var
        lrecRebateLedger: Record "Rebate Ledger Entry ELA";
    begin
        lrecRebateLedger.SetRange("Entry No.", "From Entry No.", "To Entry No.");
        PAGE.Run(PAGE::"Rebate Ledger Entries ELA", lrecRebateLedger);
    end;
}

