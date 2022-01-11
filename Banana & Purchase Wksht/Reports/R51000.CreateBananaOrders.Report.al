report 51000 "Create Banana Orders"
{
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem("Banana Worksheet Customers"; "Banana Worksheet Customers")
        {
            DataItemTableView = SORTING("Customer No.", "Ship-to Code") ORDER(Ascending);

            trigger OnAfterGetRecord()
            var
                Text001: Label 'In Banana Worksheet columns, item %1, banana preference code %2 has Order "No", but no item %3 has Input Preference of %4 with Order = Yes';
            begin
                SetRange("Item Filter");
                SetRange("Variant Filter");
                SetRange("Preference Filter");

                SetRange("Ship-to Code Filter");
                SetRange("Ship-to Code Filter", "Ship-to Code");
                CalcFields("Banana Quantity");
                if "Banana Quantity" = 0 then
                    CurrReport.Skip;

                CreateSalesHeader;
                WSCols.Reset;
                WSCols.SetCurrentKey(Sequence);
                WSCols.SetRange(Input, true);
                if WSCols.Find('-') then
                    repeat
                        SetRange("Item Filter", WSCols."Item No.");
                        SetRange("Variant Filter", WSCols."Variant Code");
                        SetRange("Preference Filter", WSCols."Banana Preference Code");

                        SetRange("Ship-to Code Filter", "Ship-to Code");
                        CalcFields("Banana Quantity");
                        if "Banana Quantity" <> 0 then begin
                            if WSCols.Order then
                                CreateSalesLine(WSCols."Item No.", WSCols."Variant Code", WSCols."Banana Preference Code",
                          "Banana Quantity", gcodLocationCode)
                            else begin
                                RemQty := "Banana Quantity";
                                WSCols2.Reset;
                                WSCols2.SetCurrentKey(Sequence);
                                WSCols2.SetRange("Item No.", WSCols."Item No.");
                                WSCols2.SetRange("Variant Code", WSCols."Variant Code");
                                WSCols2.SetRange("Input Preference Code", WSCols."Banana Preference Code");
                                WSCols2.SetRange(Order, true);
                                if not WSCols2.FindFirst then
                                    Error(Text001, WSCols."Item No.", WSCols."Banana Preference Code", WSCols."Item No.", WSCols."Banana Preference Code");

                                if WSCols2.Find('-') then begin
                                    SplitCount := 0;
                                    SplitTotal := 0;
                                    BananaWS2.Reset;
                                    BananaWS2.SetCurrentKey("Customer No.", "Ship-to Code", "Item No.", "Variant Code", "Location Code",
                                      "Preference Code", Date);
                                    BananaWS2.SetRange("Customer No.", '');
                                    BananaWS2.SetRange(Date, OrderDate);
                                    BananaWS2.SetRange("Item No.", WSCols."Item No.");
                                    BananaWS2.SetRange("Variant Code", WSCols."Variant Code");
                                    BananaWS2.SetRange("Location Code", gcodLocationCode);
                                    BananaWS2.SetFilter(Quantity, '<>0');

                                    BananaWS2.SetRange("Ship-to Code", "Banana Worksheet Customers"."Ship-to Code");
                                    repeat
                                        BananaWS2.SetRange("Preference Code", WSCols2."Banana Preference Code");
                                        if BananaWS2.Find('-') then begin
                                            SplitTotal += BananaWS2.Quantity;
                                            SplitCount += 1;
                                            SplitCode[SplitCount] := BananaWS2."Preference Code";
                                            SplitLocation[SplitCount] := gcodLocationCode;
                                            SplitFactor[SplitCount] := BananaWS2.Quantity;
                                        end;
                                    until WSCols2.Next = 0;
                                    if SplitCount = 0 then
                                        CreateSalesLine(WSCols."Item No.", WSCols."Variant Code", '', "Banana Quantity", gcodLocationCode)
                                    else begin
                                        for i := 1 to SplitCount do begin
                                            if i = SplitCount then
                                                Qty := RemQty
                                            else
                                                Qty := Round("Banana Quantity" * SplitFactor[i] / SplitTotal, 1);
                                            RemQty := RemQty - Qty;
                                            CreateSalesLine(WSCols."Item No.", WSCols."Variant Code", SplitCode[i], Qty, SplitLocation[i]); // MNJR01
                                        end;
                                    end;
                                end else begin
                                    Error('!!!!!!!!!');
                                end;
                            end;
                        end;
                    until WSCols.Next = 0;

                SalesHeader2.Get(SalesHeader."Document Type", SalesHeader."No.");

                if gblnReleaseSO then begin
                    ReleaseSalesDoc.Run(SalesHeader2);
                end;

                SalesHeader2.Mark(true);
            end;

            trigger OnPostDataItem()
            begin
                if PrintFlag then begin
                    Commit;
                    SalesHeader2.MarkedOnly(true);
                    DelTicket.SetTableView(SalesHeader2);
                    DelTicket.UseRequestPage(true);
                    DelTicket.RunModal;
                end;
                SalesHeader2.MarkedOnly(true);
                if SalesHeader2.Find('-') then
                    repeat
                        ReleaseSalesDoc.Reopen(SalesHeader2);
                    until SalesHeader2.Next = 0;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Date Filter", OrderDate);
                SetRange("Location Code", gcodLocationCode)
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
        SalesSetup: Record "Sales & Receivables Setup";
        SalesHeader: Record "Sales Header";
        SalesHeader2: Record "Sales Header";
        SalesLine: Record "Sales Line";
        BananaWS: Record "Banana Worksheet";
        BananaWS2: Record "Banana Worksheet";
        BananaPref: Record "Banana Preference";
        WSCols: Record "Banana Worksheet Column";
        WSCols2: Record "Banana Worksheet Column";
        DelTicket: Report "Delivery Tkt BANANA";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        OrderDate: Date;
        LineNo: Integer;
        SplitCode: array[10] of Code[10];
        SplitLocation: array[10] of Code[10];
        SplitFactor: array[10] of Decimal;
        SplitCount: Integer;
        SplitTotal: Decimal;
        RemQty: Decimal;
        Qty: Decimal;
        i: Integer;
        PrintFlag: Boolean;
        gblnReleaseSO: Boolean;
        gcodLocationCode: Code[20];

    [Scope('Internal')]
    procedure SetDate(date: Date; pcodLocationCode: Code[20])
    begin
        OrderDate := date;
        gcodLocationCode := pcodLocationCode;
    end;

    [Scope('Internal')]
    procedure SetPrint(PrtFlg: Boolean)
    begin
        PrintFlag := PrtFlg;
    end;

    [Scope('Internal')]
    procedure CreateSalesHeader()
    var
        lrecBananaWorksheetCustomerDateDetail: Record "Banana Wrksht. Cust. Date Dtl.";
    begin
        Clear(SalesHeader);
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.InitRecord;
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", "Banana Worksheet Customers"."Customer No.");
        SalesHeader.Validate("Document Date", OrderDate);
        SalesHeader.Validate("Order Date", OrderDate);
        SalesHeader.Validate("Posting Date", OrderDate);
        SalesHeader.Validate("Shipment Date", OrderDate);
        SalesHeader.Validate("Location Code", gcodLocationCode);
        if "Banana Worksheet Customers"."Requested Shipment Date" <> 0D then
            SalesHeader.Validate("Shipment Date", "Banana Worksheet Customers"."Requested Shipment Date"); //<JF10807SPK>
        SalesHeader.Validate("Supply Chain Group Code ELA", "Banana Worksheet Customers"."Order Template Location"); //<JF10807SPK>
        SalesHeader.Validate("Ship-to Code", "Banana Worksheet Customers"."Ship-to Code");


        BananaWS.Reset;
        BananaWS.SetRange("Customer No.", "Banana Worksheet Customers"."Customer No.");
        BananaWS.SetRange("Ship-to Code", "Banana Worksheet Customers"."Ship-to Code");
        BananaWS.SetRange("Item No.", '');
        BananaWS.SetRange("Variant Code", '');
        BananaWS.SetRange("Preference Code", '');
        BananaWS.SetRange(Date, OrderDate);
        BananaWS.SetRange("Location Code", gcodLocationCode);
        if BananaWS.Find('-') then
            SalesHeader."External Document No." := BananaWS."PO Number";
        if (
          (lrecBananaWorksheetCustomerDateDetail.Get("Banana Worksheet Customers"."Customer No.",
                                                       "Banana Worksheet Customers"."Ship-to Code",
                                                       "Banana Worksheet Customers"."Location Code",
                                                       OrderDate))
        ) then begin
            SalesHeader."External Document No." := lrecBananaWorksheetCustomerDateDetail."PO Number";
        end;

        SalesHeader.Modify;

        Clear(LineNo);

    end;

    [Scope('Internal')]
    procedure CreateSalesLine(ItemNo: Code[20]; VariantCode: Code[20]; PrefCode: Code[10]; Qty: Decimal; Loc: Code[10])
    begin
        if (SalesLine."Document No." <> SalesHeader."No.") or (SalesLine."No." <> ItemNo)
          or (SalesLine."Variant Code" <> VariantCode)
        then begin
            LineNo += 10000;
            SalesLine.Init;
            SalesLine.Validate("Document Type", SalesHeader."Document Type");
            SalesLine.Validate("Document No.", SalesHeader."No.");
            SalesLine.Validate("Line No.", LineNo);
            SalesLine.Validate(Type, SalesLine.Type::Item);
            SalesLine.Validate("No.", ItemNo);
            SalesLine.Validate("Variant Code", VariantCode);
            SalesLine.Validate("Location Code", Loc);
            SalesLine.Quantity := 0;
            SalesLine.Insert;
        end;
        SalesLine.Validate(Quantity, SalesLine.Quantity + Qty);
        if PrefCode <> '' then begin
            case PrefCode of
                'BR':
                    SalesLine."Breaking Quantity" += Qty;
                'CO':
                    SalesLine."Color Quantity" += Qty;
                'GR':
                    SalesLine."Green Quantity" += Qty;
                'NG':
                    SalesLine."No Gas Quantity" += Qty;
            end;
            SalesLine.Validate("Location Code", Loc);
        end;
        SalesLine.Modify;

    end;

    [Scope('Internal')]
    procedure jfSetRelease(pblnReleaseSO: Boolean)
    begin
        gblnReleaseSO := pblnReleaseSO;
    end;
}
