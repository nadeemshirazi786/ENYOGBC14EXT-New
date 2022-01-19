page 14229810 "Work Order"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF00081MG
    //   20071030 - hide JF attachment functionality
    // 
    // JF00017AC
    //   20080514
    //     global codeunit variable for posting consumption was caching whse ledger entry;
    //     was bonking on posting a 2nd document if anyone else posted whse in the system in the meantime
    //     solution: use local variable for WO post instead
    // 
    // JF3883MG
    //   20090702 - remove all JF attachment functionality (replaced by Links in v5.0)
    // 
    // JF11393SHR
    //   20110117 - Add Posting Date

    PageType = Document;
    SourceTable = Table23019260;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("PM Work Order No."; "PM Work Order No.")
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
                field("No."; "No.")
                {
                }
                field("Evaluated At Qty."; "Evaluated At Qty.")
                {
                    Caption = 'Current Mileage';
                }
                field("Work Order Date"; "Work Order Date")
                {
                }
                field("Person Responsible"; "Person Responsible")
                {
                }
                field("Location Code"; "Location Code")
                {
                }
                field(Type; Type)
                {
                    Visible = false;

                    trigger OnValidate()
                    begin
                        jfdoSetEditable;
                    end;
                }
                field(Name; Name)
                {
                }
                field("PM Group Code"; "PM Group Code")
                {
                }
                field(Cycles; Cycles)
                {
                    Caption = 'Most Recent Mileage per GPS';
                    Editable = false;
                }
                field("Cycles at Last Work Order"; "Cycles at Last Work Order")
                {
                    Caption = 'Mileage at Last Work Order';
                    Editable = false;
                }
                field("Serial No."; "Serial No.")
                {
                    Visible = false;
                }
                field("PM Procedure Code"; "PM Procedure Code")
                {
                    Editable = false;
                }
                field("PM Proc. Version No."; "PM Proc. Version No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field(gcduPMVersionMgt.GetActiveVersion("PM Procedure Code");
                    gcduPMVersionMgt.GetActiveVersion("PM Procedure Code"))
                {
                    Caption = 'Active Version';
                    Editable = false;
                    Visible = false;
                }
                field("Contains Critical Control"; "Contains Critical Control")
                {
                    Visible = false;
                }
                field("PM Scheduling Type"; "PM Scheduling Type")
                {

                    trigger OnValidate()
                    begin
                        jfdoSetEditable;
                    end;
                }
                field("Work Order Freq."; "Work Order Freq.")
                {
                }
                field("Evaluation Qty."; "Evaluation Qty.")
                {
                }
            }
            part(; 23019261)
            {
                SubPageLink = PM Work Order No.=FIELD(Field1);
            }
            group(Scheduling)
            {
                Caption = 'Scheduling';
                field("Posting Date"; "Posting Date")
                {
                }
                field(CapUOM1; grecWorkCenter."Unit of Measure Code")
                {
                    Caption = 'Evaluation UOM';
                    Editable = false;
                }
                field("Schedule at %"; "Schedule at %")
                {
                }
                field("Maintenance Time"; "Maintenance Time")
                {
                }
                field(MaintUOM; "Maintenance UOM")
                {
                    Caption = 'Maintenance UOM';
                }
                field(CapUOM2; grecWorkCenter."Unit of Measure Code")
                {
                    Caption = 'Evaluated At UOM';
                    Editable = false;
                }
            }
        }
        area(factboxes)
        {
            part(; 23019294)
            {
                ShowFilter = false;
                SubPageLink = Field1 = FIELD(Field1),
                              Field2 = FIELD(Field2),
                              Field3 = FIELD(Field3);
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("PM Work Order")
            {
                Caption = 'PM Work Order';
                action("<Action1101769006>")
                {
                    Caption = 'Comments';
                    Image = ListPage;
                    RunObject = Page 23019264;
                    RunPageLink = PM Work Order No.=FIELD(Field1),
                                  PM WO Line No.=CONST(0);
                }
            }
        }
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                action(Post)
                {
                    Caption = 'Post';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        lcduPMWOPost: Codeunit "23019252";
                    begin
                        IF CONFIRM(JFText0001, TRUE) THEN
                          lcduPMWOPost.RUN(Rec);
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("<Action1101769001>")
                {
                    Caption = 'Get PM Procedure';
                    Image = CopyFromTask;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        DefaultPMProcedure;
                    end;
                }
                separator()
                {
                }
                action("Create/Update Calendar Absence")
                {
                    Caption = 'Create/Update Calendar Absence';
                    Image = WorkCenterAbsence;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        gcduPMVersionMgt.CreateAbsence(Rec);
                    end;
                }
                action("Delete Calendar Absence")
                {
                    Caption = 'Delete Calendar Absence';
                    Image = WorkCenterAbsence;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        gcduPMVersionMgt.DeleteAbsence(Rec);
                    end;
                }
                action("Work Order Wizard")
                {
                    Caption = 'Work Order Wizard';
                    Image = DocumentEdit;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page 23019257;
                                    RunPageLink = PM Work Order No.=FIELD(Field1);
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                action("PM Work Order Worksheet")
                {
                    Caption = 'PM Work Order Worksheet';
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        grecPMWOHeader.SETRANGE("PM Work Order No.", "PM Work Order No.");
                        REPORT.RUN(REPORT :: Report23019251, TRUE, FALSE, grecPMWOHeader);
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

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        jfdoSetEditable;
    end;

    trigger OnOpenPage()
    begin
        SETRANGE("PM Work Order No.");
    end;

    var
        gcduPMVersionMgt: Codeunit "23019250";
        grecPMWOHeader: Record "23019260";
        JFText0001: Label 'Do you wish to post this PM Work Order?';
        grecWorkCenter: Record "99000754";
        grecMachineCenter: Record "99000758";

    [Scope('Internal')]
    procedure jfdoSetEditable()
    begin
        CLEAR(grecWorkCenter);
        CLEAR(grecMachineCenter);

        IF Type = Type :: "2" THEN
          IF grecWorkCenter.GET("No.") THEN;
        IF Type = Type :: "1" THEN BEGIN
          IF grecMachineCenter.GET("No.") THEN;
          IF grecWorkCenter.GET(grecMachineCenter."Work Center No.") THEN;
        END;
    end;
}

