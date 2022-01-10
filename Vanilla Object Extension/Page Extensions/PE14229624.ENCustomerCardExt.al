/// <summary>
/// PageExtension ENCustomerCardExt (ID 14228852) extends Record Customer Card.
/// </summary>
pageextension 14228852 "EN Customer Card Ext" extends "Customer Card"
{

    layout
    {
        addlast(General)
        {
            field("Order Rule Usage"; "Order Rule Usage ELA")
            {

            }
            field("Order Rule Group"; "Order Rule Group ELA")
            {

            }
            field("Recipient Agency No."; "Recipient Agency No. ELA")
            {
                ApplicationArea = All;
            }
            field("Require Ext. Doc. No."; "Require Ext. Doc. No.")
            {
                ApplicationArea = All;
            }
            field("Prices on Invoice"; "Prices on Invoice ELA")
            {
                ApplicationArea = All;
            }
        }

        addlast(Invoicing)
        {
            field("Customer Buying Group"; Rec."Customer Buying Group ELA")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the customer buying group code, which you can use to set up special sales prices in the Elation Item Sales Prices window.';
            }
            field("Campaingn No."; "Campaign No. ELA")
            {
                ApplicationArea = All;

            }
            field("Sales Unit of Measure"; "Sales Unit of Measure ELA")
            {
                ApplicationArea = All;
            }
            field("Price Rule Code"; Rec."Price Rule Code ELA")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the price rule code, which you can use to set up price rule order in Elation Price Rule window';
            }
            field("Price List Group Code"; Rec."Price List Group Code ELA")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the price list group code, which you can use to set up special sales prices in the Elation Item Sales Prices window.';
            }
            field("Sales Price/Sur. Date Control"; Rec."Sales Price/Sur Date Cntrl ELA")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Sales Price/Sur. Date Control, which controls sales price based on Order Date, Shipment Date or Requested Delivery Date';
            }
            field("Rebate Group Code"; "Rebate Group Code ELA")
            {
                ApplicationArea = All;
                ToolTip = 'Rebate group that applies to the customer. Used to group customers together for the purpose of setting up sales rebates.';
            }
        }
        addafter("Ship-to Code")
        {
            field("Require Ship-To on Sales Docs"; "Req. Ship-To on Sale Doc ELA")
            {
                ApplicationArea = All;
            }
        }
        modify("Ship-to Code")
        {
            Caption = 'Default Ship-to Code';
        }
        addlast(Shipping)
        {
            field("Delivery Zone Code"; "Delivery Zone Code ELA")
            {
                ApplicationArea = All;
            }
            field("Use Backorder Tolerance"; "Use Backorder Tolerance ELA")
            {
                ApplicationArea = All;
            }
            field("Backorder Tolerance % ELA"; "Backorder Tolerance % ELA")
            {
                ApplicationArea = All;
            }
            field("Direct Store Delivery"; "Direct Store Delivery")
            {
                ApplicationArea = All;
            }
            field("Required Vehicle"; "Required Vehicle ELA")
            {
                ApplicationArea = All;
            }
            field("Shipping Instructions ELA"; "Shipping Instructions ELA")
            {
                ApplicationArea = All;
            }

            field("Dropoff Banned Tags"; "Dropoff Banned Tags ELA")
            {
                Caption = 'Dropoff Banned Tags';
            }
            field("Dropoff Required Tags"; "Dropoff Required Tags ELA")
            {
                Caption = 'Dropoff Required Tags';
            }
            field("Dropoff Time Window End"; "Dropoff Time Window End ELA")
            {
                Caption = 'Dropoff Time Window End';
            }
            field("Dropoff Time Window End 2"; "Dropoff Time Window End 2 ELA")
            {
                Caption = 'Dropoff Time Window End 2';
            }
            field("Dropoff Time Window Start"; "Dropoff Time Window Start ELA")
            {
                Caption = 'Dropoff Time Window Start';
            }
            field("Dropoff Time Window Start 2"; "Dropoff Time Window Start 2 ELA")
            {
                Caption = 'Dropoff Time Window Start 2';
            }

        }
        addafter("Language Code")
        {
            field(Longitude; "Longitude ELA")
            {
                Caption = 'Longitude';
            }
            field(Latitude; "Latitude ELA")
            {
                Caption = 'Latitude';
            }
            field("Communication Group Code"; "Communication Group Code ELA")
            {
                ApplicationArea = All;
            }
        }
        addafter(Shipping)
        {
            group("Global Group ELA")
            {
                Caption = 'Global Group';
                field("Global Group 1 Code ELA"; "Global Group 1 Code ELA")
                {
                    Caption = 'Banana Customer Code';
                }
            }
        }

    }
    actions
    {



        addlast(Creation)
        {
            action(Rebate)
            {
                ApplicationArea = All;
                Caption = 'Post Rebates to Customer';
                Image = JobLedger;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Registered Cust GL Rbt Ldg ELA";
                RunPageLink = "No." = FIELD("No.");
            }
            action("Workwave Manifest List")
            {
                ApplicationArea = All;
                Image = List;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    WWManList: Page "Workwave Manifest List ELA";
                begin
                    WWManList.CustFilter("No.");
                    WWManList.RUN
                end;
            }
        }
        addbefore(Prices)
        {
            action("Sales Price Calculations")
            {
                Image = CalculateCost;
                RunObject = page "EN Price List Line";
                RunPageView = SORTING("Sales Type", "Sales Code", Type, Code, "Starting Date", "Variant Code", "Unit of Measure Code", "Minimum Quantity");
                RunPageLink = "Sales Type" = CONST(Customer), "Sales Code" = FIELD("No.");
            }
            action("Order Rules")
            {
                Image = CheckRulesSyntax;
                RunObject = page "EN Order Rule Details";
                RunPageView = SORTING("Sales Type", "Sales Code", "Ship-To Address Code", "Item Type", "Item Ref. No.", "Start Date", "Unit of Measure Code");
                RunPageLink = "Sales Type" = CONST(Customer), "Sales Code" = FIELD("No.");
            }

        }

    }
}
