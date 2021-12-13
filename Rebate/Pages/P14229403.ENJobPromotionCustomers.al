page 14229403 "Job Promotion Customers ELA"
{

    // ENRE1.00
    //   - Add Job Prmotional fields and logic

    Caption = 'Job Promotion Customers';
    PageType = List;
    SourceTable = "Job Promotion Customers ELA";
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Job No."; "Job No.")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            // group("<Action23019006>")
            // {
            //     Caption = 'Job Promotion';
            //     action("Insert Promotional Jobs")
            //     {
            //         ApplicationArea = All;
            //         Caption = 'Insert Promotional Jobs';
            //         Image = InsertAccount;

            //         trigger OnAction()
            //         var
            //             lrepInsertJobPromoCust: Report "Insert Job Promotional Cust.";
            //             lrecJob: Record Job;
            //         begin
            //             //<ENRE1.00>
            //             Clear(lrepInsertJobPromoCust);
            //             if lrecJob.Get("Job No.") then begin
            //                 lrecJob.SetRange(lrecJob."No.", "Job No.");
            //                 lrepInsertJobPromoCust.SetTableView(lrecJob);
            //                 lrepInsertJobPromoCust.RunModal;
            //             end;
            //             //</ENRE1.00>
            //         end;
            //     }
            //}
        }
    }
}

