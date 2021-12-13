report 14228911 "EN Sales Payment - Unposted"
{
    // ENSP1.00 2020-04-14 HR
    //     Created new Report
    DefaultLayout = RDLC;
    RDLCLayout = './SalesPaymentUnposted.rdlc';

    Caption = 'Sales Payment';
    UsageCategory = Documents;

    dataset
    {
        dataitem("Sales Payment Header"; "EN Sales Payment Header")
        {
            CalcFields = Amount, "Amount Tendered";
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Customer No.", "Posting Date";
            column(ReportTitle; StrSubstNo(Text000, "No."))
            {
            }
            column(PageStr; Text001)
            {
            }
            column(SalesPaymentHeaderCustNo; "Customer No.")
            {
            }
            column(SalesPaymentHeaderCustName; "Customer Name")
            {
            }
            column(SalesPaymentHeaderPostingDate; "Posting Date")
            {
            }
            column(CompanyName; COMPANYPROPERTY.DisplayName)
            {
            }
            column(OrderHeader; Text002)
            {
            }
            column(OrderFooter; Text003)
            {
            }
            column(PaymentFooter; Text005)
            {
            }
            column(PaymentHeader; Text004)
            {
            }
            column(OnAccountAmount; Amount - "Amount Tendered")
            {
                AutoFormatType = 1;
            }
            column(SalesPaymentHeaderNo; "No.")
            {
            }
            dataitem("Sales Payment Line"; "EN Sales Payment Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document No.", "Line No.");
                column(SalesPaymentLineType; Type)
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentLineNo; "No.")
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentLineDesc; Description)
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentLineAmount; Amount)
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentLineDocNo; "Document No.")
                {
                }
            }
            dataitem("Sales Payment Tender Entry"; "EN Sales Payment Tender Entry")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document No.");
                column(SalesPaymentTenderEntryType; Type)
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentTenderEntryPaymentMethodCode; "Payment Method Code")
                {
                }
                column(SalesPaymentTenderEntryDesc; Description)
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
                column(SalesPaymentTenderEntryEntryNo; "Entry No.")
                {
                }
                column(SalesPaymentTenderEntryDocNo; "Document No.")
                {
                }
            }
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
        CustNoCaption = 'Customer No.:';
        CustNameCaption = 'Customer Name:';
        PostingDateCaption = 'Posting Date:';
        OnAccountAmountCaption = 'Amount On Account:';
        PaymentMethodCodeCaption = 'Payment Method';
    }

    var
        Text000: Label 'Sales Payment %1';
        Text001: Label 'Page ';
        Text002: Label 'Orders';
        Text003: Label 'Total Orders:';
        Text004: Label 'Payments';
        Text005: Label 'Total Payments:';
}

