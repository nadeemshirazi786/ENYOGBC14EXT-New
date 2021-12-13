report 51002 "Banana Truck Route Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './BananaTruckRouteReport.rdlc';


    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING("Shipment Date", "Order Template Location ELA", "Route Stop Sequence") WHERE("Order Template Location ELA" = FILTER('B*' | ''));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Order Template Location ELA", "Bill-to Name", "Shipment Date";
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(USERID; UserId)
            {
            }
            column(Date; Date)
            {
            }
            column(Sales_Header__Order_Template_Location_; "Supply Chain Group Code ELA")
            {
            }
            column(Sales_Header__Sell_to_Customer_No__; "Sell-to Customer No.")
            {
            }
            column(Sales_Header__Sales_Header___Bill_to_Name_; "Sales Header"."Bill-to Name")
            {
            }
            column(Item2col; Item2col)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item2br; Item2br)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item2gr; Item2gr)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item1; Item1)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item5; Item5)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item2ng; Item2ng)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item6; Item6)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item10002; Item10002)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item12022; Item12022)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Spanish; Spanish)
            {
                DecimalPlaces = 0 : 0;
            }
            column(NEPC; NEPC)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Sales_Header__No__; "No.")
            {
            }
            column(Item3ng; Item3ng)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item3gr; Item3gr)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item3br; Item3br)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item3col; Item3col)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item4col; Item4col)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item4br; Item4br)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item4gr; Item4gr)
            {
                DecimalPlaces = 0 : 0;
            }
            column(DG; DG)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item1br; Item1br)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item1col; Item1col)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Sales_Header__Sales_Header___Route_Stop_Sequence_; "Sales Header"."Route Stop Sequence")
            {
            }
            column(Item2gr_Control31; Item2gr)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item2br_Control32; Item2br)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item2col_Control33; Item2col)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item1_Control36; Item1)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item5_Control40; Item5)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item2ng_Control37; Item2ng)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item12022_Control14; Item12022)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item10002_Control16; Item10002)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item6_Control21; Item6)
            {
                DecimalPlaces = 0 : 0;
            }
            column(NEPC_Control50; NEPC)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Spanish_Control51; Spanish)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item3col_Control73; Item3col)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item3br_Control74; Item3br)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item3gr_Control75; Item3gr)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item3ng_Control76; Item3ng)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item4col_Control77; Item4col)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item4br_Control78; Item4br)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item4gr_Control79; Item4gr)
            {
                DecimalPlaces = 0 : 0;
            }
            column(DG_Control80; DG)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item2col___Item2br___Item2gr___Item2ng; Item2col + Item2br + Item2gr + Item2ng)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item3col___Item3br___Item3gr___Item3ng; Item3col + Item3br + Item3gr + Item3ng)
            {
                DecimalPlaces = 0 : 0;
                Description = '0:0';
            }
            column(Item4col___Item4br___Item4gr_; Item4col + Item4br + Item4gr)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item1br_Control18; Item1br)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item1col_Control114; Item1col)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item1_Control84; Item1)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item2col_Control85; Item2col)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item2br_Control86; Item2br)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item2gr_Control87; Item2gr)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item2ng_Control88; Item2ng)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item3col_Control89; Item3col)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item3br_Control90; Item3br)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item3gr_Control91; Item3gr)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item3ng_Control92; Item3ng)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item4col_Control93; Item4col)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item4br_Control94; Item4br)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item4gr_Control95; Item4gr)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item5_Control96; Item5)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item6_Control97; Item6)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item10002_Control98; Item10002)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item12022_Control99; Item12022)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Spanish_Control101; Spanish)
            {
                DecimalPlaces = 0 : 0;
            }
            column(NEPC_Control102; NEPC)
            {
                DecimalPlaces = 0 : 0;
            }
            column(DG_Control103; DG)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item1br_Control117; Item1br)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Item1col_Control118; Item1col)
            {
                DecimalPlaces = 0 : 0;
            }
            column(Banana_Truck_Route_ReportCaption; Banana_Truck_Route_ReportCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Cust_No_Caption; Cust_No_CaptionLbl)
            {
            }
            column(DescriptionCaption; DescriptionCaptionLbl)
            {
            }
            column(ColCaption; ColCaptionLbl)
            {
            }
            column(GrCaption; GrCaptionLbl)
            {
            }
            column(NGCaption; NGCaptionLbl)
            {
            }
            column(BrCaption; BrCaptionLbl)
            {
            }
            column(BabyCaption; BabyCaptionLbl)
            {
            }
            column(OrgCaption; OrgCaptionLbl)
            {
            }
            column(PltCaption; PltCaptionLbl)
            {
            }
            column(CocoCaption; CocoCaptionLbl)
            {
            }
            column(SpnshCaption; SpnshCaptionLbl)
            {
            }
            column(NEPCCaption; NEPCCaptionLbl)
            {
            }
            column(Premium____________Caption; Premium____________CaptionLbl)
            {
            }
            column(Label_______________Caption; Label_______________CaptionLbl)
            {
            }
            column(ColCaption_Control54; ColCaption_Control54Lbl)
            {
            }
            column(BrCaption_Control55; BrCaption_Control55Lbl)
            {
            }
            column(GrCaption_Control56; GrCaption_Control56Lbl)
            {
            }
            column(NGCaption_Control57; NGCaption_Control57Lbl)
            {
            }
            column(Inv_No_Caption; Inv_No_CaptionLbl)
            {
            }
            column(Earth__________Caption; Earth__________CaptionLbl)
            {
            }
            column(GrCaption_Control69; GrCaption_Control69Lbl)
            {
            }
            column(BrCaption_Control70; BrCaption_Control70Lbl)
            {
            }
            column(ColCaption_Control71; ColCaption_Control71Lbl)
            {
            }
            column(Dry_GdsCaption; Dry_GdsCaptionLbl)
            {
            }
            column(BrCaption_Control12; BrCaption_Control12Lbl)
            {
            }
            column(GrCaption_Control13; GrCaption_Control13Lbl)
            {
            }
            column(Bags__________Caption; Bags__________CaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            column(Stop__Caption; Stop__CaptionLbl)
            {
            }
            column(Route_Totals_Caption; Route_Totals_CaptionLbl)
            {
            }
            column(ReportTotals_Caption; ReportTotals_CaptionLbl)
            {
            }
            column(Sales_Header_Document_Type; "Document Type")
            {
            }
            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");
                PrintOnlyIfDetail = false;

                trigger OnAfterGetRecord()
                begin
                    if "No." <> '' then ItemInfo.Get("No.");
                    if "Sell-to Customer No." <> '' then CustInfo.Get("Sell-to Customer No.");
                    Quantity := Sign * Quantity;
                    case "No." of
                        '1':
                            begin
                                Item1br := Item1br + "Breaking Quantity";
                                Item1col := Item1col + "Color Quantity";
                                Item1 := Item1 + Quantity;
                            end;
                        '2':
                            begin
                                Item2br := Item1br + "Breaking Quantity";
                                Item2col := Item1col + "Color Quantity";
                                Item2gr := Item2gr + "Green Quantity";
                                Item2ng := Item2ng + "No Gas Quantity";
                                Item2 := Item2 + Quantity;
                            end;
                        '3':
                            begin
                                Item3br := Item3br + "Breaking Quantity";
                                Item3gr := Item3gr + "Green Quantity";
                                Item3col := Item3col + "Color Quantity";
                                Item3ng := Item3ng + "No Gas Quantity";
                            end;
                        '15':
                            begin
                                Item4br := Item4br + "Breaking Quantity";
                                Item4gr := Item4gr + "Green Quantity";
                                Item4col := Item4col + "Color Quantity";
                            end;
                        '5':
                            Item5 := Item5 + Quantity;
                        '6':
                            Item6 := Item6 + Quantity;
                        '300':
                            Item10002 := Item10002 + Quantity;
                        '124':
                            Item12022 := Item12022 + Quantity;
                        '67013':
                            Item67013 := Item67013 + Quantity;
                    end;
                    if ("No." <> '300') and ("No." <> '124') then
                        case ItemInfo."Item Category Code" of
                            'PRODUCE':
                                Spanish := Spanish + Quantity;
                            'BANANAS', 'Z DO NOT USE', 'ZADMIN':
                                ;
                            'NEPC':
                                NEPC := NEPC + Quantity;
                            else
                                DG := DG + Quantity;
                        end;

                end;

                trigger OnPreDataItem()
                begin
                    CurrReport.CreateTotals("Qty. to Ship");
                    if "Sales Header"."Document Type" = "Sales Header"."Document Type"::"Credit Memo" then
                        Sign := -1
                    else
                        Sign := 1;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if ("Supply Chain Group Code ELA" = '') then CurrReport.Skip;
            end;

            trigger OnPreDataItem()
            begin
                LastFieldNo := FieldNo("Bill-to Name");
                CurrReport.CreateTotals(Item1, Item2col, Item2br, Item2gr, Item2ng, Item3col, Item3br, Item3gr, Item3ng);
                CurrReport.CreateTotals(Item4col, Item4br, Item4gr, Item5, Item6, Item10002, Item12022, Item67013, CustTot);
                CurrReport.CreateTotals(Spanish, NEPC, DG, Item1br, Item1col);
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
        FirstRoute := true;
    end;

    trigger OnPreReport()
    begin
        Date := CopyStr("Sales Header".GetFilters, 1, MaxStrLen(Date));

        Pref.Get('COL');
        Col := Pref.Description;
        Pref.Get('BR');
        Br := Pref.Description;
        Pref.Get('GR');
        Gr := Pref.Description;
        Pref.Get('NG');
        NG := Pref.Description;
    end;

    var
        LastFieldNo: Integer;
        FooterPrinted: Boolean;
        Item1: Decimal;
        Item1br: Decimal;
        Item1col: Decimal;
        Item2: Decimal;
        Item2br: Decimal;
        Item2gr: Decimal;
        Item2col: Decimal;
        Item2ng: Decimal;
        Item3br: Decimal;
        Item3gr: Decimal;
        Item3col: Decimal;
        Item3ng: Decimal;
        Item4br: Decimal;
        Item4gr: Decimal;
        Item4col: Decimal;
        Item5: Decimal;
        Item6: Decimal;
        Item10002: Decimal;
        Item12022: Decimal;
        Item67013: Decimal;
        Date: Text[30];
        CustTot: Decimal;
        ItemInfo: Record Item;
        CustInfo: Record Customer;
        Spanish: Decimal;
        NEPC: Decimal;
        DG: Decimal;
        Page1: Boolean;
        FirstRoute: Boolean;
        Col: Text[30];
        Br: Text[30];
        Gr: Text[30];
        NG: Text[30];
        Pref: Record "Banana Preference";
        Sign: Integer;
        Banana_Truck_Route_ReportCaptionLbl: Label 'Banana Truck Route Report';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Cust_No_CaptionLbl: Label 'Cust No.';
        DescriptionCaptionLbl: Label 'Description';
        ColCaptionLbl: Label 'Col';
        GrCaptionLbl: Label 'Gr';
        NGCaptionLbl: Label 'NG';
        BrCaptionLbl: Label 'Br';
        BabyCaptionLbl: Label 'Baby';
        OrgCaptionLbl: Label 'Org';
        PltCaptionLbl: Label 'Plt';
        CocoCaptionLbl: Label 'Coco';
        SpnshCaptionLbl: Label 'Spnsh';
        NEPCCaptionLbl: Label 'NEPC';
        Premium____________CaptionLbl: Label '------------ Premium -----------';
        Label_______________CaptionLbl: Label '--------------- Label --------------';
        ColCaption_Control54Lbl: Label 'Col';
        BrCaption_Control55Lbl: Label 'Br';
        GrCaption_Control56Lbl: Label 'Gr';
        NGCaption_Control57Lbl: Label 'NG';
        Inv_No_CaptionLbl: Label 'Inv No.';
        Earth__________CaptionLbl: Label '---------- Earth ---------';
        GrCaption_Control69Lbl: Label 'Gr';
        BrCaption_Control70Lbl: Label 'Br';
        ColCaption_Control71Lbl: Label 'Col';
        Dry_GdsCaptionLbl: Label 'Dry Gds';
        BrCaption_Control12Lbl: Label 'Br';
        GrCaption_Control13Lbl: Label 'Gr';
        Bags__________CaptionLbl: Label '---------- Bags ---------';
        TotalCaptionLbl: Label 'Total';
        Stop__CaptionLbl: Label 'Stop #';
        Route_Totals_CaptionLbl: Label 'Route Totals:';
        ReportTotals_CaptionLbl: Label 'ReportTotals:';
}

