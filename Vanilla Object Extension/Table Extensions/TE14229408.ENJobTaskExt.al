tableextension 14229408 "Job Task ELA" extends "Job Task"
{
    //ENRE1.00 2021-09-08 AJ
    fields
    {
        // Add changes to table fields here
        field(14228800; "No. of Rebates ELA"; Integer)
        {
            Caption = 'No. of Rebates';
            CalcFormula = Count("Rebate Header ELA" WHERE("Job No." = FIELD("Job No."),
                                                       "Job Task No." = FIELD("Job Task No.")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14228801; "Rebate Category Code ELA"; Code[20])
        {
            Caption = 'Rebate Category Code';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Editable = false;
            TableRelation = "Rebate Category ELA".Code WHERE("Calculation Basis" = CONST("($)/Unit"));

            trigger OnValidate()
            var
                lrecRebateCat: Record "Rebate Category ELA";
            begin

                if "Rebate Category Code ELA" <> '' then begin
                    TestField("Job Task Type", "Job Task Type"::Posting);
                    VerifyJobIsPromotion;

                    GetJob;
                    lrecRebateCat.Get("Rebate Category Code ELA");

                    //-- Enforce currency
                    grecJob.TestField("Currency Code", lrecRebateCat."Currency Code");

                    "Expense G/L Account No. ELA" := lrecRebateCat."Expense G/L Account No.";
                    "Unit of Measure Code ELA" := lrecRebateCat."Unit of Measure Code";
                    "Minimum Quantity (Base) ELA" := lrecRebateCat."Minimum Quantity (Base)";
                    "Rebate Type ELA" := lrecRebateCat."Rebate Type" + 1;     //-- add 1 because field on this table has a blank at start
                    "Post to Sub-Ledger ELA" := lrecRebateCat."Post to Sub-Ledger" + 1; //-- add 1 because field on this table has a blank at start
                    "Offset G/L Account No. ELA" := lrecRebateCat."Offset G/L Account No.";
                    "Starting Date ELA" := grecJob."Starting Date";
                    "Ending Date ELA" := grecJob."Ending Date";
                    "Minimum Amount ELA" := 0;
                    "Post to Cust. Buying Group ELA" := false;
                end else begin
                    Clear("Expense G/L Account No. ELA");
                    Clear("Quantity ELA");
                    Clear("Unit of Measure Code ELA");
                    Clear("Minimum Quantity (Base) ELA");
                    Clear("Rebate Type ELA");
                    Clear("Post to Sub-Ledger ELA");
                    Clear("Offset G/L Account No. ELA");
                    Clear("Starting Date ELA");
                    Clear("Ending Date ELA");
                    Clear("Minimum Amount ELA");
                    Clear("Post to Cust. Buying Group ELA");
                end;



                Clear(grecJob);
                if "Job No." <> '' then
                    if grecJob.Get("Job No.") then
                        if not grecJob.CheckOpenStatus(grecJob) then
                            Error(gtxt001, grecJob."No.");

                if "No. of Rebates ELA" <> 0 then
                    Error(jgftxt009, FieldCaption("Rebate Category Code ELA"));

            end;
        }
        field(14228802; "Expense G/L Account No. ELA"; Code[20])
        {
            Caption = 'Expense G/L Account No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "G/L Account";

            trigger OnValidate()
            var
                lrecGLAcct: Record "G/L Account";
            begin

                TestField("Job Task Type", "Job Task Type"::Posting);



                Clear(grecJob);
                if "Job No." <> '' then
                    if grecJob.Get("Job No.") then
                        if not grecJob.CheckOpenStatus(grecJob) then
                            Error(gtxt001, grecJob."No.");

                if "No. of Rebates ELA" <> 0 then
                    Error(jgftxt009, FieldCaption("Expense G/L Account No. ELA"));

            end;
        }
        field(14228803; "Quantity ELA"; Decimal)
        {
            Caption = 'Quantity';
            BlankZero = true;
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                TestField("Job Task Type", "Job Task Type"::Posting);


                Clear(grecJob);
                if "Job No." <> '' then
                    if grecJob.Get("Job No.") then
                        if not grecJob.CheckOpenStatus(grecJob) then
                            Error(gtxt001, grecJob."No.");



                UpdatePromoPlanningLines(FieldNo("Quantity ELA"));
                UpdateRebates(FieldNo("Quantity ELA"));

            end;
        }
        field(14228804; "Unit of Measure Code ELA"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            begin

                TestField("Job Task Type", "Job Task Type"::Posting);
                VerifyJobIsPromotion;



                if "No. of Planning Lines ELA" <> 0 then
                    Error(jgftxt005, FieldCaption("Unit of Measure Code ELA"));
                if "No. of Rebates ELA" <> 0 then
                    Error(jgftxt009, FieldCaption("Unit of Measure Code ELA"));

                Clear(grecJob);
                if "Job No." <> '' then
                    if grecJob.Get("Job No.") then
                        if not grecJob.CheckOpenStatus(grecJob) then
                            Error(gtxt001, grecJob."No.");

            end;
        }
        field(14228805; "Minimum Quantity (Base) ELA"; Decimal)
        {
            Caption = 'Minimum Quantity (Base)';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                TestField("Job Task Type", "Job Task Type"::Posting);
                VerifyJobIsPromotion;


                if (("Rebate Type ELA" <> "Rebate Type ELA"::Everyday) or ("Rebate Type ELA" <> "Rebate Type ELA"::"Off-Invoice")) then
                    Error(jgftxt006);

                if "No. of Planning Lines ELA" <> 0 then
                    Error(jgftxt005, FieldCaption("Minimum Quantity (Base) ELA"));
                if "No. of Rebates ELA" <> 0 then
                    Error(jgftxt009, FieldCaption("Minimum Quantity (Base) ELA"));

                Clear(grecJob);
                if "Job No." <> '' then
                    if grecJob.Get("Job No.") then
                        if not grecJob.CheckOpenStatus(grecJob) then
                            Error(gtxt001, grecJob."No.");

            end;
        }
        field(14228806; "Rebate Type ELA"; Option)
        {
            Caption = 'Rebate Type';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            OptionMembers = " ","Off-Invoice",Everyday,"Lump Sum";

            trigger OnValidate()
            var
                ltxt001: Label 'Please remove ''Job Promotion Customer'' & ''Promotion Expense Ship-to Code'' before clearing rebate type field.';
                lrecjob: Record Job;
            begin

                TestField("Job Task Type", "Job Task Type"::Posting);
                VerifyJobIsPromotion;

                Clear(lrecjob);
                if lrecjob.Get("Job No.") then
                    if lrecjob."Promotion ELA" then
                        if (("Rebate Type ELA" <> "Rebate Type ELA"::" ") and
                          (xRec."Rebate Type ELA" = "Rebate Type ELA"::" ") and
                          ("Rebate Type ELA" <> xRec."Rebate Type ELA")) then
                            if (("Promotion Customer No. ELA" <> '') or ("Promotion Ship-to Code ELA" <> '')) then
                                Error(ltxt001);


                if "Rebate Type ELA" <> xRec."Rebate Type ELA" then
                    Clear("Post to Sub-Ledger ELA");


                if "No. of Planning Lines ELA" <> 0 then
                    Error(jgftxt005, FieldCaption("Rebate Type ELA"));
                if "No. of Rebates ELA" <> 0 then
                    Error(jgftxt009, FieldCaption("Rebate Type ELA"));

                Clear(grecJob);
                if "Job No." <> '' then
                    if grecJob.Get("Job No.") then
                        if not grecJob.CheckOpenStatus(grecJob) then
                            Error(gtxt001, grecJob."No.");

                if "Rebate Type ELA" = "Rebate Type ELA"::" " then begin
                    "Post to Cust. Buying Group ELA" := false;
                    Clear("Post to Sub-Ledger ELA");
                    Clear("Rebate Category Code ELA");
                    Clear("Starting Date ELA");
                    Clear("Ending Date ELA");
                end;

                if (xRec."Rebate Type ELA" = xRec."Rebate Type ELA"::"Off-Invoice") or (xRec."Rebate Type ELA" = xRec."Rebate Type ELA"::Everyday) then
                    if (Rec."Rebate Type ELA" <> xRec."Rebate Type ELA"::"Off-Invoice") or (Rec."Rebate Type ELA" <> xRec."Rebate Type ELA"::Everyday) then begin
                        Clear("Minimum Quantity (Base) ELA");
                        Clear(xRec."Minimum Amount ELA");
                    end;

            end;
        }
        field(14228807; "Post to Sub-Ledger ELA"; Option)
        {
            Caption = 'Post to Sub-Ledger';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            OptionCaption = ' ,Post,Do Not Post';
            OptionMembers = " ",Post,"Do Not Post";

            trigger OnValidate()
            begin

                TestField("Job Task Type", "Job Task Type"::Posting);
                VerifyJobIsPromotion;


                if "Post to Sub-Ledger ELA" = "Post to Sub-Ledger ELA"::"Do Not Post" then
                    if "Rebate Type ELA" = "Rebate Type ELA"::"Lump Sum" then
                        FieldError("Rebate Type ELA");


                if "No. of Planning Lines ELA" <> 0 then
                    Error(jgftxt005, FieldCaption("Post to Sub-Ledger ELA"));
                if "No. of Rebates ELA" <> 0 then
                    Error(jgftxt009, FieldCaption("Post to Sub-Ledger ELA"));

                Clear(grecJob);
                if "Job No." <> '' then
                    if grecJob.Get("Job No.") then
                        if not grecJob.CheckOpenStatus(grecJob) then
                            Error(gtxt001, grecJob."No.");

                if "Post to Sub-Ledger ELA" <> "Post to Sub-Ledger ELA"::" " then
                    if "Rebate Type ELA" = "Rebate Type ELA"::" " then
                        Error(jgftxt002);

            end;
        }
        field(14228808; "Offset G/L Account No. ELA"; Code[20])
        {
            Caption = 'Offset G/L Account No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin

                TestField("Job Task Type", "Job Task Type"::Posting);
                VerifyJobIsPromotion;



                if "No. of Planning Lines ELA" <> 0 then
                    Error(jgftxt005, FieldCaption("Offset G/L Account No. ELA"));
                if "No. of Rebates ELA" <> 0 then
                    Error(jgftxt009, FieldCaption("Offset G/L Account No. ELA"));

                Clear(grecJob);
                if "Job No." <> '' then
                    if grecJob.Get("Job No.") then
                        if not grecJob.CheckOpenStatus(grecJob) then
                            Error(gtxt001, grecJob."No.");

            end;
        }
        field(14228809; "Starting Date ELA"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                TestField("Job Task Type", "Job Task Type"::Posting);
                VerifyJobIsPromotion;

                CheckDate;





                Clear(grecJob);
                if "Job No." <> '' then
                    if grecJob.Get("Job No.") then
                        if not grecJob.CheckOpenStatus(grecJob) then
                            Error(gtxt001, grecJob."No.");





                UpdatePromoPlanningLines(FieldNo("Starting Date ELA"));
                UpdateRebates(FieldNo("Starting Date ELA"));

            end;
        }
        field(14228810; "Ending Date ELA"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                TestField("Job Task Type", "Job Task Type"::Posting);
                VerifyJobIsPromotion;

                CheckDate;



                Clear(grecJob);
                if "Job No." <> '' then
                    if grecJob.Get("Job No.") then
                        if not grecJob.CheckOpenStatus(grecJob) then
                            Error(gtxt001, grecJob."No.");


                UpdatePromoPlanningLines(FieldNo("Ending Date ELA"));
                UpdateRebates(FieldNo("Ending Date ELA"));

            end;
        }
        field(14228811; "Minimum Amount ELA"; Decimal)
        {
            Caption = 'Minimum Amount';
            DataClassification = ToBeClassified;
            DecimalPlaces = 2 : 5;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                TestField("Job Task Type", "Job Task Type"::Posting);
                VerifyJobIsPromotion;

                if "No. of Planning Lines ELA" <> 0 then
                    Error(jgftxt005, FieldCaption("Minimum Amount ELA"));
                if "No. of Rebates ELA" <> 0 then
                    Error(jgftxt009, FieldCaption("Minimum Amount ELA"));

                Clear(grecJob);
                if "Job No." <> '' then
                    if grecJob.Get("Job No.") then
                        if not grecJob.CheckOpenStatus(grecJob) then
                            Error(gtxt001, grecJob."No.");

                if (("Rebate Type ELA" <> "Rebate Type ELA"::Everyday) or ("Rebate Type ELA" <> "Rebate Type ELA"::"Off-Invoice")) then
                    Error(jgftxt006);

            end;
        }
        field(14228812; "Post to Cust. Buying Group ELA"; Boolean)
        {
            Caption = 'Post to Customer Buying Group';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                TestField("Job Task Type", "Job Task Type"::Posting);
                VerifyJobIsPromotion;



                if "No. of Planning Lines ELA" <> 0 then
                    Error(jgftxt005, FieldCaption("Post to Cust. Buying Group ELA"));
                if "No. of Rebates ELA" <> 0 then
                    Error(jgftxt009, FieldCaption("Post to Cust. Buying Group ELA"));

                Clear(grecJob);
                if "Job No." <> '' then
                    if grecJob.Get("Job No.") then
                        if not grecJob.CheckOpenStatus(grecJob) then
                            Error(gtxt001, grecJob."No.");

                if "Post to Cust. Buying Group ELA" then
                    if "Rebate Type ELA" = "Rebate Type ELA"::" " then
                        Error(jgftxt002);

            end;
        }
        field(14228813; "Unit Cost ELA"; Decimal)
        {
            Caption = 'Unit Cost';
            AutoFormatType = 2;
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                TestField("Job Task Type", "Job Task Type"::Posting);



                Clear(grecJob);
                if "Job No." <> '' then
                    if grecJob.Get("Job No.") then
                        if not grecJob.CheckOpenStatus(grecJob) then
                            Error(gtxt001, grecJob."No.");

                GetJob();
                if grecJob."No." <> '' then
                    if grecJob."Promotion ELA" then
                        UpdatePromotionCostPlanLines(Rec);

                UpdatePromoPlanningLines(FieldNo("Unit Cost ELA"));
                UpdateRebates(FieldNo("Unit Cost ELA"));

            end;
        }
        field(14228814; "No. of Planning Lines ELA"; Integer)
        {
            Caption = 'No. of Planning Lines';
            CalcFormula = Count("Job Planning Line" WHERE("Job No." = FIELD("Job No."),
                                                           "Job Task No." = FIELD("Job Task No.")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14228815; "Promotion Customer No. ELA"; Code[20])
        {
            Caption = 'Promotion Customer No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "Job Promotion Customers ELA"."Customer No." WHERE("Job No." = FIELD("Job No."));

            trigger OnValidate()
            var
                ltxt001: Label 'You require a job task type of posting and a blank rebate type to enter a value in this field.';
                lrecJob: Record Job;
                ltxt002: Label 'You can only use this field for promotional jobs.';
            begin

                Clear(lrecJob);
                if lrecJob.Get("Job No.") then
                    if not lrecJob."Promotion ELA" then
                        Error(ltxt002);

                if (("Job Task Type" <> "Job Task Type"::Posting) or
                  ("Rebate Type ELA" <> "Rebate Type ELA"::" ")) then
                    Error(ltxt001);

                if "Promotion Customer No. ELA" = '' then
                    "Promotion Ship-to Code ELA" := '';

                if "No. of Planning Lines ELA" <> 0 then
                    Error(jgftxt005, FieldCaption("Promotion Customer No. ELA"));
                if "No. of Rebates ELA" <> 0 then
                    Error(jgftxt009, FieldCaption("Promotion Customer No. ELA"));

                Clear(grecJob);
                if "Job No." <> '' then
                    if grecJob.Get("Job No.") then
                        if not grecJob.CheckOpenStatus(grecJob) then
                            Error(gtxt001, grecJob."No.");

            end;
        }
        field(14228816; "Promotion Ship-to Code ELA"; Code[10])
        {
            Caption = 'Promotion Ship-to Code';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Promotion Customer No. ELA"));

            trigger OnValidate()
            var
                ltxt001: Label 'You require a valid, job promotional customer, a job task type of posting and non-blank rebate type to enter a value here.';
                lrecJob: Record Job;
                ltxt002: Label 'You can only use this field for promotional jobs.';
            begin

                Clear(lrecJob);
                if lrecJob.Get("Job No.") then
                    if not lrecJob."Promotion ELA" then
                        Error(ltxt002);

                if (("Job Task Type" <> "Job Task Type"::Posting) or
                  ("Rebate Type ELA" <> "Rebate Type ELA"::" ")) or
                  ("Promotion Customer No. ELA" = '') then
                    Error(ltxt001);

                if "No. of Planning Lines ELA" <> 0 then
                    Error(jgftxt005, FieldCaption("Promotion Ship-to Code ELA"));
                if "No. of Rebates ELA" <> 0 then
                    Error(jgftxt009, FieldCaption("Promotion Ship-to Code ELA"));

                Clear(grecJob);
                if "Job No." <> '' then
                    if grecJob.Get("Job No.") then
                        if not grecJob.CheckOpenStatus(grecJob) then
                            Error(gtxt001, grecJob."No.");

            end;
        }
        field(14228817; "Schedule (Promotion Cost) ELA"; Decimal)
        {
            Caption = 'Schedule (Promotion Cost)';
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum("Job Planning Line"."Total Promotion Cost ELA" WHERE("Job No." = FIELD("Job No."),
                                                                                "Job Task No." = FIELD("Job Task No."),
                                                                                "Job Task No." = FIELD(FILTER(Totaling)),
                                                                                "Schedule Line" = CONST(true),
                                                                                "Planning Date" = FIELD("Planning Date Filter")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    var
        CannotDeleteAssociatedEntriesErr: Label 'You cannot delete %1 because one or more entries are associated.', Comment = '%1=The job task table name.';
        CannotChangeAssociatedEntriesErr: Label 'You cannot change %1 because one or more entries are associated with this %2.', Comment = '%1 = The field name you are trying to change; %2 = The job task table name.';
        Job: Record Job;
        DimMgt: Codeunit DimensionManagement;
        grecJob: Record Job;
        gtxt001: Label 'Approval Status must be Open in Job %1.';
        jgftxt005: Label 'Please delete all associated planning lines before changing %1 on the task line.';
        jgftxt006: Label 'Rebate Type should be ''Everyday'' or ''Off-Invoice''.';
        jgftxt007: Label 'You cannot filter on the same dimension code. Please use a different dimension code.';
        jgftxt008: Label 'Please delete all associated rebates before deleting task line.';
        jgftxt009: Label 'Please delete all associated rebates before changing %1.';
        jgftxt002: Label 'Rebate Type cannot be blank.';

    procedure CheckJobRebateEntryExists(lrecJobTask: Record "Job Task")
    var
        lrecRebateHeader: Record "Rebate Header ELA";
        ltxt001: Label 'You cannot delete a job task with a blank job no.';
        lrecJob: Record Job;
        ltxt002: Label 'This job should be promotional job. Please check the promotion flag on romtoion tab for this job.';
        ltxt003: Label 'No Task Lines were found for this job %1.';
        lrecJobTask2: Record "Job Task";
        ltxt004: Label 'You cannot use this function for job task line with a Job Task Type of Posting.';
        lrecPostedRebateDetail: Record "Rebate Ledger Entry ELA";
        ltxt005: Label 'You cannot delete Rebate No. %1. It has Posted Rebate Details.';
    begin

        Clear(lrecRebateHeader);
        Clear(lrecJob);
        Clear(lrecJobTask2);
        Clear(lrecPostedRebateDetail);
        if lrecJob.Get(lrecJobTask."Job No.") then begin
            if lrecJob."Promotion ELA" then begin
                lrecJobTask2.SetRange(lrecJobTask2."Job No.", lrecJobTask."Job No.");
                lrecJobTask2.SetRange(lrecJobTask2."Job Task No.", lrecJobTask."Job Task No.");
                if not lrecJobTask2.FindFirst then begin
                    Error(ltxt003, lrecJob."No.");
                end else begin
                    if lrecJobTask2."Job Task Type" <> lrecJobTask2."Job Task Type"::Posting then
                        Error(ltxt004);
                    lrecRebateHeader.SetRange(lrecRebateHeader."Job No.", lrecJob."No.");
                    lrecRebateHeader.SetRange(lrecRebateHeader."Job Task No.", lrecJobTask2."Job Task No.");
                    if lrecRebateHeader.FindSet then begin
                        repeat
                            Clear(lrecPostedRebateDetail);
                            lrecPostedRebateDetail.SetRange(lrecPostedRebateDetail."Rebate Code", lrecRebateHeader.Code);
                            if not lrecPostedRebateDetail.IsEmpty then
                                Error(ltxt005, lrecRebateHeader.Code);
                        until lrecRebateHeader.Next = 0;
                    end;
                end;
            end else begin
                Error(ltxt002);
            end;
        end else begin
            Error(ltxt001);
        end;

    end;


    procedure DeleteRebateLines(lrecJobTask: Record "Job Task")
    var
        lrecRebateHeader: Record "Rebate Header ELA";
        lrecJob: Record Job;
        lrecJobTask2: Record "Job Task";
        ltxt001: Label 'You cannot delete a job task with a blank job no.';
        ltxt002: Label 'This job should be promotional job. Please check the promotion flag on romtoion tab for this job.';
        ltxt003: Label 'No Task Lines were found for this job %1.';
        ltxt004: Label 'You cannot use this function for job task line with a Job Task Type of Posting.';
    begin

        Clear(lrecRebateHeader);
        Clear(lrecJob);
        Clear(lrecJobTask2);
        if lrecJob.Get(lrecJobTask."Job No.") then begin
            if lrecJob."Promotion ELA" then begin
                lrecJobTask2.SetRange(lrecJobTask2."Job No.", lrecJobTask."Job No.");
                lrecJobTask2.SetRange(lrecJobTask2."Job Task No.", lrecJobTask."Job Task No.");
                if not lrecJobTask2.FindFirst then begin
                    Error(ltxt003, lrecJob."No.");
                end else begin
                    if lrecJobTask2."Job Task Type" <> lrecJobTask2."Job Task Type"::Posting then
                        Error(ltxt004);
                    lrecRebateHeader.SetRange(lrecRebateHeader."Job No.", lrecJob."No.");
                    lrecRebateHeader.SetRange(lrecRebateHeader."Job Task No.", lrecJobTask2."Job Task No.");
                    if lrecRebateHeader.FindSet then begin
                        repeat
                            lrecRebateHeader.Delete;
                        until lrecRebateHeader.Next = 0;
                    end;
                end;
            end else begin
                Error(ltxt002);
            end;
        end else begin
            Error(ltxt001);
        end;

    end;


    procedure VerifyJobIsPromotion()
    var
        ltxt000: Label 'Job No. %1 must be a Promotion';
    begin

        GetJob;

        //IF NOT grecJob.IsPromotion THEN
        // ERROR(ltxt000,"Job No.");

    end;


    procedure GetJob()
    begin

        if grecJob."No." <> "Job No." then
            grecJob.Get("Job No.");

    end;

    local procedure UpdatePromoPlanningLines(pintFieldNo: Integer)
    var
        lrecJobPlanningLine: Record "Job Planning Line";
        lcduPromoPlanningMgmt: Codeunit "Rebate Sales Functions ELA";
    begin


        if (
          ("Job No." = '')
          or ("Job Task No." = '')
        ) then begin
            exit;
        end;

        GetJob;

        if (
          (not grecJob."Promotion ELA")
        ) then begin
            exit;
        end;

        lrecJobPlanningLine.SetRange("Job No.", "Job No.");
        lrecJobPlanningLine.SetRange("Job Task No.", "Job Task No.");

        if (
          lrecJobPlanningLine.IsEmpty
        ) then begin
            exit; // nothing to update
        end;

        case pintFieldNo of

            FieldNo("Starting Date ELA"):
                begin
                    if (
                      ("Starting Date ELA" <> xRec."Starting Date ELA")
                    ) then begin
                        if (
                          lrecJobPlanningLine.FindSet(true, false)
                        ) then begin
                            repeat
                                lrecJobPlanningLine.SetUpdateFromParent(Rec);
                                lrecJobPlanningLine.Validate("Planning Date", "Starting Date ELA");
                                lrecJobPlanningLine.ClearUpdateFromParent;
                                lrecJobPlanningLine.Modify(true);
                            until lrecJobPlanningLine.Next = 0;
                        end;
                    end;
                end;

            FieldNo("Ending Date ELA"):
                begin
                    if (
                      ("Ending Date ELA" <> xRec."Ending Date ELA")
                    ) then begin
                        if (
                          lrecJobPlanningLine.FindSet(true, false)
                        ) then begin
                            repeat
                                lrecJobPlanningLine.SetUpdateFromParent(Rec);
                                lrecJobPlanningLine.Validate("Ending Date ELA", "Ending Date ELA");
                                lrecJobPlanningLine.ClearUpdateFromParent;
                                lrecJobPlanningLine.Modify(true);
                            until lrecJobPlanningLine.Next = 0;
                        end;
                    end;
                end;

            FieldNo("Quantity ELA"):
                begin
                    if (
                      ("Quantity ELA" <> xRec."Quantity ELA")
                    ) then begin
                        if (
                          lrecJobPlanningLine.FindSet(false, false)
                        ) then begin

                            lcduPromoPlanningMgmt.UpdtePromCostOnPlanningLines(Rec);

                        end;
                    end;
                end;

            FieldNo("Unit Cost ELA"):
                begin
                    if (
                      ("Unit Cost ELA" <> xRec."Unit Cost ELA")
                    ) then begin
                        if (
                          lrecJobPlanningLine.FindSet(false, false)
                        ) then begin
                            repeat
                                if (
                                  ("Rebate Type ELA" = "Rebate Type ELA"::" ")
                                  and ("Expense G/L Account No. ELA" <> '')
                                ) then begin
                                    lrecJobPlanningLine.Validate("Unit Cost", "Unit Cost ELA");
                                end;
                                lrecJobPlanningLine.Validate("Promotion Unit Cost ELA", "Unit Cost ELA");
                                lrecJobPlanningLine.Modify(true);
                            until lrecJobPlanningLine.Next = 0;

                            lcduPromoPlanningMgmt.UpdtePromCostOnPlanningLines(Rec);

                        end;
                    end;
                end;

            else begin
                    // do nothing
                end;

        end;


    end;


    procedure CreateRebateLines(lrecJob: Record Job)
    var
        lrecJobTaskLine: Record "Job Task";
        lrecJobPlanningLine: Record "Job Planning Line";
        lrecItem: Record Item;
        lrecCustomer: Record Customer;
        lrecRebateHeader: Record "Rebate Header ELA";
        lrecRebateLine: Record "Rebate Line ELA";
        lrecJobPromoCust: Record "Job Promotion Customers ELA";
        lintCount: Integer;
        lrecJobPlanningLine2: Record "Job Planning Line";
    begin

        Clear(lrecJobTaskLine);
        lrecJobTaskLine.SetRange(lrecJobTaskLine."Job No.", lrecJob."No.");
        lrecJobTaskLine.SetRange(lrecJobTaskLine."Job Task Type", lrecJobTaskLine."Job Task Type"::Posting);
        lrecJobTaskLine.SetFilter(lrecJobTaskLine."Rebate Type ELA", '<>%1', lrecJobTaskLine."Rebate Type ELA"::" ");
        if lrecJobTaskLine.FindSet then begin
            repeat
                lrecJobTaskLine.CalcFields(lrecJobTaskLine."No. of Rebates ELA");
                if (lrecJobTaskLine."No. of Rebates ELA" = 0) then begin
                    if lrecJobTaskLine."Rebate Type ELA" = lrecJobTaskLine."Rebate Type ELA"::"Lump Sum" then begin
                        // Lump sum Rebate Type logic
                        Clear(lrecJobPromoCust);
                        lrecJobPromoCust.SetRange(lrecJobPromoCust."Job No.", lrecJobTaskLine."Job No.");
                        if lrecJobPromoCust.FindSet then begin
                            //Create Rebate Header
                            lrecRebateHeader.Init;

                            lrecRebateHeader.Code := '';
                            lrecRebateHeader.Insert(true);

                            lrecRebateHeader.Description := lrecJobTaskLine.Description;

                            lrecRebateHeader.Validate("Rebate Category Code", lrecJobTaskLine."Rebate Category Code ELA");
                            lrecRebateHeader.Validate("Rebate Type", lrecRebateHeader."Rebate Type"::"Lump Sum");

                            lrecRebateHeader."Minimum Quantity (Base)" := 0;
                            lrecRebateHeader."Maximum Quantity (Base)" := 0;
                            lrecRebateHeader."Minimum Amount" := 0;
                            lrecRebateHeader."Maximum Amount" := 0;
                            lrecRebateHeader."Unit of Measure Code" := '';
                            lrecRebateHeader."Currency Code" := '';

                            lrecRebateHeader.Validate("Post to Sub-Ledger", lrecJobTaskLine."Post to Sub-Ledger ELA" - 1);
                            lrecRebateHeader.Validate("Post to Cust. Buying Group", lrecJobTaskLine."Post to Cust. Buying Group ELA");

                            lrecRebateHeader."Start Date" := lrecJobTaskLine."Starting Date ELA";

                            lrecRebateHeader."Expense G/L Account No." := lrecJobTaskLine."Expense G/L Account No. ELA";

                            if lrecRebateHeader."Post to Sub-Ledger" = lrecRebateHeader."Post to Sub-Ledger"::"Do Not Post" then
                                lrecRebateHeader."Offset G/L Account No." := lrecJobTaskLine."Offset G/L Account No. ELA";

                            lrecRebateHeader."Rebate Value" := lrecJobTaskLine."Quantity ELA" * lrecJobTaskLine."Unit Cost ELA";

                            lrecRebateHeader."Job No." := lrecJobTaskLine."Job No.";
                            lrecRebateHeader."Job Task No." := lrecJobTaskLine."Job Task No.";

                            lrecRebateHeader.Modify;

                            // Insert Job Promotional Customers as Rebate Lines
                            lintCount := 0;

                            repeat
                                lintCount += 10000;

                                lrecRebateLine.Init;

                                lrecRebateLine."Rebate Code" := lrecRebateHeader.Code;
                                lrecRebateLine."Line No." := lintCount;

                                lrecRebateLine.Validate(Source, lrecRebateLine.Source::Customer);
                                lrecRebateLine.Validate(Type, lrecRebateLine.Type::"No.");
                                lrecRebateLine.Validate(Value, lrecJobPromoCust."Customer No.");

                                lrecRebateLine.Include := true;

                                lrecRebateLine.Insert;
                            until lrecJobPromoCust.Next = 0;

                            // Insert Planning line Items if at least one customer inserted above
                            if lintCount > 0 then begin
                                Clear(lrecJobPlanningLine);

                                lrecJobPlanningLine.SetRange(lrecJobPlanningLine."Job No.", lrecJobTaskLine."Job No.");
                                lrecJobPlanningLine.SetRange(lrecJobPlanningLine."Job Task No.", lrecJobTaskLine."Job Task No.");
                                lrecJobPlanningLine.SetRange(lrecJobPlanningLine.Type, lrecJobPlanningLine.Type::Item);

                                if lrecJobPlanningLine.FindSet then begin
                                    repeat
                                        // Create item rebate lines
                                        lintCount := lintCount + 10000;

                                        lrecRebateLine.Init;

                                        lrecRebateLine."Rebate Code" := lrecRebateHeader.Code;
                                        lrecRebateLine."Line No." := lintCount;

                                        lrecRebateLine.Validate(Source, lrecRebateLine.Source::Item);
                                        lrecRebateLine.Validate(Type, lrecRebateLine.Type::"No.");
                                        lrecRebateLine.Validate(Value, lrecJobPlanningLine."No.");

                                        lrecRebateLine.Include := true;

                                        lrecRebateLine.Insert;
                                    until lrecJobPlanningLine.Next = 0;
                                end;
                            end;
                        end;
                    end else begin
                        // Non Lump Sum Rebate Type logic
                        Clear(lrecJobPlanningLine2);

                        lrecJobPlanningLine2.SetRange(lrecJobPlanningLine2."Job No.", lrecJobTaskLine."Job No.");
                        lrecJobPlanningLine2.SetRange(lrecJobPlanningLine2."Job Task No.", lrecJobTaskLine."Job Task No.");
                        lrecJobPlanningLine2.SetRange(lrecJobPlanningLine2.Type, lrecJobPlanningLine2.Type::Item);

                        // Pre-check if atleast one planning line exists
                        if lrecJobPlanningLine2.FindSet then begin
                            Clear(lrecJobPromoCust);

                            lrecJobPromoCust.SetRange(lrecJobPromoCust."Job No.", lrecJobTaskLine."Job No.");

                            // Pre-check if atleast one job promotional customer exists
                            if lrecJobPromoCust.FindSet then begin
                                repeat
                                    //Create Rebate Header
                                    lrecRebateHeader.Init;

                                    lrecRebateHeader.Code := '';
                                    lrecRebateHeader.Insert(true);

                                    lrecRebateHeader.Description := lrecJobTaskLine.Description;

                                    lrecRebateHeader.Validate("Rebate Category Code", lrecJobTaskLine."Rebate Category Code ELA");
                                    lrecRebateHeader.Validate("Rebate Type", lrecJobTaskLine."Rebate Type ELA" - 1);

                                    lrecRebateHeader."Calculation Basis" := lrecRebateHeader."Calculation Basis"::"($)/Unit";

                                    lrecRebateHeader."Minimum Quantity (Base)" := lrecJobTaskLine."Minimum Quantity (Base) ELA";
                                    lrecRebateHeader."Maximum Quantity (Base)" := 0;

                                    lrecRebateHeader."Minimum Amount" := lrecJobTaskLine."Minimum Amount ELA";
                                    lrecRebateHeader."Maximum Amount" := 0;

                                    lrecRebateHeader."Unit of Measure Code" := lrecJobTaskLine."Unit of Measure Code ELA";
                                    lrecRebateHeader."Currency Code" := lrecJob."Currency Code";

                                    lrecRebateHeader."Start Date" := lrecJobTaskLine."Starting Date ELA";
                                    lrecRebateHeader."End Date" := lrecJobTaskLine."Ending Date ELA";

                                    lrecRebateHeader.Validate("Post to Sub-Ledger", lrecJobTaskLine."Post to Sub-Ledger ELA" - 1);
                                    lrecRebateHeader.Validate("Post to Cust. Buying Group", lrecJobTaskLine."Post to Cust. Buying Group ELA");

                                    lrecRebateHeader."Expense G/L Account No." := lrecJobTaskLine."Expense G/L Account No. ELA";

                                    if lrecRebateHeader."Post to Sub-Ledger" = lrecRebateHeader."Post to Sub-Ledger"::"Do Not Post" then
                                        lrecRebateHeader."Offset G/L Account No." := lrecJobTaskLine."Offset G/L Account No. ELA";

                                    lrecRebateHeader."Rebate Value" := lrecJobTaskLine."Unit Cost ELA";

                                    lrecRebateHeader.Validate("Apply-To Customer Type", lrecRebateHeader."Apply-To Customer Type"::Specific);
                                    lrecRebateHeader.Validate("Apply-To Customer No.", lrecJobPromoCust."Customer No.");

                                    lrecRebateHeader."Job No." := lrecJobTaskLine."Job No.";
                                    lrecRebateHeader."Job Task No." := lrecJobTaskLine."Job Task No.";

                                    lrecRebateHeader.Modify;

                                    // Create item rebate lines
                                    Clear(lrecJobPlanningLine);

                                    lrecJobPlanningLine.SetRange(lrecJobPlanningLine."Job No.", lrecJobTaskLine."Job No.");
                                    lrecJobPlanningLine.SetRange(lrecJobPlanningLine."Job Task No.", lrecJobTaskLine."Job Task No.");
                                    lrecJobPlanningLine.SetRange(lrecJobPlanningLine.Type, lrecJobPlanningLine.Type::Item);

                                    lintCount := 0;
                                    if lrecJobPlanningLine.FindSet then begin
                                        repeat
                                            lintCount := lintCount + 10000;

                                            lrecRebateLine.Init;

                                            lrecRebateLine."Rebate Code" := lrecRebateHeader.Code;
                                            lrecRebateLine."Line No." := lintCount;

                                            lrecRebateLine.Validate(Source, lrecRebateLine.Source::Item);
                                            lrecRebateLine.Validate(Type, lrecRebateLine.Type::"No.");
                                            lrecRebateLine.Validate(Value, lrecJobPlanningLine."No.");

                                            lrecRebateLine.Include := true;

                                            lrecRebateLine.Insert;
                                        until lrecJobPlanningLine.Next = 0;
                                    end;
                                until lrecJobPromoCust.Next = 0;
                            end;
                        end;
                    end;
                end;
            until lrecJobTaskLine.Next = 0;
        end;

    end;

    local procedure UpdateRebates(pintFieldNo: Integer)
    var
        lrecRebateHeader: Record "Rebate Header ELA";
    begin

        if (
          ("Job No." = '')
          or ("Job Task No." = '')
        ) then begin
            exit;
        end;

        GetJob;

        if (
          (not grecJob."Promotion ELA")
        ) then begin
            exit;
        end;

        lrecRebateHeader.SetRange("Job No.", "Job No.");
        lrecRebateHeader.SetRange("Job Task No.", "Job Task No.");

        if (
          lrecRebateHeader.IsEmpty
        ) then begin
            exit; // nothing to update
        end;

        case pintFieldNo of

            FieldNo("Starting Date ELA"):
                begin
                    if (
                      ("Starting Date ELA" <> xRec."Starting Date ELA")
                    ) then begin
                        if (
                          lrecRebateHeader.FindSet(true, false)
                        ) then begin
                            repeat
                                TestRebateLedgerEntryIsEmpty(lrecRebateHeader.Code);
                                lrecRebateHeader.SetUpdateFromParent(Rec);
                                lrecRebateHeader.Validate("Start Date", "Starting Date ELA");
                                lrecRebateHeader.ClearUpdateFromParent;
                                lrecRebateHeader.Modify(true);
                            until lrecRebateHeader.Next = 0;
                        end;
                    end;
                end;

            FieldNo("Ending Date ELA"):
                begin
                    if (
                      ("Ending Date ELA" <> xRec."Ending Date ELA")
                    ) then begin
                        if (
                          lrecRebateHeader.FindSet(true, false)
                        ) then begin
                            repeat
                                TestRebateLedgerEntryIsEmpty(lrecRebateHeader.Code);
                                lrecRebateHeader.Validate("End Date", "Ending Date ELA");
                                lrecRebateHeader.Modify(true);
                            until lrecRebateHeader.Next = 0;
                        end;
                    end;
                end;

            FieldNo("Quantity ELA"):
                begin
                    if (
                      ("Quantity ELA" <> xRec."Quantity ELA")
                      and ("Rebate Type ELA" = "Rebate Type ELA"::"Lump Sum")
                    ) then begin
                        if (
                          lrecRebateHeader.FindSet(false, false)
                        ) then begin
                            repeat
                                TestRebateLedgerEntryIsEmpty(lrecRebateHeader.Code);
                                lrecRebateHeader.SetUpdateFromParent(Rec);
                                lrecRebateHeader.Validate("Rebate Value", "Unit Cost ELA" * "Quantity ELA");
                                lrecRebateHeader.ClearUpdateFromParent;
                                lrecRebateHeader.Modify(true);
                            until lrecRebateHeader.Next = 0;
                        end;
                    end;
                end;

            FieldNo("Unit Cost ELA"):
                begin
                    if (
                      ("Unit Cost ELA" <> xRec."Unit Cost ELA")
                    ) then begin
                        if (
                          lrecRebateHeader.FindSet(false, false)
                        ) then begin
                            repeat
                                TestRebateLedgerEntryIsEmpty(lrecRebateHeader.Code);
                                lrecRebateHeader.SetUpdateFromParent(Rec);
                                if (
                                  ("Rebate Type ELA" = "Rebate Type ELA"::"Lump Sum")
                                ) then begin
                                    lrecRebateHeader.Validate("Rebate Value", "Unit Cost ELA" * "Quantity ELA");
                                end else begin
                                    lrecRebateHeader.Validate("Rebate Value", "Unit Cost ELA");
                                end;
                                lrecRebateHeader.ClearUpdateFromParent;
                                lrecRebateHeader.Modify(true);
                            until lrecRebateHeader.Next = 0;
                        end;
                    end;
                end;

            else begin
                    // do nothing
                end;

        end;
    end;

    local procedure TestRebateLedgerEntryIsEmpty(pcodRebateCode: Code[20])
    var
        lrecRebateLedgerEntry: Record "Rebate Ledger Entry ELA";
        lText030: Label '%1 must not contain entries for %2 ''%3''';
    begin


        lrecRebateLedgerEntry.SetCurrentKey("Rebate Code");

        lrecRebateLedgerEntry.SetRange("Rebate Code", pcodRebateCode);
        lrecRebateLedgerEntry.SetRange("Functional Area", lrecRebateLedgerEntry."Functional Area"::Sales);

        if (
          (not lrecRebateLedgerEntry.IsEmpty)
        ) then begin
            // %1 must not contain entries for %2 '%3'.
            Error(lText030, lrecRebateLedgerEntry.TableCaption,
                               lrecRebateLedgerEntry.FieldCaption("Rebate Code"),
                               lrecRebateLedgerEntry."Rebate Code");
        end;

    end;

    local procedure CheckDate()
    var
        ltxtText000: Label '%1 must be equal to or earlier than %2.';
    begin

        if ("Starting Date ELA" > "Ending Date ELA") and ("Ending Date ELA" <> 0D) then
            Error(ltxtText000, FieldCaption("Starting Date ELA"), FieldCaption("Ending Date ELA"));

    end;


    procedure UpdatePromotionCostPlanLines(var precJobTask: Record "Job Task")
    var
        lrecJobPlanningLine: Record "Job Planning Line";
        lrecJob: Record Job;
    begin

        if precJobTask."Job No." <> '' then begin
            if lrecJob.Get(precJobTask."Job No.") then begin
                Clear(lrecJobPlanningLine);
                lrecJobPlanningLine.SetRange(lrecJobPlanningLine."Job No.", precJobTask."Job No.");
                lrecJobPlanningLine.SetRange(lrecJobPlanningLine."Job Task No.", precJobTask."Job Task No.");
                if lrecJobPlanningLine.FindSet then begin
                    repeat
                        lrecJobPlanningLine."Promotion Unit Cost ELA" := precJobTask."Unit Cost ELA";
                        lrecJobPlanningLine."Total Promotion Cost ELA" := lrecJobPlanningLine."Promotion Unit Cost ELA" * lrecJobPlanningLine.Quantity;
                        lrecJobPlanningLine.Modify;
                    until lrecJobPlanningLine.Next = 0;
                end;
            end;
        end;

    end;
}