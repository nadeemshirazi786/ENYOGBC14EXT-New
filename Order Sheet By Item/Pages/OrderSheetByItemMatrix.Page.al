page 14228813 "Order Sheet By Item Matrix"
{
    // Copyright Axentia Solutions Corp.  1999-2010.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF09161AC
    //   20100914
    //     new "subform" for FOR23019135 matrix transformation
    // 
    // JF11506SHR
    //   20110203 - Added new field:
    //              46 'Qty. Not Ordered'

    Caption = 'Order Sheet By Item Matrix';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Order Sheet Items";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {

                }
                field("Item Description"; "Item Description")
                {

                }
                field("Item Description 2"; "Item Description 2")
                {
                    ShowCaption = false;
                    Visible = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ShowCaption = false;
                    Visible = false;
                }
                field("On Special"; "On Special")
                {
                    ShowCaption = false;
                    Visible = false;
                }
                field("Backordered Item"; "Backordered Item")
                {
                    ShowCaption = false;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {

                }
                field("Total Qty. Ordered"; "Total Qty. Ordered")
                {

                }
                field("Qty. on Hand (Base)"; "Qty. on Hand (Base)")
                {
                    ShowCaption = false;
                    Visible = false;
                }
                field("Qty. on Sales Order (Base)"; "Qty. on Sales Order (Base)")
                {
                    ShowCaption = false;
                    Visible = false;
                }
                field("Scheduled Receipt (Qty.)"; "Scheduled Receipt (Qty.)")
                {
                    ShowCaption = false;
                    Visible = false;
                }
                field("Qty. Not Ordered"; "Qty. Not Ordered")
                {

                    Style = Unfavorable;
                    StyleExpr = TRUE;
                }
                field(Field1; MATRIX_CellData[1])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[1];
                    DecimalPlaces = 0 : 5;
                    Visible = Field1Visible;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(1);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(2);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(3);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(4);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(5);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(6);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(7);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(8);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(9);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(10);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(11);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(12);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(13);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(14);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(15);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(16);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(17);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(18);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(19);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(20);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(21);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(22);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(23);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(24);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(25);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(26);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(27);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(28);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(29);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(30);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(31);
                    end;

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

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(32);
                    end;

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
    begin
        MATRIX_CurrentColumnOrdinal := 0;
        MATRIX_ColumnOrdinal := 0;
        IF MATRIX_OnFindRecord('=><') THEN BEGIN
            MATRIX_CurrentColumnOrdinal := 1;
            REPEAT
                MATRIX_ColumnOrdinal := MATRIX_CurrentColumnOrdinal;
                MATRIX_OnAfterGetRecord;
                MATRIX_Steps := MATRIX_OnNextRecord(1);
                MATRIX_CurrentColumnOrdinal := MATRIX_CurrentColumnOrdinal + MATRIX_Steps;
            UNTIL (MATRIX_CurrentColumnOrdinal - MATRIX_Steps = MATRIX_NoOfMatrixColumns) OR (MATRIX_Steps = 0);
            IF MATRIX_CurrentColumnOrdinal <> 1 THEN
                MATRIX_OnNextRecord(1 - MATRIX_CurrentColumnOrdinal);
        END;

        SETFILTER("Date Filter", gtxtDateFilter);
    end;

    trigger OnInit()
    begin
        Field32Visible := TRUE;
        Field31Visible := TRUE;
        Field30Visible := TRUE;
        Field29Visible := TRUE;
        Field28Visible := TRUE;
        Field27Visible := TRUE;
        Field26Visible := TRUE;
        Field25Visible := TRUE;
        Field24Visible := TRUE;
        Field23Visible := TRUE;
        Field22Visible := TRUE;
        Field21Visible := TRUE;
        Field20Visible := TRUE;
        Field19Visible := TRUE;
        Field18Visible := TRUE;
        Field17Visible := TRUE;
        Field16Visible := TRUE;
        Field15Visible := TRUE;
        Field14Visible := TRUE;
        Field13Visible := TRUE;
        Field12Visible := TRUE;
        Field11Visible := TRUE;
        Field10Visible := TRUE;
        Field9Visible := TRUE;
        Field8Visible := TRUE;
        Field7Visible := TRUE;
        Field6Visible := TRUE;
        Field5Visible := TRUE;
        Field4Visible := TRUE;
        Field3Visible := TRUE;
        Field2Visible := TRUE;
        Field1Visible := TRUE;
    end;

    trigger OnOpenPage()
    var
        i: Integer;
    begin
        MATRIX_NoOfMatrixColumns := ARRAYLEN(MATRIX_CellData);
    end;

    var
        Text000: Label '%1 must be Limited.';
        DimComb: Record "Dimension Combination";
        MatrixRecord: Record "Order Sheet Customers";
        MatrixRecords: array[32] of Record "Order Sheet Customers";
        DimensionValueCombinations: Page "MyDim Value Combinations";
        CombRestriction: Option " ",Limited,Blocked;
        ShowColumnName: Boolean;
        MATRIX_ColumnOrdinal: Integer;
        MATRIX_NoOfMatrixColumns: Integer;
        MATRIX_CellData: array[32] of Decimal;
        MATRIX_ColumnCaption: array[32] of Text[1024];
        Text001: Label 'No limitations,Limited,Blocked';
        gtxtDateFilter: Text[1024];
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
    procedure Load(var MatrixColumns1: array[32] of Text[1024]; var MatrixRecords1: array[32] of Record "Order Sheet Customers")
    var
        lint: Integer;
    begin
        CLEAR(MATRIX_ColumnCaption);
        COPYARRAY(MATRIX_ColumnCaption, MatrixColumns1, 1);
        CLEAR(MatrixRecords);
        FOR lint := 1 TO ARRAYLEN(MatrixRecords1) DO BEGIN
            MatrixRecords[lint] := MatrixRecords1[lint];
        END;

        SetVisible;
    end;

    local procedure MatrixOnDrillDown(ColumnID: Integer)
    var
        lrecOrderSheetDetails: Record "Order Sheet Details";
    begin

        lrecOrderSheetDetails.SETRANGE("Order Sheet Batch Name", "Order Sheet Batch Name");
        lrecOrderSheetDetails.SETRANGE("Sell-to Customer No.", MatrixRecords[ColumnID]."Sell-to Customer No.");
        lrecOrderSheetDetails.SETRANGE("Ship-to Code", MatrixRecords[ColumnID]."Ship-to Code");
        lrecOrderSheetDetails.SETRANGE("Requested Ship Date", GETRANGEMIN("Date Filter"), GETRANGEMAX("Date Filter"));
        lrecOrderSheetDetails.SETRANGE("Item No.", "Item No.");
        lrecOrderSheetDetails.SETRANGE("Variant Code", "Variant Code");
        lrecOrderSheetDetails.SETRANGE("Unit of Measure Code", "Unit of Measure Code");
        lrecOrderSheetDetails.SETRANGE("External Doc. No.", "External Document No. Filter");

        PAGE.RUN(0, lrecOrderSheetDetails);
    end;

    [Scope('Internal')]
    procedure MatrixOnValidate(ColumnID: Integer)
    var
        lrecOrderSheetItem: Record "Order Sheet Items";
    begin
        SETRANGE("Customer No. Filter", MatrixRecords[ColumnID]."Sell-to Customer No.");
        SETRANGE("Ship-to Code Filter", MatrixRecords[ColumnID]."Ship-to Code");

        SETRANGE("Date Filter", GETRANGEMIN("Date Filter"), GETRANGEMAX("Date Filter"));

        CALCFIELDS("Qty. Ordered");

        VALIDATE("Qty. Ordered", MATRIX_CellData[ColumnID]);
    end;

    local procedure MATRIX_OnAfterGetRecord()
    begin
        SETRANGE("Customer No. Filter", MatrixRecords[MATRIX_ColumnOrdinal]."Sell-to Customer No.");
        SETRANGE("Ship-to Code Filter", MatrixRecords[MATRIX_ColumnOrdinal]."Ship-to Code");

        CALCFIELDS("Qty. Ordered");

        MATRIX_CellData[MATRIX_ColumnOrdinal] := "Qty. Ordered";
    end;

    local procedure MATRIX_OnFindRecord(Which: Text[1024]): Boolean
    begin
        EXIT(MatrixRecord.FIND(Which));
    end;

    local procedure MATRIX_OnNextRecord(Steps: Integer): Integer
    begin
        EXIT(MatrixRecord.NEXT(Steps));
    end;

    [Scope('Internal')]
    procedure SetVisible()
    begin
        CurrPage.UPDATE(FALSE);

        Field1Visible := (MATRIX_ColumnCaption[1] <> '');
        Field2Visible := (MATRIX_ColumnCaption[2] <> '');
        Field3Visible := (MATRIX_ColumnCaption[3] <> '');
        Field4Visible := (MATRIX_ColumnCaption[4] <> '');
        Field5Visible := (MATRIX_ColumnCaption[5] <> '');
        Field6Visible := (MATRIX_ColumnCaption[6] <> '');
        Field7Visible := (MATRIX_ColumnCaption[7] <> '');
        Field8Visible := (MATRIX_ColumnCaption[8] <> '');
        Field9Visible := (MATRIX_ColumnCaption[9] <> '');
        Field10Visible := (MATRIX_ColumnCaption[10] <> '');
        Field11Visible := (MATRIX_ColumnCaption[11] <> '');
        Field12Visible := (MATRIX_ColumnCaption[12] <> '');
        Field13Visible := (MATRIX_ColumnCaption[13] <> '');
        Field14Visible := (MATRIX_ColumnCaption[14] <> '');
        Field15Visible := (MATRIX_ColumnCaption[15] <> '');
        Field16Visible := (MATRIX_ColumnCaption[16] <> '');
        Field17Visible := (MATRIX_ColumnCaption[17] <> '');
        Field18Visible := (MATRIX_ColumnCaption[18] <> '');
        Field19Visible := (MATRIX_ColumnCaption[19] <> '');
        Field20Visible := (MATRIX_ColumnCaption[20] <> '');
        Field21Visible := (MATRIX_ColumnCaption[21] <> '');
        Field22Visible := (MATRIX_ColumnCaption[22] <> '');
        Field23Visible := (MATRIX_ColumnCaption[23] <> '');
        Field24Visible := (MATRIX_ColumnCaption[24] <> '');
        Field25Visible := (MATRIX_ColumnCaption[25] <> '');
        Field26Visible := (MATRIX_ColumnCaption[26] <> '');
        Field27Visible := (MATRIX_ColumnCaption[27] <> '');
        Field28Visible := (MATRIX_ColumnCaption[28] <> '');
        Field29Visible := (MATRIX_ColumnCaption[29] <> '');
        Field30Visible := (MATRIX_ColumnCaption[30] <> '');
        Field31Visible := (MATRIX_ColumnCaption[31] <> '');
        Field32Visible := (MATRIX_ColumnCaption[32] <> '');
    end;

    [Scope('Internal')]
    procedure SetDateFilter(ptxt: Text[1024])
    begin
        gtxtDateFilter := ptxt;
    end;
}

