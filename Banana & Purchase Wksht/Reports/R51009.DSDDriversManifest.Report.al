report 51009 "DSD Drivers Manifest"
{
    DefaultLayout = RDLC;
    RDLCLayout = './DSDDriversManifest.rdlc';

    Caption = 'DSD Drivers Manifest';

    dataset
    {
        dataitem("DSD Route Stop Template"; "DSD Route Stop Template")
        {
            DataItemTableView = SORTING(Code);
            RequestFilterFields = "Code";
            column(DSD_Route_Stop_Template_Code; Code)
            {
            }
            dataitem("DSD Route Stop Tmplt. Detail"; "DSD Route Stop Tmplt. Detail")
            {
                DataItemLink = "Route Sequence Template Code" = FIELD(Code);
                DataItemTableView = SORTING("Route Sequence Template Code", Weekday, Route, "Line No.");
                RequestFilterFields = Route;
                column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
                {
                }
                column(USERID; UserId)
                {
                }
                column(COMPANYNAME; CompanyName)
                {
                }
                column(gintPageNo; gintPageNo)
                {
                }
                column(gtxtTemplateFilters; gtxtTemplateFilters)
                {
                }
                column(gtxtDetailFilters; gtxtDetailFilters)
                {
                }
                column(gtxtSalesHeaderFilters; gtxtSalesHeaderFilters)
                {
                }
                column(DSD_Route_Stop_Tmplt__Detail_Route; Route)
                {
                }
                column(DSD_Driver_s_ManifestCaption; DSD_Driver_s_ManifestCaptionLbl)
                {
                }
                column(gintPageNoCaption; gintPageNoCaptionLbl)
                {
                }
                column(Sales_Header__Ship_to_Contact_Caption; "Sales Header".FieldCaption("Ship-to Contact"))
                {
                }
                column(Sales_Header__Ship_to_Post_Code_Caption; "Sales Header".FieldCaption("Ship-to Post Code"))
                {
                }
                column(Sales_Header__Ship_to_County_Caption; "Sales Header".FieldCaption("Ship-to County"))
                {
                }
                column(Sales_Header__Ship_to_City_Caption; "Sales Header".FieldCaption("Ship-to City"))
                {
                }
                column(Sales_Header__Ship_to_Address_2_Caption; "Sales Header".FieldCaption("Ship-to Address 2"))
                {
                }
                column(Sales_Header__Ship_to_Address_Caption; "Sales Header".FieldCaption("Ship-to Address"))
                {
                }
                column(Sales_Header__Ship_to_Name_Caption; "Sales Header".FieldCaption("Ship-to Name"))
                {
                }
                column(DSD_Route_Stop_Tmplt__Detail_RouteCaption; FieldCaption(Route))
                {
                }
                column(Sales_Header__Ship_to_Code_Caption; "Sales Header".FieldCaption("Ship-to Code"))
                {
                }
                column(Customer_No_Caption; Customer_No_CaptionLbl)
                {
                }
                column(DSD_Route_Stop_Tmplt__Detail_Route_Sequence_Template_Code; "Route Sequence Template Code")
                {
                }
                column(DSD_Route_Stop_Tmplt__Detail_Weekday; Weekday)
                {
                }
                column(DSD_Route_Stop_Tmplt__Detail_Line_No_; "Line No.")
                {
                }
                column(DSD_Route_Stop_Tmplt__Detail_Customer_No_; "Customer No.")
                {
                }
                dataitem("Sales Header"; "Sales Header")
                {
                    DataItemLink = "Sell-to Customer No." = FIELD("Customer No.");
                    DataItemTableView = SORTING("Sell-to Customer No.", "Ship-to Code") WHERE("Document Type" = CONST(Order));
                    RequestFilterFields = "Shipment Date", "Standing Order Status";
                    column(Sales_Header__Sell_to_Customer_No__; "Sell-to Customer No.")
                    {
                    }
                    column(Sales_Header__Ship_to_Code_; "Ship-to Code")
                    {
                    }
                    column(Sales_Header__Ship_to_Name_; "Ship-to Name")
                    {
                    }
                    column(Sales_Header__Ship_to_Address_; "Ship-to Address")
                    {
                    }
                    column(Sales_Header__Ship_to_Address_2_; "Ship-to Address 2")
                    {
                    }
                    column(Sales_Header__Ship_to_City_; "Ship-to City")
                    {
                    }
                    column(Sales_Header__Ship_to_Contact_; "Ship-to Contact")
                    {
                    }
                    column(Sales_Header__Ship_to_Post_Code_; "Ship-to Post Code")
                    {
                    }
                    column(Sales_Header__Ship_to_County_; "Ship-to County")
                    {
                    }
                    column(Sales_Header_Document_Type; "Document Type")
                    {
                    }
                    column(Sales_Header_No_; "No.")
                    {
                    }

                    trigger OnPreDataItem()
                    begin

                        if "DSD Route Stop Tmplt. Detail".GetFilter(Route) <> '' then begin
                            if grecDSDSetup."Orders Use Template Route" then begin
                                "Sales Header".SetRange("Order Template Location ELA", "DSD Route Stop Tmplt. Detail".GetFilter(Route));
                            end else begin
                                "Sales Header".SetRange("Location Code", "DSD Route Stop Tmplt. Detail".GetFilter(Route));
                            end;
                        end;
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    lrecDSDRouteStopTmpltDetail: Record "DSD Route Stop Tmplt. Detail";
                    lrecSalesHeader: Record "Sales Header";
                begin

                    if (gcodLastRoute <> '') and (gcodLastRoute <> "DSD Route Stop Tmplt. Detail".Route) then begin
                        gblnProcess := false;
                        CurrReport.NewPage;
                    end;

                    if (gcodLastRoute = '') or (gcodLastRoute <> "DSD Route Stop Tmplt. Detail".Route) then begin
                        Clear(lrecDSDRouteStopTmpltDetail);
                        Clear(lrecSalesHeader);
                        lrecDSDRouteStopTmpltDetail.SetCurrentKey("Route Sequence Template Code", Weekday, Route, "Line No.");
                        lrecDSDRouteStopTmpltDetail.SetRange("Route Sequence Template Code",
                                                             "DSD Route Stop Tmplt. Detail"."Route Sequence Template Code");
                        lrecDSDRouteStopTmpltDetail.SetRange(Weekday, "DSD Route Stop Tmplt. Detail".Weekday);
                        lrecDSDRouteStopTmpltDetail.SetRange(Route, "DSD Route Stop Tmplt. Detail".Route);
                        if lrecDSDRouteStopTmpltDetail.FindSet then begin
                            repeat
                                lrecSalesHeader.SetCurrentKey("Document Type", "Sell-to Customer No.", "No.");
                                lrecSalesHeader.SetRange("Document Type", lrecSalesHeader."Document Type"::Order);
                                lrecSalesHeader.SetRange("Sell-to Customer No.", lrecDSDRouteStopTmpltDetail."Customer No.");
                                lrecSalesHeader.SetRange("Shipment Date", gdteDate);
                                if gtxtStandingOrderStatus <> '' then begin
                                    lrecSalesHeader.SetFilter("Standing Order Status", Format(gtxtStandingOrderStatus));
                                end;
                                if lrecSalesHeader.FindSet then begin
                                    lrecDSDRouteStopTmpltDetail.FindLast;
                                    gblnProcess := true;
                                    gcodLastRoute := "DSD Route Stop Tmplt. Detail".Route;
                                end;
                            until lrecDSDRouteStopTmpltDetail.Next = 0;
                            if not gblnProcess then begin
                                CurrReport.Skip;
                            end;
                        end;
                    end;

                    Clear(gcodLastCustNo);
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Weekday, gintWeekdayFilter);
                end;
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
    }

    trigger OnPreReport()
    begin

        grecDSDSetup.Get;

        Evaluate(gdteDate, "Sales Header".GetFilter("Shipment Date"));
        if grecDate.Get(0, gdteDate) then begin
            case grecDate."Period Name" of
                'Monday':
                    begin
                        gintWeekdayFilter := 1;
                    end;
                'Tuesday':
                    begin
                        gintWeekdayFilter := 2;
                    end;
                'Wednesday':
                    begin
                        gintWeekdayFilter := 3;
                    end;
                'Thursday':
                    begin
                        gintWeekdayFilter := 4;
                    end;
                'Friday':
                    begin
                        gintWeekdayFilter := 5;
                    end;
                'Saturday':
                    begin
                        gintWeekdayFilter := 6;
                    end;
                'Sunday':
                    begin
                        gintWeekdayFilter := 7;
                    end;

            end;
        end else begin
            Error(jfText000);
        end;


        gtxtTemplateFilters := "DSD Route Stop Template".GetFilters;
        gtxtDetailFilters := "DSD Route Stop Tmplt. Detail".GetFilters;
        gtxtSalesHeaderFilters := "Sales Header".GetFilters;

        gtxtStandingOrderStatus := "Sales Header".GetFilter("Standing Order Status");
    end;

    var
        grecDSDSetup: Record "DSD Setup";
        grecDate: Record Date;
        gtxtTemplateFilters: Text[250];
        gtxtDetailFilters: Text[250];
        gtxtSalesHeaderFilters: Text[250];
        jfText000: Label 'You must enter a valid shipment date.';
        gdteDate: Date;
        gintWeekdayFilter: Integer;
        gcodLastCustNo: Code[20];
        gcodLastShiptoCode: Code[10];
        gblnProcess: Boolean;
        gcodLastRoute: Code[10];
        gintPageNo: Integer;
        gtxtStandingOrderStatus: Text[30];
        DSD_Driver_s_ManifestCaptionLbl: Label 'DSD Driver''s Manifest';
        gintPageNoCaptionLbl: Label 'Page';
        Customer_No_CaptionLbl: Label 'Customer No.';
}

