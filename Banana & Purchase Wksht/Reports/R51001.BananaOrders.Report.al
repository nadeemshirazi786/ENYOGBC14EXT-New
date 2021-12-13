report 51001 "Banana Orders"
{
    DefaultLayout = RDLC;
    RDLCLayout = './BananaOrders.rdlc';


    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.") ORDER(Ascending) WHERE("Banana Worksheet" = FILTER(true));
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(USERID; UserId)
            {
            }
            column(ShipDate; ShipDate)
            {
            }
            column(BananaCount_9__5_; BananaCount[9] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_8__5_; BananaCount[8] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_7__5_; BananaCount[7] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_6__5_; BananaCount[6] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_5__5_; BananaCount[5] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_4__3_; BananaCount[4] [3])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_4__2_; BananaCount[4] [2])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_4__1_; BananaCount[4] [1])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_3__4_; BananaCount[3] [4])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_3__3_; BananaCount[3] [3])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_3__2_; BananaCount[3] [2])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_3__1_; BananaCount[3] [1])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_2__4_; BananaCount[2] [4])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_2__3_; BananaCount[2] [3])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_2__2_; BananaCount[2] [2])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_2__1_; BananaCount[2] [1])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_1__5_; BananaCount[1] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(CustTotal; CustTotal)
            {
                DecimalPlaces = 0 : 0;
            }
            column(PONumber_1_; PONumber[1])
            {
            }
            column(CustName_1_; CustName[1])
            {
            }
            column(CustNo_1_; CustNo[1])
            {
            }
            column(CustNo_2_; CustNo[2])
            {
            }
            column(CustName_2_; CustName[2])
            {
            }
            column(PONumber_2_; PONumber[2])
            {
            }
            column(BananaCount_9__5__Control1000000064; BananaCount[9] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_8__5__Control1000000077; BananaCount[8] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_7__5__Control1000000079; BananaCount[7] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_6__5__Control1000000080; BananaCount[6] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_5__5__Control1000000083; BananaCount[5] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_4__3__Control1000000085; BananaCount[4] [3])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_4__2__Control1000000086; BananaCount[4] [2])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_4__1__Control1000000087; BananaCount[4] [1])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_3__4__Control1000000088; BananaCount[3] [4])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_3__3__Control1000000090; BananaCount[3] [3])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_3__2__Control1000000091; BananaCount[3] [2])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_3__1__Control1000000092; BananaCount[3] [1])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_2__4__Control1000000093; BananaCount[2] [4])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_2__3__Control1000000095; BananaCount[2] [3])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_2__2__Control1000000096; BananaCount[2] [2])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_2__1__Control1000000097; BananaCount[2] [1])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_1__5__Control1000000099; BananaCount[1] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(Customer__Chain_Name_; "Chain Name")
            {
            }
            column(CustTotal_Control1000000107; CustTotal)
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_9__5__Control1000000066; BananaCount[9] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_8__5__Control1000000068; BananaCount[8] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_7__5__Control1000000070; BananaCount[7] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_6__5__Control1000000071; BananaCount[6] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_5__5__Control1000000074; BananaCount[5] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_4__3__Control1000000101; BananaCount[4] [3])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_4__2__Control1000000103; BananaCount[4] [2])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_4__1__Control1000000104; BananaCount[4] [1])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_3__4__Control1000000105; BananaCount[3] [4])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_3__3__Control1000000109; BananaCount[3] [3])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_3__2__Control1000000110; BananaCount[3] [2])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_3__1__Control1000000111; BananaCount[3] [1])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_2__4__Control1000000113; BananaCount[2] [4])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_2__3__Control1000000114; BananaCount[2] [3])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_2__2__Control1000000115; BananaCount[2] [2])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_2__1__Control1000000116; BananaCount[2] [1])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_1__5__Control1000000118; BananaCount[1] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(CustTotal_Control1000000120; CustTotal)
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_2__5_; BananaCount[2] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_3__5_; BananaCount[3] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(BananaCount_4__5_; BananaCount[4] [5])
            {
                DecimalPlaces = 0 : 0;
            }
            column(Banana_OrdersCaption; Banana_OrdersCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Label_5_Caption; Label_5_CaptionLbl)
            {
            }
            column(BananaCount_8__5_Caption; BananaCount_8__5_CaptionLbl)
            {
            }
            column(BananaCount_7__5_Caption; BananaCount_7__5_CaptionLbl)
            {
            }
            column(BananaCount_6__5_Caption; BananaCount_6__5_CaptionLbl)
            {
            }
            column(BananaCount_5__5_Caption; BananaCount_5__5_CaptionLbl)
            {
            }
            column(BananaCount_1__5_Caption; BananaCount_1__5_CaptionLbl)
            {
            }
            column(CustTotalCaption; CustTotalCaptionLbl)
            {
            }
            column(PONumber_1_Caption; PONumber_1_CaptionLbl)
            {
            }
            column(CustName_1_Caption; CustName_1_CaptionLbl)
            {
            }
            column(CustNo_1_Caption; CustNo_1_CaptionLbl)
            {
            }
            column(Petite_Caption; Petite_CaptionLbl)
            {
            }
            column(Label_Caption; Label_CaptionLbl)
            {
            }
            column(Premium_Caption; Premium_CaptionLbl)
            {
            }
            column(BananaCount_2__1_Caption; BananaCount_2__1_CaptionLbl)
            {
            }
            column(BananaCount_2__2_Caption; BananaCount_2__2_CaptionLbl)
            {
            }
            column(BananaCount_2__3_Caption; BananaCount_2__3_CaptionLbl)
            {
            }
            column(BananaCount_2__4_Caption; BananaCount_2__4_CaptionLbl)
            {
            }
            column(BananaCount_3__3_Caption; BananaCount_3__3_CaptionLbl)
            {
            }
            column(BananaCount_3__2_Caption; BananaCount_3__2_CaptionLbl)
            {
            }
            column(BananaCount_3__1_Caption; BananaCount_3__1_CaptionLbl)
            {
            }
            column(NGCaption; NGCaptionLbl)
            {
            }
            column(BananaCount_4__1_Caption; BananaCount_4__1_CaptionLbl)
            {
            }
            column(BananaCount_4__2_Caption; BananaCount_4__2_CaptionLbl)
            {
            }
            column(BananaCount_4__3_Caption; BananaCount_4__3_CaptionLbl)
            {
            }
            column(Report_TotalsCaption; Report_TotalsCaptionLbl)
            {
            }
            column(Customer_No_; "No.")
            {
            }

            trigger OnAfterGetRecord()
            var
                row: Integer;
                col: Integer;
                i: Integer;
                j: Integer;
            begin
                Clear(BananaCount);
                Clear(CustTotal);
                Clear(CustNo);
                Clear(CustName);
                Clear(PONumber);
                Clear(PO);

                BananaWS.SetRange("Customer No.", "No.");
                if BananaWS.Find('-') then begin
                    repeat
                        row := 0;
                        if BananaWS.Quantity <> 0 then begin
                            case BananaWS."Item No." of
                                '1':
                                    row := 1;
                                '2':
                                    row := 2;
                                '3':
                                    row := 3;
                                '4':
                                    row := 4;
                                '5':
                                    row := 5;
                                '6':
                                    row := 6;
                                '300':
                                    row := 7;
                                '124':
                                    row := 8;
                                '67013':
                                    row := 9;
                            end;
                            case BananaWS."Preference Code" of
                                'COL':
                                    col := 1;
                                'BR':
                                    col := 2;
                                'GR':
                                    col := 3;
                                'NG':
                                    col := 4;
                                else
                                    col := 5;
                            end;
                            if row <> 0 then
                                BananaCount[row] [col] += BananaWS.Quantity;
                        end;

                        if BananaWS."PO Number" <> '' then
                            PO := BananaWS."PO Number";
                    until BananaWS.Next = 0;

                    for i := 1 to 9 do begin
                        for j := 1 to 4 do
                            BananaCount[i] [5] += BananaCount[i] [j];
                        CustTotal += BananaCount[i] [5];
                    end;
                end;

                ChainName := "Chain Name";
                if Next = 0 then
                    LastRecordInGroup := true
                else begin
                    LastRecordInGroup := ChainName <> "Chain Name";
                    Next(-1);
                end;
            end;

            trigger OnPreDataItem()
            begin
                BananaWS.SetCurrentKey("Customer No.", "Ship-to Code", "Item No.", "Variant Code", "Location Code", "Preference Code", Date);
                BananaWS.SetRange(Date, ShipDate);
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
        BananaWS: Record "Banana Worksheet";
        LastFieldNo: Integer;
        FooterPrinted: Boolean;
        ShipDate: Date;
        Summary: Boolean;
        BananaCount: array[9, 5] of Decimal;
        CustNo: array[2] of Code[20];
        CustName: array[2] of Text[30];
        PONumber: array[2] of Code[20];
        PO: Code[20];
        CustTotal: Decimal;
        ChainName: Code[10];
        LastRecordInGroup: Boolean;
        gcodeLocationCode: Code[10];
        Banana_OrdersCaptionLbl: Label 'Banana Orders';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Label_5_CaptionLbl: Label 'Label 5#';
        BananaCount_8__5_CaptionLbl: Label 'Coco';
        BananaCount_7__5_CaptionLbl: Label 'Plt Gr';
        BananaCount_6__5_CaptionLbl: Label 'Org';
        BananaCount_5__5_CaptionLbl: Label 'Baby';
        BananaCount_1__5_CaptionLbl: Label 'Bags';
        CustTotalCaptionLbl: Label 'Total';
        PONumber_1_CaptionLbl: Label 'PO Number';
        CustName_1_CaptionLbl: Label 'Customer Name';
        CustNo_1_CaptionLbl: Label 'Cust No.';
        Petite_CaptionLbl: Label ' Petite ';
        Label_CaptionLbl: Label ' Label ';
        Premium_CaptionLbl: Label ' Premium ';
        BananaCount_2__1_CaptionLbl: Label 'Col';
        BananaCount_2__2_CaptionLbl: Label 'Br';
        BananaCount_2__3_CaptionLbl: Label 'Gr';
        BananaCount_2__4_CaptionLbl: Label 'NG';
        BananaCount_3__3_CaptionLbl: Label 'Gr';
        BananaCount_3__2_CaptionLbl: Label 'Br';
        BananaCount_3__1_CaptionLbl: Label 'Col';
        NGCaptionLbl: Label 'NG';
        BananaCount_4__1_CaptionLbl: Label 'Col';
        BananaCount_4__2_CaptionLbl: Label 'Br';
        BananaCount_4__3_CaptionLbl: Label 'Gr';
        Report_TotalsCaptionLbl: Label 'Report Totals';

    [Scope('Internal')]
    procedure SetShipDate(dt: Date)
    begin
        ShipDate := dt;
    end;
}

