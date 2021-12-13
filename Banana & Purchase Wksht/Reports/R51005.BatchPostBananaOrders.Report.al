report 51005 "Batch Post Banana Orders"
{
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Batch Post Banana Orders';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.");
            RequestFilterFields = "Shipment Date", "Order Template Location ELA", "No.", Status, "Location Code";
            RequestFilterHeading = 'Sales Order';

            trigger OnAfterGetRecord()
            begin
                if CalcInvDisc then
                    CalculateInvoiceDiscount;

                Counter := Counter + 1;
                Window.Update(1, "No.");
                Window.Update(2, Round(Counter / CounterTotal * 10000, 1));
                Ship := ShipReq;
                Invoice := InvReq;
                Clear(SalesPost);

                gcduJXFoundation.jfCheckSalesBackorder("Sales Header");

                Commit;

                BananaWrkshtNewFunctions.SetPostingDate(ReplacePostingDate, ReplaceDocumentDate, PostingDateReq);
                if IsApprovedForPostingBatch then
                    if SalesPost.Run("Sales Header") then begin
                        CounterOK := CounterOK + 1;
                        if MarkedOnly then
                            Mark(false);
                    end;
            end;

            trigger OnPostDataItem()
            begin
                Window.Close;
                Message(Text002, CounterOK, CounterTotal);
            end;

            trigger OnPreDataItem()
            begin
                if ReplacePostingDate and (PostingDateReq = 0D) then
                    Error(Text000);

                CounterTotal := Count;
                Window.Open(Text001);

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
                    field(Ship; ShipReq)
                    {
                        Caption = 'Ship';
                    }
                    field(Invoice; InvReq)
                    {
                        Caption = 'Invoice';
                    }
                    field(PostingDate; PostingDateReq)
                    {
                        Caption = 'Posting Date';
                    }
                    field(ReplacePostingDate; ReplacePostingDate)
                    {
                        Caption = 'Replace Posting Date';

                        trigger OnValidate()
                        begin
                            if ReplacePostingDate then
                                Message(Text003);
                        end;
                    }
                    field(ReplaceDocumentDate; ReplaceDocumentDate)
                    {
                        Caption = 'Replace Document Date';
                    }
                    field(CalcInvDisc; CalcInvDisc)
                    {
                        Caption = 'Calc. Inv. Discount';

                        trigger OnValidate()
                        begin
                            SalesSetup.Get;
                            SalesSetup.TestField("Calc. Inv. Discount", false);
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            SalesSetup.Get;
            CalcInvDisc := SalesSetup."Calc. Inv. Discount";
            ReplacePostingDate := false;
            ReplaceDocumentDate := false;
        end;
    }

    labels
    {
    }

    var
        Text000: Label 'Please enter the posting date.';
        Text001: Label 'Posting orders  #1########## @2@@@@@@@@@@@@@';
        Text002: Label '%1 orders out of a total of %2 have now been posted.';
        Text003: Label 'The exchange rate associated with the new posting date on the sales header will not apply to the sales lines.';
        SalesLine: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
        SalesCalcDisc: Codeunit "Sales-Calc. Discount";
        SalesPost: Codeunit "Sales-Post";
        BananaWrkshtNewFunctions: Codeunit BananaWrkshtNewFunctions;
        Window: Dialog;
        ShipReq: Boolean;
        InvReq: Boolean;
        PostingDateReq: Date;
        CounterTotal: Integer;
        Counter: Integer;
        CounterOK: Integer;
        ReplacePostingDate: Boolean;
        ReplaceDocumentDate: Boolean;
        CalcInvDisc: Boolean;
        gcduJXFoundation: Codeunit BananaWrkshtCustomFunctions;

    [Scope('Internal')]
    procedure CalculateInvoiceDiscount()
    begin
        SalesLine.Reset;
        SalesLine.SetRange("Document Type", "Sales Header"."Document Type");
        SalesLine.SetRange("Document No.", "Sales Header"."No.");
        if SalesLine.FindFirst then
            if SalesCalcDisc.Run(SalesLine) then begin
                "Sales Header".Get("Sales Header"."Document Type", "Sales Header"."No.");
                Commit;
            end;
    end;

    [Scope('Internal')]
    procedure InitializeRequest(ShipParam: Boolean; InvoiceParam: Boolean; PostingDateParam: Date; ReplacePostingDateParam: Boolean; ReplaceDocumentDateParam: Boolean; CalcInvDiscParam: Boolean)
    begin
        ShipReq := ShipParam;
        InvReq := InvoiceParam;
        PostingDateReq := PostingDateParam;
        ReplacePostingDate := ReplacePostingDateParam;
        ReplaceDocumentDate := ReplaceDocumentDateParam;
        CalcInvDisc := CalcInvDiscParam;
    end;
}

