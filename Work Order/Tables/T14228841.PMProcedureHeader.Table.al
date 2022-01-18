table 23019250 "PM Procedure Header"
{
    DrillDownPageID = 23019287;
    LookupPageID = 23019287;

    fields
    {
        field(1; "Code"; Code[20])
        {

            trigger OnValidate()
            begin
                if Code <> xRec.Code then begin
                    grecPMSetup.Get;
                    gcduNoSeriesMgt.TestManual(grecPMSetup."PM Procedure Nos.");
                end;
            end;
        }
        field(2; "Version No."; Code[10])
        {
            Description = 'Editable=No';
            InitValue = '1';
        }
        field(4; Description; Text[80])
        {
        }
        field(5; "Starting Date"; Date)
        {
        }
        field(10; "Person Responsible"; Code[20])
        {
            TableRelation = Employee;
        }
        field(11; "PM Group Code"; Code[10])
        {
            TableRelation = "PM Group";
        }
        field(12; Status; Option)
        {
            OptionCaption = 'New,Under Development,Certified,Closed';
            OptionMembers = New,"Under Development",Certified,Closed;
        }
        field(13; "Work Order Freq."; DateFormula)
        {
        }
        field(14; "Last Work Order Date"; Date)
        {
            CalcFormula = Max (Table23019270.Field100 WHERE (Field3 = FIELD (Code)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; Type; Option)
        {
            OptionCaption = ' ,Machine Center,Work Center,Fixed Asset';
            OptionMembers = " ","Machine Center","Work Center","Fixed Asset";

            trigger OnValidate()
            begin
                if Type <> xRec.Type then
                    Validate("No.", '');
            end;
        }
        field(30; "No. Series"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(31; "PM Work Order No. Series"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(40; "PM Scheduling Type"; Option)
        {
            OptionCaption = 'Calendar,Cycles,Qty. Produced,Run Time,Stop Time';
            OptionMembers = Calendar,Cycles,"Qty. Produced","Run Time","Stop Time";

            trigger OnValidate()
            begin
                if ("PM Scheduling Type" = "PM Scheduling Type"::"Qty. Produced") or
                   ("PM Scheduling Type" = "PM Scheduling Type"::"Run Time") or
                   ("PM Scheduling Type" = "PM Scheduling Type"::"Stop Time")
                then
                    if not ((Type = Type::"Machine Center") or
                       (Type = Type::"Work Center")) then
                        FieldError(Type);
            end;
        }
        field(41; "Evaluation Qty."; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(42; "Schedule at %"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            InitValue = 100;
            MaxValue = 100;
            MinValue = 0;
        }
        field(43; "Multiple Calc. Methods"; Boolean)
        {
        }
        field(45; "Maintenance Time"; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(46; "Maintenance UOM"; Code[10])
        {
            TableRelation = "Capacity Unit of Measure";
        }
        field(50; "Contains Critical Control"; Boolean)
        {
            CalcFormula = Exist ("PM Procedure Line" WHERE ("PM Procedure Code" = FIELD (Code),
                                                           "Version No." = FIELD ("Version No."),
                                                           "Critical Control Point" = CONST (true)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(51; Comments; Boolean)
        {
            CalcFormula = Exist ("PM Proc. Comment" WHERE ("PM Procedure Code" = FIELD (Code),
                                                          "Version No." = FIELD ("Version No."),
                                                          "PM Procedure Line No." = CONST (0)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(60; "Qty. Produced"; Decimal)
        {
            CalcFormula = Sum ("Capacity Ledger Entry"."Output Quantity" WHERE (Type = FIELD ("Capacity Type Filter"),
                                                                               "No." = FIELD ("No."),
                                                                               "Posting Date" = FIELD ("Date Filter")));
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(61; "Capacity Qty."; Decimal)
        {
            CalcFormula = Sum ("Capacity Ledger Entry".Quantity WHERE (Type = FIELD ("Capacity Type Filter"),
                                                                      "No." = FIELD ("No."),
                                                                      "Posting Date" = FIELD ("Date Filter"),
                                                                      Field23019551 = CONST (false)));
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(62; Cycles; Decimal)
        {
            CalcFormula = Max ("PM Cycle History".Cycles WHERE (Type = FIELD (Type),
                                                               "No." = FIELD ("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(63; "Cycles at Last Work Order"; Decimal)
        {
            CalcFormula = Max (Table23019270.Field102 WHERE (Field3 = FIELD (Code),
                                                            Field20 = FIELD (Type),
                                                            Field101 = FIELD ("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(70; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(71; "Capacity Type Filter"; Option)
        {
            FieldClass = FlowFilter;
            OptionCaption = 'Work Center,Machine Center';
            OptionMembers = "Work Center","Machine Center";
        }
        field(101; "No."; Code[20])
        {
            TableRelation = IF (Type = CONST ("Machine Center")) "Machine Center"
            ELSE
            IF (Type = CONST ("Work Center")) "Work Center"
            ELSE
            IF (Type = CONST ("Fixed Asset")) "Fixed Asset";

            trigger OnValidate()
            begin
                if "No." <> '' then begin
                    TestField(Type);

                    case Type of
                        Type::"Machine Center":
                            begin
                                grecMachCenter.Get("No.");

                                "Serial No." := grecMachCenter."Serial No.";
                                Name := grecMachCenter.Name;
                            end;
                        Type::"Work Center":
                            begin
                                grecWorkCenter.Get("No.");

                                "Serial No." := grecWorkCenter."Serial No.";
                                Name := grecWorkCenter.Name;
                            end;
                        Type::"Fixed Asset":
                            begin
                                grecFA.Get("No.");

                                "Serial No." := grecFA."Serial No.";
                                Name := grecFA.Description;
                            end;
                    end;
                end else begin
                    Clear("Serial No.");
                    Clear(Name);
                end;
            end;
        }
        field(203; "Serial No."; Text[30])
        {
            Editable = false;
        }
        field(204; Name; Text[50])
        {
            Editable = false;
        }
        field(300; "Stop Time"; Decimal)
        {
            CalcFormula = Sum ("Capacity Ledger Entry".Quantity WHERE (Type = FIELD ("Capacity Type Filter"),
                                                                      "No." = FIELD ("No."),
                                                                      "Posting Date" = FIELD ("Date Filter"),
                                                                      Field23019551 = CONST (true)));
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code", "Version No.")
        {
            Clustered = true;
        }
        key(Key2; "Code", Status, "Starting Date", "Version No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DeleteRelations;

        if HasLinks then
            DeleteLinks;
    end;

    trigger OnInsert()
    begin
        if Code = '' then begin
            grecPMSetup.Get;
            grecPMSetup.TestField("PM Procedure Nos.");
            gcduNoSeriesMgt.InitSeries(
              grecPMSetup."PM Procedure Nos.",
              xRec."No. Series",
              0D, Code,
              "No. Series");
        end;
    end;

    trigger OnModify()
    begin
        CheckStatus;
    end;

    var
        JFText0001: Label 'Would you like to create a new version from %1, Version %2?';
        grecPMSetup: Record "PM Setup";
        gcduNoSeriesMgt: Codeunit NoSeriesManagement;
        grecFA: Record "Fixed Asset";
        grecMachCenter: Record "Machine Center";
        grecWorkCenter: Record "Work Center";

    [Scope('Internal')]
    procedure DeleteRelations()
    var
        lrecPMProcLine: Record "PM Procedure Line";
        lrecPMProcComments: Record "PM Proc. Comment";
        lrecPMCalcMethods: Record "PM Calc. Methods";
    begin
        lrecPMProcLine.SetRange("PM Procedure Code", Code);
        lrecPMProcLine.SetRange("Version No.", "Version No.");
        lrecPMProcLine.DeleteAll(true);

        lrecPMProcComments.SetRange("PM Procedure Code", Code);
        lrecPMProcComments.SetRange("Version No.", "Version No.");
        lrecPMProcComments.DeleteAll(true);

        lrecPMCalcMethods.SetRange("PM Procedure Code", Code);
        lrecPMCalcMethods.SetRange("Version No.", "Version No.");
        lrecPMCalcMethods.DeleteAll(true);
    end;

    [Scope('Internal')]
    procedure CheckStatus()
    begin
        if ((xRec.Status = Status) and (Status = Status::Certified)) then
            FieldError(Status);
        if (xRec.Code = '') and (Status = Status::Certified) then
            FieldError(Status);
    end;

    [Scope('Internal')]
    procedure AssistEdit(precOldPMProcedure: Record "PM Procedure Header"): Boolean
    var
        lrecPMProcedure: Record "PM Procedure Header";
    begin
        with lrecPMProcedure do begin
            lrecPMProcedure := Rec;
            grecPMSetup.Get;
            grecPMSetup.TestField("PM Procedure Nos.");
            if gcduNoSeriesMgt.SelectSeries(
                 grecPMSetup."PM Procedure Nos.",
                 precOldPMProcedure."No. Series",
                 "No. Series")
            then begin
                gcduNoSeriesMgt.SetSeries(Code);
                Rec := lrecPMProcedure;
                exit(true);
            end;
        end;
    end;

    [Scope('Internal')]
    procedure jfdoPrintReportSelections()
    var
        lrrfRecRef: RecordRef;
        lrecPMProc: Record "PM Procedure Header";
        lrecReportSelection: Record Table23019041;
    begin
        lrrfRecRef.GetTable(Rec);
        lrecReportSelection.SETRANGE("Table ID", lrrfRecRef.Number);
        lrecReportSelection.SETFILTER("Report ID", '<>0');
        lrecReportSelection.FINDSET;
        lrecPMProc.SetRange("No.", "No.");
        lrecPMProc.SetRange("Version No.", "Version No.");
        repeat
            REPORT.RunModal(lrecReportSelection."Report ID", true, false, lrecPMProc);
        until lrecReportSelection.NEXT = 0;
    end;
}

