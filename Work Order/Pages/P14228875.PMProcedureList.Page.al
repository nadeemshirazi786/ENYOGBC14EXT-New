page 23019287 "PM Procedure List"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF9163SHR 20100916 - Add new function jfGetSelectionFilter
    // JF43786SHR 20141030 - set type on link to Calc. Methods action

    CardPageID = "PM Procedure";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SaveValues = true;
    SourceTable = Table23019250;

    layout
    {
        area(content)
        {
            repeater()
            {
                Editable = false;
                field(Code; Code)
                {
                }
                field(Description; Description)
                {
                }
                field("PM Group Code"; "PM Group Code")
                {
                }
                field("Contains Critical Control"; "Contains Critical Control")
                {
                }
                field("Person Responsible"; "Person Responsible")
                {
                }
                field(Status; Status)
                {
                }
                field("Maintenance Time"; "Maintenance Time")
                {
                }
                field(Type; Type)
                {
                }
                field("Starting Date"; "Starting Date")
                {
                }
                field("Maintenance UOM"; "Maintenance UOM")
                {
                }
                field("Version No."; "Version No.")
                {
                }
                field(gcduPMVersionMgt.GetActiveVersion(Code);
                    gcduPMVersionMgt.GetActiveVersion(Code))
                {
                    Caption = 'Active Version';
                }
                field("Work Order Freq."; "Work Order Freq.")
                {
                }
            }
        }
        area(factboxes)
        {
            part(; 23019293)
            {
                ShowFilter = false;
                SubPageLink = Code = FIELD (Code),
                              Version No.=FIELD(Version No.);
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("<Action1000000020>")
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
            group("<Action1101769039>")
            {
                Caption = 'F&unctions';
                action("<Action1101769046>")
                {
                    Caption = 'Create New Version';
                    Image = BOMVersions;
                    Promoted = true;
                    PromotedCategory = New;

                    trigger OnAction()
                    begin
                        gcduPMVersionMgt.CreateNewVersion(Rec);
                    end;
                }
                separator()
                {
                }
                action("<Action1101769044>")
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
            group("<Action1102631000>")
            {
                Caption = '&Print';
                action("<Action1102631002>")
                {
                    Caption = 'PM Procedure';
                    Image = ProjectToolsProjectMaintenance;
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
                action("<Action1102631003>")
                {
                    Caption = 'Report Selection(s)';
                    Image = SelectReport;

                    trigger OnAction()
                    begin
                        jfdoPrintReportSelections;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        MarkRecords;
    end;

    var
        gcduPMVersionMgt: Codeunit "23019250";
        gblnShowActiveOnly: Boolean;
        grecPMProcedure: Record "23019250";

    [Scope('Internal')]
    procedure MarkRecords()
    begin
        IF gblnShowActiveOnly THEN BEGIN
          FIND('-');
          REPEAT
            IF "Version No." = gcduPMVersionMgt.GetActiveVersion(Code) THEN
              Rec.MARK(TRUE);
          UNTIL Rec.NEXT = 0;
          MARKEDONLY(TRUE);
        END ELSE
          MARKEDONLY(FALSE);
    end;

    local procedure gblnShowActiveOnlyOnPush()
    begin
        MarkRecords;
    end;

    [Scope('Internal')]
    procedure jfGetSelectionFilter() SelectionFilter: Code[80]
    var
        lrecPMProcedure: Record "23019250";
    begin
        //<JF9163SHR>
        CurrPage.SETSELECTIONFILTER(lrecPMProcedure);
        lrecPMProcedure.SETCURRENTKEY(Code,"Version No.");
        IF lrecPMProcedure.COUNT > 0 THEN BEGIN
          lrecPMProcedure.FIND('-');
          SelectionFilter := lrecPMProcedure.Code;
        END;

        EXIT(SelectionFilter);
        //</JF9163SHR>
    end;
}

