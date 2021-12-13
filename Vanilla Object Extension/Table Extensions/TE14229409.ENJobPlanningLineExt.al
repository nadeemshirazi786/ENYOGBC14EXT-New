tableextension 14229409 "Job Planning Line ELA" extends "Job Planning Line"
{
    //ENRE1.00 2021-09-08 AJ
    fields
    {
        // Add changes to table fields here
        field(14228800; "Total Promotion Cost (LCY) ELA"; Decimal)
        {
            Caption = 'Total Promotion Cost (LCY)';
            AutoFormatType = 1;
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Editable = false;

            trigger OnValidate()
            begin

                TestField(Type, Type::Item);
                VerifyJobIsPromotion;

            end;
        }
        field(14228801; "Total Promotion Cost ELA"; Decimal)
        {
            Caption = 'Total Promotion Cost';
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Editable = false;
        }
        field(14228802; "Promotion Unit Cost ELA"; Decimal)
        {
            Caption = 'Promotion Unit Cost';
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';

            trigger OnValidate()
            var
                ltxt001: Label 'Please use the job task line %1 to update unit cost and re-run Create Planning Lines to update promotion unit cost on planning line.';
                lrecJob: Record Job;
                lrecJobTask: Record "Job Task";
            begin

                VerifyJobIsPromotion;
                if "Promotion Unit Cost ELA" <> xRec."Promotion Unit Cost ELA" then begin
                    if xRec."Promotion Unit Cost ELA" = 0 then begin
                        GetJob;
                        "Total Promotion Cost ELA" := Round("Promotion Unit Cost ELA" * Quantity, AmountRoundingPrecision);
                        UpdateAllPromoAmounts;
                    end else begin
                        Error(ltxt001, "Job Task No.");
                    end;
                end;

                Clear(lrecJob);
                Clear(lrecJobTask);
                if "Job No." <> '' then begin
                    if lrecJob.Get("Job No.") then begin
                        if ("Job Task No." <> '') then begin
                            lrecJobTask.SetRange(lrecJobTask."Job No.", "Job No.");
                            lrecJobTask.SetRange(lrecJobTask."Job Task No.", "Job Task No.");
                            if lrecJobTask.FindFirst then begin
                                if lrecJobTask."Rebate Type ELA" <> lrecJobTask."Rebate Type ELA"::" " then
                                    if (("Promotion Unit Cost ELA" <> xRec."Promotion Unit Cost ELA") and (xRec."Promotion Unit Cost ELA" <> 0)) then
                                        Error(gtxt006);
                            end;
                        end;
                    end;
                end;

            end;
        }
        field(14228803; "Promotion Unit Cost (LCY) ELA"; Decimal)
        {

            Caption = 'Promotion Unit Cost (LCY)';
            AutoFormatType = 2;
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Editable = false;

            trigger OnValidate()
            begin

                TestField(Type, Type::Item);
                VerifyJobIsPromotion;
            end;


        }
        field(14228804; "Ending Date ELA"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';

            trigger OnValidate()
            var
                lrecJob: Record Job;
                lrecJobTask: Record "Job Task";
            begin

                TestField(Type, Type::Item);
                VerifyJobIsPromotion;

                Clear(lrecJob);
                Clear(lrecJobTask);
                if "Job No." <> '' then begin
                    if lrecJob.Get("Job No.") then begin
                        if (("Job Task No." <> '') and ("Line No." <> 0)) then begin
                            lrecJobTask.SetRange(lrecJobTask."Job No.", "Job No.");
                            lrecJobTask.SetRange(lrecJobTask."Job Task No.", "Job Task No.");
                            if lrecJobTask.FindFirst then begin

                                if (
                                  (CheckUseParent)
                                ) then begin
                                    lrecJobTask := grecUseJobTask;
                                end;

                                if ((lrecJobTask."Starting Date ELA" <> 0D) or (lrecJobTask."Ending Date ELA" <> 0D)) then begin

                                    if (("Ending Date ELA" < lrecJobTask."Starting Date ELA") and ("Ending Date ELA" <> 0D)
                                      and (lrecJobTask."Starting Date ELA" <> 0D)) then
                                        Error(gtxt003);
                                    if (("Ending Date ELA" > lrecJobTask."Ending Date ELA") and ("Ending Date ELA" <> 0D)
                                      and (lrecJobTask."Ending Date ELA" <> 0D)) then
                                        Error(gtxt004);

                                end;
                            end;
                        end;
                    end;
                end;

            end;
        }
    }

    var

        Job: Record Job;

        CurrExchRate: Record "Currency Exchange Rate";

        UnitAmountRoundingPrecision: Decimal;
        AmountRoundingPrecision: Decimal;

        grecUseJobTask: Record "Job Task";
        gblnUseParent: Boolean;
        gtxt006: Label 'You cannot edit promotion unit cost for a planning line linked to task line with a rebate type.';
        gtxt003: Label 'You cannot have this date earlier than task line starting date.';
        gtxt004: Label 'You cannot have this date after than task line ending date.';


    procedure SetUpdateFromParent(precJobTask: Record "Job Task")
    begin

        grecUseJobTask := precJobTask;
        gblnUseParent := true;

    end;


    procedure ClearUpdateFromParent()
    begin

        grecUseJobTask.Reset;
        Clear(grecUseJobTask);
        Clear(gblnUseParent);

    end;

    local procedure VerifyJobIsPromotion()
    var
        ltxt000: Label 'Job No. %1 must be a Promotion';
    begin

        GetJob;

        if not Job.IsPromotion then
            Error(ltxt000, "Job No.");

    end;

    local procedure UpdateAllPromoAmounts()
    begin

        GetJob;
        UpdatePromoUnitCost;
        UpdateTotalPromoCost;

    end;

    local procedure UpdatePromoUnitCost()
    begin

        "Promotion Unit Cost (LCY) ELA" := Round(
          CurrExchRate.ExchangeAmtFCYToLCY(
          "Currency Date", "Currency Code",
          "Promotion Unit Cost ELA", "Currency Factor"),
          UnitAmountRoundingPrecision);

    end;

    local procedure UpdateTotalPromoCost()
    begin

        "Total Promotion Cost (LCY) ELA" := Round(
            CurrExchRate.ExchangeAmtFCYToLCY(
              "Currency Date", "Currency Code",
              "Total Promotion Cost ELA", "Currency Factor"),
            AmountRoundingPrecision);

    end;

    local procedure CheckUseParent() pbln: Boolean
    begin

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
            ClearUpdateFromParent;
            exit(false);
        end;

    end;

    local procedure CheckLinkedRebates(var precJobPlanLine: Record "Job Planning Line"): Boolean
    var
        lrecJobTask: Record "Job Task";
        lrecJob: Record Job;
        lrecRebateHeader: Record "Rebate Header ELA";
    begin

        Clear(lrecJob);
        Clear(lrecJobTask);
        if precJobPlanLine."Job No." <> '' then begin
            if lrecJob.Get(precJobPlanLine."Job No.") then begin
                if lrecJob.IsPromotion then begin
                    if ((precJobPlanLine."Job Task No." <> '') and (precJobPlanLine."Line No." <> 0)) then begin
                        lrecJobTask.SetRange(lrecJobTask."Job No.", precJobPlanLine."Job No.");
                        lrecJobTask.SetRange(lrecJobTask."Job Task No.", precJobPlanLine."Job Task No.");
                        if lrecJobTask.FindFirst then begin
                            if lrecJobTask."Rebate Type ELA" <> lrecJobTask."Rebate Type ELA"::" " then begin
                                Clear(lrecRebateHeader);
                                lrecRebateHeader.SetRange(lrecRebateHeader."Job No.", precJobPlanLine."Job No.");
                                lrecRebateHeader.SetRange(lrecRebateHeader."Job Task No.", precJobPlanLine."Job Task No.");
                                if lrecRebateHeader.FindSet then
                                    exit(true);
                            end;
                        end;
                    end;
                end;
            end;
        end;

        exit(false);

    end;

    local procedure GetJob()
    begin
        if ("Job No." <> Job."No.") and ("Job No." <> '') then
            Job.Get("Job No.");
    end;
}