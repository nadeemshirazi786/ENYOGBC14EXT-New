table 23019266 "WO Line Result"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    DrillDownPageID = 23019266;
    LookupPageID = 23019266;

    fields
    {
        field(1; "PM Work Order No."; Code[20])
        {
            TableRelation = Table23019260.Field1;
        }
        field(2; "PM Proc. Version No."; Code[10])
        {
            TableRelation = "PM Procedure Header"."Version No." WHERE (Code = FIELD ("PM Procedure Code"));
        }
        field(3; "PM WO Line No."; Integer)
        {
        }
        field(4; "Result No."; Integer)
        {
        }
        field(5; "PM Procedure Code"; Code[20])
        {
            TableRelation = "PM Procedure Header".Code;
        }
        field(10; "PM Measure Code"; Code[20])
        {
            CalcFormula = Lookup ("Work Order Line"."PM Measure Code" WHERE ("PM Work Order No." = FIELD ("PM Work Order No."),
                                                                            "Line No." = FIELD ("PM WO Line No.")));
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "PM Measure";
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
            SumIndexFields = "Result Value";
        }
        key(Key2; "PM Work Order No.", "PM WO Line No.", "Result Value")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if HasLinks then
            DeleteLinks;
    end;

    [Scope('Internal')]
    procedure jfdoPMWOResultsLookup(precPMWOLine: Record "Work Order Line"; pblnLookupForm: Boolean): Decimal
    var
        lfrmPMWOLineResults: Page Page23019266;
        lrecPMWOLineResults: Record "WO Line Result";
        lrecQStatBufferTemp: Record Table23019239 temporary;
        lintNoResults: Integer;
        linti: Integer;
        lintMedianCount: Integer;
        ldecMedianValue: Decimal;
    begin
        lrecPMWOLineResults.SetRange("PM Work Order No.", precPMWOLine."PM Work Order No.");
        lrecPMWOLineResults.SetRange("PM WO Line No.", precPMWOLine."Line No.");

        if pblnLookupForm then begin
            lintNoResults := lrecPMWOLineResults.Count;
            if lintNoResults <> precPMWOLine."No. Results" then begin
                if lrecPMWOLineResults.Find('+') then;
                for linti := 1 to precPMWOLine."No. Results" - lintNoResults do begin
                    lrecPMWOLineResults."PM Work Order No." := precPMWOLine."PM Work Order No.";
                    lrecPMWOLineResults."PM WO Line No." := precPMWOLine."Line No.";
                    lrecPMWOLineResults."PM Proc. Version No." := precPMWOLine."PM Proc. Version No.";
                    lrecPMWOLineResults."PM Procedure Code" := precPMWOLine."PM Procedure Code";
                    lrecPMWOLineResults."Result No." := lrecPMWOLineResults."Result No." + 1;
                    lrecPMWOLineResults."Result Value" := 0;
                    lrecPMWOLineResults.Insert;
                end;
                Commit;
            end;

            lfrmPMWOLineResults.SETTABLEVIEW(lrecPMWOLineResults);
            lfrmPMWOLineResults.RUNMODAL;
        end;

        lintNoResults := lrecPMWOLineResults.Count;

        if lrecPMWOLineResults.Find('-') then begin
            case precPMWOLine."Result Calc. Type" of
                precPMWOLine."Result Calc. Type"::Mean:
                    begin
                        lrecPMWOLineResults.CalcSums("Result Value");
                        exit(Round(lrecPMWOLineResults."Result Value" / lintNoResults, precPMWOLine."Decimal Rounding Precision"));
                    end;
                precPMWOLine."Result Calc. Type"::Median:
                    begin
                        lrecPMWOLineResults.SetCurrentKey("PM Work Order No.", "PM WO Line No.", "Result Value");
                        lrecPMWOLineResults.Find('-');
                        if lintNoResults mod 2 <> 0 then begin
                            lintMedianCount := lintNoResults div 2;
                            lrecPMWOLineResults.Next(lintMedianCount);
                            ldecMedianValue := lrecPMWOLineResults."Result Value";
                            exit(ldecMedianValue);
                        end else begin
                            lintMedianCount := lintNoResults div 2;
                            lrecPMWOLineResults.Next(lintMedianCount - 1);
                            ldecMedianValue := lrecPMWOLineResults."Result Value";
                            lrecPMWOLineResults.Next;
                            ldecMedianValue += lrecPMWOLineResults."Result Value";
                            ldecMedianValue := Round(ldecMedianValue / 2, precPMWOLine."Decimal Rounding Precision");
                            exit(ldecMedianValue);
                        end;
                    end;
                precPMWOLine."Result Calc. Type"::Mode:
                    begin
                        repeat
                            lrecQStatBufferTemp."Decimal Value" := lrecPMWOLineResults."Result Value";
                            lrecQStatBufferTemp.Occurrences := 1;
                            if not lrecQStatBufferTemp.INSERT then begin
                                lrecQStatBufferTemp.FIND;
                                lrecQStatBufferTemp.Occurrences += 1;
                                lrecQStatBufferTemp.MODIFY;
                            end;
                        until lrecPMWOLineResults.Next = 0;
                        lrecQStatBufferTemp.SETCURRENTKEY(Occurrences);
                        lrecQStatBufferTemp.FIND('+');
                        lrecQStatBufferTemp.SETRANGE(Occurrences, lrecQStatBufferTemp.Occurrences);
                        exit(lrecQStatBufferTemp."Decimal Value");
                    end;
            end;
        end;
    end;
}

