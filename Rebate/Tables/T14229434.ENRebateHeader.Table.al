table 14229434 "Rebate Header ELA"
{
    // ENRE1.00 2021-09-08 AJ

    // 
    // ENRE1.00
    //           - add function CancelRebate
    //           - add fields
    //              * 117 Posted Amount (RBT)
    //              * 118 Posted Amount (LCY)
    //              * 119 Posted Amount (DOC)
    //              * 250 Functional Area Filter
    //              * 260 Source Type Filter
    //              * 270 Source No. Filter
    //              * 280 Source Line No. Filter
    //            - add all flowfilter fields as criteria for flowfields
    //           - add field
    //              * 290 Accrue Rebate To Cust. Buy Grp
    //           - add ShowStatistics
    // 
    // ENRE1.00
    //           - add field
    //              * 350 Comment
    // 
    // ENRE1.00
    //    - add field Tradespend
    //    - add field Tradespend
    // 
    // ENRE1.00
    //    - add check to all fields except End Date to make sure changes cannot happen to rebates linked to a job
    // 
    // ENRE1.00
    //    - add Blocked field (only on table, not on page/form)
    // 
    // ENRE1.00
    //    - New Fields
    //              - Maximum Quantity (Base)
    //              - Maximum Amount
    //            - New Functions
    //              - Maximum Quantity (Base) - OnValidate
    //              - Maximum Amount - OnValidate
    // 
    // ENRE1.00
    //    - new rebate type commodity

    DrillDownPageID = "Rebate List ELA";
    LookupPageID = "Rebate List ELA";
    Caption = 'Rebate Header';
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
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>

                if Code <> xRec.Code then begin
                    lrecSalesSetup.Get;
                    lcduNoSeriesMgt.TestManual(lrecSalesSetup."Rebate Nos. ELA");
                    "No. Series" := '';
                end;
            end;
        }
        field(20; Description; Text[50])
        {

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>
            end;
        }
        field(30; "Start Date"; Date)
        {

            trigger OnValidate()
            begin
                //<ENRE1.00>
                //<14526AC>
                if (
                  (not CheckUseParent)
                ) then begin
                    TestField("Job No.", '');
                end;
                //</14526AC>
                //</ENRE1.00>

                if ("Start Date" > "End Date") and ("End Date" <> 0D) then begin
                    Error(gText005);
                end;
            end;
        }
        field(40; "End Date"; Date)
        {

            trigger OnValidate()
            begin
                if "End Date" <> 0D then begin
                    if ("End Date" < "Start Date") and ("Start Date" <> 0D) then begin
                        Error(gText005);
                    end;
                end;
            end;
        }
        field(50; "Expense G/L Account No."; Code[20])
        {
            TableRelation = "G/L Account";

            trigger OnValidate()
            var
                lrecGLAcct: Record "G/L Account";
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>
            end;
        }
        field(60; "Calculation Basis"; Option)
        {
            OptionCaption = 'Pct. Sale($),($)/Unit,Lump Sum,,Commodity';
            OptionMembers = "Pct. Sale($)","($)/Unit","Lump Sum",,Commodity;

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>

                //<ENRE1.00>
                if "Rebate Type" = "Rebate Type"::Commodity then begin
                    Error(gText008, FieldCaption("Calculation Basis"), "Rebate Type");
                end;
                //</ENRE1.00>

                if ("Calculation Basis" = "Calculation Basis"::"Pct. Sale($)") and ("Rebate Value" > 100) then begin
                    Error(gconText002, Code);
                end;

                if "Calculation Basis" = "Calculation Basis"::"Pct. Sale($)" then begin
                    Clear("Minimum Quantity (Base)");
                    Clear("Currency Code");
                    Clear("Unit of Measure Code");
                end;

                if "Calculation Basis" = "Calculation Basis"::"Lump Sum" then
                    TestField("Rebate Type", "Rebate Type"::"Lump Sum");
            end;
        }
        field(70; "Unit of Measure Code"; Code[10])
        {
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>

                //<ENRE1.00>
                if "Rebate Type" = "Rebate Type"::Commodity then begin
                    Error(gText008, FieldCaption("Unit of Measure Code"), "Rebate Type");
                end;
                //</ENRE1.00>
            end;
        }
        field(80; "Minimum Quantity (Base)"; Decimal)
        {
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>

                if "Minimum Quantity (Base)" <> 0 then
                    TestField("Calculation Basis", "Calculation Basis"::"($)/Unit");
            end;
        }
        field(81; "Maximum Quantity (Base)"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                TestField("Calculation Basis", "Calculation Basis"::"($)/Unit");
                //</ENRE1.00>
            end;
        }
        field(85; "Minimum Amount"; Decimal)
        {
            DecimalPlaces = 2 : 5;

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>
            end;
        }
        field(86; "Maximum Amount"; Decimal)
        {
            DecimalPlaces = 2 : 5;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin
                TestField("Job No.", '');  //<ENRE1.00>
            end;
        }
        field(90; "Rebate Value"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                //<ENRE1.00>
                //<ENRE1.00>
                if (
                  (not CheckUseParent)
                ) then begin
                    TestField("Job No.", '');
                end;
                //</ENRE1.00>
                //</ENRE1.00>

                if "Calculation Basis" = "Calculation Basis"::"Pct. Sale($)" then
                    if "Rebate Value" > 100 then
                        Error(gconText002, Code, '%');

                //<ENRE1.00>
                if "Rebate Type" = "Rebate Type"::Commodity then begin
                    Error(gText008, FieldCaption("Rebate Value"), "Rebate Type");
                end;
                //</ENRE1.00>
            end;
        }
        field(100; "Currency Code"; Code[10])
        {
            TableRelation = Currency;

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>

                //<ENRE1.00>
                if "Rebate Type" = "Rebate Type"::Commodity then begin
                    Error(gText008, FieldCaption("Currency Code"), "Rebate Type");
                end;
                //</ENRE1.00>

                if "Currency Code" <> '' then
                    TestField("Calculation Basis", "Calculation Basis"::"($)/Unit");
            end;
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
            Description = 'ENRE1.00';
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
            Description = 'ENRE1.00';
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
            Description = 'ENRE1.00';
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

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>

                if "Rebate Category Code" <> xRec."Rebate Category Code" then begin
                    if grecRebateCategory.Get("Rebate Category Code") then begin
                        DefRebateCategoryFields;
                    end;
                end;
            end;
        }
        field(150; "Rebate Type"; Option)
        {
            OptionCaption = 'Off-Invoice,Everyday,Lump Sum," ",Commodity';
            OptionMembers = "Off-Invoice",Everyday,"Lump Sum"," ",Commodity;

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>

                if "Rebate Type" <> xRec."Rebate Type" then begin
                    Clear("Calculation Basis");
                    Clear("Post to Sub-Ledger");
                end;

                if "Rebate Type" = "Rebate Type"::"Lump Sum" then begin
                    "Calculation Basis" := "Calculation Basis"::"Lump Sum";
                    Clear("End Date");
                    Clear("Unit of Measure Code");
                    Clear("Minimum Quantity (Base)");
                end;

                //<ENRE1.00>
                if "Rebate Type" = "Rebate Type"::Commodity then begin
                    "Calculation Basis" := "Calculation Basis"::Commodity;
                    Clear("Unit of Measure Code");
                    Clear("Currency Code");
                    Clear("Rebate Value");
                end;
                //</ENRE1.00>
            end;
        }
        field(160; "Post to Sub-Ledger"; Option)
        {
            OptionMembers = Post,"Do Not Post";

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>

                if "Post to Sub-Ledger" = "Post to Sub-Ledger"::"Do Not Post" then
                    if "Rebate Type" = "Rebate Type"::"Lump Sum" then
                        FieldError("Rebate Type");

                //<ENRE1.00>
                if ("Post to Sub-Ledger" = "Post to Sub-Ledger"::"Do Not Post") and
                   ("Rebate Type" = "Rebate Type"::Commodity) then begin
                    Error(gText007, FieldCaption("Post to Sub-Ledger"), "Post to Sub-Ledger",
                                     FieldCaption("Rebate Type"), "Rebate Type");
                end;
                //</ENRE1.00>

                if "Post to Sub-Ledger" = "Post to Sub-Ledger"::Post then
                    "Offset G/L Account No." := '';
            end;
        }
        field(170; "Offset G/L Account No."; Code[20])
        {
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>
            end;
        }
        field(180; "Include In Unit Price on Print"; Boolean)
        {

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>
            end;
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

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>

                if "Apply-To Customer Type" <> "Apply-To Customer Type"::" " then
                    if not CanUseApplyToFilters then
                        Error(gconText003);

                if "Apply-To Customer Type" <> xRec."Apply-To Customer Type" then begin
                    Clear("Apply-To Customer No.");
                    Clear("Apply-To Customer Ship-To Code");
                    Clear("Apply-To Cust. Group Type");
                    Clear("Apply-To Cust. Group Code");
                end;
            end;
        }
        field(210; "Apply-To Customer No."; Code[20])
        {
            TableRelation = Customer;

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>

                if "Apply-To Customer No." <> '' then begin
                    if not CanUseApplyToFilters then
                        Error(gconText003);

                    TestField("Apply-To Customer Type", "Apply-To Customer Type"::Specific);
                end;

                if "Apply-To Customer No." <> xRec."Apply-To Customer No." then begin
                    Clear("Apply-To Customer Ship-To Code");
                end;
            end;
        }
        field(215; "Apply-To Customer Ship-To Code"; Code[10])
        {
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Apply-To Customer No."));

            trigger OnValidate()
            var
                lrecShipTo: Record "Ship-to Address";
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>

                if "Apply-To Customer Ship-To Code" <> '' then begin
                    if not CanUseApplyToFilters then
                        Error(gconText003);

                    TestField("Apply-To Customer No.");
                    TestField("Apply-To Customer Type", "Apply-To Customer Type"::Specific);

                    lrecShipTo.Get("Apply-To Customer No.", "Apply-To Customer Ship-To Code");
                end;
            end;
        }
        field(220; "Apply-To Cust. Group Type"; Option)
        {
            OptionCaption = ' ,Rebate Group';
            OptionMembers = " ","Rebate Group";

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>

                if "Apply-To Cust. Group Type" <> "Apply-To Cust. Group Type"::" " then begin
                    if not CanUseApplyToFilters then
                        Error(gconText003);
                end;

                if "Apply-To Cust. Group Type" <> xRec."Apply-To Cust. Group Type" then begin
                    Clear("Apply-To Cust. Group Code");
                end;
            end;
        }
        field(230; "Apply-To Cust. Group Code"; Code[20])
        {
            TableRelation = IF ("Apply-To Cust. Group Type" = CONST("Rebate Group")) "Rebate Group ELA".Code;

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>

                if "Apply-To Cust. Group Code" <> '' then begin
                    if not CanUseApplyToFilters then
                        Error(gconText003);

                    TestField("Apply-To Customer Type", "Apply-To Customer Type"::Group);
                    TestField("Apply-To Cust. Group Type");
                end;
            end;
        }
        field(240; "External Reference No."; Code[20])
        {

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>
            end;
        }
        field(250; "Functional Area Filter"; Option)
        {
            Description = 'ENRE1.00';
            FieldClass = FlowFilter;
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(260; "Source Type Filter"; Option)
        {
            Description = 'ENRE1.00';
            FieldClass = FlowFilter;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Posted Invoice,Posted Cr. Memo,Customer,Vendor';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Posted Invoice","Posted Cr. Memo",Customer,Vendor;
        }
        field(270; "Source No. Filter"; Code[20])
        {
            Description = 'ENRE1.00';
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
            Description = 'ENRE1.00';
            FieldClass = FlowFilter;
        }
        field(290; "Post to Cust. Buying Group"; Boolean)
        {
            Caption = 'Post to Customer Buying Group';
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>
            end;
        }
        field(300; "Custom Value 1"; Code[20])
        {
            Caption = 'Custom Value 1';

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>
            end;
        }
        field(310; "Custom Value 2"; Code[20])
        {
            Caption = 'Custom Value 2';

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>
            end;
        }
        field(320; "Custom Value 3"; Code[20])
        {
            Caption = 'Custom Value 3';

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>
            end;
        }
        field(330; "Custom Value 4"; Code[20])
        {
            Caption = 'Custom Value 4';

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>
            end;
        }
        field(340; "Custom Value 5"; Code[20])
        {
            Caption = 'Custom Value 5';

            trigger OnValidate()
            begin
                //<ENRE1.00>
                TestField("Job No.", '');
                //</ENRE1.00>
            end;
        }
        field(350; Comment; Boolean)
        {
            CalcFormula = Exist("Rebate Comment Line ELA" WHERE("Rebate Code" = FIELD(Code)));
            Caption = 'Comment';
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(351; Blocked; Boolean)
        {
            Description = 'ENRE1.00';
        }
        field(360; "Job No."; Code[20])
        {
            Description = 'ENRE1.00';
            Editable = false;
            TableRelation = Job;
        }
        field(361; "Job Task No."; Code[20])
        {
            Description = 'ENRE1.00';
            Editable = false;
            TableRelation = "Job Task"."Job Task No." WHERE("Job No." = FIELD("Job No."));
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
            MaintainSIFTIndex = false;
        }
        key(Key2; "Start Date", "End Date", "Rebate Type", Blocked)
        {
            MaintainSIFTIndex = false;
        }
        key(Key3; "Apply-To Customer Type", "Apply-To Customer No.", "Apply-To Customer Ship-To Code", "Apply-To Cust. Group Type", "Apply-To Cust. Group Code", "Start Date", "End Date", "Rebate Type")
        {
            MaintainSIFTIndex = false;
        }
        key(Key4; "External Reference No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
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
        //<ENRE1.00>
        TestField("Job No.", '');
        //</ENRE1.00>

        grecPostedRebateDetail.Reset;
        grecPostedRebateDetail.SetRange("Rebate Code", Code);
        if not grecPostedRebateDetail.IsEmpty then
            Error(gText004, Code);

        grecRebateDetail.Reset;
        grecRebateDetail.SetRange("Rebate Code", Code);
        grecRebateDetail.DeleteAll;
    end;

    trigger OnInsert()
    var
        lrecSalesSetup: Record "Sales & Receivables Setup";
        lcduNoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if Code = '' then begin
            lrecSalesSetup.Get;
            lrecSalesSetup.TestField("Rebate Nos. ELA");
            lcduNoSeriesMgt.InitSeries(lrecSalesSetup."Rebate Nos. ELA", xRec."No. Series", 0D, Code, "No. Series");
        end;

        //<ENRE1.00>
        grecSalesSetup.Get;

        "Post to Cust. Buying Group" := grecSalesSetup."Post Rbt to Cust Buy Grp ELA";
        //</ENRE1.00>
    end;

    trigger OnRename()
    begin
        Error(gconText001);
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        gconText001: Label 'You cannot rename a Rebate.';
        grecRebateDetail: Record "Rebate Line ELA";
        gconText002: Label 'Rebate value for %1 cannot be greater than 100.';
        grecPostedRebateDetail: Record "Rebate Ledger Entry ELA";
        grecRebateCategory: Record "Rebate Category ELA";
        grecSalesSetup: Record "Sales & Receivables Setup";
        gconText003: Label 'Rebate Header Apply-To Filters are not activated in Sales & Receivables Setup';
        gText004: Label 'You cannot delete Rebate No. %1. It has Posted Rebate Details.';
        gText005: Label 'Start Date must not be greater than End Date.';
        gText006: Label 'You cannot make changes or delete this rebate since it is linked to a promotinal job.';
        grecUseJobTask: Record "Job Task";
        gblnUseParent: Boolean;
        gText007: Label '%1 cannot be %2 when %3 is %4.';
        gText008: Label '%1 cannot be modified for Rebate Type %2.';


    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
    end;


    procedure AssistEdit(precOldRebate: Record "Rebate Header ELA"): Boolean
    var
        lrecRebate: Record "Rebate Header ELA";
        lcduNoSeriesMgt: Codeunit NoSeriesManagement;
    begin

        lrecRebate := Rec;
        grecSalesSetup.Get;
        grecSalesSetup.TestField(grecSalesSetup."Rebate Nos. ELA");
        if lcduNoSeriesMgt.SelectSeries(grecSalesSetup."Rebate Nos. ELA", precOldRebate."No. Series", "No. Series") then begin
            lcduNoSeriesMgt.SetSeries(Code);
            Rec := lrecRebate;
            exit(true);
        end;

    end;


    procedure CanUseApplyToFilters(): Boolean
    begin
        grecSalesSetup.Get;
        exit(grecSalesSetup."Use RbtHdr AppliesTo Filt ELA");
    end;


    procedure DefRebateCategoryFields()
    var
        lrecItemUOM: Record "Item Unit of Measure";
        lrecItemCatProp: Record "Category Default Property ELA";
        JMText001: Label 'This Item has properties associated with it.  Do you wish to delete these properties and accept the default properties associated with the new Item Category?';
    begin
        //<ENRE1.00>
        if (
          (grecRebateCategory."Rebate Type" = grecRebateCategory."Rebate Type"::"Sales-Based")
        ) then begin
            grecRebateCategory.FieldError("Rebate Type");
        end;
        if (
          (grecRebateCategory."Calculation Basis" = grecRebateCategory."Calculation Basis"::"Guaranteed Cost Deal")
        ) then begin
            grecRebateCategory.FieldError("Calculation Basis");
        end;
        //</ENRE1.00>
        Validate("Rebate Type", grecRebateCategory."Rebate Type");
        Validate("Calculation Basis", grecRebateCategory."Calculation Basis");
        Validate("Unit of Measure Code", grecRebateCategory."Unit of Measure Code");
        Validate("Minimum Quantity (Base)", grecRebateCategory."Minimum Quantity (Base)");
        Validate("Currency Code", grecRebateCategory."Currency Code");
        Validate("Post to Sub-Ledger", grecRebateCategory."Post to Sub-Ledger");
        Validate("Expense G/L Account No.", grecRebateCategory."Expense G/L Account No.");
        Validate("Offset G/L Account No.", grecRebateCategory."Offset G/L Account No.");
    end;


    procedure CancelRebate()
    var
        lrecRebate: Record "Rebate Header ELA";
    begin
        //<ENRE1.00>
        TestField("Job No.", '');
        //</ENRE1.00>

        //<ENRE1.00>
        lrecRebate.SetRange(Code, Code);

        REPORT.RunModal(REPORT::"Cancel Rebate ELA", true, false, lrecRebate);

        Reset;
        //</ENRE1.00>
    end;


    procedure ShowStatistics()
    begin
        //<ENRE1.00>
        if Code <> '' then begin
            case "Post to Sub-Ledger" of
                "Post to Sub-Ledger"::Post:
                    begin
                        PAGE.RunModal(14229450, Rec); //8822
                    end;
                "Post to Sub-Ledger"::"Do Not Post":
                    begin
                        PAGE.RunModal(14229451, Rec);
                    end;
            end;
        end;
        //</ENRE1.00>
    end;


    procedure SetUpdateFromParent(precJobTask: Record "Job Task")
    begin
        //<ENRE1.00>
        grecUseJobTask := precJobTask;
        gblnUseParent := true;
        //</ENRE1.00>
    end;

    local procedure CheckUseParent() pbln: Boolean
    begin
        //<ENRE1.00>
        if (
          (not gblnUseParent)
        ) then begin
            exit(false);
        end;

        if (
          (grecUseJobTask."Job No." = "Job No.")
          and (grecUseJobTask."Job Task No." = "Job Task No.")
        ) then begin
            exit(true)
        end else begin
            exit(false);
        end;
        //</ENRE1.00>
    end;


    procedure ClearUpdateFromParent()
    begin
        //<ENRE1.00>
        grecUseJobTask.Reset;
        Clear(grecUseJobTask);
        Clear(gblnUseParent);
        //</ENRE1.00>
    end;
}

