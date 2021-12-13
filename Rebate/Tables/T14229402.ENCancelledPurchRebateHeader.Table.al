table 14229402 "Cancel Purch. Rbt Header ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - New Table
    // 
    // ENRE1.00
    //    - New Fields
    //    - Maximum Quantity (Base)
    //    - Maximum Amount
    // 
    // ENRE1.00
    //   20111108
    //     - removed Rebate Type ::"Guaranteed Cost Deal" option; replaced with "Sales-Based"
    //     - new "Calculation Basis"::Guaranteed Cost Deal option
    // 
    // ENRE1.00
    //    - changed tablerelation of 353 from User to User."User Name"; changed ValidateTableRelation to No; added validate code

    DrillDownPageID = "Cancelled Purch Rbt List ELA";
    LookupPageID = "Cancelled Purch Rbt List ELA";

    fields
    {
        field(10; "Code"; Code[20])
        {
            Editable = true;
        }
        field(20; Description; Text[50])
        {
        }
        field(30; "Start Date"; Date)
        {
        }
        field(40; "End Date"; Date)
        {
        }
        field(50; "Credit G/L Account No."; Code[20])
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
            OptionCaption = 'Pct. Purch.($),($)/Unit,Lump Sum,Guaranteed Cost Deal';
            OptionMembers = "Pct. Purch.($)","($)/Unit","Lump Sum","Guaranteed Cost Deal";
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

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Calculation Basis", "Calculation Basis"::"($)/Unit");
                //</ENRE1.00>
            end;
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
        field(105; "Open (LCY)"; Decimal)
        {
            CalcFormula = Sum("Rebate Entry ELA"."Amount (LCY)" WHERE("Rebate Code" = FIELD(Code),
                                                                   "Posting Date" = FIELD("Date Filter"),
                                                                   "Functional Area" = FIELD("Functional Area Filter"),
                                                                   "Source Type" = FIELD("Source Type Filter"),
                                                                   "Source No." = FIELD("Source No. Filter"),
                                                                   "Source Line No." = FIELD("Source Line No. Filter")));
            Caption = 'Open ($)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; "Registered (LCY)"; Decimal)
        {
            CalcFormula = Sum("Rebate Ledger Entry ELA"."Amount (LCY)" WHERE("Rebate Code" = FIELD(Code),
                                                                          "Posted To G/L" = CONST(false),
                                                                          "Paid to Customer" = CONST(false),
                                                                          "Posting Date" = FIELD("Date Filter"),
                                                                          "Functional Area" = FIELD("Functional Area Filter"),
                                                                          "Source Type" = FIELD("Source Type Filter"),
                                                                          "Source No." = FIELD("Source No. Filter"),
                                                                          "Source Line No." = FIELD("Source Line No. Filter")));
            Caption = 'Registered ($)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(115; "Posted (LCY)"; Decimal)
        {
            CalcFormula = Sum("Rebate Ledger Entry ELA"."Amount (LCY)" WHERE("Rebate Code" = FIELD(Code),
                                                                          "Posted To G/L" = CONST(true),
                                                                          "Paid to Customer" = CONST(false),
                                                                          "Posting Date" = FIELD("Date Filter"),
                                                                          "Functional Area" = FIELD("Functional Area Filter"),
                                                                          "Source Type" = FIELD("Source Type Filter"),
                                                                          "Source No." = FIELD("Source No. Filter"),
                                                                          "Source Line No." = FIELD("Source Line No. Filter")));
            Caption = 'Posted ($)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(116; "Closed (LCY)"; Decimal)
        {
            CalcFormula = Sum("Rebate Ledger Entry ELA"."Amount (LCY)" WHERE("Rebate Code" = FIELD(Code),
                                                                          "Paid to Customer" = CONST(true),
                                                                          "Posting Date" = FIELD("Date Filter"),
                                                                          "Functional Area" = FIELD("Functional Area Filter"),
                                                                          "Source Type" = FIELD("Source Type Filter"),
                                                                          "Source No." = FIELD("Source No. Filter"),
                                                                          "Source Line No." = FIELD("Source Line No. Filter")));
            Caption = 'Closed ($)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(117; "Rebate Ledger Amount (RBT)"; Decimal)
        {
            CalcFormula = Sum("Rebate Ledger Entry ELA"."Amount (RBT)" WHERE("Rebate Code" = FIELD(Code),
                                                                          "Posting Date" = FIELD("Date Filter"),
                                                                          "Functional Area" = FIELD("Functional Area Filter"),
                                                                          "Source Type" = FIELD("Source Type Filter"),
                                                                          "Source No." = FIELD("Source No. Filter"),
                                                                          "Source Line No." = FIELD("Source Line No. Filter")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(118; "Rebate Ledger Amount (LCY)"; Decimal)
        {
            CalcFormula = Sum("Rebate Ledger Entry ELA"."Amount (LCY)" WHERE("Rebate Code" = FIELD(Code),
                                                                          "Posting Date" = FIELD("Date Filter"),
                                                                          "Functional Area" = FIELD("Functional Area Filter"),
                                                                          "Source Type" = FIELD("Source Type Filter"),
                                                                          "Source No." = FIELD("Source No. Filter"),
                                                                          "Source Line No." = FIELD("Source Line No. Filter")));
            Caption = 'Rebate Ledger Amount ($)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(119; "Rebate Ledger Amount (DOC)"; Decimal)
        {
            CalcFormula = Sum("Rebate Ledger Entry ELA"."Amount (DOC)" WHERE("Rebate Code" = FIELD(Code),
                                                                          "Posting Date" = FIELD("Date Filter"),
                                                                          "Functional Area" = FIELD("Functional Area Filter"),
                                                                          "Source Type" = FIELD("Source Type Filter"),
                                                                          "Source No." = FIELD("Source No. Filter"),
                                                                          "Source Line No." = FIELD("Source Line No. Filter")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Date Filter"; Date)
        {
            ClosingDates = false;
            FieldClass = FlowFilter;
        }
        field(121; "Posted Credit Amount (LCY)"; Decimal)
        {
            CalcFormula = - Sum("G/L Entry".Amount WHERE("G/L Account No." = FIELD("Credit G/L Account No."),
                                                         "Rebate Code ELA" = FIELD(Code)));
            Caption = 'Posted Credit Amount ($)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(122; "Posted Offset Amount (LCY)"; Decimal)
        {
            CalcFormula = - Sum("G/L Entry".Amount WHERE("G/L Account No." = FIELD("Offset G/L Account No."),
                                                         "Rebate Code ELA" = FIELD(Code)));
            Caption = 'Posted Offset Amount ($)';
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
            OptionCaption = 'Off-Invoice,Everyday,Lump Sum,Sales-Based';
            OptionMembers = "Off-Invoice",Everyday,"Lump Sum","Sales-Based";
        }
        field(160; "Post to Sub-Ledger"; Option)
        {
            OptionCaption = 'Post,Do Not Post';
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
        field(210; "Apply-To Vendor No."; Code[20])
        {
            TableRelation = Vendor;
        }
        field(215; "Apply-To Order Address Code"; Code[10])
        {
            TableRelation = "Order Address".Code WHERE("Vendor No." = FIELD("Apply-To Vendor No."));
        }
        field(230; "Apply-To Vendor Group Code"; Code[20])
        {
            TableRelation = "Rebate Group ELA".Code;
        }
        field(240; "External Reference No."; Code[20])
        {
        }
        field(250; "Functional Area Filter"; Option)
        {
            FieldClass = FlowFilter;
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(260; "Source Type Filter"; Option)
        {
            FieldClass = FlowFilter;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Posted Invoice,Posted Cr. Memo,Customer,Vendor';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Posted Invoice","Posted Cr. Memo",Customer,Vendor;
        }
        field(270; "Source No. Filter"; Code[20])
        {
            FieldClass = FlowFilter;

            trigger OnValidate()
            var
                lrecSalesInvHeader: Record "Sales Invoice Header";
                lrecSalesCrMemoHeader: Record "Sales Cr.Memo Header";
            begin
            end;
        }
        field(280; "Source Line No. Filter"; Integer)
        {
            FieldClass = FlowFilter;
        }
        field(290; "Post to Vendor Buying Group"; Boolean)
        {
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
            CalcFormula = Exist("Purchase Rbt Comment Line ELA" WHERE("Purchase Rebate Code" = FIELD(Code)));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(351; Blocked; Boolean)
        {
        }
        field(352; "Cancelled Date"; Date)
        {
        }
        field(353; "Cancelled By User ID"; Code[50])
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
        field(360; "Sales Profit Modifier"; Boolean)
        {
            Description = 'ENRE1.00';
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
        key(Key3; "Apply-To Vendor No.", "Apply-To Order Address Code", "Apply-To Vendor Group Code", "Start Date", "End Date", "Rebate Type")
        {
            MaintainSIFTIndex = false;
        }
        key(Key4; "External Reference No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Cancelled Date" := WorkDate;
        "Cancelled By User ID" := UserId;
    end;

    var
        gconText001: Label 'You cannot rename a Rebate.';
        gconText002: Label 'Rebate value for %1 cannot be greater than 100.';
        gconText003: Label 'Rebate Header Apply-To Filters are not activated in Sales & Receivables Setup';
        gText004: Label 'You cannot delete Rebate No. %1. It has Posted Rebate Details.';
        gText005: Label 'Start Date must not be greater than End Date.';
        gText006: Label 'You cannot make changes or delete this rebate since it is linked to a promotinal job.';
        gcduLoginMgt: Codeunit "User Management";
}

