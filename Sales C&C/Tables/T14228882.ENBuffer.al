table 14228882 "Buffer ELA"
{

    fields
    {
        field(1; Key1; Code[20])
        {
        }
        field(2; Key2; Code[20])
        {
        }
        field(3; Key3; Code[20])
        {
        }
        field(4; Key4; Code[20])
        {
        }
        field(5; Key5; Code[20])
        {
        }
        field(6; Key6; Code[20])
        {
        }
        field(7; Key7; Code[20])
        {
        }
        field(8; Key8; Code[20])
        {
        }
        field(100; Code1; Code[20])
        {
        }
        field(101; Code2; Code[20])
        {
        }
        field(102; Code3; Code[20])
        {
        }
        field(103; Code4; Code[20])
        {
        }
        field(104; Code5; Code[20])
        {
        }
        field(105; Code6; Code[20])
        {
        }
        field(106; Code7; Code[20])
        {
        }
        field(107; Code8; Code[20])
        {
        }
        field(108; Code9; Code[20])
        {
        }
        field(109; Code10; Code[20])
        {
        }
        field(110; Code11; Code[20])
        {
        }
        field(200; Integer0; Integer)
        {
        }
        field(201; Integer1; Integer)
        {
        }
        field(202; Integer2; Integer)
        {
        }
        field(203; Integer3; Integer)
        {
        }
        field(204; Integer4; Integer)
        {
        }
        field(205; Integer5; Integer)
        {
        }
        field(206; Integer6; Integer)
        {
        }
        field(207; Integer7; Integer)
        {
        }
        field(300; Text300; Text[250])
        {
        }
        field(301; Text1; Text[50])
        {
        }
        field(302; Text2; Text[50])
        {
        }
        field(303; Text3; Text[50])
        {
        }
        field(400; Boolean1; Boolean)
        {
        }
        field(401; Boolean2; Boolean)
        {
        }
        field(402; Boolean3; Boolean)
        {
        }
        field(403; Boolean4; Boolean)
        {
        }
        field(404; Boolean5; Boolean)
        {
        }
        field(405; Boolean6; Boolean)
        {
        }
        field(406; Boolean7; Boolean)
        {
        }
        field(407; Boolean8; Boolean)
        {
        }
        field(501; Decimal1; Decimal)
        {
        }
        field(502; Decimal2; Decimal)
        {
        }
        field(503; Decimal3; Decimal)
        {
        }
        field(504; Decimal4; Decimal)
        {
        }
        field(505; Decimal5; Decimal)
        {
        }
        field(506; Decimal6; Decimal)
        {
        }
        field(507; Decimal7; Decimal)
        {
        }
        field(508; Decimal8; Decimal)
        {
        }
        field(509; Decimal9; Decimal)
        {
        }
        field(510; Decimal10; Decimal)
        {
        }
        field(511; Decimal11; Decimal)
        {
        }
        field(512; Decimal12; Decimal)
        {
        }
        field(513; Decimal13; Decimal)
        {
        }
        field(514; Decimal14; Decimal)
        {
        }
        field(515; Decimal15; Decimal)
        {
        }
        field(516; Decimal16; Decimal)
        {
        }
        field(517; Decimal17; Decimal)
        {
        }
        field(518; Decimal18; Decimal)
        {
        }
        field(519; Decimal19; Decimal)
        {
        }
        field(520; Decimal20; Decimal)
        {
        }
        field(521; Decimal21; Decimal)
        {
        }
        field(522; Decimal22; Decimal)
        {
        }
        field(523; Decimal23; Decimal)
        {
        }
        field(524; Decimal24; Decimal)
        {
        }
        field(525; Decimal25; Decimal)
        {
        }
        field(526; Decimal26; Decimal)
        {
        }
        field(527; Decimal27; Decimal)
        {
        }
        field(528; Decimal28; Decimal)
        {
        }
        field(529; Decimal29; Decimal)
        {
        }
        field(530; Decimal30; Decimal)
        {
        }
        field(700; Date1; Date)
        {
        }
        field(701; Date2; Date)
        {
        }
        field(702; Date3; Date)
        {
        }
        field(703; Date4; Date)
        {
        }
    }

    keys
    {
        key(Key1; Key1, Key2, Key3, Key4, Key5, Key6, Key7, Key8)
        {
            Clustered = true;
        }
        key(Key2; Date1)
        {
        }
        key(Key3; Integer0)
        {
        }
    }

    fieldgroups
    {
    }


    procedure CalcTotals(var precDataBufferTmp: Record "Buffer ELA" temporary; var precTotalBufferTmp: array[5] of Record "Buffer ELA" temporary; var pbolFirst: array[5] of Boolean; var pbolLast: array[5] of Boolean)
    var
        lint: Integer;
        lrecCurrDataTmp: Record "Buffer ELA" temporary;
    begin
        // <ES01360JB>

        lrecCurrDataTmp := precDataBufferTmp;

        //Set First Flag and reset values
        if (precDataBufferTmp.Next(-1) = 0) then begin
            for lint := 1 to 5 do begin
                pbolFirst[lint] := true;
                ClearBuffer(precTotalBufferTmp, lint);
            end;
        end else begin
            pbolFirst[5] := false;
            if (precDataBufferTmp.Key1 <> lrecCurrDataTmp.Key1) then begin
                for lint := 1 to 4 do begin
                    pbolFirst[lint] := true;
                    ClearBuffer(precTotalBufferTmp, lint);

                end;
            end else begin
                pbolFirst[1] := false;
                if (precDataBufferTmp.Key2 <> lrecCurrDataTmp.Key2) then begin
                    for lint := 2 to 4 do begin
                        pbolFirst[lint] := true;
                        ClearBuffer(precTotalBufferTmp, lint);
                    end;
                end else begin
                    pbolFirst[2] := false;
                    if (precDataBufferTmp.Key3 <> lrecCurrDataTmp.Key3) then begin
                        for lint := 3 to 4 do begin
                            pbolFirst[lint] := true;
                            ClearBuffer(precTotalBufferTmp, lint);
                        end;
                    end else begin
                        pbolFirst[3] := false;
                        if (precDataBufferTmp.Key4 <> lrecCurrDataTmp.Key4) then begin
                            for lint := 4 to 4 do begin
                                pbolFirst[lint] := true;
                                ClearBuffer(precTotalBufferTmp, lint);
                            end;
                        end else begin
                            pbolFirst[4] := false;
                        end;
                    end;
                end;
            end;
        end;

        //Create Totals
        precDataBufferTmp.Get(lrecCurrDataTmp.Key1, lrecCurrDataTmp.Key2, lrecCurrDataTmp.Key3, lrecCurrDataTmp.Key4,
                              lrecCurrDataTmp.Key5, lrecCurrDataTmp.Key6, lrecCurrDataTmp.Key7, lrecCurrDataTmp.Key8);
        for lint := 1 to 5 do begin
            precTotalBufferTmp[lint].Decimal1 += precDataBufferTmp.Decimal1;
            precTotalBufferTmp[lint].Decimal2 += precDataBufferTmp.Decimal2;
            precTotalBufferTmp[lint].Decimal3 += precDataBufferTmp.Decimal3;
            precTotalBufferTmp[lint].Decimal4 += precDataBufferTmp.Decimal4;
            precTotalBufferTmp[lint].Decimal5 += precDataBufferTmp.Decimal5;
            precTotalBufferTmp[lint].Decimal6 += precDataBufferTmp.Decimal6;
            precTotalBufferTmp[lint].Decimal7 += precDataBufferTmp.Decimal7;
            precTotalBufferTmp[lint].Decimal8 += precDataBufferTmp.Decimal8;
            precTotalBufferTmp[lint].Decimal9 += precDataBufferTmp.Decimal9;
            precTotalBufferTmp[lint].Integer1 := precTotalBufferTmp[lint].Integer1 + 1;  //Counter
        end;

        //Set Last-Flag
        precDataBufferTmp.Get(lrecCurrDataTmp.Key1, lrecCurrDataTmp.Key2, lrecCurrDataTmp.Key3, lrecCurrDataTmp.Key4,
                              lrecCurrDataTmp.Key5, lrecCurrDataTmp.Key6, lrecCurrDataTmp.Key7, lrecCurrDataTmp.Key8);
        if precDataBufferTmp.Next = 0 then begin
            for lint := 1 to 5 do begin
                pbolLast[lint] := true;
            end;
        end else begin
            pbolLast[5] := false;
            if precDataBufferTmp.Key1 <> lrecCurrDataTmp.Key1 then begin
                for lint := 1 to 4 do begin
                    pbolLast[lint] := true;
                end;
            end else begin
                pbolLast[1] := false;
                if precDataBufferTmp.Key2 <> lrecCurrDataTmp.Key2 then begin
                    for lint := 2 to 4 do begin
                        pbolLast[lint] := true;
                    end;
                end else begin
                    pbolLast[2] := false;
                    if precDataBufferTmp.Key3 <> lrecCurrDataTmp.Key3 then begin
                        for lint := 3 to 4 do begin
                            pbolLast[lint] := true;
                        end;
                    end else begin
                        pbolLast[3] := false;
                        if precDataBufferTmp.Key4 <> lrecCurrDataTmp.Key4 then begin
                            for lint := 4 to 4 do begin
                                pbolLast[lint] := true;
                            end;
                        end else begin
                            pbolLast[4] := false;
                        end;
                    end;
                end;
            end;
        end;

        precDataBufferTmp.Get(lrecCurrDataTmp.Key1, lrecCurrDataTmp.Key2, lrecCurrDataTmp.Key3, lrecCurrDataTmp.Key4,
                              lrecCurrDataTmp.Key5, lrecCurrDataTmp.Key6, lrecCurrDataTmp.Key7, lrecCurrDataTmp.Key8);
    end;


    procedure ClearBuffer(var precTotalBufferTmp: array[5] of Record "Buffer ELA" temporary; pint: Integer)
    begin
        precTotalBufferTmp[pint].Decimal1 := 0;
        precTotalBufferTmp[pint].Decimal2 := 0;
        precTotalBufferTmp[pint].Decimal3 := 0;
        precTotalBufferTmp[pint].Decimal4 := 0;
        precTotalBufferTmp[pint].Decimal5 := 0;
        precTotalBufferTmp[pint].Decimal6 := 0;
        precTotalBufferTmp[pint].Decimal7 := 0;
        precTotalBufferTmp[pint].Decimal8 := 0;
        precTotalBufferTmp[pint].Decimal9 := 0;
        precTotalBufferTmp[pint].Integer1 := 0;
    end;


    procedure Date2Code(pDate: Date): Code[20]
    begin
        // <ES01360JB>

        if pDate = 0D then
            exit('00000000')
        else
            exit(Format(pDate, 0, '<Year4><Month,2><Day,2>'));
    end;
}

