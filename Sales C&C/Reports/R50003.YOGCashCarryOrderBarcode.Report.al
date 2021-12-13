report 50003 "YOG Cash & Carry Order Barcode"
{
    // EN1.00 2021-07-15 NA
    //   Report Created.
    DefaultLayout = RDLC;
    RDLCLayout = './YOGCashCarryOrderBarcode.rdlc';


    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING ("Document Type", "No.") ORDER(Ascending);
            column(No_SalesHeader; "Sales Header"."No.")
            {
            }

            trigger OnPreDataItem()
            begin
                IF AllOrderNo <> '' THEN
                    "Sales Header".SETRANGE("No.", AllOrderNo);
                IF OrderNo <> '' THEN
                    "Sales Header".SETRANGE("No.", OrderNo)
                ELSE
                    EXIT;
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

    trigger OnInitReport()
    begin
        CLEAR(OrderNo);
    end;

    var
        OrderNo: Code[20];
        AllOrderNo: Code[20];

    [Scope('Internal')]
    procedure SetOrderNo(POrderNo: Code[20])
    begin
        OrderNo := POrderNo;
    end;

    [Scope('Internal')]
    procedure SerAllOrder(PAllOrderNo: Code[20])
    begin
        AllOrderNo := PAllOrderNo;
    end;
}

