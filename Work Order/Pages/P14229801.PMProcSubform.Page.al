page 14229801 "PM Proc. Subform ELA"
{
   
    AutoSplitKey = true;
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "PM Procedure Line ELA";

    layout
    {
        area(content)
        {
            repeater()
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
                field("Value Type"; "Value Type")
                {
                }
                field("PM Unit of Measure"; "PM Unit of Measure")
                {
                }
                field("Desired Value"; gtxtValue)
                {
                    Caption = 'Desired Value';

                    trigger OnAssistEdit()
                    begin
                        IF "Value Type" = "Value Type"::Code THEN BEGIN
                            gvarValue := jmdoCodePropertyLookup;
                            jmdoValidateValue(gvarValue);

                            gtxtValue := FORMAT(gvarValue);
                        END;
                    end;

                    trigger OnValidate()
                    begin
                        gtxtValueOnAfterValidate;
                    end;
                }
                field("Critical Control Point"; "Critical Control Point")
                {
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
                field("PM Item Consumption"; "PM Item Consumption")
                {
                }
                field("PM Resources"; "PM Resources")
                {
                }
                field("PM Comments"; "PM Comments")
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
        gvarValue: Variant;
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
        lrecPMProcLine: Record "23019251";
    begin
        "Decimal MinEditable" := "Value Type" = "Value Type"::Decimal;
        "Decimal MaxEditable" := "Value Type" = "Value Type"::Decimal;

        CLEAR(gvarValue);

        CLEAR(gtxtValue);

        IF lrecPMProcLine.GET("PM Procedure Code", "Version No.", "Line No.") THEN BEGIN
            CASE "Value Type" OF
                "Value Type"::Boolean:
                    BEGIN
                        gtxtValue := FORMAT(lrecPMProcLine."Boolean Value");
                    END;
                "Value Type"::Code:
                    gtxtValue := lrecPMProcLine."Code Value";
                "Value Type"::Text:
                    gtxtValue := lrecPMProcLine."Text Value";
                "Value Type"::Decimal:
                    gtxtValue := FORMAT(lrecPMProcLine."Decimal Value");
                "Value Type"::Date:
                    gtxtValue := FORMAT(lrecPMProcLine."Date Value");
                "Value Type"::Time:
                    gtxtValue := FORMAT(lrecPMProcLine."Time Value");
            END;
        END;

        gvarValue := FORMAT(gtxtValue);
    end;

    [Scope('Internal')]
    procedure jmdoCodePropertyLookup(): Code[10]
    var
        lfrmQMCodeValues: Page "23019256";
        lrecQMCodeValue: Record "23019256";
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

    local procedure gtxtValueOnAfterValidate()
    begin
        gvarValue := gtxtValue;

        jmdoValidateValue(gvarValue);
        CurrPage.UPDATE(TRUE);
    end;

    local procedure OnAfterGetCurrRecord()
    begin
        xRec := Rec;
        SetEditable;
        jmdoFormatValue;
    end;
}

