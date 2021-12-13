table 14229427 "Purchase Rebate Header ELA"
{

    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //   20110810 - Modified Field
    //              - Added option Guranteed Cost Deal to Rebate Type
    //            - Modified Function
    //              - Rebate Type - OnValidate
    //              - DefRebateCategoryFields
    // 
    // ENRE1.00
    //   20110831 - New Fields
    //              - Maximum Quantity (Base)
    //              - Maximum Amount
    // 
    // ENRE1.00
    //   20111108
    //     - removed Rebate Type ::"Guaranteed Cost Deal" option; replaced with "Sales-Based"
    //     - new fn UpdatePurchaseRebateCust when Start Date / End Date are updated
    //     - new "Calculation Basis"::Guaranteed Cost Deal option
    // 
    // ENRE1.00
    //   20120323 - new field
    //              360 Sales Profit Modifier
    // 


    DrillDownPageID = "Purchase Rebate List ELA";
    LookupPageID = "Purchase Rebate List ELA";

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
                if Code <> xRec.Code then begin
                    lrecSalesSetup.Get;
                    lcduNoSeriesMgt.TestManual(lrecSalesSetup."Rebate Nos. ELA");
                    "No. Series" := '';
                end;
            end;
        }
        field(20; Description; Text[50])
        {
        }
        field(30; "Start Date"; Date)
        {

            trigger OnValidate()
            begin
                if ("Start Date" > "End Date") and ("End Date" <> 0D) then begin
                    Error(gText005);
                end;

                //<ENRE1.00>
                UpdatePurchaseRebateCust(FieldNo("Start Date"));
                //</ENRE1.00>
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

                //<ENRE1.00>
                UpdatePurchaseRebateCust(FieldNo("End Date"));
                //</ENRE1.00>
            end;
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

            trigger OnValidate()
            var
                ltxc0001: Label 'Calculation Basis must be ($)/Unit when Rebate Type is Guranteed Cost Deal.';
                lrecPurchRebateDetail: Record "Purchase Rebate Line ELA";
            begin
                if ("Calculation Basis" = "Calculation Basis"::"Pct. Purch.($)") and ("Rebate Value" > 100) then begin
                    Error(gconText002, Code);
                end;
                if "Calculation Basis" = "Calculation Basis"::"Pct. Purch.($)" then begin
                    Clear("Minimum Quantity (Base)");
                    Clear("Currency Code");
                    Clear("Unit of Measure Code");
                end;
                if "Calculation Basis" = "Calculation Basis"::"Lump Sum" then
                    TestField("Rebate Type", "Rebate Type"::"Lump Sum");

                //<ENRE1.00>
                if "Calculation Basis" = "Calculation Basis"::"Guaranteed Cost Deal" then begin
                    Clear("Unit of Measure Code");
                    Clear("Rebate Value");
                    Clear("Currency Code");
                    Clear("Apply-To Vendor Group Code");
                end;

                if ("Calculation Basis" <> "Calculation Basis"::"Guaranteed Cost Deal")
                  and (xRec."Calculation Basis" = xRec."Calculation Basis"::"Guaranteed Cost Deal") then begin
                    lrecPurchRebateDetail.Reset;
                    lrecPurchRebateDetail.SetRange("Purchase Rebate Code", Code);
                    if lrecPurchRebateDetail.FindSet then
                        repeat
                            lrecPurchRebateDetail.TestField("Guaranteed Unit Cost (LCY)", 0);
                            lrecPurchRebateDetail.TestField("Guaranteed Cost UOM Code", '');
                        until lrecPurchRebateDetail.Next = 0;
                end;
                //</ENRE1.00>

                //<ENRE1.00> - deleted code
            end;
        }
        field(70; "Unit of Measure Code"; Code[10])
        {
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            begin
                //<ENRE1.00>
                if "Unit of Measure Code" <> '' then begin

                    //<ENRE1.00>
                    if (
                      ("Calculation Basis" = "Calculation Basis"::"Guaranteed Cost Deal")
                    ) then begin
                        FieldError("Calculation Basis");
                    end;
                    //</ENRE1.00>

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
                if "Minimum Quantity (Base)" <> 0 then begin
                    if not ("Calculation Basis" in ["Calculation Basis"::"($)/Unit", "Calculation Basis"::"Guaranteed Cost Deal"]) then begin
                        FieldError("Calculation Basis");
                    end;
                end;
                //</ENRE1.00>
            end;
        }
        field(81; "Maximum Quantity (Base)"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin
                //<ENRE1.00>
                if "Maximum Quantity (Base)" <> 0 then begin
                    if not ("Calculation Basis" in ["Calculation Basis"::"($)/Unit", "Calculation Basis"::"Guaranteed Cost Deal"]) then begin
                        FieldError("Calculation Basis");
                    end;
                end;
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

            trigger OnValidate()
            begin
                if "Calculation Basis" = "Calculation Basis"::"Pct. Purch.($)" then
                    if "Rebate Value" > 100 then
                        Error(gconText002, Code, '%');

                //<ENRE1.00>
                if "Rebate Value" <> 0 then begin

                    //<ENRE1.00>
                    if (
                      ("Calculation Basis" = "Calculation Basis"::"Guaranteed Cost Deal")
                    ) then begin
                        FieldError("Calculation Basis");
                    end;
                    //</ENRE1.00>

                end;
                //</ENRE1.00>
            end;
        }
        field(100; "Currency Code"; Code[10])
        {
            TableRelation = Currency;

            trigger OnValidate()
            begin
                if "Currency Code" <> '' then
                    TestField("Calculation Basis", "Calculation Basis"::"($)/Unit");

                //<ENRE1.00>
                if "Currency Code" <> '' then begin

                    //<ENRE1.00>
                    if (
                      ("Calculation Basis" = "Calculation Basis"::"Guaranteed Cost Deal")
                    ) then begin
                        FieldError("Calculation Basis");
                    end;
                    //</ENRE1.00>

                end;
                //</ENRE1.00>
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
                                                                          "Paid-by Vendor" = CONST(false),
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
                                                                          "Paid-by Vendor" = CONST(false),
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
                                                                          "Paid-by Vendor" = CONST(true),
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

            trigger OnValidate()
            begin
                if "Rebate Category Code" <> xRec."Rebate Category Code" then begin
                    if grecRebateCategory.Get("Rebate Category Code") then begin
                        DefRebateCategoryFields;
                    end;
                end;
            end;
        }
        field(150; "Rebate Type"; Option)
        {
            OptionCaption = 'Off-Invoice,Everyday,Lump Sum,Sales-Based';
            OptionMembers = "Off-Invoice",Everyday,"Lump Sum","Sales-Based";

            trigger OnValidate()
            begin
                if "Rebate Type" <> xRec."Rebate Type" then
                    Clear("Calculation Basis");
                if "Rebate Type" = "Rebate Type"::"Lump Sum" then begin
                    "Calculation Basis" := "Calculation Basis"::"Lump Sum";
                    Clear("End Date");
                    Clear("Unit of Measure Code");
                    Clear("Minimum Quantity (Base)");
                    //<ENRE1.00>
                end;
                // move to "Calculation Basis"
                // - deleted code
                //</ENRE1.00>


                //<ENRE1.00>
                if (
                  ("Rebate Type" <> "Rebate Type"::"Sales-Based")
                ) then begin
                    TestPurchRebateCustIsEmpty;
                end;
                //</ENRE1.00>

                //<ENRE1.00>
                if "Rebate Type" <> xRec."Rebate Type" then begin
                    if "Rebate Type" = "Rebate Type"::"Sales-Based" then begin
                        "Sales Profit Modifier" := true;
                    end else begin
                        "Sales Profit Modifier" := false;
                    end;
                end;
                //</ENRE1.00>
            end;
        }
        field(160; "Post to Sub-Ledger"; Option)
        {
            OptionCaption = 'Post,Do Not Post';
            OptionMembers = Post,"Do Not Post";

            trigger OnValidate()
            begin
                if "Post to Sub-Ledger" = "Post to Sub-Ledger"::Post then
                    "Offset G/L Account No." := '';
            end;
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

            trigger OnValidate()
            begin
                if "Apply-To Vendor No." <> '' then begin
                    if not CanUseApplyToFilters then
                        Error(gconText003);
                end;
                if "Apply-To Vendor No." <> xRec."Apply-To Vendor No." then begin
                    Clear("Apply-To Order Address Code");
                end;
            end;
        }
        field(215; "Apply-To Order Address Code"; Code[10])
        {
            TableRelation = "Order Address".Code WHERE("Vendor No." = FIELD("Apply-To Vendor No."));

            trigger OnValidate()
            var
                lrecOrderAddress: Record "Order Address";
            begin
                if "Apply-To Order Address Code" <> '' then begin
                    if not CanUseApplyToFilters then
                        Error(gconText003);
                    TestField("Apply-To Vendor No.");
                    lrecOrderAddress.Get("Apply-To Vendor No.", "Apply-To Order Address Code");
                end;
            end;
        }
        field(230; "Apply-To Vendor Group Code"; Code[20])
        {
            TableRelation = "Rebate Group ELA".Code;

            trigger OnValidate()
            begin
                if "Apply-To Vendor Group Code" <> '' then begin
                    if not CanUseApplyToFilters then
                        Error(gconText003);
                end;
            end;
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
            MaintainSIFTIndex = false;
        }
        key(Key2; "Start Date", "End Date", "Rebate Type", Blocked)
        {
            MaintainSIFTIndex = false;
        }
        key(Key3; "Apply-To Vendor No.", "Apply-To Order Address Code", "Apply-To Vendor Group Code", "Start Date", "End Date", "Rebate Type")
        {
            MaintainSIFTIndex = false;
        }
        key(Key4; "External Reference No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        lrecPurchRebateCust: Record "Purchase Rebate Customer ELA";
    begin
        grecPostedRebateDetail.Reset;
        grecPostedRebateDetail.SetRange("Rebate Code", Code);
        if not grecPostedRebateDetail.IsEmpty then
            Error(gText004, Code);

        grecRebateDetail.Reset;
        grecRebateDetail.SetRange("Purchase Rebate Code", Code);
        grecRebateDetail.DeleteAll;

        grecPurchRebateCommentLine.Reset;
        grecPurchRebateCommentLine.SetRange("Purchase Rebate Code", Code);
        grecPurchRebateCommentLine.DeleteAll;

        //<ENRE1.00>
        if (
          ("Rebate Type" = "Rebate Type"::"Sales-Based")
        ) then begin
            lrecPurchRebateCust.SetRange("Purchase Rebate Code", Code);
            if (
              (not lrecPurchRebateCust.IsEmpty)
            ) then begin
                lrecPurchRebateCust.DeleteAll;
            end;
        end;
        //</ENRE1.00>
    end;

    trigger OnInsert()
    var
        lrecPurchSetup: Record "Purchases & Payables Setup";
        lcduNoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if Code = '' then begin
            lrecPurchSetup.Get;
            lrecPurchSetup.TestField("Rebate Nos.");
            lcduNoSeriesMgt.InitSeries(lrecPurchSetup."Rebate Nos.", xRec."No. Series", 0D, Code, "No. Series");
        end;
        grecPurchSetup.Get;
        "Post to Vendor Buying Group" := grecPurchSetup."Post Rbt to Vend Buy Group ELA";
    end;

    trigger OnRename()
    begin
        Error(gconText001);
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        gconText001: Label 'You cannot rename a Rebate.';
        grecRebateDetail: Record "Purchase Rebate Line ELA";
        gconText002: Label 'Rebate value for %1 cannot be greater than 100.';
        grecPostedRebateDetail: Record "Rebate Ledger Entry ELA";
        grecRebateCategory: Record "Rebate Category ELA";
        grecPurchSetup: Record "Purchases & Payables Setup";
        gconText003: Label 'Rebate Header Apply-To Filters are not activated in Sales & Receivables Setup';
        gText004: Label 'You cannot delete Rebate No. %1. It has Posted Rebate Details.';
        gText005: Label 'Start Date must not be greater than End Date.';
        gText006: Label 'You cannot make changes or delete this rebate since it is linked to a promotinal job.';
        grecPurchRebateCommentLine: Record "Purchase Rbt Comment Line ELA";
        gText007: Label '%1 must not be equal to %2 for %3 %4.';


    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
    end;


    procedure AssistEdit(precOldRebate: Record "Purchase Rebate Header ELA"): Boolean
    var
        lrecRebate: Record "Purchase Rebate Header ELA";
        lcduNoSeriesMgt: Codeunit NoSeriesManagement;
    begin

        lrecRebate := Rec;
        grecPurchSetup.Get;
        grecPurchSetup.TestField(grecPurchSetup."Rebate Nos.");
        if lcduNoSeriesMgt.SelectSeries(grecPurchSetup."Rebate Nos.", precOldRebate."No. Series", "No. Series") then begin
            lcduNoSeriesMgt.SetSeries(Code);
            Rec := lrecRebate;
            exit(true);
        end;

    end;


    procedure CanUseApplyToFilters(): Boolean
    begin
        grecPurchSetup.Get;
        exit(true);
    end;


    procedure DefRebateCategoryFields()
    var
        lrecItemUOM: Record "Item Unit of Measure";
        lrecItemCatProp: Record "Category Default Property ELA";
        JMText001: Label 'This Item has properties associated with it.  Do you wish to delete these properties and accept the default properties associated with the new Item Category?';
    begin
        //<ENRE1.00>
        if (
          (grecRebateCategory."Rebate Type" = grecRebateCategory."Rebate Type"::Commodity)
        ) then begin
            grecRebateCategory.FieldError("Rebate Type");
        end;
        if (
          (grecRebateCategory."Calculation Basis" = grecRebateCategory."Calculation Basis"::Commodity)
        ) then begin
            grecRebateCategory.FieldError("Calculation Basis");
        end;
        //</ENRE1.00>
        Validate("Rebate Type", grecRebateCategory."Rebate Type");
        Validate("Calculation Basis", grecRebateCategory."Calculation Basis");
        if grecRebateCategory."Calculation Basis" <> grecRebateCategory."Calculation Basis"::"Guaranteed Cost Deal" then
            Validate("Unit of Measure Code", grecRebateCategory."Unit of Measure Code");
        Validate("Minimum Quantity (Base)", grecRebateCategory."Minimum Quantity (Base)");
        Validate("Currency Code", grecRebateCategory."Currency Code");
        Validate("Post to Sub-Ledger", grecRebateCategory."Post to Sub-Ledger");
        Validate("Credit G/L Account No.", grecRebateCategory."Expense G/L Account No.");
        Validate("Offset G/L Account No.", grecRebateCategory."Offset G/L Account No.");
    end;


    procedure CancelRebate()
    var
        lrecPurchRebate: Record "Purchase Rebate Header ELA";
    begin
        lrecPurchRebate.SetRange(Code, Code);
        REPORT.RunModal(REPORT::"Cancel Purchase Rebate ELA", true, false, lrecPurchRebate);
        Reset;
    end;


    procedure ShowStatistics()
    begin
        if Code <> '' then begin
            case "Post to Sub-Ledger" of
                "Post to Sub-Ledger"::Post:
                    begin
                        PAGE.RunModal(14229438, Rec);
                    end;
                "Post to Sub-Ledger"::"Do Not Post":
                    begin
                        PAGE.RunModal(14229437, Rec);
                    end;
            end;
        end;
    end;


    procedure UpdatePurchaseRebateCust(pintFieldNo: Integer)
    var
        lrecPurchaseRebateCustomer: Record "Purchase Rebate Customer ELA";
    begin
        //<ENRE1.00>

        if (
          ("Rebate Type" <> "Rebate Type"::"Sales-Based")
        ) then begin
            exit;
        end;

        TestField(Code);

        lrecPurchaseRebateCustomer.SetRange("Purchase Rebate Code", Code);

        if (
          (lrecPurchaseRebateCustomer.IsEmpty)
        ) then begin
            exit;
        end;

        lrecPurchaseRebateCustomer.FindSet(true, false);

        repeat

            case pintFieldNo of
                FieldNo("Start Date"):
                    begin
                        if (
                          (lrecPurchaseRebateCustomer."Rebate Start Date" <> "Start Date")
                        ) then begin
                            lrecPurchaseRebateCustomer.Validate("Rebate Start Date", "Start Date");
                            lrecPurchaseRebateCustomer.Modify(true);
                        end;
                    end;
                FieldNo("End Date"):
                    begin
                        if (
                          (lrecPurchaseRebateCustomer."Rebate End Date" <> "End Date")
                        ) then begin
                            lrecPurchaseRebateCustomer.Validate("Rebate End Date", "End Date");
                            lrecPurchaseRebateCustomer.Modify(true);
                        end;
                    end;
                else
            //
            end;

        until lrecPurchaseRebateCustomer.Next = 0;

        //</ENRE1.00>
    end;


    procedure TestPurchRebateCustIsEmpty()
    var
        lrecPurchaseRebateCustomer: Record "Purchase Rebate Customer ELA";
        lText030: Label '%1 entries may not exist for %2 %3.';
    begin
        //<ENRE1.00>

        if (
          (Code = '')
        ) then begin
            exit;
        end;

        lrecPurchaseRebateCustomer.SetRange("Purchase Rebate Code", Code);

        if (
          (not lrecPurchaseRebateCustomer.IsEmpty)
        ) then begin
            // %1 entries may not exist for %2 %3.
            Error(lText030, lrecPurchaseRebateCustomer.TableCaption,
                               TableCaption,
                               Code);
        end;

        //</ENRE1.00>
    end;
}

