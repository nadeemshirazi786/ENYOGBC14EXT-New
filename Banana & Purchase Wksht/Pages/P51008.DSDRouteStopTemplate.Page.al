page 51008 "DSD Route Stop Template"
{
    ApplicationArea = all;
    UsageCategory = Lists;
    PageType = ListPlus;
    SaveValues = true;
    SourceTable = "DSD Route Stop Template";

    layout
    {
        area(content)
        {
            group(ctrlTabs)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                }
                field(goptWeekday; goptWeekday)
                {
                    Caption = 'Weekday';

                    trigger OnValidate()
                    begin
                        goptWeekdayOnAfterValidate;
                    end;
                }
                field(textboxRoute1; gcodRoute1)
                {
                    Caption = 'Route 1';
                    TableRelation = Location;

                    trigger OnValidate()
                    begin
                        gcodRoute1OnAfterValidate;
                    end;
                }
                field("Start Date"; "Start Date")
                {
                }
                field("End Date"; "End Date")
                {
                }
            }
            part(subform; "DSD Route Stop Tmplt. Subform")
            {
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(ctrlMenuTemplate)
            {
                Caption = 'Template';
                action("Route Overview")
                {
                    Caption = 'Route Overview';
                    ShortCutKey = 'Shift+F11';

                    trigger OnAction()
                    var
                        lpagOverview: Page "DSD Templt. Stop Over.";
                    begin
                        lpagOverview.jfSetWeekday(Code, goptWeekday);
                        lpagOverview.Run;
                    end;
                }
            }
        }
        area(processing)
        {
            action(ctrlButtUp)
            {
                Caption = 'Move Line Up';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    lrecMoveMe: Record "DSD Route Stop Tmplt. Detail";
                begin
                    CurrPage.subform.PAGE.GetRecord(lrecMoveMe);

                    jxSwap(lrecMoveMe, '<', 1);
                end;
            }
            action(ctrlButtDown)
            {
                Caption = 'Move Line Down';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    lrecMoveMe: Record "DSD Route Stop Tmplt. Detail";
                begin
                    CurrPage.subform.PAGE.GetRecord(lrecMoveMe);

                    jxSwap(lrecMoveMe, '>', 1);
                end;
            }
            group(ctrlMenuFunctions)
            {
                Caption = 'Functions';
                action("Apply New Sequence")
                {
                    Caption = 'Apply New Sequence';

                    trigger OnAction()
                    begin
                        jxApplySequence(1);

                        CurrPage.subform.PAGE.jxUpdate;
                    end;
                }
                action("Activate DSD Day")
                {
                    Caption = 'Activate DSD Day';
                    Visible = false;

                    trigger OnAction()
                    begin
                    end;
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                action("Driver's Manifest")
                {
                    Caption = 'Driver''s Manifest';

                    trigger OnAction()
                    var
                        lrecDSDRouteStopTemplate: Record "DSD Route Stop Template";
                        lrecDSDRouteStopTmpltDetail: Record "DSD Route Stop Tmplt. Detail";
                        lrptDSDDriversManifest: Report "DSD Drivers Manifest";
                    begin

                        lrecDSDRouteStopTemplate.SetFilter(Code, Code);
                        lrecDSDRouteStopTmpltDetail.SetFilter(Route, gcodRoute1);
                        lrptDSDDriversManifest.SetTableView(lrecDSDRouteStopTemplate);
                        lrptDSDDriversManifest.SetTableView(lrecDSDRouteStopTmpltDetail);
                        lrptDSDDriversManifest.RunModal;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin

        jxUpdateSubforms;
    end;

    trigger OnInit()
    var
        lrecLocation: Record Location;
    begin
        if gcodRoute1 = '' then begin
            gcodRoute1 := lrecLocation.Code;
        end;

    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        jxUpdateSubforms;
    end;

    trigger OnOpenPage()
    begin
        jxUpdateSubforms;
    end;

    var
        gcodRoute1: Code[10];
        gcodRoute2: Code[10];
        goptWeekday: Enum Weekdays;
        jfText030: Label '%1 may not be %2';
        gintHeight: Integer;
        gintWidth: Integer;

    [Scope('Internal')]
    procedure jxSwap(var precMoveMe: Record "DSD Route Stop Tmplt. Detail"; ptxtDirection: Text[1]; pintSubformIndex: Integer)
    var
        lrecTarget: Record "DSD Route Stop Tmplt. Detail";
        lrecTEMP: Record "DSD Route Stop Tmplt. Detail" temporary;
        lrecInsert: Record "DSD Route Stop Tmplt. Detail";
        lintLineNo: Integer;
    begin
        jxTestRouteFilter(pintSubformIndex);

        lrecTarget.Copy(precMoveMe);
        lrecTarget.SetRange("Route Sequence Template Code", precMoveMe."Route Sequence Template Code");
        lrecTarget.SetRange(Weekday, precMoveMe.Weekday);
        lrecTarget.SetRange(Route, precMoveMe.Route);

        if (lrecTarget.Find(ptxtDirection)) then begin
            lrecTEMP := lrecTarget;

            lrecTarget.TransferFields(precMoveMe, false);
            lrecTarget.Modify;

            precMoveMe.TransferFields(lrecTEMP, false);
            precMoveMe.Modify;

            CurrPage.subform.PAGE.jxBumpCurrIndex(ptxtDirection);
            CurrPage.subform.PAGE.jxUpdate;

        end;
    end;

    [Scope('Internal')]
    procedure jxApplySequence(pintSubformIndex: Integer)
    var
        lrecTEMP: Record "DSD Route Stop Tmplt. Detail" temporary;
        lrecReorder: Record "DSD Route Stop Tmplt. Detail";
        lcodRoute: Code[10];
        lintWeekday: Enum Weekdays;
    begin
        lintWeekday := goptWeekday;

        case pintSubformIndex of
            1:
                begin
                    lcodRoute := gcodRoute1;
                end;
            2:
                begin
                    lcodRoute := gcodRoute2;
                end;
            else begin
                    exit;
                end;
        end;

        lrecReorder.SetCurrentKey("New Sequence");
        lrecReorder.SetRange("New Sequence");
        lrecReorder.SetRange("Route Sequence Template Code", Code);
        lrecReorder.SetRange(Weekday, lintWeekday);
        lrecReorder.SetRange(Route, lcodRoute);

        if lrecReorder.FindSet then begin

            repeat
                lrecTEMP.Init;
                lrecTEMP."Route Sequence Template Code" := Code;
                lrecTEMP.Weekday := lintWeekday;
                lrecTEMP.Route := lcodRoute;
                lrecTEMP."Line No." += 10000;
                lrecTEMP.TransferFields(lrecReorder, false);
                lrecTEMP.Insert;
            until lrecReorder.Next = 0;

            lrecReorder.DeleteAll;

            if lrecTEMP.FindSet then begin
                repeat
                    lrecReorder.Init;
                    lrecReorder.TransferFields(lrecTEMP, true);
                    lrecReorder."New Sequence" := 0;
                    lrecReorder.Insert;
                until lrecTEMP.Next = 0;
            end;

        end;
    end;

    [Scope('Internal')]
    procedure jxUpdateSubforms()
    var
        lrecLines: Record "DSD Route Stop Tmplt. Detail";
    begin
        lrecLines.FilterGroup(8);

        lrecLines.SetRange("Route Sequence Template Code", Code);
        lrecLines.SetRange(Weekday, goptWeekday);
        lrecLines.SetRange(Route, gcodRoute1);

        CurrPage.subform.PAGE.SetTableView(lrecLines);
        CurrPage.subform.PAGE.jxUpdate;

        lrecLines.FilterGroup(0);
    end;

    [Scope('Internal')]
    procedure jxTestRouteFilter(pintSubformIndex: Integer)
    var
        lblnBlank: Boolean;
    begin

        case pintSubformIndex of
            1:
                begin
                    lblnBlank := gcodRoute1 = '';
                end;
            2:
                begin
                    lblnBlank := gcodRoute2 = '';
                end;
            else begin
                    exit;
                end;
        end;

        if lblnBlank then begin
            Error(jfText030, 'Route', '''');
        end;
    end;

    local procedure ActivateDSDDay(pintSubformIndex: Integer)
    var
        lcodRoute: Code[10];
        lrecRouteTemplate: Record "DSD Route Stop Template";
        ldat: Record Date;
        lintWeekday: Enum Weekdays;
    begin

        jxTestRouteFilter(pintSubformIndex);

        case pintSubformIndex of
            1:
                begin
                    lcodRoute := gcodRoute1;
                end;
            2:
                begin
                    lcodRoute := gcodRoute2;
                end;
            else begin
                    exit;
                end;
        end;

        lintWeekday := goptWeekday;

        ldat.SetRange("Period Type", ldat."Period Type"::Date);
        ldat.SetFilter("Period Start", '%1..%2', WorkDate, CalcDate('+6D', WorkDate));
        ldat.SetRange("Period No.", lintWeekday);
        ldat.FindFirst;

        lrecRouteTemplate.SetRange(Code, Code);
        lrecRouteTemplate.SetRange("Date Filter", ldat."Period Start");
        lrecRouteTemplate.SetRange("Weekday Filter", goptWeekday);
        lrecRouteTemplate.SetRange("Route Filter", lcodRoute);

    end;

    local procedure gcodRoute1OnAfterValidate()
    begin
        jxUpdateSubforms;
    end;

    local procedure goptWeekdayOnAfterValidate()
    begin
        jxUpdateSubforms;
    end;
}

