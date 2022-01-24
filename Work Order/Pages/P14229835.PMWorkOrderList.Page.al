page 14229835 "PM Work Order List"
{
    CardPageID = "Work Order";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SaveValues = true;
    SourceTable = "Work Order Header ELA";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("PM Work Order No."; "PM Work Order No.")
                {
                }
                field("PM Procedure Code"; "PM Procedure Code")
                {
                    Visible = false;
                }
                field("PM Proc. Version No."; "PM Proc. Version No.")
                {
                    Visible = false;
                }
                field(Description; Description)
                {
                }
                field("Active Version";
                    gcduPMVersionMgt.GetActiveVersion("PM Procedure Code"))
                {
                    Caption = 'Active Version';
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
                field("Contains Critical Control"; "Contains Critical Control")
                {
                }
                field("Person Responsible"; "Person Responsible")
                {
                }
                field("Work Order Date"; "Work Order Date")
                {
                }
                field("Maintenance Time"; "Maintenance Time")
                {
                }
                field("Maintenance UOM"; "Maintenance UOM")
                {
                }
            }
        }
        area(factboxes)
        {
            part("PM Work Ord Statistics FactBox"; "PM Work Ord Statistics FactBox")
            {
                ShowFilter = false;
                SubPageLink = "PM Work Order No." = FIELD ("PM Work Order No."),
                              "PM Proc. Version No." = FIELD ("PM Proc. Version No."),
                              "PM Procedure Code" = FIELD("PM Procedure Code");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("<Action1000000020>")
            {
                Caption = 'PM Work Order';
                action("<Action1101769006>")
                {
                    Caption = 'Comments';
                    Image = ListPage;
                    RunObject = Page "WO Comments";
                    RunPageLink = "PM Work Order No."=FIELD("PM Work Order No."),
                                  "PM WO Line No."=CONST(0);
                }
            }
        }
        area(processing)
        {
            group("<Action1101769057>")
            {
                Caption = 'P&osting';
                action("<Action1101769058>")
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
            group("<Action1101769045>")
            {
                Caption = 'F&unctions';
                action("<Action1102631007>")
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
                action("<Action1102631009>")
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
                action("<Action23019000>")
                {
                    Caption = 'Work Order Wizard';
                    Image = DocumentEdit;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "PM Work Order Wizard";
                                    RunPageLink = "PM Work Order No."=FIELD("PM Work Order No.");
                }
            }
            group("<Action1102631004>")
            {
                Caption = '&Print';
                action("<Action1102631005>")
                {
                    Caption = 'PM Work Order Worksheet';
                    Image = SuggestGrid;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        grecPMWOHeader.SETRANGE("PM Work Order No.", "PM Work Order No.");
                        REPORT.RUN(REPORT :: "PM Work Order Worksheet ELA", TRUE, FALSE, grecPMWOHeader);
                    end;
                }
                // action("<Action1102631006>")
                // {
                //     Caption = 'Report Selection(s)';
                //     Image = "Report";

                //     trigger OnAction()
                //     begin
                //         jfdoPrintReportSelections;
                //     end;
                // }
            }
        }
    }

    var
        gcduPMVersionMgt: Codeunit "PM Management ELA";
        JFText0001: Label 'Do you wish to post this PM Work Order?';
        grecPMWOHeader: Record "Work Order Header ELA";
}

