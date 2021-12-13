report 14228910 "EN Fix Sales Payment"
{
    // ENSP1.00 2020-04-14 RP
    //     Created new Report

    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Payment Header"; "EN Sales Payment Header")
        {
            RequestFilterFields = "No.";
            dataitem("Sales Payment Line"; "EN Sales Payment Line")
            {
                DataItemLink = "Document No." = FIELD("No."), "Customer No." = FIELD("Customer No.");
                DataItemTableView = SORTING("Document No.", "Line No.") ORDER(Ascending);

                trigger OnAfterGetRecord()
                var
                    PstdSalesPmtLine: Record "EN Posted Sales Payment Line";
                begin
                    PstdSalesPmtLine.Init;
                    PstdSalesPmtLine."Document No." := PstdSalesPmtHdr."No.";
                    PstdSalesPmtLine."Line No." := "Line No.";
                    PstdSalesPmtLine."Customer No." := "Customer No.";
                    PstdSalesPmtLine.Type := Type;
                    PstdSalesPmtLine."No." := "No.";
                    PstdSalesPmtLine.Description := Description;
                    PstdSalesPmtLine.Amount := Amount;
                    PstdSalesPmtLine."Entry No." := 0;
                    PstdSalesPmtLine.Insert;
                end;

                trigger OnPostDataItem()
                begin
                    Commit;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if PstdSalesPmtHdr.Get("Posting No.") then
                    Error(StrSubstNo('Posting Sales payment header %1 already exists for payment %2', "Posting No.", "No."));

                Clear(PstdSalesPmtHdr);
                PstdSalesPmtHdr.Init;
                PstdSalesPmtHdr."No." := "Posting No.";
                PstdSalesPmtHdr."Customer No." := "Customer No.";
                PstdSalesPmtHdr."Customer Name" := "Customer Name";
                PstdSalesPmtHdr."Posting Date" := "Posting Date";
                PstdSalesPmtHdr."No. Series" := "No. Series";
                PstdSalesPmtHdr."Sales Payment No." := "No.";
                PstdSalesPmtHdr.Amount := Amount;
                PstdSalesPmtHdr."Amount Tendered" := "Amount Tendered";
                PstdSalesPmtHdr.Insert;
            end;

            trigger OnPostDataItem()
            var
                SalesPmtLine: Record "EN Sales Payment Line";
                SalesPmtTndr: Record "EN Sales Payment Tender Entry";
            begin

                SalesPmtTndr.Reset;
                SalesPmtTndr.SetRange("Document No.", "No.");
                if SalesPmtTndr.FindSet then
                    repeat
                        SalesPmtTndr."Document No." := "Posting No.";
                        SalesPmtTndr.Modify;
                    until SalesPmtTndr.Next = 0;

                SalesPmtLine.Reset;
                SalesPmtLine.SetRange("Document No.", "No.");
                SalesPmtLine.DeleteAll;
                Delete;
                Message(StrSubstNo('Payment %1 is moved', "No."));
                Commit;
            end;

            trigger OnPreDataItem()
            begin
                if GetFilter("No.") = '' then
                    Error('You must select a payment to clear');
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
        PstdSalesPmtHdr: Record "EN Posted Sales Payment Header";
}

