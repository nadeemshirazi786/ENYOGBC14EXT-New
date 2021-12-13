report 14229407 "Delete Job Promo Rebates ELA"
{
    //ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //   The report deletes existing rebates for promotional jobs based on task lines of posting type with existing rebates with
    //   no rebate ledger entries.


    ProcessingOnly = true;

    dataset
    {
        dataitem(Job; Job)
        {
            DataItemTableView = SORTING("No.");
            dataitem("Job Task"; "Job Task")
            {
                DataItemLink = "Job No." = FIELD("No.");
                RequestFilterFields = "Job Task No.";

                trigger OnAfterGetRecord()
                begin
                    //<ENRE1.00>
                    if grecJob."Promotion ELA" then begin
                        if ((grecJob."No." <> '') and ("Job Task Type" = "Job Task Type"::Posting)) then begin
                            //Check if any entries exists
                            "Job Task".CheckJobRebateEntryExists("Job Task");
                            //Delete Job Task Rebates
                            "Job Task".DeleteRebateLines("Job Task");
                            "Job Task".Modify;
                        end;
                    end;
                    //</ENRE1.00>
                end;

                trigger OnPreDataItem()
                begin
                    //<ENRE1.00>
                    SetFilter("Job Task"."Job Task Type", '%1', "Job Task"."Job Task Type"::Posting);
                    //</ENRE1.00>
                end;
            }

            trigger OnAfterGetRecord()
            begin
                //<ENRE1.00>
                Clear(grecJob);
                if not Job."Promotion ELA" then
                    CurrReport.Skip
                else
                    grecJob := Job;
                //</ENRE1.00>
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        grecJob: Record Job;
        grecJobTask: Record "Job Task";
}

