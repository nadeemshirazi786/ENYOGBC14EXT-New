pageextension 14229615 "EN Purch. & Pay. Setup" extends "Purchases & Payables Setup"
{
    layout
    {
        addafter("Default Accounts")
        {
            group("Extra Charge")
            {

                field("Shortcut Extra Charge 1 Code"; "Shortcut Extra Chrg 1 Code ELA")
                {
                    ApplicationArea = All;

                }
                field("Shortcut Extra Charge 2 Code"; "Shortcut Extra Chrg 2 Code ELA")
                {
                    ApplicationArea = All;

                }
                field("Shortcut Extra Charge 3 Code"; "Shortcut Extra Chrg 3 Code ELA")
                {
                    ApplicationArea = All;

                }
                field("Shortcut Extra Charge 4 Code"; "Shortcut Extra Chrg 4 Code ELA")
                {
                    ApplicationArea = All;

                }
                field("Shortcut Extra Charge 5 Code"; "Shortcut Extra Chrg 5 Code ELA")
                {
                    ApplicationArea = All;
                }
            }
        }
        addlast(General)
        {
            field("Purchase Worksheet Location"; "Purchase Worksheet Location")
            {
                ApplicationArea = All;
            }
        }
        addlast("Number Series")
        {
            field("Rebate Nos."; "Rebate Nos.")
            {
                ApplicationArea = All;
            }
            field("Rebate Document Nos."; "Rebate Document Nos. ELA")
            {
                ApplicationArea = All;
            }
            field("Rebate Claim Reference Nos."; "Rbt Claim Reference Nos. ELA")
            {
                ApplicationArea = All;
            }
        }
        addlast(General)
        {
            field("Allow Over Receiving ELA"; "Allow Over Receiving ELA")
            {
                Caption = 'Allow Over Receiving';
            }
            field("Use Over Receiving Approvals ELA"; "Use Over Receiving Approvals ELA")
            {
                Caption = 'Use Over Receiving Approvals';
            }
            field("Over Rcv. Approval Rule Source ELA"; "Over Rcv. Approval Rule Source ELA")
            {
                Caption = 'Over Rcv. Approval Rule Source';
            }
        }
        addlast(content)
        {

            group(Rebates)
            {
                Caption = 'Rebates';
                group(Calculation)
                {
                    Caption = 'Calculation';
                    field("Calculate Rebates on Release"; "Calculate Rbt on Release ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Calculate SB Rbt on Release"; "Calc SB Rbt on Release ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Calc. Rebate After Discounts"; "Calc. Rbt After Discounts ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Rebate Calc. Date Formula"; "Rbt Calc. Date Formula ELA")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Registering)
                {
                    Caption = 'Registering';
                    field("Register Rebates on Doc. Post"; "Register Rbt on Doc. Post ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Register SB Rbt on SDoc Post"; "Register SB Rbt SDoc Post ELA")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Posting)
                {
                    Caption = 'Posting';
                    field("Post Rebates on Document Post"; "Post Rbt on Document Post ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Post SB Rbt on SDoc Post"; "Post SB Rbt on SDoc Post ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Post Rebates to Vend Buy Group"; "Post Rbt to Vend Buy Group ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Auto-Apply Rebates on Post"; "Auto-Apply Rebates on Post ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Use Src Doc No For Doc Rebates"; "Use Src Doc No For Doc Rbt ELA")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control1000000010)
                {
                    ShowCaption = false;
                    field("Rebate Batch Name"; "Rbt Batch Name ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Rebate Refund Jnl. Template"; "Rbt Refund Jnl. Template ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Rebate Refund Journal Batch"; "Rbt Refund Journal Batch ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Rebate Date Source"; "Rebate Date Source ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Lump Sum Rebate Distribution"; "Lump Sum Rbt Distribution ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Lump Sum Rbt Blocked Vend. Act"; "Lump Sum Rbt Blk Vend. Act ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Items Req. on Lump Sum Rebate"; "Items Req. on Lump Sum Rbt ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Hide Rbt Ent on Vend Ledg. Frm"; "Hide Rbt Ent Vend Ledg Frm ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Guaranteed Cost Basis"; "Guaranteed Cost Basis ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Guaranteed Cost Date Basis"; "Guaranteed Cost Date Basis ELA")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
        addafter(Archiving)
        {
            group("Global Group ELA")
            {
                Caption = 'Global Group';
                field("Global Group 1 Code ELA"; "Global Group 1 Code ELA")
                {
                    Caption = 'Global Group 1 Code';
                }
                field("Global Group 2 Code ELA"; "Global Group 2 Code ELA")
                {
                    Caption = 'Global Group 2 Code';
                }
                field("Global Group 3 Code ELA"; "Global Group 3 Code ELA")
                {
                    Caption = 'Global Group 3 Code';
                }
                field("Global Group 4 Code ELA"; "Global Group 4 Code ELA")
                {
                    Caption = 'Global Group 4 Code';
                }
                field("Global Group 5 Code ELA"; "Global Group 5 Code ELA")
                {
                    Caption = 'Global Group 5 Code';
                }

            }
        }
    }


}