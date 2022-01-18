page 23019288 "PM Work Order List"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    CardPageID = "Work Order";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SaveValues = true;
    SourceTable = Table23019260;

    layout
    {
        area(content)
        {
            repeater()
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
                field(gcduPMVersionMgt.GetActiveVersion("PM Procedure Code");
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
            part(; 23019294)
            {
                ShowFilter = false;
                SubPageLink = Field1 = FIELD (Field1),
                              Field2 = FIELD (Field2),
                              Field3 = FIELD (Field3);
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
                    RunObject = Page 23019264;
                    RunPageLink = PM Work Order No.=FIELD(Field1),
                                  PM WO Line No.=CONST(0);
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
                        lcduPMWOPost: Codeunit "23019252";
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
                    RunObject = Page 23019257;
                                    RunPageLink = PM Work Order No.=FIELD(Field1);
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
                        REPORT.RUN(REPORT :: Report23019251, TRUE, FALSE, grecPMWOHeader);
                    end;
                }
                action("<Action1102631006>")
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

    var
        gcduPMVersionMgt: Codeunit "23019250";
        JFText0001: Label 'Do you wish to post this PM Work Order?';
        grecPMWOHeader: Record "23019260";
}

