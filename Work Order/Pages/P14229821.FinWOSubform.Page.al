page 14229821 "Fin. WO Subform ELA"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Finished WO Line ELA";

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("PM Measure Code"; "PM Measure Code")
                {
                }
                field(Description; Description)
                {
                }
                field("PM Step Code"; "PM Step Code")
                {
                }
                field("PM Unit of Measure"; "PM Unit of Measure")
                {
                }
                field("Critical Control Point"; "Critical Control Point")
                {
                }
                field("Value Type"; "Value Type")
                {
                }
                field("Desired Value"; gtxtValue)
                {
                    Caption = 'Result Value';

                    trigger OnAssistEdit()
                    begin
                        IF "Value Type" = "Value Type"::Code THEN BEGIN
                            jmdoCodePropertyLookup;
                        END;
                        IF ("Value Type" = "Value Type"::Decimal) AND ("No. Results" > 1) THEN BEGIN
                            jfdoResultLineLookup;
                        END;
                    end;

                    trigger OnValidate()
                    begin
                        gtxtValueOnAfterValidate;
                    end;
                }
                field(Result; Result)
                {
                }
                field("Test Complete"; "Test Complete")
                {
                }
                field(gtxtDesiredValue; gtxtDesiredValue)
                {
                    Caption = 'Desired Value';
                    Editable = false;
                }
                field("No. Results"; "No. Results")
                {
                }
                field("Result Calc. Type"; "Result Calc. Type")
                {
                }
                field("Decimal Min"; "Decimal Min")
                {
                    Editable = "Decimal MinEditable";
                }
                field("Decimal Max"; "Decimal Max")
                {
                    Editable = "Decimal MaxEditable";
                }
                field("Qualification Code"; "Qualification Code")
                {
                }
                field("Employee No."; "Employee No.")
                {
                }
                field("PM Measure Cost"; "PM Measure Cost")
                {
                }
                field("Decimal Rounding Precision"; "Decimal Rounding Precision")
                {
                    Editable = DecimalRoundingPrecisionEditab;
                    Visible = false;
                }
                field("PMWO Item Consumption"; "PMWO Item Consumption")
                {
                }
                field("PMWO Resources"; "PMWO Resources")
                {
                }
                field("PMWO Comments"; "PMWO Comments")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        jmdoFormatValue;
        OnAfterGetCurrRecord;
    end;

    trigger OnInit()
    begin
        DecimalRoundingPrecisionEditab := TRUE;
        "Decimal MaxEditable" := TRUE;
        "Decimal MinEditable" := TRUE;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        OnAfterGetCurrRecord;
    end;

    var
        gtxtValue: Text[250];
        gtxtDesiredValue: Text[250];
        gvarValue: Variant;
        gvarDesiredValue: Variant;
        [InDataSet]
        "Decimal MinEditable": Boolean;
        [InDataSet]
        "Decimal MaxEditable": Boolean;
        [InDataSet]
        DecimalRoundingPrecisionEditab: Boolean;

    [Scope('Internal')]
    procedure SetEditable()
    begin
        "Decimal MinEditable" := TRUE;
        "Decimal MaxEditable" := TRUE;
        DecimalRoundingPrecisionEditab := TRUE;

        IF "Value Type" <> "Value Type"::Decimal THEN BEGIN
            "Decimal MinEditable" := FALSE;
            "Decimal MaxEditable" := FALSE;
            DecimalRoundingPrecisionEditab := FALSE;
        END;
    end;

    [Scope('Internal')]
    procedure jmdoFormatValue()
    var
        lrecPMWOLine: Record "Finished WO Line ELA";
        lrecPMProcLine: Record "PM Procedure Line ELA";
    begin
        "Decimal MinEditable" := "Value Type" = "Value Type"::Decimal;
        "Decimal MaxEditable" := "Value Type" = "Value Type"::Decimal;

        CLEAR(gvarValue);
        CLEAR(gvarDesiredValue);

        CLEAR(gtxtValue);
        CLEAR(gtxtDesiredValue);

        IF lrecPMWOLine.GET("PM Work Order No.", "Line No.") THEN BEGIN
            CASE "Value Type" OF
                "Value Type"::Boolean:
                    BEGIN
                        gtxtValue := FORMAT(lrecPMWOLine."Boolean Value");
                    END;
                "Value Type"::Code:
                    gtxtValue := lrecPMWOLine."Code Value";
                "Value Type"::Text:
                    gtxtValue := lrecPMWOLine."Text Value";
                "Value Type"::Decimal:
                    gtxtValue := FORMAT(lrecPMWOLine."Decimal Value");
                "Value Type"::Date:
                    BEGIN
                        gtxtValue := FORMAT(lrecPMWOLine."Date Value");
                    END;
            END;
        END ELSE
            gtxtValue := '';

        IF lrecPMProcLine.GET("PM Procedure Code", "PM Proc. Version No.", "Line No.") THEN BEGIN
            IF lrecPMProcLine."PM Measure Code" = "PM Measure Code" THEN BEGIN
                CASE "Value Type" OF
                    "Value Type"::Boolean:
                        BEGIN
                            gtxtDesiredValue := FORMAT(lrecPMProcLine."Boolean Value");
                        END;
                    "Value Type"::Code:
                        gtxtDesiredValue := lrecPMProcLine."Code Value";
                    "Value Type"::Text:
                        gtxtDesiredValue := lrecPMProcLine."Text Value";
                    "Value Type"::Decimal:
                        gtxtDesiredValue := FORMAT(lrecPMProcLine."Decimal Value");
                    "Value Type"::Date:
                        BEGIN
                            gtxtDesiredValue := FORMAT(lrecPMProcLine."Date Value");
                        END;
                END;
            END;
        END ELSE
            gtxtDesiredValue := '';

        gvarValue := FORMAT(gtxtValue);
        gvarDesiredValue := FORMAT(gtxtDesiredValue);
    end;

    [Scope('Internal')]
    procedure jmdoCodePropertyLookup(): Code[10]
    var
        lfrmQMCodeValues: Page "PM Measure Code Values ELA";
        lrecQMCodeValue: Record "PM Measure Code Value ELA";
    begin
        lrecQMCodeValue.SETRANGE("PM Measure Code", "PM Measure Code");
        lfrmQMCodeValues.SETTABLEVIEW(lrecQMCodeValue);
        CLEAR(lrecQMCodeValue);
        lfrmQMCodeValues.LOOKUPMODE := TRUE;
        IF lfrmQMCodeValues.RUNMODAL = ACTION::LookupOK THEN BEGIN
            lfrmQMCodeValues.GETRECORD(lrecQMCodeValue);
            EXIT(lrecQMCodeValue.Code);
        END ELSE
            EXIT(gvarValue);
    end;

    [Scope('Internal')]
    procedure jfdoResultLineLookup()
    var
        lrecFinPMWOLineResult: Record "Fin. WO Line Results ELA";
    begin
        lrecFinPMWOLineResult.jfdoPMWOResultsLookup(Rec, TRUE);
    end;

    local procedure gtxtValueOnAfterValidate()
    begin
        gvarValue := gtxtValue;

        jmdoValidateValue(gvarValue);
    end;

    local procedure OnAfterGetCurrRecord()
    begin
        xRec := Rec;
        SetEditable;
        jmdoFormatValue;
    end;
}

