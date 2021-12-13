table 14229417 "Job Promotion Customers ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //   - Create table to store customer list for a promotional job.
    // 
    // ENRE1.00
    //   - Add additional logic when job is single promotional customer only.
    // 
    // ENRE1.00
    //   - Add additional logic when job promotional customer name.
    // 
    // ENRE1.00
    //   20110406 - do not allow customers to be changed if ledgers exist
    // 


    DrillDownPageID = "Job Promotion Customers ELA"; //Job Promotion Customers
    LookupPageID = "Job Promotion Customers ELA";

    fields
    {
        field(10; "Job No."; Code[20])
        {
            Description = 'ENRE1.00';
            NotBlank = true;
            TableRelation = Job;

            trigger OnValidate()
            begin
                //<ENRE1.00>
                GetJob;
                //</ENRE1.00>
            end;
        }
        field(20; "Customer No."; Code[20])
        {
            Description = 'ENRE1.00';
            NotBlank = true;
            TableRelation = Customer;

            trigger OnValidate()
            begin
                //<ENRE1.00>
                if ((xRec."Customer No." <> '') and (xRec."Customer No." <> "Customer No.")) then begin
                    Clear(grecJob3);
                    if "Job No." <> '' then
                        if grecJob3.Get("Job No.") then begin
                            //<ENRE1.00>
                            if grecJob3.JobLedgEntryExistFunc then
                                Error(gText000, grecJob3."No.");
                            //</ENRE1.00>

                            if grecJob3.CountJobPromoCust(grecJob3) = 1 then begin
                                grecJob3."Promotion Customer No. ELA" := "Customer No.";
                                //<ENRE1.00>
                                Clear(grecCust);
                                if grecCust.Get("Customer No.") then
                                    grecJob3."Promotion Customer Name ELA" := grecCust.Name;
                                //</ENRE1.00>
                                grecJob3.Modify;
                            end;
                        end;
                end;
                //</ENRE1.00>
            end;
        }
        field(30; "Customer Name"; Text[100])
        {
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Customer No.")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Job No.", "Customer No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        lrecJobPromoCust: Record "Job Promotion Customers ELA";
    begin
        //<ENRE1.00>
        if not CheckJobOpenStatus(Rec) then
            Error(gtxt001, "Job No.");
        if CheckJobRebatesExist(Rec) then
            Error(gtxt002, "Job No.");
        //</ENRE1.00>

        //<ENRE1.00>
        Clear(grecJob2);
        if "Job No." <> '' then
            if grecJob2.Get("Job No.") then begin
                if grecJob2.CountJobPromoCust(grecJob2) > 2 then begin
                    Clear(grecJob2."Promotion Customer No. ELA");
                    grecJob2.Modify;
                end;

                if grecJob2.CountJobPromoCust(grecJob2) = 2 then begin
                    Clear(lrecJobPromoCust);
                    lrecJobPromoCust.SetRange(lrecJobPromoCust."Job No.", "Job No.");
                    lrecJobPromoCust.SetFilter(lrecJobPromoCust."Customer No.", '<>%1', "Customer No.");
                    if lrecJobPromoCust.FindFirst then
                        grecJob2."Promotion Customer No. ELA" := lrecJobPromoCust."Customer No.";
                    //<ENRE1.00>
                    Clear(grecCust);
                    if grecCust.Get(lrecJobPromoCust."Customer No.") then
                        grecJob2."Promotion Customer Name ELA" := grecCust.Name;
                    //</ENRE1.00>
                    grecJob2.Modify;
                end;

                if grecJob2.CountJobPromoCust(grecJob2) = 1 then begin
                    Clear(grecJob2."Promotion Customer No. ELA");
                    //<ENRE1.00>
                    Clear(grecJob2."Promotion Customer Name ELA");
                    //</ENRE1.00>
                    grecJob2.Modify;
                end;
            end;
        //</ENRE1.00>
    end;

    trigger OnInsert()
    begin
        //<ENRE1.00>
        if not CheckJobOpenStatus(Rec) then
            Error(gtxt001, "Job No.");
        if CheckJobRebatesExist(Rec) then
            Error(gtxt002, "Job No.");
        //</ENRE1.00>
        //<ENRE1.00>
        Clear(grecJob2);
        if "Job No." <> '' then
            if grecJob2.Get("Job No.") then begin
                if grecJob2.CountJobPromoCust(grecJob2) = 0 then begin
                    grecJob2."Promotion Customer No. ELA" := "Customer No.";
                    //<ENRE1.00>
                    Clear(grecCust);
                    if grecCust.Get("Customer No.") then
                        grecJob2."Promotion Customer Name ELA" := grecCust.Name;
                    //</ENRE1.00>
                    grecJob2.Modify;
                end;
                if grecJob2.CountJobPromoCust(grecJob2) >= 1 then begin
                    Clear(grecJob2."Promotion Customer No. ELA");
                    //<ENRE1.00>
                    Clear(grecJob2."Promotion Customer Name ELA");
                    //</ENRE1.00>
                    grecJob2.Modify;
                end;
            end;
        //</ENRE1.00>
    end;

    trigger OnModify()
    begin
        //<ENRE1.00>
        if not CheckJobOpenStatus(Rec) then
            Error(gtxt001, "Job No.");
        if CheckJobRebatesExist(Rec) then
            Error(gtxt002, "Job No.");
        //</ENRE1.00>
    end;

    trigger OnRename()
    begin
        //<ENRE1.00>
        if not CheckJobOpenStatus(Rec) then
            Error(gtxt001, "Job No.");
        if CheckJobRebatesExist(Rec) then
            Error(gtxt002, "Job No.");
        //</ENRE1.00>
    end;

    var
        grecJob: Record Job;
        grecJob2: Record Job;
        grecJob3: Record Job;
        gtxt001: Label 'Approval Status must be open in Job %1.';
        gtxt002: Label 'The job %1 has existing rebates. Please delete all rebates before changing job promotion customers.';
        grecCust: Record Customer;
        gText000: Label 'You cannot change the customers on Job No. %1 because it has ledger entries.';


    procedure GetJob()
    var
        ltxt001: Label 'You cannot enter promotion customers for a Non-promotion Job. Please check the Promotion checkbox on Promotion tab.';
    begin
        //<ENRE1.00>
        TestField("Job No.");
        if grecJob.Get("Job No.") then
            if not grecJob."Promotion ELA" then
                Error(ltxt001);
        //</ENRE1.00>
    end;


    procedure CheckJobOpenStatus(precJobPromoCust: Record "Job Promotion Customers ELA"): Boolean
    var
        lrecJob: Record Job;
    begin
        //<ENRE1.00>
        Clear(lrecJob);
        if precJobPromoCust."Job No." <> '' then begin
            if lrecJob.Get(precJobPromoCust."Job No.") then begin
                if lrecJob."Approval Status ELA" = lrecJob."Approval Status ELA"::Open then
                    exit(true)
                else
                    exit(false);
            end;
        end;
        exit(false);
        //</ENRE1.00>
    end;


    procedure CheckJobRebatesExist(precJobPromoCust: Record "Job Promotion Customers ELA"): Boolean
    var
        lrecJobTask: Record "Job Task";
        lrecJob: Record Job;
    begin
        //<ENRE1.00>
        Clear(lrecJob);
        Clear(lrecJobTask);
        if precJobPromoCust."Job No." <> '' then begin
            if lrecJob.Get(precJobPromoCust."Job No.") then begin
                if lrecJob."Promotion ELA" then begin
                    lrecJobTask.SetRange(lrecJobTask."Job No.", lrecJob."No.");
                    lrecJobTask.SetRange(lrecJobTask."Job Task Type", lrecJobTask."Job Task Type"::Posting);
                    lrecJobTask.SetFilter(lrecJobTask."No. of Rebates ELA", '>%1', 0);
                    if lrecJobTask.FindSet then
                        exit(true);
                end;
            end;
        end;
        exit(false);
        //</ENRE1.00>
    end;
}

