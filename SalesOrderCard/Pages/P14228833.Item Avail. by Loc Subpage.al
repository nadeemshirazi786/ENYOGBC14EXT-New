page 14228833 "Item Avail. by Loc Subpage ELA"
{
    PageType = ListPart;
    Editable = false;
    Caption = 'Item by Location';
    LinksAllowed = false;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Item;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(group)
            {
                //FreezeColumn = 'Total';
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Enabled = false;
                }
                field(Quantites; Description)
                {
                    Caption = 'Quantities';
                    ApplicationArea = All;
                }
                field(Total; "Reorder Point")
                {
                    Caption = 'Total';
                    BlankNumbers = BlankZero;
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(0);
                    end;
                }
                field(Field1; MATRIX_CellData[1])
                {
                    ApplicationArea = All;
                    Visible = Field1Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[1];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(1);
                    end;
                }
                field(Field2; MATRIX_CellData[2])
                {
                    ApplicationArea = All;
                    Visible = Field2Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[2];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(2);
                    end;
                }
                field(Field3; MATRIX_CellData[3])
                {
                    ApplicationArea = All;
                    Visible = Field3Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[3];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(3);
                    end;
                }
                field(Field4; MATRIX_CellData[4])
                {
                    ApplicationArea = All;
                    Visible = Field4Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[4];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(4);
                    end;
                }
                field(Field5; MATRIX_CellData[5])
                {
                    ApplicationArea = All;
                    Visible = Field5Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[5];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(5);
                    end;
                }
                field(Field6; MATRIX_CellData[6])
                {
                    ApplicationArea = All;
                    Visible = Field6Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[6];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(6);
                    end;
                }
                field(Field7; MATRIX_CellData[7])
                {
                    ApplicationArea = All;
                    Visible = Field7Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[7];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(7);
                    end;
                }
                field(Field8; MATRIX_CellData[8])
                {
                    ApplicationArea = All;
                    Visible = Field8Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[8];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(8);
                    end;
                }
                field(Field9; MATRIX_CellData[9])
                {
                    ApplicationArea = All;
                    Visible = Field9Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[9];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(9);
                    end;
                }
                field(Field10; MATRIX_CellData[10])
                {
                    ApplicationArea = All;
                    Visible = Field10Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[10];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(10);
                    end;
                }
                field(Field11; MATRIX_CellData[11])
                {
                    ApplicationArea = All;
                    Visible = Field11Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[11];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(11);
                    end;
                }
                field(Field12; MATRIX_CellData[12])
                {
                    ApplicationArea = All;
                    Visible = Field12Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[12];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(12);
                    end;
                }
                field(Field13; MATRIX_CellData[13])
                {
                    ApplicationArea = All;
                    Visible = Field13Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[13];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(13);
                    end;
                }
                field(Field14; MATRIX_CellData[14])
                {
                    ApplicationArea = All;
                    Visible = Field14Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[14];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(14);
                    end;
                }
                field(Field15; MATRIX_CellData[15])
                {
                    ApplicationArea = All;
                    Visible = Field15Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[15];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(15);
                    end;
                }
                field(Field16; MATRIX_CellData[16])
                {
                    ApplicationArea = All;
                    Visible = Field16Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[16];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(16);
                    end;
                }
                field(Field17; MATRIX_CellData[17])
                {
                    ApplicationArea = All;
                    Visible = Field17Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[17];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(17);
                    end;
                }
                field(Field18; MATRIX_CellData[18])
                {
                    ApplicationArea = All;
                    Visible = Field18Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[18];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(18);
                    end;
                }
                field(Field19; MATRIX_CellData[19])
                {
                    ApplicationArea = All;
                    Visible = Field19Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[19];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(19);
                    end;
                }
                field(Field20; MATRIX_CellData[20])
                {
                    ApplicationArea = All;
                    Visible = Field20Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[20];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(20);
                    end;
                }
                field(Field21; MATRIX_CellData[21])
                {
                    ApplicationArea = All;
                    Visible = Field21Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[21];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(21);
                    end;
                }
                field(Field22; MATRIX_CellData[22])
                {
                    ApplicationArea = All;
                    Visible = Field22Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[22];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(22);
                    end;
                }
                field(Field23; MATRIX_CellData[23])
                {
                    ApplicationArea = All;
                    Visible = Field23Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[23];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(23);
                    end;
                }
                field(Field24; MATRIX_CellData[24])
                {
                    ApplicationArea = All;
                    Visible = Field24Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[24];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(24);
                    end;
                }
                field(Field25; MATRIX_CellData[25])
                {
                    ApplicationArea = All;
                    Visible = Field25Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[25];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(25);
                    end;
                }
                field(Field26; MATRIX_CellData[26])
                {
                    ApplicationArea = All;
                    Visible = Field26Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[26];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(26);
                    end;
                }
                field(Field27; MATRIX_CellData[27])
                {
                    ApplicationArea = All;
                    Visible = Field27Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[27];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(27);
                    end;
                }
                field(Field28; MATRIX_CellData[28])
                {
                    ApplicationArea = All;
                    Visible = Field28Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[28];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(28);
                    end;
                }
                field(Field29; MATRIX_CellData[29])
                {
                    ApplicationArea = All;
                    Visible = Field29Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[29];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(29);
                    end;
                }
                field(Field30; MATRIX_CellData[30])
                {
                    ApplicationArea = All;
                    Visible = Field30Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[30];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(30);
                    end;
                }
                field(Field31; MATRIX_CellData[31])
                {
                    ApplicationArea = All;
                    Visible = Field31Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[31];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(31);
                    end;
                }
                field(Field32; MATRIX_CellData[32])
                {
                    ApplicationArea = All;
                    Visible = Field32Visible;
                    BlankNumbers = BlankZero;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[32];
                    DecimalPlaces = 0 : 5;
                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(32);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        ItemLedgerEntry: Record 32;
        MatrixRecords: ARRAY[32] OF Record 14;
        MatrixRecord: Record 14;
        ItemAvailFormsMgt: Codeunit 353;
        MATRIX_NoOfMatrixColumns: Integer;
        MATRIX_CellData: ARRAY[32] OF Decimal;
        MATRIX_ColumnCaption: ARRAY[32] OF Text[1024];
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
        gItem: Record Item;
        MatrixRecordRef: RecordRef;
        MATRIX_SetWanted: Option "Initial","Previous","Same","Next";
        ShowColumnName: Boolean;
        ShowInTransit: Boolean;
        MATRIX_CaptionSet: ARRAY[32] OF Text[1024];
        MATRIX_CaptionRange: Text[100];
        MATRIX_PKFirstRecInCurrSet: Text[100];
        MATRIX_CurrSetLength: Integer;
        gQtyArray: ARRAY[4] OF Decimal;
        gStartDate: Date;
        gEndDate: Date;
        WeekSalesBufferTMP: Record "Buffer ELA" temporary;

    trigger OnInit()
    begin
        Field1Visible := true;
        Field32Visible := true;
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
    end;

    trigger OnOpenPage()
    begin
        "No." := '001';
        Description := 'Qty. on Hand';
        INSERT;
        "No." := '002';
        Description := 'Qty. on PO';
        INSERT;
        "No." := '003';
        Description := 'Qty. on SO';
        INSERT;
        "No." := '004';
        Description := 'Qty. in Transit';
        INSERT;
        "No." := '005';
        Description := 'Available';
        INSERT;
        "No." := '006';
        Description := 'Avg Week Sale';
        INSERT;

        FINDFIRST;
        SetColumns(MATRIX_SetWanted::Initial);
        MATRIX_NoOfMatrixColumns := ARRAYLEN(MATRIX_CellData);
        Load(MATRIX_CaptionSet, MatrixRecords, MatrixRecord);

        gEndDate := WORKDATE;
        gStartDate := CALCDATE('-41D', gEndDate);
        CalcTotals;
    end;

    trigger OnAfterGetRecord()
    var
        MATRIX_CurrentColumnOrdinal: Integer;
    begin
        MATRIX_CurrentColumnOrdinal := 0;
        IF MatrixRecord.FIND('-') THEN
            REPEAT
                MATRIX_CurrentColumnOrdinal := MATRIX_CurrentColumnOrdinal + 1;
                MATRIX_OnAfterGetRecord(MATRIX_CurrentColumnOrdinal);
            UNTIL (MatrixRecord.NEXT(1) = 0) OR (MATRIX_CurrentColumnOrdinal = MATRIX_NoOfMatrixColumns);
    end;

    procedure MATRIX_OnAfterGetRecord(ColumnID: Integer)
    begin
        gItem.SETRANGE("Location Filter", MatrixRecords[ColumnID].Code);
        CASE "No." OF
            '001':
                BEGIN

                    gItem.CALCFIELDS("Qty. on Hand (Rep. UOM) ELA");
                    MATRIX_CellData[ColumnID] := ROUND(gItem."Qty. on Hand (Rep. UOM) ELA", 0.01);

                END;
            '002':
                BEGIN
                    gItem.CALCFIELDS("Qty. on Purch. Order");

                    MATRIX_CellData[ColumnID] := ROUND(ibItemTransfToRepUOMValue(gItem."Qty. on Purch. Order", gItem), 0.01);

                END;
            '003':
                BEGIN
                    gItem.CALCFIELDS("Qty. on Sales Order");

                    MATRIX_CellData[ColumnID] := 0 - ROUND(ibItemTransfToRepUOMValue(gItem."Qty. on Sales Order", gItem), 0.01);

                END;
            '004':
                BEGIN
                    gItem.CALCFIELDS("Qty. in Transit", "Trans. Ord. Receipt (Qty.)", "Trans. Ord. Shipment (Qty.)");
                    MATRIX_CellData[ColumnID] := ROUND(ibItemTransfToRepUOMValue(gItem."Qty. in Transit" + "Trans. Ord. Receipt (Qty.)" - "Trans. Ord. Shipment (Qty.)", gItem), 0.01);

                END;
            '005':
                BEGIN
                    gItem.CALCFIELDS(Inventory);
                    gItem.CALCFIELDS("Qty. on Hand (Rep. UOM) ELA");
                    gItem.CALCFIELDS("Qty. on Purch. Order");
                    gItem.CALCFIELDS("Qty. on Sales Order");

                    gItem.CALCFIELDS("Qty. in Transit", "Trans. Ord. Receipt (Qty.)", "Trans. Ord. Shipment (Qty.)");

                    MATRIX_CellData[ColumnID] :=
                      ROUND(gItem."Qty. on Hand (Rep. UOM) ELA", 0.01)
                      + ROUND(ibItemTransfToRepUOMValue(gItem."Qty. on Purch. Order", gItem), 0.01)
                      - ROUND(ibItemTransfToRepUOMValue(gItem."Qty. on Sales Order", gItem), 0.01)
                      + ROUND(ibItemTransfToRepUOMValue(gItem."Qty. in Transit" + "Trans. Ord. Receipt (Qty.)" - "Trans. Ord. Shipment (Qty.)", gItem), 0.01);

                END;
            '006':
                BEGIN
                    MATRIX_CellData[ColumnID] := WeekSalesGet(MatrixRecords[ColumnID].Code, FALSE);
                END;
        END;
        //</IB56395RTH>
        SetVisible;
    end;

    procedure Load(MatrixColumns1: ARRAY[32] OF Text[1024]; VAR MatrixRecords1: ARRAY[32] OF Record Location; VAR MatrixRecord1: Record Location)
    begin
        COPYARRAY(MATRIX_ColumnCaption, MatrixColumns1, 1);
        COPYARRAY(MatrixRecords, MatrixRecords1, 1);
        MatrixRecord.COPY(MatrixRecord1);
    end;

    procedure MatrixOnDrillDown(ColumnID: Integer)
    var
        lPurchLine: Record "Purchase Line";
        lSalesLine: Record "Sales Line";
        lItemLedgerEntry: Record "Item Ledger Entry";
        lTransferLine: Record "Transfer Line";
        lLocCode: Code[10];
    begin
        IF ColumnID <> 0 THEN BEGIN
            lLocCode := MatrixRecords[ColumnID].Code;
        END ELSE BEGIN
            lLocCode := '';
        END;
        CASE "No." OF
            '001':
                BEGIN
                    WITH lItemLedgerEntry DO BEGIN
                        SETCURRENTKEY(
                          "Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
                        SETRANGE("Item No.", gItem."No.");
                        IF lLocCode <> '' THEN BEGIN
                            SETRANGE("Location Code", lLocCode);
                        END;
                        PAGE.RUN(0, lItemLedgerEntry);
                    END;
                END;
            '002':
                BEGIN
                    WITH lPurchLine DO BEGIN
                        SETFILTER("Document Type", '%1', "Document Type"::Order);
                        SETFILTER(Type, '%1', Type::Item);
                        SETFILTER("No.", gItem."No.");
                        IF lLocCode <> '' THEN BEGIN
                            SETRANGE("Location Code", lLocCode);
                        END;
                        PAGE.RUN(0, lPurchLine);
                    END;
                END;
            '003':
                BEGIN
                    WITH lSalesLine DO BEGIN
                        SETFILTER("Document Type", '%1', "Document Type"::Order);
                        SETFILTER(Type, '%1', Type::Item);
                        SETFILTER("No.", gItem."No.");
                        IF lLocCode <> '' THEN BEGIN
                            SETRANGE("Location Code", lLocCode);
                        END;
                        PAGE.RUN(0, lSalesLine);
                    END;
                END;
            '004':
                BEGIN
                    WITH lTransferLine DO BEGIN
                        SETFILTER("Derived From Line No.", '%1', 0);
                        SETFILTER("Item No.", gItem."No.");
                        IF lLocCode <> '' THEN BEGIN
                            SETRANGE("Transfer-to Code", lLocCode);
                        END;
                        PAGE.RUN(0, lTransferLine);
                    END;
                END;
            '005':
                BEGIN
                END;
            '006':
                BEGIN
                    WeekSalesGet(lLocCode, TRUE);
                END;
        END;
    end;

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
    end;

    procedure SetItem(VAR pItem: Record Item)
    begin
        gItem.GET(pItem."No.");
        CalcTotals;
    end;

    procedure SetColumns(SetWanted: Option "Initial","Previous","Same","Next")
    var
        MatrixMgt: Codeunit "Matrix Management";
        CaptionFieldNo: Integer;
        CurrentMatrixRecordOrdinal: Integer;
    begin
        MatrixRecord.SETRANGE("Use As In-Transit", ShowInTransit);
        MatrixRecord.SETFILTER("Item List Matrix ELA", '%1', TRUE);

        CLEAR(MATRIX_CaptionSet);
        CLEAR(MatrixRecords);
        CurrentMatrixRecordOrdinal := 1;

        MatrixRecordRef.GETTABLE(MatrixRecord);
        MatrixRecordRef.SETTABLE(MatrixRecord);

        IF ShowColumnName THEN
            CaptionFieldNo := MatrixRecord.FIELDNO(Name)
        ELSE
            CaptionFieldNo := MatrixRecord.FIELDNO(Code);

        MatrixMgt.GenerateMatrixData(MatrixRecordRef, SetWanted, ARRAYLEN(MatrixRecords), CaptionFieldNo, MATRIX_PKFirstRecInCurrSet,
          MATRIX_CaptionSet, MATRIX_CaptionRange, MATRIX_CurrSetLength);

        IF MATRIX_CurrSetLength > 0 THEN BEGIN
            MatrixRecord.SETPOSITION(MATRIX_PKFirstRecInCurrSet);
            MatrixRecord.FIND;
            REPEAT
                MatrixRecords[CurrentMatrixRecordOrdinal].COPY(MatrixRecord);
                CurrentMatrixRecordOrdinal := CurrentMatrixRecordOrdinal + 1;
            UNTIL (CurrentMatrixRecordOrdinal > MATRIX_CurrSetLength) OR (MatrixRecord.NEXT <> 1);
        END;
    end;

    procedure CalcTotals()
    var
        x: Integer;
        y: Integer;
    begin
        IF gItem."No." = '' THEN BEGIN
            EXIT;
        END;
        CLEAR(gQtyArray);
        MODIFYALL("Reorder Point", 0);
        // For all locations ...
        FOR y := 1 TO MatrixRecord.COUNT DO BEGIN
            gItem.SETRANGE("Location Filter", MatrixRecords[y].Code);
            // First 4 recs are CALCFIELDS, 5th is sum of the 4
            FINDFIRST;
            FOR x := 1 TO 6 DO BEGIN
                CASE "No." OF
                    '001': // Qty. on Hand
                        BEGIN

                            gItem.CALCFIELDS("Qty. on Hand (Rep. UOM) ELA");
                            gQtyArray[1] := ROUND(gItem."Qty. on Hand (Rep. UOM) ELA", 0.01);
                            "Reorder Point" += gQtyArray[1];
                            MODIFY;
                        END;
                    '002': // Qty. on PO
                        BEGIN
                            gItem.CALCFIELDS("Qty. on Purch. Order");

                            gQtyArray[2] := ROUND(ibItemTransfToRepUOMValue(gItem."Qty. on Purch. Order", gItem), 0.01);
                            //</IB8954JYL>
                            "Reorder Point" += gQtyArray[2];
                            MODIFY;
                        END;
                    '003': // Qty. on SO
                        BEGIN
                            gItem.CALCFIELDS("Qty. on Sales Order");
                            gQtyArray[3] := 0 - ROUND(ibItemTransfToRepUOMValue(gItem."Qty. on Sales Order", gItem), 0.01);
                            //</IB8954JYL>
                            "Reorder Point" += gQtyArray[3];
                            MODIFY;
                        END;
                    '004': // Qty. in Transit
                        BEGIN
                            // As per PBI
                            gItem.CALCFIELDS("Qty. in Transit", "Trans. Ord. Receipt (Qty.)", "Trans. Ord. Shipment (Qty.)");
                            gQtyArray[4] := ROUND(ibItemTransfToRepUOMValue(gItem."Qty. in Transit" + "Trans. Ord. Receipt (Qty.)" - "Trans. Ord. Shipment (Qty.)", gItem), 0.01);
                            //</IB8954JYL>
                            "Reorder Point" += gQtyArray[4];
                            MODIFY;
                        END;
                    '005': // Available
                        BEGIN
                            "Reorder Point" += gQtyArray[1] + gQtyArray[2] + gQtyArray[3] + gQtyArray[4];
                            MODIFY;
                        END;
                    '006':
                        BEGIN
                            "Reorder Point" += WeekSalesGet(MatrixRecords[y].Code, FALSE);
                            MODIFY;
                        END;
                END;
                NEXT;
            END;
        END;
        CurrPage.ACTIVATE(TRUE);
    end;

    procedure WeekSalesGet(pLocationCode: Code[10]; pDrillDown: Boolean): Decimal
    var
        lILE: Record "Item Ledger Entry";
        lCalced: Boolean;
    begin
        lILE.SETFILTER("Item No.", gItem."No.");
        lILE.SETRANGE("Posting Date", gStartDate, gEndDate);
        lILE.SETFILTER("Entry Type", '%1', lILE."Entry Type"::Sale);
        IF pLocationCode <> '' THEN BEGIN
            lILE.SETFILTER("Location Code", pLocationCode);
        END;
        IF NOT WeekSalesBufferTMP.GET(pLocationCode, gItem."No.") THEN BEGIN
            lILE.CALCSUMS("Reporting Qty. ELA");
            lCalced := TRUE;
            WeekSalesBufferTMP.Key1 := pLocationCode;
            WeekSalesBufferTMP.Key2 := gItem."No.";
            WeekSalesBufferTMP.Decimal1 := ROUND(0 - lILE."Reporting Qty. ELA" / 6, 0.1);
            WeekSalesBufferTMP.INSERT;
        END;
        IF pDrillDown THEN BEGIN
            PAGE.RUNMODAL(0, lILE);
            EXIT;
        END;
        IF NOT lCalced THEN BEGIN

            lILE.CALCSUMS("Reporting Qty. ELA");
        END;
        EXIT(ROUND(0 - lILE."Reporting Qty. ELA" / 6, 0.1));
    end;

    procedure ibItemTransfToRepUOMValue(pSourceValue: Decimal; pSourceItem: Record Item) rReptingUOMValue: Decimal
    var
        lItemUoM: Record "Item Unit of Measure";
    begin
        IF (pSourceValue = 0) OR (pSourceItem."Reporting UOM ELA" = '') THEN BEGIN
            EXIT(0);
        END;

        IF NOT lItemUoM.GET(pSourceItem."No.", pSourceItem."Reporting UOM ELA") THEN BEGIN
            EXIT(0);
        END;

        rReptingUOMValue := pSourceValue / lItemUoM."Qty. per Unit of Measure";
    end;
}