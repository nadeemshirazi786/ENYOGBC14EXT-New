table 14229825 "PM Calc. Methods ELA"
{
    DrillDownPageID = "PM Calc. Methods";
    LookupPageID = "PM Calc. Methods";

    fields
    {
        field(1; "PM Procedure Code"; Code[20])
        {
        }
        field(2; "Version No."; Code[10])
        {
            Description = 'Editable=No';
            InitValue = '1';
        }
        field(13; "Work Order Freq."; DateFormula)
        {
        }
        field(14; "Last Work Order Date"; Date)
        {
            CalcFormula = Max ("Finished WO Header ELA"."Work Order Date" WHERE ("PM Procedure Code" = FIELD("PM Procedure Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; Type; Option)
        {
            OptionCaption = ' ,Machine Center,Work Center,Fixed Asset';
            OptionMembers = " ","Machine Center","Work Center","Fixed Asset";
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
                                                                      "Posting Date" = FIELD ("Date Filter")));
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(62; Cycles; Decimal)
        {
            CalcFormula = Max ("PM Cycle History ELA".Cycles WHERE (Type = FIELD (Type),
                                                               "No." = FIELD ("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(63; "Cycles at Last Work Order"; Decimal)
        {
            CalcFormula = Max ("Finished WO Header ELA"."Evaluated At Qty." WHERE ("PM Procedure Code" = FIELD ("PM Procedure Code"),
                                                            Type = FIELD (Type),
                                                            "No." = FIELD ("No.")));
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
        }
    }

    keys
    {
        key(Key1; "PM Procedure Code", "Version No.", "PM Scheduling Type")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CheckStatus;
    end;

    trigger OnInsert()
    begin
        CheckStatus;
        if grecPMProcedure.Get("PM Procedure Code", "Version No.") then begin
            Type := grecPMProcedure.Type;
            "No." := grecPMProcedure."No.";
        end;

        //<JF43786SHR>
        if ("PM Scheduling Type" = "PM Scheduling Type"::"Qty. Produced") or
           ("PM Scheduling Type" = "PM Scheduling Type"::"Run Time") or
           ("PM Scheduling Type" = "PM Scheduling Type"::"Stop Time")
        then
            if not ((Type = Type::"Machine Center") or
               (Type = Type::"Work Center")) then
                FieldError(Type);
        //</JF43786SHR>
    end;

    trigger OnModify()
    begin
        CheckStatus;
    end;

    trigger OnRename()
    begin
        CheckStatus;
    end;

    var
        JFText0001: Label 'Would you like to create a new version from %1, Version %2?';
        grecPMSetup: Record "PM Setup ELA";
        grecPMProcedure: Record "PM Procedure Header ELA";

    [Scope('Internal')]
    procedure CheckStatus()
    var
        lrecPMProcedure: Record "PM Procedure Header ELA";
    begin
        if lrecPMProcedure.Get("PM Procedure Code", "Version No.") then begin
            if lrecPMProcedure.Status = lrecPMProcedure.Status::Certified then
                lrecPMProcedure.FieldError(Status);
        end;
    end;
}

