report 14228913 "EN Sales Payment Daily Detail"
{
    // ENSP1.00 2020-04-14 HR
    //     Created new Report
    DefaultLayout = RDLC;
    RDLCLayout = './SalesPaymentDailyDetail.rdlc';

    Caption = 'Sales Payment - Daily Detail';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Sales Payment Header"; "EN Sales Payment Header")
        {
            DataItemTableView = SORTING("No.");

            trigger OnAfterGetRecord()
            begin
                SalesPayment.TransferFields("Sales Payment Header");
                SalesPayment.Insert;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Posting Date", PostingDate);
            end;
        }
        dataitem("Posted Sales Payment Header"; "EN Posted Sales Payment Header")
        {
            DataItemTableView = SORTING("No.");

            trigger OnAfterGetRecord()
            begin
                SalesPayment.TransferFields("Posted Sales Payment Header");
                SalesPayment.Insert;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Posting Date", PostingDate);
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number);
            dataitem("Sales Payment Tender Entry"; "EN Sales Payment Tender Entry")
            {
                DataItemTableView = SORTING("Document No.") WHERE(Type = FILTER(<> Void), Result = FILTER(" " | Posted));
                column(SalesPaymentTenderEntryCustNo; "Customer No.")
                {
                    IncludeCaption = true;
                }
                column(CompanyName; CompanyInfo.Name)
                {
                }
                column(PostingDate; StrSubstNo(Text002, PostingDate))
                {
                }
                column(SalesPaymentTenderEntryPaymentMethodCode; "Payment Method Code")
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentTenderEntryAmount; Amount)
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentTenderEntryCardCheckNo; "Card/Check No.")
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentTenderEntryType; Type)
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentCustName; SalesPayment."Customer Name")
                {
                }

                trigger OnPreDataItem()
                begin
                    SetRange("Document No.", SalesPayment."No.");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                    SalesPayment.Find('-')
                else
                    SalesPayment.Next;
            end;

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, SalesPayment.Count);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PostingDate; PostingDate)
                    {
                        Caption = 'Posting Date';
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
        CustNameCaption = 'Customer Name';
        ReportTitleCaption = 'Sales Payment Daily Detail';
        PageCaption = 'Page';
    }

    trigger OnInitReport()
    begin
        PostingDate := WorkDate;
    end;

    trigger OnPreReport()
    begin
        if PostingDate = 0D then
            Error(Text001);
        CompanyInfo.Get;
    end;

    var
        CompanyInfo: Record "Company Information";
        SalesPayment: Record "EN Posted Sales Payment Header" temporary;
        Text001: Label 'Posting Date must be entered.';
        PaymentMethod: Record "Payment Method";
        PostingDate: Date;
        Text002: Label 'Transactions Posted %1';
}

