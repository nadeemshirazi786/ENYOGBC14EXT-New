table 14229405 "Cancelled Rebate Header ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - new table to be used for rebates that have been cancelled
    //    - add field
    //       * 290 Accrue Rebate To Cust. Buy Grp
    // 
    // ENRE1.00
    //    - add field
    //       * 350 Comment
    // 
    // ENRE1.00
    //   - New Fields
    //   - Maximum Quantity (Base)
    //   - Maximum Amount
    // 
    // ENRE1.00
    //    - new rebate type option commodity
    // 
    // ENRE1.00
    //    - changed tablerelation of 10001 from User to User."User Name"; changed ValidateTableRelation to No; added validate code

    LookupPageID = "Cancelled Rebate List ELA";

    fields
    {
        field(10; "Code"; Code[20])
        {
            Editable = true;

            trigger OnValidate()
            var
                lrecSalesSetup: Record "Sales & Receivables Setup";
                lcduNoSeriesMgt: Codeunit NoSeriesManagement;
            begin
            end;
        }
        field(20; Description; Text[50])
        {
        }
        field(30; "Start Date"; Date)
        {

            trigger OnValidate()
            var
                lText000: Label 'Start Date must be greater than End Date';
            begin
            end;
        }
        field(40; "End Date"; Date)
        {

            trigger OnValidate()
            var
                lText000: Label 'End Date must be greater than Start Date';
            begin
            end;
        }
        field(50; "Expense G/L Account No."; Code[20])
        {
            TableRelation = "G/L Account";

            trigger OnValidate()
            var
                lrecGLAcct: Record "G/L Account";
            begin
            end;
        }
        field(60; "Calculation Basis"; Option)
        {
            OptionCaption = 'Pct. Sale($),($)/Unit,Lump Sum,,Commodity';
            OptionMembers = "Pct. Sale($)","($)/Unit","Lump Sum",,Commodity;
        }
        field(70; "Unit of Measure Code"; Code[10])
        {
            TableRelation = "Unit of Measure";
        }
        field(80; "Minimum Quantity (Base)"; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(81; "Maximum Quantity (Base)"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            Description = 'ENRE1.00';
        }
        field(85; "Minimum Amount"; Decimal)
        {
            DecimalPlaces = 2 : 5;
        }
        field(86; "Maximum Amount"; Decimal)
        {
            DecimalPlaces = 2 : 5;
            Description = 'ENRE1.00';
        }
        field(90; "Rebate Value"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(100; "Currency Code"; Code[10])
        {
            TableRelation = Currency;
        }
        field(110; "Registered (LCY)"; Decimal)
        {
            CalcFormula = Sum("Rebate Ledger Entry ELA"."Amount (LCY)" WHERE("Rebate Code" = FIELD(Code),
                                                                          "Posted To G/L" = CONST(false),
                                                                          "Paid to Customer" = CONST(false)));
            Caption = 'Registered ($)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(115; "Posted (LCY)"; Decimal)
        {
            CalcFormula = Sum("Rebate Ledger Entry ELA"."Amount (LCY)" WHERE("Rebate Code" = FIELD(Code),
                                                                          "Posted To G/L" = CONST(true),
                                                                          "Paid to Customer" = CONST(false)));
            Caption = 'Posted ($)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(116; "Closed (LCY)"; Decimal)
        {
            CalcFormula = Sum("Rebate Ledger Entry ELA"."Amount (LCY)" WHERE("Rebate Code" = FIELD(Code),
                                                                          "Paid to Customer" = CONST(true)));
            Caption = 'Closed ($)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Date Filter"; Date)
        {
            ClosingDates = false;
            FieldClass = FlowFilter;
        }
        field(121; "Posted Expense Amount (LCY)"; Decimal)
        {
            CalcFormula = - Sum("G/L Entry".Amount WHERE("G/L Account No." = FIELD("Expense G/L Account No."),
                                                         "Rebate Code ELA" = FIELD(Code)));
            Caption = 'Posted Expense Amount ($)';
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(122; "Posted Offset Amount (LCY)"; Decimal)
        {
            CalcFormula = - Sum("G/L Entry".Amount WHERE("G/L Account No." = FIELD("Offset G/L Account No."),
                                                         "Rebate Code ELA" = FIELD(Code)));
            Caption = 'Posted Offset Amount ($)';
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(130; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(140; "Rebate Category Code"; Code[20])
        {
            TableRelation = "Rebate Category ELA".Code;
        }
        field(150; "Rebate Type"; Option)
        {
            OptionCaption = 'Off-Invoice,Everyday,Lump Sum,,Commodity';
            OptionMembers = "Off-Invoice",Everyday,"Lump Sum",,Commodity;
        }
        field(160; "Post to Sub-Ledger"; Option)
        {
            OptionMembers = Post,"Do Not Post";
        }
        field(170; "Offset G/L Account No."; Code[20])
        {
            TableRelation = "G/L Account";
        }
        field(180; "Include In Unit Price on Print"; Boolean)
        {
        }
        field(190; "Has Rebate Ledger Entries"; Boolean)
        {
            CalcFormula = Exist("Rebate Ledger Entry ELA" WHERE("Rebate Code" = FIELD(Code)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(200; "Apply-To Customer Type"; Option)
        {
            OptionCaption = ' ,All,Specific,Group';
            OptionMembers = " ",All,Specific,Group;
        }
        field(210; "Apply-To Customer No."; Code[20])
        {
            TableRelation = Customer;
        }
        field(215; "Apply-To Customer Ship-To Code"; Code[10])
        {
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Apply-To Customer No."));

            trigger OnValidate()
            var
                lrecShipTo: Record "Ship-to Address";
            begin
            end;
        }
        field(220; "Apply-To Cust. Group Type"; Option)
        {
            OptionCaption = ' ,Rebate Group';
            OptionMembers = " ","Rebate Group";
        }
        field(230; "Apply-To Cust. Group Code"; Code[20])
        {
            TableRelation = IF ("Apply-To Cust. Group Type" = CONST("Rebate Group")) "Rebate Group ELA".Code;
        }
        field(240; "External Reference No."; Code[20])
        {
        }
        field(290; "Post to Cust. Buying Group"; Boolean)
        {
            Caption = 'Post to Customer Buying Group';
            Description = 'ENRE1.00';
        }
        field(300; "Custom Value 1"; Code[20])
        {
            Caption = 'Custom Value 1';
        }
        field(310; "Custom Value 2"; Code[20])
        {
            Caption = 'Custom Value 2';
        }
        field(320; "Custom Value 3"; Code[20])
        {
            Caption = 'Custom Value 3';
        }
        field(330; "Custom Value 4"; Code[20])
        {
            Caption = 'Custom Value 4';
        }
        field(340; "Custom Value 5"; Code[20])
        {
            Caption = 'Custom Value 5';
        }
        field(350; Comment; Boolean)
        {
            CalcFormula = Exist("Cancel Rbt Comment Line ELA" WHERE("Rebate Code" = FIELD(Code)));
            Caption = 'Comment';
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(360; "Job No."; Code[20])
        {
            Editable = false;
            TableRelation = Job;
        }
        field(361; "Job Task No."; Code[20])
        {
            Editable = false;
            TableRelation = "Job Task"."Job Task No." WHERE("Job No." = FIELD("Job No."));
        }
        field(10000; "Cancelled Date"; Date)
        {
        }
        field(10001; "Cancelled By User ID"; Code[50])
        {
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
                gcduLoginMgt.LookupUserID("Cancelled By User ID");
            end;

            trigger OnValidate()
            begin
                //<ENRE1.00>
                gcduLoginMgt.ValidateUserID("Cancelled By User ID");
                //</ENRE1.00>
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; "Start Date", "End Date", "Rebate Type")
        {
            MaintainSIFTIndex = false;
        }
        key(Key3; "Apply-To Customer Type", "Apply-To Customer No.", "Apply-To Customer Ship-To Code", "Apply-To Cust. Group Type", "Apply-To Cust. Group Code", "Start Date", "End Date", "Rebate Type")
        {
            MaintainSIFTIndex = false;
        }
        key(Key4; "External Reference No.")
        {
        }
        key(Key5; "Job No.", "Job Task No.")
        {
            MaintainSIFTIndex = false;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        Error(gText002);
    end;

    trigger OnInsert()
    var
        lrecSalesSetup: Record "Sales & Receivables Setup";
        lcduNoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        "Cancelled Date" := WorkDate;
        "Cancelled By User ID" := UserId;
    end;

    trigger OnRename()
    begin
        Error(gText001);
    end;

    var
        gText001: Label 'You cannot rename a cancelled rebate.';
        gText002: Label 'You cannot delete a cancelled rebate.';
        gcduLoginMgt: Codeunit "User Management";
}

