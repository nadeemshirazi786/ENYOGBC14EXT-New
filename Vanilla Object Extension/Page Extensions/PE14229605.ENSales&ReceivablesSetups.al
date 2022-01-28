pageextension 14229605 "EN Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    layout
    {
        addafter(Archiving)
        {
            group("Sales Order Cash & Carry")
            {
                field("C&C Cash Journal Template"; "C&C Journal Template ELA")
                {
                    ApplicationArea = All;

                }
                field("C&C Cash Journal Batch"; "C&C Cash Journal Batch ELA")
                {
                    ApplicationArea = All;

                }
                field("C&C Credits Journal Batch"; Rec."C&C Credits Journal Batch")
                {
                    ApplicationArea = All;

                }
                field("C&C Minimum Overdue Invoice"; "C&C Min Overdue Invoice ELA")
                {
                    ApplicationArea = All;

                }
                field("Ship-to Code for CC"; "Ship-to Code for CC ELA")
                {
                    ApplicationArea = All;
                }
                field("Cash Payment Method ELA"; "Cash Payment Method ELA")
                {
                    Caption = 'Cash Payment Method';
                    ApplicationArea = All;
                }
                field("Cash Receipt Option ELA"; "Cash Receipt Option ELA")
                {
                    Caption = 'Cash Receipt Option';
                    ApplicationArea = All;

                }
            }
        }
        addlast("Number Series")
        {
            field("Sales Payment Nos."; "Sales Payment Nos. ELA")
            {

            }
            field("Posted Sales Payment Nos."; "Posted Sales Payment Nos. ELA")
            {

            }
            field("Rebate Nos."; "Rebate Nos. ELA")
            {
                ApplicationArea = All;
            }
            field("Rebate Document Nos."; "Rebate Document Nos. ELA")
            {
                ApplicationArea = All;
                ToolTip = 'Rebate entries get posted to the sub-ledger using this no. series';
            }
        }
        addlast(General)
        {
            field("Archive S.Quote on Release"; Rec."Archive S.Quote on Release ELA")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether to archive Sales Quote on Release or not.';
            }
            field("Update Item Cost on Invoice"; Rec."Update ItemCost on Invoice ELA")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether to update item cost on invoice or not.';
            }
            field("Update Item Cost on Release"; Rec."Update ItemCost on Release ELA")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether to update item cost on release or not.';
            }
            field("Update Item Cost on Shipment"; Rec."Update ItemCost on Spmt ELA")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether to update item cost on shipment or not.';
            }
        }
        addlast(Content)
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
                        MultiLine = true;
                    }
                    field("Calc. Rebate After Discount"; "Calc. Rbt After Discount ELA")
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                    }
                    field("Rebate Calc. Date Formula"; "Rebate Calc. Date Formula ELA")
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                        ToolTip = 'Define a standard date formula to tell the "Calculate/Accrue Rebates" periodic activity how far back to analyse documents for applicable rebates (eg. -30D)';
                    }
                    field("Use Rebate Hdr Applies-to Filt"; "Use RbtHdr AppliesTo Filt ELA")
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                    }
                    field("Incl. Open Ord. Commodity Calc"; "Inc Open Ord CommodityCalc ELA")
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
                        MultiLine = true;
                        ToolTip = 'If TRUE, document-based rebates will be calculated when the Source Document is invoiced.';
                    }
                }
                group(Posting)
                {
                    Caption = 'Posting';
                    field("Post Rebates on Document Post"; "Post Rbt on Document Post ELA")
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                        ToolTip = 'If TRUE, all document-based rebates will be posted to the GL when the Source Document is invoiced.';
                    }
                    field("Auto-Apply Rebates on Post"; "Auto-Apply Rebates on Post ELA")
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                        ToolTip = 'If TRUE, when a rebate is posted to the Customer Sub-Ledger, it will be automatically applied to the Source Document';
                    }
                    field("Post Rebates to Cust Buy Grp"; "Post Rbt to Cust Buy Grp ELA")
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                    }
                    field("Use Src Doc No For Doc Rebates"; "Use Src DocNo For Doc Rbt ELA")
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                        ToolTip = 'If TRUE, document-based rebates will be posted ot the sub-ledger using the Source Document No.';
                    }
                }
                group(Control1000000018)
                {
                    ShowCaption = false;
                    field("Rebate Batch Name"; "Rebate Batch Name ELA")
                    {
                        ApplicationArea = All; //check
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
                    field("Rebate Price Source"; "Rebate Price Source ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Lump Sum Rebate Distribution"; "LumpSum Rbt Distribution ELA")
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                        ToolTip = 'When distributing the Lump Sum rebate, tells the system whether or not to break it out by customer only, or by customer-item combination';
                    }
                    field("Lump Sum Rbt Blocked Cust Acti"; "LumpSum Rbt Blk Cust Act ELA")
                    {
                        ApplicationArea = All;
                    }
                    field("Items Req. on Lump Sum Rebate"; "Items Req on LumpSum Rbt ELA")
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                        ToolTip = 'For Lump Sum rebates, tells the system whether or not to error out if there are no item lines defined in the Rebate Details';
                    }
                    field("Hide Rbt Ent on Cust Ledge Frm"; "Hide Rbt Ent Cust Ledg Frm ELA")
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                        ToolTip = 'If TRUE, Rebate Entries will be automatically filtered out of the Customer Ledger Entry forms, however you can remove the filter on the form.';
                    }
                }
            }
        }
        addafter(General)
        {
            group("Global Groups")
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
        addafter("Number Series")
        {
            group("Costing/Pricing")
            {
                field("Sales Price Model"; Rec."Sales Pricing Model ELA")
                {
                    ApplicationArea = All;
                    ToolTip = 'For selected as Default will use default Microsoft Pricing Model, if Specified as Best Price or Specific Price will apply Pricing based on Elation Pricing model';
                }

                field("Global Price List Group"; Rec."Global Price List Group ELA")
                {
                    ApplicationArea = All;
                }
                field("Sales Price/Discount Source"; Rec."Sales Price/Disc Source ELA")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to have pricing based on Bill-to Customer or Sell-to Customer';
                }
                field("Order Rule Comb Price Priority"; Rec."Order Rule Comb Price Prio ELA")
                {

                }
                field("Mandatory Item Rep UOM"; "Mandatory Item Rep UOM ELA")
                {

                }
                field("Lock Unit Price on Manual Edit"; "Lock UnitPrice on ManEdit ELA")
                {

                }


            }
            group(Rules)
            {
                field("Use Order Rules"; "Use Order Rules ELA")
                {

                }

                field("Validate Item No. On Entry"; "Validate Item No. On Entry ELA")
                {

                }

                field("Default Min. Qty. On Entry"; "Default Min. Qty. On Entry ELA")
                {

                }

                field("Auto Round Order Multiples"; "Auto Round Order Multiples ELA")
                {

                }

                field("Item Setup Priority"; "Item Setup Priority ELA")
                {

                }

                field("Allow Over Shipping"; "Allow Over Shipping ELA")
                {

                }

                field("Allow Negative Invoice Posting"; "Allow Negative Inv Posting ELA")
                {

                }

                field("Ship-To Req. on Order Staging"; "Ship-To Req. on Order Stg ELA")
                {

                }
                field("Order Rule Grp Cust. Priority"; "Order Rule Grp Cust. Prio. ELA")
                {

                }

            }
        }
		addafter("Skip Manual Reservation")
        {
            field("Auto Create Whse. Shipment"; "Auto Create Whse. Shipment ELA")
            {
                ApplicationArea = All;
            }
            field("Auto Create Trip"; "Auto Create Trip ELA")
            {
                ApplicationArea = All;
            }
        }

    }
}


