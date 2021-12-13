tableextension 14229405 "Job ELA" extends Job
{
    //ENRE1.00 2021-09-08 AJ
    fields
    {
        // Add changes to table fields here
        field(14228800; "Promotion ELA"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                //-- Block all jobs turned into promotions from posting
                if ("Promotion ELA") and (not xRec."Promotion ELA") then
                    Validate(Blocked, Blocked::Posting);

                //<<ENRE1.00
                if ("Promotion ELA") and ("No." <> '') then begin
                    lrecRebateHeader.SetRange("Job No.", "No.");

                    if lrecRebateHeader.FindSet(true) then begin
                        repeat
                            lrecRebateHeader.Blocked := Blocked <> Blocked::" ";
                            lrecRebateHeader.Modify;
                        until lrecRebateHeader.Next = 0;
                    end;
                end;
                //>>ENRE1.00

                if not "Promotion ELA" then
                    CheckJobPromotionCustomers(Rec);

            end;
        }
        field(14228801; "Approval Status ELA"; Option)
        {
            Caption = 'Approval Status';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Editable = false;
            OptionCaption = 'Open,Released,Pending Approval';
            OptionMembers = Open,Released,"Pending Approval";
        }
        field(14228802; "Promotion Customer No. ELA"; Code[20])
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = Customer;

            trigger OnValidate()
            var
                ltxt001: Label 'You cannot insert multiple job promotional customers from this field. Please use the job promotional form.';
                ltxt002: Label 'Please remove from job promotional customer form.';
                ltxt003: Label 'Do you want to update the record on the job promotional customer?';
                ltxt004: Label 'User Stopped Process.';
            begin

                if "Promotion Customer No. ELA" <> '' then begin
                    TestField("Promotion ELA", true);
                end;



                if "Promotion Customer No. ELA" <> xRec."Promotion Customer No. ELA" then begin
                    if JobLedgEntryExist then
                        Error(AssociatedEntriesExistErr, FieldCaption("Promotion Customer No. ELA"), TableCaption);
                end;



                if ((xRec."Promotion Customer No. ELA" <> '') and ("Promotion Customer No. ELA" = '')) then begin


                    if not CheckOpenStatus(Rec) then
                        Error(gtxt001, "No.");
                    if CheckJobRebatesExist(Rec) then
                        Error(gtxt002, "No.");


                    if CountJobPromoCust(Rec) > 0 then
                        Error(ltxt002);

                end;
                if ((xRec."Promotion Customer No. ELA" = '') and (xRec."Promotion Customer No. ELA" <> "Promotion Customer No. ELA")) then begin


                    if not CheckOpenStatus(Rec) then
                        Error(gtxt001, "No.");
                    if CheckJobRebatesExist(Rec) then
                        Error(gtxt002, "No.");


                    if CountJobPromoCust(Rec) > 1 then
                        Error(ltxt001);
                    if CountJobPromoCust(Rec) = 0 then begin
                        Clear(grecJobPromo);
                        grecJobPromo."Job No." := "No.";
                        grecJobPromo."Customer No." := "Promotion Customer No. ELA";
                        grecJobPromo.Insert;

                        Clear(grecCust);
                        if grecCust.Get("Promotion Customer No. ELA") then
                            "Promotion Customer Name ELA" := grecCust.Name;

                    end;

                end;

                if ((xRec."Promotion Customer No. ELA" <> '') and (xRec."Promotion Customer No. ELA" <> "Promotion Customer No. ELA")) then begin


                    if not CheckOpenStatus(Rec) then
                        Error(gtxt001, "No.");
                    if CheckJobRebatesExist(Rec) then
                        Error(gtxt002, "No.");


                    if CountJobPromoCust(Rec) > 1 then
                        Error(ltxt001);
                    if CountJobPromoCust(Rec) = 1 then begin
                        Clear(grecJobPromo);
                        grecJobPromo.SetRange(grecJobPromo."Job No.", "No.");
                        if grecJobPromo.FindFirst then begin
                            if grecJobPromo."Customer No." <> "Promotion Customer No. ELA" then
                                if Confirm(ltxt003, true) then begin
                                    grecJobPromo.Delete;
                                    Clear(grecJobPromo);
                                    grecJobPromo."Job No." := "No.";
                                    grecJobPromo."Customer No." := "Promotion Customer No. ELA";
                                    grecJobPromo.Insert;

                                    Clear(grecCust);
                                    if grecCust.Get("Promotion Customer No. ELA") then
                                        "Promotion Customer Name ELA" := grecCust.Name;

                                end else
                                    Error(ltxt004);
                        end;
                    end;
                end;


                if "Promotion Customer No. ELA" = '' then
                    Clear("Promotion Customer Name ELA");

            end;
        }
        field(14228803; "Promotion Customer Name ELA"; Text[100])
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Editable = false;
        }
        field(14228804; "Promotion Quantity ELA"; Decimal)
        {
            BlankZero = true;
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                if "Promotion Quantity ELA" <> 0 then begin
                    TestField("Promotion ELA", true);
                end;



                "Sched. (Promotion Revenue) ELA" := "Promotion Quantity ELA" * "Promotion Unit Price ELA";

            end;
        }
        field(14228805; "Promotion Unit Price ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                "Sched. (Promotion Revenue) ELA" := "Promotion Quantity ELA" * "Promotion Unit Price ELA";

            end;
        }
        field(14228806; "Sched. (Promotion Revenue) ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                if "Promotion Quantity ELA" <> 0 then
                    "Promotion Unit Price ELA" := "Sched. (Promotion Revenue) ELA" / "Promotion Quantity ELA";

            end;
        }
        field(14228807; "Promo Unit of Measure Code ELA"; Code[10])
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            begin

                if "Promo Unit of Measure Code ELA" <> '' then begin
                    TestField("Promotion ELA", true);
                end;

            end;
        }

    }

    var

        AssociatedEntriesExistErr: Label 'You cannot change %1 because one or more entries are associated with this %2.', Comment = '%1 = Name of field used in the error; %2 = The name of the Job table';
        gtxt001: Label 'Approval Status must be open in Job %1.';
        gtxt002: Label 'The job %1 has existing rebates. Please delete all rebates before changing job promotion customers.';
        grecJobPromo: Record "Job Promotion Customers ELA";
        grecCust: Record Customer;
        lrecRebateHeader: Record "Rebate Header ELA";

    procedure CheckJobPromotionCustomers(lrecJob: Record Job)
    var
        lrecJobPromotionCustomers: Record "Job Promotion Customers ELA";
        ltxt001: Label 'You cannot turn-off promotions for a job with existing promotions customers. Please delete all ''''Job Promotional Customers'''' for this job, before turning off this feature.''';
    begin

        if lrecJob."No." <> '' then begin
            Clear(lrecJobPromotionCustomers);
            lrecJobPromotionCustomers.SetRange(lrecJobPromotionCustomers."Job No.", lrecJob."No.");
            if lrecJobPromotionCustomers.FindFirst then
                Error(ltxt001);
        end

    end;


    procedure CountJobPromoCust(lrecJob: Record Job): Integer
    var
        lrecJobPromoCust: Record "Job Promotion Customers ELA";
        lintCount: Integer;
    begin

        lintCount := 0;
        Clear(lrecJobPromoCust);
        lrecJobPromoCust.SetRange(lrecJobPromoCust."Job No.", lrecJob."No.");
        if lrecJobPromoCust.FindFirst then begin
            repeat
                lintCount += 1;
            until lrecJobPromoCust.Next = 0;
        end;
        exit(lintCount);

    end;


    procedure CheckOpenStatus(precJob: Record Job): Boolean
    begin

        if precJob."No." <> '' then begin
            if precJob."Approval Status ELA" = precJob."Approval Status ELA"::Open then
                exit(true);
        end;
        exit(false);

    end;


    procedure CheckJobRebatesExist(precJob: Record Job): Boolean
    var
        lrecJobTask: Record "Job Task";
    begin

        Clear(lrecJobTask);
        if precJob."No." <> '' then begin
            if precJob."Promotion ELA" then begin
                lrecJobTask.SetRange(lrecJobTask."Job No.", precJob."No.");
                lrecJobTask.SetRange(lrecJobTask."Job Task Type", lrecJobTask."Job Task Type"::Posting);
                lrecJobTask.SetFilter(lrecJobTask."No. of Rebates ELA", '>%1', 0);
                if lrecJobTask.FindSet then
                    exit(true);
            end;
        end;
        exit(false);

    end;


    procedure JobLedgEntryExistFunc(): Boolean
    begin

        exit(JobLedgEntryExist);

    end;

    local procedure JobLedgEntryExist(): Boolean
    var
        JobLedgEntry: Record "Job Ledger Entry";
    begin
        Clear(JobLedgEntry);
        JobLedgEntry.SetCurrentKey("Job No.");
        JobLedgEntry.SetRange("Job No.", "No.");
        exit(JobLedgEntry.FindFirst);
    end;

    procedure IsPromotion(): Boolean
    begin

        exit("Promotion ELA");

    end;
}