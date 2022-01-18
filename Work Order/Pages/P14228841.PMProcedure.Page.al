page 23019250 "PM Procedure"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF00081MG
    //   20071030 - hide JF attachment functionality
    // 
    // JF3883MG
    //   20090702 - remove all JF attachment functionality (replaced by Links in v5.0)
    // JF43483SHR 20141014 - modified jfdoSetEditable
    // JF43786SHR 20141030 - set type on link to Calc. Methods action

    PageType = Document;
    SourceTable = Table23019250;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Code; Code)
                {

                    trigger OnAssistEdit()
                    begin
                        IF AssistEdit(xRec) THEN
                            CurrPage.UPDATE;
                    end;
                }
                field(Description; Description)
                {
                }
                field("PM Group Code"; "PM Group Code")
                {
                }
                field(Type; Type)
                {
                }
                field("No."; "No.")
                {
                }
                field(Name; Name)
                {
                }
                field("Serial No."; "Serial No.")
                {
                }
                field(Status; Status)
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Version No."; "Version No.")
                {
                }
                field("Starting Date"; "Starting Date")
                {
                }
                field("Person Responsible"; "Person Responsible")
                {
                }
                field("Contains Critical Control"; "Contains Critical Control")
                {
                }
                field("PM Work Order No. Series"; "PM Work Order No. Series")
                {
                }
            }
            part(; 23019251)
            {
                SubPageLink = PM Procedure Code=FIELD(Code),
                              Version No.=FIELD(Version No.);
            }
            group(Scheduling)
            {
                Caption = 'Scheduling';
                field("PM Scheduling Type";"PM Scheduling Type")
                {
                    Editable = "PM Scheduling TypeEditable";

                    trigger OnValidate()
                    begin
                        jfdoSetEditable;
                    end;
                }
                field("Work Order Freq.";"Work Order Freq.")
                {
                    Editable = "Work Order Freq.Editable";
                }
                group()
                {
                    field("Evaluation Qty.";"Evaluation Qty.")
                    {
                        Editable = "Evaluation Qty.Editable";
                    }
                    field(CapUOM1;grecWorkCenter."Unit of Measure Code")
                    {
                        Caption = 'Evaluation UOM';
                        Editable = false;
                    }
                }
                field("Schedule at %";"Schedule at %")
                {
                    Editable = "Schedule at %Editable";
                }
                field("Maintenance Time";"Maintenance Time")
                {
                }
                field(MaintUOM;"Maintenance UOM")
                {
                    Caption = 'Maintenance UOM';
                }
                field("Multiple Calc. Methods";"Multiple Calc. Methods")
                {

                    trigger OnValidate()
                    begin
                        jfdoSetEditable;
                    end;
                }
            }
        }
        area(factboxes)
        {
            part(;23019293)
            {
                ShowFilter = false;
                SubPageLink = Code=FIELD(Code),
                              Version No.=FIELD(Version No.);
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("PM Procedure")
            {
                Caption = 'PM Procedure';
                action("<Action1101769006>")
                {
                    Caption = 'Comments';
                    Image = ListPage;
                    RunObject = Page 23019258;
                                    RunPageLink = PM Procedure Code=FIELD(Code),
                                  Version No.=FIELD(Version No.),
                                  PM Procedure Line No.=CONST(0);
                }
                action("<Action1101769017>")
                {
                    Caption = 'Open Work Orders';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page 23019288;
                                    RunPageLink = Field3=FIELD(Code);
                }
                action("<Action1101769014>")
                {
                    Caption = 'Finished Work Orders';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page 23019289;
                                    RunPageLink = Field3=FIELD(Code);
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("<Action1101769011>")
                {
                    Caption = 'Go to Active Version';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        //Rec.GET(Code,gcduPMVersionMgt.GetActiveVersion(Code));
                    end;
                }
                separator()
                {
                }
                action("Create New Version")
                {
                    Caption = 'Create New Version';
                    Image = BOMVersions;
                    Promoted = true;
                    PromotedCategory = New;

                    trigger OnAction()
                    begin
                        //gcduPMVersionMgt.CreateNewVersion(Rec);
                    end;
                }
                separator()
                {
                }
                action("Calc. Methods")
                {
                    Caption = 'Calc. Methods';
                    Image = ListPage;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page 23019277;
                                    RunPageLink = PM Procedure Code=FIELD(Code),
                                  Version No.=FIELD(Version No.),
                                  Type=FIELD(Type);
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                action("PM Procedure")
                {
                    Caption = 'PM Procedure';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        grecPMProcedure.SETRANGE(Code, Code);
                        grecPMProcedure.SETRANGE("Version No.", "Version No.");
                        REPORT.RUN(REPORT :: Report23019250, TRUE, FALSE, grecPMProcedure);
                    end;
                }
                action("Report Selection(s)")
                {
                    Caption = 'Report Selection(s)';
                    Image = "Report";

                    trigger OnAction()
                    begin
                        jfdoPrintReportSelections;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        jfdoSetEditable;
    end;

    trigger OnInit()
    begin
        "Work Order Freq.Editable" := TRUE;
        "Evaluation Qty.Editable" := TRUE;
        "Schedule at %Editable" := TRUE;
        "PM Scheduling TypeEditable" := TRUE;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        jfdoSetEditable;
    end;

    var
        grecPMProcedure: Record "23019250";
        grecWorkCenter: Record "99000754";
        grecMachineCenter: Record "99000758";
        grecFixedAsset: Record "5600";
        gdecCyclesPct: Decimal;
        [InDataSet]
        "PM Scheduling TypeEditable": Boolean;
        [InDataSet]
        "Schedule at %Editable": Boolean;
        [InDataSet]
        "Evaluation Qty.Editable": Boolean;
        [InDataSet]
        "Work Order Freq.Editable": Boolean;

    [Scope('Internal')]
    procedure jfdoSetEditable()
    var
        lblnEvalQtyEdit: Boolean;
        lblnCapUOM1Visible: Boolean;
        lblnCapUOM2Visible: Boolean;
    begin
        "PM Scheduling TypeEditable" := NOT "Multiple Calc. Methods";
        "Work Order Freq.Editable" := NOT "Multiple Calc. Methods";
        "Evaluation Qty.Editable" := NOT "Multiple Calc. Methods";
        "Schedule at %Editable" := NOT "Multiple Calc. Methods";

        "Work Order Freq.Editable" := "PM Scheduling Type" = "PM Scheduling Type"::Calendar;

        lblnEvalQtyEdit :=
          ("PM Scheduling Type" = "PM Scheduling Type" :: Cycles) OR
          ("PM Scheduling Type" = "PM Scheduling Type" :: "Qty. Produced") OR
          ("PM Scheduling Type" = "PM Scheduling Type" :: "Run Time") OR
          ("PM Scheduling Type" = "PM Scheduling Type" :: "Stop Time");

        "Evaluation Qty.Editable" := lblnEvalQtyEdit;

        IF Type = Type :: "Work Center" THEN
          IF grecWorkCenter.GET("No.") THEN;
        IF Type = Type :: "Machine Center" THEN BEGIN
          IF grecMachineCenter.GET("No.") THEN;
          IF grecWorkCenter.GET(grecMachineCenter."Work Center No.") THEN;
        END;
    end;
}

