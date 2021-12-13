report 14228900 "EN Sales Guide Order Entry"
{
    Caption = 'Sales Guide Order Entry';
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

            trigger OnAfterGetRecord()
            var
                SalesGuideOrderEntry: Codeunit "EN Sales Guide - Order Entry";
            begin
                //<<TMS1.00
                ILE.Reset;
                ILE.SetCurrentKey(Open, "Drop Shipment");
                ILE.SetRange(Open, true);
                ILE.SetRange("Drop Shipment", false);
                if not LoadAll then
                    //IF SalesTeamFilter <> '' THEN //TMS1.01
                    if SuppChnUsrGrpFilter <> '' then // TMS1.01
                                                      //ILE.SETFILTER("Supply Chain Group Code",SalesTeamFilter) // TMS1.01
                        ILE.SetFilter("Supply Chain Group Code ELA", SuppChnUsrGrpFilter) //TMS1.01
                    else
                        //ILE.SETFILTER("Supply Chain Group Code", UserSetup.GetUserSalesTeam); // TMS1.01
                        ILE.SetFilter("Supply Chain Group Code ELA", SalesGuideOrderEntry.GetSupplyChainGroup); // TMS1.01

                if ILE.FindSet(false, false) then
                    repeat
                        CreateSalesGuideOrderEntry(ILE."Item No.", ILE."Variant Code", ILE."Country/Reg of Origin Code ELA");
                    until ILE.Next = 0;

                PurchLine.Reset;
                PurchLine.SetCurrentKey("Document Type", Type, "Drop Shipment", "Country/Reg of Origin Code ELA", "Variant Code",
                  "No.", "Expected Receipt Date");
                PurchLine.SetRange(Type, PurchLine.Type::Item);
                PurchLine.SetRange("Drop Shipment", false);
                PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
                //PurchLine.SETFILTER("Country/Region of Origin Code", '>%1', '');
                PurchLine.SetFilter("Outstanding Quantity", '>%1', 0);
                if PurchLine.FindSet(false, false) then
                    repeat
                        if not LoadAll then begin
                            if SalesTeamFilter <> '' then begin
                                Item3.Reset;
                                Item3.SetRange("No.", PurchLine."No.");
                                //Item3.SETFILTER("Supply Chain Group Code",SalesTeamFilter); // TMS1.01
                                Item3.SetFilter("Supply Chain Group Code ELA", SuppChnUsrGrpFilter);// TMS1.01
                                if Item3.FindFirst then
                                    CreateSalesGuideOrderEntry(PurchLine."No.", PurchLine."Variant Code", PurchLine."Country/Reg of Origin Code ELA");
                            end else begin
                                Item3.Reset;
                                Item3.SetRange("No.", PurchLine."No.");
                                // Item3.SETFILTER("Supply Chain Group Code",UserSetup.GetUserSalesTeam); // TMS1.01/
                                Item3.SetFilter("Supply Chain Group Code ELA", SalesGuideOrderEntry.GetSupplyChainGroup);// TMS1.01
                                if Item3.FindFirst then
                                    CreateSalesGuideOrderEntry(PurchLine."No.", PurchLine."Variant Code", PurchLine."Country/Reg of Origin Code ELA");
                            end;
                        end else
                            CreateSalesGuideOrderEntry(PurchLine."No.", PurchLine."Variant Code", PurchLine."Country/Reg of Origin Code ELA");
                    until PurchLine.Next = 0;
                //>>TMS1.00
            end;

            trigger OnPreDataItem()
            begin

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

    trigger OnPreReport()
    begin
        SalesGuideOrderEntry.SetCurrentKey("Order No.", "Item No.", "Item Variant Code", "Country/Region of Origin Code");
        SalesGuideOrderEntry.SetRange("Order No.", OrderNo);
        //IF SalesGuideOrderEntry.FIND('-') THEN
        if not SalesGuideOrderEntry.IsEmpty then
            if not Reload then
                CurrReport.Quit
            else
                SalesGuideOrderEntry.DeleteAll;
    end;

    var
        SalesGuideOrderEntry: Record "EN Sales Guide Order Entry";
        LoadAll: Boolean;
        OrderNo: Code[20];
        Reload: Boolean;
        UserSetup: Record "User Setup";
        LotNoInfo: Record "Lot No. Information";
        SalesLine: Record "Sales Line";
        SalesTeamFilter: Text[255];
        SuppChnUsrGrpFilter: Text[255];
        StampUserID: Code[50];
        StampStartTime: DateTime;
        Country: Record "Country/Region";
        ILE: Record "Item Ledger Entry";
        PurchLine: Record "Purchase Line";
        SalesGuideOrderEntry2: Record "EN Sales Guide Order Entry";
        LastCountry: Code[10];
        Item2: Record Item;
        Variant2: Record "Item Variant";
        Item3: Record Item;
        FirstTime: Boolean;
        LastCountryCode: Code[10];
        CountryQty: Decimal;
        SalesQty: Decimal;

    procedure ShowAll(SetValue: Boolean)
    begin
        LoadAll := SetValue;
    end;

    procedure SetOrderNo(SalesOrderNo: Code[20])
    begin
        OrderNo := SalesOrderNo;
    end;

    procedure SetReload(ReloadItems: Boolean)
    begin
        Reload := ReloadItems;
    end;

    procedure CreateSalesGuideOrderEntry(ItemNo: Code[20]; VariantCode: Code[10]; CountryOfOrigin: Code[10])
    begin
        if not SalesGuideOrderEntry2.Get(OrderNo, ItemNo, VariantCode) then begin
            SalesGuideOrderEntry.Init;
            Item2.Get(ItemNo);
            SalesGuideOrderEntry."Order No." := OrderNo;
            SalesGuideOrderEntry.Validate("Item No.", ItemNo);
            SalesGuideOrderEntry."Item Variant Code" := VariantCode;
            ///SalesGuideOrderEntry."Country Of Origin" := CountryOfOrigin;
            SalesGuideOrderEntry."Country/Region of Origin Code" := CountryOfOrigin;   //TMS 11-15-2015
            SalesGuideOrderEntry.Description := Item2.Description;
            SalesGuideOrderEntry."Sales Unit of Measure" := Item2."Sales Unit of Measure";
            //SalesGuideOrderEntry."Salesperson Code" := Item2."Sales Team";
            SalesGuideOrderEntry."Supply Chain Group Code" := Item2."Supply Chain Group Code ELA";
            SalesGuideOrderEntry."Item Category" := Item2."Item Category Code";
            SalesGuideOrderEntry."Description 2" := '';
            //SalesGuideOrderEntry."Qty. On Hand" := CountryQty;
            //SalesGuideOrderEntry."Qty. On Sales Orders" := SalesQty;
            SalesGuideOrderEntry."User ID" := StampUserID;
            SalesGuideOrderEntry."Form Start" := StampStartTime;
            SalesGuideOrderEntry.Insert;
        end;
    end;

    procedure SetSalesTeamFilter(inSalesTeamFilter: Text[255])
    begin
        //84732
        // SalesTeamFilter := inSalesTeamFilter; //<<TMS1.01
    end;

    procedure SetSupplyChGrpUsrFilter(inSuppChnUsrGrpFilter: Text[255])
    begin
        //<<TMS1.01
        SuppChnUsrGrpFilter := inSuppChnUsrGrpFilter;
        //>>TMS1.01
    end;

    /// <summary>
    /// SetStamp.
    /// </summary>
    /// <param name="inUserID">Code[50].</param>
    /// <param name="inStartTime">DateTime.</param>
    procedure SetStamp(inUserID: Code[50]; inStartTime: DateTime)
    begin
        
        StampUserID := inUserID;
        StampStartTime := inStartTime;
    end;
}

