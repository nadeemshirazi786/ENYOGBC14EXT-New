tableextension 14229603 "Sales & Receivables Setup ELA" extends "Sales & Receivables Setup"
{
    fields
    {
        field(14229400; "Rebate Nos. ELA"; Code[20])
        {
            Caption = 'Rebate Nos.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "No. Series";
        }
        field(14229401; "Rebate Document Nos. ELA"; Code[20])
        {
            Caption = 'Rebate Document Nos.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "No. Series";
        }
        field(14229402; "Use RbtHdr AppliesTo Filt ELA"; Boolean)
        {

            Caption = 'Use Rebate Header Applies-to Filters';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229406; "Post Rbt to Cust Buy Grp ELA"; Boolean)
        {

            Caption = 'Post Rebates to Customer Buying Groups';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229407; "Auto-Apply Rebates on Post ELA"; Boolean)
        {
            Caption = 'Auto-Apply Rebates on Post';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229408; "Use Src DocNo For Doc Rbt ELA"; Boolean)
        {
            Caption = 'Use Source Doc. No. For Doc.-Based Rebates';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229409; "Rebate Price Source ELA"; Option)
        {
            Caption = 'Rebate Price Source';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            OptionCaption = 'Unit Price,Delivered Unit Price';
            OptionMembers = "Unit Price","Delivered Unit Price";
        }
        field(14229410; "Rebate Date Source ELA"; Option)
        {
            Caption = 'Rebate Date Source';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            OptionCaption = 'Order Date,Shipment Date';
            OptionMembers = "Order Date","Shipment Date";
        }
        field(14229411; "Rbt Refund Jnl. Template ELA"; Code[10])
        {
            Caption = 'Rebate Refund Jnl. Template';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "Gen. Journal Template".Name WHERE(Type = FILTER(Payments));

            trigger OnValidate()
            begin

                Clear("Rbt Refund Journal Batch ELA");

            end;
        }
        field(14229412; "Rbt Refund Journal Batch ELA"; Code[10])
        {
            Caption = 'Rebate Refund Journal Batch';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Rbt Refund Jnl. Template ELA"));
        }
        field(14229414; "Post Rbt on Document Post ELA"; Boolean)
        {
            Caption = 'Post Rebates on Document Post';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229415; "Register Rbt on Doc. Post ELA"; Boolean)
        {

            Caption = 'Register Rebates on Document Post';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229416; "Rebate Batch Name ELA"; Code[10])
        {
            Caption = 'Rebate Batch Name';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = CONST('SALES'));
        }
        field(14229417; "Rebate Calc. Date Formula ELA"; DateFormula)
        {
            Caption = 'Rebate Calculation Date Formula';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229418; "Inc Open Ord CommodityCalc ELA"; Boolean)
        {
            Caption = 'Include Open Docs in Commodity Calculation';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229419; "Calc. Rbt After Discount ELA"; Boolean)
        {
            Caption = 'Calculate Rebate After Discounts';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229420; "Frc Appl On SalesReturns ELA"; Boolean)
        {
            Caption = 'Force Applies-to Doc. Type and ID On Sales Returns';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229421; "LumpSum Rbt Blk Cust Act ELA"; Option)
        {
            Caption = 'Lump Sum Rebate Blocked Customer Action';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            OptionCaption = 'None,Error,Skip';
            OptionMembers = "None",Error,Skip;
        }
        field(14229422; "LumpSum Rbt Distribution ELA"; Option)
        {
            Caption = 'Lump Sum Rebate Distribution';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            OptionCaption = 'Customer,Customer-Item';
            OptionMembers = Customer,"Customer-Item";
        }
        field(14229423; "Items Req on LumpSum Rbt ELA"; Boolean)
        {
            Caption = 'Items Req. on Lump Sum Rebate';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229424; "Calculate Rbt on Release ELA"; Boolean)
        {
            Caption = 'Calculate Rebates on Release';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229425; "Hide Rbt Ent Cust Ledg Frm ELA"; Boolean)
        {
            Caption = 'Hide Rebate Entries on Cust Ledger Forms';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229426; "Calc Commissions on Post ELA"; Boolean)
        {
            Caption = 'Calculate Commissions on Post';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229427; "Calc. Comm. After Rebates ELA"; Boolean)
        {
            Caption = 'Calc. Comm. After Rebates';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14228850; "Sales Price/Disc Source ELA"; Enum "EN Sales Price/Discount Source")
        {
            Caption = 'Sales Price/Discount Source';
            DataClassification = ToBeClassified;
        }
        field(14228851; "Global Price List Group ELA"; Code[10])
        {
            Caption = 'Global Price List Group';
            DataClassification = ToBeClassified;
        }
        field(14228852; "Order Rule Comb Price Prio ELA"; Enum "EN Order Rule Combination Price Priority")
        {
            Caption = 'Order Rule Combination Price Priority';

            DataClassification = ToBeClassified;
        }
        field(14228853; "Update ItemCost on Release ELA"; Boolean)
        {
            Caption = 'Update Item Cost on Release';
            DataClassification = ToBeClassified;
        }
        field(14228854; "Update ItemCost on Spmt ELA"; Boolean)
        {
            Caption = 'Update Item Cost on Shipment';
            DataClassification = ToBeClassified;
        }
        field(14228855; "Update ItemCost on Invoice ELA"; Boolean)
        {
            Caption = 'Update Item Cost on Invoice';
            DataClassification = ToBeClassified;
        }

        field(14228856; "Archive S.Quote on Release ELA"; Boolean)
        {
            Caption = 'Archive S.Quote on Release';
            DataClassification = ToBeClassified;
        }

        field(14228857; "Sales Pricing Model ELA"; Enum "EN Sales Price Model")
        {
            Caption = 'Sales Price Model';
            DataClassification = ToBeClassified;
        }
        field(14228858; "Std. Pallet UOM Code ELA"; Code[10])
        {
            Caption = 'Std. Pallet UOM Code';
            DataClassification = ToBeClassified;
            TableRelation = "Unit of Measure";
        }
        field(14228859; "Mandatory Item Rep UOM ELA"; Boolean)
        {
            Caption = 'Mandatory Item Reporting UOM';
            DataClassification = ToBeClassified;
        }
        field(14228860; "Lock UnitPrice on ManEdit ELA"; Boolean)
        {
            Caption = 'Lock Unit Price on Manual Edit';
            DataClassification = ToBeClassified;
        }
        field(14228861; "Use Order Rules ELA"; Boolean)
        {
            Caption = 'Use Order Rules';
            DataClassification = ToBeClassified;
        }
        field(14228862; "Validate Item No. On Entry ELA"; Boolean)
        {
            Caption = 'Validate Item No. On Entry';
            DataClassification = ToBeClassified;
        }
        field(14228863; "Default Min. Qty. On Entry ELA"; Boolean)
        {
            Caption = 'Default Min. Qty. On Entry';
            DataClassification = ToBeClassified;
        }
        field(14228864; "Auto Round Order Multiples ELA"; Boolean)
        {
            Caption = 'Auto Round Order Multiples';
            DataClassification = ToBeClassified;
        }
        field(14228865; "Item Setup Priority ELA"; Enum "EN Item Setup Priority")
        {
            Caption = 'Item Setup Priority';
            DataClassification = ToBeClassified;
        }

        field(14228866; "Allow Over Shipping ELA"; Boolean)
        {
            Caption = 'Allow Over Shipping';
            DataClassification = ToBeClassified;
        }
        field(14228867; "Allow Negative Inv Posting ELA"; Boolean)
        {
            Caption = 'Allow Negative Invoice Posting';
            DataClassification = ToBeClassified;
        }

        field(14228868; "Ship-To Req. on Order Stg ELA"; Boolean)
        {
            Caption = 'Ship-To Req. on Order Staging';
            DataClassification = ToBeClassified;
        }
        field(14228869; "Order Rule Grp Cust. Prio. ELA"; Enum "EN Ord. Rule Grp Cust Priotiry")
        {
            Caption = 'Order Rule Grp Cust. Priority';
            DataClassification = ToBeClassified;
        }


        field(14228880; "C&C Journal Template ELA"; Code[10])
        {
            Caption = 'C&C Cash Journal Template';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Template";
        }
        field(14228881; "C&C Cash Journal Batch ELA"; Code[10])
        {
            Caption = 'C&C Cash Journal Batch';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = FIELD("C&C Journal Template ELA"));
        }

        field(14228882; "C&C Credits Journal Batch"; Code[10])
        {
            Caption = 'C&C Credits Journal Batch';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = FIELD("C&C Journal Template ELA"));
        }
        field(14228883; "C&C Min Overdue Invoice ELA"; Decimal)
        {
            Caption = 'C&C Minimum Overdue Invoice';
            DataClassification = ToBeClassified;
        }
        field(14228884; "Ship-to Code for CC ELA"; Code[20])
        {
            Caption = 'Ship-to Code for CC';
            DataClassification = ToBeClassified;
        }
        field(14228910; "Sales Payment Nos. ELA"; Code[20])
        {
            Caption = 'Sales Payment Nos.';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(14228911; "Posted Sales Payment Nos. ELA"; Code[20])
        {
            Caption = 'Posted Sales Payment Nos.';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(51000; "Blank Drop Shipm. Qty. to Ship"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(51001; "Item Chg Posted Pallet Source"; Enum PstedPalletSrc)
        {
            DataClassification = ToBeClassified;
        }
        field(51002; "Sales-Freight Item Charge"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(51003; "Sales-Allowance Item Charge"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(14229311; "Import Order Type ELA"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Quote","Order";
        }
        field(14229310; "Auto Rel Imported Order ELA"; Boolean)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                IF "Import Order Type ELA" <> "Import Order Type ELA"::Order THEN
                    ERROR(Text50001);
            end;

        }
        field(14229312; "Auto Create Whse Shpmt ELA"; Boolean)
        {
            DataClassification = ToBeClassified;


        }
        field(14229313; "Import Order path ELA"; Text[20])
        {
            DataClassification = ToBeClassified;


        }
        field(14229314; "Shipment days ELA"; Integer)
        {
            DataClassification = ToBeClassified;


        }
        field(14229315; "Archive Order Path ELA"; Text[20])
        {
            DataClassification = ToBeClassified;


        }
        field(14229316; "Apply Order Rule Grp Fltr ELA"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Apply Order Rule Group Filter';


        }
        field(14229317; "Keep Message No. of Days ELA"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(14229318; "Cash Payment Method ELA"; Code[20])
        {
            Caption = 'Cash Payment Method';
            TableRelation = "Payment Method";
        }
        field(14229319; "Cash Receipt Option ELA"; Option)
        {
            Caption = 'Cash Receipt Option';
            OptionMembers = Company,Alternate,Location;
        }
        field(14229321; "Global Group 1 Code ELA"; Code[20])
        {
            Caption = 'Global Group 1 Code';
            TableRelation = "Global Group ELA";

        }
        field(14229322; "Global Group 2 Code ELA"; Code[20])
        {
            Caption = 'Global Group 2 Code';
            TableRelation = "Global Group ELA";
        }
        field(14229323; "Global Group 3 Code ELA"; Code[20])
        {
            Caption = 'Global Group 3 Code';
            TableRelation = "Global Group ELA";
        }
        field(14229324; "Global Group 4 Code ELA"; Code[20])
        {
            Caption = 'Global Group 4 Code';
            TableRelation = "Global Group ELA";
        }
        field(14229325; "Global Group 5 Code ELA"; Code[20])
        {
            Caption = 'Global Group 5 Code';
            TableRelation = "Global Group ELA";
        }
        field(14229326; "Use Over Shipping Approval ELA"; Boolean)
        {
            Caption = 'Use Over Shipping Approvals';
        }

    }
    var
        Text50001: Label 'You can only release Order type';
}