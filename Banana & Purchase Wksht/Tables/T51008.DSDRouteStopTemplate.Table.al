table 51008 "DSD Route Stop Template"
{
    LookupPageID = "DSD Route Stop Template List";

    fields
    {
        field(10; "Code"; Code[10])
        {
        }
        field(20; "Start Date"; Date)
        {

            trigger OnValidate()
            var
                lrecRouteTemplate: Record "DSD Route Stop Template";
                lrecRouteTemplateDetail: Record "DSD Route Stop Tmplt. Detail";
            begin
                TestField("Start Date");

                if ("End Date" = 0D) then begin
                    "End Date" := "Start Date";
                end;

 
                if ("Start Date" > "End Date") then begin
                    Error(jfText001, FieldCaption("Start Date"), FieldCaption("End Date"));
                end;

                lrecRouteTemplate.SetRange("Start Date", "Start Date", "End Date");

                if (lrecRouteTemplate.FindSet) then begin
                    repeat
                        if lrecRouteTemplate."Start Date" <> xRec."Start Date" then begin 
                            Error(jfText000, FieldCaption("Start Date"), TableCaption);
                        end;
                    until lrecRouteTemplate.Next = 0;
                end;

                

                lrecRouteTemplate.SetFilter("Start Date", '<%1', "Start Date");
                lrecRouteTemplate.SetFilter("End Date", '>=%1', "Start Date");

                if (lrecRouteTemplate.FindSet) then begin
                    repeat
                        if lrecRouteTemplate."Start Date" <> xRec."Start Date" then begin 
                            Error(jfText000, FieldCaption("Start Date"), TableCaption);
                        end;
                    until lrecRouteTemplate.Next = 0;
                end;

                lrecRouteTemplateDetail.SetRange("Route Sequence Template Code", Code);
                if lrecRouteTemplateDetail.FindSet(true) then begin
                    lrecRouteTemplateDetail.ModifyAll("Start Date", "Start Date");
                end;
            end;
        }
        field(30; "End Date"; Date)
        {

            trigger OnValidate()
            var
                lrecRouteTemplate: Record "DSD Route Stop Template";
                lrecRouteTemplateDetail: Record "DSD Route Stop Tmplt. Detail";
            begin

                TestField("End Date");

                if ("Start Date" = 0D) then begin
                    "Start Date" := "End Date";
                end;

                if ("Start Date" > "End Date") then begin
                    Error(jfText001, FieldCaption("End Date"), FieldCaption("Start Date"));
                end;
                lrecRouteTemplate.SetRange("End Date", "Start Date", "End Date");

                if (lrecRouteTemplate.FindSet) then begin
                    repeat
                        if lrecRouteTemplate."End Date" <> xRec."End Date" then begin
                            Error(jfText000, FieldCaption("End Date"), TableCaption);
                        end;
                    until lrecRouteTemplate.Next = 0;
                end;

                lrecRouteTemplate.SetFilter("Start Date", '<=%1', "End Date");
                lrecRouteTemplate.SetFilter("End Date", '>%1', "End Date");

                if (lrecRouteTemplate.FindSet) then begin
                    repeat
                        if lrecRouteTemplate."End Date" <> xRec."End Date" then begin
                            Error(jfText000, FieldCaption("End Date"), TableCaption);
                        end;
                    until lrecRouteTemplate.Next = 0;
                end;

                lrecRouteTemplateDetail.SetRange("Route Sequence Template Code", Code);
                if lrecRouteTemplateDetail.FindSet(true) then begin
                    lrecRouteTemplateDetail.ModifyAll("End Date", "End Date");
                end;
            end;
        }
        field(600; "Route Filter"; Code[10])
        {
            FieldClass = FlowFilter;
            TableRelation = Location;
        }
        field(601; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(602; "Weekday Filter"; Enum Weekdays)
        {
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; "Start Date", "End Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        lrecRouteTemplateDetail: Record "DSD Route Stop Tmplt. Detail";
    begin

        lrecRouteTemplateDetail.SetRange("Route Sequence Template Code", Code);
        if lrecRouteTemplateDetail.FindSet(true, true) then begin
            if not Confirm(jfText003, false, TableCaption, lrecRouteTemplateDetail.TableCaption) then begin
                Error(jfText004);
            end else begin
                lrecRouteTemplateDetail.DeleteAll;
            end;
        end;
    end;

    trigger OnInsert()
    begin
        TestField(Code);
    end;

    trigger OnModify()
    begin
        jxIntegrityCheck;
    end;

    trigger OnRename()
    begin
        jxIntegrityCheck;
    end;

    var
        jfText000: Label '%1 may not overlap with another %2';
        jfText001: Label '%1 must not be > %2';
        jfText003: Label '%1 contains %2 details; are you sure you wish to delete? (Details will also be deleted.)';
        jfText004: Label 'Aborting action based on your input.';

    [Scope('Internal')]
    procedure jxIntegrityCheck()
    begin
        TestField(Code);
        TestField("Start Date");
        TestField("End Date");
    end;
}

