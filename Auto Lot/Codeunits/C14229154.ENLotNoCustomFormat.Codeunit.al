/// <summary>
/// Codeunit Lot No. Custom Format ELA (ID 14229154).
/// </summary>
codeunit 14229154 "Lot No. Custom Format ELA"
{
    trigger OnRun()
    var
        LotNoData: Record "EN Lot No. Data ELA";
    begin
    end;

    var
        Text001: Label 'D*';
        Text002: Label 'Day of month - numeric (variable)';
        Text003: Label 'DD';
        Text004: Label 'Day of month - numeric (2)';
        Text005: Label 'DDD';
        Text006: Label 'Day of week - text (3)';
        Text007: Label 'D';
        Text008: Label 'Day of week - numeric (1)';
        Text009: Label 'M*';
        Text010: Label 'Month - numeric (variable)';
        Text011: Label 'MM';
        Text012: Label 'Month - numeric (2)';
        Text013: Label 'MMM';
        Text014: Label 'Month - text (3)';
        Text015: Label 'SPACE';
        Text016: Label 'Space - text (1)';
        Text017: Label 'J*';
        Text018: Label 'Day of year - numeric (variable)';
        Text019: Label 'JJJ';
        Text020: Label 'Day of year - numeric (3)';
        Text021: Label 'W*';
        Text022: Label 'Week of year - numeric (variable)';
        Text023: Label 'WW';
        Text024: Label 'Week of year - fixed (2)';
        Text025: Label 'Y';
        Text026: Label 'Year - numeric (1)';
        Text027: Label 'YY';
        Text028: Label 'Year - numeric (2)';
        Text029: Label 'YYYY';
        Text030: Label 'Year - numeric (4)';
        Text031: Label 'L';
        Text032: Label 'Location - text (variable)';
        Text033: Label 'E';
        Text034: Label 'Equipment - text (variable)';
        Text035: Label 'S';
        Text036: Label 'Shift - text (variable)';
        Text037: Label 'U';
        Text038: Label 'Unique sequence - numeric (1)';
        Text039: Label 'UU';
        Text040: Label 'Unique sequence - numeric (2)';
        Text041: Label 'UUU';
        Text042: Label 'Unique sequence - numeric (3)';
        Text043: Label 'U*';
        Text044: Label 'Unique sequence - numeric (variable)';
        Text045: Label 'N';
        Text046: Label 'Document No. - text (variable)';
/// <summary>
/// InitializeSegments.
/// </summary>
/// <param name="LotNoSegment">Temporary VAR Record "EN Lot No. Segment ELA".</param>
    [Scope('Internal')]
    procedure InitializeSegments(var LotNoSegment: Record "EN Lot No. Segment ELA" temporary)
    begin
        LotNoSegment.Reset;
        LotNoSegment.DeleteAll;
        LotNoSegment."Sequence No." := 0;

        InsertSegment('SPACE', LotNoSegment);
        InsertSegment('D*', LotNoSegment);
        InsertSegment('DD', LotNoSegment);
        InsertSegment('D', LotNoSegment);
        InsertSegment('DDD', LotNoSegment);
        InsertSegment('J*', LotNoSegment);
        InsertSegment('JJJ', LotNoSegment);
        InsertSegment('W*', LotNoSegment);
        InsertSegment('WW', LotNoSegment);
        InsertSegment('M*', LotNoSegment);
        InsertSegment('MM', LotNoSegment);
        InsertSegment('MMM', LotNoSegment);
        InsertSegment('Y', LotNoSegment);
        InsertSegment('YY', LotNoSegment);
        InsertSegment('YYYY', LotNoSegment);
        InsertSegment('N', LotNoSegment);
        InsertSegment('L', LotNoSegment);
        InsertSegment('E', LotNoSegment);
        InsertSegment('S', LotNoSegment);
        InsertSegment('U*', LotNoSegment);
        InsertSegment('U', LotNoSegment);
        InsertSegment('UU', LotNoSegment);
        InsertSegment('UUU', LotNoSegment);
    end;
/// <summary>
/// InitSegment.
/// </summary>
/// <param name="SegmentCode">Code[10].</param>
/// <param name="LotNoSegment">Temporary VAR Record "EN Lot No. Segment ELA".</param>
/// <returns>Return variable SegmentFound of type Boolean.</returns>
    local procedure InitSegment(SegmentCode: Code[10]; var LotNoSegment: Record "EN Lot No. Segment ELA" temporary) SegmentFound: Boolean
    begin
        SegmentFound := true;

        case SegmentCode of
            'SPACE':
                begin
                    LotNoSegment.Code := Text015;
                    LotNoSegment.Description := Text016;
                end;
            'D*':
                begin
                    LotNoSegment.Code := Text001;
                    LotNoSegment.Description := Text002;
                end;
            'DD':
                begin
                    LotNoSegment.Code := Text003;
                    LotNoSegment.Description := Text004;
                end;
            'DDD':
                begin
                    LotNoSegment.Code := Text005;
                    LotNoSegment.Description := Text006;
                end;
            'D':
                begin
                    LotNoSegment.Code := Text007;
                    LotNoSegment.Description := Text008;
                end;
            'J*':
                begin
                    LotNoSegment.Code := Text017;
                    LotNoSegment.Description := Text018;
                end;
            'JJJ':
                begin
                    LotNoSegment.Code := Text019;
                    LotNoSegment.Description := Text020;
                end;
            'W*':
                begin
                    LotNoSegment.Code := Text021;
                    LotNoSegment.Description := Text022;
                end;
            'WW':
                begin
                    LotNoSegment.Code := Text023;
                    LotNoSegment.Description := Text024;
                end;
            'M*':
                begin
                    LotNoSegment.Code := Text009;
                    LotNoSegment.Description := Text010;
                end;
            'MM':
                begin
                    LotNoSegment.Code := Text011;
                    LotNoSegment.Description := Text012;
                end;
            'MMM':
                begin
                    LotNoSegment.Code := Text013;
                    LotNoSegment.Description := Text014;
                end;
            'Y':
                begin
                    LotNoSegment.Code := Text025;
                    LotNoSegment.Description := Text026;
                end;
            'YY':
                begin
                    LotNoSegment.Code := Text027;
                    LotNoSegment.Description := Text028;
                end;
            'YYYY':
                begin
                    LotNoSegment.Code := Text029;
                    LotNoSegment.Description := Text030;
                end;
            'N':
                begin
                    LotNoSegment.Code := Text045;
                    LotNoSegment.Description := Text046;
                end;
            'L':
                begin
                    LotNoSegment.Code := Text031;
                    LotNoSegment.Description := Text032;
                end;
            'E':
                begin
                    LotNoSegment.Code := Text033;
                    LotNoSegment.Description := Text034;
                end;
            'S':
                begin
                    LotNoSegment.Code := Text035;
                    LotNoSegment.Description := Text036;
                end;
            'U':
                begin
                    LotNoSegment.Code := Text037;
                    LotNoSegment.Description := Text038;
                end;
            'UU':
                begin
                    LotNoSegment.Code := Text039;
                    LotNoSegment.Description := Text040;
                end;
            'UUU':
                begin
                    LotNoSegment.Code := Text041;
                    LotNoSegment.Description := Text042;
                end;
            'U*':
                begin
                    LotNoSegment.Code := Text043;
                    LotNoSegment.Description := Text044;
                end;
            else
                SegmentFound := false;
        end;

        if SegmentFound then begin
            LotNoSegment."Sequence No." += 1;
            LotNoSegment."Segment Code" := SegmentCode;
        end;
    end;

/// <summary>
/// SegmentField.
/// </summary>
/// <param name="SegmentCode">Code[10].</param>
/// <returns>Return value of type Integer.</returns>
    procedure SegmentField(SegmentCode: Code[10]): Integer
    var
        LotNoData: Record "EN Lot No. Data ELA";
    begin
        case SegmentCode of
            'SPACE':
                exit(0);
            'D*':
                exit(LotNoData.FieldNo(Date));
            'DD':
                exit(LotNoData.FieldNo(Date));
            'DDD':
                exit(LotNoData.FieldNo(Date));
            'D':
                exit(LotNoData.FieldNo(Date));
            'J*':
                exit(LotNoData.FieldNo(Date));
            'JJJ':
                exit(LotNoData.FieldNo(Date));
            'W*':
                exit(LotNoData.FieldNo(Date));
            'WW':
                exit(LotNoData.FieldNo(Date));
            'M*':
                exit(LotNoData.FieldNo(Date));
            'MM':
                exit(LotNoData.FieldNo(Date));
            'MMM':
                exit(LotNoData.FieldNo(Date));
            'Y':
                exit(LotNoData.FieldNo(Date));
            'YY':
                exit(LotNoData.FieldNo(Date));
            'YYYY':
                exit(LotNoData.FieldNo(Date));
            'N':
                exit(LotNoData.FieldNo("Document No."));
            'L':
                exit(LotNoData.FieldNo("Location Segment"));
            'E':
                exit(LotNoData.FieldNo("Equipment Segment"));
            'S':
                exit(LotNoData.FieldNo("Shift Segment"));
            'U*':
                exit(0);
            'U':
                exit(0);
            'UU':
                exit(0);
            'UUU':
                exit(0);
        end;
    end;

/// <summary>
/// FormatSegment.
/// </summary>
/// <param name="SegmentCode">Code[10].</param>
/// <param name="LotNoData">Record "EN Lot No. Data ELA".</param>
/// <returns>Return variable LotNo of type Code[50].</returns>
    procedure FormatSegment(SegmentCode: Code[10]; LotNoData: Record "EN Lot No. Data ELA") LotNo: Code[50]
    var
        DOY: Integer;
    begin

        case SegmentCode of
            'SPACE':
                begin
                    LotNo[1] := 177;
                end;
            'D*':
                begin
                    LotNoData.TestField(Date);
                    LotNo := Format(LotNoData.Date, 0, '<Day>');
                end;
            'DD':
                begin
                    LotNoData.TestField(Date);
                    LotNo := Format(LotNoData.Date, 0, '<Day,2>');
                end;
            'DDD':
                begin
                    LotNoData.TestField(Date);
                    LotNo := Format(LotNoData.Date, 0, '<WeekDay Text,3>');
                end;
            'D':
                begin
                    LotNoData.TestField(Date);
                    LotNo := Format(LotNoData.Date, 0, '<WeekDay>');
                end;
            'J*':
                begin
                    LotNoData.TestField(Date);
                    DOY := LotNoData.Date - CalcDate('<CY-1Y>', LotNoData.Date);
                    LotNo := Format(DOY);
                end;
            'JJJ':
                begin
                    LotNoData.TestField(Date);
                    DOY := LotNoData.Date - CalcDate('<CY-1Y>', LotNoData.Date);
                    LotNo := Format(DOY, 3, '<Integer,3><Filler,0>');
                end;
            'W*':
                begin
                    LotNoData.TestField(Date);
                    LotNo := Format(LotNoData.Date, 0, '<Week>');
                end;
            'WW':
                begin
                    LotNoData.TestField(Date);
                    LotNo := Format(LotNoData.Date, 0, '<Week,2>');
                end;
            'M*':
                begin
                    LotNoData.TestField(Date);
                    LotNo := Format(LotNoData.Date, 0, '<Month>');
                end;
            'MM':
                begin
                    LotNoData.TestField(Date);
                    LotNo := Format(LotNoData.Date, 0, '<Month,2>');
                end;
            'MMM':
                begin
                    LotNoData.TestField(Date);
                    LotNo := Format(LotNoData.Date, 0, '<Month Text,3>');
                end;
            'Y':
                begin
                    LotNoData.TestField(Date);
                    LotNo := CopyStr(Format(LotNoData.Date, 0, '<Year,2>'), 2, 1);
                end;
            'YY':
                begin
                    LotNoData.TestField(Date);
                    LotNo := Format(LotNoData.Date, 0, '<Year,2>');
                end;
            'YYYY':
                begin
                    LotNoData.TestField(Date);
                    LotNo := Format(LotNoData.Date, 0, '<Year4>');
                end;
            'N':
                begin
                    LotNoData.TestField("Document No.");
                    LotNo := LotNoData."Document No.";
                end;
            'L':
                begin
                    LotNoData.TestField("Location Segment");
                    LotNo := LotNoData."Location Segment";
                end;
            'E':
                begin
                    LotNoData.TestField("Equipment Segment");
                    LotNo := LotNoData."Equipment Segment";
                end;
            'S':
                begin
                    LotNoData.TestField("Shift Segment");
                    LotNo := LotNoData."Shift Segment";
                end;
            'U':
                if LotNoData.Sample then
                    LotNo := '9'
                else begin
                    LotNo := '-U-';
                    LotNo[1] := 176;
                    LotNo[3] := 176;
                end;
            'UU':
                if LotNoData.Sample then
                    LotNo := '99'
                else begin
                    LotNo := '-UU-';
                    LotNo[1] := 176;
                    LotNo[4] := 176;
                end;
            'UUU':
                if LotNoData.Sample then
                    LotNo := '999'
                else begin
                    LotNo := '-UUU-';
                    LotNo[1] := 176;
                    LotNo[5] := 176;
                end;
            'U*':
                if LotNoData.Sample then
                    LotNo := '999'
                else begin
                    LotNo := '-U*-';
                    LotNo[1] := 176;
                    LotNo[4] := 176;
                end;
        end;
    end;

/// <summary>
/// CheckSegment.
/// </summary>
/// <param name="SegmentCode">Code[10].</param>
/// <param name="LotNoData">Record "EN Lot No. Data ELA".</param>
/// <returns>Return value of type Boolean.</returns>
    procedure CheckSegment(SegmentCode: Code[10]; LotNoData: Record "EN Lot No. Data ELA"): Boolean
    var
        ReqFieldNo: Integer;
        LotNoDataRecRef: RecordRef;
        ReqField: FieldRef;
        DateVar: Date;
        CodeVar: Code[20];
    begin
        if ReqFieldNo = 0 then
            exit(true);

        LotNoDataRecRef.GetTable(LotNoData);
        ReqField := LotNoDataRecRef.Field(ReqFieldNo);

        case UpperCase(Format(ReqField.Type)) of
            'DATE':
                begin
                    DateVar := ReqField.Value;
                    exit(DateVar <> 0D);
                end;
            'CODE':
                begin
                    CodeVar := ReqField.Value;
                    exit(CodeVar <> '');
                end;
        end;
    end;

/// <summary>
/// SegmentChanged.
/// </summary>
/// <param name="SegmentCode">Code[10].</param>
/// <param name="LotNoData">Record "EN Lot No. Data ELA".</param>
/// <param name="xLotNoData">Record "EN Lot No. Data ELA".</param>
/// <returns>Return value of type Boolean.</returns>
    procedure SegmentChanged(SegmentCode: Code[10]; LotNoData: Record "EN Lot No. Data ELA"; xLotNoData: Record "EN Lot No. Data ELA"): Boolean
    var
        ReqFieldNo: Integer;
        LotNoDataRecRef: RecordRef;
        xLotNoDataRecRef: RecordRef;
        ReqField: FieldRef;
        xReqField: FieldRef;
        DateVar: Date;
        CodeVar: Code[10];
    begin
        ReqFieldNo := SegmentField(SegmentCode);
        if ReqFieldNo = 0 then
            exit(false);

        LotNoDataRecRef.GetTable(LotNoData);
        ReqField := LotNoDataRecRef.Field(ReqFieldNo);
        xLotNoDataRecRef.GetTable(xLotNoData);
        xReqField := xLotNoDataRecRef.Field(ReqFieldNo);

        exit(ReqField.Value <> xReqField.Value);
    end;

    local procedure InsertSegment(SegmentCode: Code[10]; var LotNoSegment: Record "EN Lot No. Segment ELA" temporary)
    var
        LotNoData: Record "EN Lot No. Data ELA";
    begin
        if InitSegment(SegmentCode, LotNoSegment) then
            LotNoSegment.Insert;
    end;
}

