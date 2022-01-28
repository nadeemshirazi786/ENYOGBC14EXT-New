page 14229811 "Work Order Subform ELA"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Work Order Line ELA";

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("PM Step Code"; "PM Step Code")
                {
                }
                field("PM Measure Code"; "PM Measure Code")
                {
                }
                field(Description; Description)
                {
                }
                field("Desired Value"; gtxtValue)
                {
                    Caption = 'Result Value';

                    trigger OnAssistEdit()
                    begin
                        IF "Value Type" = "Value Type"::Code THEN BEGIN
                            gvarValue := jmdoCodePropertyLookup;
                            jmdoValidateValue(gvarValue);
                        END;
                        IF ("Value Type" = "Value Type"::Decimal) AND ("No. Results" > 1) THEN BEGIN
                            gvarValue := (jfdoPMWOResultsLookup);
                            jmdoValidateValue(gvarValue);
                        END;

                        gtxtValue := FORMAT(gvarValue);
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
                field("Critical Control Point"; "Critical Control Point")
                {
                }
                field("PM Unit of Measure"; "PM Unit of Measure")
                {
                }
                field(gtxtDesiredValue; gtxtDesiredValue)
                {
                    Caption = 'Desired Value';
                    Editable = false;
                }
                field("Value Type"; "Value Type")
                {
                }
                field("No. Results"; "No. Results")
                {
                }
                field("Result Calc. Type"; "Result Calc. Type")
                {

                    trigger OnValidate()
                    begin
                        ResultCalcTypeOnAfterValidate;
                    end;
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
                field("PM Work Order Faults"; "PM Work Order Faults")
                {
                }
                field("PM Fault Possibilities"; "PM Fault Possibilities")
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
        lrecPMWOLine: Record "Work Order Line ELA";
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
                        gtxtDesiredValue := FORMAT(lrecPMProcLine."Date Value");
                    "Value Type"::Time:
                        gtxtDesiredValue := FORMAT(lrecPMProcLine."Time Value");
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
    procedure jfdoPMWOResultsLookup(): Decimal
    var
        lfrmPMWOLineResults: Page "WO Line Results ELA";
        lrecPMWOLineResults: Record "WO Line Result ELA";
    begin
        EXIT(lrecPMWOLineResults.jfdoPMWOResultsLookup(Rec, TRUE));
    end;

    local procedure gtxtValueOnAfterValidate()
    begin
        gvarValue := gtxtValue;

        jmdoValidateValue(gvarValue);
    end;

    local procedure ResultCalcTypeOnAfterValidate()
    begin
        CurrPage.UPDATE;
    end;

    local procedure OnAfterGetCurrRecord()
    begin
        xRec := Rec;
        SetEditable;
        jmdoFormatValue;
    end;
}

