page 51011 "DSD Templt. Stop Over."
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = all;
    UsageCategory = Lists;
    PageType = List;
    ShowFilter = false;
    SourceTable = "DSD Route Stop Tmplt. Detail";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Route Sequence Template Code", Weekday, Route, "Line No.");

    layout
    {
        area(content)
        {
            group(Control23019004)
            {
                ShowCaption = false;
                field(gcodRouteStopTempCodeFilter; gcodRouteStopTempCodeFilter)
                {
                    Caption = 'Route Stop Template Code';
                    TableRelation = "DSD Route Stop Template".Code;

                    trigger OnValidate()
                    var
                        lrecDSDRouteStopTemplate: Record "DSD Route Stop Template";
                    begin
                        lrecDSDRouteStopTemplate.Get(gcodRouteStopTempCodeFilter);
                        jfSetRoute;
                    end;
                }
                field(goptWeekdayFilter; goptWeekdayFilter)
                {
                    Caption = 'Weekday Filter';

                    trigger OnValidate()
                    begin
                        jfSetRoute;
                    end;
                }
            }
            repeater(Group)
            {
                field(Route; Route)
                {
                    Editable = false;
                }
                field("New Sequence"; "New Sequence")
                {
                    Caption = 'No. of Stops';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        jfSetRoute;
    end;

    var
        gcodRouteStopTempCodeFilter: Code[10];
        goptWeekdayFilter: Enum Weekdays;
        gcodRoute: Code[10];
        gintNoOfStops: Integer;

    [Scope('Internal')]
    procedure jfSetRoute()
    var
        lrecLocation: Record Location;
        lrecRSTD: Record "DSD Route Stop Tmplt. Detail";
    begin
        Reset;
        DeleteAll;
        if lrecLocation.FindSet then begin
            repeat
                Init;
                "Route Sequence Template Code" := gcodRouteStopTempCodeFilter;
                Weekday := goptWeekdayFilter;
                Route := lrecLocation.Code;

                lrecRSTD.SetRange("Route Sequence Template Code", gcodRouteStopTempCodeFilter);
                lrecRSTD.SetFilter(Weekday, '%1', goptWeekdayFilter);
                lrecRSTD.SetRange(Route, lrecLocation.Code);

                "New Sequence" := lrecRSTD.Count;
                Insert;

            until lrecLocation.Next = 0;
        end;
        Reset;
        if FindFirst then;
    end;

    [Scope('Internal')]
    procedure jfSetWeekday(pcodRouteStopTempCodeFilter: Code[10]; pintWeekday: Enum Weekdays)
    begin
        gcodRouteStopTempCodeFilter := pcodRouteStopTempCodeFilter;
        goptWeekdayFilter := pintWeekday;
    end;
}

