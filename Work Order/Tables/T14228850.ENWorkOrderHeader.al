table 14228850 "Work Order Header"
{
    DrillDownPageID = "PM Work Order List ELA";
    LookupPageID = "PM Work Order List ELA";

    fields
    {
        field(1; "PM Work Order No."; Code[20])
        {

            trigger OnValidate()
            begin
                if "PM Work Order No." <> xRec."PM Work Order No." then begin
                    grecPMSetup.GET;
                    gcduNoSeriesMgt.TestManual(grecPMSetup."PM Work Order Nos.");
                    "PM Work Order No. Series" := '';
                end;
            end;
        }
        field(2; "PM Proc. Version No."; Code[10])
        {
            Editable = false;
            TableRelation = Table23019250.Field2 WHERE (Field1 = FIELD ("PM Procedure Code"));
        }
        field(3; "PM Procedure Code"; Code[20])
        {
            TableRelation = Table23019250.Field1;
        }
        field(4; Description; Text[80])
        {
        }
        field(10; "Person Responsible"; Code[20])
        {
            TableRelation = Employee;
        }
        field(11; "PM Group Code"; Code[10])
        {
            TableRelation = Table23019287;
        }
        field(13; "Work Order Freq."; DateFormula)
        {
        }
        field(14; "Last Work Order Date"; Date)
        {
            CalcFormula = Max (Table23019270.Field100 WHERE (Field3 = FIELD ("PM Procedure Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; Type; Option)
        {
            OptionCaption = ' ,Machine Center,Work Center,Fixed Asset';
            OptionMembers = " ","Machine Center","Work Center","Fixed Asset";

            trigger OnValidate()
            begin
                if Type <> xRec.Type then begin
                    Validate("No.", '');
                end;
            end;
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
            CalcFormula = Exist ("Work Order Line" WHERE ("PM Work Order No." = FIELD ("PM Work Order No."),
                                                         "Critical Control Point" = CONST (true)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(51; Comments; Boolean)
        {
            CalcFormula = Exist (Table23019264 WHERE (Field1 = FIELD ("PM Work Order No."),
                                                     Field3 = CONST (0)));
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
            CalcFormula = Max (Table23019295.Field4 WHERE (Field1 = FIELD (Type),
                                                          Field2 = FIELD ("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(63; "Cycles at Last Work Order"; Decimal)
        {
            CalcFormula = Max (Table23019270.Field102 WHERE (Field3 = FIELD ("PM Procedure Code"),
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
        field(100; "Work Order Date"; Date)
        {

            trigger OnValidate()
            begin
                "Posting Date" := "Work Order Date";
            end;
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
        field(102; "Evaluated At Qty."; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(104; "Posting Date"; Date)
        {
        }
        field(106; "Location Code"; Code[10])
        {
            TableRelation = Location;
        }
        field(200; "Maintenance Cost"; Decimal)
        {
            CalcFormula = Sum ("Work Order Line"."PM Measure Cost" WHERE ("PM Work Order No." = FIELD ("PM Work Order No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(201; "PM WO Failure"; Boolean)
        {
            CalcFormula = Exist ("Work Order Line" WHERE ("PM Work Order No." = FIELD ("PM Work Order No."),
                                                         "Critical Control Point" = CONST (true),
                                                         Result = CONST (Fail)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(202; "Test Complete"; Boolean)
        {
            CalcFormula = - Exist ("Work Order Line" WHERE ("PM Work Order No." = FIELD ("PM Work Order No."),
                                                          "Test Complete" = CONST (false)));
            Editable = false;
            FieldClass = FlowField;
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
        key(Key1; "PM Work Order No.")
        {
            Clustered = true;
        }
        key(Key2; Type, "No.")
        {
        }
        key(Key3; "Work Order Date")
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
        if "PM Work Order No." = '' then begin
            if "PM Work Order No. Series" = '' then begin
                grecPMSetup.GET;
                grecPMSetup.TESTFIELD("PM Work Order Nos.");
                gcduNoSeriesMgt.InitSeries(grecPMSetup."PM Work Order Nos.", xRec."PM Work Order No. Series", "Posting Date",
                                           "PM Work Order No.", "PM Work Order No. Series");
            end else begin
                gcduNoSeriesMgt.InitSeries("PM Work Order No. Series", xRec."PM Work Order No. Series", "Posting Date",
                                           "PM Work Order No.", "PM Work Order No. Series");
            end;
        end;

        if "Work Order Date" = 0D then
            Validate("Work Order Date", WorkDate);
    end;

    var
        JFText0001: Label 'Would you like to create a new version from %1, Version %2?';
        grecItem: Record Item;
        grecPMSetup: Record Table23019254;
        gcduNoSeriesMgt: Codeunit NoSeriesManagement;
        gcduUOMMgt: Codeunit "Unit of Measure Management";
        JFText0002: Label 'A PM Procedure Header has already been defaulted for this PM Work Order.  Choosing another setup will reset the PM Work Order.  Do you wish to continue?';
        JFText0003: Label 'Would you like to create a PM Work Order from %1, %2 %3?';
        gcduPMMgt: Codeunit Codeunit23019250;
        grecFA: Record "Fixed Asset";
        grecMachCenter: Record "Machine Center";
        grecWorkCenter: Record "Work Center";

    [Scope('Internal')]
    procedure DeleteRelations()
    var
        lrecPMWOLine: Record "Work Order Line";
        lrecPMWOComments: Record Table23019264;
    begin
        lrecPMWOLine.SetRange("PM Work Order No.", "PM Work Order No.");
        lrecPMWOLine.DeleteAll(true);

        lrecPMWOComments.SETRANGE("PM Work Order No.", "PM Work Order No.");
        lrecPMWOComments.DELETEALL;
    end;

    [Scope('Internal')]
    procedure DefaultPMProcedure()
    var
        lrecPMProcedure: Record Table23019250;
        lrecPMProcLine: Record Table23019251;
        lrecPMPItemCons: Record Table23019252;
        lrecPMPResReq: Record Table23019253;
        lrecPMProcComments: Record Table23019258;
        lfrmPMProcedureList: Page Page23019287;
        lcduPMMgt: Codeunit Codeunit23019250;
    begin
        //Check to see if it's already associated with a QP
        if "PM Procedure Code" <> '' then begin
            if not Confirm(JFText0002, true) then
                exit;
            DeleteRelations;
            "PM Procedure Code" := '';
            "PM Proc. Version No." := '';
            Modify;
            Commit;
        end;

        if "PM Group Code" <> '' then
            lrecPMProcedure.SETRANGE("PM Group Code", "PM Group Code");
        lfrmPMProcedureList.SETTABLEVIEW(lrecPMProcedure);

        lfrmPMProcedureList.LOOKUPMODE := true;
        if lfrmPMProcedureList.RUNMODAL = ACTION::LookupOK then begin
            lfrmPMProcedureList.GETRECORD(lrecPMProcedure);
        end else begin
            exit;
        end;
        if not Confirm(JFText0003, true, lrecPMProcedure.Code, lrecPMProcedure.FIELDCAPTION("Version No."), lrecPMProcedure."Version No.")
        then
            exit;
        lcduPMMgt.CreatePMWOFromVersion("PM Work Order No.", lrecPMProcedure);
    end;

    [Scope('Internal')]
    procedure GetItem()
    begin
        Clear(grecItem);
        if "No." = '' then exit;
        if Type = Type::"Machine Center" then
            grecItem.Get("No.");
    end;

    [Scope('Internal')]
    procedure jfdoCreatePMWO()
    var
        lrecPMProcedure: Record Table23019250;
        lcodActiveVersion: Code[10];
        lrecPMWOHeader: Record "Work Order Header";
    begin
        lcodActiveVersion := gcduPMMgt.GetActiveVersion("PM Procedure Code");
        lrecPMProcedure.GET("PM Procedure Code", lcodActiveVersion);
        gcduPMMgt.CreatePMWOFromVersion("PM Work Order No.", lrecPMProcedure);

        if lrecPMWOHeader.Get("PM Work Order No.") then begin
            lrecPMWOHeader.Type := Type;
            lrecPMWOHeader.Validate("No.", "No.");
            lrecPMWOHeader."Location Code" := "Location Code";
            lrecPMWOHeader.Modify;
        end;
    end;

    [Scope('Internal')]
    procedure AssistEdit(precOldPMWOHeader: Record "Work Order Header"): Boolean
    var
        lrecPMWOHeader: Record "Work Order Header";
    begin
        with lrecPMWOHeader do begin
            lrecPMWOHeader.Copy(Rec);
            grecPMSetup.GET;

            grecPMSetup.TESTFIELD("PM Work Order Nos.");

            if gcduNoSeriesMgt.SelectSeries(grecPMSetup."PM Work Order Nos.",
                                            precOldPMWOHeader."PM Work Order No. Series",
                                            "PM Work Order No. Series") then begin
                gcduNoSeriesMgt.SetSeries("PM Work Order No.");

                Rec := lrecPMWOHeader;

                exit(true);
            end;
        end;
    end;

    [Scope('Internal')]
    procedure jfdoPrintReportSelections()
    var
        lrrfRecRef: RecordRef;
        lrecWO: Record "Work Order Header";
        lrecReportSelection: Record Table23019041;
    begin
        lrrfRecRef.GetTable(Rec);
        lrecReportSelection.SETRANGE("Table ID", lrrfRecRef.Number);
        lrecReportSelection.SETFILTER("Report ID", '<>0');
        lrecReportSelection.FINDSET;
        lrecWO.SetRange("No.", "No.");
        repeat
            REPORT.RunModal(lrecReportSelection."Report ID", true, false, lrecWO);
        until lrecReportSelection.NEXT = 0;
    end;
}
