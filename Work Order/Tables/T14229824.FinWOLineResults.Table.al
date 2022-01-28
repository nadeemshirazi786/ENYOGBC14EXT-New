table 14229824 "Fin. WO Line Results ELA"
{
    DrillDownPageID = "Fin. WO Line Results ELA";
    LookupPageID = "Fin. WO Line Results ELA";

    fields
    {
        field(1; "PM Work Order No."; Code[20])
        {
            TableRelation = "Finished WO Header ELA"."PM Work Order No.";
        }
        field(2; "PM Proc. Version No."; Code[10])
        {
        }
        field(3; "PM WO Line No."; Integer)
        {
        }
        field(4; "Result No."; Integer)
        {
        }
        field(5; "PM Procedure Code"; Code[20])
        {
            TableRelation = "PM Procedure Header ELA".Code;
        }
        field(10; "PM Measure Code"; Code[20])
        {
            CalcFormula = Lookup ("Work Order Line ELA"."PM Measure Code" WHERE ("PM Work Order No." = FIELD ("PM Work Order No."),
                                                                            "Line No." = FIELD ("PM WO Line No.")));
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "PM Measure ELA";
        }
        field(11; "Result Value"; Decimal)
        {
        }
    }

    keys
    {
        key(Key1; "PM Work Order No.", "PM WO Line No.", "Result No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    [Scope('Internal')]
    procedure jfdoPMWOResultsLookup(precFinPMWOLine: Record "Finished WO Line ELA"; pblnLookupForm: Boolean): Decimal
    var
        lfrmFinPMWOLineResults: Page "Fin. WO Line Results ELA";
        lrecFinPMWOLineResults: Record "Fin. WO Line Results ELA";
        //lrecQStatBufferTemp: Record Table23019239 temporary;
        lintNoResults: Integer;
        linti: Integer;
        lintMedianCount: Integer;
        ldecMedianValue: Decimal;
    begin
        lrecFinPMWOLineResults.SetRange("PM Work Order No.", precFinPMWOLine."PM Work Order No.");
        lrecFinPMWOLineResults.SetRange("PM WO Line No.", precFinPMWOLine."Line No.");

        if pblnLookupForm then begin
            lfrmFinPMWOLineResults.SETTABLEVIEW(lrecFinPMWOLineResults);
            lfrmFinPMWOLineResults.RUNMODAL;
        end;

        /*
        lintNoResults := lrecFinPMWOLineResults.COUNT;
        
        IF lrecFinPMWOLineResults.FIND('-') THEN BEGIN
          CASE precFinPMWOLine."Result Calc. Type" OF
            precFinPMWOLine."Result Calc. Type" :: Mean : BEGIN
              lrecFinPMWOLineResults.CALCSUMS("Result Value");
              EXIT(ROUND(lrecFinPMWOLineResults."Result Value" / lintNoResults, precFinPMWOLine."Decimal Rounding Precision"));
            END;
            precFinPMWOLine."Result Calc. Type" :: Median : BEGIN
              lrecFinPMWOLineResults.SETCURRENTKEY("PM Work Order No.", "PM WO Line No.", "Result Value");
              lrecFinPMWOLineResults.FIND('-');
              IF lintNoResults MOD 2 <> 0 THEN BEGIN
                lintMedianCount := lintNoResults DIV 2;
                lrecFinPMWOLineResults.NEXT(lintMedianCount);
                ldecMedianValue := lrecFinPMWOLineResults."Result Value";
                EXIT(ldecMedianValue);
              END ELSE BEGIN
                lintMedianCount := lintNoResults DIV 2;
                lrecFinPMWOLineResults.NEXT(lintMedianCount-1);
                ldecMedianValue := lrecFinPMWOLineResults."Result Value";
                lrecFinPMWOLineResults.NEXT;
                ldecMedianValue += lrecFinPMWOLineResults."Result Value";
                ldecMedianValue := ROUND(ldecMedianValue / 2,precFinPMWOLine."Decimal Rounding Precision");
                EXIT(ldecMedianValue);
              END;
            END;
            precFinPMWOLine."Result Calc. Type" :: Mode : BEGIN
              REPEAT
                lrecQStatBufferTemp."Decimal Value" := lrecFinPMWOLineResults."Result Value";
                lrecQStatBufferTemp.Occurrences := 1;
                IF NOT lrecQStatBufferTemp.INSERT THEN BEGIN
                  lrecQStatBufferTemp.FIND;
                  lrecQStatBufferTemp.Occurrences += 1;
                  lrecQStatBufferTemp.MODIFY;
                END;
              UNTIL lrecFinPMWOLineResults.NEXT = 0;
              lrecQStatBufferTemp.SETCURRENTKEY(Occurrences);
              lrecQStatBufferTemp.FIND('+');
              lrecQStatBufferTemp.SETRANGE(Occurrences, lrecQStatBufferTemp.Occurrences);
              EXIT(lrecQStatBufferTemp."Decimal Value");
            END;
          END;
        END;
        */

    end;
}

