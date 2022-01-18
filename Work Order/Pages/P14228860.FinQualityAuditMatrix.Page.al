page 23019269 "Fin. Quality Audit Matrix"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF9162SHR
    //   20100915 - New Matrix Page

    Caption = 'Fin. Quality Audit Matrix';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = Table23019237;

    layout
    {
        area(content)
        {
            repeater()
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
        PeriodFormMgt: Codeunit "359";
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        QtyType: Option "Net Change","Balance at Date";
        MatrixRecord: Record "2000000007";
        MatrixRecords: array[32] of Record "2000000007";
        MATRIX_NoOfMatrixColumns: Integer;
        MATRIX_CellData: array[32] of Decimal;
        MATRIX_ColumnCaption: array[32] of Text[1024];
        goptValueType: Option "All Q.Audits","Failed Q.Audits","Complete Q.Audits";
        gcodPersonRespFilter: Code[20];
        gcodQPSetupCodeFilter: Code[20];
        goptQATypeFilter: Option " ",Item,"Machine Center","Work Center","Fixed Asset",Vendor,Customer,Employee,"Ship Agent","Quality Hold Remedial Actions","Quality Hold Disposition";

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

        IF goptValueType = goptValueType::"All Q.Audits" THEN BEGIN
            SETRANGE("QA Failure Filter");
            SETRANGE("Test Complete Filter");
        END;
        IF goptValueType = goptValueType::"Failed Q.Audits" THEN BEGIN
            SETRANGE("QA Failure Filter", TRUE);
            SETRANGE("Test Complete Filter");
        END;
        IF goptValueType = goptValueType::"Complete Q.Audits" THEN BEGIN
            SETRANGE("QA Failure Filter");
            SETRANGE("Test Complete Filter", TRUE);
        END;

        IF gcodPersonRespFilter <> '' THEN
            SETFILTER("Person Responsible Filter", gcodPersonRespFilter)
        ELSE
            SETRANGE("Person Responsible Filter");

        IF gcodQPSetupCodeFilter <> '' THEN
            SETFILTER("QP Setup Code Filter", gcodQPSetupCodeFilter)
        ELSE
            SETRANGE("QP Setup Code Filter");


        CASE goptQATypeFilter OF
            goptQATypeFilter::" ":
                BEGIN
                    SETRANGE("QA Type Filter");
                END;
            ELSE
                SETRANGE("QA Type Filter", goptQATypeFilter);
        END;

        /*
        CASE goptQADocType OF
          goptQADocType::" ":
          BEGIN
            SETRANGE("QA Doc. Type Filter");
          END;
        ELSE
          SETRANGE("QA Doc. Type Filter",goptQADocType);
        END;
        */

        CALCFIELDS("Fin. QA Count");
        IF "Fin. QA Count" <> 0 THEN
            MATRIX_CellData[ColumnID] := "Fin. QA Count"
        ELSE
            MATRIX_CellData[ColumnID] := 0;

    end;

    [Scope('Internal')]
    procedure Load(PeriodType1: Option Day,Week,Month,Quarter,Year,"Accounting Period"; QtyType1: Option "Net Change","Balance at Date"; MatrixColumns1: array[32] of Text[1024]; var MatrixRecords1: array[32] of Record "2000000007"; NoOfMatrixColumns1: Integer; loptValueType1: Option "All Q.Audits","Failed Q.Audits","Complete Q.Audits"; lcodPersonResp1: Code[20]; lcodQPSetupCode1: Code[20]; loptQAType1: Option " ",Item,"Machine Center","Work Center","Fixed Asset",Vendor,Customer,Employee,"Ship Agent","Quality Hold Remedial Actions","Quality Hold Disposition")
    var
        i: Integer;
    begin
        goptValueType := loptValueType1;
        gcodPersonRespFilter := lcodPersonResp1;
        gcodQPSetupCodeFilter := lcodQPSetupCode1;
        goptQATypeFilter := loptQAType1;


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
        FinQA: Record "23019220";
    begin
        SetDateFilter(ColumnID);
        FinQA.SETCURRENTKEY("Quality Audit No.");
        FinQA.SETRANGE("Quality Group Code", Code);

        FinQA.SETFILTER("Audit Date", GETFILTER("Date Filter"));

        IF goptValueType = goptValueType::"All Q.Audits" THEN BEGIN
            FinQA.SETRANGE("QA Failure");
            FinQA.SETRANGE("Test Complete");
        END;
        IF goptValueType = goptValueType::"Failed Q.Audits" THEN BEGIN
            FinQA.SETRANGE("QA Failure", TRUE);
            FinQA.SETRANGE("Test Complete");
        END;
        IF goptValueType = goptValueType::"Complete Q.Audits" THEN BEGIN
            FinQA.SETRANGE("QA Failure");
            FinQA.SETRANGE("Test Complete", TRUE);
        END;

        IF gcodPersonRespFilter <> '' THEN BEGIN
            FinQA.SETRANGE("Person Responsible", gcodPersonRespFilter);
        END ELSE BEGIN
            FinQA.SETRANGE("Person Responsible");
        END;
        IF gcodQPSetupCodeFilter <> '' THEN BEGIN
            FinQA.SETRANGE("QP Setup Code", gcodQPSetupCodeFilter);
        END ELSE BEGIN
            FinQA.SETRANGE("QP Setup Code");
        END;
        IF goptQATypeFilter <> goptQATypeFilter::" " THEN BEGIN
            FinQA.SETRANGE(Type, goptQATypeFilter);
        END ELSE BEGIN
            FinQA.SETRANGE(Type);
        END;
        PAGE.RUN(0, FinQA);
    end;

    [Scope('Internal')]
    procedure ValidateCapacity(MATRIX_ColumnOrdinal: Integer)
    begin
        SetDateFilter(MATRIX_ColumnOrdinal);
        CALCFIELDS("Fin. QA Count");
        VALIDATE("Fin. QA Count", MATRIX_CellData[MATRIX_ColumnOrdinal]);
    end;
}

