page 51013 "Purchase Worksheet Matrix"
{
    AutoSplitKey = true;
    ApplicationArea = all;
    UsageCategory = Lists;
    PageType = ListPart;
    SourceTable = "Purchase Worksheet Header";

    layout
    {
        area(content)
        {
            repeater(Control50001)
            {
                ShowCaption = false;
                field("Vendor No."; "Vendor No.")
                {
                }
                field(VendName; VendorName)
                {
                    Caption = 'Vendor Name';
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                }
                field("Freight Cost"; "Freight Cost")
                {
                }
                field("Customer PO"; "Customer PO")
                {
                }
                field("Expected Pickup Date"; "Expected Pickup Date")
                {
                }
                field("Expected Receipt Date"; "Expected Receipt Date")
                {
                }
                field(OrderTtl; OrderTotal)
                {
                    Caption = 'Order Total';
                }
                field(Field1; MATRIX_CellData[1])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[1];
                    DecimalPlaces = 0 : 5;
                    Visible = Field1Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(1);
                    end;
                }
                field(Field2; MATRIX_CellData[2])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[2];
                    DecimalPlaces = 0 : 5;
                    Visible = Field2Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(2);
                    end;
                }
                field(Field3; MATRIX_CellData[3])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[3];
                    DecimalPlaces = 0 : 5;
                    Visible = Field3Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(3);
                    end;
                }
                field(Field4; MATRIX_CellData[4])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[4];
                    DecimalPlaces = 0 : 5;
                    Visible = Field4Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(4);
                    end;
                }
                field(Field5; MATRIX_CellData[5])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[5];
                    DecimalPlaces = 0 : 5;
                    Visible = Field5Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(5);
                    end;
                }
                field(Field6; MATRIX_CellData[6])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[6];
                    DecimalPlaces = 0 : 5;
                    Visible = Field6Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(6);
                    end;
                }
                field(Field7; MATRIX_CellData[7])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[7];
                    DecimalPlaces = 0 : 5;
                    Visible = Field7Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(7);
                    end;
                }
                field(Field8; MATRIX_CellData[8])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[8];
                    DecimalPlaces = 0 : 5;
                    Visible = Field8Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(8);
                    end;
                }
                field(Field9; MATRIX_CellData[9])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[9];
                    DecimalPlaces = 0 : 5;
                    Visible = Field9Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(9);
                    end;
                }
                field(Field10; MATRIX_CellData[10])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[10];
                    DecimalPlaces = 0 : 5;
                    Visible = Field10Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(10);
                    end;
                }
                field(Field11; MATRIX_CellData[11])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[11];
                    DecimalPlaces = 0 : 5;
                    Visible = Field11Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(11);
                    end;
                }
                field(Field12; MATRIX_CellData[12])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[12];
                    DecimalPlaces = 0 : 5;
                    Visible = Field12Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(12);
                    end;
                }
                field(Field13; MATRIX_CellData[13])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[13];
                    DecimalPlaces = 0 : 5;
                    Visible = Field13Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(13);
                    end;
                }
                field(Field14; MATRIX_CellData[14])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[14];
                    DecimalPlaces = 0 : 5;
                    Visible = Field14Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(14);
                    end;
                }
                field(Field15; MATRIX_CellData[15])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[15];
                    DecimalPlaces = 0 : 5;
                    Visible = Field15Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(15);
                    end;
                }
                field(Field16; MATRIX_CellData[16])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[16];
                    DecimalPlaces = 0 : 5;
                    Visible = Field16Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(16);
                    end;
                }
                field(Field17; MATRIX_CellData[17])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[17];
                    DecimalPlaces = 0 : 5;
                    Visible = Field17Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(17);
                    end;
                }
                field(Field18; MATRIX_CellData[18])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[18];
                    DecimalPlaces = 0 : 5;
                    Visible = Field18Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(18);
                    end;
                }
                field(Field19; MATRIX_CellData[19])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[19];
                    DecimalPlaces = 0 : 5;
                    Visible = Field19Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(19);
                    end;
                }
                field(Field20; MATRIX_CellData[20])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[20];
                    DecimalPlaces = 0 : 5;
                    Visible = Field20Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(20);
                    end;
                }
                field(Field21; MATRIX_CellData[21])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[21];
                    DecimalPlaces = 0 : 5;
                    Visible = Field21Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(21);
                    end;
                }
                field(Field22; MATRIX_CellData[22])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[22];
                    DecimalPlaces = 0 : 5;
                    Visible = Field22Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(22);
                    end;
                }
                field(Field23; MATRIX_CellData[23])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[23];
                    DecimalPlaces = 0 : 5;
                    Visible = Field23Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(23);
                    end;
                }
                field(Field24; MATRIX_CellData[24])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[24];
                    DecimalPlaces = 0 : 5;
                    Visible = Field24Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(24);
                    end;
                }
                field(Field25; MATRIX_CellData[25])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[25];
                    DecimalPlaces = 0 : 5;
                    Visible = Field25Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(25);
                    end;
                }
                field(Field26; MATRIX_CellData[26])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[26];
                    DecimalPlaces = 0 : 5;
                    Visible = Field26Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(26);
                    end;
                }
                field(Field27; MATRIX_CellData[27])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[27];
                    DecimalPlaces = 0 : 5;
                    Visible = Field27Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(27);
                    end;
                }
                field(Field28; MATRIX_CellData[28])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[28];
                    DecimalPlaces = 0 : 5;
                    Visible = Field28Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(28);
                    end;
                }
                field(Field29; MATRIX_CellData[29])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[29];
                    DecimalPlaces = 0 : 5;
                    Visible = Field29Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(29);
                    end;
                }
                field(Field30; MATRIX_CellData[30])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[30];
                    DecimalPlaces = 0 : 5;
                    Visible = Field30Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(30);
                    end;
                }
                field(Field31; MATRIX_CellData[31])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[31];
                    DecimalPlaces = 0 : 5;
                    Visible = Field31Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(31);
                    end;
                }
                field(Field32; MATRIX_CellData[32])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[32];
                    DecimalPlaces = 0 : 5;
                    Visible = Field32Visible;
                    Width = 5;

                    trigger OnValidate()
                    begin
                        MatrixOnValidate(32);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        OnAfterGetRecord2;

    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        OnAfterGetRecord2;
    end;

    trigger OnOpenPage()
    begin
        SetRange("Order Date", OrderDate);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        AdditionalFreight: Record "Additional Freight";
    begin
        AdditionalFreight.SetRange("Order No.", "Order No.");
        AdditionalFreight.SetRange("Order Date", "Order Date");
        IF AdditionalFreight.FindSet() then
            AdditionalFreight.DeleteAll();
    end;

    var
        OrderDate: Date;
        PWLine: Record "Purchase Worksheet Line";
        LocCode: Code[10];
        MatrixRecord: Record "Purchase Worksheet Items";
        MatrixRecords: array[32] of Record "Purchase Worksheet Items";
        MATRIX_ColumnOrdinal: Integer;
        MATRIX_NoOfMatrixColumns: Integer;
        MATRIX_CellData: array[32] of Decimal;
        MATRIX_ColumnCaption: array[32] of Text[1024];
        [InDataSet]
        Field1Visible: Boolean;
        [InDataSet]
        Field2Visible: Boolean;
        [InDataSet]
        Field3Visible: Boolean;
        [InDataSet]
        Field4Visible: Boolean;
        [InDataSet]
        Field5Visible: Boolean;
        [InDataSet]
        Field6Visible: Boolean;
        [InDataSet]
        Field7Visible: Boolean;
        [InDataSet]
        Field8Visible: Boolean;
        [InDataSet]
        Field9Visible: Boolean;
        [InDataSet]
        Field10Visible: Boolean;
        [InDataSet]
        Field11Visible: Boolean;
        [InDataSet]
        Field12Visible: Boolean;
        [InDataSet]
        Field13Visible: Boolean;
        [InDataSet]
        Field14Visible: Boolean;
        [InDataSet]
        Field15Visible: Boolean;
        [InDataSet]
        Field16Visible: Boolean;
        [InDataSet]
        Field17Visible: Boolean;
        [InDataSet]
        Field18Visible: Boolean;
        [InDataSet]
        Field19Visible: Boolean;
        [InDataSet]
        Field20Visible: Boolean;
        [InDataSet]
        Field21Visible: Boolean;
        [InDataSet]
        Field22Visible: Boolean;
        [InDataSet]
        Field23Visible: Boolean;
        [InDataSet]
        Field24Visible: Boolean;
        [InDataSet]
        Field25Visible: Boolean;
        [InDataSet]
        Field26Visible: Boolean;
        [InDataSet]
        Field27Visible: Boolean;
        [InDataSet]
        Field28Visible: Boolean;
        [InDataSet]
        Field29Visible: Boolean;
        [InDataSet]
        Field30Visible: Boolean;
        [InDataSet]
        Field31Visible: Boolean;
        [InDataSet]
        Field32Visible: Boolean;

    [Scope('Internal')]
    procedure VendorName(): Text[30]
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get("Vendor No.") then
            exit(Vendor.Name);
    end;

    procedure OrderTotal() OrdTot: Decimal
    var
        PWLine: Record "Purchase Worksheet Line";
        AdditionalFreight: Record "Additional Freight";
    begin
        AdditionalFreight.Reset();
        AdditionalFreight.SetRange("Order Date", "Order Date");
        AdditionalFreight.SetRange("Order No.", "Order No.");
        IF AdditionalFreight.FindSet() then begin
            Repeat
                OrdTot += AdditionalFreight."Freight Cost";
            Until AdditionalFreight.Next() = 0;
        end;
        PWLine.SetRange("Order Date", "Order Date");
        PWLine.SetRange("Order No.", "Order No.");
        if PWLine.Find('-') then
            repeat
                OrdTot += PWLine.Quantity * PWLine."Unit Price";
            until PWLine.Next = 0;
    end;

    [Scope('Internal')]
    procedure jfCalcUnitCost2(pcodVendorNo: Code[20]; pcodItemNo: Code[20]; pcodVariantCode: Code[20]; pdatOrderDate: Date): Decimal
    var
        lrecPHeaderTMP: Record "Purchase Header" temporary;
        lrecPLineTMP: Record "Purchase Line" temporary;
        PurchPriceCalcMgt: Codeunit "Purch. Price Calc. Mgt.";
    begin
        lrecPHeaderTMP."Document Type" := lrecPHeaderTMP."Document Type"::Order;
        lrecPHeaderTMP."No." := '999999';
        lrecPHeaderTMP."Buy-from Vendor No." := pcodVendorNo;
        lrecPHeaderTMP."Pay-to Vendor No." := pcodVendorNo;
        lrecPHeaderTMP."Location Code" := LocCode;
        lrecPHeaderTMP."Posting Date" := OrderDate;
        lrecPHeaderTMP."Order Date" := OrderDate;
        lrecPHeaderTMP."Expected Receipt Date" := OrderDate;
        lrecPHeaderTMP."Document Date" := OrderDate;


        lrecPLineTMP."Document Type" := lrecPLineTMP."Document Type"::Order;
        lrecPLineTMP."Document No." := lrecPHeaderTMP."No.";
        lrecPLineTMP."Line No." := 1;
        lrecPLineTMP.Type := lrecPLineTMP.Type::Item;
        lrecPLineTMP."No." := pcodItemNo;
        lrecPLineTMP."Variant Code" := pcodVariantCode;
        lrecPLineTMP."Pay-to Vendor No." := pcodVendorNo;
        lrecPLineTMP."Buy-from Vendor No." := pcodVendorNo;
        lrecPLineTMP."Country/Reg of Origin Code ELA" := lrecPLineTMP.jfGetPurchPriceUOM;
        lrecPLineTMP."Location Code" := LocCode;


        PurchPriceCalcMgt.FindPurchLinePrice(lrecPHeaderTMP, lrecPLineTMP, 0);
        exit(lrecPLineTMP."Direct Unit Cost");
    end;

    procedure Load(var MatrixColumns1: array[32] of Text[1024]; var MatrixRecords1: array[32] of Record "Purchase Worksheet Items"; pcodLocationCode: Code[10]; pdat: Date)
    var
        lint: Integer;
        lintMod2: Integer;
        lintDiv2: Integer;
    begin

        Clear(MATRIX_ColumnCaption);
        for lint := 1 to ArrayLen(MatrixRecords1) do begin
            lintMod2 := lint mod 2;
            lintDiv2 := lint div 2;
            MATRIX_ColumnCaption[lint] := MatrixColumns1[lintDiv2 + lintMod2];
            MATRIX_ColumnCaption[lint] := DelChr(MATRIX_ColumnCaption[lint], '=', '()');
            if (
              (MATRIX_ColumnCaption[lint] <> '')
            ) then begin
                if (
                  (lintMod2 = 1)
                ) then begin
                    MATRIX_ColumnCaption[lint] := MATRIX_ColumnCaption[lint] + ' - Qty';
                end else begin
                    MATRIX_ColumnCaption[lint] := MATRIX_ColumnCaption[lint] + ' - Price';
                end;
            end;
        end;

        Clear(MatrixRecords);
        for lint := 1 to ArrayLen(MatrixRecords1) do begin
            lintMod2 := lint mod 2;
            lintDiv2 := lint div 2;
            MatrixRecords[lint] := MatrixRecords1[lintDiv2 + lintMod2];
        end;

        LocCode := pcodLocationCode;

        OrderDate := pdat;
        SetRange("Order Date", OrderDate);
        SetVisible;
    end;

    local procedure MatrixOnValidate(ColumnID: Integer)
    var
        lintMod2: Integer;
    begin
        PWLine.Reset;
        PWLine.SetRange("Order Date", "Order Date");
        PWLine.SetRange("Order No.", "Order No.");
        PWLine.SetRange("Item No.", MatrixRecords[ColumnID]."Item No.");
        PWLine.SetRange("Variant Code", MatrixRecords[ColumnID]."Variant Code");
        if not PWLine.FindFirst then begin
            PWLine.Init;
            PWLine."Order Date" := "Order Date";
            PWLine."Order No." := "Order No.";
            PWLine."Item No." := MatrixRecords[ColumnID]."Item No.";
            PWLine."Variant Code" := MatrixRecords[ColumnID]."Variant Code";
            PWLine.Insert;
        end;
        lintMod2 := ColumnID mod 2;
        if (lintMod2 = 1) and (PWLine.Quantity = 0) and (MATRIX_CellData[ColumnID] <> 0) then begin
            PWLine."Unit Price" := jfCalcUnitCost2(
              Rec."Vendor No.",
              MatrixRecords[ColumnID]."Item No.",
              MatrixRecords[ColumnID]."Variant Code",
              "Order Date"
            );
            MATRIX_CellData[ColumnID + 1] := PWLine."Unit Price";
        end;
        if (lintMod2 = 1) then
            PWLine.Quantity := MATRIX_CellData[ColumnID]
        else
            PWLine."Unit Price" := MATRIX_CellData[ColumnID];
        if (PWLine.Quantity = 0) and (PWLine."Unit Price" = 0) then
            PWLine.Delete
        else
            PWLine.Modify;
    end;

    local procedure MATRIX_OnAfterGetRecord()
    var
        lintMod2: Integer;
    begin
        MATRIX_CellData[MATRIX_ColumnOrdinal] := 0;

        if (
          (PWLine.Get("Order Date", "Order No.",
                        MatrixRecords[MATRIX_ColumnOrdinal]."Item No.",
                        MatrixRecords[MATRIX_ColumnOrdinal]."Variant Code"))
        ) then begin
            lintMod2 := MATRIX_ColumnOrdinal mod 2;
            if (
              (lintMod2 = 1)
            ) then begin
                MATRIX_CellData[MATRIX_ColumnOrdinal] := PWLine.Quantity;
            end else begin
                MATRIX_CellData[MATRIX_ColumnOrdinal] := PWLine."Unit Price";
            end;
        end;
    end;

    local procedure MATRIX_OnFindRecord(Which: Text[1024]): Boolean
    begin
        exit(MatrixRecord.Find(Which));
    end;

    local procedure MATRIX_OnNextRecord(Steps: Integer): Integer
    begin
        exit(MatrixRecord.Next(Steps));
    end;

    [Scope('Internal')]
    procedure SetVisible()
    begin
        Field1Visible := MATRIX_ColumnCaption[1] <> '';
        Field2Visible := MATRIX_ColumnCaption[2] <> '';
        Field3Visible := MATRIX_ColumnCaption[3] <> '';
        Field4Visible := MATRIX_ColumnCaption[4] <> '';
        Field5Visible := MATRIX_ColumnCaption[5] <> '';
        Field6Visible := MATRIX_ColumnCaption[6] <> '';
        Field7Visible := MATRIX_ColumnCaption[7] <> '';
        Field8Visible := MATRIX_ColumnCaption[8] <> '';
        Field9Visible := MATRIX_ColumnCaption[9] <> '';
        Field10Visible := MATRIX_ColumnCaption[10] <> '';
        Field11Visible := MATRIX_ColumnCaption[11] <> '';
        Field12Visible := MATRIX_ColumnCaption[12] <> '';
        Field13Visible := MATRIX_ColumnCaption[13] <> '';
        Field14Visible := MATRIX_ColumnCaption[14] <> '';
        Field15Visible := MATRIX_ColumnCaption[15] <> '';
        Field16Visible := MATRIX_ColumnCaption[16] <> '';
        Field17Visible := MATRIX_ColumnCaption[17] <> '';
        Field18Visible := MATRIX_ColumnCaption[18] <> '';
        Field19Visible := MATRIX_ColumnCaption[19] <> '';
        Field20Visible := MATRIX_ColumnCaption[20] <> '';
        Field21Visible := MATRIX_ColumnCaption[21] <> '';
        Field22Visible := MATRIX_ColumnCaption[22] <> '';
        Field23Visible := MATRIX_ColumnCaption[23] <> '';
        Field24Visible := MATRIX_ColumnCaption[24] <> '';
        Field25Visible := MATRIX_ColumnCaption[25] <> '';
        Field26Visible := MATRIX_ColumnCaption[26] <> '';
        Field27Visible := MATRIX_ColumnCaption[27] <> '';
        Field28Visible := MATRIX_ColumnCaption[28] <> '';
        Field29Visible := MATRIX_ColumnCaption[29] <> '';
        Field30Visible := MATRIX_ColumnCaption[30] <> '';
        Field31Visible := MATRIX_ColumnCaption[31] <> '';
        Field32Visible := MATRIX_ColumnCaption[32] <> '';

        CurrPage.Update(false);
    end;

    [Scope('Internal')]
    procedure OnAfterGetRecord2()
    var
        MATRIX_CurrentColumnOrdinal: Integer;
        MATRIX_Steps: Integer;
    begin
        MATRIX_CurrentColumnOrdinal := 0;
        MATRIX_ColumnOrdinal := 0;
        if MATRIX_OnFindRecord('=><') then begin
            MATRIX_CurrentColumnOrdinal := 1;
            repeat

                MATRIX_ColumnOrdinal := MATRIX_CurrentColumnOrdinal;
                MATRIX_OnAfterGetRecord;
                MATRIX_CurrentColumnOrdinal += 1;
                MATRIX_ColumnOrdinal := MATRIX_CurrentColumnOrdinal;
                MATRIX_OnAfterGetRecord;

                MATRIX_Steps := MATRIX_OnNextRecord(1);
                MATRIX_CurrentColumnOrdinal := MATRIX_CurrentColumnOrdinal + MATRIX_Steps;
            until (MATRIX_CurrentColumnOrdinal - MATRIX_Steps = MATRIX_NoOfMatrixColumns) or (MATRIX_Steps = 0);
            if MATRIX_CurrentColumnOrdinal <> 1 then
                MATRIX_OnNextRecord(1 - MATRIX_CurrentColumnOrdinal);
        end;
    end;
}

