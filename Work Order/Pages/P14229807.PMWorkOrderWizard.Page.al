page 14229807 "PM Work Order Wizard"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    Caption = 'PM Work Order Wizard';
    DataCaptionExpression = jfSetFormCaption();
    DeleteAllowed = false;
    PageType = NavigatePage;
    SourceTable = "Work Order Line ELA";

    layout
    {
        area(content)
        {
            group(Step2)
            {
                Visible = Step2Visible;
                label("Please fill in the values for the Quality Measure:")
                {
                    
                }
                field("PM Measure Code"; "PM Measure Code")
                {
                    Editable = false;
                }
                field(Description; Description)
                {
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("PM Unit of Measure"; "PM Unit of Measure")
                {
                    Editable = false;
                }
                field("Critical Control Point"; "Critical Control Point")
                {
                    Editable = false;
                }
                field("Value Type"; "Value Type")
                {
                    Editable = false;
                }
                field("Decimal Min"; "Decimal Min")
                {
                    Editable = false;
                }
                field("Decimal Max"; "Decimal Max")
                {
                    Editable = false;
                }
                field("Desired Value"; gtxtDesiredValue)
                {
                    Caption = 'Desired Value';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("No. Results"; "No. Results")
                {
                    Editable = false;
                }
                field("Result Value"; gtxtValue)
                {

                    trigger OnAssistEdit()
                    begin
                        CASE "Value Type" OF
                            "Value Type"::Code:
                                BEGIN
                                    gvarValue := jfdoCodePropertyLookup;
                                    jmdoValidateValue(gvarValue);
                                END;
                            "Value Type"::Decimal:
                                BEGIN
                                    IF "No. Results" > 1 THEN BEGIN
                                        gvarValue := (jfdoPMWOResultsLookup);
                                        jmdoValidateValue(gvarValue);
                                    END;
                                END;
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
            }
            group(Step1)
            {
                Visible = Step1Visible;
                label("This wizard helps you to fill out the values in a Quality Audit.")
                {
                    
                }
                label("What Work Order would you like to fill out?")
                {
                    
                }
                field(gcodPMWONo; gcodPMWONo)
                {
                    Caption = 'Work Order No.';
                    TableRelation = "Work Order Header ELA";
                }
            }
            group(Step3)
            {
                Visible = Step3Visible;
                label("The following fields are optional. If you want to complete the document attachment now, click Finish.")
                {
                    
                }
                field(gblnPostWO; gblnPostWO)
                {
                    Caption = 'Post Work Order on Finish';
                    MultiLine = true;
                }
                field(gblnCloseFormOnFinish; gblnCloseFormOnFinish)
                {
                    Caption = 'Close wizard on Finish';
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Back)
            {
                Caption = '< &Back';
                Enabled = BackEnable;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CASE CurrMenuType OF
                        2:
                            BEGIN
                                SetSubMenu(CurrMenuType, FALSE);
                                IF Rec.NEXT(-1) = 0 THEN BEGIN
                                    CurrMenuType := CurrMenuType - 1;
                                    SetSubMenu(CurrMenuType, TRUE);
                                    BackEnable := TRUE;
                                    FinishEnable := TRUE;
                                    CancelEnable := TRUE;
                                    NextEnable := TRUE;
                                END ELSE BEGIN
                                    SetSubMenu(CurrMenuType, TRUE);
                                    BackEnable := TRUE;
                                    FinishEnable := TRUE;
                                    CancelEnable := TRUE;
                                    NextEnable := TRUE;
                                END;
                                SetSubMenu(CurrMenuType, TRUE);
                            END;
                        3:
                            BEGIN
                                SetSubMenu(CurrMenuType, FALSE);
                                CurrMenuType := 1;
                                SetSubMenu(CurrMenuType, TRUE);
                                BackEnable := FALSE;
                                NextEnable := TRUE;
                                FinishEnable := FALSE;
                            END;
                    END;
                end;
            }
            action(Next)
            {
                Caption = '&Next >';
                Enabled = NextEnable;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CASE CurrMenuType OF
                        1:
                            BEGIN
                                SetSubMenu(CurrMenuType, FALSE);
                                IF grecPMWOHeader.GET(gcodPMWONo) THEN BEGIN
                                    Rec.SETRANGE("PM Work Order No.", grecPMWOHeader."PM Work Order No.");
                                    Rec.FIND('-');
                                    CurrMenuType := 2;
                                END ELSE BEGIN
                                    CurrMenuType := 3;
                                END;
                                SetSubMenu(CurrMenuType, TRUE);
                                BackEnable := TRUE;
                                FinishEnable := TRUE;
                            END;

                        2:
                            BEGIN
                                BackEnable := FALSE;
                                NextEnable := FALSE;
                                CancelEnable := FALSE;
                                SetSubMenu(CurrMenuType, FALSE);

                                IF Rec.NEXT(1) = 0 THEN BEGIN
                                    CurrMenuType := CurrMenuType + 1;
                                    SetSubMenu(CurrMenuType, TRUE);

                                    BackEnable := TRUE;
                                    FinishEnable := TRUE;
                                    CancelEnable := TRUE;
                                END ELSE BEGIN
                                    SetSubMenu(CurrMenuType, TRUE);
                                    BackEnable := TRUE;
                                    NextEnable := TRUE;
                                    FinishEnable := TRUE;
                                    CancelEnable := TRUE;
                                END;
                            END;
                    END;
                end;
            }
            action(Finish)
            {
                Caption = '&Finish';
                Enabled = FinishEnable;
                InFooterBar = true;

                trigger OnAction()
                begin

                    MODIFY;
                    Rec.SETRANGE("PM Work Order No.");

                    IF gblnPostWO THEN BEGIN
                        gcduPostPMWO.RUN(grecPMWOHeader);
                    END;

                    IF gblnCloseFormOnFinish THEN
                        CurrPage.CLOSE
                    ELSE BEGIN
                        SetSubMenu(CurrMenuType, FALSE);
                        CurrMenuType := 1;
                        SetSubMenu(CurrMenuType, TRUE);
                    END;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        OnAfterGetCurrRecord;
    end;

    trigger OnClosePage()
    begin
        IF Complete = FALSE THEN;
    end;

    trigger OnInit()
    begin
        NextEnable := TRUE;
        CancelEnable := TRUE;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        OnAfterGetCurrRecord;
    end;

    trigger OnOpenPage()
    begin

        jfdoSetPMWONo;
        FormWidth := CancelXPos + CancelWidth + 220;
        FrmXPos := ROUND((FrmWidth - FormWidth) / 2, 1) + FrmXPos;
        FrmYPos := 3000;
        FrmHeight := CancelYPos + CancelHeight + 220;
        FrmWidth := FormWidth;

        Complete := FALSE;

        CurrMenuType := 1;
        SetSubMenu(CurrMenuType, TRUE);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        IF CloseAction IN [ACTION::Cancel, ACTION::LookupCancel] THEN
            CancelOnPush;
    end;

    var
        grecPMWOHeader: Record "Work Order Header ELA";
        gcduPostPMWO: Codeunit "PM Work Order-Post";
        gcodPMWONo: Code[20];
        gvarValue: Variant;
        gvarDesiredValue: Variant;
        gblnPostWO: Boolean;
        gblnCloseFormOnFinish: Boolean;
        Complete: Boolean;
        CurrMenuType: Integer;
        EntryNo: Integer;
        FormWidth: Integer;
        AppDescription: Label 'This wizard helps you to fill out Quality Audits.';
        BlankNo: Label 'You must fill in the %1 field.';
        BlankSubject: Label 'You must fill in the Subject of the communication.';
        BlankTemplate: Label 'You must fill in the Template that you would like to use.';
        MasterDescription: Label 'This wizard helps you to fill out the values in a Quality Audit.';
        Step2Description: Label 'Please fill in the values for the Quality Measure:';
        Step3Description: Label 'The following fields are optional. If you want to complete the document attachment now, click Finish.';
        TempTransDocError: Label 'There is not a document created for the %1.\You will either need to:\    - Specify a different %2 and/or %3 OR\    - Go to the %4s form and create a document (%5: %6\      and %7: %8)';
        QuestionOne: Label 'What Work Order would you like to fill out?';
        QuestionTwo: Label 'Give the attachment a description.';
        gtxtValue: Text[250];
        gtxtDesiredValue: Text[250];
        CancelXPos: Integer;
        CancelYPos: Integer;
        CancelHeight: Integer;
        CancelWidth: Integer;
        FrmXPos: Integer;
        FrmYPos: Integer;
        FrmHeight: Integer;
        FrmWidth: Integer;
        [InDataSet]
        BackEnable: Boolean;
        [InDataSet]
        FinishEnable: Boolean;
        [InDataSet]
        CancelEnable: Boolean;
        [InDataSet]
        NextEnable: Boolean;
        [InDataSet]
        Step1Visible: Boolean;
        [InDataSet]
        Step2Visible: Boolean;
        [InDataSet]
        Step3Visible: Boolean;

    [Scope('Internal')]
    procedure SetSubMenu(MenuType: Integer; Visible: Boolean)
    begin
        CASE MenuType OF
            1:
                BEGIN
                    Step1Visible := Visible;
                    BackEnable := FALSE;
                    FinishEnable := FALSE;
                END;
            2:
                BEGIN
                    Step2Visible := Visible;
                    IF Visible THEN;
                END;
            3:
                BEGIN
                    Step3Visible := Visible;
                    IF Visible THEN BEGIN
                        gblnPostWO := TRUE;
                        gblnCloseFormOnFinish := TRUE;
                        NextEnable := FALSE;
                    END ELSE BEGIN
                        gblnPostWO := FALSE;
                        gblnCloseFormOnFinish := FALSE;
                    END;
                END;
        END;
    end;

    [Scope('Internal')]
    procedure jfdoFormatValue()
    var
        lrecPMWOLine: Record "Work Order Line ELA";
        lrecPMSetupLine: Record "PM Procedure Line ELA";
    begin

        CLEAR(gvarValue);
        CLEAR(gvarDesiredValue);

        CLEAR(gtxtValue);
        CLEAR(gtxtDesiredValue);

        IF lrecPMWOLine.GET("PM Work Order No.", "Line No.") THEN BEGIN
            CASE "Value Type" OF
                "Value Type"::Boolean:
                    gvarValue := FORMAT(lrecPMWOLine."Boolean Value");
                "Value Type"::Code:
                    gvarValue := lrecPMWOLine."Code Value";
                "Value Type"::Text:
                    gvarValue := lrecPMWOLine."Text Value";
                "Value Type"::Decimal:
                    gvarValue := lrecPMWOLine."Decimal Value";
                "Value Type"::Date:
                    gvarValue := FORMAT(lrecPMWOLine."Date Value");
                "Value Type"::Time:
                    gvarValue := FORMAT(lrecPMWOLine."Time Value");
            END;
        END ELSE
            gvarValue := '';

        IF lrecPMSetupLine.GET("PM Procedure Code", "PM Proc. Version No.", "Line No.") THEN BEGIN
            IF lrecPMSetupLine."PM Measure Code" = "PM Measure Code" THEN BEGIN
                CASE "Value Type" OF
                    "Value Type"::Boolean:
                        gvarDesiredValue := FORMAT(lrecPMSetupLine."Boolean Value");
                    "Value Type"::Code:
                        gvarDesiredValue := lrecPMSetupLine."Code Value";
                    "Value Type"::Text:
                        gvarDesiredValue := lrecPMSetupLine."Text Value";
                    "Value Type"::Decimal:
                        gvarDesiredValue := lrecPMSetupLine."Decimal Value";
                    "Value Type"::Date:
                        gvarDesiredValue := FORMAT(lrecPMSetupLine."Date Value");
                    "Value Type"::Time:
                        gvarDesiredValue := FORMAT(lrecPMSetupLine."Time Value");
                END;
            END;
        END ELSE
            gvarDesiredValue := '';

        gtxtValue := FORMAT(gvarValue);
        gtxtDesiredValue := FORMAT(gvarDesiredValue);
    end;

    [Scope('Internal')]
    procedure jfdoCodePropertyLookup(): Code[10]
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
        lfrmWOLineResults: Page "WO Line Results ELA";
        lrecWOLineResults: Record "WO Line Result ELA";
    begin
        EXIT(lrecWOLineResults.jfdoPMWOResultsLookup(Rec, TRUE));
    end;

    [Scope('Internal')]
    procedure jfdoSetPMWONo()
    begin
        IF GETFILTER("PM Work Order No.") <> '' THEN
            gcodPMWONo := GETFILTER("PM Work Order No.");
    end;

    [Scope('Internal')]
    procedure jfSetFormCaption(): Text[260]
    var
        lrecWOHeader: Record "Work Order Header ELA";
        ltxtFormCaption: Text[50];
    begin
        IF lrecWOHeader.GET(gcodPMWONo) THEN BEGIN
            ltxtFormCaption := lrecWOHeader.Description;
        END;

        EXIT(ltxtFormCaption);
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
        jfdoFormatValue;
    end;

    local procedure CancelOnPush()
    begin
        Complete := FALSE;
    end;
}

