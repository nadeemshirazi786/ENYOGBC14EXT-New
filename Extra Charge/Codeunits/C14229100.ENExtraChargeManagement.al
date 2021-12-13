codeunit 14229100 "EN Extra Charge Management"
{
    trigger OnRun()
    begin
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        ExtraChargeBuffer: Record "EN Document Extra Charge" temporary;
        PurchaseCurrency: Record Currency;
        VendorPurchaseInvoice: Record "Purchase Header";
        PurchaseLineTotals: Record "Purchase Line" temporary;
        ACYMgt: Codeunit "Additional-Currency Management";
        PurchSetupShortcutECCode: array[5] of Code[10];
        HasGotPurchSetup: Boolean;
        Text001: Label 'This Shortcut EN  Charge is not defined in the %1.';
        ItemJnlQuantity: Decimal;
        PurchDocType: Option Quote,"Blanket Order","Order",Invoice,"Return Order","Credit Memo","Posted Receipt","Posted Invoice","Posted Return Shipment","Posted Credit Memo";
        PostingDate: Date;
        PurchOrderNo: Code[20];
        VendorBuffer: Record "EN Extra Charge Vendor Buffer";
        LinePostingBuffer: Record "EN Extra Charge Posting Buffer" temporary;
        ItemJnlPostingBuffer: Record "EN Extra Charge Posting Buffer" temporary;

        ECPostingBuffer: Record "EN Extra Charge Posting Buffer";

        DropShipPostingBuffer: Record "EN Extra Charge Posting Buffer";
        ExtraCharge: Boolean;

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


    procedure ShowExtraCharge(TableID: Integer; DocType: Option; DocNo: Code[20]; LineNo: Integer; var ShortcutECCharge: array[5] of Decimal)
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        i: Integer;
    begin

        GetPurchSetup;
        for i := 1 to 5 do begin
            ShortcutECCharge[i] := 0;
            if PurchSetupShortcutECCode[i] <> '' then
                if DocExtraCharge.Get(TableID, DocType, DocNo, LineNo, PurchSetupShortcutECCode[i]) then
                    ShortcutECCharge[i] := DocExtraCharge.Charge;
        end
    end;


    procedure ShowExtraVendor(TableID: Integer; DocType: Option; DocNo: Code[20]; var ShortcutECVendor: array[5] of Code[20])
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        i: Integer;
    begin

        GetPurchSetup;
        for i := 1 to 5 do begin
            ShortcutECVendor[i] := '';
            if PurchSetupShortcutECCode[i] <> '' then
                if DocExtraCharge.Get(TableID, DocType, DocNo, 0, PurchSetupShortcutECCode[i]) then
                    ShortcutECVendor[i] := DocExtraCharge."Vendor No.";
        end;
    end;


    procedure ShowTempExtraCharge(var ShortcutECCharge: array[5] of Decimal)
    var
        i: Integer;
    begin
        GetPurchSetup;
        for i := 1 to 5 do begin
            ShortcutECCharge[i] := 0;
            if PurchSetupShortcutECCode[i] <> '' then
                if ExtraChargeBuffer.Get(0, 0, '', 0, PurchSetupShortcutECCode[i]) then
                    ShortcutECCharge[i] := ExtraChargeBuffer.Charge;
        end;
    end;


    procedure ShowTempExtraVendor(var ShortcutECVendor: array[5] of Code[20])
    var
        i: Integer;
    begin
        GetPurchSetup;
        for i := 1 to 5 do begin
            ShortcutECVendor[i] := '';
            if PurchSetupShortcutECCode[i] <> '' then
                if ExtraChargeBuffer.Get(0, 0, '', 0, PurchSetupShortcutECCode[i]) then
                    ShortcutECVendor[i] := ExtraChargeBuffer."Vendor No.";
        end;
    end;


    procedure ValidateExtraCharge(FieldNumber: Integer; Charge: Decimal)
    begin
        GetPurchSetup;
        if (PurchSetupShortcutECCode[FieldNumber] = '') and (Charge <> 0) then
            Error(Text001, PurchSetup.TableCaption);
    end;


    procedure ValidateExtraVendor(FieldNumber: Integer; VendorNo: Code[20])
    var
        Vendor: Record Vendor;
    begin
        GetPurchSetup;
        if (PurchSetupShortcutECCode[FieldNumber] = '') and (VendorNo <> '') then
            Error(Text001, PurchSetup.TableCaption);
        Vendor.Get(VendorNo);
    end;


    procedure LookupExtraVendor(FieldNumber: Integer; var ShortcutVendorNo: Text[1024]): Boolean
    var
        Vendor: Record Vendor;
    begin

        GetPurchSetup;
        if PurchSetupShortcutECCode[FieldNumber] = '' then
            Error(Text001, PurchSetup.TableCaption);
        Vendor."No." := ShortcutVendorNo;
        if PAGE.RunModal(0, Vendor) = ACTION::LookupOK then begin
            ShortcutVendorNo := Vendor."No.";
            exit(true);
        end;
    end;


    procedure SaveExtraCharge(TableID: Integer; DocType: Integer; DocNo: Code[20]; LineNo: Integer; FieldNumber: Integer; Charge: Decimal)
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        RecRef: RecordRef;
        xRecRef: RecordRef;
        ChangeLogMgt: Codeunit "Change Log Management";
    begin

        GetPurchSetup;
        if Charge <> 0 then begin
            if DocExtraCharge.Get(TableID, DocType, DocNo, LineNo, PurchSetupShortcutECCode[FieldNumber]) then begin
                xRecRef.GetTable(DocExtraCharge);
                DocExtraCharge.Validate(Charge, Charge);
                DocExtraCharge.Modify;
                RecRef.GetTable(DocExtraCharge);
            end else begin
                DocExtraCharge.Init;
                DocExtraCharge."Table ID" := TableID;
                DocExtraCharge.Validate("Document Type", DocType);
                DocExtraCharge.Validate("Document No.", DocNo);
                DocExtraCharge.Validate("Line No.", LineNo);
                DocExtraCharge.InitRecord;
                DocExtraCharge.Validate("Extra Charge Code", PurchSetupShortcutECCode[FieldNumber]);
                DocExtraCharge.Validate(Charge, Charge);
                DocExtraCharge.Insert;
                RecRef.GetTable(DocExtraCharge);
            end;
        end else
            if DocExtraCharge.Get(TableID, DocType, DocNo, LineNo, PurchSetupShortcutECCode[FieldNumber]) then
                if DocExtraCharge."Vendor No." = '' then begin
                    RecRef.GetTable(DocExtraCharge);
                    DocExtraCharge.Delete;

                end;
    end;


    procedure SaveExtraVendor(TableID: Integer; DocType: Integer; DocNo: Code[20]; LineNo: Integer; FieldNumber: Integer; VendorNo: Code[20])
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        RecRef: RecordRef;
        xRecRef: RecordRef;
        ChangeLogMgt: Codeunit "Change Log Management";
    begin

        GetPurchSetup;
        if VendorNo <> '' then begin
            if DocExtraCharge.Get(TableID, DocType, DocNo, LineNo, PurchSetupShortcutECCode[FieldNumber]) then begin
                xRecRef.GetTable(DocExtraCharge);
                DocExtraCharge.Validate("Vendor No.", VendorNo);
                DocExtraCharge.Modify;
                RecRef.GetTable(DocExtraCharge);
            end else begin
                DocExtraCharge.Init;
                DocExtraCharge."Table ID" := TableID;
                DocExtraCharge.Validate("Document Type", DocType);
                DocExtraCharge.Validate("Document No.", DocNo);
                DocExtraCharge.Validate("Line No.", LineNo);
                DocExtraCharge.Validate("Extra Charge Code", PurchSetupShortcutECCode[FieldNumber]);
                DocExtraCharge.Validate("Vendor No.", VendorNo);
                DocExtraCharge.Insert;
                RecRef.GetTable(DocExtraCharge);

            end;
        end else
            if DocExtraCharge.Get(TableID, DocType, DocNo, LineNo, PurchSetupShortcutECCode[FieldNumber]) then
                if DocExtraCharge."Charge (LCY)" = 0 then begin
                    RecRef.GetTable(DocExtraCharge);
                    DocExtraCharge.Delete;

                end;
    end;


    procedure SaveTempExtraCharge(FieldNumber: Integer; Charge: Decimal)
    begin
        GetPurchSetup;
        if Charge <> 0 then begin
            if ExtraChargeBuffer.Get(0, 0, '', 0, PurchSetupShortcutECCode[FieldNumber]) then begin
                ExtraChargeBuffer.Validate(Charge, Charge);
                ExtraChargeBuffer.Modify;
            end else begin
                ExtraChargeBuffer.Init;
                ExtraChargeBuffer.Validate("Extra Charge Code", PurchSetupShortcutECCode[FieldNumber]);
                ExtraChargeBuffer.Validate(Charge, Charge);
                ExtraChargeBuffer.Insert;
            end;
        end else
            if ExtraChargeBuffer.Get(0, 0, '', 0, PurchSetupShortcutECCode[FieldNumber]) then
                if ExtraChargeBuffer."Vendor No." = '' then
                    ExtraChargeBuffer.Delete;
        ExtraChargeBuffer.Reset;
    end;


    procedure SaveTempExtraVendor(FieldNumber: Integer; VendorNo: Code[20])
    begin
        if VendorNo <> '' then begin
            if ExtraChargeBuffer.Get(0, 0, '', 0, PurchSetupShortcutECCode[FieldNumber]) then begin
                ExtraChargeBuffer.Validate("Vendor No.", VendorNo);
                ExtraChargeBuffer.Modify;
            end else begin
                ExtraChargeBuffer.Init;
                ExtraChargeBuffer.Validate("Extra Charge Code", PurchSetupShortcutECCode[FieldNumber]);
                ExtraChargeBuffer.Validate("Vendor No.", VendorNo);
                ExtraChargeBuffer.Insert;
            end;
        end else
            if ExtraChargeBuffer.Get(0, 0, '', 0, PurchSetupShortcutECCode[FieldNumber]) then
                if ExtraChargeBuffer."Charge (LCY)" = 0 then
                    ExtraChargeBuffer.Delete;
        ExtraChargeBuffer.Reset;
    end;


    procedure TotalTempExtraCharge() TotalExtraCharge: Decimal
    begin
        if ExtraChargeBuffer.Find('-') then
            repeat
                TotalExtraCharge += ExtraChargeBuffer.Charge;
            until ExtraChargeBuffer.Next = 0;
        ExtraChargeBuffer.Reset;
    end;


    procedure InsertDocExtraCharge(TableID: Integer; DocType: Integer; DocNo: Code[20]; LineNo: Integer)
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        RecRef: RecordRef;
        ChangeLogMgt: Codeunit "Change Log Management";
    begin
        if ExtraChargeBuffer.Find('-') then begin
            repeat
                DocExtraCharge.Init;
                DocExtraCharge."Table ID" := TableID;
                DocExtraCharge.Validate("Document Type", DocType);
                DocExtraCharge.Validate("Document No.", DocNo);
                DocExtraCharge.Validate("Line No.", LineNo);
                DocExtraCharge.InitRecord;
                DocExtraCharge."Extra Charge Code" := ExtraChargeBuffer."Extra Charge Code";
                DocExtraCharge.Validate(Charge, ExtraChargeBuffer.Charge);
                DocExtraCharge."Vendor No." := ExtraChargeBuffer."Vendor No.";
                DocExtraCharge.Insert;
                RecRef.GetTable(DocExtraCharge);
                ChangeLogMgt.LogInsertion(RecRef);
            until ExtraChargeBuffer.Next = 0;
            ExtraChargeBuffer.Reset;
            ExtraChargeBuffer.DeleteAll;
        end;
    end;


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
                TargetECPostingSetup."Invt. Accrual Acc. (Interim)" := SourceECPostingSetup."Invt. Accrual Acc. (Interim)";
                TargetECPostingSetup.Insert;
            until SourceECPostingSetup.Next = 0;
        end;
    end;


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
        ECPostingBuffer.Reset;
        ECPostingBuffer.DeleteAll;
        PurchaseCurrency := Currency;
        Currency2.InitRoundingPrecision;
        PostingDate := PurchHeader."Posting Date";

        DocExtraCharge.SetRange("Table ID", DATABASE::"Purchase Line");
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

                ECPostingBuffer.Init;
                ECPostingBuffer."Extra Charge Code" := DocExtraCharge."Extra Charge Code";
                ECPostingBuffer.Charge := DocExtraCharge."Charge (LCY)";
                ECPostingBuffer.Quantity := PurchLine."Qty. to Receive" + (SignFactor * PurchLine."Return Qty. to Ship");
                ECPostingBuffer."Invoiced Quantity" := SignFactor * PurchLine."Qty. to Invoice";
                ECPostingBuffer."Recv/Ship Charge" := Round(
                  DocExtraCharge.Charge * ECPostingBuffer.Quantity / PurchLine.Quantity,
                  Currency."Amount Rounding Precision");
                ECPostingBuffer."Invoicing Charge" := Round(
                  DocExtraCharge.Charge * ECPostingBuffer."Invoiced Quantity" / PurchLine.Quantity,
                  Currency."Amount Rounding Precision");
                ECPostingBuffer."Recv/Ship Charge (LCY)" :=
                  Round(
                    DocExtraCharge."Charge (LCY)" * ECPostingBuffer.Quantity / PurchLine.Quantity,
                    Currency2."Amount Rounding Precision");
                ECPostingBuffer."Invoicing Charge (LCY)" :=
                  Round(DocExtraCharge."Charge (LCY)" * ECPostingBuffer."Invoiced Quantity" / PurchLine.Quantity,
                    Currency2."Amount Rounding Precision");
                //<<EN 102918 Rpatel
                if PstdRcptCharge <> 0 then begin
                    ECPostingBuffer."Recv/Ship Charge" := DocExtraCharge.Charge - PstdRcptCharge;
                    ECPostingBuffer."Recv/Ship Charge (LCY)" := DocExtraCharge."Charge (LCY)" - PstdRcptChargeLCY;
                end;
                //>>EN 102918

                ECPostingBuffer.Insert;

                if PurchHeader.Invoice then begin
                    ExtraCharge.Get(ECPostingBuffer."Extra Charge Code");
                    ExtraCharge.Mark(false);
                end;
            until DocExtraCharge.Next = 0;

        if PurchHeader.Invoice then begin
            ExtraCharge.MarkedOnly(true);
            if ExtraCharge.FindSet then begin
                ECPostingBuffer.Init;
                ECPostingBuffer.Quantity := PurchLine."Qty. to Receive" + (SignFactor * PurchLine."Return Qty. to Ship");
                ECPostingBuffer."Invoiced Quantity" := SignFactor * PurchLine."Qty. to Invoice";
                repeat
                    ECPostingBuffer."Extra Charge Code" := ExtraCharge.Code;
                    ECPostingBuffer.Insert;
                until ExtraCharge.Next = 0;
            end;
        end;

    end;


    procedure StartTransferPosting(TransHeader: Record "Transfer Header"; TransLine: Record "Transfer Line")
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        Currency: Record Currency;
    begin

        ECPostingBuffer.Reset;
        ECPostingBuffer.DeleteAll;
        Currency.InitRoundingPrecision;
        PostingDate := TransHeader."Posting Date";

        DocExtraCharge.SetRange("Table ID", DATABASE::"Transfer Line");
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
                ECPostingBuffer.Init;
                ECPostingBuffer."Extra Charge Code" := DocExtraCharge."Extra Charge Code";
                ECPostingBuffer.Charge := DocExtraCharge."Charge (LCY)";
                ECPostingBuffer.Quantity := TransLine."Qty. to Receive";
                ECPostingBuffer."Invoiced Quantity" := TransLine."Qty. to Receive";
                ECPostingBuffer."Recv/Ship Charge" := Round(
                  DocExtraCharge.Charge * ECPostingBuffer.Quantity / TransLine.Quantity,
                  Currency."Amount Rounding Precision");
                ECPostingBuffer."Invoicing Charge" := ECPostingBuffer."Recv/Ship Charge";
                ECPostingBuffer."Recv/Ship Charge (LCY)" := ECPostingBuffer."Recv/Ship Charge";
                ECPostingBuffer."Invoicing Charge (LCY)" := ECPostingBuffer."Recv/Ship Charge";
                ECPostingBuffer.Insert;
            until DocExtraCharge.Next = 0;
    end;

    procedure SetExtraChargeBuffer(var ExtraChargeBuffer: Record "EN Extra Charge Posting Buffer" Temporary; Qty: Decimal; OrderNo: Code[20])
    var
    begin
        ExtraCharge := ExtraChargeBuffer.FIND('-');

        SetBufferForItemPosting(ExtraChargeBuffer, Qty, OrderNo);
    end;

    procedure AdjustItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; var PostingBuffer: Record "EN Extra Charge Posting Buffer"; var ExtraChargeQuantity: Decimal)
    var
        GLSetup: Record "General Ledger Setup";
        TotalCharge: Decimal;
        TotalChargeLCY: Decimal;
        ChargeLCY: Decimal;
        Factor: Decimal;
        Quantity: Decimal;
    begin
        PostingBuffer.Reset;
        if not PostingBuffer.Find('-') then
            exit;

        if ItemJnlLine."Invoiced Quantity" <> 0 then begin

            ExtraChargeQuantity := ItemJnlLine.GetCostingQtyELA(ItemJnlLine.FieldNo("Invoiced Qty. (Base)"));
            Factor := ItemJnlLine.GetCostingQtyELA(ItemJnlLine.FieldNo("Invoiced Quantity")) /
              PostingBuffer."Invoiced Quantity";

        end else begin

            ExtraChargeQuantity := ItemJnlLine.GetCostingQtyELA(ItemJnlLine.FieldNo("Quantity (Base)"));
            Factor := ItemJnlLine.GetCostingQtyELA(ItemJnlLine.FieldNo(Quantity)) /
              PostingBuffer.Quantity;
        end;

        GLSetup.Get;
        repeat
            if ItemJnlLine."Invoiced Quantity" <> 0 then begin
                TotalCharge += PostingBuffer."Invoicing Charge";
                ChargeLCY := PostingBuffer."Invoicing Charge (LCY)";
            end else begin
                TotalCharge += PostingBuffer."Recv/Ship Charge";
                ChargeLCY := PostingBuffer."Recv/Ship Charge (LCY)";
            end;
            ChargeLCY := ChargeLCY * Factor + PostingBuffer."Remaining Amount";
            // PostingBuffer.Init;
            // PostingBuffer."Extra Charge Code" := LinePostingBuffer."Extra Charge Code";
            // PostingBuffer.Charge := Round(ChargeLCY, GLSetup."Amount Rounding Precision");
            // PostingBuffer.Insert;
            PostingBuffer."Remaining Amount" := ChargeLCY - PostingBuffer.Charge;
            PostingBuffer.Modify;
            TotalChargeLCY += PostingBuffer.Charge;
        until PostingBuffer.Next = 0;


        if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Purchase then begin
            ItemJnlLine.Amount += TotalChargeLCY;
            if ItemJnlLine."Invoiced Quantity" <> 0 then
                Quantity := ItemJnlLine.GetCostingQtyELA(ItemJnlLine.FieldNo("Invoiced Quantity"))
            else
                Quantity := ItemJnlLine.GetCostingQtyELA(ItemJnlLine.FieldNo(Quantity));

            ItemJnlLine."Unit Cost (ACY)" += Round(TotalCharge / Quantity, PurchaseCurrency."Unit-Amount Rounding Precision");
            ItemJnlLine."Unit Cost" += Round(TotalChargeLCY / Quantity, GLSetup."Unit-Amount Rounding Precision");
        end;
    end;


    procedure MoveToDocumentHeader(TableID: Integer; SourceDocType: Option; SourceDocNo: Code[20]; PostDate: Date; TableNo: Integer; DocNo: Code[20])
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        PstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
    begin

        DocExtraCharge.SetRange("Table ID", TableID);
        DocExtraCharge.SetRange("Document Type", SourceDocType);
        DocExtraCharge.SetRange("Document No.", SourceDocNo);

        if DocExtraCharge.Find('-') then
            repeat
                PstdDocExtraCharge."Table ID" := TableNo;
                PstdDocExtraCharge."Document No." := DocNo;
                PstdDocExtraCharge."Line No." := 0;
                PstdDocExtraCharge."Extra Charge Code" := DocExtraCharge."Extra Charge Code";
                PstdDocExtraCharge."Charge (LCY)" := 0;
                PstdDocExtraCharge."Vendor No." := DocExtraCharge."Vendor No.";
                PstdDocExtraCharge."Allocation Method" := DocExtraCharge."Allocation Method";
                PstdDocExtraCharge."Currency Code" := DocExtraCharge."Currency Code";
                PstdDocExtraCharge.UpdateCurrencyFactor(PostDate);
                PstdDocExtraCharge.Charge := 0;
                //<<EN 102918 Rpatel
                PstdDocExtraCharge."Posting Date" := Today;
                if TableNo in [120, 121] then begin
                    PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Interim;
                    //<<EN 122618 Rpatel
                    if DocExtraCharge."Vendor No." = '' then begin
                        if PurchRcptHeader.Get(DocNo) then
                            PstdDocExtraCharge."Vendor No." := PurchRcptHeader."Buy-from Vendor No.";
                    end;
                    //>>EN 122618
                    //<<EN 081019 Rpatel
                    PurchInvLine.Reset;
                    //PurchInvLine.SETCURRENTKEY(Type,"No.","Purch. Order for Extra Charge","Extra Charge Code");}TBR
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
                PstdDocExtraCharge.Insert;
            until DocExtraCharge.Next = 0;
    end;


    procedure MoveToDocumentLine(TableNo: Integer; DocNo: Code[20]; LineNo: Integer)
    var
        PstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        HeaderTable: Integer;
        ChargeLCY: Decimal;
        PstdDocExtraCharge1: Record "EN Posted Doc. Extra Charges";
        PurchInvLine: Record "Purch. Inv. Line";

    begin

        ECPostingBuffer.Reset;
        if ECPostingBuffer.Find('-') then
            repeat
                case TableNo of
                    DATABASE::"Purch. Rcpt. Line":
                        begin
                            HeaderTable := DATABASE::"Purch. Rcpt. Header";
                            ChargeLCY := ECPostingBuffer."Recv/Ship Charge (LCY)";
                        end;
                    DATABASE::"Return Shipment Line":
                        begin
                            HeaderTable := DATABASE::"Return Shipment Header";
                            ChargeLCY := -ECPostingBuffer."Recv/Ship Charge (LCY)";
                        end;
                    DATABASE::"Purch. Inv. Line":
                        begin
                            HeaderTable := DATABASE::"Purch. Inv. Header";
                            ChargeLCY := ECPostingBuffer."Invoicing Charge (LCY)";
                        end;
                    DATABASE::"Purch. Cr. Memo Line":
                        begin
                            HeaderTable := DATABASE::"Purch. Cr. Memo Hdr.";
                            ChargeLCY := -ECPostingBuffer."Invoicing Charge (LCY)";

                        end;

                    DATABASE::"Transfer Receipt Line":
                        begin
                            HeaderTable := DATABASE::"Transfer Receipt Header";
                            ChargeLCY := ECPostingBuffer."Invoicing Charge (LCY)";
                        end;

                end;

                if ChargeLCY <> 0 then begin
                    PstdDocExtraCharge."Table ID" := TableNo;
                    PstdDocExtraCharge."Document No." := DocNo;
                    PstdDocExtraCharge."Line No." := LineNo;
                    PstdDocExtraCharge."Extra Charge Code" := ECPostingBuffer."Extra Charge Code";
                    PstdDocExtraCharge."Currency Code" := PurchaseCurrency.Code;
                    PstdDocExtraCharge.UpdateCurrencyFactor(PostingDate);
                    PstdDocExtraCharge."Charge (LCY)" := ChargeLCY;

                    PstdDocExtraCharge.ChargeLCYToCharge(PostingDate);
                    PstdDocExtraCharge."Vendor No." := '';
                    //<<EN 122618 Rpatel
                    if PstdDocExtraCharge1.Get(HeaderTable, DocNo, 0, ECPostingBuffer."Extra Charge Code") and
                      (PstdDocExtraCharge1."Vendor No." <> '')
                    then
                        PstdDocExtraCharge."Vendor No." := PstdDocExtraCharge1."Vendor No.";
                    //>>EN 122618
                    PstdDocExtraCharge."Allocation Method" := 0;
                    //<<EN 102918 Rpatel
                    if TableNo in [120, 121] then begin
                        PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Interim;
                        //<<EN 081019 Rpatel
                        PurchInvLine.Reset;
                        PurchInvLine.SetCurrentKey(Type, "No.", "Purch. Ord for Extra Chrg ELA", "Extra Charge Code ELA");
                        PurchInvLine.SetRange("Extra Charge Code ELA", ECPostingBuffer."Extra Charge Code");
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
                        PurchInvLine.SetRange("Extra Charge Code ELA", ECPostingBuffer."Extra Charge Code");
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
                    PstdDocExtraCharge.Insert;

                    if not PstdDocExtraCharge.Get(HeaderTable, DocNo, 0, ECPostingBuffer."Extra Charge Code") then begin
                        PstdDocExtraCharge."Table ID" := HeaderTable;
                        PstdDocExtraCharge."Document No." := DocNo;
                        PstdDocExtraCharge."Line No." := 0;
                        PstdDocExtraCharge."Extra Charge Code" := ECPostingBuffer."Extra Charge Code";
                        PstdDocExtraCharge."Currency Code" := '';
                        PstdDocExtraCharge."Currency Factor" := 0;
                        PstdDocExtraCharge."Charge (LCY)" := 0;
                        PstdDocExtraCharge."Vendor No." := '';
                        PstdDocExtraCharge."Allocation Method" := 0;
                        //<<EN 102918 Rpatel
                        PstdDocExtraCharge."Posting Date" := Today;
                        if TableNo in [120, 121] then begin
                            PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Interim;
                            //<<EN 081019 Rpatel
                            PurchInvLine.Reset;
                            PurchInvLine.SetCurrentKey(Type, "No.", "Purch. Ord for Extra Chrg ELA", "Extra Charge Code ELA");
                            PurchInvLine.SetRange("Extra Charge Code ELA", ECPostingBuffer."Extra Charge Code");
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
                            PurchInvLine.SetRange("Extra Charge Code ELA", ECPostingBuffer."Extra Charge Code");
                            PurchInvLine.SetFilter("Purch. Ord for Extra Chrg ELA", '%1', DocNo + '*');
                            if PurchInvLine.FindFirst then begin
                                PstdDocExtraCharge.Status := PstdDocExtraCharge.Status::Closed;
                                PstdDocExtraCharge."EC Invoice No." := PurchInvLine."Document No.";
                                PstdDocExtraCharge."EC Inv Posting Date" := PurchInvLine."Posting Date";
                            end;
                            //>>EN 081019
                        end;
                        //>>EN 102918 Rpatel
                        PstdDocExtraCharge.Insert;
                    end;

                    PstdDocExtraCharge."Charge (LCY)" += ChargeLCY;
                    PstdDocExtraCharge.ChargeLCYToCharge(PostingDate);
                    PstdDocExtraCharge.Modify;
                end;
            until ECPostingBuffer.Next = 0;
    end;


    procedure CopyDocExtraCharge(SourceTableID: Integer; SourceDocNo: Code[20]; SourceLineNo: Integer; TargetTableID: Integer; TargetDocNo: Code[20]; TargetLineNo: Integer; Sign: Integer)
    var
        SourcePstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        TargetPstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
    begin
        TargetPstdDocExtraCharge."Table ID" := TargetTableID;
        TargetPstdDocExtraCharge."Document No." := TargetDocNo;
        TargetPstdDocExtraCharge."Line No." := TargetLineNo;

        SourcePstdDocExtraCharge.SetRange("Table ID", SourceTableID);
        SourcePstdDocExtraCharge.SetRange("Document No.", SourceDocNo);
        SourcePstdDocExtraCharge.SetRange("Line No.", SourceLineNo);
        if SourcePstdDocExtraCharge.Find('-') then
            repeat
                TargetPstdDocExtraCharge."Extra Charge Code" := SourcePstdDocExtraCharge."Extra Charge Code";
                TargetPstdDocExtraCharge."Charge (LCY)" := Sign * SourcePstdDocExtraCharge."Charge (LCY)";
                TargetPstdDocExtraCharge."Currency Code" := SourcePstdDocExtraCharge."Currency Code";
                TargetPstdDocExtraCharge."Currency Factor" := SourcePstdDocExtraCharge."Currency Factor";
                TargetPstdDocExtraCharge.Charge := Sign * SourcePstdDocExtraCharge.Charge;
                //<<EN 102918 Rpatel
                TargetPstdDocExtraCharge."Source Line No." := SourcePstdDocExtraCharge."Source Line No.";
                TargetPstdDocExtraCharge."Posting Date" := Today;
                //>>EN 102918
                TargetPstdDocExtraCharge.Insert;
            until SourcePstdDocExtraCharge.Next = 0;

    end;


    procedure CalculateDocExtraCharge(DocTable: Integer; DocLineTable: Integer; DocNo: Code[20]; PostingDate: Date)
    var
        PstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        PstdDocLineExtraCharge: Record "EN Posted Doc. Extra Charges";
    begin

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
                PstdDocExtraCharge.ChargeLCYToCharge(PostingDate);
                PstdDocExtraCharge.Modify;
            until PstdDocExtraCharge.Next = 0;
    end;


    procedure SetBufferForItemPosting(var PostingBuffer: Record "EN Extra Charge Posting Buffer"; Qty: Decimal; OrderNo: Code[20])
    begin

        ItemJnlPostingBuffer.Reset;
        ItemJnlPostingBuffer.DeleteAll;
        PostingBuffer.Reset;
        if PostingBuffer.FindSET then
            repeat
                ItemJnlPostingBuffer.TransferFields(PostingBuffer, true);
                ItemJnlPostingBuffer.Insert;
            until PostingBuffer.Next = 0;
        ItemJnlQuantity := Qty;
        PurchOrderNo := OrderNo;
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


    procedure CalcExpectedCharge(ItemLedgEntryNo: Integer; ChargeCode: Code[10]; InvoicedQty: Decimal; Quantity: Decimal; var ExpectedCharge: Decimal; var ExpectedChargeACY: Decimal; CalcRemainder: Boolean; RoundPrecision: Decimal; RoundPrecisionACY: Decimal)
    var
        EntryExtraCharge: Record "EN Value Entry Extra Charge";
    begin


        EntryExtraCharge.SetCurrentKey("Item Ledger Entry No.", "Extra Charge Code", "Expected Cost");
        EntryExtraCharge.SetRange("Item Ledger Entry No.", ItemLedgEntryNo);
        EntryExtraCharge.SetRange("Extra Charge Code", ChargeCode);
        EntryExtraCharge.SetRange("Expected Cost", true);
        if EntryExtraCharge.Find('-') then begin
            if CalcRemainder then
                EntryExtraCharge.SetRange(EntryExtraCharge."Expected Cost");
            EntryExtraCharge.CalcSums(EntryExtraCharge."Expected Charge", EntryExtraCharge."Expected Charge (ACY)");

            if CalcRemainder then begin
                ExpectedCharge := -EntryExtraCharge."Expected Charge";
                ExpectedChargeACY := -EntryExtraCharge."Expected Charge (ACY)";
            end else begin
                ExpectedCharge :=
                    CalcExpCostToBalance(EntryExtraCharge."Expected Charge", InvoicedQty, Quantity, RoundPrecision);
                ExpectedChargeACY :=
                    CalcExpCostToBalance(EntryExtraCharge."Expected Charge (ACY)", InvoicedQty, Quantity, RoundPrecisionACY);
            end;
        end;

    end;


    procedure CalcExpCostToBalance(ExpectedCharge: Decimal; InvoicedQty: Decimal; Quantity: Decimal; RoundPrecision: Decimal): Decimal
    begin

        exit(-Round(InvoicedQty / Quantity * ExpectedCharge, RoundPrecision));
    end;


    procedure CopyEntryExtraCharge(SourceEntryNo: Integer; TargetEntryNo: Integer; Sign: Integer; ExpectedCost: Boolean; QtyToShip: Decimal)
    var
        SourceEntryExtraCharge: Record "EN Value Entry Extra Charge";
        TargetEntryExtraCharge: Record "EN Value Entry Extra Charge";
    begin


        SourceEntryExtraCharge.SetRange("Entry No.", SourceEntryNo);
        if SourceEntryExtraCharge.Find('-') then
            repeat

                TargetEntryExtraCharge := SourceEntryExtraCharge;
                TargetEntryExtraCharge."Entry No." := TargetEntryNo;

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

                TargetEntryExtraCharge."Charge Posted to G/L" := 0;
                TargetEntryExtraCharge."Charge Posted to G/L (ACY)" := 0;
                TargetEntryExtraCharge."Expected Charge Posted to G/L" := 0;
                TargetEntryExtraCharge."Exp. Chg. Posted to G/L (ACY)" := 0;

                TargetEntryExtraCharge.Insert;
            until SourceEntryExtraCharge.Next = 0;

    end;


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
        TotalsAreZero: Boolean;
        i: Integer;
        NegativeLinesExist: Boolean;
        LineTableID: Integer;
    begin

        case TableID of
            DATABASE::"Purchase Header":
                LineTableID := DATABASE::"Purchase Line";
            DATABASE::"Transfer Header":
                LineTableID := DATABASE::"Transfer Line";
        end;
        DocLineExtraCharge.SetRange("Table ID", LineTableID);

        DocLineExtraCharge.SetRange("Document Type", DocType);
        DocLineExtraCharge.SetRange("Document No.", DocNo);

        DocExtraCharge.SetRange("Table ID", TableID);
        DocExtraCharge.SetRange("Document Type", DocType);
        DocExtraCharge.SetRange("Document No.", DocNo);

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


        case TableID of
            DATABASE::"Purchase Header":
                GetPurchaseLineTotals(DocType, DocNo, LineTotals, NegativeLinesExist);
            DATABASE::"Transfer Header":
                GetTransferLineTotals(DocNo, LineTotals);
        end;

        TotalsAreZero := true;
        for i := 1 to ArrayLen(LineTotals) do
            TotalsAreZero := TotalsAreZero and (LineTotals[i] = 0);

        //<<EN 100519 Rpatel
        //IF TotalsAreZero THEN
        //  EXIT;
        //>>EN 100519 Rpatel

        Currency.InitRoundingPrecision;

        DocLineExtraCharge."Table ID" := LineTableID;
        DocLineExtraCharge."Document Type" := DocType;
        DocLineExtraCharge."Document No." := DocNo;


        case TableID of
            DATABASE::"Purchase Header":
                begin
                    PurchaseLine.SetRange("Document Type", DocType);
                    PurchaseLine.SetRange("Document No.", DocNo);
                    PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
                    PurchaseLine.SetFilter("No.", '<>%1', '');

                    if NegativeLinesExist then begin
                        PurchaseLine.SetFilter(Quantity, '<0');
                        if PurchaseLine.FindSet then
                            repeat

                                CalcLineAllocation(TempDocExtraCharge, LineTotals,
                                  PurchaseLine."Line Amount", PurchaseLine."Gross Weight" * PurchaseLine.Quantity,
                                  PurchaseLine."Unit Volume" * PurchaseLine.Quantity, PurchaseLine."Quantity",
                                  PurchaseLine."Pallet Count ELA",
                                  DATABASE::"Purchase Line", DocType, DocNo, PurchaseLine."Line No.",
                                  Currency, CurrencyCode);
                            until PurchaseLine.Next = 0;
                        PurchaseLine.SetFilter(Quantity, '>=0');
                    end;
                    if PurchaseLine.FindSet then
                        repeat
                            CalcLineAllocation(TempDocExtraCharge, LineTotals,
                              PurchaseLine."Line Amount", PurchaseLine."Gross Weight" * PurchaseLine.Quantity,
                              PurchaseLine."Unit Volume" * PurchaseLine.Quantity, PurchaseLine."Quantity",
                              PurchaseLine."Pallet Count ELA",
                              DATABASE::"Purchase Line", DocType, DocNo, PurchaseLine."Line No.",
                              Currency, CurrencyCode);
                        until PurchaseLine.Next = 0;
                end;

        end;

    end;


    procedure CalcLineAllocation(var TempDocExtraCharge: Record "EN Document Extra Charge" temporary; var LineTotals: array[5] of Decimal; Amount: Decimal; Weight: Decimal; Volume: Decimal; Quantity: Decimal; Pallet: Decimal; TableID: Integer; DocType: Integer; DocNo: Code[20]; LineNo: Integer; var Currency: Record Currency; CurrencyCode: Code[10])
    var
        DocLineExtraCharge: Record "EN Document Extra Charge";
        Qty: Decimal;
    begin

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
                        Qty := Pallet;
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
        LineTotals[DocLineExtraCharge."Allocation Method"::Pallet] -= Pallet;
    end;


    procedure GetPurchaseLineTotals(DocType: Integer; DocNo: Code[20]; var LineTotals: array[5] of Decimal; var NegativeLinesExist: Boolean)
    var
        PurchaseLine: Record "Purchase Line";
        DocExtraCharge: Record "EN Document Extra Charge";
        ItemUOM: Record "Item Unit of Measure";
    begin
        Clear(LineTotals);
        if not PurchaseLineTotals.Get(DocType, DocNo) then begin
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
                    PurchaseLineTotals."Gross Weight" += PurchaseLine."Gross Weight" * PurchaseLine.Quantity;
                    PurchaseLineTotals."Unit Volume" += PurchaseLine."Unit Volume" * PurchaseLine.Quantity;

                    PurchaseLineTotals."Quantity (Base)" += PurchaseLine."Quantity (Base)";

                    ItemUOM.Get(PurchaseLine."No.", 'PALLET');
                    PurchaseLineTotals."Pallet Count ELA" += PurchaseLine."Pallet Count ELA";
                    if PurchaseLine.Quantity < 0 then
                        NegativeLinesExist := true;
                until PurchaseLine.Next = 0;
            PurchaseLineTotals.Insert;
        end;

        LineTotals[DocExtraCharge."Allocation Method"::Amount] += PurchaseLineTotals."Line Amount";
        LineTotals[DocExtraCharge."Allocation Method"::Weight] += PurchaseLineTotals."Gross Weight";
        LineTotals[DocExtraCharge."Allocation Method"::Volume] += PurchaseLineTotals."Unit Volume";
        LineTotals[DocExtraCharge."Allocation Method"::Quantity] += PurchaseLineTotals."Quantity (Base)";
        LineTotals[DocExtraCharge."Allocation Method"::Pallet] += PurchaseLineTotals."Pallet Count ELA";

    end;


    procedure GetTransferLineTotals(DocNo: Code[20]; var LineTotals: array[5] of Decimal)
    var
        TransferLine: Record "Transfer Line";
        DocExtraCharge: Record "EN Document Extra Charge";
    begin
        Clear(LineTotals);
        TransferLine.SetRange("Document No.", DocNo);
        //TransferLine.SETRANGE(Type,TransferLine.Type::Item); TBR
        TransferLine.SetFilter("Item No.", '<>%1', '');
        TransferLine.SetRange("Derived From Line No.", 0);
        if TransferLine.FindSet then
            repeat
                //LineTotals[DocExtraCharge."Allocation Method"::Amount] += TransferLine.LineCost; TBR
                LineTotals[DocExtraCharge."Allocation Method"::Weight] += TransferLine."Gross Weight" * TransferLine.Quantity;
                LineTotals[DocExtraCharge."Allocation Method"::Volume] += TransferLine."Unit Volume" * TransferLine.Quantity;
            /*
              LineTotals[DocExtraCharge."Allocation Method"::Quantity] += TransferLine."Quantity (Base)";
            LineTotals[DocExtraCharge."Allocation Method"::Pallet] += TransferLine."Pallet Count";      //12-10-2014    *///TBR
            until TransferLine.Next = 0;

    end;


    procedure FCYtoLCY(Amount: Decimal; ExchDate: Date; Currency: Record Currency; CurrencyFactor: Decimal): Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin

        if Currency.Code <> '' then
            exit(Round(CurrExchRate.ExchangeAmtFCYToLCY(ExchDate, Currency.Code, Amount, CurrencyFactor), Currency."Amount Rounding Precision"))
        else
            exit(Amount);
    end;


    procedure UpdatePurchaseVendorBuffer(PurchHeader: Record "Purchase Header")
    var
        PstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        PstdDocExtraCharge2: Record "EN Posted Doc. Extra Charges";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ExtraChargePostingSetup: Record "EN Extra Charge Posting Setup";
        Vendor: Record Vendor;
    begin

        PstdDocExtraCharge2.SetRange("Table ID", DATABASE::"Purch. Rcpt. Header");
        PstdDocExtraCharge2.SetRange("Document No.", PurchHeader."Last Receiving No.");
        PstdDocExtraCharge2.SetRange("Line No.", 0);

        PstdDocExtraCharge2.SetFilter("Vendor No.", '<>%1', PurchHeader."Buy-from Vendor No."); //EN 122618 Rpatel
        if not PstdDocExtraCharge2.Find('-') then
            exit;

        VendorPurchaseInvoice."Posting Date" := PurchHeader."Posting Date";
        VendorPurchaseInvoice."Vendor Shipment No." := PurchHeader."Vendor Shipment No.";

        VendorPurchaseInvoice."No." := PurchHeader."No.";


        PstdDocExtraCharge.SetRange("Table ID", DATABASE::"Purch. Rcpt. Line");
        PstdDocExtraCharge.SetRange("Document No.", PurchHeader."Last Receiving No.");
        repeat
            if PstdDocExtraCharge2."Vendor No." <> '' then
                Vendor.Get(PstdDocExtraCharge2."Vendor No.");
            if Vendor."Pay-to Vendor No." <> '' then
                Vendor.Get(Vendor."Pay-to Vendor No.");

            PstdDocExtraCharge.SetRange("Extra Charge Code", PstdDocExtraCharge2."Extra Charge Code");
            if PstdDocExtraCharge.Find('-') then
                repeat
                    PurchRcptLine.Get(PurchHeader."Last Receiving No.", PstdDocExtraCharge."Line No.");
                    if ExtraChargePostingSetup.Get(PurchRcptLine."Gen. Bus. Posting Group", PurchRcptLine."Gen. Prod. Posting Group",
                      PstdDocExtraCharge2."Extra Charge Code")
                    then
                        if ExtraChargePostingSetup."Direct Cost Applied Account" <> '' then begin
                            IF NOT VendorBuffer.GET(PstdDocExtraCharge2."Vendor No.", PstdDocExtraCharge2."Currency Code",
                              PstdDocExtraCharge2."Extra Charge Code", ExtraChargePostingSetup."Direct Cost Applied Account")
                            THEN BEGIN
                                VendorBuffer.INIT;
                                VendorBuffer."Vendor No." := PstdDocExtraCharge2."Vendor No.";
                                VendorBuffer."Currency Code" := PstdDocExtraCharge2."Currency Code";
                                VendorBuffer."Extra Charge Code" := PstdDocExtraCharge2."Extra Charge Code";
                                VendorBuffer."Account No." := ExtraChargePostingSetup."Direct Cost Applied Account";
                                VendorBuffer.INSERT;
                            END;


                            VendorBuffer.Charge += PstdDocExtraCharge."Charge (LCY)";

                            VendorBuffer.MODIFY;
                        end;
                until PstdDocExtraCharge.Next = 0;
        until PstdDocExtraCharge2.Next = 0;

    end;


    procedure UpdateTransferVendorBuffer(TransHeader: Record "Transfer Header")
    var
        PstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        PstdDocExtraCharge2: Record "EN Posted Doc. Extra Charges";
        TransRcptLine: Record "Transfer Receipt Line";
        ExtraChargePostingSetup: Record "EN Extra Charge Posting Setup";
        Vendor: Record Vendor;
    begin

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
                            IF NOT VendorBuffer.GET(PstdDocExtraCharge2."Vendor No.", '',
                              PstdDocExtraCharge2."Extra Charge Code", ExtraChargePostingSetup."Direct Cost Applied Account")
                            THEN BEGIN
                                VendorBuffer.INIT;
                                VendorBuffer."Vendor No." := PstdDocExtraCharge2."Vendor No.";
                                VendorBuffer."Extra Charge Code" := PstdDocExtraCharge2."Extra Charge Code";
                                VendorBuffer."Account No." := ExtraChargePostingSetup."Direct Cost Applied Account";
                                VendorBuffer.INSERT;
                            END;
                            VendorBuffer.Charge += PstdDocExtraCharge."Charge (LCY)";
                            VendorBuffer.MODIFY;
                        end;
                until PstdDocExtraCharge.Next = 0;
        until PstdDocExtraCharge2.Next = 0;

    end;


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

        VendorBuffer.RESET;
        IF ExtraCharge.FIND('-') THEN
            REPEAT
                VendorBuffer.SETRANGE("Extra Charge Code", ExtraCharge.Code);
                VendorBuffer.SETFILTER(Charge, '>0'); //EN 102918 Rpatel
                IF VendorBuffer.FIND('-') THEN
                    REPEAT
                        //<<EN 102918 Rpatel
                        //VendorBuffer.MARK(TRUE);
                        InvLine.SETRANGE("Document Type", InvLine."Document Type"::Order);
                        InvLine.SETRANGE("Purch. Ord for Ext Charge ELA", VendorPurchaseInvoice."No.");
                        InvLine.SETRANGE("Extra Charge Code ELA", VendorBuffer."Extra Charge Code");
                        IF NOT InvLine.FINDFIRST THEN
                            VendorBuffer.MARK(TRUE);
                    //>>EN 102918
                    UNTIL VendorBuffer.NEXT = 0;
            UNTIL ExtraCharge.NEXT = 0;

        VendorBuffer.SETRANGE("Extra Charge Code");
        VendorBuffer.MARKEDONLY(TRUE);
        IF NOT VendorBuffer.FIND('-') THEN
            EXIT;

        REPEAT

            IF VendorBuffer."Currency Code" <> '' THEN
                Currency.GET(VendorBuffer."Currency Code")
            ELSE BEGIN
                CLEAR(Currency);
                Currency.InitRoundingPrecision;
            END;

            PurchaseHeader.INIT;
            PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
            PurchaseHeader."No." := '';
            PurchaseHeader.INSERT(TRUE);
            PurchaseHeader.VALIDATE("Buy-from Vendor No.", VendorBuffer."Vendor No.");
            PurchaseHeader.VALIDATE("Posting Date", VendorPurchaseInvoice."Posting Date");
            PurchaseHeader.VALIDATE("Document Date", VendorPurchaseInvoice."Posting Date");
            PurchaseHeader.VALIDATE("Vendor Shipment No.", VendorPurchaseInvoice."Vendor Shipment No.");
            PurchaseHeader.VALIDATE("Currency Code", VendorBuffer."Currency Code");
            IF VendorPurchaseInvoice."No." <> '' THEN
                PurchaseHeader."ExtrChrg crtd for Ord. No. ELA" := VendorPurchaseInvoice."No.";
            PurchaseHeader.MODIFY(TRUE);
            VendorBuffer.SETRANGE("Vendor No.", VendorBuffer."Vendor No.");
            VendorBuffer.SETRANGE("Currency Code", VendorBuffer."Currency Code");
            PurchaseLine."Document Type" := PurchaseHeader."Document Type";
            PurchaseLine."Document No." := PurchaseHeader."No.";
            PurchaseLine."Line No." := 0;
            REPEAT
                PurchaseLine.INIT;
                PurchaseLine."Line No." += 10000;
                PurchaseLine.Type := PurchaseLine.Type::"G/L Account";
                PurchaseLine.VALIDATE("No.", VendorBuffer."Account No.");
                ExtraCharge.GET(VendorBuffer."Extra Charge Code");
                IF ExtraCharge.Description <> '' THEN
                    PurchaseLine.Description := ExtraCharge.Description;
                PurchaseLine.VALIDATE(Quantity, 1);
                PurchaseLine.VALIDATE("Direct Unit Cost",

                  ROUND(
                    CurrExchRate.ExchangeAmtLCYToFCY(
                      PurchaseHeader."Posting Date", VendorBuffer."Currency Code",
                      VendorBuffer.Charge, PurchaseHeader."Currency Factor"),
                      Currency."Amount Rounding Precision"));

                PurchaseLine."Extra Charge Code ELA" := ExtraCharge.Code;
                IF VendorPurchaseInvoice."No." <> '' THEN
                    PurchaseLine."Purch. Ord for Ext Charge ELA" := VendorPurchaseInvoice."No.";
                PurchaseLine.INSERT(TRUE);
            UNTIL VendorBuffer.NEXT = 0;
            VendorBuffer.SETRANGE("Vendor No.");
            VendorBuffer.SETRANGE("Currency Code");
        UNTIL VendorBuffer.NEXT = 0;

        VendorBuffer.DELETEALL;
        VendorBuffer.RESET;


    end;


    procedure CopyFromPurchHeader(ToPurchHeader: Record "Purchase Header"; FromPurchHeader: Record "Purchase Header"; RecalculateLines: Boolean)
    var
        FromDocExtraCharge: Record "EN Document Extra Charge";
        ToDocExtraCharge: Record "EN Document Extra Charge";
    begin
        ToDocExtraCharge.SetRange("Table ID", DATABASE::"Purchase Header");
        ToDocExtraCharge.SetRange("Document Type", ToPurchHeader."Document Type");
        ToDocExtraCharge.SetRange("Document No.", ToPurchHeader."No.");

        ToDocExtraCharge.DeleteAll;

        FromDocExtraCharge.SetRange("Table ID", DATABASE::"Purchase Header");
        FromDocExtraCharge.SetRange("Document Type", FromPurchHeader."Document Type");
        FromDocExtraCharge.SetRange("Document No.", FromPurchHeader."No.");

        if FromDocExtraCharge.Find('-') then
            repeat
                ToDocExtraCharge := FromDocExtraCharge;
                ToDocExtraCharge."Document Type" := ToPurchHeader."Document Type";
                ToDocExtraCharge."Document No." := ToPurchHeader."No.";
                ToDocExtraCharge.UpdateCurrencyFactor;
                if RecalculateLines then
                    ToDocExtraCharge.Charge := 0;
                ToDocExtraCharge.Validate(Charge);
                if ToDocExtraCharge."Vendor No." <> '' then
                    ToDocExtraCharge.Insert;
            until FromDocExtraCharge.Next = 0;
    end;


    procedure CopyFromPurchLine(ToPurchLine: Record "Purchase Line"; FromPurchLine: Record "Purchase Line")
    var
        FromDocExtraCharge: Record "EN Document Extra Charge";
        ToDocExtraCharge: Record "EN Document Extra Charge";
    begin
        ToDocExtraCharge.SetRange("Table ID", DATABASE::"Purchase Line");
        ToDocExtraCharge.SetRange("Document Type", ToPurchLine."Document Type");
        ToDocExtraCharge.SetRange("Document No.", ToPurchLine."Document No.");
        ToDocExtraCharge.SetRange("Line No.", ToPurchLine."Line No.");
        ToDocExtraCharge.DeleteAll;

        FromDocExtraCharge.SetRange("Table ID", DATABASE::"Purchase Line");
        FromDocExtraCharge.SetRange("Document Type", FromPurchLine."Document Type");
        FromDocExtraCharge.SetRange("Document No.", FromPurchLine."Document No.");
        FromDocExtraCharge.SetRange("Line No.", ToPurchLine."Line No.");
        if FromDocExtraCharge.Find('-') then
            repeat
                ToDocExtraCharge := FromDocExtraCharge;
                ToDocExtraCharge."Document Type" := ToPurchLine."Document Type";
                ToDocExtraCharge."Document No." := ToPurchLine."Document No.";
                ToDocExtraCharge."Line No." := ToPurchLine."Line No.";
                ToDocExtraCharge.UpdateCurrencyFactor;
                ToDocExtraCharge.Validate(Charge);
                ToDocExtraCharge.Insert;
            until FromDocExtraCharge.Next = 0;
    end;


    procedure CopyFromPostedPurchDocHeader(ToPurchHeader: Record "Purchase Header"; FromTableID: Integer; FromDocNo: Code[20]; RecalculateLines: Boolean)
    var
        FromPstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        ToDocExtraCharge: Record "EN Document Extra Charge";
    begin
        ToDocExtraCharge.SetRange("Table ID", DATABASE::"Purchase Header");
        ToDocExtraCharge.SetRange("Document Type", ToPurchHeader."Document Type");
        ToDocExtraCharge.SetRange("Document No.", ToPurchHeader."No.");
        ToDocExtraCharge.SetRange("Line No.", 0);
        ToDocExtraCharge.DeleteAll;

        FromPstdDocExtraCharge.SetRange("Table ID", FromTableID);
        FromPstdDocExtraCharge.SetRange("Document No.", FromDocNo);
        if FromPstdDocExtraCharge.Find('-') then
            repeat
                ToDocExtraCharge."Table ID" := DATABASE::"Purchase Header";
                ToDocExtraCharge."Document Type" := ToPurchHeader."Document Type";
                ToDocExtraCharge."Document No." := ToPurchHeader."No.";
                ToDocExtraCharge."Line No." := 0;
                ToDocExtraCharge."Extra Charge Code" := FromPstdDocExtraCharge."Extra Charge Code";
                if RecalculateLines then
                    ToDocExtraCharge.Charge := 0
                else
                    ToDocExtraCharge.Charge := FromPstdDocExtraCharge.Charge;
                ToDocExtraCharge."Vendor No." := FromPstdDocExtraCharge."Vendor No.";
                ToDocExtraCharge."Currency Code" := FromPstdDocExtraCharge."Currency Code";
                ToDocExtraCharge.UpdateCurrencyFactor;
                ToDocExtraCharge."Allocation Method" := FromPstdDocExtraCharge."Allocation Method";
                ToDocExtraCharge.Validate(Charge);
                if ToDocExtraCharge."Vendor No." <> '' then
                    ToDocExtraCharge.Insert;
            until FromPstdDocExtraCharge.Next = 0;
    end;


    procedure CopyFromPostedPurchDocLine(ToPurchLine: Record "Purchase Line"; FromTableID: Integer; FromDocNo: Code[20]; FromLineNo: Integer)
    var
        FromPstdDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        ToDocExtraCharge: Record "EN Document Extra Charge";
    begin
        ToDocExtraCharge.SetRange("Table ID", DATABASE::"Purchase Line");
        ToDocExtraCharge.SetRange("Document Type", ToPurchLine."Document Type");
        ToDocExtraCharge.SetRange("Document No.", ToPurchLine."Document No.");
        ToDocExtraCharge.SetRange("Line No.", ToPurchLine."Line No.");
        ToDocExtraCharge.DeleteAll;

        FromPstdDocExtraCharge.SetRange("Table ID", FromTableID);
        FromPstdDocExtraCharge.SetRange("Document No.", FromDocNo);
        FromPstdDocExtraCharge.SetRange("Line No.", FromLineNo);
        if FromPstdDocExtraCharge.Find('-') then
            repeat
                ToDocExtraCharge."Table ID" := DATABASE::"Purchase Line";
                ToDocExtraCharge."Document Type" := ToPurchLine."Document Type";
                ToDocExtraCharge."Document No." := ToPurchLine."No.";
                ToDocExtraCharge."Line No." := ToPurchLine."Line No.";
                ToDocExtraCharge."Extra Charge Code" := FromPstdDocExtraCharge."Extra Charge Code";
                ToDocExtraCharge."Currency Code" := FromPstdDocExtraCharge."Currency Code";
                ToDocExtraCharge.UpdateCurrencyFactor;
                ToDocExtraCharge.Validate(Charge, FromPstdDocExtraCharge.Charge);
                ToDocExtraCharge.Insert;
            until FromPstdDocExtraCharge.Next = 0;
    end;


    procedure CalcChargeToPost(var ECToPost: Record "EN Extra Charge Posting Buffer" temporary; EntryNo: Integer; Expected: Boolean; var PostToGL: Boolean)
    var
        EntryExtraCharge: Record "EN Value Entry Extra Charge";
    begin

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

                ECToPost.Modify;
            until EntryExtraCharge.Next = 0;
    end;


    procedure ChargeToPost(var CostToPost: Decimal; AdjdCost: Decimal; var PostedCost: Decimal; var PostToGL: Boolean)
    begin

        CostToPost := AdjdCost - PostedCost;

        if CostToPost <> 0 then begin
            PostedCost := AdjdCost;
            PostToGL := true;
        end;
    end;


    procedure UpdatePostedCharge(EntryNo: Integer; Expected: Boolean)
    var
        EntryExtraCharge: Record "EN Value Entry Extra Charge";
    begin

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


    procedure ClearDropShipPostingBuffer()
    begin
        DropShipPostingBuffer.Reset;
        DropShipPostingBuffer.DeleteAll;
    end;


    procedure StartDropShipPosting(PurchHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    var
        Currency: Record Currency;
    begin

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

        ECPostingBuffer.Reset;
        if ECPostingBuffer.Find('-') then
            repeat
                DropShipPostingBuffer := ECPostingBuffer;
                DropShipPostingBuffer."Sales Line No." := SalesLine."Line No.";
                DropShipPostingBuffer.Insert;
            until ECPostingBuffer.Next = 0;
    end;


    procedure DropShipMoveToDocumentLine(RcptNo: Code[20]; RcptLineNo: Integer; SalesLineNo: Integer)
    begin
        DropShipPostingBuffer.Reset;
        DropShipPostingBuffer.SetRange("Sales Line No.", SalesLineNo);
        if DropShipPostingBuffer.Find('-') then
            repeat
                ECPostingBuffer := DropShipPostingBuffer;
                ECPostingBuffer."Sales Line No." := 0;
                ECPostingBuffer.Insert;
            until DropShipPostingBuffer.Next = 0;

        MoveToDocumentLine(DATABASE::"Purch. Rcpt. Line", RcptNo, RcptLineNo);
    end;


    procedure DropShipUpdateVendorBuffer(PurchHeader: Record "Purchase Header")
    begin

        PurchHeader."Last Receiving No." := PurchHeader."Receiving No.";
        UpdatePurchaseVendorBuffer(PurchHeader);
    end;


    procedure CopyFromPstdReceiptToPurchLine(PurchRcptLine: Record "Purch. Rcpt. Line"; PurchLine: Record "Purchase Line")
    var
        PostedDocExtraCharge: Record "EN Posted Doc. Extra Charges";
        DocExtraCharge: Record "EN Document Extra Charge";
    begin

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


    procedure UpdateExistingECInvoices(PONum: Code[20])
    var
        DocExtraCharge: Record "EN Document Extra Charge";
        InvHdr: Record "Purchase Header";
        InvLine: Record "Purchase Line";
    begin

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


    procedure UpdateExtraChargeSummary(OrderNo: Code[20]; EntryExtraCharge: Record "EN Value Entry Extra Charge"; VEPostingDate: Date)
    var
        ExtraChargeSummary: Record "EN Extra Charge Summary";
        DocExtraCharge: Record "EN Document Extra Charge";
    begin

        if not ExtraChargeSummary.Get(OrderNo, EntryExtraCharge."Extra Charge Code") then begin
            ExtraChargeSummary.Init;
            ExtraChargeSummary."Purchase Order No." := OrderNo;
            ExtraChargeSummary."Extra Charge Code" := EntryExtraCharge."Extra Charge Code";
            ExtraChargeSummary.Open := true;
            ExtraChargeSummary."Posting Date" := VEPostingDate;
            DocExtraCharge.Reset;
            IF DocExtraCharge.Get(38, 1, OrderNo, 0, EntryExtraCharge."Extra Charge Code") THEN;
            ExtraChargeSummary."Vendor No." := DocExtraCharge."Vendor No.";
            ExtraChargeSummary.Insert;
        end;
        ExtraChargeSummary."Charge Amount (Expected)" += EntryExtraCharge."Expected Charge";
        ExtraChargeSummary."Charge Amount (Actual)" += EntryExtraCharge.Charge;
        ExtraChargeSummary."Charge Amount" := ExtraChargeSummary."Charge Amount (Expected)" + ExtraChargeSummary."Charge Amount (Actual)";
        ExtraChargeSummary.Modify;
        Clear(VEPostingDate);
        DocExtraCharge.Reset;
    end;


}

