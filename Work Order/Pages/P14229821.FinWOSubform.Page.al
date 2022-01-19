page 14229821 "Fin. WO Subform"
{
    // Copyright Axentia Solutions Corp.  1999-2011.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF14148AC
    //   20110822
    //     remove "Employee Position Code" (legacy Serenic field/table)

    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = Table23019271;

    layout
    {
        area(content)
        {
            repeater()
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
                        IF "Value Type" = "Value Type"::"1" THEN BEGIN
                            jmdoCodePropertyLookup;
                        END;
                        IF ("Value Type" = "Value Type"::"3") AND ("No. Results" > 1) THEN BEGIN
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

        IF "Value Type" <> "Value Type"::"3" THEN BEGIN
            "Decimal MinEditable" := FALSE;
            "Decimal MaxEditable" := FALSE;
            DecimalRoundingPrecisionEditab := FALSE;
        END;
    end;

    [Scope('Internal')]
    procedure jmdoFormatValue()
    var
        lrecPMWOLine: Record "23019271";
        lrecPMProcLine: Record "23019251";
    begin
        "Decimal MinEditable" := "Value Type" = "Value Type"::"3";
        "Decimal MaxEditable" := "Value Type" = "Value Type"::"3";

        CLEAR(gvarValue);
        CLEAR(gvarDesiredValue);

        CLEAR(gtxtValue);
        CLEAR(gtxtDesiredValue);

        IF lrecPMWOLine.GET("PM Work Order No.", "Line No.") THEN BEGIN
            CASE "Value Type" OF
                "Value Type"::"0":
                    BEGIN
                        gtxtValue := FORMAT(lrecPMWOLine."Boolean Value");
                    END;
                "Value Type"::"1":
                    gtxtValue := lrecPMWOLine."Code Value";
                "Value Type"::"2":
                    gtxtValue := lrecPMWOLine."Text Value";
                "Value Type"::"3":
                    gtxtValue := FORMAT(lrecPMWOLine."Decimal Value");
                "Value Type"::"4":
                    BEGIN
                        gtxtValue := FORMAT(lrecPMWOLine."Date Value");
                    END;
            END;
        END ELSE
            gtxtValue := '';

        IF lrecPMProcLine.GET("PM Procedure Code", "PM Proc. Version No.", "Line No.") THEN BEGIN
            IF lrecPMProcLine."PM Measure Code" = "PM Measure Code" THEN BEGIN
                CASE "Value Type" OF
                    "Value Type"::"0":
                        BEGIN
                            gtxtDesiredValue := FORMAT(lrecPMProcLine."Boolean Value");
                        END;
                    "Value Type"::"1":
                        gtxtDesiredValue := lrecPMProcLine."Code Value";
                    "Value Type"::"2":
                        gtxtDesiredValue := lrecPMProcLine."Text Value";
                    "Value Type"::"3":
                        gtxtDesiredValue := FORMAT(lrecPMProcLine."Decimal Value");
                    "Value Type"::"4":
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

    [Scope('Internal')]
    procedure jfdoResultLineLookup()
    var
        lrecFinPMWOLineResult: Record "23019276";
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

