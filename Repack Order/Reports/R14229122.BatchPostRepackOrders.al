report 14229122 "EN Batch Post Repack Orders"
{


    Caption = 'Batch Post Repack Orders';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Repack Order"; "EN Repack Order")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            var
                RepackBatchPostMgt: Codeunit "EN Repack Batch Post Mgt.";
            begin

                RepackBatchPostMgt.RunBatch("Repack Order", ReplacePostingDate, PostingDateReq, TransReq, ProdReq);

                CurrReport.Break;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(TransReq; TransReq)
                    {
                        Caption = 'Transfer';
                    }
                    field(ProdReq; ProdReq)
                    {
                        Caption = 'Produce';
                    }
                    field(PostingDateReq; PostingDateReq)
                    {
                        Caption = 'Posting Date';
                    }
                    field(ReplacePostingDate; ReplacePostingDate)
                    {
                        Caption = 'Replace Posting Date';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        PostingDateReq: Date;
        TransReq: Boolean;
        ProdReq: Boolean;
        ReplacePostingDate: Boolean;
}

