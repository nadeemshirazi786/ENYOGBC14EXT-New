report 51008 "Batch Reopen Ship Date Orders"
{
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Batch Releassssssse Ship Date Orders';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Date; Date)
        {
            DataItemLinkReference = Date;
            DataItemTableView = SORTING("Period Type", "Period Start") ORDER(Ascending) WHERE("Period Type" = CONST(Date));
            dataitem("Sales Header"; "Sales Header")
            {
                DataItemLink = "Shipment Date" = FIELD("Period Start");
                DataItemLinkReference = Date;
                DataItemTableView = SORTING("Shipment Date", "Location Code", "Sell-to Customer No.") WHERE("Document Type" = CONST(Order));
                RequestFilterFields = "Shipment Date", "Location Code";

                trigger OnAfterGetRecord()
                var
                    lcduReleaseSalesDoc: Codeunit "Release Sales Document";
                    lrecSalesHeader: Record "Sales Header";
                begin
                    gdlgWindow.Update(2, "Shipment Date");
                    gdlgWindow.Update(3, "No.");

                    lrecSalesHeader := "Sales Header";

                    lcduReleaseSalesDoc.Reopen(lrecSalesHeader)
                end;
            }

            trigger OnAfterGetRecord()
            begin

                gdlgWindow.Update(1, "Period Start");
            end;

            trigger OnPreDataItem()
            begin
                SetFilter(Date."Period Start", gtxtDateFilter);

                gdlgWindow.Open(
                  Date.TableCaption + ' #1############### \ ' +
                  "Sales Header".FieldCaption("Shipment Date") + ' #2############### \ ' +
                  "Sales Header".FieldCaption("No.") + ' #3###############');
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

    trigger OnPostReport()
    var
        lrecSalesHeader: Record "Sales Header";
        lfrmSalesList: Page "Sales List";
        ljftext000: Label '%1 Orders Reopened Ok; %2 failed.';
    begin
        gdlgWindow.Close;

        lrecSalesHeader.Copy("Sales Header");
        lrecSalesHeader.SetRange(lrecSalesHeader.Status, lrecSalesHeader.Status::Released);

    end;

    trigger OnPreReport()
    begin

        gtxtDateFilter := "Sales Header".GetFilter("Shipment Date");
        if (gtxtDateFilter = '') then begin
            Error(jfText030, "Sales Header".FieldCaption("Date Filter"), gtxtDateFilter);
        end;
    end;

    var
        grecSalesHeader: Record "Sales Header";
        grecSalesLine: Record "Sales Line";
        gintNextLineNo: Integer;
        gdlgWindow: Dialog;
        JFText001: Label ' #1###############';
        JFText002: Label ' #2###############';
        JFText003: Label ' #3###############';
        jfText030: Label '%1 may not be ''%2''.';
        jfText031: Label '%2 from Standing Order already exists';
        jfText032: Label '; skipping order creation.';
        jfText033: Label 'Note: a non-"Standing Order" Order already exists for this date.';
        jfText034: Label '%1 is %2';
        jfText035: Label '%1 does not exist';
        gtxtDateFilter: Text[80];
        gintSuccess: Integer;
        gintFailure: Integer;
}

