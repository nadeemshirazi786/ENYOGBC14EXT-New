page 14229834 "PM Procedure List"
{
    CardPageID = "PM Procedure ELA";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SaveValues = true;
    SourceTable = "PM Procedure Header ELA";

    layout
    {
        area(content)
        {
            repeater(General)
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
                field("Active Version";
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
            part("PM Sched. Statistics FactBox"; "PM Sched. Statistics FactBox")
            {
                ShowFilter = false;
                SubPageLink = Code = FIELD(Code),
                              "Version No."=FIELD("Version No.");
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
                    RunObject = Page "PM Proc. Comments";
                    RunPageLink = "PM Procedure Code"=FIELD(Code),
                                  "Version No."=FIELD("Version No."),
                                  "PM Procedure Line No."=CONST(0);
                }
                action("<Action1101769017>")
                {
                    Caption = 'Open Work Orders';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "PM Work Order List";
                                    RunPageLink = "PM Procedure Code"=FIELD(Code);
                }
                action("<Action1101769014>")
                {
                    Caption = 'Finished Work Orders';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Fin. Work Order List";
                                    RunPageLink = "PM Procedure Code"=FIELD(Code);
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
                
                action("<Action1101769044>")
                {
                    Caption = 'Calc. Methods';
                    Image = ListPage;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "PM Calc. Methods";
                                    RunPageLink = "PM Procedure Code"=FIELD(Code),
                                  "Version No."=FIELD("Version No."),
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
                        REPORT.RUN(REPORT :: "PM Procedure ELA", TRUE, FALSE, grecPMProcedure);
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
        gcduPMVersionMgt: Codeunit "PM Management ELA";
        gblnShowActiveOnly: Boolean;
        grecPMProcedure: Record "PM Procedure Header ELA";

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
        lrecPMProcedure: Record "PM Procedure Header ELA";
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

