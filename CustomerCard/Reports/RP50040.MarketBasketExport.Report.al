report 50040 "Market Basket Export"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(CustomerFilter; Customer)
        {
            DataItemTableView = SORTING ("No.") ORDER(Ascending);
            RequestFilterFields = "No.", Name;

            trigger OnPreDataItem()
            begin
                CurrReport.Break;
            end;
        }
        dataitem(SalesInvoiceHeaderFilter; "Sales Invoice Header")
        {
            DataItemTableView = SORTING ("No.") ORDER(Ascending);
            RequestFilterFields = "No.", "Sell-to Customer No.", "Ship-to Code";

            trigger OnPreDataItem()
            begin
                CurrReport.Break;
            end;
        }
        dataitem(SalesCrMemoHeaderFilter; "Sales Cr.Memo Header")
        {
            RequestFilterFields = "No.", "Sell-to Customer No.", "Ship-to Code";

            trigger OnPreDataItem()
            begin
                CurrReport.Break;
            end;
        }
        dataitem("Integer"; "Integer")
        {

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1);
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
    begin
        Customer.CopyFilters(CustomerFilter);
        InvoiceHeader.CopyFilters(SalesInvoiceHeaderFilter);
        CRMemoHeader.CopyFilters(SalesCrMemoHeaderFilter);

        if Exists(FullPath) then
            Erase(FullPath);

        DataFile.TextMode(true);
        if not DataFile.Create(FullPath) then
            Error('Unable to create file %1.', FullPath);

        // If any filters are set by the user for invoices or credit memos, then only export the selected items
        InvFilter := InvoiceHeader.GetFilters <> ''; // MNJR02
        CMFilter := CRMemoHeader.GetFilters <> '';   // MNJR02
        Customer.CopyFilter("Date Filter", InvoiceHeader."Posting Date");
        Customer.CopyFilter("Date Filter", CRMemoHeader."Posting Date");

        DataRec."Line No." := 1;
        DataRec.Insert;
        if Customer.Find('-') then
            repeat
                InvoiceHeader.SetRange("Sell-to Customer No.", Customer."No.");
                if (InvFilter or ((not InvFilter) and (not CMFilter))) and InvoiceHeader.Find('-') then
                    repeat
                        //GetMBVendor(InvoiceHeader."Ship-to Code", // MNJR01
                        //  COPYSTR(InvoiceHeader."Sell-to County",1,2)); // MNJR01
                        WriteHeader(InvoiceHeader."No.", InvoiceHeader."Posting Date", Customer."MB Export Store No.",
                          InvoiceHeader."External Document No.");
                        DocTotal := 0;
                        DiscTotal := 0;
                        InvoiceLine.Reset;
                        InvoiceLine.SetRange("Document No.", InvoiceHeader."No.");
                        //<JF13974OPO>
                        InvoiceLine.SetRange(Type, InvoiceLine.Type::Item);
                        //</JF13974OPO>
                        InvoiceLine.SetFilter(Quantity, '<>0');
                        if InvoiceLine.Find('-') then begin
                            InitDetail;
                            repeat
                                UnitPrice := InvoiceLine."Unit Price";
                                //<DP20160524>
                                /*
                                //<IB57302OPO>
                                gtxtBotDep := InvoiceLine.jfGetUDCalculation('85_BOTTLE');

                                IF EVALUATE(BotDep,gtxtBotDep) THEN BEGIN
                                 UnitPrice += BotDep;
                                END;
                                 //</IB57302OPO>
                                */
                                //</DP20160524>

                                //<DP20160512>
                                //WriteDetail(Customer."No.",InvoiceLine."No.",InvoiceLine.Quantity,
                                //  UnitPrice,InvoiceLine.Amount,InvoiceLine."Inv. Discount Amount",InvoiceLine."Unit of Measure Code");
                                WriteDetail(Customer."MB Export Store No.", InvoiceLine."No.", InvoiceLine.Quantity,
                                  UnitPrice, InvoiceLine.Amount, InvoiceLine."Inv. Discount Amount", InvoiceLine."Unit of Measure Code");
                            until InvoiceLine.Next = 0;
                            FinishDetail;
                        end;
                        WriteTrailer(InvoiceHeader."No.", InvoiceHeader."Posting Date", Customer."MB Export Store No.",
                          DocTotal);
                    until InvoiceHeader.Next = 0;

                CRMemoHeader.SetRange("Sell-to Customer No.", Customer."No.");
                if (CMFilter or ((not InvFilter) and (not CMFilter))) and CRMemoHeader.Find('-') then
                    repeat
                        //GetMBVendor(CRMemoHeader."Ship-to Code", // MNJR01
                        //  COPYSTR(CRMemoHeader."Sell-to County",1,2)); // MNJR01
                        WriteHeader(CRMemoHeader."No.", CRMemoHeader."Posting Date", Customer."MB Export Store No.",
                          CRMemoHeader."External Document No.");
                        DocTotal := 0;
                        DiscTotal := 0;
                        CRMemoLine.Reset;
                        CRMemoLine.SetRange("Document No.", CRMemoHeader."No.");
                        CRMemoLine.SetRange(Type, CRMemoLine.Type::Item);
                        CRMemoLine.SetFilter(Quantity, '<>0');
                        if CRMemoLine.Find('-') then begin
                            InitDetail;
                            repeat
                                UnitPrice := CRMemoLine."Unit Price";
                                //<DP20160524>
                                /*
                                //<IB57302OPO>
                                  gtxtBotDep := CRMemoLine.jfGetUDCalculation('85_BOTTLE');

                                  IF EVALUATE(BotDep,gtxtBotDep) THEN BEGIN
                                   UnitPrice += BotDep;
                                  END;

                                 //<IB57302OPO>
                                 */
                                //</DP20160524>


                                //<DP20160628>
                                WriteDetailCM(Customer."No.", CRMemoLine."No.", -CRMemoLine.Quantity,
                                  UnitPrice, -CRMemoLine.Amount, -CRMemoLine."Inv. Discount Amount", CRMemoLine."Unit of Measure Code");
                            until CRMemoLine.Next = 0;
                            FinishDetail;
                        end;
                        WriteTrailerCM(CRMemoHeader."No.", CRMemoHeader."Document Date", Customer."MB Export Store No.",
                          DocTotal);
                    until CRMemoHeader.Next = 0;
            until Customer.Next = 0;

        DataRec.Reset;
        gintLineCount := DataRec.Count;
        LineNo := gintLineCount;

        //Document Type,No.,Document Line No.,Line No.
        if not DataRec.Get(0, '', 0, 1) then begin
            DataRec.Init;
            DataRec."Line No." := 1;
            DataRec.Insert;
        end;
        DataRec.Comment := grecMarketBaskExpSetup."File Name" +
                           //<DP20150626>
                           FormatNum(gintLineCount + 1, 7);
        DataRec.Modify;
        DataRec."Line No." := LineNo + 1;
        DataRec.Insert; // File trailer is same as header

        DataRec.Find('-');
        repeat
            DataFile.Write(PadStr(DataRec.Comment, 80));
        until DataRec.Next = 0;

        DataFile.Close;

    end;

    trigger OnPreReport()
    var
        i: Integer;
        j: Integer;
    begin

        SignDigit[1] [1] := '0';
        SignDigit[2] [1] := 'I';
        for i := 1 to 2 do
            for j := 2 to 10 do
                SignDigit[i] [j] := 1 + SignDigit[i] [j - 1];
        //<JF13974OPO>
        SignDigit[2] [1] := '}';
        //<JF13974OPO>
        gintInvLineLEN := 71; //1 + (4+5+5) * 5;

        grecMarketBaskExpSetup.Get;
        grecMarketBaskExpSetup.TestField("Destination Folder Path");
        grecMarketBaskExpSetup.TestField("File Name");
        grecMarketBaskExpSetup.TestField("Vendor No.");
        FullPath := DelChr(grecMarketBaskExpSetup."Destination Folder Path", '>', '\') + '\' + grecMarketBaskExpSetup."File Name";
    end;

    var
        Customer: Record Customer;
        InvoiceHeader: Record "Sales Invoice Header";
        InvoiceLine: Record "Sales Invoice Line";
        CRMemoHeader: Record "Sales Cr.Memo Header";
        CRMemoLine: Record "Sales Cr.Memo Line";
        Item: Record Item;
        DataRec: Record "Sales Comment Line" temporary;
        grecMarketBaskExpSetup: Record "Market Basket Export Setup";
        DataFile: File;
        FullPath: Text[1024];
        UnitPrice: Decimal;
        DocTotal: Decimal;
        DiscTotal: Decimal;
        SignDigit: array[2, 10] of Char;
        LineNo: Integer;
        InvFilter: Boolean;
        CMFilter: Boolean;
        gintInvLineLEN: Integer;
        gintLineCount: Integer;
        gtxtBotDep: Text;
        BotDep: Decimal;

    [Scope('Internal')]
    procedure FormatNum(num: Decimal; len: Integer) string: Text[250]
    var
        diff: Integer;
        sign: Integer;
        lastdigit: Integer;
    begin
        num := Round(num, 1);
        if num >= 0 then
            sign := 1
        else
            sign := 2;
        num := Abs(num);
        lastdigit := num mod 10;

        string := Format(num, -len, '<Integer>');
        string[StrLen(string)] := SignDigit[sign] [1 + lastdigit];

        diff := len - StrLen(string);
        if diff < 0 then
            string := CopyStr(string, 1, len)
        else
            if diff > 0 then
                string := PadStr('', diff, '0') + string;
    end;

    [Scope('Internal')]
    procedure WriteHeader(DocNo: Code[20]; DocDate: Date; CustNo: Code[20]; ExtDocNo: Code[30])
    begin
        if StrLen(DocNo) > 8 then
            if DocNo[StrLen(DocNo)] in ['0' .. '9'] then
                DocNo := CopyStr(DocNo, StrLen(DocNo) - 7)
            else
                DocNo := CopyStr(DocNo, StrLen(DocNo) - 8, 8);
        DataRec."Line No." += 1;
        DataRec.Comment := '1' + // Record Type
                           grecMarketBaskExpSetup."Vendor No." + // Vendor No. // MNJR01
                           ZeroFill(CopyStr(DelChr(DocNo, '<', 'SO'), 1, 8), 8) + //ZeroFill(DocNo,8) + // Document No.
                           Format(DocDate, 8, '<Month,2><Day,2><Year4>') + // Document Date
                                                                           //<DP20160512>
                                                                           //COPYSTR(CustNo,STRLEN(CustNo)-2) + // Store No.
                           CustNo + // Store No.
                           'V';
        DataRec.Insert;
    end;

    [Scope('Internal')]
    procedure InitDetail()
    begin
        DataRec."Line No." += 1;
        DataRec.Comment := '2';
    end;

    [Scope('Internal')]
    procedure WriteDetail(CustNo: Code[20]; ItemNo: Code[20]; Qty: Decimal; UnitPrice: Decimal; Amount: Decimal; DiscAmount: Decimal; UOM: Code[10])
    begin
        if StrLen(DataRec.Comment) = gintInvLineLEN then begin
            DataRec.Insert;
            InitDetail;
        end;
        Item.Get(ItemNo);

        //<DP20160303>
        if InvoiceLine."Cross-Reference No." <> '' then
            DataRec.Comment := DataRec.Comment +
                               FormatNum(Qty, 4) + // Quantity
                               ZeroFill(InvoiceLine."Cross-Reference No.", 5) + // Item Code
                               FormatNum(UnitPrice * 100, 5) // Unit Price
        else
            DataRec.Comment := DataRec.Comment +
                               FormatNum(Qty, 4) + // Quantity
                               ZeroFill(InvoiceLine."No.", 5) + // Item Code
                               FormatNum(UnitPrice * 100, 5); // Unit Price

        //</DP20160303>

        DocTotal += Amount;
        DiscTotal += DiscAmount;
    end;

    [Scope('Internal')]
    procedure WriteDetailCM(CustNo: Code[20]; ItemNo: Code[20]; Qty: Decimal; UnitPrice: Decimal; Amount: Decimal; DiscAmount: Decimal; UOM: Code[10])
    begin
        if StrLen(DataRec.Comment) = gintInvLineLEN then begin
            DataRec.Insert;
            InitDetail;
        end;
        Item.Get(ItemNo);

        //<DP20160623>
        if CRMemoLine."Cross-Reference No." <> '' then
            DataRec.Comment := DataRec.Comment +
                               FormatNum(Qty, 4) + // Quantity
                               ZeroFill(CRMemoLine."Cross-Reference No.", 5) + // Item Code
                               FormatNum(UnitPrice * 100, 5) // Unit Price
        else
            DataRec.Comment := DataRec.Comment +
                               FormatNum(Qty, 4) + // Quantity
                               ZeroFill(CRMemoLine."No.", 5) + // Item Code
                               FormatNum(UnitPrice * 100, 5); // Unit Price
        //</DP20160623>

        DocTotal += Amount;
        DiscTotal += DiscAmount;
    end;

    [Scope('Internal')]
    procedure FinishDetail()
    begin
        DataRec.Comment := PadStr(DataRec.Comment, 71, '0');
        DataRec.Insert;
    end;

    [Scope('Internal')]
    procedure WriteTrailer(DocNo: Code[20]; DocDate: Date; CustNo: Code[20]; DocTotal: Decimal)
    var
        lInvoiceLine: Record "Sales Invoice Line";
        lDocTotal: Decimal;
    begin
        //<JF13974OPO>
        lInvoiceLine.Reset;
        lInvoiceLine.SetRange("Document No.", InvoiceHeader."No.");
        lInvoiceLine.SetFilter(Quantity, '<>0');
        if lInvoiceLine.FindSet then begin
            repeat
                lDocTotal += lInvoiceLine.Amount;
            until lInvoiceLine.Next = 0
        end;
        DocTotal := lDocTotal;
        // </JF13974OPO>
        if StrLen(DocNo) > 8 then
            if DocNo[StrLen(DocNo)] in ['0' .. '9'] then
                DocNo := CopyStr(DocNo, StrLen(DocNo) - 7)
            else
                DocNo := CopyStr(DocNo, StrLen(DocNo) - 8, 8);
        DataRec."Line No." += 1;
        DataRec.Comment := '3' + // Record Type
                                 //<DP20150626>
                                 //<DP20160303>
                           ZeroFill(grecMarketBaskExpSetup."Vendor No.", 6) +
                           ZeroFill(CopyStr(DelChr(DocNo, '<', 'SO'), 1, 8), 8) + // Document No.
                           Format(DocDate, 8, '<Month,2><Day,2><Year4>') + // Document Date
                                                                           //<DP20160512>
                                                                           //ZeroFill(COPYSTR(CustNo,STRLEN(CustNo)-2), 3) +
                           CustNo +
                           //</DP20160512>
                           'V' +
                           FormatNum((DocTotal + DiscTotal) * 100, 9) + // YG0205B Document Total
                           FormatNum(DiscTotal * 100, 9); // YG0205B Payment Discount (Invoice Discount)
        DataRec.Insert;
    end;

    // procedure GetMBVendor(Dept: Code[10]; State: Code[2])
    // begin
    //     // MNJR01 Begin
    //     if not MBVendor.GET(Dept, State) then
    //         if not MBVendor.GET(Dept, '') then
    //             if not MBVendor.GET('', State) then
    //                 if not MBVendor.GET('', '') then
    //                     Clear(MBVendor);
    //     // MNJR01 End
    // end;

    [Scope('Internal')]
    procedure ZeroFill(text: Text[30]; len: Integer): Text[30]
    begin
        // MNJR01 Begin
        if len <= StrLen(text) then
            exit(CopyStr(text, 1, len))
        else
            exit(PadStr('', len - StrLen(text), '0') + text);
        // MNJR01 End
    end;

    [Scope('Internal')]
    procedure WriteTrailerCM(DocNo: Code[20]; DocDate: Date; CustNo: Code[20]; DocTotal: Decimal)
    var
        lInvoiceLine: Record "Sales Invoice Line";
        lDocTotal: Decimal;
        lCRMemoHeader: Record "Sales Cr.Memo Line";
    begin
        //<JF13974OPO>
        lCRMemoHeader.Reset;
        lCRMemoHeader.SetRange("Document No.", CRMemoHeader."No.");
        lCRMemoHeader.SetFilter(Quantity, '<>0');
        if lCRMemoHeader.FindSet then begin
            repeat
                lDocTotal += lCRMemoHeader.Amount;
            until lCRMemoHeader.Next = 0
        end;
        DocTotal := lDocTotal * -1;  //DP20160727
        // </JF13974OPO>
        if StrLen(DocNo) > 8 then
            if DocNo[StrLen(DocNo)] in ['0' .. '9'] then
                DocNo := CopyStr(DocNo, StrLen(DocNo) - 7)
            else
                DocNo := CopyStr(DocNo, StrLen(DocNo) - 8, 8);
        DataRec."Line No." += 1;
        DataRec.Comment := '3' + // Record Type
                                 //<DP20150626>
                                 //<DP20160303>
                           ZeroFill(grecMarketBaskExpSetup."Vendor No.", 6) +
                           ZeroFill(CopyStr(DelChr(DocNo, '<', 'SO'), 1, 8), 8) + // Document No.
                           Format(DocDate, 8, '<Month,2><Day,2><Year4>') + // Document Date
                                                                           //<DP20160512>
                                                                           //ZeroFill(COPYSTR(CustNo,STRLEN(CustNo)-2), 3) +
                           CustNo +
                           //</DP20160512>
                           'V' +
                           FormatNum((DocTotal + DiscTotal) * 100, 9) + // YG0205B Document Total
                           FormatNum(DiscTotal * 100, 9); // YG0205B Payment Discount (Invoice Discount)
        DataRec.Insert;
    end;
}

