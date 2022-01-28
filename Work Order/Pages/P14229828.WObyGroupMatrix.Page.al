page 14229828 "WO by Group Matrix ELA"
{
    Caption = 'WO by Group Matrix';
    Editable = true;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "PM Group ELA";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Code)
                {
                }
                field(Description; Description)
                {
                }
                field(Field1; MATRIX_CellData[1])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[1];
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(1)
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(1);
                    end;
                }
                field(Field2; MATRIX_CellData[2])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[2];
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(2)
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(2);
                    end;
                }
                field(Field3; MATRIX_CellData[3])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[3];
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(3)
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(3);
                    end;
                }
                field(Field4; MATRIX_CellData[4])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[4];
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(4)
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(4);
                    end;
                }
                field(Field5; MATRIX_CellData[5])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[5];
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(5)
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(5);
                    end;
                }
                field(Field6; MATRIX_CellData[6])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[6];
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(6)
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(6);
                    end;
                }
                field(Field7; MATRIX_CellData[7])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[7];
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(7)
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(7);
                    end;
                }
                field(Field8; MATRIX_CellData[8])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[8];
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(8)
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(8);
                    end;
                }
                field(Field9; MATRIX_CellData[9])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[9];
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(9)
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(9);
                    end;
                }
                field(Field10; MATRIX_CellData[10])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[10];
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(10)
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(10);
                    end;
                }
                field(Field11; MATRIX_CellData[11])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[11];
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(11)
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(11);
                    end;
                }
                field(Field12; MATRIX_CellData[12])
                {
                    CaptionClass = '3,' + MATRIX_ColumnCaption[12];
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(12)
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(12);
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
        WHILE MATRIX_CurrentColumnOrdinal < MATRIX_NoOfMatrixColumns DO BEGIN
            MATRIX_CurrentColumnOrdinal := MATRIX_CurrentColumnOrdinal + 1;
            MATRIX_OnAfterGetRecord(MATRIX_CurrentColumnOrdinal);
        END;
    end;

    var
        PeriodFormMgt: Codeunit PeriodFormManagement;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        QtyType: Option "Net Change","Balance at Date";
        MatrixRecord: Record Date;
        MatrixRecords: array[32] of Record Date;
        MATRIX_NoOfMatrixColumns: Integer;
        MATRIX_CellData: array[32] of Decimal;
        MATRIX_ColumnCaption: array[32] of Text[1024];
        goptValueType: Option "All PM WOs","Failed PM WOs","Complete PM WOs";
        gcodPersonRespFilter: Code[20];
        gcodPMProdCodeFilter: Code[20];
        goptPMTypeFilter: Option " ","Machine Center","Work Center","Fixed Asset";

    local procedure SetDateFilter(ColumnID: Integer)
    begin
        IF QtyType = QtyType::"Net Change" THEN
            IF MatrixRecords[ColumnID]."Period Start" = MatrixRecords[ColumnID]."Period End" THEN
                SETRANGE("Date Filter", MatrixRecords[ColumnID]."Period Start")
            ELSE
                SETRANGE("Date Filter", MatrixRecords[ColumnID]."Period Start", MatrixRecords[ColumnID]."Period End")
        ELSE
            SETRANGE("Date Filter", 0D, MatrixRecords[ColumnID]."Period End");
    end;

    local procedure MATRIX_OnAfterGetRecord(ColumnID: Integer)
    begin
        SetDateFilter(ColumnID);


        IF goptValueType = goptValueType::"All PM WOs" THEN BEGIN
            SETRANGE("PM Failure Filter");
            SETRANGE("Test Complete Filter");
        END;
        IF goptValueType = goptValueType::"Failed PM WOs" THEN BEGIN
            SETRANGE("PM Failure Filter", TRUE);
            SETRANGE("Test Complete Filter");
        END;
        IF goptValueType = goptValueType::"Complete PM WOs" THEN BEGIN
            SETRANGE("PM Failure Filter");
            SETRANGE("Test Complete Filter", TRUE);
        END;

        IF gcodPersonRespFilter <> '' THEN BEGIN
            SETFILTER("Person Responsible Filter", gcodPersonRespFilter)
        END ELSE BEGIN
            SETRANGE("Person Responsible Filter");
        END;

        IF gcodPMProdCodeFilter <> '' THEN BEGIN
            SETRANGE("PM Procedure Filter", gcodPMProdCodeFilter);
        END ELSE BEGIN
            SETRANGE("PM Procedure Filter");
        END;

        IF goptPMTypeFilter <> goptPMTypeFilter::" " THEN BEGIN
            SETRANGE("PM Type Filter", goptPMTypeFilter);
        END ELSE BEGIN
            SETRANGE("PM Type Filter");
        END;


        CALCFIELDS("PM Work Order Count");
        IF "PM Work Order Count" <> 0 THEN
            MATRIX_CellData[ColumnID] := "PM Work Order Count"
        ELSE
            MATRIX_CellData[ColumnID] := 0;
    end;

    [Scope('Internal')]
    procedure Load(PeriodType1: Option Day,Week,Month,Quarter,Year,"Accounting Period"; QtyType1: Option "Net Change","Balance at Date"; MatrixColumns1: array[32] of Text[1024]; var MatrixRecords1: array[32] of Record Date; NoOfMatrixColumns1: Integer; loptValueType1: Option "All PM WOs","Failed PM WOs","Complete PM WOs"; lcodPersonResp1: Code[20]; lcodPMProdCode1: Code[20]; loptPMType1: Option " ","Machine Center","Work Center","Fixed Asset")
    var
        i: Integer;
    begin
        goptValueType := loptValueType1;
        gcodPersonRespFilter := lcodPersonResp1;
        gcodPMProdCodeFilter := lcodPMProdCode1;
        goptPMTypeFilter := loptPMType1;


        PeriodType := PeriodType1;
        QtyType := QtyType1;
        COPYARRAY(MATRIX_ColumnCaption, MatrixColumns1, 1);
        FOR i := 1 TO ARRAYLEN(MatrixRecords) DO
            MatrixRecords[i].COPY(MatrixRecords1[i]);
        MATRIX_NoOfMatrixColumns := NoOfMatrixColumns1;

        CurrPage.UPDATE(FALSE);
    end;

    [Scope('Internal')]
    procedure MatrixOnDrillDown(ColumnID: Integer)
    var
        WOHeader: Record "Work Order Header ELA";
    begin
        SetDateFilter(ColumnID);

        WOHeader.SETCURRENTKEY("Work Order Date");

        WOHeader.SETRANGE("PM Group Code", Code);
        WOHeader.SETFILTER("Work Order Date", GETFILTER("Date Filter"));

        IF goptValueType = goptValueType::"All PM WOs" THEN BEGIN
            WOHeader.SETRANGE("PM WO Failure");
            WOHeader.SETRANGE("Test Complete");
        END;
        IF goptValueType = goptValueType::"Failed PM WOs" THEN BEGIN
            WOHeader.SETRANGE("PM WO Failure", TRUE);
            WOHeader.SETRANGE("Test Complete");
        END;
        IF goptValueType = goptValueType::"Complete PM WOs" THEN BEGIN
            WOHeader.SETRANGE("PM WO Failure");
            WOHeader.SETRANGE("Test Complete", TRUE);
        END;

        IF gcodPersonRespFilter <> '' THEN BEGIN
            WOHeader.SETRANGE("Person Responsible", gcodPersonRespFilter);
        END ELSE BEGIN
            WOHeader.SETRANGE("Person Responsible");
        END;

        IF gcodPMProdCodeFilter <> '' THEN BEGIN
            WOHeader.SETRANGE("PM Procedure Code", gcodPMProdCodeFilter);
        END ELSE BEGIN
            WOHeader.SETRANGE("PM Procedure Code");
        END;

        IF goptPMTypeFilter <> goptPMTypeFilter::" " THEN BEGIN
            WOHeader.SETRANGE(Type, goptPMTypeFilter);
        END ELSE BEGIN
            WOHeader.SETRANGE(Type);
        END;

        PAGE.RUN(0, WOHeader);
    end;

    [Scope('Internal')]
    procedure ValidateCapacity(MATRIX_ColumnOrdinal: Integer)
    begin
        SetDateFilter(MATRIX_ColumnOrdinal);
        CALCFIELDS("PM Work Order Count");
        VALIDATE("PM Work Order Count", MATRIX_CellData[MATRIX_ColumnOrdinal]);
    end;
}

