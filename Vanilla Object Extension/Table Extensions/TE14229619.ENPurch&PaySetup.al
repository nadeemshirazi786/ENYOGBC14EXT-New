tableextension 14229619 "Purchases & Payables Setup ELA" extends "Purchases & Payables Setup"
{
    fields
    {
        field(14229400; "Rebate Nos."; Code[20])
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
        field(14229402; "Rbt Claim Reference Nos. ELA"; Code[20])
        {
            Caption = 'Rebate Claim Reference Nos.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "No. Series";
        }
        field(14229403; "Rbt Refund Jnl. Template ELA"; Code[10])
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
        field(14229404; "Rbt Refund Journal Batch ELA"; Code[10])
        {
            Caption = 'Rebate Refund Journal Batch';
            Description = 'ENRE1.00';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Rbt Refund Jnl. Template ELA"));
        }
        field(14229405; "Rbt Batch Name ELA"; Code[10])
        {
            Caption = 'Rebate Batch Name';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = CONST('SALES'));
        }
        field(14229406; "Rebate Date Source ELA"; Option)
        {
            Caption = 'Rebate Date Source';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            OptionCaption = 'Order Date,Expected Receipt Date';
            OptionMembers = "Order Date","Expected Receipt Date";
        }
        field(14229407; "Post Rbt to Vend Buy Group ELA"; Boolean)
        {
            Caption = 'Post Rebates to Vendor Buying Group';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229408; "Rbt Calc. Date Formula ELA"; DateFormula)
        {
            Caption = 'Rebate Calculation Date Formula';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229409; "Guaranteed Cost Basis ELA"; Option)
        {
            Caption = 'Guaranteed Cost Basis';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            OptionCaption = 'Last Receipt,Adj. Document Cost,User-Defined Calculation';
            OptionMembers = "Last Receipt","Adj. Document Cost","User-Defined Calculation";
        }
        field(14229410; "Guaranteed Cost Date Basis ELA"; Option)
        {
            Caption = 'Guaranteed Cost Date Basis';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            OptionCaption = 'Order Date,Shipment Date';
            OptionMembers = "Order Date","Shipment Date";
        }
        field(14229411; "Auto-Apply Rebates on Post ELA"; Boolean)
        {
            Caption = 'Auto-Apply Rebates on Post';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229412; "Use Src Doc No For Doc Rbt ELA"; Boolean)
        {
            Caption = 'Use Source Doc. No. For Doc.-Based Rebates';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229413; "Calc. Rbt After Discounts ELA"; Boolean)
        {
            Caption = 'Calculate Rebate After Discounts';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229414; "Force Appl On Doc Returns ELA"; Boolean)
        {
            Caption = 'Force Applies-to Doc. Type and ID On Purchase/Sale Returns';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229415; "Lump Sum Rbt Distribution ELA"; Option)
        {
            Caption = 'Lump Sum Rebate Distribution';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            OptionCaption = 'Vendor,Vendor-Item';
            OptionMembers = Vendor,"Vendor-Item";
        }
        field(14229416; "Lump Sum Rbt Blk Vend. Act ELA"; Option)
        {
            Caption = 'Lump Sum Rbt Blocked Vend. Act';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            OptionCaption = 'None,Error,Skip';
            OptionMembers = "None",Error,Skip;
        }
        field(14229417; "Items Req. on Lump Sum Rbt ELA"; Boolean)
        {
            Caption = 'Items Req. on Lump Sum Rebate';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229418; "Item BOC Nos. ELA"; Code[20])
        {
            Caption = 'Item BOC Nos.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "No. Series";
        }
        field(14229419; "Register SB Rbt SDoc Post ELA"; Boolean)
        {
            Caption = 'Register Sales-Based Rebates on Sales Document Post';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229420; "Post SB Rbt on SDoc Post ELA"; Boolean)
        {
            Caption = 'Post Sales-Based Rebates on Sales Document Post';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229421; "Calc SB Rbt on Release ELA"; Boolean)
        {
            Caption = 'Calc. Sales-Based Rebate on Sales Doc. Release.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229422; "Calculate Rbt on Release ELA"; Boolean)
        {
            Caption = 'Calculate Rebates on Release';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229423; "Register Rbt on Doc. Post ELA"; Boolean)
        {
            Caption = 'Register Rebates on Document Post';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229424; "Post Rbt on Document Post ELA"; Boolean)
        {
            Caption = 'Post Rebates on Document Post';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229425; "Hide Rbt Ent Vend Ledg Frm ELA"; Boolean)
        {
            Caption = 'Hide Rbt Ent on Vend Ledg. Frm';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229100; "Shortcut Extra Chrg 1 Code ELA"; Code[10])
        {
            Caption = 'Shortcut Extra Charge 1 Code';
            DataClassification = ToBeClassified;
            TableRelation = "EN Extra Charge";
        }
        field(14229101; "Shortcut Extra Chrg 2 Code ELA"; Code[10])
        {
            Caption = 'Shortcut Extra Charge 2 Code';
            DataClassification = ToBeClassified;
            TableRelation = "EN Extra Charge";
        }
        field(14229102; "Shortcut Extra Chrg 3 Code ELA"; Code[10])
        {
            Caption = 'Shortcut Extra Charge 3 Code';
            DataClassification = ToBeClassified;
            TableRelation = "EN Extra Charge";
        }
        field(14229103; "Shortcut Extra Chrg 4 Code ELA"; Code[10])
        {
            Caption = 'Shortcut Extra Charge 4 Code';
            DataClassification = ToBeClassified;
            TableRelation = "EN Extra Charge";
        }
        field(14229104; "Shortcut Extra Chrg 5 Code ELA"; Code[10])
        {
            Caption = 'Shortcut Extra Charge 5 Code';
            DataClassification = ToBeClassified;
            TableRelation = "EN Extra Charge";
        }
        field(51000; "Retain Exp. Purch. Cost Detail"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(51001; "Purchase Worksheet Location"; Code[20])
        {
            TableRelation = Location;
            DataClassification = ToBeClassified;
        }
        field(51002; "Global Group 1 Code ELA"; Code[20])
        {
            Caption = 'Global Group 1 Code';
            TableRelation = "Global Group ELA";
            DataClassification = ToBeClassified;
        }
        field(51003; "Global Group 2 Code ELA"; Code[20])
        {
            Caption = 'Global Group 2 Code';
            TableRelation = "Global Group ELA";
            DataClassification = ToBeClassified;
        }
        field(51004; "Global Group 3 Code ELA"; Code[20])
        {
            Caption = 'Global Group 3 Code';
            TableRelation = "Global Group ELA";
            DataClassification = ToBeClassified;
        }
        field(51005; "Global Group 4 Code ELA"; Code[20])
        {
            Caption = 'Global Group 4 Code';
            TableRelation = "Global Group ELA";
            DataClassification = ToBeClassified;
        }
        field(51006; "Global Group 5 Code ELA"; Code[20])
        {
            Caption = 'Global Group 5 Code';
            TableRelation = "Global Group ELA";
            DataClassification = ToBeClassified;
        }
    }


}