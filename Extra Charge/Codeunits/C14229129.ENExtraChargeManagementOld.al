codeunit 14229129 "Extra Charge Management Old"
{


    trigger OnRun()
    begin
    end;

    var
        ExtraChargeBuffer: Record "EN Document Extra Charge" temporary;
        LinePostingBuffer: Record "EN Extra Charge Posting Buffer" temporary;
        ItemJnlPostingBuffer: Record "EN Extra Charge Posting Buffer" temporary;
        DropShipPostingBuffer: Record "EN Extra Charge Posting Buffer" temporary;
        PurchaseCurrency: Record Currency;
        VendorBuffer: Record "EN Extra Charge Vendor Buffer" temporary;
        VendorPurchaseInvoice: Record "Purchase Header";
        PurchaseLineTotals: Record "Purchase Line" temporary;
        ACYMgt: Codeunit "Additional-Currency Management";
        //P800UOMFunctions: Codeunit "Process 800 UOM Functions"; //TBR EN
        PurchSetupShortcutECCode: array[5] of Code[10];
        HasGotPurchSetup: Boolean;
        Text001: Label 'This Shortcut Extra Charge is not defined in the %1.';
        ItemJnlQuantity: Decimal;
        PurchDocType: Option Quote,"Blanket Order","Order",Invoice,"Return Order","Credit Memo","Posted Receipt","Posted Invoice","Posted Return Shipment","Posted Credit Memo";
        PostingDate: Date;
        PurchOrderNo: Code[20];
        PurchSetup: Record "Purchases & Payables Setup";
        ExtraCharge: Boolean;

    [Scope('Internal')]
    procedure GetPurchSetup()
    begin
        if not HasGotPurchSetup then begin
            PurchSetup.Get;
            PurchSetupShortcutECCode[1] := PurchSetup."Shortcut Extra Chrg 1 Code ELA";
            PurchSetupShortcutECCode[2] := PurchSetup."Shortcut Extra Chrg 2 Code ELA";
            PurchSetupShortcutECCode[3] := PurchSetup."Shortcut Extra Chrg 3 Code ELA";
            PurchSetupShortcutECCode[4] := PurchSetup."Shortcut Extra Chrg 4 Code ELA";
            PurchSetupShortcutECCode[5] := PurchSetup."Shortcut Extra Chrg 5 Code ELA";
            HasGotPurchSetup := true;
        end;
    end;

    [Scope('Internal')]
    procedure ShowExtraCharge(TableID: Integer; DocType: Option; DocNo: Code[20]; LineNo: Integer; var ShortcutECCharge: array[5] of Decimal)
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        i: Integer;
    begin
        // P8000928 - added parameter OrderType
        // P8000132 - changed OrderType to TableID
        GetPurchSetup;
        for i := 1 to 5 do begin
            ShortcutECCharge[i] := 0;
            if PurchSetupShortcutECCode[i] <> '' then
                if DocExtraCharge.Get(TableID, DocType, DocNo, LineNo, PurchSetupShortcutECCode[i]) then // P8000928, P8001032
                    ShortcutECCharge[i] := DocExtraCharge.Charge; // P8000487A
        end;
    end;

    [Scope('Internal')]
    procedure ShowExtraVendor(TableID: Integer; DocType: Option; DocNo: Code[20]; var ShortcutECVendor: array[5] of Code[20])
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        i: Integer;
    begin
        // P8000928 - added parameter OrderType
        // P8000132 - changed OrderType to TableID
        GetPurchSetup;
        for i := 1 to 5 do begin
            ShortcutECVendor[i] := '';
            if PurchSetupShortcutECCode[i] <> '' then
                if DocExtraCharge.Get(TableID, DocType, DocNo, 0, PurchSetupShortcutECCode[i]) then // P8000928, P8001032
                    ShortcutECVendor[i] := DocExtraCharge."Vendor No.";
        end;
    end;

    [Scope('Internal')]
    procedure ShowTempExtraCharge(var ShortcutECCharge: array[5] of Decimal)
    var
        i: Integer;
    begin
        GetPurchSetup;
        for i := 1 to 5 do begin
            ShortcutECCharge[i] := 0;
            if PurchSetupShortcutECCode[i] <> '' then
                if ExtraChargeBuffer.Get(0, 0, '', 0, PurchSetupShortcutECCode[i]) then // P8000928
                    ShortcutECCharge[i] := ExtraChargeBuffer.Charge; // P8000487A
        end;
    end;

    [Scope('Internal')]
    procedure ShowTempExtraVendor(var ShortcutECVendor: array[5] of Code[20])
    var
        i: Integer;
    begin
        GetPurchSetup;
        for i := 1 to 5 do begin
            ShortcutECVendor[i] := '';
            if PurchSetupShortcutECCode[i] <> '' then
                if ExtraChargeBuffer.Get(0, 0, '', 0, PurchSetupShortcutECCode[i]) then // P8000928
                    ShortcutECVendor[i] := ExtraChargeBuffer."Vendor No.";
        end;
    end;

    [Scope('Internal')]
    procedure ValidateExtraCharge(FieldNumber: Integer; Charge: Decimal)
    begin
        GetPurchSetup;
        if (PurchSetupShortcutECCode[FieldNumber] = '') and (Charge <> 0) then
            Error(Text001, PurchSetup.TableCaption);
    end;

    [Scope('Internal')]
    procedure ValidateExtraVendor(FieldNumber: Integer; VendorNo: Code[20])
    var
        Vendor: Record Vendor;
    begin
        GetPurchSetup;
        if (PurchSetupShortcutECCode[FieldNumber] = '') and (VendorNo <> '') then
            Error(Text001, PurchSetup.TableCaption);
        Vendor.Get(VendorNo);
    end;

    [Scope('Internal')]
    procedure LookupExtraVendor(FieldNumber: Integer; var ShortcutVendorNo: Text[1024]): Boolean
    var
        Vendor: Record Vendor;
    begin
        // P8000466A - ShortcutVendorNo changed to TEXT1024; Boolean return value added
        GetPurchSetup;
        if PurchSetupShortcutECCode[FieldNumber] = '' then
            Error(Text001, PurchSetup.TableCaption);
        Vendor."No." := ShortcutVendorNo;
        if PAGE.RunModal(0, Vendor) = ACTION::LookupOK then begin // P8000466A
            ShortcutVendorNo := Vendor."No.";
            exit(true);                                            // P8000466A
        end;                                                     // P8000466A
    end;

    [Scope('Internal')]
    procedure SaveExtraCharge(TableID: Integer; DocType: Integer; DocNo: Code[20]; LineNo: Integer; FieldNumber: Integer; Charge: Decimal)
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        RecRef: RecordRef;
        xRecRef: RecordRef;
        ChangeLogMgt: Codeunit "Change Log Management";
    begin
        // P8000928 - added parameter OrderType
        // P8001032 - replace OrderType by TableID
        GetPurchSetup;
        if Charge <> 0 then begin
            if DocExtraCharge.Get(TableID, DocType, DocNo, LineNo, PurchSetupShortcutECCode[FieldNumber]) then begin // P8000928, P801032
                xRecRef.GetTable(DocExtraCharge);
                DocExtraCharge.Validate(Charge, Charge); // P8000487A
                DocExtraCharge.Modify;
                RecRef.GetTable(DocExtraCharge);
                //ChangeLogMgt.LogModification(RecRef,xRecRef); // P8001132
            end else begin
                DocExtraCharge.Init;
                DocExtraCharge."Table ID" := TableID; // P8000928, P8001032
                DocExtraCharge.Validate("Document Type", DocType);
                DocExtraCharge.Validate("Document No.", DocNo);
                DocExtraCharge.Validate("Line No.", LineNo);
                DocExtraCharge.InitRecord; // P8000487A
                DocExtraCharge.Validate("Extra Charge Code", PurchSetupShortcutECCode[FieldNumber]);
                DocExtraCharge.Validate(Charge, Charge); // P8000487A
                DocExtraCharge.Insert;
                RecRef.GetTable(DocExtraCharge);
                //ChangeLogMgt.LogInsertion(RecRef); // P8001132
            end;
        end else
            if DocExtraCharge.Get(TableID, DocType, DocNo, LineNo, PurchSetupShortcutECCode[FieldNumber]) then // P8000928, P8001032
                if DocExtraCharge."Vendor No." = '' then begin
                    RecRef.GetTable(DocExtraCharge);
                    DocExtraCharge.Delete;
                    //ChangeLogMgt.LogDeletion(RecRef); // P8001132
                end;
    end;

    [Scope('Internal')]
    procedure SaveExtraVendor(TableID: Integer; DocType: Integer; DocNo: Code[20]; LineNo: Integer; FieldNumber: Integer; VendorNo: Code[20])
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        RecRef: RecordRef;
        xRecRef: RecordRef;
        ChangeLogMgt: Codeunit "Change Log Management";
    begin
        // P8000928 - added parameter OrderType
        // P8001032 - replace OrderType by TableID
        GetPurchSetup;
        if VendorNo <> '' then begin
            if DocExtraCharge.Get(TableID, DocType, DocNo, LineNo, PurchSetupShortcutECCode[FieldNumber]) then begin // P8000928, P8000132
                xRecRef.GetTable(DocExtraCharge);
                DocExtraCharge.Validate("Vendor No.", VendorNo);
                DocExtraCharge.Modify;
                RecRef.GetTable(DocExtraCharge);
                //ChangeLogMgt.LogModification(RecRef,xRecRef); // P8001132
            end else begin
                DocExtraCharge.Init;
                DocExtraCharge."Table ID" := TableID; // P8000928, P8001032
                DocExtraCharge.Validate("Document Type", DocType);
                DocExtraCharge.Validate("Document No.", DocNo);
                DocExtraCharge.Validate("Line No.", LineNo);
                DocExtraCharge.Validate("Extra Charge Code", PurchSetupShortcutECCode[FieldNumber]);
                DocExtraCharge.Validate("Vendor No.", VendorNo);
                DocExtraCharge.Insert;
                RecRef.GetTable(DocExtraCharge);
                //ChangeLogMgt.LogInsertion(RecRef); // P8001132
            end;
        end else
            if DocExtraCharge.Get(TableID, DocType, DocNo, LineNo, PurchSetupShortcutECCode[FieldNumber]) then // P8000928, P8000132
                if DocExtraCharge."Charge (LCY)" = 0 then begin
                    RecRef.GetTable(DocExtraCharge);
                    DocExtraCharge.Delete;
                    //ChangeLogMgt.LogDeletion(RecRef); // P8001132
                end;
    end;

    [Scope('Internal')]
    procedure SaveTempExtraCharge(FieldNumber: Integer; Charge: Decimal)
    begin
        GetPurchSetup;
        if Charge <> 0 then begin
            if ExtraChargeBuffer.Get(0, 0, '', 0, PurchSetupShortcutECCode[FieldNumber]) then begin // P8000928
                ExtraChargeBuffer.Validate(Charge, Charge); // P8000487A
                ExtraChargeBuffer.Modify;
            end else begin
                ExtraChargeBuffer.Init;
                ExtraChargeBuffer.Validate("Extra Charge Code", PurchSetupShortcutECCode[FieldNumber]);
                ExtraChargeBuffer.Validate(Charge, Charge); // P8000487A
                ExtraChargeBuffer.Insert;
            end;
        end else
            if ExtraChargeBuffer.Get(0, 0, '', 0, PurchSetupShortcutECCode[FieldNumber]) then // P8000928
                if ExtraChargeBuffer."Vendor No." = '' then
                    ExtraChargeBuffer.Delete;
        ExtraChargeBuffer.Reset;
    end;

    [Scope('Internal')]
    procedure SaveTempExtraVendor(FieldNumber: Integer; VendorNo: Code[20])
    begin
        GetPurchSetup;
        if VendorNo <> '' then begin
            if ExtraChargeBuffer.Get(0, 0, '', 0, PurchSetupShortcutECCode[FieldNumber]) then begin // P8000928
                ExtraChargeBuffer.Validate("Vendor No.", VendorNo);
                ExtraChargeBuffer.Modify;
            end else begin
                ExtraChargeBuffer.Init;
                ExtraChargeBuffer.Validate("Extra Charge Code", PurchSetupShortcutECCode[FieldNumber]);
                ExtraChargeBuffer.Validate("Vendor No.", VendorNo);
                ExtraChargeBuffer.Insert;
            end;
        end else
            if ExtraChargeBuffer.Get(0, 0, '', 0, PurchSetupShortcutECCode[FieldNumber]) then // P8000928
                if ExtraChargeBuffer."Charge (LCY)" = 0 then
                    ExtraChargeBuffer.Delete;
        ExtraChargeBuffer.Reset;
    end;

    [Scope('Internal')]
    procedure TotalTempExtraCharge() TotalExtraCharge: Decimal
    begin
        if ExtraChargeBuffer.Find('-') then
            repeat
                TotalExtraCharge += ExtraChargeBuffer.Charge; // P8000487A
            until ExtraChargeBuffer.Next = 0;
        ExtraChargeBuffer.Reset;
    end;

    [Scope('Internal')]
    procedure InsertDocExtraCharge(TableID: Integer; DocType: Integer; DocNo: Code[20]; LineNo: Integer)
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        RecRef: RecordRef;
        ChangeLogMgt: Codeunit "Change Log Management";
    begin
        // P8000928 - added parameter OrderType
        // P8001032 - replace OrderType by TableID
        if ExtraChargeBuffer.Find('-') then begin
            repeat
                DocExtraCharge.Init;
                DocExtraCharge."Table ID" := TableID; // P8000928, P8001032
                DocExtraCharge.Validate("Document Type", DocType);
                DocExtraCharge.Validate("Document No.", DocNo);
                DocExtraCharge.Validate("Line No.", LineNo);
                DocExtraCharge.InitRecord; // P8000487A
                DocExtraCharge."Extra Charge Code" := ExtraChargeBuffer."Extra Charge Code";
                DocExtraCharge.Validate(Charge, ExtraChargeBuffer.Charge); // P8000487A
                DocExtraCharge."Vendor No." := ExtraChargeBuffer."Vendor No.";
                DocExtraCharge.Insert;
                RecRef.GetTable(DocExtraCharge);
                ChangeLogMgt.LogInsertion(RecRef);
            until ExtraChargeBuffer.Next = 0;
            ExtraChargeBuffer.Reset;
            ExtraChargeBuffer.DeleteAll;
        end;
    end;

    [Scope('Internal')]
    procedure CopyPostingSetup(SourceGPSetup: Record "General Posting Setup"; TargetGPSetup: Record "General Posting Setup")
    var
        SourceECPostingSetup: Record "EN Extra Charge Posting Setup";
        TargetECPostingSetup: Record "EN Extra Charge Posting Setup";
    begin
        TargetECPostingSetup.SetRange("Gen. Bus. Posting Group", TargetGPSetup."Gen. Bus. Posting Group");
        TargetECPostingSetup.SetRange("Gen. Prod. Posting Group", TargetGPSetup."Gen. Prod. Posting Group");
        TargetECPostingSetup.DeleteAll;

        SourceECPostingSetup.SetRange("Gen. Bus. Posting Group", SourceGPSetup."Gen. Bus. Posting Group");
        SourceECPostingSetup.SetRange("Gen. Prod. Posting Group", SourceGPSetup."Gen. Prod. Posting Group");
        if SourceECPostingSetup.Find('-') then begin
            TargetECPostingSetup."Gen. Bus. Posting Group" := TargetGPSetup."Gen. Bus. Posting Group";
            TargetECPostingSetup."Gen. Prod. Posting Group" := TargetGPSetup."Gen. Prod. Posting Group";
            repeat
                TargetECPostingSetup.Init;
                TargetECPostingSetup."Extra Charge Code" := SourceECPostingSetup."Extra Charge Code";
                TargetECPostingSetup."Direct Cost Applied Account" := SourceECPostingSetup."Direct Cost Applied Account";
                TargetECPostingSetup."Invt. Accrual Acc. (Interim)" := SourceECPostingSetup."Invt. Accrual Acc. (Interim)"; // P8000062B
                TargetECPostingSetup.Insert;
            until SourceECPostingSetup.Next = 0;
        end;
    end;

    [Scope('Internal')]
    procedure StartPurchasePosting(PurchHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line"; Currency: Record Currency)
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        RetShptLine: Record "Return Shipment Line";
        ExtraCharge: Record "EN Extra Charge";
        PstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        CurrExchRate: Record "Currency Exchange Rate";
        Currency2: Record Currency;
        SignFactor: Integer;
        PstdDocExtraCharge1: Record "EN Posted Doc. Extra Charges";
        PstdRcptCharge: Decimal;
        PstdRcptChargeLCY: Decimal;
    begin
        // P8000928 - Renamed from StartPosting
        LinePostingBuffer.Reset;
        LinePostingBuffer.DeleteAll;
        PurchaseCurrency := Currency;
        Currency2.InitRoundingPrecision; // P80000487A
        PostingDate := PurchHeader."Posting Date"; // P8000487A

        DocExtraCharge.SetRange("Table ID", DATABASE::"Purchase Line"); // P8000928, P8001032
        DocExtraCharge.SetRange("Document Type", PurchLine."Document Type");
        DocExtraCharge.SetRange("Document No.", PurchLine."Document No.");
        DocExtraCharge.SetRange("Line No.", PurchLine."Line No.");



        if PurchLine.Quantity = 0 then begin
            if DocExtraCharge.Find('-') then
                repeat
                    DocExtraCharge.TestField("Charge (LCY)");
                until DocExtraCharge.Next = 0;
            exit;
        end;

        // P8000772
        case PurchLine."Document Type" of
            PurchLine."Document Type"::Order, PurchLine."Document Type"::Invoice:
                begin
                    SignFactor := 1;
                    if PurchHeader.Invoice and (PurchLine."Document Type" = PurchLine."Document Type"::Order) then begin
                        PurchRcptLine.SetCurrentKey("Order No.", "Order Line No.");
                        PurchRcptLine.SetRange("Order No.", PurchLine."Document No.");
                        PurchRcptLine.SetRange("Order Line No.", PurchLine."Line No.");
                        if PurchRcptLine.FindSet then begin
                            PstdDocExtraCharge.SetRange("Table ID", DATABASE::"Purch. Rcpt. Line");
                            repeat
                                PstdDocExtraCharge.SetRange("Document No.", PurchRcptLine."Document No.");
                                PstdDocExtraCharge.SetRange("Line No.", PurchRcptLine."Line No.");
                                if PstdDocExtraCharge.FindSet then
                                    repeat
                                        ExtraCharge.Get(PstdDocExtraCharge."Extra Charge Code");
                                        ExtraCharge.Mark(true);
                                    until PstdDocExtraCharge.Next = 0;
                            until PurchRcptLine.Next = 0;
                        end;
                    end;
                end;
            PurchLine."Document Type"::"Credit Memo", PurchLine."Document Type"::"Return Order":
                begin
                    SignFactor := -1;
                    if PurchHeader.Invoice and (PurchLine."Document Type" = PurchLine."Document Type"::"Return Order") then begin
                        RetShptLine.SetCurrentKey("Return Order No.", "Return Order Line No.");
                        RetShptLine.SetRange("Return Order No.", PurchLine."Document No.");
                        RetShptLine.SetRange("Return Order Line No.", PurchLine."Line No.");
                        if RetShptLine.FindSet then begin
                            PstdDocExtraCharge.SetRange("Table ID", DATABASE::"Return Shipment Line");
                            repeat
                                PstdDocExtraCharge.SetRange("Document No.", RetShptLine."Document No.");
                                PstdDocExtraCharge.SetRange("Line No.", RetShptLine."Line No.");
                                if PstdDocExtraCharge.FindSet then
                                    repeat
                                        ExtraCharge.Get(PstdDocExtraCharge."Extra Charge Code");
                                        ExtraCharge.Mark(true);
                                    until PstdDocExtraCharge.Next = 0;
                            until RetShptLine.Next = 0;
                        end;
                    end;
                end;
        end;
        // P8000772

        if DocExtraCharge.Find('-') then
            repeat
                //<<EN 102918 Rpatel
                Clear(PstdRcptCharge);
                Clear(PstdRcptChargeLCY);
                PstdDocExtraCharge1.Reset;
                PstdDocExtraCharge1.SetRange("Table ID", DATABASE::"Purch. Rcpt. Line");
                PstdDocExtraCharge1.SetRange("Document No.", DocExtraCharge."Document No.");
                PstdDocExtraCharge1.SetRange("Source Line No.", DocExtraCharge."Line No.");
                PstdDocExtraCharge1.SetRange("Extra Charge Code", DocExtraCharge."Extra Charge Code");
                if PstdDocExtraCharge1.FindSet then
                    repeat
                        PstdRcptCharge += PstdDocExtraCharge1.Charge;
                        PstdRcptChargeLCY += PstdDocExtraCharge1."Charge (LCY)";
                    until PstdDocExtraCharge1.Next = 0;
                //>>EN 102918
                LinePostingBuffer.Init;
                LinePostingBuffer."Extra Charge Code" := DocExtraCharge."Extra Charge Code";
                LinePostingBuffer.Charge := DocExtraCharge."Charge (LCY)";
                LinePostingBuffer.Quantity := PurchLine."Qty. to Receive" + (SignFactor * PurchLine."Return Qty. to Ship");
                LinePostingBuffer."Invoiced Quantity" := SignFactor * PurchLine."Qty. to Invoice";
                LinePostingBuffer."Recv/Ship Charge" := Round(
                  DocExtraCharge.Charge * LinePostingBuffer.Quantity / PurchLine.Quantity, // P8000487A
                  Currency."Amount Rounding Precision");
                LinePostingBuffer."Invoicing Charge" := Round(
                  DocExtraCharge.Charge * LinePostingBuffer."Invoiced Quantity" / PurchLine.Quantity, // P8000487A
                  Currency."Amount Rounding Precision");
                LinePostingBuffer."Recv/Ship Charge (LCY)" :=
                  Round(
                    //CurrExchRate.ExchangeAmtFCYToLCY(PurchHeader."Posting Date",PurchHeader."Currency Code", // P8000487A
                    //  LinePostingBuffer."Recv/Ship Charge",PurchHeader."Currency Factor"),                   // P8000487A
                    //  Currency."Amount Rounding Precision");                                                 // P8000487A
                    DocExtraCharge."Charge (LCY)" * LinePostingBuffer.Quantity / PurchLine.Quantity,      // P8000487A
                    Currency2."Amount Rounding Precision");                                                    // P8000487A
                LinePostingBuffer."Invoicing Charge (LCY)" :=
                  Round(
                    //CurrExchRate.ExchangeAmtFCYToLCY(PurchHeader."Posting Date",PurchHeader."Currency Code",       // P8000487A
                    //  LinePostingBuffer."Invoicing Charge",PurchHeader."Currency Factor"),                         // P8000487A
                    //  Currency."Amount Rounding Precision");                                                       // P8000487A
                    DocExtraCharge."Charge (LCY)" * LinePostingBuffer."Invoiced Quantity" / PurchLine.Quantity, // P8000487A
                    Currency2."Amount Rounding Precision");
                //<<EN 102918 Rpatel
                if PstdRcptCharge <> 0 then begin
                    LinePostingBuffer."Recv/Ship Charge" := DocExtraCharge.Charge - PstdRcptCharge;
                    LinePostingBuffer."Recv/Ship Charge (LCY)" := DocExtraCharge."Charge (LCY)" - PstdRcptChargeLCY;
                end;
                //>>EN 102918                                                         // P8000487A
                LinePostingBuffer.Insert;
                // P8000772
                if PurchHeader.Invoice then begin
                    ExtraCharge.Get(LinePostingBuffer."Extra Charge Code");
                    ExtraCharge.Mark(false);
                end;
            // P8000772
            /*PR3.70.03 Begin
                IF NOT TotalPostingBuffer.GET(LinePostingBuffer."Extra Charge Code") THEN BEGIN
                  TotalPostingBuffer.INIT;
                  TotalPostingBuffer."Extra Charge Code" := LinePostingBuffer."Extra Charge Code";
                  TotalPostingBuffer.INSERT;
                END;
                TotalPostingBuffer.Charge += LinePostingBuffer.Charge;
                TotalPostingBuffer."Recv/Ship Charge" += LinePostingBuffer."Recv/Ship Charge";
                TotalPostingBuffer."Invoicing Charge" += LinePostingBuffer."Invoicing Charge";
                TotalPostingBuffer."Recv/Ship Charge (LCY)" += LinePostingBuffer."Recv/Ship Charge (LCY)";
                TotalPostingBuffer."Invoicing Charge (LCY)" += LinePostingBuffer."Invoicing Charge (LCY)";
                TotalPostingBuffer.MODIFY;
            PR3.70.03 End*/
            until DocExtraCharge.Next = 0;

        // P8000772
        if PurchHeader.Invoice then begin
            ExtraCharge.MarkedOnly(true);
            if ExtraCharge.FindSet then begin
                LinePostingBuffer.Init;
                LinePostingBuffer.Quantity := PurchLine."Qty. to Receive" + (SignFactor * PurchLine."Return Qty. to Ship");
                LinePostingBuffer."Invoiced Quantity" := SignFactor * PurchLine."Qty. to Invoice";
                repeat
                    LinePostingBuffer."Extra Charge Code" := ExtraCharge.Code;
                    LinePostingBuffer.Insert;
                until ExtraCharge.Next = 0;
            end;
        end;
        // P8000772

    end;

    [Scope('Internal')]
    procedure StartTransferPosting(TransHeader: Record "Transfer Header"; TransLine: Record "Transfer Line")
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        Currency: Record Currency;
    begin
        // P8000928
        LinePostingBuffer.Reset;
        LinePostingBuffer.DeleteAll;
        Currency.InitRoundingPrecision;
        PostingDate := TransHeader."Posting Date";

        DocExtraCharge.SetRange("Table ID", DATABASE::"Transfer Line"); // P8001032
        DocExtraCharge.SetRange("Document No.", TransLine."Document No.");
        DocExtraCharge.SetRange("Line No.", TransLine."Line No.");


        if TransLine.Quantity = 0 then begin
            if DocExtraCharge.Find('-') then
                repeat
                    DocExtraCharge.TestField("Charge (LCY)");
                until DocExtraCharge.Next = 0;
            exit;
        end;

        if DocExtraCharge.FindSet then
            repeat
                LinePostingBuffer.Init;
                LinePostingBuffer."Extra Charge Code" := DocExtraCharge."Extra Charge Code";
                LinePostingBuffer.Charge := DocExtraCharge."Charge (LCY)";
                LinePostingBuffer.Quantity := TransLine."Qty. to Receive";
                LinePostingBuffer."Invoiced Quantity" := TransLine."Qty. to Receive";
                LinePostingBuffer."Recv/Ship Charge" := Round(
                  DocExtraCharge.Charge * LinePostingBuffer.Quantity / TransLine.Quantity,
                  Currency."Amount Rounding Precision");
                LinePostingBuffer."Invoicing Charge" := LinePostingBuffer."Recv/Ship Charge";
                LinePostingBuffer."Recv/Ship Charge (LCY)" := LinePostingBuffer."Recv/Ship Charge";
                LinePostingBuffer."Invoicing Charge (LCY)" := LinePostingBuffer."Recv/Ship Charge";
                LinePostingBuffer.Insert;
            until DocExtraCharge.Next = 0;
    end;

    [Scope('Internal')]
    procedure AdjustItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; var PostingBuffer: Record "EN Extra Charge Posting Buffer" temporary; var ExtraChargeQuantity: Decimal)
    var
        GLSetup: Record "General Ledger Setup";
        TotalCharge: Decimal;
        TotalChargeLCY: Decimal;
        ChargeLCY: Decimal;
        Factor: Decimal;
        Quantity: Decimal;
    begin
        PostingBuffer.Reset;
        PostingBuffer.DeleteAll;
        LinePostingBuffer.Reset;
        if not LinePostingBuffer.Find('-') then
            exit;

        if ItemJnlLine."Invoiced Quantity" <> 0 then begin
            // P8000446A
            ExtraChargeQuantity := ItemJnlLine.GetCostingQtyELA(ItemJnlLine.FieldNo("Invoiced Qty. (Base)"));
            Factor := ItemJnlLine.GetCostingQtyELA(ItemJnlLine.FieldNo("Invoiced Quantity")) /
              LinePostingBuffer."Invoiced Quantity";
            //IF ItemJnlLine.CostInAlternateUnits THEN
            //  ExtraChargeQuantity := ItemJnlLine."Invoiced Qty. (Alt.)"
            //ELSE
            //  ExtraChargeQuantity := ItemJnlLine."Invoiced Quantity";
            //Factor := ExtraChargeQuantity / LinePostingBuffer."Invoiced Quantity";
            // P8000446A
        end else begin
            // P8000446A
            ExtraChargeQuantity := ItemJnlLine.GetCostingQtyELA(ItemJnlLine.FieldNo("Quantity (Base)"));
            Factor := ItemJnlLine.GetCostingQtyELA(ItemJnlLine.FieldNo(Quantity)) /
              LinePostingBuffer.Quantity;
            //IF ItemJnlLine.CostInAlternateUnits THEN
            //  ExtraChargeQuantity := ItemJnlLine."Quantity (Alt.)"
            //ELSE
            //  ExtraChargeQuantity := ItemJnlLine.Quantity;
            //Factor := ExtraChargeQuantity / LinePostingBuffer.Quantity;
            // P8000446A
        end;

        GLSetup.Get; // P8000487A
        repeat
            if ItemJnlLine."Invoiced Quantity" <> 0 then begin
                TotalCharge += LinePostingBuffer."Invoicing Charge";
                ChargeLCY := LinePostingBuffer."Invoicing Charge (LCY)";
            end else begin
                TotalCharge += LinePostingBuffer."Recv/Ship Charge";
                ChargeLCY := LinePostingBuffer."Recv/Ship Charge (LCY)";
            end;
            ChargeLCY := ChargeLCY * Factor + LinePostingBuffer."Remaining Amount";
            PostingBuffer.Init;
            PostingBuffer."Extra Charge Code" := LinePostingBuffer."Extra Charge Code";
            PostingBuffer.Charge := Round(ChargeLCY, GLSetup."Amount Rounding Precision"); // P8000487A
            PostingBuffer.Insert;
            LinePostingBuffer."Remaining Amount" := ChargeLCY - PostingBuffer.Charge;
            LinePostingBuffer.Modify;
            TotalChargeLCY += PostingBuffer.Charge;
        until LinePostingBuffer.Next = 0;

        //GLSetup.GET; // P8000487A
        if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Purchase then begin // P8000928
            ItemJnlLine.Amount += TotalChargeLCY;
            if ItemJnlLine."Invoiced Quantity" <> 0 then
                Quantity := ItemJnlLine.GetCostingQtyELA(ItemJnlLine.FieldNo("Invoiced Quantity")) // P8000967
            else
                Quantity := ItemJnlLine.GetCostingQtyELA(ItemJnlLine.FieldNo(Quantity)); // P8000967
                                                                                      // Although the field below is named "Unit Cost (ACY)" its actual use is for the unit cost in the currency
                                                                                      // of the purchase order
            ItemJnlLine."Unit Cost (ACY)" += Round(TotalCharge / Quantity, PurchaseCurrency."Unit-Amount Rounding Precision");
            ItemJnlLine."Unit Cost" += Round(TotalChargeLCY / Quantity, GLSetup."Unit-Amount Rounding Precision");
        end; // P8000928
    end;

    [Scope('Internal')]
    procedure MoveToDocumentHeader(TableID: Integer; SourceDocType: Option; SourceDocNo: Code[20]; PostDate: Date; TableNo: Integer; DocNo: Code[20])
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        PstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        // P8000928 - added parameters OrderType, SourceDocType, SourceDocNo, PostDate; removed FromPurchHeader
        // P8001032 - replace OrderType with TableID
        DocExtraCharge.SetRange("Table ID", TableID);            // P8000928, P8001032
        DocExtraCharge.SetRange("Document Type", SourceDocType); // P8000928
        DocExtraCharge.SetRange("Document No.", SourceDocNo);    // P8000928
        //DocExtraCharge.SETRANGE("Line No.",0);                // P8001032
        if DocExtraCharge.Find('-') then
            repeat
                PstdDocExtraCharge."Table ID" := TableNo;
                PstdDocExtraCharge."Document No." := DocNo;
                PstdDocExtraCharge."Line No." := 0;
                PstdDocExtraCharge."Extra Charge Code" := DocExtraCharge."Extra Charge Code";
                PstdDocExtraCharge."Charge (LCY)" := 0;
                PstdDocExtraCharge."Vendor No." := DocExtraCharge."Vendor No.";
                PstdDocExtraCharge."Allocation Method" := DocExtraCharge."Allocation Method";
                PstdDocExtraCharge."Currency Code" := DocExtraCharge."Currency Code"; // P8000487A
                PstdDocExtraCharge.UpdateCurrencyFactor(PostDate);                    // P8000487A, P8000928
                PstdDocExtraCharge.Charge := 0;                                       // P8000487A
                                                                                      //<<EN 102918 Rpatel
                PstdDocExtraCharge."Posting Date" := Today;
                if TableNo in [120, 121] then begin
                    PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Interim;

                    ////////////  REVIEW
                    if DocExtraCharge."Vendor No." = '' then begin
                        if PurchRcptHeader.Get(DocNo) then
                            PstdDocExtraCharge."Vendor No." := PurchRcptHeader."Buy-from Vendor No.";
                    end;
                    //>>EN 122618
                    //<<EN 081019 Rpatel
                    PurchInvLine.Reset;
                    PurchInvLine.SetCurrentKey(Type, "No.", "Purch. Ord for Extra Chrg ELA", "Extra Charge Code ELA");
                    PurchInvLine.SetRange("Extra Charge Code ELA", DocExtraCharge."Extra Charge Code");
                    PurchInvLine.SetFilter("Purch. Ord for Extra Chrg ELA", '%1', DocNo + '*');
                    if PurchInvLine.FindFirst then
                        PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Closed;
                    //>>EN 081019
                end;
                if TableNo in [122, 123] then begin
                    PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Open;
                    //<<EN 122618 Rpatel
                    if DocExtraCharge."Vendor No." = '' then begin
                        if PurchInvHeader.Get(DocNo) then
                            PstdDocExtraCharge."Vendor No." := PurchInvHeader."Buy-from Vendor No.";
                    end;
                    //>>EN 122618
                    //<<EN 081019 Rpatel
                    PurchInvLine.Reset;
                    PurchInvLine.SetCurrentKey(Type, "No.", "Purch. Ord for Extra Chrg ELA", "Extra Charge Code ELA");
                    PurchInvLine.SetRange("Extra Charge Code ELA", DocExtraCharge."Extra Charge Code");
                    PurchInvLine.SetFilter("Purch. Ord for Extra Chrg ELA", '%1', DocNo + '*');
                    if PurchInvLine.FindFirst then begin
                        PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Closed;
                        PstdDocExtraCharge."EC Invoice No." := PurchInvLine."Document No.";
                        PstdDocExtraCharge."EC Inv Posting Date" := PurchInvLine."Posting Date";
                    end;
                    //>>EN 081019
                end;
                //>>EN 102918 Rpatel
                ////////////
                PstdDocExtraCharge.Insert;
            until DocExtraCharge.Next = 0;
    end;

    [Scope('Internal')]
    procedure MoveToDocumentLine(TableNo: Integer; DocNo: Code[20]; LineNo: Integer)
    var
        PstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        HeaderTable: Integer;
        ChargeLCY: Decimal;
        PstdDocExtraCharge1: Record "EN Posted Doc. Extra Charges";
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        LinePostingBuffer.Reset;
        if LinePostingBuffer.Find('-') then
            repeat
                case TableNo of
                    DATABASE::"Purch. Rcpt. Line":
                        begin
                            HeaderTable := DATABASE::"Purch. Rcpt. Header";
                            ChargeLCY := LinePostingBuffer."Recv/Ship Charge (LCY)"; // P8000487A
                        end;
                    DATABASE::"Return Shipment Line":
                        begin
                            HeaderTable := DATABASE::"Return Shipment Header";
                            ChargeLCY := -LinePostingBuffer."Recv/Ship Charge (LCY)"; // P8000487A
                        end;
                    DATABASE::"Purch. Inv. Line":
                        begin
                            HeaderTable := DATABASE::"Purch. Inv. Header";
                            ChargeLCY := LinePostingBuffer."Invoicing Charge (LCY)"; // P8000487A
                        end;
                    DATABASE::"Purch. Cr. Memo Line":
                        begin
                            HeaderTable := DATABASE::"Purch. Cr. Memo Hdr.";
                            ChargeLCY := -LinePostingBuffer."Invoicing Charge (LCY)"; // P8000487A
                        end;
                    // P8000928
                    DATABASE::"Transfer Receipt Line":
                        begin
                            HeaderTable := DATABASE::"Transfer Receipt Header";
                            ChargeLCY := LinePostingBuffer."Invoicing Charge (LCY)";
                        end;
                // P8000928
                end;
                if ChargeLCY <> 0 then begin // P8000487A
                    PstdDocExtraCharge."Table ID" := TableNo;
                    PstdDocExtraCharge."Document No." := DocNo;
                    PstdDocExtraCharge."Line No." := LineNo;
                    PstdDocExtraCharge."Extra Charge Code" := LinePostingBuffer."Extra Charge Code";
                    PstdDocExtraCharge."Currency Code" := PurchaseCurrency.Code; // P8000487A
                    PstdDocExtraCharge.UpdateCurrencyFactor(PostingDate);        // P8000487A
                    PstdDocExtraCharge."Charge (LCY)" := ChargeLCY;              // P8000487A
                    PstdDocExtraCharge.ChargeLCYToCharge(PostingDate);           // P8000487A
                    PstdDocExtraCharge."Vendor No." := '';       // P8000395A
                                                                 //////// REVIEW
                                                                 //<<EN 122618 Rpatel
                    if PstdDocExtraCharge1.Get(HeaderTable, DocNo, 0, LinePostingBuffer."Extra Charge Code") and
                      (PstdDocExtraCharge1."Vendor No." <> '')
                    then
                        PstdDocExtraCharge."Vendor No." := PstdDocExtraCharge1."Vendor No.";
                    //>>EN 122618
                    PstdDocExtraCharge."Allocation Method" := 0; // P8000395A
                                                                 //<<EN 102918 Rpatel
                    if TableNo in [120, 121] then begin
                        PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Interim;
                        //<<EN 081019 Rpatel
                        PurchInvLine.Reset;
                        PurchInvLine.SetCurrentKey(Type, "No.", "Purch. Ord for Extra Chrg ELA", "Extra Charge Code ELA");
                        PurchInvLine.SetRange("Extra Charge Code ELA", LinePostingBuffer."Extra Charge Code");
                        PurchInvLine.SetFilter("Purch. Ord for Extra Chrg ELA", '%1', DocNo + '*');
                        if PurchInvLine.FindFirst then
                            PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Closed;
                        //>>EN 081019
                    end;
                    if TableNo in [122, 123] then begin
                        PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Open;
                        //<<EN 081019 Rpatel
                        PurchInvLine.Reset;
                        PurchInvLine.SetCurrentKey(Type, "No.", "Purch. Ord for Extra Chrg ELA", "Extra Charge Code ELA");
                        PurchInvLine.SetRange("Extra Charge Code ELA", LinePostingBuffer."Extra Charge Code");
                        PurchInvLine.SetFilter("Purch. Ord for Extra Chrg ELA", '%1', DocNo + '*');
                        if PurchInvLine.FindFirst then begin
                            PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Closed;
                            PstdDocExtraCharge."EC Invoice No." := PurchInvLine."Document No.";
                            PstdDocExtraCharge."EC Inv Posting Date" := PurchInvLine."Posting Date";
                        end;
                        //>>EN 081019
                    end;
                    PstdDocExtraCharge."Posting Date" := Today;
                    PstdDocExtraCharge."Source Line No." := LineNo;
                    //>>EN 102918
                    ////////
                    PstdDocExtraCharge.Insert;

                    if not PstdDocExtraCharge.Get(HeaderTable, DocNo, 0, LinePostingBuffer."Extra Charge Code") then begin
                        PstdDocExtraCharge."Table ID" := HeaderTable;
                        PstdDocExtraCharge."Document No." := DocNo;
                        PstdDocExtraCharge."Line No." := 0;
                        PstdDocExtraCharge."Extra Charge Code" := LinePostingBuffer."Extra Charge Code";
                        PstdDocExtraCharge."Currency Code" := '';  // P8000487A
                        PstdDocExtraCharge."Currency Factor" := 0; // P8000487A
                        PstdDocExtraCharge."Charge (LCY)" := 0;
                        PstdDocExtraCharge."Vendor No." := '';
                        PstdDocExtraCharge."Allocation Method" := 0;
                        /////// REVIEW
                        //<<EN 102918 Rpatel
                        PstdDocExtraCharge."Posting Date" := Today;
                        if TableNo in [120, 121] then begin
                            PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Interim;
                            //<<EN 081019 Rpatel
                            PurchInvLine.Reset;
                            PurchInvLine.SetCurrentKey(Type, "No.", "Purch. Ord for Extra Chrg ELA", "Extra Charge Code ELA");
                            PurchInvLine.SetRange("Extra Charge Code ELA", LinePostingBuffer."Extra Charge Code");
                            PurchInvLine.SetFilter("Purch. Ord for Extra Chrg ELA", '%1', DocNo + '*');
                            if PurchInvLine.FindFirst then
                                PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Closed;
                            //>>EN 081019
                        end;
                        if TableNo in [122, 123] then begin
                            PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Open;
                            //<<EN 081019 Rpatel
                            PurchInvLine.Reset;
                            PurchInvLine.SetCurrentKey(Type, "No.", "Purch. Ord for Extra Chrg ELA", "Extra Charge Code ELA");
                            PurchInvLine.SetRange("Extra Charge Code ELA", LinePostingBuffer."Extra Charge Code");
                            PurchInvLine.SetFilter("Purch. Ord for Extra Chrg ELA", '%1', DocNo + '*');
                            if PurchInvLine.FindFirst then begin
                                PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Closed;
                                PstdDocExtraCharge."EC Invoice No." := PurchInvLine."Document No.";
                                PstdDocExtraCharge."EC Inv Posting Date" := PurchInvLine."Posting Date";
                            end;
                            //>>EN 081019
                        end;
                        //>>EN 102918 Rpatel
                        /////////////
                        PstdDocExtraCharge.Insert;
                    end;
                    PstdDocExtraCharge."Charge (LCY)" += ChargeLCY;    // P8000487A
                    PstdDocExtraCharge.ChargeLCYToCharge(PostingDate); // P8000487A
                    PstdDocExtraCharge.Modify;
                end;
            until LinePostingBuffer.Next = 0;
    end;

    [Scope('Internal')]
    procedure CopyDocExtraCharge(SourceTableID: Integer; SourceDocNo: Code[20]; SourceLineNo: Integer; TargetTableID: Integer; TargetDocNo: Code[20]; TargetLineNo: Integer; Sign: Integer)
    var
        SourcePstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        TargetPstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
    begin
        TargetPstdDocExtraCharge."Table ID" := TargetTableID;
        TargetPstdDocExtraCharge."Document No." := TargetDocNo;
        TargetPstdDocExtraCharge."Line No." := TargetLineNo;
        with SourcePstdDocExtraCharge do begin
            SetRange("Table ID", SourceTableID);
            SetRange("Document No.", SourceDocNo);
            SetRange("Line No.", SourceLineNo);
            if Find('-') then
                repeat
                    TargetPstdDocExtraCharge."Extra Charge Code" := "Extra Charge Code";
                    TargetPstdDocExtraCharge."Charge (LCY)" := Sign * "Charge (LCY)";
                    TargetPstdDocExtraCharge."Currency Code" := "Currency Code";     // P8000487A
                    TargetPstdDocExtraCharge."Currency Factor" := "Currency Factor"; // P8000487A
                    TargetPstdDocExtraCharge.Charge := Sign * Charge;                // P8000487A
                                                                                     //<<EN 102918 Rpatel
                    TargetPstdDocExtraCharge."Source Line No." := "Source Line No.";
                    TargetPstdDocExtraCharge."Posting Date" := Today;
                    //>>EN 102918
                    TargetPstdDocExtraCharge.Insert;
                until Next = 0;
        end;
    end;

    [Scope('Internal')]
    procedure CalculateDocExtraCharge(DocTable: Integer; DocLineTable: Integer; DocNo: Code[20]; PostingDate: Date)
    var
        PstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        PstdDocLineExtraCharge: Record "EN Posted Doc. Extra Charges";
    begin
        // P8000216A
        // P8000487A - add parameter for posting date
        PstdDocExtraCharge.SetRange("Table ID", DocTable);
        PstdDocExtraCharge.SetRange("Document No.", DocNo);
        PstdDocExtraCharge.SetRange("Line No.", 0);

        PstdDocLineExtraCharge.SetRange("Table ID", DocLineTable);
        PstdDocLineExtraCharge.SetRange("Document No.", DocNo);

        if PstdDocExtraCharge.Find('-') then
            repeat
                PstdDocLineExtraCharge.SetRange("Extra Charge Code", PstdDocExtraCharge."Extra Charge Code");
                PstdDocLineExtraCharge.CalcSums("Charge (LCY)");
                PstdDocExtraCharge."Charge (LCY)" := PstdDocLineExtraCharge."Charge (LCY)";
                PstdDocExtraCharge.ChargeLCYToCharge(PostingDate); // P8000487A
                PstdDocExtraCharge.Modify;
            until PstdDocExtraCharge.Next = 0;
    end;

    [Scope('Internal')]
    procedure SetBufferForItemPosting(var PostingBuffer: Record "EN Extra Charge Posting Buffer" temporary; Qty: Decimal; OrderNo: Code[20])
    begin
        // DA0049A - add parameter for OrderNo
        ItemJnlPostingBuffer.Reset;
        ItemJnlPostingBuffer.DeleteAll;
        PostingBuffer.Reset;
        if PostingBuffer.Find('-') then
            repeat
                ItemJnlPostingBuffer.TransferFields(PostingBuffer, true);
                ItemJnlPostingBuffer.Insert;
            until PostingBuffer.Next = 0;
        ItemJnlQuantity := Qty;
        PurchOrderNo := OrderNo; // DA0049A
    end;

    [Scope('Internal')]
    procedure MoveToValueEntry(var ValueEntry: Record "Value Entry"; ItemLedgEntry: Record "Item Ledger Entry")
    var
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        EntryExtraCharge: Record "EN Value Entry Extra Charge";
        Factor: Decimal;
        Charge: Decimal;
        TotalCharge: Decimal;
        TotalChargeACY: Decimal;
    begin
        // PR4.00 - re-done for posting of expected charges
        // P8000928 - change ValueEntry parameter to pass by reference
        if (ValueEntry."Entry Type" <> ValueEntry."Entry Type"::"Direct Cost") or
         ((ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Transfer Receipt") and // P8001140
          (not ItemLedgEntry.Positive)) or                                                        // P8001140
         (ItemJnlQuantity = 0) or (ValueEntry."Valued Quantity" = 0)
        then
            exit;

        GLSetup.Get;
        if GLSetup."Additional Reporting Currency" <> '' then
            Currency.Get(GLSetup."Additional Reporting Currency");
        Factor := ValueEntry."Valued Quantity" / ItemJnlQuantity;

        ItemJnlPostingBuffer.Reset;
        if ItemJnlPostingBuffer.Find('-') then
            repeat
                EntryExtraCharge.Init;
                EntryExtraCharge."Entry No." := ValueEntry."Entry No.";
                EntryExtraCharge."Extra Charge Code" := ItemJnlPostingBuffer."Extra Charge Code";
                EntryExtraCharge."Item Ledger Entry No." := ValueEntry."Item Ledger Entry No.";
                EntryExtraCharge."Expected Cost" := ValueEntry."Expected Cost";
                Charge := Round(ItemJnlPostingBuffer.Charge * Factor, GLSetup."Amount Rounding Precision");
                //IF Charge <> 0 THEN BEGIN P8000772
                if ValueEntry."Expected Cost" then begin
                    EntryExtraCharge."Expected Charge" := Charge;
                    EntryExtraCharge."Expected Charge (ACY)" := ACYMgt.CalcACYAmt(Charge, ValueEntry."Posting Date", false);
                end else begin
                    EntryExtraCharge.Charge := Charge;
                    EntryExtraCharge."Charge (ACY)" := ACYMgt.CalcACYAmt(Charge, ValueEntry."Posting Date", false);
                    CalcExpectedCharge(
                      ItemLedgEntry."Entry No.",
                      EntryExtraCharge."Extra Charge Code",
                      ValueEntry."Invoiced Quantity",
                      ItemLedgEntry.GetCostingQtyELA,
                      EntryExtraCharge."Expected Charge",
                      EntryExtraCharge."Expected Charge (ACY)",
                      ItemLedgEntry.GetCostingQtyELA = ItemLedgEntry.GetCostingInvQtyELA,
                      GLSetup."Amount Rounding Precision",
                      Currency."Amount Rounding Precision");
                end;
                if (EntryExtraCharge.Charge <> 0) or (EntryExtraCharge."Expected Charge" <> 0) then begin // P8000772
                                                                                                          ///
                    ////// UpdateExtraChargeSummary(PurchOrderNo,EntryExtraCharge,ValueEntry."Posting Date");  //DA0049A
                    ///                                                                   //11202008 Added Parameters ValueEntry."Posting Date"
                    EntryExtraCharge.Insert;
                    ///
                    UpdateExtraChargeSummary(PurchOrderNo, EntryExtraCharge, ValueEntry."Posting Date");  //DA0049A
                                                                                                          ///                                                                   //11202008 Added Parameters ValueEntry."Posting Date"
                    ItemJnlPostingBuffer.Charge -= Charge;
                    ItemJnlPostingBuffer.Modify;
                end;
                TotalCharge += EntryExtraCharge.Charge;            // P8000928
                TotalChargeACY += EntryExtraCharge."Charge (ACY)"; // P8000928
            until ItemJnlPostingBuffer.Next = 0;

        ItemJnlQuantity -= ValueEntry."Valued Quantity";

        // P8000928
        if ItemLedgEntry."Entry Type" = ItemLedgEntry."Entry Type"::Transfer then begin
            ValueEntry."Cost Amount (Actual)" += TotalCharge;
            ValueEntry."Cost Amount (Actual) (ACY)" += TotalChargeACY;
            if ValueEntry."Valued Quantity" <> 0 then begin
                ValueEntry."Cost per Unit" := Round(ValueEntry."Cost Amount (Actual)" / ValueEntry."Valued Quantity",
                  GLSetup."Unit-Amount Rounding Precision");
                ValueEntry."Cost per Unit (ACY)" := Round(ValueEntry."Cost Amount (Actual) (ACY)" / ValueEntry."Valued Quantity",
                  Currency."Unit-Amount Rounding Precision");
            end else begin
                ValueEntry."Cost per Unit" := 0;
                ValueEntry."Cost per Unit (ACY)" := 0;
            end;
        end;
        // P8000928
    end;

    [Scope('Internal')]
    procedure CalcExpectedCharge(ItemLedgEntryNo: Integer; ChargeCode: Code[10]; InvoicedQty: Decimal; Quantity: Decimal; var ExpectedCharge: Decimal; var ExpectedChargeACY: Decimal; CalcRemainder: Boolean; RoundPrecision: Decimal; RoundPrecisionACY: Decimal)
    var
        EntryExtraCharge: Record "EN Value Entry Extra Charge";
    begin
        // PR4.00
        with EntryExtraCharge do begin
            SetCurrentKey("Item Ledger Entry No.", "Extra Charge Code", "Expected Cost");
            SetRange("Item Ledger Entry No.", ItemLedgEntryNo);
            SetRange("Extra Charge Code", ChargeCode);
            SetRange("Expected Cost", true);
            if Find('-') then begin
                if CalcRemainder then
                    SetRange("Expected Cost");
                CalcSums("Expected Charge", "Expected Charge (ACY)");

                if CalcRemainder then begin
                    ExpectedCharge := -"Expected Charge";
                    ExpectedChargeACY := -"Expected Charge (ACY)";
                end else begin
                    ExpectedCharge :=
                      CalcExpCostToBalance("Expected Charge", InvoicedQty, Quantity, RoundPrecision);
                    ExpectedChargeACY :=
                      CalcExpCostToBalance("Expected Charge (ACY)", InvoicedQty, Quantity, RoundPrecisionACY);
                end;
            end;
        end;
    end;

    [Scope('Internal')]
    procedure CalcExpCostToBalance(ExpectedCharge: Decimal; InvoicedQty: Decimal; Quantity: Decimal; RoundPrecision: Decimal): Decimal
    begin
        // PR4.00
        exit(-Round(InvoicedQty / Quantity * ExpectedCharge, RoundPrecision));
    end;

    [Scope('Internal')]
    procedure CopyEntryExtraCharge(SourceEntryNo: Integer; TargetEntryNo: Integer; Sign: Integer; ExpectedCost: Boolean; QtyToShip: Decimal)
    var
        SourceEntryExtraCharge: Record "EN Value Entry Extra Charge";
        TargetEntryExtraCharge: Record "EN Value Entry Extra Charge";
    begin
        // PR4.00 - remove references to Table ID
        // P8000487A - add parameter for Invoiced
        //TargetEntryExtraCharge."Entry No." := TargetEntryNo; // P8000487A
        with SourceEntryExtraCharge do begin
            SetRange("Entry No.", SourceEntryNo);
            if Find('-') then
                repeat
                    // P8000487A
                    TargetEntryExtraCharge := SourceEntryExtraCharge;
                    TargetEntryExtraCharge."Entry No." := TargetEntryNo;
                    // P80061261
                    if not ExpectedCost then begin
                        TargetEntryExtraCharge."Expected Charge" := -Sign * SourceEntryExtraCharge."Expected Charge";
                        TargetEntryExtraCharge."Expected Charge (ACY)" := -Sign * SourceEntryExtraCharge."Expected Charge (ACY)";
                        if QtyToShip = 0 then begin
                            TargetEntryExtraCharge.Charge := Sign * SourceEntryExtraCharge."Expected Charge";
                            TargetEntryExtraCharge."Charge (ACY)" := Sign * SourceEntryExtraCharge."Expected Charge (ACY)";
                        end else begin
                            TargetEntryExtraCharge.Charge := -TargetEntryExtraCharge.Charge;
                            TargetEntryExtraCharge."Charge (ACY)" := -TargetEntryExtraCharge."Charge (ACY)";
                        end;
                    end else begin
                        TargetEntryExtraCharge."Expected Charge" := -SourceEntryExtraCharge."Expected Charge";
                        TargetEntryExtraCharge."Expected Charge (ACY)" := -SourceEntryExtraCharge."Expected Charge (ACY)";
                        TargetEntryExtraCharge.Charge := 0;
                        TargetEntryExtraCharge."Charge (ACY)" := 0;
                    end;
                    // P80061261
                    TargetEntryExtraCharge."Charge Posted to G/L" := 0;
                    TargetEntryExtraCharge."Charge Posted to G/L (ACY)" := 0;
                    TargetEntryExtraCharge."Expected Charge Posted to G/L" := 0;
                    TargetEntryExtraCharge."Exp. Chg. Posted to G/L (ACY)" := 0;
                    //TargetEntryExtraCharge."Extra Charge Code" := "Extra Charge Code";
                    //TargetEntryExtraCharge.Charge := Sign * Charge;
                    // P8000487A
                    TargetEntryExtraCharge.Insert;
                until Next = 0;
        end;
    end;

    [Scope('Internal')]
    procedure AllocateChargesToLines(TableID: Integer; DocType: Option; DocNo: Code[20]; CurrencyCode: Code[10]; var ExtraCharge: Record "EN Extra Charge")
    var
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        DocLineExtraCharge: Record "EN Document Extra Charge";
        DocExtraCharge: Record "EN Document Extra Charge";
        TempDocExtraCharge: Record "EN Document Extra Charge" temporary;
        Currency: Record Currency;
        LineTotals: array[5] of Decimal;
        Quantity: Decimal;
        LineQuantity: array[3] of Decimal;
        TotalsAreZero: Boolean;
        i: Integer;
        NegativeLinesExist: Boolean;
        LineTableID: Integer;
    begin
        // ExtraCharge is passed as parameter to provide filter to allow control over which extra charges to allocate
        // P8000928 - added parameters for OrderType, DocType, DocNo, CurrencyCode; removed parameter for PurchaseHeader
        // P8001032 - replace OrderType with TableID
        // P8001032
        case TableID of
            DATABASE::"Purchase Header":
                LineTableID := DATABASE::"Purchase Line";
            DATABASE::"Transfer Header":
                LineTableID := DATABASE::"Transfer Line";
        end;
        DocLineExtraCharge.SetRange("Table ID", LineTableID);    // P8000928
        // P8001032
        DocLineExtraCharge.SetRange("Document Type", DocType); // P8000928
        DocLineExtraCharge.SetRange("Document No.", DocNo);    // P8000928
        //DocLineExtraCharge.SETFILTER("Line No.",'<>0');     // P8001032

        DocExtraCharge.SetRange("Table ID", TableID);      // P8000928, P8001032
        DocExtraCharge.SetRange("Document Type", DocType); // P8000928
        DocExtraCharge.SetRange("Document No.", DocNo);    // P8000928
        //DocExtraCharge.SETRANGE("Line No.",0);          // P8001032

        if ExtraCharge.Find('-') then begin
            repeat
                DocExtraCharge.SetRange("Extra Charge Code", ExtraCharge.Code);
                if DocExtraCharge.Find('-') then begin
                    if DocExtraCharge."Allocation Method" <> 0 then begin
                        DocLineExtraCharge.SetRange("Extra Charge Code", DocExtraCharge."Extra Charge Code");
                        DocLineExtraCharge.DeleteAll;
                        if DocExtraCharge."Charge (LCY)" <> 0 then begin
                            TempDocExtraCharge.TransferFields(DocExtraCharge);
                            TempDocExtraCharge.Insert;
                        end;
                    end;
                end else begin
                    if ExtraCharge."Allocation Method" <> 0 then begin
                        DocLineExtraCharge.SetRange("Extra Charge Code", ExtraCharge.Code);
                        DocLineExtraCharge.DeleteAll;
                    end;
                end;
            until ExtraCharge.Next = 0;
        end else
            exit;

        if not TempDocExtraCharge.Find('-') then
            exit;

        // P8000928
        case TableID of                 // P8001032
            DATABASE::"Purchase Header": // P8001032
                GetPurchaseLineTotals(DocType, DocNo, LineTotals, NegativeLinesExist); // P8000988
            DATABASE::"Transfer Header": // P8001032
                GetTransferLineTotals(DocNo, LineTotals);
        end;
        // P8000928
        TotalsAreZero := true;
        for i := 1 to ArrayLen(LineTotals) do
            TotalsAreZero := TotalsAreZero and (LineTotals[i] = 0);
        //<<EN 100519 Rpatel
        //IF TotalsAreZero THEN
        //  EXIT;
        //>>EN 100519 Rpatel
        Currency.InitRoundingPrecision; // P8000487A

        DocLineExtraCharge."Table ID" := LineTableID;  // P8000928, P8001032
        DocLineExtraCharge."Document Type" := DocType; // P8000928
        DocLineExtraCharge."Document No." := DocNo;    // P8000928

        // P8000928
        case TableID of                 // P8001032
            DATABASE::"Purchase Header": // P8001032
                begin
                    PurchaseLine.SetRange("Document Type", DocType);
                    PurchaseLine.SetRange("Document No.", DocNo);
                    PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
                    PurchaseLine.SetFilter("No.", '<>%1', '');
                    // P8000988
                    if NegativeLinesExist then begin
                        PurchaseLine.SetFilter(Quantity, '<0');
                        if PurchaseLine.FindSet then
                            repeat
                                // P80042359
                                LineQuantity[1] := PurchaseLine.Quantity;
                                /* //TBR EN
                                P800UOMFunctions.ItemUnitGrossWeightAndVolume(LineQuantity, PurchaseLine."No.", PurchaseLine."Quantity (Base)",
                                  PurchaseLine.Quantity, PurchaseLine."Unit of Measure Code",0);
                                // P80042359
                                */
                                CalcLineAllocation(TempDocExtraCharge, LineTotals,
                                PurchaseLine."Line Amount", LineQuantity[2] * PurchaseLine.Quantity,     // P80042359
                                LineQuantity[3] * PurchaseLine.Quantity, PurchaseLine."Quantity (Base)", // P80042359
                                PurchaseLine."Pallet Count ELA",                                     //12-10-2014
                                DATABASE::"Purchase Line", DocType, DocNo, PurchaseLine."Line No.", // P8001032
                                Currency, CurrencyCode);
                            until PurchaseLine.Next = 0;
                        PurchaseLine.SetFilter(Quantity, '>=0');
                    end;
                    if PurchaseLine.FindSet then
                        // P8000988
                        repeat
                            // P80042359
                            LineQuantity[1] := PurchaseLine.Quantity;
                            /* //TBR EN
                            P800UOMFunctions.ItemUnitGrossWeightAndVolume(LineQuantity, PurchaseLine."No.", PurchaseLine."Quantity (Base)",
                              PurchaseLine.Quantity, PurchaseLine."Unit of Measure Code", 0);
                            // P80042359
                            */

                            CalcLineAllocation(TempDocExtraCharge, LineTotals,
                              PurchaseLine."Line Amount", LineQuantity[2] * PurchaseLine.Quantity,     // P80042359
                              LineQuantity[3] * PurchaseLine.Quantity, PurchaseLine."Quantity (Base)", // P80042359
                              PurchaseLine."Pallet Count ELA",                                     //12-10-2014
                              DATABASE::"Purchase Line", DocType, DocNo, PurchaseLine."Line No.", // P8001032
                              Currency, CurrencyCode);
                        until PurchaseLine.Next = 0;
                end;
            DATABASE::"Transfer Header": // P8001032
                begin
                    TransferLine.SetRange("Document No.", DocNo);
                    //TransferLine.SetRange(Type, TransferLine.Type::Item); //TBR EN
                    TransferLine.SetFilter("Item No.", '<>%1', '');
                    TransferLine.SetRange("Derived From Line No.", 0);
                    TransferLine.FindSet;
                    repeat
                        // P80042359
                        LineQuantity[1] := TransferLine.Quantity;
                    /* //TBR EN
                      P800UOMFunctions.ItemUnitGrossWeightAndVolume(LineQuantity, TransferLine."Item No.", TransferLine."Quantity (Base)",
                        TransferLine.Quantity, TransferLine."Unit of Measure Code", 0);
                      // P80042359

                      CalcLineAllocation(TempDocExtraCharge, LineTotals,
                        TransferLine.LineCost, LineQuantity[2] * TransferLine.Quantity,          // P80042359
                        LineQuantity[3] * TransferLine.Quantity, TransferLine."Quantity (Base)", // P80042359
                        TransferLine."Pallet Count",                                     //12-10-2014
                        DATABASE::"Transfer Line", DocType, DocNo, TransferLine."Line No.", // P8001032
                        Currency, '');

                   */
                    until TransferLine.Next = 0;
                end;
        end;
        // P8000928
    end;

    [Scope('Internal')]
    procedure CalcLineAllocation(var TempDocExtraCharge: Record "EN Document Extra Charge" temporary; var LineTotals: array[5] of Decimal; Amount: Decimal; Weight: Decimal; Volume: Decimal; Quantity: Decimal; Pallet: Decimal; TableID: Integer; DocType: Integer; DocNo: Code[20]; LineNo: Integer; var Currency: Record Currency; CurrencyCode: Code[10])
    var
        DocLineExtraCharge: Record "EN Document Extra Charge";
        Qty: Decimal;
    begin
        // P8000928
        // P8001032 - replace OrderType with TableID
        TempDocExtraCharge.Find('-');
        repeat
            if LineTotals[TempDocExtraCharge."Allocation Method"] <> 0 then begin
                case TempDocExtraCharge."Allocation Method" of
                    TempDocExtraCharge."Allocation Method"::Amount:
                        Qty := Amount;
                    TempDocExtraCharge."Allocation Method"::Weight:
                        Qty := Weight;
                    TempDocExtraCharge."Allocation Method"::Volume:
                        Qty := Volume;
                    TempDocExtraCharge."Allocation Method"::Quantity:
                        Qty := Quantity;
                    TempDocExtraCharge."Allocation Method"::Pallet:
                        Qty := Pallet;   //12-10-2014
                end;
                if Quantity <> 0 then begin
                    DocLineExtraCharge.Init;
                    DocLineExtraCharge."Table ID" := TableID;
                    DocLineExtraCharge."Document Type" := DocType;
                    DocLineExtraCharge."Document No." := DocNo;
                    DocLineExtraCharge."Line No." := LineNo;
                    DocLineExtraCharge."Extra Charge Code" := TempDocExtraCharge."Extra Charge Code";
                    DocLineExtraCharge.Validate("Currency Code", CurrencyCode);
                    DocLineExtraCharge.Validate("Charge (LCY)", Round(
                      TempDocExtraCharge."Charge (LCY)" * Qty / LineTotals[TempDocExtraCharge."Allocation Method"],
                      Currency."Amount Rounding Precision"));
                    DocLineExtraCharge.Insert;
                    TempDocExtraCharge."Charge (LCY)" -= DocLineExtraCharge."Charge (LCY)";
                    TempDocExtraCharge.Modify;
                end;
            end;
        until TempDocExtraCharge.Next = 0;
        LineTotals[DocLineExtraCharge."Allocation Method"::Amount] -= Amount;
        LineTotals[DocLineExtraCharge."Allocation Method"::Weight] -= Weight;
        LineTotals[DocLineExtraCharge."Allocation Method"::Volume] -= Volume;
        LineTotals[DocLineExtraCharge."Allocation Method"::Quantity] -= Quantity;
        LineTotals[DocLineExtraCharge."Allocation Method"::Pallet] -= Pallet;     //12-10-2014
    end;

    [Scope('Internal')]
    procedure GetPurchaseLineTotals(DocType: Integer; DocNo: Code[20]; var LineTotals: array[5] of Decimal; var NegativeLinesExist: Boolean)
    var
        PurchaseLine: Record "Purchase Line";
        DocExtraCharge: Record "EN Document Extra Charge";
        LineQuantity: array[3] of Decimal;
        ItemUOM: Record "Item Unit of Measure";
    begin
        // P8000928 - Renamed from GetLineTotals
        // P8000988 - add parameter NegativeLinesExist
        Clear(LineTotals);
        ///IF NOT PurchaseLineTotals.GET(DocType,DocNo) THEN BEGIN
        if not PurchaseLineTotals.Get(DocType, DocNo, 0) then begin
            PurchaseLineTotals.Init;
            PurchaseLineTotals."Document Type" := DocType;
            PurchaseLineTotals."Document No." := DocNo;

            PurchaseLine.SetRange("Document Type", DocType);
            PurchaseLine.SetRange("Document No.", DocNo);
            PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
            PurchaseLine.SetFilter("No.", '<>%1', '');
            if PurchaseLine.Find('-') then
                repeat
                    PurchaseLineTotals."Line Amount" += PurchaseLine."Line Amount";
                    // P80042359
                    LineQuantity[1] := PurchaseLine.Quantity;
                    /* //TBR EN
                    P800UOMFunctions.ItemUnitGrossWeightAndVolume(LineQuantity, PurchaseLine."No.", PurchaseLine."Quantity (Base)",
                      PurchaseLine.Quantity, PurchaseLine."Unit of Measure Code", 0);
                    */
                    PurchaseLineTotals."Gross Weight" += LineQuantity[2] * PurchaseLine.Quantity;
                    PurchaseLineTotals."Unit Volume" += LineQuantity[3] * PurchaseLine.Quantity;
                    // P80042359

                    PurchaseLineTotals."Quantity (Base)" += PurchaseLine."Quantity (Base)";
                    // DA0007A BEGIN
                    ItemUOM.Get(PurchaseLine."No.", 'PALLET');
                    PurchaseLineTotals."Pallet Count ELA" += PurchaseLine."Pallet Count ELA";                                   //DATMS
                                                                                                                        //      PurchaseLine."Quantity (Base)" / ItemUOM."Qty. per Unit of Measure";                                DATMS
                                                                                                                        // DA0007A END

                    if PurchaseLine.Quantity < 0 then // P8000988
                        NegativeLinesExist := true;     // P8000988
                until PurchaseLine.Next = 0;
            PurchaseLineTotals.Insert;
        end;

        LineTotals[DocExtraCharge."Allocation Method"::Amount] += PurchaseLineTotals."Line Amount";
        LineTotals[DocExtraCharge."Allocation Method"::Weight] += PurchaseLineTotals."Gross Weight";
        LineTotals[DocExtraCharge."Allocation Method"::Volume] += PurchaseLineTotals."Unit Volume";
        LineTotals[DocExtraCharge."Allocation Method"::Quantity] += PurchaseLineTotals."Quantity (Base)";
        LineTotals[DocExtraCharge."Allocation Method"::Pallet] += PurchaseLineTotals."Pallet Count ELA";  //12-10-2014
    end;

    [Scope('Internal')]
    procedure GetTransferLineTotals(DocNo: Code[20]; var LineTotals: array[5] of Decimal)
    var
        TransferLine: Record "Transfer Line";
        DocExtraCharge: Record "EN Document Extra Charge";
        LineQuantity: array[3] of Decimal;
    begin
        // P8000928
        Clear(LineTotals);
        TransferLine.SetRange("Document No.", DocNo);
        //TransferLine.SetRange(Type, TransferLine.Type::Item); //TBR EN
        TransferLine.SetFilter("Item No.", '<>%1', '');
        TransferLine.SetRange("Derived From Line No.", 0);
        if TransferLine.FindSet then
            repeat
                //LineTotals[DocExtraCharge."Allocation Method"::Amount] += TransferLine.LineCost; //TBR EN
                // P80042359
                LineQuantity[1] := TransferLine.Quantity;
                /* //TBR EN
                P800UOMFunctions.ItemUnitGrossWeightAndVolume(LineQuantity, TransferLine."Item No.", TransferLine."Quantity (Base)",
                  TransferLine.Quantity, TransferLine."Unit of Measure Code", 0);
                */
                LineTotals[DocExtraCharge."Allocation Method"::Weight] += LineQuantity[2] * TransferLine.Quantity;
                LineTotals[DocExtraCharge."Allocation Method"::Volume] += LineQuantity[3] * TransferLine.Quantity;
                // P80042359

                LineTotals[DocExtraCharge."Allocation Method"::Quantity] += TransferLine."Quantity (Base)";
            //LineTotals[DocExtraCharge."Allocation Method"::Pallet] += TransferLine."Pallet Count";  // TBR EN
            until TransferLine.Next = 0;
    end;

    [Scope('Internal')]
    procedure FCYtoLCY(Amount: Decimal; ExchDate: Date; Currency: Record Currency; CurrencyFactor: Decimal): Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        // P8000487A
        if Currency.Code <> '' then
            exit(Round(CurrExchRate.ExchangeAmtFCYToLCY(ExchDate, Currency.Code, Amount, CurrencyFactor), Currency."Amount Rounding Precision"))
        else
            exit(Amount);
    end;

    [Scope('Internal')]
    procedure UpdatePurchaseVendorBuffer(PurchHeader: Record "Purchase Header")
    var
        PstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        PstdDocExtraCharge2: Record "EN Posted Doc. Extra Charges";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ExtraChargePostingSetup: Record "EN Extra Charge Posting Setup";
        Vendor: Record Vendor;
    begin
        // P8000928 - renamed from UpdateVendorBuffer
        PstdDocExtraCharge2.SetRange("Table ID", DATABASE::"Purch. Rcpt. Header");      // P8000487A
        PstdDocExtraCharge2.SetRange("Document No.", PurchHeader."Last Receiving No."); // P8000487A
        PstdDocExtraCharge2.SetRange("Line No.", 0);                                    // P8000487A
        //PstdDocExtraCharge2.SETFILTER("Vendor No.",'<>%1','');                         // P8000487A
        PstdDocExtraCharge2.SetFilter("Vendor No.", '<>%1', PurchHeader."Buy-from Vendor No."); //EN 122618 Rpatel
        if not PstdDocExtraCharge2.Find('-') then                                      // P8000487A
            exit;

        VendorPurchaseInvoice."Posting Date" := PurchHeader."Posting Date";
        VendorPurchaseInvoice."Vendor Shipment No." := PurchHeader."Vendor Shipment No.";
        ///12-31-2014
        VendorPurchaseInvoice."No." := PurchHeader."No.";
        ///
        PstdDocExtraCharge.SetRange("Table ID", DATABASE::"Purch. Rcpt. Line");
        PstdDocExtraCharge.SetRange("Document No.", PurchHeader."Last Receiving No.");
        repeat
            if PstdDocExtraCharge2."Vendor No." <> '' then              //TMS 013119
                Vendor.Get(PstdDocExtraCharge2."Vendor No."); // P8000487A
            if Vendor."Pay-to Vendor No." <> '' then
                Vendor.Get(Vendor."Pay-to Vendor No.");
            /*P8000487A
            IF PstdDocExtraCharge2."Currency Code" = '' THEN
              Currency.InitRoundingPrecision
            ELSE BEGIN
              Currency.GET(DocExtraCharge2."Currency Code");
              Currency.TESTFIELD("Amount Rounding Precision");
            END;
            P8000487A*/
            PstdDocExtraCharge.SetRange("Extra Charge Code", PstdDocExtraCharge2."Extra Charge Code"); // P8000487A
            if PstdDocExtraCharge.Find('-') then
                repeat
                    PurchRcptLine.Get(PurchHeader."Last Receiving No.", PstdDocExtraCharge."Line No.");
                    if ExtraChargePostingSetup.Get(PurchRcptLine."Gen. Bus. Posting Group", PurchRcptLine."Gen. Prod. Posting Group",
                      PstdDocExtraCharge2."Extra Charge Code") // P8000487A
                    then
                        if ExtraChargePostingSetup."Direct Cost Applied Account" <> '' then begin
                            if not VendorBuffer.Get(PstdDocExtraCharge2."Vendor No.", PstdDocExtraCharge2."Currency Code", // P8000487A
                              PstdDocExtraCharge2."Extra Charge Code", ExtraChargePostingSetup."Direct Cost Applied Account")  // P8000487A
                            then begin
                                VendorBuffer.Init;
                                VendorBuffer."Vendor No." := PstdDocExtraCharge2."Vendor No."; // P8000487A
                                VendorBuffer."Currency Code" := PstdDocExtraCharge2."Currency Code"; // P8000487A
                                VendorBuffer."Extra Charge Code" := PstdDocExtraCharge2."Extra Charge Code"; // P8000487A
                                VendorBuffer."Account No." := ExtraChargePostingSetup."Direct Cost Applied Account";
                                VendorBuffer.Insert;
                            end;
                            // P8000487A
                            //VendorBuffer.Charge += ConvertCurrency(
                            //  PurchHeader."Posting Date",PurchHeader."Currency Code",Currency.Code,DocExtraCharge."Charge (LCY)",
                            //  Currency."Amount Rounding Precision");
                            VendorBuffer.Charge += PstdDocExtraCharge."Charge (LCY)";
                            // P8000487A
                            VendorBuffer.Modify;
                        end;
                until PstdDocExtraCharge.Next = 0;
        until PstdDocExtraCharge2.Next = 0; // P8000487A

    end;

    [Scope('Internal')]
    procedure UpdateTransferVendorBuffer(TransHeader: Record "Transfer Header")
    var
        PstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        PstdDocExtraCharge2: Record "EN Posted Doc. Extra Charges";
        TransRcptLine: Record "Transfer Receipt Line";
        ExtraChargePostingSetup: Record "EN Extra Charge Posting Setup";
        Vendor: Record Vendor;
    begin
        // P8000928 - copied from UpdatePurchaseVendorBuffer
        PstdDocExtraCharge2.SetRange("Table ID", DATABASE::"Transfer Receipt Header");
        PstdDocExtraCharge2.SetRange("Document No.", TransHeader."Last Receipt No.");
        PstdDocExtraCharge2.SetRange("Line No.", 0);
        PstdDocExtraCharge2.SetFilter("Vendor No.", '<>%1', '');
        if not PstdDocExtraCharge2.Find('-') then
            exit;

        VendorPurchaseInvoice."Posting Date" := TransHeader."Posting Date";

        PstdDocExtraCharge.SetRange("Table ID", DATABASE::"Transfer Receipt Line");
        PstdDocExtraCharge.SetRange("Document No.", TransHeader."Last Receipt No.");
        repeat
            Vendor.Get(PstdDocExtraCharge2."Vendor No.");
            if Vendor."Pay-to Vendor No." <> '' then
                Vendor.Get(Vendor."Pay-to Vendor No.");
            PstdDocExtraCharge.SetRange("Extra Charge Code", PstdDocExtraCharge2."Extra Charge Code");
            if PstdDocExtraCharge.Find('-') then
                repeat
                    TransRcptLine.Get(TransHeader."Last Receipt No.", PstdDocExtraCharge."Line No.");
                    if ExtraChargePostingSetup.Get('', TransRcptLine."Gen. Prod. Posting Group", PstdDocExtraCharge2."Extra Charge Code")
                    then
                        if ExtraChargePostingSetup."Direct Cost Applied Account" <> '' then begin
                            if not VendorBuffer.Get(PstdDocExtraCharge2."Vendor No.", '',
                              PstdDocExtraCharge2."Extra Charge Code", ExtraChargePostingSetup."Direct Cost Applied Account")
                            then begin
                                VendorBuffer.Init;
                                VendorBuffer."Vendor No." := PstdDocExtraCharge2."Vendor No.";
                                VendorBuffer."Extra Charge Code" := PstdDocExtraCharge2."Extra Charge Code";
                                VendorBuffer."Account No." := ExtraChargePostingSetup."Direct Cost Applied Account";
                                VendorBuffer.Insert;
                            end;
                            VendorBuffer.Charge += PstdDocExtraCharge."Charge (LCY)";
                            VendorBuffer.Modify;
                        end;
                until PstdDocExtraCharge.Next = 0;
        until PstdDocExtraCharge2.Next = 0;
    end;

    [Scope('Internal')]
    procedure CreateVendorInvoices(var ExtraCharge: Record "EN Extra Charge" temporary)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        InvHdr: Record "Purchase Header";
        InvLine: Record "Purchase Line";
        InvAmt: Decimal;
    begin
        // ExtraCharge is passed as parameter to provide filter to allow control over which extra charges to invoice
        VendorBuffer.Reset;
        if ExtraCharge.Find('-') then
            repeat
                VendorBuffer.SetRange("Extra Charge Code", ExtraCharge.Code);
                VendorBuffer.SetFilter(Charge, '>0'); //EN 102918 Rpatel
                if VendorBuffer.Find('-') then
                    repeat
                        //<<EN 102918 Rpatel
                        //VendorBuffer.MARK(TRUE);
                        InvLine.SetRange("Document Type", InvLine."Document Type"::Invoice);
                        InvLine.SetRange("Purch. Ord for Ext Charge ELA", VendorPurchaseInvoice."No.");
                        InvLine.SetRange("Extra Charge Code ELA", VendorBuffer."Extra Charge Code");
                        if not InvLine.FindFirst then
                            VendorBuffer.Mark(true);
                    //>>EN 102918
                    until VendorBuffer.Next = 0;
            until ExtraCharge.Next = 0;

        VendorBuffer.SetRange("Extra Charge Code");
        VendorBuffer.MarkedOnly(true);
        if not VendorBuffer.Find('-') then
            exit;

        repeat
            // P8000487A
            if VendorBuffer."Currency Code" <> '' then
                Currency.Get(VendorBuffer."Currency Code")
            else begin
                Clear(Currency);
                Currency.InitRoundingPrecision;
            end;
            // P8000487A
            PurchaseHeader.Init;
            PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Invoice;
            PurchaseHeader."No." := '';
            PurchaseHeader.Insert(true);
            PurchaseHeader.Validate("Buy-from Vendor No.", VendorBuffer."Vendor No.");
            PurchaseHeader.Validate("Posting Date", VendorPurchaseInvoice."Posting Date");
            PurchaseHeader.Validate("Document Date", VendorPurchaseInvoice."Posting Date");
            PurchaseHeader.Validate("Vendor Shipment No.", VendorPurchaseInvoice."Vendor Shipment No.");
            PurchaseHeader.Validate("Currency Code", VendorBuffer."Currency Code"); // P8000487A
            if VendorPurchaseInvoice."No." <> '' then                                           // DA0034A 12-10-2014
                PurchaseHeader."ExtrChrg crtd for Ord. No. ELA" := VendorPurchaseInvoice."No.";   // DA0034A 12-10-2014
            PurchaseHeader.Modify(true);
            VendorBuffer.SetRange("Vendor No.", VendorBuffer."Vendor No.");
            VendorBuffer.SetRange("Currency Code", VendorBuffer."Currency Code"); // P8000487A
            PurchaseLine."Document Type" := PurchaseHeader."Document Type";
            PurchaseLine."Document No." := PurchaseHeader."No.";
            PurchaseLine."Line No." := 0;
            repeat
                PurchaseLine.Init;
                PurchaseLine."Line No." += 10000;
                PurchaseLine.Type := PurchaseLine.Type::"G/L Account";
                PurchaseLine.Validate("No.", VendorBuffer."Account No.");
                ExtraCharge.Get(VendorBuffer."Extra Charge Code");
                if ExtraCharge.Description <> '' then
                    PurchaseLine.Description := ExtraCharge.Description;
                PurchaseLine.Validate(Quantity, 1);
                PurchaseLine.Validate("Direct Unit Cost", // P8000487A
                                                          // P8000487A
                  Round(
                    CurrExchRate.ExchangeAmtLCYToFCY(
                      PurchaseHeader."Posting Date", VendorBuffer."Currency Code",
                      VendorBuffer.Charge, PurchaseHeader."Currency Factor"),
                      Currency."Amount Rounding Precision"));
                // P8000487A
                PurchaseLine."Extra Charge Code ELA" := ExtraCharge.Code;                             //12-10-2104
                if VendorPurchaseInvoice."No." <> '' then                                         // DA0034A 12-10-2014
                    PurchaseLine."Purch. Ord for Ext Charge ELA" := VendorPurchaseInvoice."No.";    // DA0049A//12-10-2104
                PurchaseLine.Insert(true);
            until VendorBuffer.Next = 0;
            VendorBuffer.SetRange("Vendor No.");
            VendorBuffer.SetRange("Currency Code"); // P8000487A
        until VendorBuffer.Next = 0;

        VendorBuffer.DeleteAll;
        VendorBuffer.Reset;
    end;

    [Scope('Internal')]
    procedure CopyFromPurchHeader(ToPurchHeader: Record "Purchase Header"; FromPurchHeader: Record "Purchase Header"; RecalculateLines: Boolean)
    var
        FromDocExtraCharge: Record "EN Document Extra Charge";
        ToDocExtraCharge: Record "EN Document Extra Charge";
    begin
        ToDocExtraCharge.SetRange("Table ID", DATABASE::"Purchase Header"); // P8000928, P8001032
        ToDocExtraCharge.SetRange("Document Type", ToPurchHeader."Document Type");
        ToDocExtraCharge.SetRange("Document No.", ToPurchHeader."No.");
        //ToDocExtraCharge.SETRANGE("Line No.",0); // P8001032
        ToDocExtraCharge.DeleteAll;

        FromDocExtraCharge.SetRange("Table ID", DATABASE::"Purchase Header"); // P8000928, P8001032
        FromDocExtraCharge.SetRange("Document Type", FromPurchHeader."Document Type");
        FromDocExtraCharge.SetRange("Document No.", FromPurchHeader."No.");
        //FromDocExtraCharge.SETRANGE("Line No.",0); // P8001032
        if FromDocExtraCharge.Find('-') then
            repeat
                ToDocExtraCharge := FromDocExtraCharge;
                ToDocExtraCharge."Document Type" := ToPurchHeader."Document Type";
                ToDocExtraCharge."Document No." := ToPurchHeader."No.";
                ToDocExtraCharge.UpdateCurrencyFactor; // P8000487A
                if RecalculateLines then
                    ToDocExtraCharge.Charge := 0;  // P8000487A
                ToDocExtraCharge.Validate(Charge); // P8000487A
                if ToDocExtraCharge."Vendor No." <> '' then
                    ToDocExtraCharge.Insert;
            until FromDocExtraCharge.Next = 0;
    end;

    [Scope('Internal')]
    procedure CopyFromPurchLine(ToPurchLine: Record "Purchase Line"; FromPurchLine: Record "Purchase Line")
    var
        FromDocExtraCharge: Record "EN Document Extra Charge";
        ToDocExtraCharge: Record "EN Document Extra Charge";
    begin
        ToDocExtraCharge.SetRange("Table ID", DATABASE::"Purchase Line"); // P8000928, P8001032
        ToDocExtraCharge.SetRange("Document Type", ToPurchLine."Document Type");
        ToDocExtraCharge.SetRange("Document No.", ToPurchLine."Document No.");
        ToDocExtraCharge.SetRange("Line No.", ToPurchLine."Line No.");
        ToDocExtraCharge.DeleteAll;

        FromDocExtraCharge.SetRange("Table ID", DATABASE::"Purchase Line"); // P8000928, P8001032
        FromDocExtraCharge.SetRange("Document Type", FromPurchLine."Document Type");
        FromDocExtraCharge.SetRange("Document No.", FromPurchLine."Document No.");
        FromDocExtraCharge.SetRange("Line No.", ToPurchLine."Line No.");
        if FromDocExtraCharge.Find('-') then
            repeat
                ToDocExtraCharge := FromDocExtraCharge;
                ToDocExtraCharge."Document Type" := ToPurchLine."Document Type";
                ToDocExtraCharge."Document No." := ToPurchLine."Document No.";
                ToDocExtraCharge."Line No." := ToPurchLine."Line No.";
                ToDocExtraCharge.UpdateCurrencyFactor; // P8000487A
                ToDocExtraCharge.Validate(Charge); // P8000487A
                ToDocExtraCharge.Insert;
            until FromDocExtraCharge.Next = 0;
    end;

    [Scope('Internal')]
    procedure CopyFromPostedPurchDocHeader(ToPurchHeader: Record "Purchase Header"; FromTableID: Integer; FromDocNo: Code[20]; RecalculateLines: Boolean)
    var
        FromPstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        ToDocExtraCharge: Record "EN Document Extra Charge";
    begin
        ToDocExtraCharge.SetRange("Table ID", DATABASE::"Purchase Header"); // P8000928, P8001032
        ToDocExtraCharge.SetRange("Document Type", ToPurchHeader."Document Type");
        ToDocExtraCharge.SetRange("Document No.", ToPurchHeader."No.");
        ToDocExtraCharge.SetRange("Line No.", 0);
        ToDocExtraCharge.DeleteAll;

        FromPstdDocExtraCharge.SetRange("Table ID", FromTableID);
        FromPstdDocExtraCharge.SetRange("Document No.", FromDocNo);
        if FromPstdDocExtraCharge.Find('-') then
            repeat
                ToDocExtraCharge."Table ID" := DATABASE::"Purchase Header"; // P8000928, P8001032
                ToDocExtraCharge."Document Type" := ToPurchHeader."Document Type";
                ToDocExtraCharge."Document No." := ToPurchHeader."No.";
                ToDocExtraCharge."Line No." := 0;
                ToDocExtraCharge."Extra Charge Code" := FromPstdDocExtraCharge."Extra Charge Code";
                if RecalculateLines then
                    ToDocExtraCharge.Charge := 0 // P8000487A
                else
                    ToDocExtraCharge.Charge := FromPstdDocExtraCharge.Charge; // P8000487A
                ToDocExtraCharge."Vendor No." := FromPstdDocExtraCharge."Vendor No.";
                ToDocExtraCharge."Currency Code" := FromPstdDocExtraCharge."Currency Code"; // P8000487A
                ToDocExtraCharge.UpdateCurrencyFactor; // P8000487A
                ToDocExtraCharge."Allocation Method" := FromPstdDocExtraCharge."Allocation Method";
                ToDocExtraCharge.Validate(Charge); // P8000487A
                if ToDocExtraCharge."Vendor No." <> '' then
                    ToDocExtraCharge.Insert;
            until FromPstdDocExtraCharge.Next = 0;
    end;

    [Scope('Internal')]
    procedure CopyFromPostedPurchDocLine(ToPurchLine: Record "Purchase Line"; FromTableID: Integer; FromDocNo: Code[20]; FromLineNo: Integer)
    var
        FromPstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        ToDocExtraCharge: Record "EN Document Extra Charge";
    begin
        ToDocExtraCharge.SetRange("Table ID", DATABASE::"Purchase Line"); // P8000928, P8001032
        ToDocExtraCharge.SetRange("Document Type", ToPurchLine."Document Type");
        ToDocExtraCharge.SetRange("Document No.", ToPurchLine."Document No.");
        ToDocExtraCharge.SetRange("Line No.", ToPurchLine."Line No.");
        ToDocExtraCharge.DeleteAll;

        FromPstdDocExtraCharge.SetRange("Table ID", FromTableID);
        FromPstdDocExtraCharge.SetRange("Document No.", FromDocNo);
        FromPstdDocExtraCharge.SetRange("Line No.", FromLineNo);
        if FromPstdDocExtraCharge.Find('-') then
            repeat
                ToDocExtraCharge."Table ID" := DATABASE::"Purchase Line"; // P8000928, P8001032
                ToDocExtraCharge."Document Type" := ToPurchLine."Document Type";
                ToDocExtraCharge."Document No." := ToPurchLine."No.";
                ToDocExtraCharge."Line No." := ToPurchLine."Line No.";
                ToDocExtraCharge."Extra Charge Code" := FromPstdDocExtraCharge."Extra Charge Code";
                ToDocExtraCharge."Currency Code" := FromPstdDocExtraCharge."Currency Code"; // P8000487A
                ToDocExtraCharge.UpdateCurrencyFactor; // P8000487A
                ToDocExtraCharge.Validate(Charge, FromPstdDocExtraCharge.Charge); // P8000487A
                ToDocExtraCharge.Insert;
            until FromPstdDocExtraCharge.Next = 0;
    end;

    [Scope('Internal')]
    procedure CalcChargeToPost(var ECToPost: Record "EN Extra Charge Posting Buffer" temporary; EntryNo: Integer; Expected: Boolean; var PostToGL: Boolean)
    var
        EntryExtraCharge: Record "EN Value Entry Extra Charge";
    begin
        // PR4.00
        EntryExtraCharge.SetRange("Entry No.", EntryNo);
        if EntryExtraCharge.Find('-') then
            repeat
                if not ECToPost.Get(EntryExtraCharge."Extra Charge Code") then begin
                    ECToPost.Init;
                    ECToPost."Extra Charge Code" := EntryExtraCharge."Extra Charge Code";
                    ECToPost.Insert;
                end;
                if Expected then begin
                    ChargeToPost(ECToPost."Cost To Post (Expected)", EntryExtraCharge."Expected Charge",
                      EntryExtraCharge."Expected Charge Posted to G/L", PostToGL);
                    ChargeToPost(ECToPost."Cost To Post (Expected) (ACY)", EntryExtraCharge."Expected Charge (ACY)",
                      EntryExtraCharge."Exp. Chg. Posted to G/L (ACY)", PostToGL);
                end else begin
                    ChargeToPost(ECToPost."Cost To Post", EntryExtraCharge.Charge,
                      EntryExtraCharge."Charge Posted to G/L", PostToGL);
                    ChargeToPost(ECToPost."Cost To Post (ACY)", EntryExtraCharge."Charge (ACY)",
                      EntryExtraCharge."Charge Posted to G/L (ACY)", PostToGL);
                end;
                //EntryExtraCharge.MODIFY; // P8000466A
                ECToPost.Modify;
            until EntryExtraCharge.Next = 0;
    end;

    [Scope('Internal')]
    procedure ChargeToPost(var CostToPost: Decimal; AdjdCost: Decimal; var PostedCost: Decimal; var PostToGL: Boolean)
    begin
        // PR4.00
        CostToPost := AdjdCost - PostedCost;

        if CostToPost <> 0 then begin
            PostedCost := AdjdCost;
            PostToGL := true;
        end;
    end;

    [Scope('Internal')]
    procedure UpdatePostedCharge(EntryNo: Integer; Expected: Boolean)
    var
        EntryExtraCharge: Record "EN Value Entry Extra Charge";
    begin
        // P8000466A
        EntryExtraCharge.SetRange("Entry No.", EntryNo);
        if EntryExtraCharge.Find('-') then
            repeat
                if Expected then begin
                    EntryExtraCharge."Expected Charge Posted to G/L" := EntryExtraCharge."Expected Charge";
                    EntryExtraCharge."Exp. Chg. Posted to G/L (ACY)" := EntryExtraCharge."Expected Charge (ACY)";
                end else begin
                    EntryExtraCharge."Charge Posted to G/L" := EntryExtraCharge.Charge;
                    EntryExtraCharge."Charge Posted to G/L (ACY)" := EntryExtraCharge."Charge (ACY)";
                end;
                EntryExtraCharge.Modify;
            until EntryExtraCharge.Next = 0;
    end;

    [Scope('Internal')]
    procedure ClearDropShipPostingBuffer()
    begin
        // P8000403A
        DropShipPostingBuffer.Reset;
        DropShipPostingBuffer.DeleteAll;
    end;

    [Scope('Internal')]
    procedure StartDropShipPosting(PurchHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    var
        Currency: Record Currency;
    begin
        // P8000403A
        PurchHeader."Posting Date" := SalesHeader."Posting Date";
        PurchHeader.Receive := true;
        PurchHeader.Invoice := false;
        PurchHeader.Ship := false;

        PurchLine."Qty. to Receive" := -SalesLine."Qty. to Ship";


        if PurchHeader."Currency Code" = '' then
            Currency.InitRoundingPrecision
        else begin
            Currency.Get(PurchHeader."Currency Code");
            Currency.TestField("Amount Rounding Precision");
        end;

        StartPurchasePosting(PurchHeader, PurchLine, Currency);

        LinePostingBuffer.Reset;
        if LinePostingBuffer.Find('-') then
            repeat
                DropShipPostingBuffer := LinePostingBuffer;
                DropShipPostingBuffer."Sales Line No." := SalesLine."Line No.";
                DropShipPostingBuffer.Insert;
            until LinePostingBuffer.Next = 0;
    end;

    [Scope('Internal')]
    procedure DropShipMoveToDocumentLine(RcptNo: Code[20]; RcptLineNo: Integer; SalesLineNo: Integer)
    begin
        // P8000403A
        LinePostingBuffer.Reset;
        LinePostingBuffer.DeleteAll;

        DropShipPostingBuffer.Reset;
        DropShipPostingBuffer.SetRange("Sales Line No.", SalesLineNo);
        if DropShipPostingBuffer.Find('-') then
            repeat
                LinePostingBuffer := DropShipPostingBuffer;
                LinePostingBuffer."Sales Line No." := 0;
                LinePostingBuffer.Insert;
            until DropShipPostingBuffer.Next = 0;

        MoveToDocumentLine(DATABASE::"Purch. Rcpt. Line", RcptNo, RcptLineNo);
    end;

    [Scope('Internal')]
    procedure DropShipUpdateVendorBuffer(PurchHeader: Record "Purchase Header")
    begin
        // P8000403A
        PurchHeader."Last Receiving No." := PurchHeader."Receiving No.";
        UpdatePurchaseVendorBuffer(PurchHeader);
    end;

    [Scope('Internal')]
    procedure CopyFromPstdReceiptToPurchLine(PurchRcptLine: Record "Purch. Rcpt. Line"; PurchLine: Record "Purchase Line")
    var
        PostedDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        DocExtraCharge: Record "EN Document Extra Charge";
    begin
        // P8001036
        PostedDocExtraCharge.SetRange("Table ID", DATABASE::"Purch. Rcpt. Line");
        PostedDocExtraCharge.SetRange("Document No.", PurchRcptLine."Document No.");
        PostedDocExtraCharge.SetRange("Line No.", PurchRcptLine."Line No.");
        if PostedDocExtraCharge.FindSet then
            repeat
                DocExtraCharge."Table ID" := DATABASE::"Purchase Line";
                DocExtraCharge."Document Type" := PurchLine."Document Type";
                DocExtraCharge."Document No." := PurchLine."Document No.";
                DocExtraCharge."Line No." := PurchLine."Line No.";
                DocExtraCharge."Extra Charge Code" := PostedDocExtraCharge."Extra Charge Code";
                DocExtraCharge."Charge (LCY)" := PostedDocExtraCharge."Charge (LCY)";
                DocExtraCharge."Currency Code" := PostedDocExtraCharge."Currency Code";
                DocExtraCharge."Currency Factor" := PostedDocExtraCharge."Currency Factor";
                DocExtraCharge.Charge := PostedDocExtraCharge.Charge;
                DocExtraCharge.Insert;
            until PostedDocExtraCharge.Next = 0;
    end;

    [Scope('Internal')]
    procedure UpdateExistingECInvoices(PONum: Code[20])
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        InvHdr: Record "Purchase Header";
        InvLine: Record "Purchase Line";
    begin
        //filter on extraC entries that match ponum
        DocExtraCharge.SetRange("Document Type", ExtraChargeBuffer."Document Type"::Order);
        DocExtraCharge.SetRange("Document No.", PONum);
        DocExtraCharge.SetRange(DocExtraCharge."Line No.", 0);
        if DocExtraCharge.Find('-') then
            repeat
                InvHdr.SetRange("Document Type", InvLine."Document Type"::Invoice);
                InvHdr.SetRange("ExtrChrg crtd for Ord. No. ELA", PONum);
                if InvHdr.Find('-') then begin
                    InvLine.SetRange("Document Type", InvLine."Document Type"::Invoice);
                    InvLine.SetRange("Document No.", InvHdr."No.");
                    InvLine.SetRange("Extra Charge Code ELA", DocExtraCharge."Extra Charge Code");
                    if InvLine.Find('-') then begin
                        InvLine.Validate("Direct Unit Cost", DocExtraCharge.Charge);
                        InvLine.Modify;
                    end;
                end;
            until DocExtraCharge.Next = 0;
    end;

    [Scope('Internal')]
    procedure UpdateExtraChargeSummary(OrderNo: Code[20]; EntryExtraCharge: Record "EN Value Entry Extra Charge"; VEPostingDate: Date)
    var
        ExtraChargeSummary: Record "EN Extra Charge Summary";
        DocExtraCharge: Record "EN Document Extra Charge";
    begin
        // DA0049A
        if not ExtraChargeSummary.Get(OrderNo, EntryExtraCharge."Extra Charge Code") then begin
            ExtraChargeSummary.Init;
            ExtraChargeSummary."Purchase Order No." := OrderNo;
            ExtraChargeSummary."Extra Charge Code" := EntryExtraCharge."Extra Charge Code";
            ExtraChargeSummary.Open := true;
            ExtraChargeSummary."Posting Date" := VEPostingDate;                      //11202008  Added parameter VEPostingDate
            DocExtraCharge.Reset;
            DocExtraCharge.Get(38, 1, OrderNo, 0, EntryExtraCharge."Extra Charge Code");  //11202008
            ExtraChargeSummary."Vendor No." := DocExtraCharge."Vendor No.";        //11202008
            ExtraChargeSummary.Insert;
        end;
        ExtraChargeSummary."Charge Amount (Expected)" += EntryExtraCharge."Expected Charge";
        ExtraChargeSummary."Charge Amount (Actual)" += EntryExtraCharge.Charge;
        ExtraChargeSummary."Charge Amount" := ExtraChargeSummary."Charge Amount (Expected)" + ExtraChargeSummary."Charge Amount (Actual)";
        ExtraChargeSummary.Modify;
        Clear(VEPostingDate);                     //11202008 Added parameter VEPostingDate
        DocExtraCharge.Reset;
    end;

    procedure SetExtraChargeBuffer(var ExtraChargeBuffer: Record "EN Extra Charge Posting Buffer" Temporary; Qty: Decimal; OrderNo: Code[20])
    var
    begin
        ExtraCharge := ExtraChargeBuffer.FIND('-');

        SetBufferForItemPosting(ExtraChargeBuffer, Qty, OrderNo);
    end;
    procedure MoveToValueEntry(var ValueEntry: Record "Value Entry"; ItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    var
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        EntryExtraCharge: Record "EN Value Entry Extra Charge";
        Factor: Decimal;
        Charge: Decimal;
        TotalCharge: Decimal;
        TotalChargeACY: Decimal;
    begin
        if (ValueEntry."Entry Type" <> ValueEntry."Entry Type"::"Direct Cost") or
         ((ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Transfer Receipt") and
          (not ItemLedgEntry.Positive)) or
         (ItemJnlQuantity = 0) or (ValueEntry."Valued Quantity" = 0)
        then
            exit;

        GLSetup.Get;
        if GLSetup."Additional Reporting Currency" <> '' then
            Currency.Get(GLSetup."Additional Reporting Currency");
        Factor := ValueEntry."Valued Quantity" / ItemJnlQuantity;

        ItemJnlPostingBuffer.Reset;
        if ItemJnlPostingBuffer.Find('-') then
            repeat
                EntryExtraCharge.Init;
                EntryExtraCharge."Entry No." := ValueEntry."Entry No.";
                EntryExtraCharge."Extra Charge Code" := ItemJnlPostingBuffer."Extra Charge Code";
                EntryExtraCharge."Item Ledger Entry No." := ValueEntry."Item Ledger Entry No.";
                EntryExtraCharge."Expected Cost" := ValueEntry."Expected Cost";
                Charge := Round(ItemJnlPostingBuffer.Charge * Factor, GLSetup."Amount Rounding Precision");

                if ValueEntry."Expected Cost" then begin
                    EntryExtraCharge."Expected Charge" := Charge;
                    EntryExtraCharge."Expected Charge (ACY)" := ACYMgt.CalcACYAmt(Charge, ValueEntry."Posting Date", false);
                end else begin
                    EntryExtraCharge.Charge := Charge;
                    EntryExtraCharge."Charge (ACY)" := ACYMgt.CalcACYAmt(Charge, ValueEntry."Posting Date", false);
                    CalcExpectedCharge(
                      ItemLedgEntry."Entry No.",
                      EntryExtraCharge."Extra Charge Code",
                      ValueEntry."Invoiced Quantity",
                      ItemLedgEntry.GetCostingQtyELA,
                      EntryExtraCharge."Expected Charge",
                      EntryExtraCharge."Expected Charge (ACY)",
                      ItemLedgEntry.GetCostingQtyELA = ItemLedgEntry.GetCostingInvQtyELA,
                      GLSetup."Amount Rounding Precision",
                      Currency."Amount Rounding Precision");
                end;
                if (EntryExtraCharge.Charge <> 0) or (EntryExtraCharge."Expected Charge" <> 0) then begin
                    EntryExtraCharge.Insert;
                    UpdateExtraChargeSummary(PurchOrderNo, EntryExtraCharge, ValueEntry."Posting Date");
                    ItemJnlPostingBuffer.Charge -= Charge;
                    ItemJnlPostingBuffer.Modify;
                end;
                TotalCharge += EntryExtraCharge.Charge;
                TotalChargeACY += EntryExtraCharge."Charge (ACY)";
            until ItemJnlPostingBuffer.Next = 0;

        ItemJnlQuantity -= ValueEntry."Valued Quantity";


        if ItemLedgEntry."Entry Type" = ItemLedgEntry."Entry Type"::Transfer then begin
            ValueEntry."Cost Amount (Actual)" += TotalCharge;
            ValueEntry."Cost Amount (Actual) (ACY)" += TotalChargeACY;
            if ValueEntry."Valued Quantity" <> 0 then begin
                ValueEntry."Cost per Unit" := Round(ValueEntry."Cost Amount (Actual)" / ValueEntry."Valued Quantity",
                  GLSetup."Unit-Amount Rounding Precision");
                ValueEntry."Cost per Unit (ACY)" := Round(ValueEntry."Cost Amount (Actual) (ACY)" / ValueEntry."Valued Quantity",
                  Currency."Unit-Amount Rounding Precision");
            end else begin
                ValueEntry."Cost per Unit" := 0;
                ValueEntry."Cost per Unit (ACY)" := 0;
            end;
        end;


    end;

}

