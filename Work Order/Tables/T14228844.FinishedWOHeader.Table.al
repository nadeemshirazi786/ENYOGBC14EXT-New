table 14228844 "Finished WO Header"
{
    
    DrillDownPageID = 23019289;
    LookupPageID = 23019289;

    fields
    {
        field(1; "PM Work Order No."; Code[20])
        {
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
            CalcFormula = Max ("Finished WO Header"."Work Order Date" WHERE ("PM Procedure Code" = FIELD ("PM Procedure Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; Type; Option)
        {
            OptionCaption = ' ,Machine Center,Work Center,Fixed Asset';
            OptionMembers = " ","Machine Center","Work Center","Fixed Asset";
        }
        field(31; "PM Work Order No. Series"; Code[10])
        {
            TableRelation = "No. Series";
        }
        field(40; "PM Scheduling Type"; Option)
        {
            OptionCaption = 'Calendar,Cycles,Qty. Produced,Run Time,Stop Time';
            OptionMembers = Calendar,Cycles,"Qty. Produced","Run Time","Stop Time";
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
            CalcFormula = Exist ("Finished WO Line" WHERE ("PM Work Order No." = FIELD ("PM Work Order No."),
                                                          "Critical Control Point" = CONST (true)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(51; Comments; Boolean)
        {
            CalcFormula = Exist (Table23019274 WHERE (Field1 = FIELD ("PM Work Order No."),
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
        }
        field(101; "No."; Code[20])
        {
            TableRelation = IF (Type = CONST ("Machine Center")) "Machine Center"
            ELSE
            IF (Type = CONST ("Work Center")) "Work Center"
            ELSE
            IF (Type = CONST ("Fixed Asset")) "Fixed Asset";
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
            CalcFormula = Sum ("Finished WO Line"."PM Measure Cost" WHERE ("PM Work Order No." = FIELD ("PM Work Order No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(201; "PM WO Failure"; Boolean)
        {
            CalcFormula = Exist ("Finished WO Line" WHERE ("PM Work Order No." = FIELD ("PM Work Order No."),
                                                          "Critical Control Point" = CONST (true),
                                                          Result = CONST (Fail)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(202; "Test Complete"; Boolean)
        {
            CalcFormula = - Exist ("Finished WO Line" WHERE ("PM Work Order No." = FIELD ("PM Work Order No."),
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
    end;

    var
        JFText0001: Label 'Would you like to create a new version from %1, Version %2?';
        grecItem: Record Item;
        grecPMSetup: Record Table23019254;
        gcduNoSeriesMgt: Codeunit NoSeriesManagement;
        gcduUOMMgt: Codeunit "Unit of Measure Management";
        JFText0002: Label 'A PM Procedure Header has already been defaulted for this PM Work Order.  Choosing another setup will reset the PM Work Order.  Do you wish to continue?';
        JFText0003: Label 'Would you like to create an audit from %1, %2 %3?';
        gcduQualityVersionMgt: Codeunit Codeunit23019250;

    [Scope('Internal')]
    procedure DeleteRelations()
    var
        lrecFinPMWOLine: Record "Finished WO Line";
        lrecFinPMWOComments: Record Table23019274;
    begin
        lrecFinPMWOLine.SetRange("PM Work Order No.", "PM Work Order No.");
        lrecFinPMWOLine.DeleteAll(true);

        lrecFinPMWOComments.SETRANGE("PM Work Order No.", "PM Work Order No.");
        lrecFinPMWOComments.DELETEALL;
    end;

    [Scope('Internal')]
    procedure jfdoPrintReportSelections()
    var
        lrrfRecRef: RecordRef;
        lrecFinWO: Record "Finished WO Header";
        lrecReportSelection: Record Table23019041;
    begin
        lrrfRecRef.GetTable(Rec);
        lrecReportSelection.SETRANGE("Table ID", lrrfRecRef.Number);
        lrecReportSelection.SETFILTER("Report ID", '<>0');
        lrecReportSelection.FINDSET;
        lrecFinWO.SetRange("No.", "No.");
        repeat
            REPORT.RunModal(lrecReportSelection."Report ID", true, false, lrecFinWO);
        until lrecReportSelection.NEXT = 0;
    end;
}

