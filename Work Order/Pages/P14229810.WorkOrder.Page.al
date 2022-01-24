page 14229810 "Work Order"
{
    PageType = Document;
    SourceTable = "Work Order Header ELA";

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
                field("Active Version";
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
            part(Lines; "Work Order Subform")
            {
                SubPageLink = "PM Work Order No." = FIELD("PM Work Order No.");
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
            part("PM Work Ord Statistics FactBox"; "PM Work Ord Statistics FactBox")
            {
                ShowFilter = false;
                SubPageLink = "PM Work Order No." = FIELD("PM Work Order No."), "PM Proc. Version No." = FIELD("PM Proc. Version No."), "PM Procedure Code" = FIELD("PM Procedure Code");
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
                    RunObject = Page "WO Comments";
                    RunPageLink = "PM Work Order No." = FIELD("PM Work Order No."), "PM WO Line No." = CONST(0);
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
                        lcduPMWOPost: Codeunit "PM Work Order-Post";
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
                separator(Separator)
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
                    RunObject = Page "PM Work Order Wizard";
                    RunPageLink = "PM Work Order No." = FIELD("PM Work Order No.");
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
                        REPORT.RUN(REPORT :: "PM Work Order Worksheet ELA", TRUE, FALSE, grecPMWOHeader);
                    end;
                }
                action("Report Selection(s)")
                {
                    Caption = 'Report Selection(s)';
                    Image = "Report";

                    // trigger OnAction()
                    // begin
                    //     jfdoPrintReportSelections;
                    // end;
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
        gcduPMVersionMgt: Codeunit "PM Management ELA";
        grecPMWOHeader: Record "Work Order Header ELA";
        JFText0001: Label 'Do you wish to post this PM Work Order?';
        grecWorkCenter: Record "Work Center";
        grecMachineCenter: Record "Machine Center";

    [Scope('Internal')]
    procedure jfdoSetEditable()
    begin
        CLEAR(grecWorkCenter);
        CLEAR(grecMachineCenter);

        IF Type = Type::"Work Center" THEN
            IF grecWorkCenter.GET("No.") THEN;
        IF Type = Type::"Machine Center" THEN BEGIN
            IF grecMachineCenter.GET("No.") THEN;
            IF grecWorkCenter.GET(grecMachineCenter."Work Center No.") THEN;
        END;
    end;
}

