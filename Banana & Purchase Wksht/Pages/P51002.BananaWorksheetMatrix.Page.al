page 51002 "Banana Worksheet Matrix"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ApplicationArea = all;
    UsageCategory = Lists;
    PageType = ListPart;
    SourceTable = "Banana Worksheet Customers";

    layout
    {
        area(content)
        {
            repeater(Control50001)
            {
                ShowCaption = false;
                field("Customer No."; "Customer No.")
                {
                }
                field("Customer Name"; "Customer Name")
                {
                }
                field(PONumber; PONumber)
                {
                    Caption = 'PO Number';

                    trigger OnValidate()
                    var
                        lrecBananaWorksheetCustomerDateDetails: Record "Banana Wrksht. Cust. Date Dtl.";
                        lblnRecordExists: Boolean;
                    begin
                        lblnRecordExists := lrecBananaWorksheetCustomerDateDetails.Get("Customer No.",
                                                                                        "Ship-to Code",
                                                                                        "Location Code",
                                                                                        Date);

                        if (
                          (not lblnRecordExists)
                        ) then begin
                            lrecBananaWorksheetCustomerDateDetails.Init;
                            lrecBananaWorksheetCustomerDateDetails."Customer No." := "Customer No.";
                            lrecBananaWorksheetCustomerDateDetails."Ship-to Code" := "Ship-to Code";
                            lrecBananaWorksheetCustomerDateDetails."Location Code" := "Location Code";
                            lrecBananaWorksheetCustomerDateDetails.Date := Date;
                        end;

                        lrecBananaWorksheetCustomerDateDetails.Validate("PO Number", PONumber);

                        if (
                          (lblnRecordExists)
                        ) then begin
                            lrecBananaWorksheetCustomerDateDetails.Modify(true);
                        end
                        else begin
                            lrecBananaWorksheetCustomerDateDetails.Insert(true);
                        end;
                    end;
                }
                field("Requested Shipment Date"; "Requested Shipment Date")
                {
                }
                field("Order Template Location"; "Order Template Location")
                {
                }
                field("GetTotal(""Customer No."",Date,""Location Code"")"; GetTotal("Customer No.", Date, "Location Code"))
                {
                    Caption = 'Total';
                    Editable = false;
                }
                field(Field1; MATRIX_CellData[1])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[1];
                    DecimalPlaces = 0 : 5;
                    Visible = Field1Visible;

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
    var
        MATRIX_CurrentColumnOrdinal: Integer;
        MATRIX_Steps: Integer;
        lrecBananaWorksheetCustomerDateDetail: Record "Banana Wrksht. Cust. Date Dtl.";
    begin
        MATRIX_CurrentColumnOrdinal := 0;
        MATRIX_ColumnOrdinal := 0;
        if MATRIX_OnFindRecord('=><') then begin
            MATRIX_CurrentColumnOrdinal := 1;
            repeat
                MATRIX_ColumnOrdinal := MATRIX_CurrentColumnOrdinal;
                MATRIX_OnAfterGetRecord;
                MATRIX_Steps := MATRIX_OnNextRecord(1);
                MATRIX_CurrentColumnOrdinal := MATRIX_CurrentColumnOrdinal + MATRIX_Steps;
            until (MATRIX_CurrentColumnOrdinal - MATRIX_Steps = MATRIX_NoOfMatrixColumns) or (MATRIX_Steps = 0);
            if MATRIX_CurrentColumnOrdinal <> 1 then
                MATRIX_OnNextRecord(1 - MATRIX_CurrentColumnOrdinal);
        end;
        if (
                  not lrecBananaWorksheetCustomerDateDetail.Get("Customer No.", "Ship-to Code", "Location Code", Date)
                ) then begin
            ;
        end;

        PONumber := lrecBananaWorksheetCustomerDateDetail."PO Number";

    end;

    var
        BananaWS: Record "Banana Worksheet";
        Date: Date;
        PONumber: Code[20];
        gcodLocationCode: Code[20];
        MatrixRecord: Record "Banana Worksheet Column";
        MatrixRecords: array[32] of Record "Banana Worksheet Column";
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
    procedure GetTotal(CustNo: Code[20]; Date: Date; pcodLocationCode: Code[20]): Decimal
    begin
        BananaWS.Reset;
        BananaWS.SetCurrentKey("Customer No.", "Ship-to Code", "Item No.", "Variant Code", "Location Code", "Preference Code", Date);
        BananaWS.SetRange("Customer No.", CustNo);
        BananaWS.SetRange("Ship-to Code", "Ship-to Code");
        BananaWS.SetRange("Location Code", pcodLocationCode);
        BananaWS.SetRange(Date, Date);
        BananaWS.CalcSums(Quantity);
        exit(BananaWS.Quantity);
    end;

    [Scope('Internal')]
    procedure GetPO(CustNo: Code[20]; Date: Date; pcodLocationCode: Code[20]): Code[20]
    begin

        BananaWS.Reset;
        BananaWS.SetRange("Customer No.", CustNo);
        BananaWS.SetRange("Item No.", '');
        BananaWS.SetRange("Variant Code", '');
        BananaWS.SetRange("Location Code", pcodLocationCode);
        BananaWS.SetRange("Preference Code", '');
        BananaWS.SetRange(Date, Date);
        if BananaWS.Find('-') then
            exit(BananaWS."PO Number")
        else
            exit('');
    end;

    [Scope('Internal')]
    procedure CustOrderExpected(ShipDate: Date) ret: Boolean
    begin
    end;

    [Scope('Internal')]
    procedure jfCopyRec(var precBananaWorksheetCustomer: Record "Banana Worksheet Customers")
    begin

        precBananaWorksheetCustomer.Copy(Rec);
    end;

    [Scope('Internal')]
    procedure Load(var MatrixColumns1: array[32] of Text[1024]; var MatrixRecords1: array[32] of Record "Banana Worksheet Column"; pcodLocationCode: Code[10]; pdat: Date; ptxtMatrixView: Text)
    var
        lint: Integer;
    begin
        CopyArray(MATRIX_ColumnCaption, MatrixColumns1, 1);
        Clear(MatrixRecords);
        for lint := 1 to ArrayLen(MatrixRecords1) do begin
            MatrixRecords[lint] := MatrixRecords1[lint];
        end;


        MatrixRecord.SetView(ptxtMatrixView);
        SetRange("Location Code", pcodLocationCode);

        Date := pdat;

        SetVisible;
    end;

    local procedure MatrixOnDrillDown(ColumnID: Integer)
    begin
    end;

    local procedure MatrixOnValidate(ColumnID: Integer)
    begin
        SetRange("Date Filter", Date);
        SetRange("Item Filter", MatrixRecords[ColumnID]."Item No.");
        SetRange("Preference Filter", MatrixRecords[ColumnID]."Banana Preference Code");
        SetRange("Variant Filter", MatrixRecords[ColumnID]."Variant Code");
        SetRange("Ship-to Code Filter", "Ship-to Code");
        CalcFields("Banana Quantity");

        Validate("Banana Quantity", MATRIX_CellData[ColumnID]);
    end;

    local procedure MATRIX_OnAfterGetRecord()
    begin
        SetRange("Date Filter", Date);
        SetRange("Item Filter", MatrixRecords[MATRIX_ColumnOrdinal]."Item No.");
        SetRange("Preference Filter", MatrixRecords[MATRIX_ColumnOrdinal]."Banana Preference Code");
        SetRange("Variant Filter", MatrixRecords[MATRIX_ColumnOrdinal]."Variant Code");
        SetRange("Ship-to Code Filter", "Ship-to Code");
        CalcFields("Banana Quantity");

        MATRIX_CellData[MATRIX_ColumnOrdinal] := "Banana Quantity";
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
}

